#!/usr/bin/bash

# 'Logs' of script

#  script SCRIPT.log

#----------------------------------------------------------------------------------------------------------------------------------
 
# Parameters

  BEGINNER_DIR=$(pwd)
  LOADKEY=""

  type=""
  type_choice=""

  SWAP_choice=""
  ENCRYPTION_choice=""
  INIT_choice=""
  INTRO_choice=""

  VALUE_1=""
  VALUE_2=""
  VALUE_3=""
  VALID_ENTRY_choices=""
  VALID_ENTRY_intro_check=""
  INTRO_proceed=""

  ENCRYPTION_1=""
  ENCRYPTION_2=""
  ENCRYPTION_check=""
  ENCRYPTION_confirm=""
  ENCRYPTION_double_confirm=""

  OUTPUT=""
  DRIVE_proceed=""

  drive=""
  drive_size=""
  drive_name=""

  VALID_ENTRY_drive_size_format=""
  BOOT_size=""
  SWAP_size=""
  SWAP_size_real=""

  VALID_ENTRY_drive_name=""
  BOOT_label=""
  SWAP_label=""
  PRIMARY_label=""

  DRIVE_choice=""
  VALID_ENTRY_drive_check=""

  DRIVE_LABEL=""
  DRIVE_LABEL_boot=""
  DRIVE_LABEL_swap=""
  DRIVE_LABEL_primary=""

  UUID_swap=""
  RAM_size=""
  FSTAB_check=""
  VALID_ENTRY_fstab_check=""
  FSTAB_proceed=""
  FSTAB_confirm=""
  VALID_ENTRY_fstab_confirm_check=""

  DRIVE_LABEL_after_chroot=""
  ENCRYPTION_after_chroot=""
  ENCRYPTION_PASSWD_after_chroot=""

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
  echo
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
      if [ "$type" == "Init" ]; then
        read -rp "Which init-system do you wish to use: \"runit\" (yaaay) or \"openrc\"? " type_choice
      else 
        read -rp "Do you plan to utilise "${type,,}"? Please type \"1\" for yes, \"2\" if not: " type_choice
      fi
      echo
      if [ "$type" == "Init" ]; then
        VALUE_1="runit"
        VALUE_2="openrc"
      else
        VALUE_3="2"
        VALUE_2="1"
      fi
      if [ "$type_choice" == "$VALUE_3" ]; then
        print yellow ""$1" will not be configured"
        echo
        VALID_ENTRY_choices=true
      elif [[ "$type_choice" == "$VALUE_1" || "$type_choice" == "$VALUE_2" ]]; then
        if [ "$type" == "Init" ]; then
          print green ""${type_choice^}" will be configured"
        else
          print green ""$1" will be configured"
        fi
        echo
        VALID_ENTRY_choices=true
      else
        VALID_ENTRY_choices=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
    if [ "$type" == "SWAP" ]; then
      SWAP_choice="$type_choice"
    elif [ "$type" == "Encryption" ]; then
      ENCRYPTION_choice="$type_choice"
    elif [ "$type" == "Init" ]; then
      INIT_choice="$type_choice"
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
    until [ "$VALID_ENTRY_drive_name" == "true" ]; do 
      read -rp "A special name for the "$drive"-partition? " drive_name
      echo
      if [ "$drive" == "BOOT" ]; then
        if [[ "${#drive_name}" -ge "11" ]]; then
          print red "Sorry, the boot-name is too long; maximum 11 characters is allowed with FAT32"
          echo
          drive_name=""
          VALID_ENTRY_drive_name=false
        else
          VALID_ENTRY_drive_name=true
        fi
      else
        VALID_ENTRY_drive_name=true
      fi
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
    VALID_ENTRY_drive_name=""
}

#----------------------------------------------------------------------------------------------------------------------------------

# Until-loop; drive-size

  until_loop_drive_size() {
    drive="$1"
    drive_size="$2"
    until [ "$VALID_ENTRY_drive_size_format" == "true" ]; do 
      VALID_ENTRY_drive_size_format=false # Necessary for trying again
      if [ "$drive" == "BOOT" ]; then
        read -rp "Any favourite size for the "$drive"-partition in MB? Though minimum 261MB; only type the size without units: " drive_size
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
        if ! [[ "$drive_size" -ge "260" ]]; then
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
    done
    if [ "$drive" == "BOOT" ]; then
      BOOT_size="$drive_size"
    elif [ "$drive" == "SWAP" ]; then
      SWAP_size="$drive_size"
      SWAP_size_real=$(("$drive_size"+"$BOOT_size"))
    fi
    drive=""
    drive_size=""
    VALID_ENTRY_drive_size_format=""
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
    until_loop_intro Encryption ENCRYPTION_choice
    until_loop_intro SWAP SWAP_choice
    until_loop_intro Init INIT_choice
    print blue "You have chosen the following options: "
    echo
    echo -n "SWAP = " && checkbox "$SWAP_choice"
    echo -n "ENCRYPTION = " && checkbox "$ENCRYPTION_choice"
    echo "Init = \""${INIT_choice^}"\""
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
          INIT_choice=""
          INTRO_choice=""
          VALID_ENTRY_intro_check=true
          INTRO_proceed=false
          print cyan "Back to square one!"
          echo
        else
          VALID_ENTRY_intro_check=false
          print red "Invalid answer. Please try again"
          echo
        fi
    done
  done 
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Partitions; sizes and labels

  swapoff -a
  umount -R /mnt # In case of executing the script again
  more partitions.txt
  echo

  until [ "$DRIVE_proceed" == "true" ]; do
    VALID_ENTRY_drive_check=false # Neccessary for trying again
    fdisk -l
    echo
    print blue "Which drive do you want to partition? Please only enter the part after \"/dev/\": " 
    read -rp "Drive: " DRIVE_LABEL
    echo
    OUTPUT=$(lsblk -do name)
    if echo "$OUTPUT" | grep -w -q "$DRIVE_LABEL"; then
      if [ "$DRIVE_LABEL" == "nvme0n1" ]; then
        if [ "$SWAP_choice" == "1" ]; then
          DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL"p"1"
          DRIVE_LABEL_swap=/dev/"$DRIVE_LABEL"p"2"
          DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL"p"3"
        else
          DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL"p"1"
          DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL"p"2"
        fi
      else
        if [ "$SWAP_choice" == "1" ]; then
          DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL""1"
          DRIVE_LABEL_swap=/dev/"$DRIVE_LABEL""2"
          DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL""3"
        else
          DRIVE_LABEL_boot=/dev/"$DRIVE_LABEL""1"
          DRIVE_LABEL_primary=/dev/"$DRIVE_LABEL""2"
        fi
      fi
      until_loop_drive_size BOOT BOOT_size
      until_loop_drive_name BOOT BOOT_label
      if [ "$SWAP_choice" == "1" ]; then
        until_loop_drive_size SWAP SWAP_size
        until_loop_drive_name SWAP SWAP_label
      fi
      until_loop_drive_name primary PRIMARY_label
      echo
      print blue "You have chosen the following labels / sizes: "
      echo
      print green "Drive to partition = \"/dev/"$DRIVE_LABEL"\""
      print green "BOOT_size = \""$BOOT_size"MB\" and BOOT_label = \""$BOOT_label"\""
      if [ "$SWAP_choice" == "1" ]; then
        print green "SWAP_size = \""$SWAP_size"MB\" and SWAP_label = \""$SWAP_label"\""
      fi
      print green "ROOT_label = \""$PRIMARY_label"\""
      echo
      until [ "$VALID_ENTRY_drive_check" == "true" ]; do 
        read -rp "Is everything fine? Please type either \"YES\" or \"NO\": " DRIVE_choice
        echo
        if [ "$DRIVE_choice" == "YES" ]; then 
          VALID_ENTRY_drive_check=true
          DRIVE_proceed=true
        elif [ "$DRIVE_choice" == "NO" ]; then  
          DRIVE_LABEL=""
          BOOT_size=""
          BOOT_label=""
          SWAP_size=""
          SWAP_label=""
          PRIMARY_label=""
          VALID_ENTRY_drive_check=true
          DRIVE_proceed=false
          print cyan "Back to square one!"
          echo
        else
          VALID_ENTRY_drive_check=false
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
  if [ "$ENCRYPTION_choice" == "1" ]; then
    more encryption.txt
    echo
    until [ "$ENCRYPTION_check" == "true" ]; do
      ENCRYPTION_confirm=false # Neccessary for trying again
      print blue "Because you seek encryption, please enter the encryption-password that you wish to use: "
      read -rp "Encryption-password: " ENCRYPTION_1
      echo
      print yellow "And again to confirm your choice: "
      echo
      read -rp "Encryption-password: " ENCRYPTION_2
      echo
      if [ "$ENCRYPTION_1" != "$ENCRYPTION_2" ]; then
        print red "Sorry, you didn't enter the same password twice :("
        ENCRYPTION_1=""
        ENCRYPTION_2=""
        ENCRYPTION_check=false
        echo
      elif [ "$ENCRYPTION_1" == "$ENCRYPTION_2" ]; then
        until [ "$ENCRYPTION_confirm" == "true" ]; do   
          read -rp "You have chosen \""$ENCRYPTION_2"\" as your encryption-password - if correct, please type \"YES\"; otherwise \"NO\": " ENCRYPTION_double_confirm
          if [ "$ENCRYPTION_double_confirm" == "YES" ]; then
            ENCRYPTION_confirm=true
            ENCRYPTION_check=true
          elif [ "$ENCRYPTION_double_confirm" == "NO" ]; then
            ENCRYPTION_confirm=true
            ENCRYPTION_check=false
            print cyan "Back to square one!"
            echo
          else
            ENCRYPTION_confirm=false
            print red "Invalid answer. Please try again"
            echo
          fi
        done
      fi
    done
  fi
  head -c 100000000 /dev/random > /dev/"$DRIVE_LABEL"; sync
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Installing parted to format drives + support for zstd-compression + configuring Arch's repo

  pacman -S --noconfirm archlinux-keyring artix-keyring artix-archlinux-support
  pacman-key --init
  pacman-key --populate archlinux artix
  cp pacman.conf /etc/pacman.conf
  pacman -Syy --noconfirm parted
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Partitioning drives

  if [ "$SWAP_choice" == "2" ]; then
    parted --script -a optimal /dev/"$DRIVE_LABEL" \
      mklabel gpt \
      mkpart BOOT fat32 1MiB "$BOOT_size"MiB set 1 ESP on \
      mkpart PRIMARY btrfs "$BOOT_size"MiB 100%   
  elif [ "$SWAP_choice" == "1" ]; then
    parted --script -a optimal /dev/"$DRIVE_LABEL" \
      mklabel gpt \
      mkpart BOOT fat32 1MiB "$BOOT_size"MiB set 1 ESP on \
      mkpart SWAP linux-swap "$BOOT_size"MiB "$SWAP_size_real"MiB  \
      mkpart PRIMARY btrfs "$SWAP_size_real"MiB 100%      
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if [ "$ENCRYPTION_choice" == "1" ]; then
    echo "$ENCRYPTION_2" | cryptsetup luksFormat --batch-mode --type luks2 --pbkdf=pbkdf2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random "$DRIVE_LABEL_primary" # --pbkdf=pbkdf2 due to GRUB currently lacking support for ARGON2d
    echo "$ENCRYPTION_2" | cryptsetup open "$DRIVE_LABEL_primary" cryptroot
  fi

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
  btrfs subvolume create @boot
  btrfs subvolume create @grub
  cd /
  umount /mnt
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@ "$MOUNT" /mnt
  mkdir -p /mnt/{boot,home,srv,.snapshots,.secret,var/{abs,tmp,log,cache/pacman/pkg}}
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@home "$MOUNT" /mnt/home
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_pkg "$MOUNT" /mnt/var/cache/pacman/pkg
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_log "$MOUNT" /mnt/var/log
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_abs "$MOUNT" /mnt/var/abs
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@var_tmp "$MOUNT" /mnt/var/tmp
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@srv "$MOUNT" /mnt/srv
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@.snapshots "$MOUNT" /mnt/.snapshots
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@boot "$MOUNT" /mnt/boot
  mkdir -p /mnt/boot/{EFI,grub}
  mount -o noatime,nodiratime,compress=zstd,space_cache,ssd,subvol=@grub "$MOUNT" /mnt/boot/grub
  sync
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-mount

  cd "$BEGINNER_DIR" || exit
  mount "$DRIVE_LABEL_boot" /mnt/boot/EFI
  if [ "$SWAP_choice" == "1" ]; then
    swapon "$DRIVE_LABEL_swap"
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Base-install + encrypted swap (if swap is chosen)

  if [ "$INIT_choice" == "runit" ]; then
    PACKAGES="fcron-runit dhcpcd-runit chrony-runit cryptsetup-runit cryptsetup libressl vim bat base base-devel neovim nano runit linux-zen zstd linux-zen-headers grub-btrfs linux-firmware networkmanager-runit grub os-prober efibootmgr sudo btrfs-progs git bc lz4 realtime-privileges elogind-runit mkinitcpio artix-archlinux-support"
  elif [ "$INIT_choice" == "openrc" ]; then
    PACKAGES="fcron-openrc dhcpcd-openrc chrony-openrc cryptsetup-openrc cryptsetup libressl vim bat base base-devel neovim nano openrc linux-zen zstd linux-zen-headers grub-btrfs linux-firmware networkmanager-openrc grub os-prober efibootmgr sudo btrfs-progs git bc lz4 realtime-privileges elogind-openrc mkinitcpio artix-archlinux-support"
  fi
  if grep -q Intel "/proc/cpuinfo"; then # Poor soul :(
    basestrap /mnt intel-ucode $PACKAGES
  elif grep -q AMD "/proc/cpuinfo"; then
    basestrap /mnt amd-ucode $PACKAGES
  fi
  if [ "$SWAP_choice" == "1" ]; then
    UUID_swap=$(lsblk -no TYPE,UUID "$DRIVE_LABEL_swap" | awk '$1=="part"{print $2}')
    cat << EOF | tee -a /mnt/etc/crypttab > /dev/null
swap     UUID=$UUID_swap  /dev/urandom  swap,offset=2048,cipher=aes-xts-plain64,size=512
EOF
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# fstab-generation with UUID; it can be a good idea to do a double check with "fdisk -l"

  more fstab.txt
  fstabgen -U /mnt >> /mnt/etc/fstab
  sed -i '/swap/c\\/dev\/mapper\/swap  none   swap    defaults   0       0' /mnt/etc/fstab
  RAM_size="$((($(free -g | grep Mem: | awk '{print $2}') + 1) / 2))G" # tmpfs will fill half the RAM-size
  cat << EOF | tee -a /mnt/etc/fstab > /dev/null
tmpfs	/tmp	tmpfs	rw,size=$RAM_size,nr_inodes=5k,noexec,nodev,nosuid,mode=1700	0	0  
EOF
  echo
  until [ "$FSTAB_proceed" == "true" ]; do 
    until [ "$VALID_ENTRY_fstab_check" == "true" ]; do 
      read -rp "If you want to check whether the UUIDs in fstab is correct, enter \"YES\"; if not, enter \"NO\": " FSTAB_check
      echo
      if [ "$FSTAB_check" == "NO" ]; then
        VALID_ENTRY_fstab_check=true
        FSTAB_proceed=true
      elif [ "$FSTAB_check" == "YES" ]; then
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
            umount /mnt
            echo "$ENCRYPTION_2" | cryptsetup close cryptroot
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

  if [ "$ENCRYPTION_choice" == "1" ]; then
    DRIVE_LABEL_after_chroot="$DRIVE_LABEL_primary"
    ENCRYPTION_after_chroot="1"
    ENCRYPTION_PASSWD_after_chroot="$ENCRYPTION_2"
  fi
  mkdir /mnt/install_script
  cp {artix_runit_pre_chroot.sh,artix_runit_after_chroot.sh,AUR.txt,farewell.txt,packages.txt,summary.txt,hostname.txt,btrfs_snapshot.sh,users.txt,paru-1.8.2-1-x86_64.pkg.tar.zst,pacman.conf,paru.conf,GRUB.txt,initramfs.txt,locals.txt,time.txt} /mnt/install_script
  artix-chroot /mnt /install_script/artix_runit_after_chroot.sh "$DRIVE_LABEL_after_chroot" "$ENCRYPTION_after_chroot" "$ENCRYPTION_PASSWD_after_chroot" "$INIT_choice"
