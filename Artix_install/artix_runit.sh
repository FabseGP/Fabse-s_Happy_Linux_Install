#!/usr/bin/bash

# Parameters

  VALID_ENTRY_intro=false
  VALID_ENTRY_wifi=false
  VALID_ENTRY_swap=false
  VALID_ENTRY_encryption=false
  VALID_ENTRY_subvolumes=false

  INTRO_choices=""

  VALID_ENTRY_drive=false
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
  DRIVE_check=""

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

# Insure that the script is run as root-user

  if [ "$USER" = 'root' ]; then

    echo "Sorry, this script must be run as root"
    exit 1

  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Introduction

  more welcome.txt # Prints the content of the file
   
  echo

  echo "To tailor the installation to your needs, you have the following choices: "

  echo

  until [ $VALID_ENTRY_intro == "true" ]; do 

    until [ $VALID_ENTRY_wifi == "true" ]; do 

      read -rp "Do you plan to use WiFi (unnesscary if using ethernet)? If no, please type \"1\" - if yes, please type \"2\": " WIFI_choice

      if [[ $WIFI_choice == "1" ]]; then
  
        echo
  
        echo "WiFi will therefore not be initialised"
    
        echo

        VALID_ENTRY_wifi=true

      elif [[ $WIFI_choice = "2" ]]; then

        echo

        echo "WiFi will therefore be initialised"
    
        echo

        VALID_ENTRY_wifi=true

      fi

      if [[ $WIFI_choice -ne 1 ]] && [[ $WIFI_choice -ne 2 ]]; then 

        VALID_ENTRY_wifi=false
        
        echo 

        echo "Invalid answer. Please try again"

        echo
     
      fi
      done
 
    echo

    until [ $VALID_ENTRY_encryption == "true" ]; do 

      read -rp "Any thoughts on encryption? Type \"1\" for skipping encryption, \"2\" for setting encryption: " ENCRYPTION_choice

      if [[ $ENCRYPTION_choice == "1" ]]; then
  
        echo
  
        echo "The main partition will not be encrypted"
    
        echo
  
        VALID_ENTRY_encryption=true

      elif [[ $ENCRYPTION_choice = "2" ]]; then

        echo

        echo "The main partition will be encrypted"
    
        echo

        VALID_ENTRY_encryption=true

      fi

      if [[ $ENCRYPTION_choice -ne 1 ]] && [[ $ENCRYPTION_choice -ne 2 ]]; then 

        VALID_ENTRY_encryption=false
        
        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
      done
 
    echo

    until [ $VALID_ENTRY_swap == "true" ]; do 

      read -rp "Any thoughts on a swap-partition? Type \"1\" to skip creating a swap-partition, \"2\" to create a swap-partition: " SWAP_choice

      if [[ $SWAP_choice == "1" ]]; then
  
        echo
  
        echo "No SWAP-partition will be created"
    
        echo

        VALID_ENTRY_swap=true
  
      elif [[ $SWAP_choice = "2" ]]; then

        echo

        echo "The size of the SWAP-partition will be set later on"
    
        echo

        VALID_ENTRY_swap=true

      fi

      if [[ $SWAP_choice -ne 1 ]] && [[ $SWAP_choice -ne 2 ]]; then 

        VALID_ENTRY_swap=false
        
        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
      done
 
    echo
  
    until [ $VALID_ENTRY_subvolumes == "true" ]; do 

      read -rp "Any thoughts on subvolumes for BTRFS? Type \"1\" to not have subvolumes, \"2\" to have subvolumes: " SUBVOLUMES_choice

      if [[ $SUBVOLUMES_choice == "1" ]]; then
  
        echo
  
        echo "A BTRFS-partition will be created without subvolumes"
    
        echo

        VALID_ENTRY_subvolumes=true
  
      elif [[ $SUBVOLUMES_choice = "2" ]]; then

        echo

        echo "The BTRFS-partition will consists of subvolumes"
    
        echo

        VALID_ENTRY_subvolumes=true

      fi    

      if [[ $SUBVOLUMES_choice -ne 1 ]] && [[ $SUBVOLUMES_choice -ne 2 ]]; then 

        VALID_ENTRY_subvolumes=false
        
        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
      done
 
    echo

    echo "You have chosen the following choices: "

    more text

    read -rp "Is everything fine? Type \"YES\" if yes, \"NO\" if no: " INTRO_choice

    if [[ $INTRO_choice == "YES" ]]; then 

      VALID_ENTRY_intro=true

      else 

       echo "Back to square one!"

    fi
  done 

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Network-configuration

  if [[ $WIFI_choice == 2 ]]; then

    more network.txt

    echo

    echo "You're wifi-card is about to be activated"

    echo

    rfkill unblock wifi
    connmanctl enable wifi
    connmanctl scan wifi
    connmanctl services
    connmanctl services > wifi_list
    connmanctl agent on

    echo

    read -rp "Please type the WIFI-name from the list above, which you wish to connect to: " WIFI_SSID
    
    echo
  
    echo "You have chosen $WIFI_SSID"
    
    echo
    
    WIFI_ID=sed -n "s //^.*$WIFI_SSID\s*\(\S*\)/\1/p" wifi_list
    rm wifi_list

    connmanctl connect "$WIFI_ID" 

  echo
    
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Partitions

  more partitions.txt

  echo

  fdisk -l

  VALID_ENTRY_drive=false

  echo

  echo "Which drive do you want to partition?"

  until [ $VALID_ENTRY_drive == "true" ]; do 

    read -r DRIVE_LABEL
    OUTPUT="fdisk -l | sed -n "s/^.*\("$DRIVE_LABEL"\).*$/\1/p""

    if [[ $DRIVE_LABEL == "$OUTPUT" ]]; then 

        VALID_ENTRY_drive=true

    else
 
       echo "Invalid drive. Please try again"

       echo

    fi
  done 
 
  read -rp "You have chosen ""$DRIVE_LABEL"" - is that the correct drive? Type \"1\" for no, \"2\" for yes: " DRIVE_check

  if [[ $DRIVE_check == "1" ]]; then

    echo "Sorry, you have to execute the scipt again :("
      
    exit 1

  fi

  if [[ $SWAP_choice == "1" ]]; then

    DRIVE_LABEL_boot="$DRIVE_LABEL""1"
    DRIVE_LABEL_root="$DRIVE_LABEL""2"

    badblocks -c 10240 -s -w -t random -v "$DRIVE_LABEL"

    read -rp "Any favourite size for the boot-partition in MB? Though minimum 256MB; only type the size without units: " BOOT_size

    echo
  
    echo "The boot-partition is set to be $BOOT_size"
    
    echo

    read -rp "A special name for the boot-partition? " BOOT_label

    echo
  
    echo "The boot-partition will be named $BOOT_label"
    
    echo

    read -rp "A special name for the primary partition? " ROOT_label

    echo
  
    echo "The primary partition will be named $ROOT_label"

    echo

    parted "$DRIVE_LABEL"

    mklabel gpt

    mkpart ESP fat32 1MiB "$BOOT_size"MiB
    set 1 boot on
    name 1 "$BOOT_label"

    mkpart primary "$BOOT_size"MiB 100%
    name 2 "$ROOT_label"

    quit

  elif [[ $SWAP_choice == "2" ]]; then

    DRIVE_LABEL_boot="$DRIVE_LABEL""1"
    DRIVE_LABEL_swap="$DRIVE_LABEL""2"
    DRIVE_LABEL_root="$DRIVE_LABEL""3"

    badblocks -c 10240 -s -w -t random -v "$DRIVE_LABEL"

    read -rp "Any favourite size for the boot-partition in MB? Though minimum 256MB; only type the size without units: " BOOT_size

    echo
  
    echo "The boot-partition is set to be $BOOT_size"
    
    echo

    read -rp "A special name for the boot-partition? " BOOT_label

    echo
  
    echo "The boot-partition will be named $BOOT_label"
    
    echo

    read -rp "Any favourite size for the SWAP-partition in MB? " SWAP_size

    echo
  
    echo "The SWAP-partition is set to be $SWAP_size"
    
    echo

    read -rp "A special name for the SWAP-partition? " SWAP_label

    echo
  
    echo "The SWAP-partition will be named $SWAP_label"
    
    echo

    read -rp "A special name for the primary partition? " ROOT_label

    echo
  
    echo "The primary partition will be named $ROOT_label"

    echo

    parted "$DRIVE_LABEL"

    mklabel gpt

    mkpart ESP fat32 1MiB "$BOOT_size"MiB
    set 1 boot on
    name 1 "$BOOT_label"

    mkpart primary "$BOOT_size"MiB "$SWAP_size"MiB
    name 2 "$SWAP_label"

    mkpart primary "$SWAP_size"MiB 100%
    name 3 "$ROOT_label"

    quit

  echo

  fi

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if [[ $ENCRYPTION_choice == 2 ]]; then

    more encryptions.txt

    echo

    echo "Please have your encryption-password ready "

    echo

    cryptsetup luksFormat --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random "$DRIVE_LABEL"

    cryptsetup open /dev/DRIVE_LABEL_root cryptroot

    echo
    
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-formatting

  more formatting.txt

  echo "A favourite filesystem for the root-drive? BTRFS of course!"

  mkfs.vfat -F32 "$DRIVE_LABEL_boot"

  mkswap -L "$SWAP_label" "$DRIVE_LABEL_swap"

  mkfs.btrfs -l "$ROOT_label" /dev/mapper/cryptroot

  echo

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

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-mount

  mount "$DRIVE_LABEL_boot" /mnt/boot

  swapon /"$DRIVE_LABEL_swap"

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Base-install

  basestrap /mnt base base-devel neovim nano runit linux linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 cryptsetup

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

  more fstab.txt

  fstabgen -U /mnt >> /mnt/etc/fstab
 
  echo

  read -rp "If unsure / want to do a double check, enter \"1\"; if not, enter \"2\": " FSTAB_double_check

  echo

  if [[ $FSTAB_double_check == 2 ]]; then
  
    fdisk -l

    echo
    
    more /mnt/etc/fstab

    echo

    read -rp "Does everything seems right? Type \"1\" for no, \"2\" for yes: " FSTAB_confirm
    
    echo
  
  fi
    
    if [[ $FSTAB_confirm == 2 ]]; then

      echo "Sorry, you have to execute the scipt again :("
      
      exit 1

  fi

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Chroot

  artix-chroot /mnt

  /bin/bash

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  more time.txt

  echo

  echo "Do you know your local timezone?"

  echo "Example: Europe/Copenhagen"

  read -r TIMEZONE

  ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
  hwclock --systoch

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals

  more locals.txt

  echo

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

  echo

  echo "Any thoughts on the system-wide language?"

  echo "Example: da_DK.UTF-8"

  read -r LANGUAGE

  echo "LANG=$LANGUAGE" >> /etc/locale.conf

  echo

  echo "Any thoughts on the system-wide keymap?"

  echo "Example: dk-latin1"

  read -r KEYMAP

  echo "keymap=""$KEYMAP""" >> /etc/conf.d/keymaps
  
  echo "keymap=""$KEYMAP""" >> /etc/vconsole.conf

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Regenerating initramfs with encrypt-hook

  more initramfs.txt

  sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
  mkinitcpio -p linux

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up GRUB

  more GRUB.txt

  echo

  read -rp "Any fitting name for the bootloader? " BOOTLOADER_label

  echo
  
  echo "The bootloader will be viewed as $BOOTLOADER_label in the BIOS"

  echo

  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="$BOOTLOADER_label" --recheck

  echo

  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=\/dev\/$DRIVE_LABEL_root:cryptroot\ root=\/dev\/mapper\/cryptroot\ rootflags=subvol=@\/rootvol\ quiet"/' /etc/default/grub

  echo

  grub-mkconfig -o /boot/grub/grub.cfg

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting root-password + creating personal user

  more users.txt

  echo

  echo "Any thoughts on a root-password"?

  read -r ROOT_PASSWD

  passwd
  $ROOT_PASSWD

  echo

  echo "Can I suggest a username?"

  read -r USERNAME

  echo

  echo "A password too?"

  read -r USERNAME_PASSWD

  useradd -m -G users -g video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel "$USERNAME"

  passwd "$USERNAME"
  $USERNAME_PASSWD

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up hostname

  more hostname.txt

  echo

  echo "Is there a name that you want to host?"

  read -r HOSTNAME

  echo "$HOSTNAME" >> /etc/hostname

  cat > /etc/hosts<< "EOF"
  127.0.0.1 localhost
  ::1 localhost
  127.0.1.1 $HOSTNAME.localdomain $HOSTNAME     
EOF

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting NetworkManager to start on boot

  ln -s /etc/runit/sv/NetworkManager /run/runit/service 

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Allow users to use sudo

  echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Farewell

  more farewell.txt

  echo

  exit
  exit
  umount -R /mnt
  reboot
 
