#!/usr/bin/bash

# Parametres

WIFI_ID="wifi_xxx_managed_psk"
WIFI_PASSWD="hello"

DRIVE_LABEL="nvme0n1"
DRIVE_LABEL_boot="nvme0n1p1"
DRIVE_LABEL_swap="nvme0n1p2"
DRIVE_LABEL_root="nvme0n1p3"

BOOT_label="boot"
ROOT_label="alpine"
SWAP_label="RAM_co"
VOLUME_label="drive_space"

ENCRYPTION_PASSWD="test098765"

TIMEZONE="Europe/Copenhagen"
HOSTNAME="alpine_host"
LANGUAGE="da_DK.UTF-8"
KEYMAP="dk-latin1"

LANGUAGE_GEN1="da_DK.UTF-8"
LANGUAGE_GEN2="de_DE.UTF-8"
LANGUAGE_GEN3="en_GB.UTF-8"

ROOT_PASSWD="root1234"
USERNAME="runit"
USERNAME_PASSWD="Alpine12345"

BOOTLOADER_label="alpine_runit"

# Network-configuration

rfkill unblock wifi
connmanctl
  enable wifi
  scan wifi
  services
  agent on
  connect $WIFI_ID
  $WIFI_PASSWD
  exit

# Partitions; 325M boot-, 8GB swap- and then a BTRFS-partition

badblocks -c 10240 -s -w -t random -v /dev/$DRIVE_label

parted /dev/$DRIVE_label

mklabel gpt
mkpart ESP fat32 1MiB 325MiB
set 1 boot on
name 1 $BOOT_label

mkpart primary 325MiB 8325MiB
name 2 $SWAP_label

mkpart primary 8325MiB 100%
name 3 $ROOT_label

quit

# ROOT-encryption

cryptsetup luksFormat --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random /dev/$DRIVE_LABEL_root
$ENCRYPTION_PASSWD
$ENCRYPTION_PASSWD

cryptsetup open /dev/DRIVE_LABEL_root cryptroot

# Drive-formatting

mkfs.vfat -F32 /dev/$DRIVE_LABEL_boot

mkswap -L $SWAP_label /dev/$DRIVE_LABEL_swap

mkfs.btrfs -l $ROOT_label /dev/mapper/cryptroot

# BTRFS-subvolumes

mount -o noatime,compress=lz4,discard,ssd,defaults /dev/mapper/cryptroot /mnt
cd /mnt
  btrfs subvolume create @
  btrfs subvolume create @home
  btrfs subvolume create @pkg
  btrfs subvolume create @snapshots
cd 
umount /mnt

mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots}
mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@pkg /dev/mapper/cryptroot /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
sync

# Drive-mount

mount /dev/$DRIVE_LABEL_boot /mnt/boot

swapon /dev/$DRIVE_LABEL_swap

# Base-install

basestrap /mnt base base-devel neovim nano runit linux linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 cryptsetup

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

fstabgen -U /mnt >> /mnt/etc/fstab

# Chroot

artix-chroot /mnt

/bin/bash

# Setting up time

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systoch

# Setting up locals

sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen
sed -i 's/^# *\($LANGUAGE_GEN3\)/\1/' /etc/locale.gen

locale.gen

echo "LANG=$LANGUAGE" >> /etc/locale.conf
echo "keymap="$KEYMAP$"" >> /etc/conf.d/keymaps

# Regenerating initramfs with encrypt-hook

sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Setting up GRUB

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=$BOOTLOADER_label --recheck

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=\/dev\/$DRIVE_LABEL_root:cryptroot\ root=\/dev\/mapper\/cryptroot\ rootflags=subvol=@\/rootvol\ quiet"/' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

# Setting root-password + creating personal user

passwd
$ROOT_PASSWD

useradd -m -G users -g video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel $USERNAME
passwd $USERNAME
$USERNAME_PASSWD

# Setting up hostname

echo "$HOSTNAME" >> /etc/hostname

cat >> /etc/hosts<< EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

# Setting NetworkManager to start on boot

ln -s /etc/runit/sv/NetworkManager /run/runit/service 

# Allow users to use sudo

echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

# Farewell

exit
exit
umount -R /mnt
reboot
