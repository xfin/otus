#!/usr/bin/env bash

# Включаем обработку ошибок
set -Eeuo pipefail

raid="/dev/md0"

# Вырубаем всё при ошибке
die() {
    echo "ошибка: $*" >&2
    exit 1
}

# Проверки необходимого ПО
[[ $EUID -eq 0 ]] || die "Скрипт должен запускаться через sudo."
command -v mdadm >/dev/null || die "mdadm не установлен."
command -v lsblk >/dev/null || die "Не найдена команда lsblk."
command -v wipefs >/dev/null || die "Не найдена команда wipefs."

# Проверка на существование RAID
[[ ! -e "$raid" ]] || die "$raid уже существует."

echo "Создание RAID-1"
echo "Введите имена двух дисков (например /dev/sdb и /dev/sdc)"
echo "Системный диск использовать нельзя."
echo

read -r -p "Первый диск: " disk1
read -r -p "Второй диск: " disk2

# Проверки на правильность указанных дисков
[[ "$disk1" != "$disk2" ]] || die "Нужно выбрать два разных диска."

for disk in "$disk1" "$disk2"; do
    [[ "$disk" =~ ^/dev/[a-zA-Z0-9._/-]+$ ]] ||
        die "Некорректное имя устройства: $disk"

    [[ -b "$disk" ]] || die "Устройство $disk не найдено."
    [[ "$(lsblk -dn -o TYPE "$disk")" == "disk" ]] ||
        die "$disk не является целым диском."

    # Запрещаем использовать диск, на котором находится ОС
    root_source="$(findmnt -n -o SOURCE /)"
    root_parent="$(lsblk -s -n -o NAME "$root_source" 2>/dev/null | tail -n 1 || true)"
    disk_name="$(basename "$disk")"

    if [[ "$root_source" == "$disk" ]] ||
       lsblk -s -n -o NAME "$root_source" 2>/dev/null |
           grep -Fxq "$disk_name"; then
        die "$disk связан с корневой файловой системой."
    fi

    if lsblk -nr -o MOUNTPOINTS "$disk" |
        grep -q '[^[:space:]]'; then
        die "$disk или один из его разделов смонтирован."
    fi

    if wipefs -n "$disk" 2>/dev/null | grep -q .; then
        die "На $disk обнаружены сигнатуры. Сначала проверь его вручную."
    fi

    # Проверяем, не является ли диск участником другого MD-массива.
    if mdadm --examine "$disk" >/dev/null 2>&1; then
        die "На $disk обнаружены RAID-метаданные."
    fi
done

echo
echo "Будет создан массив $raid уровня RAID-1."
echo "Диски: $disk1 и $disk2"
read -r -p "Для подтверждения введи YES: " confirm

[[ "$confirm" == "YES" ]] || die "Отменено пользователем."

mdadm --zero-superblock --force "$disk1" "$disk2"
mdadm --create "$raid" --metadata=1.2 --level=1 --raid-devices=2 "$disk1" "$disk2"

echo
echo "Массив создан. Проверка состояния:"
cat /proc/mdstat
mdadm --detail "$raid"