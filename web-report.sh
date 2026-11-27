#!/bin/bash

# Настройки
LOG_DIR="/var/log/nginx"
EMAIL="xfin@bk.ru"
STATE="/var/lib/web-report/last_run"
LOCK="/var/lock/web-report.lock"
TOP=10

# Очистка временного файла
cleanup() {
    [[ -n "$TMP" && -f "$TMP" ]] && rm -f "$TMP"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Защита от параллельного запуска
mkdir -p "$(dirname "$STATE")"
exec 9>"$LOCK"
flock -n 9 || exit 0

# Время отчёта
NOW=$(date +%s)
START=$(cat "$STATE" 2>/dev/null)

[[ "$START" =~ ^[0-9]+$ ]] || START=$((NOW - 3600))
(( START < NOW )) || START=$((NOW - 3600))

FROM=$(date -d "@$START" "+%d.%m.%Y %H:%M:%S")
TO=$(date -d "@$NOW" "+%d.%m.%Y %H:%M:%S")

TMP=$(mktemp)

# Поиск текущих и ротированных журналов
mapfile -d '' ACCESS_FILES < <(
    find "$LOG_DIR" -maxdepth 1 -type f -name 'access.log*' ! -name '*.gz' -print0
)

mapfile -d '' ERROR_FILES < <(
    find "$LOG_DIR" -maxdepth 1 -type f -name 'error.log*' ! -name '*.gz' -print0
)

if ((${#ACCESS_FILES[@]} == 0)); then
    echo "Не найдены журналы access.log" >&2
    exit 1
fi

# Сбор статистики запросов
collect_stats() {
    TZ=UTC gawk -v start="$START" -v end="$NOW" '
    BEGIN {
        split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", m)
        for (i=1; i<=12; i++) month[m[i]]=i
    }
    {
        ts=$4
        gsub(/^\[/, "", ts)
        split(ts,d,/[\/:]/)

        if (!(d[2] in month)) next

        epoch=mktime(d[3] " " month[d[2]] " " d[1] " " d[4] " " d[5] " " d[6])

        offset=$5
        gsub(/]/, "", offset)
        seconds=substr(offset,2,2)*3600 + substr(offset,4,2)*60
        if (substr(offset,1,1)=="-") seconds=-seconds
        epoch-=seconds

        if (epoch<=start || epoch>end) next

        ip_count[$1]++
        url_count[$7]++
        code_count[$9]++
        total++
    }
    END {
        print "TOTAL\t" total
        for (i in ip_count) print "IP\t" ip_count[i] "\t" i
        for (i in url_count) print "URL\t" url_count[i] "\t" i
        for (i in code_count) print "CODE\t" code_count[i] "\t" i
    }' "${ACCESS_FILES[@]}"
}

# Вывод рейтинга
print_top() {
    local TYPE="$1"
    local TITLE="$2"

    echo "$TITLE"
    echo "$STATS" |
        awk -F '\t' -v type="$TYPE" '$1==type {print $2 "\t" $3}' |
        sort -k1,1nr | head -n "$TOP" |
        awk -F '\t' '{print $2 " — " $1 " запросов"}'
}

# Вывод ошибок Nginx за отчётный период
report_errors() {
    echo "ОШИБКИ NGINX:"

    if ((${#ERROR_FILES[@]} == 0)); then
        echo "Журналы ошибок не найдены"
        return
    fi

    sed -nE '/\[(warn|error|crit|alert|emerg)\]/p' "${ERROR_FILES[@]}" |
    gawk -v start="$START" -v end="$NOW" '
    {
        split($1,d,"/")
        split($2,t,":")

        epoch=mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3])

        if (epoch>start && epoch<=end)
            print
    }' | tail -n 20
}

# Формирование статистики
STATS=$(collect_stats) || exit 1

# Формирование письма
{
    echo "ОТЧЁТ О РАБОТЕ NGINX"
    echo "Сервер: $(hostname)"
    echo "Период: $FROM - $TO"
    echo
    echo "Всего запросов: $(echo "$STATS" | awk -F '\t' '$1=="TOTAL"{print $2}')"
    echo

    print_top "IP" "ТОП IP-АДРЕСОВ:"
    echo

    print_top "URL" "ТОП URL:"
    echo

    echo "HTTP-КОДЫ:"
    echo "$STATS" |
        awk -F '\t' '$1=="CODE"{print $2 "\t" $3}' |
        sort -k1,1nr |
        awk -F '\t' '{print $2 " — " $1 " запросов"}'

    echo
    report_errors

} > "$TMP"

# Отправка отчёта
if mail -s "Nginx report: $(hostname)" "$EMAIL" < "$TMP"; then
    printf '%s\n' "$NOW" > "$STATE.tmp" &&
        mv "$STATE.tmp" "$STATE"
    echo "Отчёт отправлен успешно"
else
    echo "Ошибка отправки отчёта" >&2
    exit 1
fi
