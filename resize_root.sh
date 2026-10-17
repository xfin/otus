#!/usr/bin/env bash

set -euo pipefail

echo "=== LVM setup started: $(date) ==="

# ---------------------------------------------------------------
# Выполняем проверки
# ---------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Запускать только от root"; exit 1
fi

root_vg="ubuntu-vg"
root_lv="ubuntu-lv"
tg_root_size="8G"

# Свободные диски для temp-VG (/), для /var-mirror и /home.
# Например sdb, sdc, sdd, sde
t_disk="/dev/sdb"     # temp VG для переноса /
v_disk1="/dev/sdc"    # первый mirror для /var
v_disk2="/dev/sdd"    # второй mirror для /var

# Диск для /home — берём free space из root_vg, если есть,
# если нет - используем extra. Здесь считаем, что в VG есть место.

# ---------------------------------------------------------------
#  Уменьшаем / до 8G через временную VG
# ---------------------------------------------------------------

resize_root() {
    echo "--- Уменьшение / до ${tg_root_size} ---"

    # Готовим временную VG на отдельном диске
    pvcreate -ff -y "$t_disk"
    vgcreate vg_root "$t_disk"
    lvcreate -y -n lv_root -l +100%FREE vg_root

    # ФС и монтирование
    mkfs.ext4 -F /dev/vg_root/lv_root
    mkdir -p /mnt/newroot
    mount /dev/vg_root/lv_root /mnt/newroot

    # Перенос данных
    rsync -avxHAX --progress / /mnt/newroot/

    # Готовим chroot и обновляем grub/initrd
    for i in /proc /sys /dev /run /boot; do
        mount --bind "$i" "/mnt/newroot$i"
    done

    chroot /mnt/newroot /bin/bash -c "
        grub-mkconfig -o /boot/grub/grub.cfg
        update-initramfs -u
    "

    echo ">>> Перезагрузка для работы из временного /."
    echo ">>> После reboot запустите скрипт с аргументом: $0 after-reboot"
    umount -R /mnt/newroot || true
    reboot
}

# После первой перезагрузки
resize_root_2() {
    echo "--- Шаг 2: возврат на уменьшенный корневой том ---"

    # Удаляем старый LV и создаём новый на 8G
    lvremove -y /dev/${root_vg}/${root_lv}
    lvcreate -y -n ${root_lv} -L ${tg_root_size} /dev/${root_vg}
    mkfs.ext4 -F /dev/${root_vg}/${root_lv}

    # Переносим текущий / на новый LV
    mount /dev/${root_vg}/${root_lv} /mnt/newroot
    rsync -avxHAX --progress / /mnt/newroot/

    # chroot + grub/initrd
    for i in /proc /sys /dev /run /boot; do
        mount --bind "$i" "/mnt/newroot$i"
    done

    chroot /mnt/newroot /bin/bash -c "
        grub-mkconfig -o /boot/grub/grub.cfg
        update-initramfs -u
    "

    umount -R /mnt/newroot

    # Удаляем временную VG
    lvremove -y /dev/vg_root/lv_root
    vgremove -y vg_root
    pvremove -y "$t_disk"

    echo ">>> Перезагрузка на уменьшенный /."
    echo ">>> Затем: $0 after-reboot-2"
    reboot
}

# ---------------------------------------------------------------
# Создаем /var в mirror
# ---------------------------------------------------------------
setup_var_mirror() {
    echo "--- Создание /var (mirror) ---"

    pvcreate -ff -y "$v_disk1" "$v_disk2"
    vgcreate vg_var "$v_disk1" "$v_disk2"

    lvcreate -y -L 950M -m1 -n lv_var vg_var
    mkfs.ext4 -F /dev/vg_var/lv_var

    # Копируем /var
    mkdir -p /mnt/newvar
    mount /dev/vg_var/lv_var /mnt/newvar
    cp -aR /var/. /mnt/newvar/

    # Бэкап старого /var
    mkdir -p /var_old
    rsync -aHAX /var/ /var_old/

    # Монтируем новый /var
    umount /mnt/newvar
    mount /dev/vg_var/lv_var /var

    # fstab
    local uuid
    uuid=$(blkid -s UUID -o value /dev/vg_var/lv_var)
    grep -q "$uuid" /etc/fstab || \
        echo "UUID=$uuid /var ext4 defaults,noatime 0 2" >> /etc/fstab

    echo "--- /var в mirror создан ---"
}

# ---------------------------------------------------------------
# Создаем /home
# ---------------------------------------------------------------
setup_home() {
    echo "--- Создание /home ---"

    lvcreate -y -n LogVol_Home -L 2G /dev/${root_vg}
    mkfs.ext4 -F /dev/${root_vg}/LogVol_Home

    mkdir -p /mnt/newhome
    mount /dev/${root_vg}/LogVol_Home /mnt/newhome
    cp -aR /home/. /mnt/newhome/ || true

    # Чистим /home и монтируем LV
    find /home -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    umount /mnt/newhome
    mount /dev/${root_vg}/LogVol_Home /home

    # fstab
    local uuid
    uuid=$(blkid -s UUID -o value /dev/${root_vg}/LogVol_Home)
    grep -q "$uuid" /etc/fstab || \
        echo "UUID=$uuid /home ext4 defaults,noatime 0 2" >> /etc/fstab

    echo "--- /home создан ---"
}

# ---------------------------------------------------------------
# ---------------------------------------------------------------
case "${1:-}" in
    "")
        resize_root
        ;;
    after-reboot)
        resize_root_2
        ;;
    after-reboot-2)
        setup_var_mirror
        setup_home
        echo "=== Готово. Проверьте: lsblk, lvs, cat /etc/fstab ==="
        ;;
    *)
        echo "Usage: $0 [after-reboot|after-reboot-2]"; exit 1
        ;;
esac