#!/usr/bin/bash

# Parameters

  BEGINNER_DIR=$(pwd)
  LOADKEY=""

  type=""
  type_choice=""

  SWAP_choice=""
  ENCRYPTION_choice=""
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

  drive=""
  drive_size=""
  drive_name=""
  drive_size_check=""
  drive_name_check=""

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

  RAM_size=""
  FSTAB_check=""
  VALID_ENTRY_fstab_check=""
  FSTAB_proceed=""
  FSTAB_confirm=""
  VALID_ENTRY_fstab_confirm_check=""

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
    [[ "$1" -eq 1 ]] && echo -e "${BBlue}[${Reset}${Bold}X${BBlue}]${Reset}" || echo -e "${BBlue}[ ${BBlue}]${Reset}";
}

#----------------------------------------------------------------------------------------------------------------------------------

# Until-loop; intro

  until_loop_intro() {
    type="$1"
    type_choice="$2"
    until [ "$VALID_ENTRY_choices" == "true" ]; do 
      read -rp "Do you plan to utilise "${type,,}"? Please type \"1\" for yes, \"2\" if not: " type_choice
      echo
      if [ "$type_choice" == "2" ]; then
        print yellow ""$1" will not be configured"
        echo
        VALID_ENTRY_choices=true
      elif [ "$type_choice" == "1" ]; then
        print green ""$1" will be configured"
        echo
        VALID_ENTRY_choices=true
      else
        VALID_ENTRY_choices=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
    if [ "$type" == "WiFi" ]; then
      WIFI_choice="$type_choice"
    elif [ "$type" == "SWAP" ]; then
      SWAP_choice="$type_choice"
    elif [ "$type" == "Encryption" ]; then
      ENCRYPTION_choice="$type_choice"
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
      read -rp "A special name for the "$drive"-partition? " drive_name
      echo
      if [ "$drive" == "BOOT" ]; then
        if [[ "${#drive_name}" -ge "11" ]]; then
          print red "Sorry, the boot-name is too long; maximum 11 characters is allowed with FAT32"
          echo
          drive_name=""
          VALID_ENTRY_drive_name=false
          VALID_ENTRY_drive_name_check=true
        fi
      fi
      until [ "$VALID_ENTRY_drive_name_check" == "true" ]; do 
        read -rp "The "$drive"-partition will be named \""$drive_name"\". Type \"YES\" if correct or \"NO\" if not: " drive_name_check
        echo
        if [ "$drive_name_check" == "NO" ]; then
          print yellow "You'll get a new prompt"
          VALID_ENTRY_drive_name_check=true
          VALID_ENTRY_drive_name=false
          echo
        elif [ "$drive_name_check" == "YES" ]; then
          VALID_ENTRY_drive_name_check=true
          VALID_ENTRY_drive_name=true
          print green "Roger roger - the "$drive"-partition will be named "$drive_name""
          if [ "$drive" == "primary" ]; then
            DRIVE_proceed=true
          fi
          echo
        else 
          print red "Invalid answer. Please try again"
          VALID_ENTRY_drive_name_check=false
          echo
        fi
      done
    done
    if [ "$drive" == "BOOT" ]; then
      BOOT_label="$drive_name"
    elif [ "$drive" == "SWAP" ]; then
      SWAP_label="$drive_name"
    elif [ "$drive" == "primary" ]; then
      PRIMARY_label="$drive_name"
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
      if [ "$drive" == "BOOT" ]; then
        read -rp "Any favourite size for the "$drive"-partition in MB? Though minimum 256MB; only type the size without units: " drive_size
      else
        read -rp "Any favourite size for the "$drive"-partition in MB? Please only type the size without units: " drive_size
      fi
      echo
      if ! [[ "$drive_size" =~ ^[0-9]+$ ]]; then
        print red "Sorry, only numbers please"
        echo
        drive_size=""
        VALID_ENTRY_drive_size_format=false
      elif [ "$drive" == "BOOT" ]; then
        if ! [[ "$drive_size" -ge "255" ]]; then
          print red "Sorry, the "$drive"-partition will not be large enough"
          echo
          drive_size=""
          VALID_ENTRY_drive_size_format=false
        else
          VALID_ENTRY_drive_size_format=true
        fi
      else 
        VALID_ENTRY_drive_size_format=true
      fi
      if [ "$VALID_ENTRY_drive_size_format" == "true" ]; then
        until [ "$VALID_ENTRY_drive_size_check" == "true" ]; do
          VALID_ENTRY_drive_size_check=false # Necessary for trying again 
          read -rp "The "$drive"-partition will fill "$drive_size"MB. Type \"YES\" if correct or \"NO\" if not: " drive_size_check
          echo
          if [ "$drive_size_check" == "NO" ]; then
            print yellow "You'll get a new prompt"
            VALID_ENTRY_drive_size_check=true
            VALID_ENTRY_drive_size_format=false
            VALID_ENTRY_drive_size=false
            echo
          elif [ "$drive_size_check" == "YES" ]; then
            VALID_ENTRY_drive_size_check=true
            VALID_ENTRY_drive_size=true
            print green "The "$drive"-partition is set to be $drive_size MiB"
            echo
          else
            VALID_ENTRY_drive_size_check=false
            print red "Invalid answer. Please try again"
            echo
          fi
        done
      fi
    done
    if [ "$drive" == "BOOT" ]; then
      BOOT_size=$drive_size
    elif [ "$drive" == "SWAP" ]; then
      SWAP_size=$((drive_size+BOOT_size))
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
    print red "Sorry, this script must be run as root-user"
    exit 1
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Loadkeys

  ls -R /usr/share/kbd/keymaps
  echo
  print blue "Which keymap do you want to use during the install"?
  echo
  read -r LOADKEY
  loadkeys "$LOADKEY"
  lines

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
    until_loop_intro SWAP SWAP_choice
    print blue "You have chosen the following options: "
    echo
    echo -n "WIFI = " && checkbox "$WIFI_choice"
    echo -n "SWAP = " && checkbox "$SWAP_choice"
    echo -n "ENCRYPTION = " && checkbox "$ENCRYPTION_choice"
    echo
    print white "Where [X] = YES and [ ] = NO"
    echo
    until [ "$VALID_ENTRY_intro_check" == "true" ]; do 
      read -rp "Is everything fine? Please type either \"YES\" or \"NO\": " INTRO_choice
      echo
        if [ "$INTRO_choice" == "YES" ]; then 
          VALID_ENTRY_intro_check=true
          INTRO_proceed=true
        elif [ "$INTRO_choice" == "NO" ]; then  
          SWAP_choice=""
          ENCRYPTION_choice=""
          WIFI_choice=""
          INTRO_choice=""
          VALID_ENTRY_intro_check=true
          INTRO_proceed=false
          print cyan "Back to square one!"
          echo
        else
          VALID_ENTRY_intro_check=true
          print red "Invalid answer. Please try again"
          echo
        fi
    done
  done 
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Network-configuration

  if [ "$WIFI_choice" == "1" ]; then
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
      read -rp "Which WiFi-network from the list above should be connected to? " WIFI_SSID
      echo
      until [ "$VALID_ENTRY_wifi_check" == "true" ]; do 
        read -rp "You have chosen "$WIFI_SSID". Type \"YES\" if correct or \"NO\" if not: " WIFI_check
        echo
        if [ "$WIFI_check" == "NO" ]; then
          print yellow "You'll get a new prompt"
          WIFI_SSID=""
          WIFI_proceed=false
          VALID_ENTRY_wifi_check=true
          echo
        elif [ "$WIFI_check" == "YES" ]; then
          WIFI_proceed=true
          VALID_ENTRY_wifi_check=true
        else
          VALID_ENTRY_wifi_check=false
          print red "Invalid answer. Please try again"
          echo
        fi
      done
    done
    WIFI_ID=$(sed -n "s //^.*$WIFI_SSID\s*\(\S*\)/\1/p" wifi_list)
    rm wifi_list
    connmanctl connect "$WIFI_ID" 
    echo
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Installing parted to format drives + support for zstd-compression + configuring Arch's repo

  pacman -S --noconfirm archlinux-keyring artix-keyring artix-archlinux-support
  pacman-key --init
  pacman-key --populate archlinux artix
  cp pacman.conf /etc/pacman.conf
  pacman -Syy
  pacman -S --noconfirm parted zstd
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Partitions

  swapoff -a
  more partitions.txt
  echo
  fdisk -l
  echo
  until [ "$VALID_ENTRY_drive" == "true" ]; do
    print blue "Which drive do you want to partition? Please only enter the part after \"/dev/\": " 
    VALID_ENTRY_drive_choice=false # Necessary for trying again
    read -r DRIVE_LABEL
    OUTPUT=$(fdisk -l | sed -n "s/^.*\("$DRIVE_LABEL"\).*$/\1/p")
    if [[ "$OUTPUT" == *"$DRIVE_LABEL"* ]]; then 
      until [ "$VALID_ENTRY_drive_choice" == "true" ]; do 
        echo
        read -rp "You have chosen \""$DRIVE_LABEL"\" . Type \"YES\" if correct or \"NO\" if not: " DRIVE_check
        echo
        if [ "$DRIVE_check" == "NO" ]; then
          print yellow "You'll get a new prompt"
          echo
          VALID_ENTRY_drive_choice=true
          VALID_ENTRY_drive=false
        elif [ "$DRIVE_check" == "YES" ]; then
          VALID_ENTRY_drive_choice=true
          VALID_ENTRY_drive=true
        else
          VALID_ENTRY_drive_choice=false
          print red "Invalid answer. Please try again"
          echo
        fi
      done
    else
       echo
       fdisk -l
       echo
       print red "Invalid drive. Please try again"
       echo
    fi
  done
  print yellow "Erasing your drive! This might take some time depending on your drive size - you are hereby permitted to exit using Ctrl+C"
  echo
  dd if=/dev/zero of=/dev/"$DRIVE_LABEL" bs=512 count=1 status=progress
  echo
  if [ "$SWAP_choice" == "2" ]; then
    if [ "$DRIVE_LABEL" == "nvme0n1" ]; then
      DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL"p"1"
      DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL"p"2"
    else
      DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL""1"
      DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL""2"
    fi
    until [ "$DRIVE_proceed" == "true" ]; do 
      until_loop_drive_size BOOT BOOT_size BOOT_size_check
      until_loop_drive_name BOOT BOOT_label BOOT_label_check
      until_loop_drive_name primary PRIMARY_label PRIMARY_label_check
    done
    parted --script -a optimal /dev/"$DRIVE_LABEL" \
      mklabel gpt \
      mkpart BOOT fat32 1MiB "$BOOT_size"MiB set 1 ESP on \
      mkpart PRIMARY btrfs "$BOOT_size"MiB 100%   
    echo
  elif [ "$SWAP_choice" == "1" ]; then
    if [ "$DRIVE_LABEL" == "nvme0n1" ]; then
      DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL"p"1"
      DRIVE_LABEL_swap=/dev/"$DRIVE_LABEL"p"2"
      DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL"p"3"
    else
      DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL""1"
      DRIVE_LABEL_swap=/dev/"$DRIVE_LABEL""2"
      DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL""3"
    fi
    until [ "$DRIVE_proceed" == "true" ]; do 
      until_loop_drive_size BOOT BOOT_size BOOT_size_check
      until_loop_drive_name BOOT BOOT_label BOOT_label_check
      until_loop_drive_size SWAP SWAP_size SWAP_size_check
      until_loop_drive_name SWAP SWAP_label SWAP_label_check
      until_loop_drive_name primary PRIMARY_label PRIMARY_label_check
    done
    parted --script -a optimal /dev/"$DRIVE_LABEL" \
      mklabel gpt \
      mkpart BOOT fat32 1MiB "$BOOT_size"MiB set 1 ESP on \
      mkpart SWAP linux-swap "$BOOT_size"MiB "$SWAP_size"MiB  \
      mkpart PRIMARY btrfs "$SWAP_size"MiB 100%      
    echo
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if [ "$ENCRYPTION_choice" == "1" ]; then
    more encryption.txt
    echo
    print blue "Please have your encryption-password ready "
    echo
    cryptsetup luksFormat --batch-mode --verify-passphrase --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random "$DRIVE_LABEL_primary"
    cryptsetup open "$DRIVE_LABEL_primary" cryptroot
    echo
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-formatting

  more formatting.txt
  mkfs.vfat -F32 -n "$BOOT_label" "$DRIVE_LABEL_boot" 
  echo
  if [ "$SWAP_choice" == "1" ]; then
    mkswap -L "$SWAP_label" "$DRIVE_LABEL_swap"
  fi
  print blue "Currently BTRFS is the only real filesystem for your root-partition!"
  echo
  if [ "$ENCRYPTION_choice" == "1" ]; then
    mkfs.btrfs -f -L "$PRIMARY_label" /dev/mapper/cryptroot
  else
    mkfs.btrfs -f -L "$PRIMARY_label" "$DRIVE_LABEL_primary"
  fi
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# BTRFS-subvolumes

  more subvolumes.txt
  if [ "$ENCRYPTION_choice" == "1" ]; then
    MOUNT="/dev/mapper/cryptroot"
  else
    MOUNT="$DRIVE_LABEL_primary"
  fi
  mount -o noatime,compress=zstd,discard,ssd,defaults "$MOUNT" /mnt
  cd /mnt || return
  btrfs subvolume create @
  btrfs subvolume create @home
  btrfs subvolume create @var_log
  btrfs subvolume create @srv
  btrfs subvolume create @var_tmp
  btrfs subvolume create @var_abs
  btrfs subvolume create @var_pkg
  btrfs subvolume create @.snapshots
  btrfs subvolume create @.snapshots_home
  btrfs subvolume create @.snapshots_root
  cd /
  mkdir -p /mnt/{boot,home,srv,.snapshots/{home,root,packages_list},var/{abs,tmp,log,cache/pacman/pkg}}
  umount /mnt
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ "$MOUNT" /mnt
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home "$MOUNT" /mnt/home
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_pkg "$MOUNT" /mnt/var/cache/pacman/pkg
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_log "$MOUNT" /mnt/var/log
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_abs "$MOUNT" /mnt/var/abs
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_tmp "$MOUNT" /mnt/var/tmp
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@srv "$MOUNT" /mnt/srv
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@.snapshots "$MOUNT" /mnt/.snapshots
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@.snapshots_home "$MOUNT" /mnt/.snapshots/home
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@.snapshots_root "$MOUNT" /mnt/.snapshots/root
  sync
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-mount

  cd "$BEGINNER_DIR" || exit
  mount "$DRIVE_LABEL_boot" /mnt/boot
  if [[ "$SWAP_choice" == "1" ]]; then
    swapon "$DRIVE_LABEL_swap"
    cat << EOF | tee -a /mnt/etc/crypttab > /dev/null
swap     LABEL="$SWAP_label"  /dev/urandom  swap,offset=2048,cipher=aes-xts-plain64,size=512
EOF
  fi
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Base-install

  if grep -q Intel "/proc/cpuinfo"; then
    basestrap /mnt intel-ucode
  elif grep -q AMD "/proc/cpuinfo"; then
    basestrap /mnt amd-ucode
  fi
  basestrap /mnt fcron-runit apparmor-runit libressl bat base base-devel neovim nano runit linux-zen zstd linux-zen-headers grub-btrfs linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 cryptsetup realtime-privileges elogind-runit mkinitcpio artix-archlinux-support
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

  more fstab.txt
  fstabgen -U /mnt >> /mnt/etc/fstab
  sed -i '/swap/c\\/dev\/mapper\/swap  none   swap    defaults   0       0' /mnt/etc/fstab
  RAM_size="$((($(free -g | grep Mem: | awk '{print $2}') + 1) / 2))G" # tmpfs will fill half the RAM-size
  cat << EOF | tee -a /mnt/etc/fstab > /dev/null
tmpfs	/tmp	tmpfs	rw_size=$RAM_size,nr_inodes=5k,noexec,nodev,nousid	0	0  
EOF
  echo
  until [ "$FSTAB_proceed" == "true" ]; do 
    until [ "$VALID_ENTRY_fstab_check" == "true" ]; do 
      read -rp "If you want to check that the UUIDs in fstab is correct, enter \"2\"; if not, enter \"1\": " FSTAB_check
      echo
      if [ "$FSTAB_check" == "1" ]; then
        VALID_ENTRY_fstab_check=true
        FSTAB_proceed=true
      elif [ "$FSTAB_check" == "2" ]; then
        VALID_ENTRY_fstab_check=true
        fdisk -l
        FSTAB_proceed=false
        more /mnt/etc/fstab
        echo
        until [ "$VALID_ENTRY_fstab_confirm_check" == "true" ]; do 
          read -rp "Does everything seems right? Type either \"YES\" or \"NO\": " FSTAB_confirm
          echo
          if [ "$FSTAB_confirm" == "NO" ]; then
            print cyan "Sorry, you have to execute the scipt again :("
            exit 1
          elif [ "$FSTAB_confirm" == "YES" ]; then
            VALID_ENTRY_fstab_confirm_check=true
            FSTAB_proceed=true
          else
            VALID_ENTRY_fstab_confirm_check=false
            print red "Invalid answer. Please try again"
            echo
          fi
        done
      else
        VALID_ENTRY_fstab_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done 
  done
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Chroot

  mkdir /mnt/install_script
  cp {artix_runit_after_chroot.sh,AUR.txt,farewell.txt,grub-btrfs-update.stop,packages.txt,hostname.txt,btrfs_snapshot.sh,users.txt,paru-1.8.2-1-x86_64.pkg.tar.zst,pacman.conf,paru.conf,GRUB.txt,initramfs.txt,locals.txt,time.txt} /mnt/install_script
  artix-chroot /mnt /install_script/artix_runit_after_chroot.sh
