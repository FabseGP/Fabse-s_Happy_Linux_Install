#!/usr/bin/bash

# Parameters

  SWAP_choice = ""
  ENCRYPTION_choice = ""
  SUBVOLUMES_choice = ""
  WIFI_choice = ""

  WIFI_SSID = ""

  BOOT_size = ""
  SWAP_size = ""

  DRIVE_label = ""

  BOOT_label = ""
  ROOT_label = ""
  SWAP_label = ""

  FSTAB_double_check = ""

  TIMEZONE = ""
  HOSTNAME = ""
  LANGUAGE = ""
  KEYMAP = ""

  LANGUAGE_how_many = ""

  ROOT_passwd = ""
  USERNAME = ""
  USERNAME_passwd = ""

  BOOTLOADER_label = ""

  PACKAGE_choice = ""

#----------------------------------------------------------------------------------------------------------------------------------

# Introduction

  echo "Welcome"

  echo "You are about to install Artix Linux with Runit as init"

  echo "Are you using ethernet now? If yes, then you probably don't need to set up WiFi"
  echo "and can simply type "no". If no or if you want to use WiFi, then type "yes""

  read WIFI_choice

  echo "Any thoughts on encryption? Type "yes" for setting encryption, "no" for not setting encryption"

  read ENCRYPTION_choice

  echo "Any thoughts on a swap-partition? Type "yes" for having a swap-partition, "no" for not having a swap-partition"

  read SWAP_choice

  echo "Any thoughts on subvolumes for BTRFS? Type "yes" for having subvolumes, "no" for not having subvolumes

  read SUBVOLUMES_choice

#----------------------------------------------------------------------------------------------------------------------------------

# Network-configuration

  if (WIFI_choice = yes)

  {

    echo "You're wifi-card is about to be activated"

    rfkill unblock wifi
    connmanctl enable wifi
    connmanctl scan wifi
    connmanctl services
    connmanctl services > wifi_list
    connmanctl agent on

    echo "Please select wifi name"
    read WIFI_SSID

    WIFI_ID = sed -n "s //^.*$WIFI_SSID\s*\(\S*\)/\1/p" wifi_list
    rm wifi_list

    connmanctl connect $WIFI_ID

  }

#----------------------------------------------------------------------------------------------------------------------------------

# Partitions

  lsblk

  echo "What is your drive profile name from the list above?"

  read DRIVE_label

  DRIVE_boot = "$DRIVE_label1"
  DRIVE_swap = "$DRIVE_label2"
  DRIVE_root = "$DRIVE_label3"

  badblocks -c 10240 -s -w -t random -v /dev/$DRIVE_label

  parted /dev/$DRIVE_label

  echo "Any favourite size for the boot-partition in MB?"

  read BOOT_size

  echo "A special name for the boot-partition?"

  read BOOT_label

  mklabel gpt
  mkpart ESP fat32 1MiB $BOOT_sizeMiB
  set 1 boot on
  name 1 $BOOT_label

  echo "Any favourite size for the swap-partition in MB?"

  read SWAP_size

  echo "A special name for the swap-partition?"

  read SWAP_label

  mkpart primary $BOOT_sizeMiB $SWAP_sizeMiB
  name 2 $SWAP_label

  echo "A special name for the root-partition?"

  read ROOT_label

  mkpart primary $SWAP_sizeMiB 100%
  name 3 $ROOT_label

  quit

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if (ENCRYPTION_choice = yes)

  {

    echo "Please have your encryption-password ready"

    cryptsetup luksFormat --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random /dev/$DRIVE_label

    cryptsetup open /dev/DRIVE_LABEL_root cryptroot

  }

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-formatting

  echo "A favourite filesystem for the root-drive? BTRFS of course!"

  mkfs.vfat -F32 /dev/$DRIVE_LABEL_boot

  mkswap -L $SWAP_label /dev/$DRIVE_LABEL_swap

  mkfs.btrfs -l $ROOT_label /dev/mapper/cryptroot

#----------------------------------------------------------------------------------------------------------------------------------

# BTRFS-subvolumes

  mount -o noatime,compress=lz4,discard,ssd,defaults /dev/mapper/cryptroot /mnt
  cd /mnt
    btrfs subvolume create @
    btrfs subvolume create @home
    btrfs subvolume create @pkg
    btrfs subvolume create @snapshots
  cd /

  umount /mnt

  mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@ /dev/mapper/cryptroot /mnt
  mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots}
  mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@home /dev/mapper/cryptroot /mnt/home
  mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@pkg /dev/mapper/cryptroot /mnt/var/cache/pacman/pkg
  mount -o noatime,nodiratime,compress=lz4,space_cache,ssd,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots

  sync

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-mount

  mount /dev/$DRIVE_LABEL_boot /mnt/boot

  swapon /dev/$DRIVE_LABEL_swap

#----------------------------------------------------------------------------------------------------------------------------------

# Base-install

  basestrap /mnt base base-devel neovim nano runit linux linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 cryptsetup

#----------------------------------------------------------------------------------------------------------------------------------

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

  fstabgen -U /mnt >> /mnt/etc/fstab

  echo "If unsure / want to do a double check, enter "yes"; if not, enter "no""

  read FSTAB_double

  if (FSTAB_double = yes)

  {
  
    fdisk -l

  }

#----------------------------------------------------------------------------------------------------------------------------------

# Chroot

  artix-chroot /mnt

  /bin/bash

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  echo "Do you know your local timezone?"

  echo "Example: Europe/Copenhagen"

  read TIMEZONE

  ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  hwclock --systoch

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals

  echo "How many languages do you plan to use? No wrong answers, unless it is above 3!"

  read LANGUAGE_size

  if ((LANGUAGE_size = 0) or (LANGUAGE_size > 3))

  {

     echo "Please try again; I don't have time for this!
  
  }

  if (LANGUAGE_size = 1)

  {

    echo "What language do you wish to generate?
  
    echo "Example: da_DK.UTF-8"

    read LANGUAGE_GEN1

    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen

  }

  if (LANGUAGE_size = 2)

  { 

    echo "What languages do you wish to generate?
  
    echo "Example: da_DK.UTF-8"

    read LANGUAGE_GEN1

    echo "Second language"

    read LANGUAGE_GEN2

    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
    sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen

  }

  if (LANGUAGE_size = 3)

  {

    echo "What languages do you wish to generate?
  
    echo "Example: da_DK.UTF-8"

    read LANGUAGE_GEN1

    echo "Second language"

    read LANGUAGE_GEN2

    echo "Third language"

    read LANGUAGE_GEN3

    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
    sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen
    sed -i 's/^# *\($LANGUAGE_GEN3\)/\1/' /etc/locale.gen

  }

  locale.gen

  echo "Any thoughts on the system-wide language?"

  echo "Example: da_DK.UTF-8"

  read LANGUAGE

  echo "LANG=$LANGUAGE" >> /etc/locale.conf

  echo "Any thoughts on the system-wide keymap?"

  echo "Example: dk-latin1"

  read KEYMAP

  echo "keymap="$KEYMAP$"" >> /etc/conf.d/keymaps

#----------------------------------------------------------------------------------------------------------------------------------

# Regenerating initramfs with encrypt-hook

  sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
  mkinitcpio -p linux

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up GRUB

  echo "Any fitting name for the bootloader?"

  read BOOTLOADER_label

  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=$BOOTLOADER_label --recheck

  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=\/dev\/$DRIVE_LABEL_root:cryptroot\ root=\/dev\/mapper\/cryptroot\ rootflags=subvol=@\/rootvol\ quiet"/' /etc/default/grub

  grub-mkconfig -o /boot/grub/grub.cfg

#----------------------------------------------------------------------------------------------------------------------------------

# Setting root-password + creating personal user

  echo "Any thoughts on a root-password"?

  read ROOT_PASSWD

  passwd
  $ROOT_PASSWD

  echo "Can I suggest a username?"

  read USERNAME

  echo "A password too?"

  read USERNAME_PASSWD

  useradd -m -G users -g video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel $USERNAME
  passwd $USERNAME
  $USERNAME_PASSWD

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up hostname

  echo "Is there a name that you want to host?"

  read HOSTNAME

  echo "$HOSTNAME" >> /etc/hostname

  cat >> /etc/hosts<< EOF
  127.0.0.1 localhost
  ::1 localhost
  127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
  EOF

#----------------------------------------------------------------------------------------------------------------------------------

# Setting NetworkManager to start on boot

  ln -s /etc/runit/sv/NetworkManager /run/runit/service 

#----------------------------------------------------------------------------------------------------------------------------------

# Allow users to use sudo

  echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

#----------------------------------------------------------------------------------------------------------------------------------

# Farewell

  exit
  exit
  umount -R /mnt
  reboot