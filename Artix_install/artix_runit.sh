#!/usr/bin/bash

# Parameters

  SWAP_choice=""
  ENCRYPTION_choice=""
  SUBVOLUMES_choice=""
  WIFI_choice=""
  INTRO_choice=""

  VALID_ENTRY_choices=""
  VALID_ENTRY_intro_check=""
  INTRO_proceed=""

  WIFI_SSID=""
  WIFI_check=""
  VALID_ENTRY_wifi_check=""
  WIFI_proceed=""
  WIFI_ID=""

  VALID_ENTRY_drive=""
  VALID_ENTRY_drive_choice=""
  OUTPUT=""
  DRIVE_check=""
  DRIVE_proceed=""

  VALID_ENTRY_drive_size_format=""
  VALID_ENTRY_drive_size=""
  VALID_ENTRY_drive_size_check=""
  BOOT_size=""
  SWAP_size=""
  BOOT_size_check=""
  SWAP_size_check=""

  VALID_ENTRY_drive_name=""
  VALID_ENTRY_drive_name_check=""
  BOOT_label=""
  SWAP_label=""
  PRIMARY_label=""
  BOOT_label_check=""
  SWAP_label_check=""
  PRIMARY_label_check=""

  DRIVE_LABEL=""
  DRIVE_LABEL_boot=""
  DRIVE_LABEL_swap=""
  DRIVE_LABEL_primary=""

  FSTAB_check=""
  VALID_ENTRY_fstab_check=""
  FSTAB_proceed=""
  FSTAB_confirm=""
  VALID_ENTRY_fstab_confirm_check=""

  VALID_ENTRY_timezone=""
  TIMEZONE_1=""
  TIMEZONE_2=""
  TIME_check=""
  VALID_ENTRY_time_check=""
  TIME_proceed=""

  LANGUAGE_how_many=""
  LANGUAGE_GEN1=""
  LANGUAGE_GEN2=""
  LANGUAGE_GEN3=""  
  LANGUAGE=""
  VALID_ENTRY_languages=""
  LOCALS_check=""
  VALID_ENTRY_locals_check=""
  LOCALS_proceed=""

  KEYMAP=""
  VALID_ENTRY_keymap=""
  KEYMAP_check=""
  VALID_ENTRY_keymap_check=""
  KEYMAP_proceed=""

  HOSTNAME=""
  HOSTNAME_check=""
  VALID_ENTRY_hostname_check=""
  HOSTNAME_proceed=""

  ROOT_passwd=""
  ROOT_check=""
  VALID_ENTRY_root_check=""
  ROOT_proceed=""

  USERNAME=""
  USERNAME_passwd=""
  USER_check=""
  VALID_ENTRY_user_check=""
  USER_proceed=""

  BOOTLOADER_label=""
  BOOTLOADER_check=""
  VALID_ENTRY_bootloader_check=""
  BOOTLOADER_proceed=""

  PACKAGES=""
  PACKAGES_check=""
  VALID_ENTRY_packages_check=""
  PACKAGES_proceed=""

  SUMMARY=""
  SUMMARY_check=""
  VALID_ENTRY_summary_check=""
  SUMMARY_proceed="" # Rebooting if true

#----------------------------------------------------------------------------------------------------------------------------------

# Colors for the output

  print(){
    case $1 in
      red)
        echo -e "\033[31m$2\033[0m"
        ;;
      green)
        echo -e "\033[32m$2\033[0m"
        ;;
      yellow)
        echo -e "\033[33m$2\033[0m"
        ;;
      blue)
        echo -e "\033[34m$2\033[0m"
        ;;
      cyan)
        echo -e "\033[36m$2\033[0m"
        ;;
      purple)
        echo -e "\033[37m$2\033[0m"
        ;;
      white)
        echo -e "\033[37m$2\033[0m"
        ;;
    esac
}

#----------------------------------------------------------------------------------------------------------------------------------

# Lines between each part of the installation

  lines(){
  echo "--------------------------------------------------------------------------------------------------------------------------"
  echo
}

#----------------------------------------------------------------------------------------------------------------------------------

# 1 = [X], anything else = [ ]

  checkbox() { 
    [[ "$1" -eq 2 ]] && echo -e "${BBlue}[${Reset}${Bold}X${BBlue}]${Reset}" || echo -e "${BBlue}[ ${BBlue}]${Reset}";
}

#----------------------------------------------------------------------------------------------------------------------------------

# Until-loop; intro

  until_loop_intro() {
    type="$1"
    type_choice="$2"
    until [ "$VALID_ENTRY_choices" == "true" ]; do 
      read -rp "Do you plan to utilise ""${type,,}""? If no, please type \"1\" - if yes, please type \"2\": " type_choice
      echo
      if [[ $type_choice == "1" ]]; then
        print yellow """$1"" will therefore not be configured"
        echo
        VALID_ENTRY_choices=true
      elif [[ $type_choice == "2" ]]; then
        print green """$1"" will therefore be configured"
        echo
        VALID_ENTRY_choices=true
      elif [[ $type_choice -ne 1 ]] && [[ $type_choice -ne 2 ]]; then 
        VALID_ENTRY_choices=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
    if [[ $type == "WiFi" ]]; then
      WIFI_choice=$type_choice
    elif [[ $type == "Swap" ]]; then
      SWAP_choice=$type_choice
    elif [[ $type == "Encryption" ]]; then
      ENCRYPTION_choice=$type_choice
    elif [[ $type == "Subvolumes" ]]; then
      SUBVOLUMES_choice=$type_choice
    fi
    type=""
    type_choice=""
    VALID_ENTRY_choices=""
}

#----------------------------------------------------------------------------------------------------------------------------------

# Until-loop; disk-name

  until_loop_drive_name() {
    drive="$1"
    drive_name="$2"
    drive_name_check="$3"
    until [ "$VALID_ENTRY_drive_name" == "true" ]; do 
      VALID_ENTRY_drive_name_check=false # Necessary for trying again
      read -rp "A special name for the ""$drive""-partition? " drive_name
      echo
      until [ "$VALID_ENTRY_drive_name_check" == "true" ]; do 
        read -rp "The ""$drive""-partition will be named \"$drive_name\". Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " drive_name_check
        echo
        if [[ $drive_name_check == "YES" ]]; then
          print yellow "You'll get a new prompt"
          VALID_ENTRY_drive_name_check=true
          VALID_ENTRY_drive_name=false
          echo
        elif [[ $drive_name_check == "NO" ]]; then
          VALID_ENTRY_drive_name_check=true
          VALID_ENTRY_drive_name=true
          print green "The ""$drive""-partition will be named $drive_name"
          echo
        elif [[ $drive_name_check -ne "NO" ]] && [[ $drive_name_check -ne "YES" ]]; then 
          print red "Invalid answer. Please try again"
          VALID_ENTRY_drive_name_check=false
          echo
        fi
      done
    done
    if [[ $drive == "boot" ]]; then
      BOOT_label=$drive_name
    elif [[ $drive == "SWAP" ]]; then
      SWAP_label=$drive_name
    elif [[ $drive == "primary" ]]; then
      PRIMARY_label=$drive_name
    fi
    drive=""
    drive_name=""
    drive_name_check=""
    VALID_ENTRY_drive_name=""
    VALID_ENTRY_drive_name_check=""
}

#----------------------------------------------------------------------------------------------------------------------------------

# Until-loop; drive-size

  until_loop_drive_size() {
    drive="$1"
    drive_size="$2"
    drive_size_check="$3"
    until [ "$VALID_ENTRY_drive_size_format" == "true" ] && [ "$VALID_ENTRY_drive_size" == "true" ]; do 
      VALID_ENTRY_drive_size_check=false # Necessary for trying again
      read -rp "Any favourite size for the ""$drive""-partition in MB? Though minimum 256MB; only type the size without units: " drive_size
      echo
      if ! [[ "$drive_size" =~ ^[0-9]+$ ]]; then
        print red "Sorry, only numbers please"
        echo
        drive_size=""
        VALID_ENTRY_drive_size_format=false
      elif [ "$drive" == "BOOT" ]; then
        if ! [[ "$drive_size" -ge 256 ]]; then
          print red "Sorry, the ""$drive""-partition will not be large enough"
          echo
          drive_size=""
          VALID_ENTRY_drive_size_format=false
        fi
      else 
        VALID_ENTRY_drive_size_format=true
      fi
      if [ "$VALID_ENTRY_drive_size_format" == "true" ]; then
        until [ "$VALID_ENTRY_drive_size_check" == "true" ]; do 
          read -rp "The ""$drive""-partition will fill $drive_size. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " drive_size_check
          echo
          if [[ $drive_size_check == "YES" ]]; then
            print yellow "You'll get a new prompt"
            VALID_ENTRY_drive_size_check=true
            VALID_ENTRY_drive_size_format=false
            VALID_ENTRY_drive_size=false
            echo
          elif [[ $drive_size_check == "NO" ]]; then
            VALID_ENTRY_drive_size_check=true
            VALID_ENTRY_drive_size=true
            print green "The ""$drive""-partition is set to be $drive_size MiB"
            echo
          elif [[ $drive_size_check -ne "NO" ]] && [[ $drive_size_check -ne "YES" ]]; then 
            VALID_ENTRY_drive_size_check=false
            print red "Invalid answer. Please try again"
            echo
          fi
        done
      fi
    done
    if [[ $drive == "BOOT" ]]; then
      BOOT_size=$drive_size
    elif [[ $drive == "SWAP" ]]; then
      SWAP_size=$drive_size
    fi
    drive=""
    drive_size=""
    drive_size_check=""
    VALID_ENTRY_drive_size_format=""
    VALID_ENTRY_drive_size=""
    VALID_ENTRY_drive_size_check=""
}

#----------------------------------------------------------------------------------------------------------------------------------

# Insure that the script is run as root-user

  if ! [ "$USER" = 'root' ]; then
    echo
    print red "Sorry, this script must be run as ROOT"
    exit 1
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Introduction

  more welcome.txt # Prints the content of the file
 
  echo
  print blue "To tailor the installation to your needs, you have the following choices: "
  echo

  until [ "$INTRO_proceed" == "true" ]; do 
    VALID_ENTRY_intro_check=false # Necessary for trying again
    until_loop_intro WiFi WIFI_choice
    until_loop_intro Encryption ENCRYPTION_choice
    until_loop_intro Swap SWAP_choice
    until_loop_intro Subvolumes SUBVOLUMES_choice
    print blue "You have chosen the following choices: "
    echo
    echo -n "WIFI = " && checkbox "$WIFI_choice"
    echo -n "SWAP = " && checkbox "$SWAP_choice"
    echo -n "ENCRYPTION = " && checkbox "$ENCRYPTION_choice"
    echo -n "SUBVOLUMES = " && checkbox "$SUBVOLUMES_choice"
    echo
    print white "Where [ ] = NO and [X] = YES"
    echo
    until [ $VALID_ENTRY_intro_check == "true" ]; do 
      read -rp "Is everything fine? Type \"YES\" if yes, \"NO\" if no: " INTRO_choice
      echo
        if [[ $INTRO_choice == "YES" ]]; then 
          VALID_ENTRY_intro_check=true
          INTRO_proceed=true
        elif [[ $INTRO_choice == "NO" ]]; then  
          SWAP_choice=""
          ENCRYPTION_choice=""
          SUBVOLUMES_choice=""
          WIFI_choice=""
          INTRO_choice=""
          VALID_ENTRY_intro_check=true
          INTRO_proceed=false
          print cyan "Back to square one!"
          echo
        elif [[ $INTRO_choice -ne "NO" ]] && [[ $INTRO_choice -ne "YES" ]]; then 
          VALID_ENTRY_intro_check=true
          print red "Invalid answer. Please try again"
          echo
        fi
    done
  done 

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Network-configuration

  if [[ $WIFI_choice == 2 ]]; then
    more network.txt
    echo
    print blue "You're wifi-card is about to be activated"
    echo
    rfkill unblock wifi
    connmanctl enable wifi
    connmanctl scan wifi
    connmanctl services
    connmanctl services > wifi_list
    connmanctl agent on
    echo
    until [ "$WIFI_proceed" == "true" ]; do 
      VALID_ENTRY_wifi_check=false # Necessary for trying again
      read -rp "Please type the WIFI-name from the list above, which you wish to connect to: " WIFI_SSID
      echo
      until [ "$VALID_ENTRY_wifi_check" == "true" ]; do 
        read -rp "You have chosen $WIFI_SSID. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " WIFI_check
        echo
        if [[ $WIFI_check == "YES" ]]; then
          print yellow "You'll get a new prompt"
          WIFI_SSID=""
          WIFI_proceed=false
          VALID_ENTRY_wifi_check=true
          echo
        elif [[ $WIFI_check == "NO" ]]; then
          WIFI_proceed=true
          VALID_ENTRY_wifi_check=true
        elif [[ $WIFI_check -ne "NO" ]] && [[ $WIFI_check -ne "YES" ]]; then 
          VALID_ENTRY_wifi_check=false
          print red "Invalid answer. Please try again"
          echo
        fi
      done
    done
    WIFI_ID=sed -n "s //^.*$WIFI_SSID\s*\(\S*\)/\1/p" wifi_list
    rm wifi_list
    connmanctl connect "$WIFI_ID" 
    echo
  fi

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Partitions

  more partitions.txt
  echo
  fdisk -l
  echo

  until [ "$VALID_ENTRY_drive" == "true" ]; do
    print blue "Which drive do you want to partition? Please enter the whole part such as \"/dev/sda\": " 
    VALID_ENTRY_drive_choice=false # Necessary for trying again
    read -r DRIVE_LABEL
    OUTPUT=`fdisk -l | sed -n "s/^.*\("$DRIVE_LABEL"\).*$/\1/p"`
    if [[ "$OUTPUT" == *"$DRIVE_LABEL"* ]]; then 
      until [ "$VALID_ENTRY_drive_choice" == "true" ]; do 
        echo
        read -rp "You have chosen ""$DRIVE_LABEL"" - is that the correct drive? Type \"1\" for no, \"2\" for yes: " DRIVE_check
        echo
        if [[ $DRIVE_check == "1" ]]; then
          print yellow "You'll get a new prompt"
          echo
          VALID_ENTRY_drive_choice=true
          VALID_ENTRY_drive=false
        elif [[ $DRIVE_check == "2" ]]; then
          VALID_ENTRY_drive_choice=true
          VALID_ENTRY_drive=true
        elif [[ $DRIVE_check -ne 1 ]] && [[ $DRIVE_check -ne 2 ]]; then 
          VALID_ENTRY_drive_choice=false
          print red "Invalid answer. Please try again"
          echo
        fi
      done
    else
       echo
       fdisk -l
       print red "Invalid drive. Please try again"
       echo
    fi
  done

  if [[ $SWAP_choice == "1" ]]; then
    DRIVE_LABEL_boot="$DRIVE_LABEL""1"
    DRIVE_LABEL_primary="$DRIVE_LABEL""2"
    badblocks -c 10240 -s -w -t random -v "$DRIVE_LABEL"
    until [ "$DRIVE_proceed" == "true" ]; do 
      until_loop_drive_size BOOT BOOT_size BOOT_size_check
      until_loop_drive_name boot BOOT_label BOOT_label_check
      until_loop_drive_name primary PRIMARY_label PRIMARY_label_check
    done
    parted "$DRIVE_LABEL"
    mklabel gpt
    mkpart ESP fat32 1MiB "$BOOT_size"MiB
    set 1 boot on
    name 1 "$BOOT_label"
    mkpart primary "$BOOT_size"MiB 100%
    name 2 "$PRIMARY_label"
    quit
    echo

  elif [[ $SWAP_choice == "2" ]]; then
    DRIVE_LABEL_boot="$DRIVE_LABEL""1"
    DRIVE_LABEL_swap="$DRIVE_LABEL""2"
    DRIVE_LABEL_primary="$DRIVE_LABEL""3"
    badblocks -c 10240 -s -w -t random -v "$DRIVE_LABEL"
    until [ "$DRIVE_proceed" == "true" ]; do 
      until_loop_drive_size BOOT BOOT_size BOOT_size_check
      until_loop_drive_name boot BOOT_label BOOT_label_check
      until_loop_drive_size SWAP SWAP_size SWAP_size_check
      until_loop_drive_name SWAP SWAP_label SWAP_label_check
      until_loop_drive_name primary PRIMARY_label PRIMARY_label_check
    done
    parted "$DRIVE_LABEL"
    mklabel gpt
    mkpart ESP fat32 1MiB "$BOOT_size"MiB
    set 1 boot on
    name 1 "$BOOT_label"
    mkpart primary "$BOOT_size"MiB "$SWAP_size"MiB
    name 2 "$SWAP_label"
    mkpart primary "$SWAP_size"MiB 100%
    name 3 "$PRIMARY_label"
    quit
    echo
  fi

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if [[ $ENCRYPTION_choice == 2 ]]; then
    more encryptions.txt
    echo
    print blue "Please have your encryption-password ready "
    echo
    cryptsetup luksFormat --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random "$DRIVE_LABEL_primary"
    cryptsetup open /dev/DRIVE_LABEL_root cryptroot
    echo
  fi

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-formatting

  more formatting.txt
  print blue "A favourite filesystem for the root-drive? BTRFS of course!"
  mkfs.vfat -F32 "$DRIVE_LABEL_boot"
  mkswap -L "$SWAP_label" "$DRIVE_LABEL_swap"
  mkfs.btrfs -l "$PRIMARY_label" /dev/mapper/cryptroot
  echo

  lines

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

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-mount

  mount "$DRIVE_LABEL_boot" /mnt/boot
  swapon /"$DRIVE_LABEL_swap"
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Base-install

  basestrap /mnt base base-devel neovim nano runit linux linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 cryptsetup realtime-privileges
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

  more fstab.txt
  fstabgen -U /mnt >> /mnt/etc/fstab
  echo
 
  until [ "$FSTAB_proceed" == "true" ]; do 
    until [ "$VALID_ENTRY_fstab_check" == "true" ]; do 
      read -rp "If unsure / want to do be sure that the UUID in fstab is correct, enter \"1\"; if not, enter \"2\": " FSTAB_check
      echo
      if [[ $FSTAB_check == 1 ]]; then
        VALID_ENTRY_fstab_check=true
        FSTAB_proceed=true
      elif [[ $FSTAB_check == 2 ]]; then
        VALID_ENTRY_fstab_check=true
        fdisk -l
        FSTAB_proceed=false
        more /mnt/etc/fstab
        echo
        until [ "$VALID_ENTRY_fstab_confirm_check" == "true" ]; do 
          read -rp "Does everything seems right? Type \"1\" for no, \"2\" for yes: " FSTAB_confirm
          echo
          if [[ $FSTAB_confirm == 1 ]]; then
            print cyan "Sorry, you have to execute the scipt again :("
            exit 1
          elif [[ $FSTAB_confirm == 2 ]]; then
            VALID_ENTRY_fstab_confirm_check=true
            FSTAB_proceed=true
          elif [[ $FSTAB_confirm -ne 1 ]] && [[ $FSTAB_check -ne 2 ]]; then 
            VALID_ENTRY_fstab_confirm_check=false
            print red "Invalid answer. Please try again"
            echo
          fi
        done
      elif [[ $FSTAB_check -ne 1 ]] && [[ $FSTAB_check -ne 2 ]]; then 
        VALID_ENTRY_fstab_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done 
  done

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Chroot

  artix-chroot /mnt
  /bin/bash
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  more time.txt
  echo

  until [ "$TIME_proceed" == "true" ]; do 
    VALID_ENTRY_time_check=false # Necessary for trying again
    print blue "Please choose your locale time"
    select TIMEZONE_1 in $(ls /usr/share/zoneinfo);do
      if [ -d "/usr/share/zoneinfo/$TIME" ];then
        select TIMEZONE_2 in $(ls /usr/share/zoneinfo/"$TIMEZONE_1");do
          ln -sf /usr/share/zoneinfo/"$TIMEZONE_1"/"$TIMEZONE_2" /etc/localtime
        break
        done
      else
        ln -sf /usr/share/zoneinfo/"$TIMEZONE_1" /etc/localtime
      fi
    break
    done
    until [ "$VALID_ENTRY_time_check" == "true" ]; do 
      read -rp "You have chosen $TIMEZONE_1/$TIMEZONE_2 . Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " TIME_check
      echo
      if [[ $TIME_check == "YES" ]]; then
        print yellow "You'll get a new prompt"
        TIMEZONE_1=""
        TIMEZONE_2=""
        TIME_proceed=false
        VALID_ENTRY_time_check=true
        echo
      elif [[ $TIME_check == "NO" ]]; then
        TIME_proceed=true
        VALID_ENTRY_time_check=true
      elif [[ $TIME_check -ne "NO" ]] && [[ $TIME_check -ne "YES" ]]; then 
        VALID_ENTRY_time_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done

  hwclock --systoch

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals_languages

  more locals.txt
  echo
  read -rp "How many languages do you plan to use? No wrong answers, unless it is above 3!: " LANGUAGE_how_many
  echo
  print blue "$LANGUAGE_how_many languages will be generated"
  echo
  
  if [[ "$LANGUAGE_how_many" == 0 ]] || [[ "$LANGUAGE_how_many" -gt 3 ]]; then
    print cyan "Please try again; I don't have time for this!"
    echo
    read -rp "How many languages do you plan to use? No wrong answers, unless it is above 3!: " LANGUAGE_how_many
    echo
    print blue "$LANGUAGE_how_many languages will be generated"
    echo
  fi

  if [[ $LANGUAGE_how_many == 1 ]]; then
    print blue "What language do you wish to generate?"
    print purple "Example: da_DK.UTF-8"
    read -r LANGUAGE_GEN1
    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
  elif [[ $LANGUAGE_how_many == 2 ]]; then
    print blue "Which languages do you wish to generate?"
    print purple "Example: da_DK.UTF-8"
    read -r LANGUAGE_GEN1
    echo
    print blue "Second language"
    read -r LANGUAGE_GEN2
    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
    sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen
  elif [[ $LANGUAGE_how_many == 3 ]]; then
     print blue "Which languages do you wish to generate?"
     print purple "Example: da_DK.UTF-8"
     read -r LANGUAGE_GEN1
     echo
     print blue "Second language"
     read -r LANGUAGE_GEN2
     echo
     print blue "Third language"
     read -r LANGUAGE_GEN3
     sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
     sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen
     sed -i 's/^# *\($LANGUAGE_GEN3\)/\1/' /etc/locale.gen
  fi

  echo
  locale.gen
  locale -a
  echo

  print blue "Any thoughts on the system-wide language?"
  print purple "Example: da_DK.UTF-8"
  read -r LANGUAGE
  echo
  echo "LANG=$LANGUAGE" >> /etc/locale.conf
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals_keymap

  until [ "$KEYMAP_proceed" == "true" ]; do 
    VALID_ENTRY_keymap_check=false # Necessary for trying again
    print blue "Any thoughts on the system-wide keymap?"
    print purple "Example: dk-latin1"
    read -r KEYMAP
    echo
    until [ "$VALID_ENTRY_keymap_check" == "true" ]; do 
      read -rp "You have chosen $KEYMAP. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " KEYMAP_check
      echo
      if [[ $KEYMAP_check == "YES" ]]; then
        print yellow "You'll get a new prompt"
        KEYMAP=""
        KEYMAP_proceed=false
        VALID_ENTRY_keymap_check=true
        echo
      elif [[ $KEYMAP_check == "NO" ]]; then
        KEYMAP_proceed=true
        VALID_ENTRY_keymap_check=true
      elif [[ $KEYMAP_check -ne "NO" ]] && [[ $KEYMAP_check -ne "YES" ]]; then 
        VALID_ENTRY_keymap_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done

  echo "keymap=""$KEYMAP""" >> /etc/conf.d/keymaps  
  echo "keymap=""$KEYMAP""" >> /etc/vconsole.conf
  echo

  lines
#----------------------------------------------------------------------------------------------------------------------------------

# Regenerating initramfs with encrypt-hook

  more initramfs.txt
  sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS="base\ udev\ autodetect\ modconf\ block\ encrypt\ filesystems\ keyboard\ fsck"/' /etc/mkinitcpio.conf
  mkinitcpio -p linux
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up GRUB

  more GRUB.txt
  echo

  until [ "$BOOTLOADER_proceed" == "true" ]; do 
    VALID_ENTRY_bootloader_check=false # Necessary for trying again
    read -rp "Any fitting name for the bootloader? " BOOTLOADER_label
    echo
    until [ "$VALID_ENTRY_bootloader_check" == "true" ]; do 
      read -rp "You have chosen $BOOTLOADER_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " BOOTLOADER_check
      echo
      if [[ $BOOTLOADER_check == "YES" ]]; then
        print yellow "You'll get a new prompt"
        BOOTLOADER_label=""
        BOOTLOADER_proceed=false
        VALID_ENTRY_bootloader_check=true
        echo
      elif [[ $BOOTLOADER_check == "NO" ]]; then
        BOOTLOADER_proceed=true
        VALID_ENTRY_bootloader_check=true
      elif [[ $BOOTLOADER_check -ne "NO" ]] && [[ $BOOTLOADER_check -ne "YES" ]]; then 
        VALID_ENTRY_bootloader_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done

  print blue "The bootloader will be viewed as $BOOTLOADER_label in the BIOS"
  echo
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="$BOOTLOADER_label" --recheck
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=\/dev\/$DRIVE_LABEL_root:cryptroot\ root=\/dev\/mapper\/cryptroot\ rootflags=subvol=@\/rootvol\ quiet"/' /etc/default/grub
  echo
  grub-mkconfig -o /boot/grub/grub.cfg
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting root-password + creating personal user

  more users.txt
  echo

  until [ "$ROOT_proceed" == "true" ]; do 
    VALID_ENTRY_root_check=false # Necessary for trying again
    print blue "Any thoughts on a root-password"?
    read -r ROOT_passwd
    echo
    until [ "$VALID_ENTRY_root_check" == "true" ]; do 
      read -rp "You have chosen $ROOT_passwd. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " ROOT_check
      echo
      if [[ $ROOT_check == "YES" ]]; then
        print yellow "You'll get a new prompt"
        ROOT_passwd=""
        ROOT_proceed=false
        VALID_ENTRY_root_check=true
        echo
      elif [[ $ROOT_check == "NO" ]]; then
        ROOT_passwd=true
        VALID_ENTRY_root_check=true
      elif [[ $ROOT_check -ne "NO" ]] && [[ $ROOT_check -ne "YES" ]]; then 
        VALID_ENTRY_root_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done

  passwd
  $ROOT_passwd
  echo

  until [ "$USER_proceed" == "true" ]; do 
    VALID_ENTRY_user_check=false # Necessary for trying again
    print blue "Can I suggest a username?"
    read -r USERNAME
    echo
    print blue "A password too?"
    read -r USERNAME_passwd
    echo
    until [ "$VALID_ENTRY_user_check" == "true" ]; do 
      read -rp "You have chosen $USERNAME as username and $USERNAME_passwd as password. Do you want to change anyone of these? Type \"YES\" if yes, \"NO\" if no: " USER_check
      echo
      if [[ $USER_check == "YES" ]]; then
        print yellow "You'll get a new prompt"
        USERNAME=""
        USERNAME_passwd=""
        USER_proceed=false
        VALID_ENTRY_user_check=true
        echo
      elif [[ $USER_check == "NO" ]]; then
        USERNAME=""
        USERNAME_passwd=""
        VALID_ENTRY_user_check=true
      elif [[ $USER_check -ne "NO" ]] && [[ $USER_check -ne "YES" ]]; then 
        VALID_ENTRY_user_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done

  useradd -m -G users -g video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel,realtime "$USERNAME"
  passwd "$USERNAME"
  $USERNAME_passwd
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up hostname

  more hostname.txt
  echo

  until [ "$LOCALS_proceed" == "true" ]; do 
    VALID_ENTRY_hostname_check=false # Necessary for trying again
    print blue "What name do you want to host?"
    read -r HOSTNAME
    echo
    until [ "$VALID_ENTRY_hostname_check" == "true" ]; do 
      read -rp "You have chosen $HOSTNAME. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " HOSTNAME_check
      echo
      if [[ $HOSTNAME_check == "YES" ]]; then
        print yellow "You'll get a new prompt"
        HOSTNAME=""
        LOCALS_proceed=false
        VALID_ENTRY_hostname_check=true
        echo
      elif [[ $HOSTNAME_check == "NO" ]]; then
        LOCALS_proceed=true
        VALID_ENTRY_hostname_check=true
      elif [[ $HOSTNAME_check -ne "NO" ]] && [[ $HOSTNAME_check -ne "YES" ]]; then 
        VALID_ENTRY_hostname_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done

  echo "$HOSTNAME" >> /etc/hostname
  cat > /etc/hosts<< "EOF"
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME     
EOF
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting NetworkManager to start on boot

  ln -s /etc/runit/sv/NetworkManager /run/runit/service 
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Allow users to use sudo

  echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Choice of DE/VM, Wayland/Xorg and other packages/services (including wanting access to AUR (yay) or not)



#----------------------------------------------------------------------------------------------------------------------------------

# Summary before restart



#----------------------------------------------------------------------------------------------------------------------------------

# Farewell

  more farewell.txt
  echo
  exit
  exit
  umount -R /mnt
  reboot
 
