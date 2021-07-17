#!/usr/bin/bash

# Parameters

  AUR_choice=""
  VALID_ENTRY_choice=""
  VALID_ENTRY_intro_check=""
  INTRO_proceed=""

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
  VALID_ENTRY_user_check_username=""
  VALID_ENTRY_user_check_passwd=""
  USER_proceed_username=""
  USER_proceed_passwd=""

  BOOTLOADER_label=""
  BOOTLOADER_check=""
  VALID_ENTRY_bootloader_check=""
  BOOTLOADER_proceed=""

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

# Until-loop; intro

  lines
  cd /install_script

  until [ "$VALID_ENTRY_choice" == "true" ]; do 
    read -rp "Do you plan to utilise AUR? Please type \"1\" for yes, \"1\" if not: " AUR_choice
    echo
    if [[ "$AUR_choice" == "2" ]]; then
      print yellow "AUR will not be configured"
      echo
      VALID_ENTRY_choice==true
    elif [[ "$AUR_choice" == "1" ]]; then
      print green "Access to AUR will be configured"
      echo
      VALID_ENTRY_choice=true
    else
      VALID_ENTRY_choice=false
      print red "Invalid answer. Please try again"
      echo
    fi
  done

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

  more time.txt
  echo

  until [ "$TIME_proceed" == "true" ]; do 
    VALID_ENTRY_time_check=false # Necessary for trying again
    print blue "Please choose your locale time; if two-part (such as Europe/Copenhagen) choose the first part "
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
      read -rp "You have chosen \""$TIMEZONE_1"/"$TIMEZONE_2"\" . Are you sure that's the correct timezone? Type either \"YES\" or \"NO\": " TIME_check
      echo
      if [[ "$TIME_check" == "NO" ]]; then
        print yellow "You'll get a new prompt"
        TIMEZONE_1=""
        TIMEZONE_2=""
        TIME_proceed=false
        VALID_ENTRY_time_check=true
        echo
      elif [[ "$TIME_check" == "YES" ]]; then
        TIME_proceed=true
        VALID_ENTRY_time_check=true
      else
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
  print blue ""$LANGUAGE_how_many" languages will be generated"
  echo
  if [[ "$LANGUAGE_how_many" == "1" ]]; then
    print blue "What language do you wish to generate?"
    print purple "Example: da_DK.UTF-8"
    read -r LANGUAGE_GEN1
    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
  elif [[ "$LANGUAGE_how_many" == "2" ]]; then
    print blue "Which languages do you wish to generate?"
    print purple "Example: da_DK.UTF-8"
    read -r LANGUAGE_GEN1
    echo
    print blue "Second language"
    read -r LANGUAGE_GEN2
    sed -i 's/^# *\($LANGUAGE_GEN1\)/\1/' /etc/locale.gen
    sed -i 's/^# *\($LANGUAGE_GEN2\)/\1/' /etc/locale.gen
  elif [[ "$LANGUAGE_how_many" == "3" ]]; then
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
  else
    print cyan "Please choose again; I don't have time for this!"
    echo
    read -r LANGUAGE_how_many
    echo
    print blue ""$LANGUAGE_how_many" languages will be generated"
    echo
  fi
  echo
  locale-gen
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
      read -rp "You have chosen \""$KEYMAP"\". Are you sure that's the correct keymap? Type either \"YES\" or \"NO\": " KEYMAP_check
      echo
      if [[ "$KEYMAP_check" == "NO" ]]; then
        print yellow "You'll get a new prompt"
        KEYMAP=""
        KEYMAP_proceed=false
        VALID_ENTRY_keymap_check=true
        echo
      elif [[ "$KEYMAP_check" == "YES" ]]; then
        KEYMAP_proceed=true
        VALID_ENTRY_keymap_check=true
      else
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
      read -rp "You have chosen \""$BOOTLOADER_label"\". Are you sure that's the correct name? Type either \"YES\" or \"NO\": " BOOTLOADER_check
      echo
      if [[ "$BOOTLOADER_check" == "NO" ]]; then
        print yellow "You'll get a new prompt"
        BOOTLOADER_label=""
        BOOTLOADER_proceed=false
        VALID_ENTRY_bootloader_check=true
        echo
      elif [[ "$BOOTLOADER_check" == "YES" ]]; then
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
    ROOT_passwd=$1
    VALID_ENTRY_root_check=false # Necessary for trying again
    print blue "Any thoughts on a root-password"?
    passwd
    echo
    until [ "$VALID_ENTRY_root_check" == "true" ]; do 
      read -rp "You have chosen \""$ROOT_passwd"\". Do you want to change that? Type either \"YES\" or \"NO\": " ROOT_check
      echo
      if [[ "$ROOT_check" == "YES" ]]; then
        print yellow "You'll get a new prompt"
        ROOT_passwd=""
        VALID_ENTRY_root_check=true
        echo
      elif [[ "$ROOT_check" == "NO" ]]; then
        ROOT_proceed=true
        VALID_ENTRY_root_check=true
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
    read -r USERNAME
    until [ "$VALID_ENTRY_user_check_username" == "true" ]; do 
      read -rp "You have chosen \""$USERNAME"\" as username. Are you sure that's correct? Type either \"YES\" or \"NO\": " USER_check
      echo
      if [[ $USER_check == "NO" ]]; then
        print yellow "You'll get a new prompt"
        USERNAME=""
        VALID_ENTRY_user_check_username=true
        echo
      elif [[ $USER_check == "YES" ]]; then
        VALID_ENTRY_user_check_username=true
        useradd -m -g users -G video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,dialout,wheel,realtime "$USERNAME"
        USER_proceed_name=true
      elif [[ $USER_check -ne "NO" ]] && [[ $USER_check -ne "YES" ]]; then 
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
    USERNAME_passwd=$1
    passwd "$USERNAME"
    echo
    USER_check=""
    until [ "$VALID_ENTRY_user_check_passwd" == "true" ]; do 
      read -rp "You have chosen \""$USERNAME_passwd"\" as password. Are you sure that's correct? Type \"YES\" if yes, \"NO\" if no: " USER_check
      echo
      if [[ $USER_check == "NO" ]]; then
        print yellow "You'll get a new prompt"
        USERNAME_passwd=""
        VALID_ENTRY_user_check_passwd=true
        echo
      elif [[ $USER_check == "YES" ]]; then
        VALID_ENTRY_user_check_passwd=true
        USER_proceed_passwd=true
      elif [[ $USER_check -ne "NO" ]] && [[ $USER_check -ne "YES" ]]; then 
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

  until [ "$LOCALS_proceed" == "true" ]; do 
    VALID_ENTRY_hostname_check=false # Necessary for trying again
    print blue "What name do you want to host?"
    read -r HOSTNAME
    echo
    until [ "$VALID_ENTRY_hostname_check" == "true" ]; do 
      read -rp "You have chosen \""$HOSTNAME"\". Are you sure that's the correct hostname? Type \"YES\" if yes, \"NO\" if no: " HOSTNAME_check
      echo
      if [[ "$HOSTNAME_check" == "NO" ]]; then
        print yellow "You'll get a new prompt"
        HOSTNAME=""
        LOCALS_proceed=false
        VALID_ENTRY_hostname_check=true
        echo
      elif [[ "$HOSTNAME_check" == "YES" ]]; then
        LOCALS_proceed=true
        VALID_ENTRY_hostname_check=true
      else
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

# AUR-configuration

  if [[ $AUR_choice == "1" ]]; then
    more AUR.txt
    echo
    cd /opt || return
    git clone https://aur.archlinux.org/yay-git.git
    chown -R "$USERNAME":wheel ./yay-git
    cd yay-git || return
    makepkg -si
  fi
  
  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Choice of DE/VM, Wayland/Xorg and other packages/services

  more packages.txt
  echo

  until [ "$PACKAGES_proceed" == "true" ]; do 
    print blue "If you want to install any other packages/services or desktop environments / window managers now, type \"YES\" - otherwise type \"No\" "
    read -r PACKAGES_choice
    echo
    if [[ "$PACKAGES_choice" == "NO" ]]; then
      print yellow "No additional packages will be installed"
      PACKAGES_proceed=true
      echo
    elif [[ "$PACKAGES_choice" == "YES" ]]; then
      until [ "$VALID_ENTRY_packages_check" == "true" ]; do 
        print blue "Please enter all packages/services which should be installed now; all must be separated by TAB: "
        read -r PACKAGES
        echo
        print cyan "These packages/services will be installed: "
        echo "$PACKAGES"
        echo
        read -rp "If that's correct, type \"YES\" - otherwise type \"NO\": " PACKAGES_check
        if [[ "$PACKAGES_check" == "NO" ]]; then
          print yellow "You'll get a new prompt"
          PACKAGES=""
          PACKAGES_check=false
          VALID_ENTRY_packages_check=true
          echo
        elif [[ "$PACKAGES_check" == "YES" ]]; then
          pacman -Syq --noconfirm "$PACKAGES"
          VALID_ENTRY_packages_check=true
        else
          VALID_ENTRY_packages_check=false
          print red "Invalid answer. Please try again"
          echo
        fi
      done
      PACKAGES_proceed=true
    else
      PACKAGES_proceed=false
      print red "Invalid answer. Please try again"
      echo
    fi
  done

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Setting NetworkManager to start on boot

  ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Allow users to use sudo

  echo "%wheel ALL=(ALL) ALL" | (EDITOR="tee -a" visudo)
  echo

  lines

#----------------------------------------------------------------------------------------------------------------------------------

# Summary before restart

  more summary.txt


#----------------------------------------------------------------------------------------------------------------------------------

# Farewell

  more farewell.txt
  echo
  exit
  exit
  umount -R /mnt
  reboot
 
