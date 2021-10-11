#!/usr/bin/bash

# Correct start

  cd /install_script || exit

#----------------------------------------------------------------------------------------------------------------------------------

# Parameters

  BEGINNER_DIR=$(pwd)

  DRIVE_LABEL="$1"
  ENCRYPTION_choice="$2"
  ENCRYPTION_passwd="$3"

  CONFIRM_choices=""
  ALL_choices=""
  VALID_ENTRY_all_check=""

  AUR_choice=""
  VALID_ENTRY_AUR_choice=""

  TIMEZONE_1=""
  TIMEZONE_2=""

  LANGUAGES=""
  LANGUAGES_array=""
  LANGUAGE=""

  KEYMAP=""

  HOSTNAME=""

  ROOT_passwd=""
  USERNAME=""
  USER_passwd=""

  PACKAGES=""

  DOAS_choice=""
  VALID_ENTRY_DOAS_choice=""

  BOOTLOADER_label=""
  UUID_1=$(blkid -s UUID -o value "$DRIVE_LABEL")
  UUID_2=$(lsblk -no TYPE,UUID "$DRIVE_LABEL" | awk '$1=="part"{print $2}' | tr -d -)

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

# Until-loop; all choices

  until [ "$CONFIRM_choices" == "true" ]; do
    VALID_ENTRY_all_check=false # Neccessary for trying again
    # AUR
    until [ "$VALID_ENTRY_AUR_choice" == "true" ]; do 
      read -rp "Do you plan to utilise AUR? Please type \"1\" for yes, \"2\" if not: " AUR_choice
      echo
      if [ "$AUR_choice" != "1" ] && [ "$AUR_choice" != "2" ]; then
        VALID_ENTRY_AUR_choice=false
        print red "Invalid answer. Please try again"
        echo s
      else
        VALID_ENTRY_AUR_choice=true
        echo
      fi
    done
    lines
    # Timezone
    more time.txt
    echo
    print blue "Please choose your locale time; if two-part (such as Europe/Copenhagen) choose the first part "
    select TIMEZONE_1 in $(ls /usr/share/zoneinfo); do
      if [ -d "/usr/share/zoneinfo/"$TIMEZONE_1"" ]; then
        echo
        select TIMEZONE_2 in $(ls /usr/share/zoneinfo/"$TIMEZONE_1"); do
        break
        done
      fi
    break
    done
    lines
    # Language
    more locals.txt
    echo
    print blue "Which languages do you wish to generate? Please follow the example below: "
    print purple "Example: da_DK.UTF-8 en_GB.UTF-8 en_US.UTF-8"
    echo
    read -rp "Languages: " LANGUAGES 
    echo
    print blue "Any thoughts on the system-wide language?"
    print purple "Example: da_DK.UTF-8"
    echo
    read -rp "Language: " LANGUAGE
    lines
    # Keymap
    print blue "Any thoughts on the system-wide keymap?"
    print purple "Example: dk-latin1"
    echo
    read -rp "Keymap: " KEYMAP
    lines
    # Hostname
    more hostname.txt
    echo
    print blue "What name do you wish to host?"
    read -rp "Hostname: " HOSTNAME
    lines
    # Users
    more users.txt
    echo
    read -rp "Any thoughts on a root-password? Please enter it here: " ROOT_passwd
    echo
    print blue "Can I suggest a username for a new user?"
    read -rp "Username: " USERNAME
    echo
    print blue "A password too for \"$USERNAME\"?"
    read -rp "Password: " USER_passwd
    lines
    # Packages
    more packages.txt
    echo
    print blue "If you wish to install any packages now (all separated by space), please type them now - otherwise press enter: "
    read -rp "Packages: " PACKAGES
    lines
    # Sudo vs Opendoas
    until [ "$VALID_ENTRY_DOAS_choice" == "true" ]; do 
    read -rp "Doas is a lightweight and more secure alternative to sudo with similar commands. If you wish to replace sudo with doas, type \"1\" - otherwise type \"2\": " DOAS_choice
    echo
      if [ "$DOAS_choice" != "1" ] && [ "$DOAS_choice" != "2" ]; then
        VALID_ENTRY_DOAS_choice=false
        print red "Invalid answer. Please try again"
        echo
      else
        VALID_ENTRY_DOAS_choice=true
        echo
      fi
    done
    lines
    # Bootloader_ID
    read -rp "Any fitting name for the bootloader? " BOOTLOADER_label
    echo
    # Summary
    print blue "You have chosen the following options: "
    echo
    if [[ -z "$TIMEZONE_2" ]]; then
      print green "TIMEZONE = \""$TIMEZONE_1"\""
    else
      print green "TIMEZONE = \""$TIMEZONE_1"/"$TIMEZONE_2"\""
    fi
    print green "LANGUAGES_generated = \""$LANGUAGES"\""
    print green "LANGUAGE_system = \""$LANGUAGE"\""
    print green "KEYMAP = \""$KEYMAP"\""
    print green "HOSTNAME = \""$HOSTNAME"\""
    print green "ROOT_passwd = \""$ROOT_passwd"\""
    print green "USERNAME = \""$USERNAME"\" and USER_passwd = \""$USER_passwd"\""
    if [[ -z "$PACKAGES" ]]; then
      print green "No additional packages will be installed"
    else
      print green "PACKAGES = \""$PACKAGES"\""
    fi
    print green "BOOTLOADER_label = \""$BOOTLOADER_label"\""
    echo -n "AUR = " && checkbox "$AUR_choice"
    echo -n "REPLACE_sudo = " && checkbox "$DOAS_choice"
    echo
    print white "Where [X] = YES and [ ] = NO"
    echo
    until [ "$VALID_ENTRY_all_check" == "true" ]; do 
      read -rp "Is everything fine? Please type either \"YES\" or \"NO\": " ALL_choices
      echo
        if [ "$ALL_choices" == "YES" ]; then 
          VALID_ENTRY_all_check=true
          CONFIRM_choices=true
          if [ "$ENCRYPTION_choice" == "1" ]; then
            dd bs=512 count=6 if=/dev/random of=/.secret/crypto_keyfile.bin iflag=fullblock
            chmod 600 /.secret/crypto_keyfile.bin
            chmod 600 /boot/initramfs-linux*
            echo "$ENCRYPTION_passwd" | cryptsetup luksAddKey "$DRIVE_LABEL" /.secret/crypto_keyfile.bin
            sed -i 's/FILES=()/FILES=(\/.secret\/crypto_keyfile.bin)/' /etc/mkinitcpio.conf
          fi
        elif [ "$ALL_choices" == "NO" ]; then  
          TIMEZONE_1=""
          TIMEZONE_2=""
          LANGUAGES=""
          LANGUAGE=""
          KEYMAP=""
          HOSTNAME=""
          ROOT_passwd=""
          USERNAME=""
          PACKAGES=""
          BOOTLOADER_label=""
          AUR_choice=""
          DOAS_choice=""
          VALID_ENTRY_AUR_choice=""
          VALID_ENTRY_DOAS_choice=""
          VALID_ENTRY_all_check=true
          CONFIRM_choices=false
          print cyan "Back to square one!"
          echo
        else
          VALID_ENTRY_all_check=true
          print red "Invalid answer. Please try again"
          echo
        fi
    done
  done
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Configuring Arch's repository

  cd "$BEGINNER_DIR" || exit
  pacman -Sy --noconfirm archlinux-keyring artix-keyring
  pacman-key --init
  pacman-key --populate archlinux artix
  cp pacman.conf /etc/pacman.conf
  pacman -Syy
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  if [[ -z "$TIMEZONE_2" ]]; then
    ln -sf /usr/share/zoneinfo/"$TIMEZONE_1" /etc/localtime
  else
    ln -sf /usr/share/zoneinfo/"$TIMEZONE_1"/"$TIMEZONE_2" /etc/localtime
  fi
  hwclock --systohc

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals_languages

  IFS=' ' read -ra LANGUAGES_array <<< "$LANGUAGES"
  for val in "${LANGUAGES_array[@]}";
  do
    sed -i '/'"$val"'/s/^#//g' /etc/locale.gen
  done
  echo
  locale-gen
  echo
  echo "export LANG="$LANGUAGE"" >> /etc/profile
  echo "export LC_ALL="$LANGUAGE"" >> /etc/profile
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up keymap

  echo "KEYMAP="$KEYMAP"" >> /etc/vconsole.conf
  kbd_mode -u
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting root-password + creating personal user

  echo "root:$ROOT_passwd" | chpasswd
  useradd -m -g users -G video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel,realtime -p "$(openssl passwd -crypt "$USER_passwd")" "$USERNAME"
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up hostname

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
    cp paru.conf /etc/paru.conf # Links sudo to doas + more
  fi
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Choice of DE/VM, Wayland/Xorg and other packages/services

  yay --noconfim --useask -S "$PACKAGES"
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting NetworkManager + fcron + chrony to start on boot

  ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default
  ln -s /etc/runit/sv/fcron /etc/runit/runsvdir/default
  ln -s /etc/runit/sv/chrony /etc/runit/runsvdir/default
  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Choosing either doas or sudo + allowing users to use the respective command

  if [ "$DOAS_choice" == "1" ]; then
    pacman -Rns --noconfirm sudo
    pacman -S --noconfirm opendoas
    touch /etc/doas.conf
    cat << EOF | tee -a /etc/doas.conf > /dev/null
permit persist :wheel
EOF
    chown -c root:root /etc/doas.conf
    chmod -c 0400 /etc/doas.conf
  elif [ "$DOAS_choice" == "2" ]; then
    echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)
    sed -i -e "/Sudo = doas/s/^#*/;/" /etc/doas.conf
  fi 
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Regenerating initramfs with encrypt-hook + keyfile

  more initramfs.txt
  sed -i 's/HOOKS=(base\ udev\ autodetect\ modconf\ block\ filesystems\ keyboard\ fsck)/HOOKS=(base\ udev\ keymap\ keyboard\ autodetect\ modconf\ block\ encrypt\ filesystems\ fsck)/' /etc/mkinitcpio.conf
  sed -i 's/BINARIES=()/BINARIES=(\/usr\/bin\/btrfs)/' /etc/mkinitcpio.conf
  mkinitcpio -p linux-zen
  echo
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up GRUB

  more GRUB.txt
  echo
  print blue "The bootloader will be viewed as "$BOOTLOADER_label" in the BIOS"
  echo
  grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id="$BOOTLOADER_label" --modules="luks2 fat all_video jpeg png pbkdf2 gettext gzio gfxterm gfxmenu gfxterm_background part_gpt cryptodisk gcry_rijndael gcry_sha512 btrfs" --recheck
  if [ "$ENCRYPTION_choice" == "1" ]; then
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="lsm=landlock,lockdown,apparmor,yama,bpf\ loglevel=3\ quiet\ cryptdevice=UUID='"$UUID_1"':cryptroot:allow-discards\ root=\/dev\/mapper\/cryptroot\ cryptkey=rootfs:\/.secret\/crypto_keyfile.bin"/' /etc/default/grub
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
  cat << EOF | tee -a /etc/firejail/firejail.users > /dev/null
"$USERNAME"
EOF
  cd "$BEGINNER_DIR" || exit
  cp btrfs_snapshot.sh /.snapshots # Maximum 3 snapshots stored
  cp grub-btrfs.sh /.snapshots # Updates GRUB to show snapshots at boot
  ln -s /.snapshots/btrfs_snapshot.sh /etc/cron.daily/btrfs_snapshot.sh
  ln -s /.snapshots/grub-btrfs.sh /etc/cron.daily/grub-btrfs.sh
  chmod u+x /etc/cron.daily/* && chmod u+x /.snapshots/*
  sed -i -e "/GRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION/s/^#//" /etc/default/grub-btrfs/config
  touch /etc/rc.shutdown
  sed -i 's/02/13/g' /var/spool/fcron/systab.orig # Taking daily snapshots at 13:00:00

#----------------------------------------------------------------------------------------------------------------------------------

# Summary before restart

  more summary.txt

#----------------------------------------------------------------------------------------------------------------------------------

# Farewell

  more farewell.txt
  echo
  exit
  umount -R /mnt
  echo
  print yellow "You might want to delete /install_script "
  echo
  exit
