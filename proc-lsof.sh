#!/bin/bash

# Аналог lsof на основе файловой системы /proc

set -u
export LC_ALL=C

show_help() {
    cat <<EOF
Использование: $0 [PID]

Без аргументов: показать открытые дескрипторы всех доступных процессов.
С аргументом PID: показать дескрипторы указанного процесса.

Примеры:
  sudo $0
  sudo $0 1234
  sudo $0 | tee output.txt
EOF
}

# Проверка аргументов
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ $# -gt 1 ]]; then
    show_help >&2
    exit 1
fi

if [[ $# -eq 1 && ! "$1" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: PID должен быть числом." >&2
    exit 1
fi

# Получение списка процессов
if [[ $# -eq 1 ]]; then
    proc_list="/proc/$1"
    if [[ ! -d "$proc_list" ]]; then
        echo "Ошибка: процесс с PID $1 не найден." >&2
        exit 1
    fi
    processes=("$proc_list")
else
    shopt -s nullglob
    processes=(/proc/[0-9]*)
fi

# Заголовок таблицы
printf "%-10s %-20s %-8s %s\n" \
    "PID" "COMMAND" "FD" "TARGET"

printf '%s\n' "--------------------------------------------------------------------------"

# Обработка процессов
for proc_dir in "${processes[@]}"; do

    pid="${proc_dir##*/}"

    # Дополнительная проверка PID
    [[ "$pid" =~ ^[0-9]+$ ]] || continue

    # Получение имени процесса
    comm="unknown"

    if IFS= read -r comm < "$proc_dir/comm" 2>/dev/null; then
        :
    else
        comm="unknown"
    fi

    # Получение открытых файловых дескрипторов
    fd_dir="$proc_dir/fd"

    [[ -d "$fd_dir" ]] || continue

    shopt -s nullglob
    fd_list=("$fd_dir"/*)

    for fd_path in "${fd_list[@]}"; do

        # Проверяем, что элемент является символической ссылкой
        [[ -L "$fd_path" ]] || continue

        # Получаем путь, на который указывает дескриптор
        target=$(readlink -- "$fd_path" 2>/dev/null) || continue

        fd="${fd_path##*/}"

        # Вывод результата
        printf "%-10s %-20s %-8s %s\n" \
            "$pid" "$comm" "$fd" "$target"

    done
	
done
