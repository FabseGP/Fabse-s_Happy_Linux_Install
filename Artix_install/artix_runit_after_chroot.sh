#!/usr/bin/bash

# Correct start

  cd /install_script || exit

#----------------------------------------------------------------------------------------------------------------------------------

# Parameters

  BEGINNER_DIR=$(pwd)

  AUR_choice=""
  ENCRYPTION_choice=""
  DRIVE_LABEL=""
  VALID_ENTRY_choice=""
  VALID_ENTRY_intro_check=""

  VALID_ENTRY_timezone=""
  TIMEZONE_1=""
  TIMEZONE_2=""
  TIME_check=""
  VALID_ENTRY_time_check=""
  TIME_proceed=""
 
  LANGUAGES=""
  LANGUAGES_array=""
  LANGUAGE=""
  VALID_ENTRY_languages=""
  VALID_ENTRY_locals_check=""

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
  USER_passwd=""
  USER_check=""
  VALID_ENTRY_user_check_username=""
  VALID_ENTRY_user_check_passwd=""
  USER_proceed_username=""
  USER_proceed_passwd=""

  DOAS_choice=""
  DOAS_confirm=""
  VALID_ENTRY_doas_check=""
  VALID_ENTRY_doas_confirm=""

  BOOTLOADER_label=""
  BOOTLOADER_check=""
  VALID_ENTRY_bootloader_check=""
  BOOTLOADER_proceed=""
  UUID=""

  PACKAGES=""
  PACKAGES_check=""
  PACKAGES_choice=""
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
    [[ "$1" -eq 1 ]] && echo -e "${BBlue}[${Reset}${Bold}X${BBlue}]${Reset}" || echo -e "${BBlue}[ ${BBlue}]${Reset}";
}

#----------------------------------------------------------------------------------------------------------------------------------

# Configuring Arch's repository

  cd "$BEGINNER_DIR" || exit
  pacman -Sy --noconfirm archlinux-keyring artix-keyring
  pacman-key --init
  pacman-key --populate archlinux artix
  mv pacman.conf /etc/pacman.conf
  pacman -Syy
  echo
  lines
#----------------------------------------------------------------------------------------------------------------------------------

# Until-loop; intro

  until [ "$VALID_ENTRY_choice" == "true" ]; do 
    read -rp "Do you plan to utilise AUR? Please type \"1\" for yes, \"2\" if not: " AUR_choice
    echo
    if [ "$AUR_choice" == "2" ]; then
      print yellow "AUR will not be configured"
      echo
      VALID_ENTRY_choice=true
    elif [ "$AUR_choice" == "1" ]; then
      print green "Access to AUR will be configured"
      echo
      VALID_ENTRY_choice=true
    else
      VALID_ENTRY_choice=false
      print red "Invalid answer. Please try again"
      echo
    fi
  done
  VALID_ENTRY_choice=""
  until [ "$VALID_ENTRY_choice" == "true" ]; do 
    read -rp "Did you set up encryption previously? Please type \"1\" for yes, \"2\" if not: " ENCRYPTION_choice
    echo
    if [ "$ENCRYPTION_choice" == "2" ]; then
      print yellow "Forget this question..."
      echo
      VALID_ENTRY_choice=true
    elif [ "$ENCRYPTION_choice" == "1" ]; then
      fdisk -l
      echo
      print blue "Which drive was set up for encryption, for example \"sda3\"?"
      read -r DRIVE_LABEL
      echo
      VALID_ENTRY_choice=true
    else
      VALID_ENTRY_choice=false
      print red "Invalid answer. Please try again"
      echo
    fi
  done
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  more time.txt
  echo
  until [ "$TIME_proceed" == "true" ]; do 
    VALID_ENTRY_time_check=false # Necessary for trying again
    print blue "Please choose your locale time; if two-part (such as Europe/Copenhagen) choose the first part "
    select TIMEZONE_1 in $(ls /usr/share/zoneinfo); do
      if [ -d "/usr/share/zoneinfo/$TIME" ]; then
        echo
        select TIMEZONE_2 in $(ls /usr/share/zoneinfo/"$TIMEZONE_1"); do
          ln -sf /usr/share/zoneinfo/"$TIMEZONE_1"/"$TIMEZONE_2" /etc/localtime
        break
        done
      else
        ln -sf /usr/share/zoneinfo/"$TIMEZONE_1" /etc/localtime
      fi
    break
    done
    echo
    until [ "$VALID_ENTRY_time_check" == "true" ]; do 
      read -rp "You have chosen \""$TIMEZONE_1"/"$TIMEZONE_2"\" . Type \"YES\" if correct or \"NO\" if not: " TIME_check
      echo
      if [ "$TIME_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        TIMEZONE_1=""
        TIMEZONE_2=""
        TIME_proceed=false
        VALID_ENTRY_time_check=true
        echo
      elif [ "$TIME_check" == "YES" ]; then
        TIME_proceed=true
        VALID_ENTRY_time_check=true
      else
        VALID_ENTRY_time_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  hwclock --systohc
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals_languages

  more locals.txt
  echo
  print blue "Which languages do you wish to generate? Please follow the example below: "
  print purple "Example: da_DK.UTF-8 en_GB.UTF-8 en_US.UTF-8"
  echo
  read -rp "Languages: " LANGUAGES 
  IFS=' ' read -ra LANGUAGES_array <<< "$LANGUAGES"
  for val in "${LANGUAGES_array[@]}";
  do
    sed -i '/'"$val"'/s/^#//g' /etc/locale.gen
  done
  echo
  locale-gen
  echo
  print blue "Any thoughts on the system-wide language?"
  print purple "Example: da_DK.UTF-8"
  echo
  read -rp "Language: " LANGUAGE
  echo
  echo LANG="$LANGUAGE" > /etc/locale.conf
  echo
  echo "export LANG="$LANGUAGE"" >> /etc/profile
  echo "export LC_ALL="$LANGUAGE"" >> /etc/profile
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up keymap

  until [ "$KEYMAP_proceed" == "true" ]; do 
    VALID_ENTRY_keymap_check=false # Necessary for trying again
    print blue "Any thoughts on the system-wide keymap?"
    print purple "Example: dk-latin1"
    echo
    read -rp "Keymap: " KEYMAP
    echo
    until [ "$VALID_ENTRY_keymap_check" == "true" ]; do 
      read -rp "You have chosen \""$KEYMAP"\". Type \"YES\" if correct or \"NO\" if not: " KEYMAP_check
      echo
      if [ "$KEYMAP_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        KEYMAP=""
        KEYMAP_proceed=false
        VALID_ENTRY_keymap_check=true
        echo
      elif [ "$KEYMAP_check" == "YES" ]; then
        KEYMAP_proceed=true
        VALID_ENTRY_keymap_check=true
      else
        VALID_ENTRY_keymap_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  echo "KEYMAP="$KEYMAP"" >> /etc/vconsole.conf
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting root-password + creating personal user

  more users.txt
  echo
  until [ "$ROOT_proceed" == "true" ]; do 
    VALID_ENTRY_root_check=false # Necessary for trying again
    read -rp "Any thoughts on a root-password? Please enter it here: " ROOT_passwd
    echo
    until [ "$VALID_ENTRY_root_check" == "true" ]; do 
      read -rp "You have chosen \""$ROOT_passwd"\" as the root-password. Type \"YES\" if fine or \"NO\" if you wish to change it: " ROOT_check
      echo
      if [ "$ROOT_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        ROOT_passwd=""
        VALID_ENTRY_root_check=true
        echo
      elif [ "$ROOT_check" == "YES" ]; then
        ROOT_proceed=true
        VALID_ENTRY_root_check=true
        echo "root:$ROOT_passwd" | chpasswd
      else
        VALID_ENTRY_root_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  echo
  until [ "$USER_proceed_name" == "true" ]; do 
    VALID_ENTRY_user_check_username=false # Necessary for trying again
    print blue "Can I suggest a username for a new user?"
    read -rp "Username: " USERNAME
    echo
    until [ "$VALID_ENTRY_user_check_username" == "true" ]; do 
      read -rp "You have chosen \""$USERNAME"\" as username. Type \"YES\" if correct or \"NO\" if not: " USER_check
      echo
      if [ "$USER_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        USERNAME=""
        VALID_ENTRY_user_check_username=true
        echo
      elif [ "$USER_check" == "YES" ]; then
        VALID_ENTRY_user_check_username=true
        USER_proceed_name=true
      elif [ "$USER_check" != "YES" ] && [ "$USER_check" != "NO" ]; then 
        VALID_ENTRY_user_check_username=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  until [ "$USER_proceed_passwd" == "true" ]; do 
    VALID_ENTRY_user_check_passwd=false # Necessary for trying again
    echo
    print blue "A password too for \"$USERNAME\"?"
    read -rp "Password: " USER_passwd
    echo
    USER_check=""
    until [ "$VALID_ENTRY_user_check_passwd" == "true" ]; do 
      read -rp "You have chosen \""$USER_passwd"\" as the user-password. Type \"YES\" if fine or \"NO\" if you wish to change it: " USER_check
      echo
      if [ "$USER_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        USER_passwd=""
        VALID_ENTRY_user_check_passwd=true
        echo
      elif [ "$USER_check" == "YES" ]; then
        VALID_ENTRY_user_check_passwd=true
        USER_proceed_passwd=true
        useradd -m -g users -G video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel,realtime -p "$(openssl passwd -crypt "$USER_passwd")" "$USERNAME"
      elif [ "$USER_check" != "NO" ] && [ "$USER_check" != "YES" ]; then 
        VALID_ENTRY_user_check_passwd=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up hostname

  more hostname.txt
  echo
  until [ "$HOSTNAME_proceed" == "true" ]; do 
    VALID_ENTRY_hostname_check=false # Necessary for trying again
    print blue "What name do you wish to host?"
    read -rp "Hostname: " HOSTNAME
    echo
    until [ "$VALID_ENTRY_hostname_check" == "true" ]; do 
      read -rp "You have chosen \""$HOSTNAME"\" as hostname. Type \"YES\" if correct or \"NO\" if not: " HOSTNAME_check
      echo
      if [ "$HOSTNAME_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        HOSTNAME=""
        HOSTNAME_proceed=false
        VALID_ENTRY_hostname_check=true
        echo
      elif [ "$HOSTNAME_check" == "YES" ]; then
        HOSTNAME_proceed=true
        VALID_ENTRY_hostname_check=true
      else
        VALID_ENTRY_hostname_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  echo "$HOSTNAME" >> /etc/hostname
  cat << EOF | tee -a /etc/hosts > /dev/null
127.0.0.1 localhost
::1 localhost
127.0.1.1 "$HOSTNAME".localdomain "$HOSTNAME" 
EOF
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# AUR-configuration

  if [ "$AUR_choice" == "1" ]; then
    more AUR.txt
    echo
    pacman -U --noconfirm paru-1.8.2-1-x86_64.pkg.tar.zst
    pacman -Syu --noconfirm
    echo "alias yay=paru" >> /etc/profile
    cd "$BEGINNER_DIR" || exit
    mv paru.conf /etc/paru.conf # Links sudo to doas + more
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Choice of DE/VM, Wayland/Xorg and other packages/services

  more packages.txt
  echo
  until [ "$PACKAGES_proceed" == "true" ]; do 
    print blue "If you want to install any other packages/services or desktop environments / window managers from either AUR or with pacman now, type \"YES\" - otherwise type \"NO\" "
    read -r PACKAGES_choice
    echo
    if [ "$PACKAGES_choice" == "YES" ]; then
      until [ "$VALID_ENTRY_packages_check" == "true" ]; do 
        print blue "Please enter all packages/services which should be installed now; all must be separated by space: "
        read -rp "Packages: " PACKAGES
        echo
        print cyan "These packages/services will be installed: "
        echo "$PACKAGES"
        echo
        read -rp "If that's correct, type \"YES\" - otherwise type \"NO\": " PACKAGES_check
        if [ "$PACKAGES_check" == "NO" ]; then
          print yellow "You'll get a new prompt"
          PACKAGES=""
          PACKAGES_check=false
          VALID_ENTRY_packages_check=true
          echo
        elif [ "$PACKAGES_check" == "YES" ]; then
          yay -S "$PACKAGES"
          VALID_ENTRY_packages_check=true
        else
          VALID_ENTRY_packages_check=false
          print red "Invalid answer. Please try again"
          echo
        fi
      done
      PACKAGES_proceed=true
    elif [ "$PACKAGES_choice" == "NO" ]; then
      print yellow "No additional packages will be installed"
      PACKAGES_proceed=true
      echo
    else
      PACKAGES_proceed=false
      print red "Invalid answer. Please try again"
      echo
    fi
  done
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting NetworkManager + fcron + chrony to start on boot

  ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default
  ln -s /etc/runit/sv/fcron /etc/runit/runsvdir/default
  ln -s /etc/runit/sv/chrony /etc/runit/runsvdir/default
  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Choosing either doas or sudo + allowing users to use the respective command

  until [ "$VALID_ENTRY_doas_check" == "true" ]; do 
    read -rp "Doas is a lightweight and more secure alternative to sudo with similar commands. If you wish to replace sudo with doas, type \"YES\" - otherwise type \"NO\": " DOAS_choice
    echo
    VALID_ENTRY_doas_confirm=false # Neccessary for trying again
    until [ "$VALID_ENTRY_doas_confirm" == "true" ]; do 
      read -rp "You have chosen \""$DOAS_choice"\" regarding replacing sudo. Type \"YES\" if correct or \"NO\" if not: " DOAS_confirm
      if [ "$DOAS_confirm" == "YES" ]; then
        if [ "$DOAS_choice" == "YES" ]; then
          pacman -Rns --noconfirm sudo
          pacman -S --noconfirm opendoas
          touch /etc/doas.conf
          cat << EOF | tee -a /etc/doas.conf > /dev/null
permit persist :wheel
EOF
          chown -c root:root /etc/doas.conf
          chmod -c 0400 /etc/doas.conf
          VALID_ENTRY_doas_confirm=true
          VALID_ENTRY_doas_check=true
          echo
        elif [ "$DOAS_choice" == "NO" ]; then
          echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)
          sed -i -e "/Sudo = doas/s/^#//" /etc/doas.conf
          VALID_ENTRY_doas_confirm=true
          VALID_ENTRY_doas_check=true
        fi
      elif [ "$DOAS_confirm" == "NO" ]; then
        print yellow "Roger roger - back to square one again!"
        VALID_ENTRY_doas_confirm=true
        VALID_ENTRY_doas_check=false
      else
        print red "I don't have that much time to deal with you, okay? Please answer correct!"
        VALID_ENTRY_doas_confirm=false
        VALID_ENTRY_doas_check=false  
      fi
    done
  done 
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Regenerating initramfs with encrypt-hook + keyfile

  more initramfs.txt
  sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS=(base\ udev\ keymap\ keyboard\ autodetect\ modconf\ block\ encrypt\ filesystems\ fsck)/' /etc/mkinitcpio.conf
  sed -i 's/BINARIES=()/BINARIES=(\/usr\/bin\/btrfs)/' /etc/mkinitcpio.conf
  if [ "$ENCRYPTION_choice" == "1" ]; then
    dd bs=512 count=5 if=/dev/random of=/.secret/crypto_keyfile.bin iflag=fullblock
    chmod 600 /.secret/crypto_keyfile.bin
    chmod 600 /boot/initramfs-linux*
    echo
    print yellow "Please have your encryption-password ready"
    echo
    cryptsetup luksAddKey /dev/"$DRIVE_LABEL" /.secret/crypto_keyfile.bin
    sed -i 's/FILES=()/FILES=(\/.secret\/crypto_keyfile.bin)/' /etc/mkinitcpio.conf
  fi
  mkinitcpio -p linux-zen
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
      read -rp "You have chosen \""$BOOTLOADER_label"\". Type \"YES\" if correct or \"NO\" if not: " BOOTLOADER_check
      echo
      if [ "$BOOTLOADER_check" == "NO" ]; then
        print yellow "You'll get a new prompt"
        BOOTLOADER_label=""
        BOOTLOADER_proceed=false
        VALID_ENTRY_bootloader_check=true
        echo
      elif [ "$BOOTLOADER_check" == "YES" ]; then
        BOOTLOADER_proceed=true
        VALID_ENTRY_bootloader_check=true
      else
        VALID_ENTRY_bootloader_check=false
        print red "Invalid answer. Please try again"
        echo
      fi
    done
  done
  print blue "The bootloader will be viewed as "$BOOTLOADER_label" in the BIOS"
  echo
  grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id="$BOOTLOADER_label" --modules="luks2 fat all_video jpeg png pbkdf2 gettext gzio gfxterm gfxmenu gfxterm_background part_gpt cryptodisk gcry_rijndael gcry_sha512 btrfs" --recheck
  if [ "$ENCRYPTION_choice" == "1" ]; then
    UUID_1=$(lsblk -no TYPE,UUID /dev/"$DRIVE_LABEL" | awk '$1=="part"{print $2}')
    UUID_2=$(lsblk -no TYPE,UUID /dev/"$DRIVE_LABEL" | awk '$1=="part"{print $2}' | tr -d -)
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="lsm=landlock,lockdown,yama,bpf\ loglevel=3\ quiet\ cryptdevice=UUID='"$UUID_1"':cryptroot:allow-discards\ root=UUID='"$UUID_1"'\ cryptkey=rootfs:/.secret"/' /etc/default/grub
    sed -i -e "/GRUB_ENABLE_CRYPTODISK/s/^#//" /etc/default/grub
    touch grub-pre.cfg
    cat << EOF | tee -a grub-pre.cfg > /dev/null
insmod all_video
set gfxmode=auto
terminal_input console
terminal_output gfxterm
cryptomount -u $UUID_2
set prefix='(crypto0)/@grub'
set root='(crypto0)'
insmod normal
normal
EOF
    grub-mkimage -p '(crypto0)/@grub' -O x86_64-efi -c grub-pre.cfg -o /boot/EFI/EFI/"$BOOTLOADER_label"/grubx64.efi luks2 fat all_video jpeg png pbkdf2 gettext gzio gfxterm gfxmenu gfxterm_background part_gpt cryptodisk gcry_rijndael gcry_sha512 btrfs
    rm grub-pre.cfg
  fi
  echo
  grub-mkconfig -o /boot/grub/grub.cfg
  cd "$BEGINNER_DIR" || exit
  mv grub-btrfs-update.stop /etc/local.d
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Security enhancements + BTRFS-snapshot

  cat << EOF | tee -a /etc/pam.d/system-login > /dev/null # 3 seconds delay, when system login failes
auth optional pam_faildelay.so delay=3000000
EOF
  mkdir /etc/pacman.d/hooks
  touch /etc/pacman.d/hooks/firejail.hook
  cat << EOF | tee -a /etc/pacman.d/hooks/firejail.hook > /dev/null
[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Operation = Remove
Target = usr/bin/*
Target = usr/local/bin/*
Target = usr/share/applications/*.desktop

[Action]
Description = Configure symlinks in /usr/local/bin based on firecfg.config...
When = PostTransaction
Depends = firejail
Exec = /bin/bash -c 'firecfg >/dev/null 2>&1'
EOF
  cd "$BEGINNER_DIR" || exit
  mv btrfs_snapshot.sh /etc/cron.daily # Maximum 3 snapshots stored
  chmod u+x /etc/cron.daily/btrfs_snapshot.sh

#----------------------------------------------------------------------------------------------------------------------------------

# Summary before restart

  more summary.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Farewell

  more farewell.txt
  echo
  exit
  umount -f -R /mnt
  echo
  print yellow "You might want to delete /install_script "
  echo
  exit
