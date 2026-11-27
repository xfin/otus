
#!/bin/bash

# Настройки
ACCESS_LOG="/var/log/nginx/access.log"
ERROR_LOG="/var/log/nginx/error.log"
EMAIL="to@example"
STATE="/var/lib/web-report/last_run"
TOP=10

# Защита от параллельного запуска
mkdir -p "$(dirname "$STATE")"
exec 9>/var/lock/web-report.lock
flock -n 9 || exit 0

NOW=$(date +%s)
START=$(cat "$STATE" 2>/dev/null)

[[ "$START" =~ ^[0-9]+$ ]] || START=$((NOW - 3600))
(( START < NOW )) || START=$((NOW - 3600))

FROM=$(date -d "@$START" "+%d.%m.%Y %H:%M:%S")
TO=$(date -d "@$NOW" "+%d.%m.%Y %H:%M:%S")

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

# Статистика запросов
STATS=$(TZ=UTC gawk -v start="$START" -v end="$NOW" '
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
    sign=substr(offset,1,1)
    seconds=substr(offset,2,2)*3600 + substr(offset,4,2)*60
    if (sign=="-") seconds=-seconds
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
}
' "$ACCESS_LOG") || exit 1

# Формирование письма
{
    echo "ОТЧЁТ О РАБОТЕ NGINX"
    echo "Сервер: $(hostname)"
    echo "Период: $FROM - $TO"
    echo
    echo "Всего запросов: $(echo "$STATS" | awk -F'\t' '$1=="TOTAL"{print $2}')"

    echo
    echo "ТОП IP-АДРЕСОВ:"
    echo "$STATS" | awk -F'\t' '$1=="IP"{print $2 "\t" $3}' |
        sort -k1,1nr | head -n "$TOP" |
        awk -F'\t' '{print $2 " — " $1 " запросов"}'

    echo
    echo "ТОП URL:"
    echo "$STATS" | awk -F'\t' '$1=="URL"{print $2 "\t" $3}' |
        sort -k1,1nr | head -n "$TOP" |
        awk -F'\t' '{print $2 " — " $1 " запросов"}'

    echo
    echo "HTTP-КОДЫ:"
    echo "$STATS" | awk -F'\t' '$1=="CODE"{print $2 "\t" $3}' |
        sort -k1,1nr |
        awk -F'\t' '{print $2 " — " $1}'

    echo
    echo "ОШИБКИ NGINX:"

    if [[ -r "$ERROR_LOG" ]]; then
        gawk -v start="$START" -v end="$NOW" '
        {
            split($1,d,"/")
            split($2,t,":")

            epoch=mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3])

            if (epoch>start && epoch<=end &&
                $0 ~ /\[(warn|error|crit|alert|emerg)\]/)
                print
        }' "$ERROR_LOG" | tail -n 20
    else
        echo "Журнал ошибок недоступен"
    fi

} > "$TMP"

# Отправка отчёта
if mail -s "Nginx report: $(hostname)" "$EMAIL" < "$TMP"; then
    echo "$NOW" > "$STATE"
    echo "Отчёт отправлен успешно"
else
    echo "Ошибка отправки отчёта" >&2
    exit 1
fi
