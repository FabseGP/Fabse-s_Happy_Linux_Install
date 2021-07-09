#!/usr/bin/bash

# Parameters

  VALID_ENTRY=false
  INPUT=""
  OUTPUT=""
  
  SWAP_choice=""
  ENCRYPTION_choice=""
  SUBVOLUMES_choice=""
  WIFI_choice=""

  WIFI_SSID=""
  WIFI_ID=""

  BOOT_size=""
  SWAP_size=""

  DRIVE_LABEL=""
  DRIVE_LABEL_boot=""
  DRIVE_LABEL_swap=""
  DRIVE_LABEL_root=""

  BOOT_label=""
  ROOT_label=""
  SWAP_label=""

  FSTAB_double_check=""
  FSTAB_confirm=""

  TIMEZONE=""
  HOSTNAME=""
  LANGUAGE=""
  KEYMAP=""

  LANGUAGE_how_many=""
  LANGUAGE_GEN1=""
  LANGUAGE_GEN2=""
  LANGUAGE_GEN3=""  

  ROOT_passwd=""
  USERNAME=""
  USERNAME_passwd=""

  BOOTLOADER_label=""

  PACKAGE_choice=""

#----------------------------------------------------------------------------------------------------------------------------------

# Introduction

  more welcome.txt # Prints the content of the file
   
  read -rp "Are you using ethernet now? If yes, then you probably don't need to set up WiFi. Typing "1" skips setting up WiFi, while typing "2" will make it to set up WiFi: " WIFI_choice

  if [[ $WIFI_choice == "1" ]]; then
  
    echo
  
    echo "WiFi will therefore not be initialised"
    
    echo
  
  elif [[ $WIFI_choice = "2" ]]; then

    echo

    echo "WiFi will therefore be initialised"
    
    echo

  fi
  
  read -rp "Any thoughts on encryption? Type "1" for skipping encryption, "2" for setting encryption: " ENCRYPTION_choice

  if [[ $ENCRYPTION_choice == "1" ]]; then
  
    echo
  
    echo "The main partition will not be encrypted"
    
    echo
  
  elif [[ $ENCRYPTION_choice = "2" ]]; then

    echo

    echo "The main partition will be encrypted"
    
    echo

  fi

  read -rp "Any thoughts on a swap-partition? Type "1" to skip creating a swap-partition, "2" to create a swap-partition: " SWAP_choice

  if [[ $SWAP_choice == "1" ]]; then
  
    echo
  
    echo "No SWAP-partition will be created"
    
    echo
  
  elif [[ $SWAP_choice = "2" ]]; then

    echo

    echo "The size of the SWAP-partition will be set later on"
    
    echo

  fi
  
  read -rp "Any thoughts on subvolumes for BTRFS? Type "1" to not have subvolumes, "2" to have subvolumes: " SUBVOLUMES_choice

  if [[ $SUBVOLUMES_choice == "1" ]]; then
  
    echo
  
    echo "A BTRFS-partition will be created without subvolumes"
    
    echo
  
  elif [[ $SUBVOLUMES_choice = "2" ]]; then

    echo

    echo "The BTRFS-partition will consists of subvolumes"
    
    echo

  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Network-configuration

  if [[ $WIFI_choice == 2 ]]; then

    more network.txt

    echo "You're wifi-card is about to be activated"

    rfkill unblock wifi
    connmanctl enable wifi
    connmanctl scan wifi
    connmanctl services
    connmanctl services > wifi_list
    connmanctl agent on

    read -p "Please type the WIFI-name from the list above, which you wish to connect to: " WIFI_SSID
    
    echo
  
    echo "You have chosen $WIFI_SSID"
    
    echo
    
    WIFI_ID=sed -n "s //^.*$WIFI_SSID\s*\(\S*\)/\1/p" wifi_list
    rm wifi_list

    connmanctl connect "$WIFI_ID" 
    
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Partitions

  more partitions.txt

  fdisk -l

  VALID_ENTRY=false
  echo "Which drive do you want to partition?"
  until [ $VALID_ENTRY == true ]; do 
    read DRIVE_LABEL
    OUTPUT = fdisk -l | sed -n "s/^.*\($DRIVE_LABEL\).*$/\1/p"
      if [[ "$DRIVE_LABEL" == *"$OUTPUT"* ]]; then 
        VALID_ENTRY=true
      else 
       echo "Invalid drive. Try again."
     fi
    done 
    
  DRIVE_LABEL_boot="$DRIVE_LABEL""1"
  DRIVE_LABEL_swap="$DRIVE_LABEL""2"
  DRIVE_LABEL_root="$DRIVE_LABEL""3"

  badblocks -c 10240 -s -w -t random -v /dev/"$DRIVE_LABEL"

  parted /dev/"$DRIVE_LABEL"

  read -rp "Any favourite size for the boot-partition in MB? " BOOT_size

  echo
  
  echo "The boot-partition is set to be $BOOT_size"
    
  echo

  read -rp "A special name for the boot-partition? " BOOT_label

  echo
  
  echo "The boot-partition will be named $BOOT_label"
    
  echo

  mklabel gpt

  mkpart ESP fat32 1MiB "$BOOT_size"MiB
  set 1 boot on
  name 1 "$BOOT_label"

  read -rp "Any favourite size for the SWAP-partition in MB? " SWAP_size

  echo
  
  echo "The SWAP-partition is set to be $SWAP_size"
    
  echo

  read -rp "A special name for the SWAP-partition? " SWAP_label

  echo
  
  echo "The SWAP-partition will be named $SWAP_label"
    
  echo

  mkpart primary "$SWAP_size"MiB
  name 2 "$SWAP_label"

  read -rp "A special name for the primary partition? " ROOT_label

  echo
  
  echo "The primary partition will be named $ROOT_label"

  echo

  mkpart primary "$SWAP_size"MiB 100%
  name 3 "$ROOT_label"

  quit

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if [[ $ENCRYPTION_choice == 2 ]]; then

    more encryptions.txt

    echo "Please have your encryption-password ready"

    cryptsetup luksFormat --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random /dev/"$DRIVE_LABEL"

    cryptsetup open /dev/DRIVE_LABEL_root cryptroot
    
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-formatting

  more formatting.txt

  echo "A favourite filesystem for the root-drive? BTRFS of course!"

  mkfs.vfat -F32 /dev/"$DRIVE_LABEL_boot"

  mkswap -L "$SWAP_label" /dev/"$DRIVE_LABEL_swap"

  mkfs.btrfs -l "$ROOT_label" /dev/mapper/cryptroot

#----------------------------------------------------------------------------------------------------------------------------------

# BTRFS-subvolumes

 if [[ $SUBVOLUMES_choice == 2 ]]; then

    more subvolumes.txt

    mount -o noatime,compress=lz4,discard,ssd,defaults /dev/mapper/cryptroot /mnt
    cd /mnt || return
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

  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-mount

  mount /dev/"$DRIVE_LABEL_boot" /mnt/boot

  swapon /dev/"$DRIVE_LABEL_swap"

#----------------------------------------------------------------------------------------------------------------------------------

# Base-install

  basestrap /mnt base base-devel neovim nano runit linux linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 cryptsetup

#----------------------------------------------------------------------------------------------------------------------------------

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

  more fstab.txt

  fstabgen -U /mnt >> /mnt/etc/fstab

  read -rp "If unsure / want to do a double check, enter "1"; if not, enter "2": " FSTAB_double_check

  echo

  if [[ $FSTAB_double_check == 2 ]]; then
  
    fdisk -l
    
    more /mnt/etc/fstab

    read -rp "Does everything seems right? Type "1" for no, "2" for yes: " FSTAB_confirm
    
    echo
    
    if [[ $FSTAB_confirm == 2 ]]; then

      echo "Sorry, you have to execute the scipt again :("
      
      exit 1

  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Chroot

  artix-chroot /mnt

  /bin/bash

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  more time.txt

  echo "Do you know your local timezone?"

  echo "Example: Europe/Copenhagen"

  read -r TIMEZONE

  ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
  hwclock --systoch

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals

  more locals.txt

  read -rp "How many languages do you plan to use? No wrong answers, unless it is above 3!: " LANGUAGE_how_many

  echo
  
  echo "$LANGUAGE_how_many languages will be generated"

  echo
  
  if [[ "$LANGUAGE_how_many" == 0 ]] || [[ "$LANGUAGE_how_many" -gt 3 ]]; then

    echo "Please try again; I don't have time for this!"

    read -rp "How many languages do you plan to use? No wrong answers, unless it is above 3!: " LANGUAGE_how_many

    echo
  
    echo "$LANGUAGE_how_many languages will be generated"

    echo

  fi

  if [[ $LANGUAGE_how_many == 1 ]]; then

    echo "What language do you wish to generate?"
  
    echo "Example: da_DK.UTF-8"

    read -r LANGUAGE_GEN1
    
    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen

  fi


  if [[ $LANGUAGE_how_many == 2 ]]; then

    echo "Which languages do you wish to generate?"
  
    echo "Example: da_DK.UTF-8"

    read -r LANGUAGE_GEN1

    echo "Second language"

    read -r LANGUAGE_GEN2

    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
    sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen

  fi

   if [[ $LANGUAGE_how_many == 3 ]]; then

     echo "Which languages do you wish to generate?"
  
     echo "Example: da_DK.UTF-8"

     read -r LANGUAGE_GEN1

     echo "Second language"

     read -r LANGUAGE_GEN2

     echo "Third language"

     read -r LANGUAGE_GEN3

     sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
     sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen
     sed -i 's/^# *\($LANGUAGE_GEN3\)/\1/' /etc/locale.gen

  fi

  locale.gen

  echo "Any thoughts on the system-wide language?"

  echo "Example: da_DK.UTF-8"

  read LANGUAGE

  echo "LANG=$LANGUAGE" >> /etc/locale.conf

  echo "Any thoughts on the system-wide keymap?"

  echo "Example: dk-latin1"

  read KEYMAP

  echo "keymap="$KEYMAP$"" >> /etc/conf.d/keymaps
  
  echo "keymap="$KEYMAP$"" >> /etc/vconsole.conf

#----------------------------------------------------------------------------------------------------------------------------------

# Regenerating initramfs with encrypt-hook

  more initramfs.txt

  sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
  mkinitcpio -p linux

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up GRUB

  more GRUB.txt

  read -p "Any fitting name for the bootloader? " BOOTLOADER_label

  echo
  
  echo "The bootloader will be viewed as $BOOTLOADER_label in the BIOS"

  echo

  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=$BOOTLOADER_label --recheck

  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=\/dev\/$DRIVE_LABEL_root:cryptroot\ root=\/dev\/mapper\/cryptroot\ rootflags=subvol=@\/rootvol\ quiet"/' /etc/default/grub

  grub-mkconfig -o /boot/grub/grub.cfg

#----------------------------------------------------------------------------------------------------------------------------------

# Setting root-password + creating personal user

  more users.txt

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

  more hostname.txt

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

  more farewell.txt

  exit
  exit
  umount -R /mnt
  reboot
  
