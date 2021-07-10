#!/usr/bin/bash

# Parameters

  SWAP_choice=""
  ENCRYPTION_choice=""
  SUBVOLUMES_choice=""
  WIFI_choice=""
  INTRO_choice=""

  VALID_ENTRY_wifi=false
  VALID_ENTRY_swap=false
  VALID_ENTRY_encryption=false
  VALID_ENTRY_subvolumes=false

  VALID_ENTRY_intro_check=false
  INTRO_proceed=false

  WIFI_SSID=""
  WIFI_check=""
  VALID_ENTRY_wifi_check=""
  WIFI_proceed=""
  WIFI_ID=""

  VALID_ENTRY_drive=false
  VALID_ENTRY_drive_choice=false
  OUTPUT=""

  DRIVE_check=""
  DRIVE_proceed=""

  VALID_ENTRY_boot_size_format=""
  VALID_ENTRY_boot_size=""
  VALID_ENTRY_boot_size_check=""
  BOOT_size_check=""

  VALID_ENTRY_swap_size=""
  VALID_ENTRY_swap_size_check=""
  SWAP_size_check=""

  VALID_ENTRY_boot_name=""
  VALID_ENTRY_boot_name_check=""
  BOOT_label_check=""

  VALID_ENTRY_swap_name=""
  VALID_ENTRY_swap_name_check=""
  SWAP_label_check=""

  VALID_ENTRY_primary_name=""
  VALID_ENTRY_primary_name_check=""
  PRIMARY_label_check=""

  BOOT_size=""
  SWAP_size=""

  DRIVE_LABEL=""

  DRIVE_LABEL_boot=""
  DRIVE_LABEL_swap=""
  DRIVE_LABEL_primary=""

  BOOT_label=""
  PRIMARY_label=""
  SWAP_label=""

  FSTAB_check=""
  VALID_ENTRY_fstab_check=""
  FSTAB_proceed=""

  FSTAB_confirm=""
  VALID_ENTRY_fstab_confirm_check=""

  TIMEZONE=""
  HOSTNAME=""
  LANGUAGE=""
  KEYMAP=""

  LANGUAGE_how_many=""
  LANGUAGE_GEN1=""
  LANGUAGE_GEN2=""
  LANGUAGE_GEN3=""  

  VALID_ENTRY_timezone=false

  TIME_check=""
  VALID_ENTRY_time_check=false
  TIME_proceed=""

  VALID_ENTRY_languages=false

  LOCALS_check=""
  VALID_ENTRY_locals_check=false
  LOCALS_proceed=""

  VALID_ENTRY_keymap=false

  KEYMAP_check=""
  VALID_ENTRY_keymap_check=false
  KEYMAP_proceed=""

  HOSTNAME_check=""
  VALID_ENTRY_hostname_check=false
  HOSTNAME_proceed=""

  ROOT_passwd=""

  ROOT_check=""
  VALID_ENTRY_root_check=false
  ROOT_proceed=""

  USERNAME=""
  USERNAME_passwd=""

  USER_check=""
  VALID_ENTRY_user_check=false
  USER_proceed=""

  BOOTLOADER_label=""

  BOOTLOADER_check=""
  VALID_ENTRY_bootloader_check=false
  BOOTLOADER_proceed=""

  SUMMARY=""
  SUMMARY_check=""
  VALID_ENTRY_SUMMARY_check=false
  SUMMARY_proceed="" # Rebooting if true

#----------------------------------------------------------------------------------------------------------------------------------

# Insure that the script is run as root-user

  if [ "$USER" != 'root' ]; then

    echo
    echo "Sorry, this script must be run as ROOT"
    exit 1

  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Introduction

  more welcome.txt # Prints the content of the file
   
  echo

  echo "To tailor the installation to your needs, you have the following choices: "

  echo

  until [ $INTRO_proceed == "true" ]; do 

    until [ $VALID_ENTRY_wifi == "true" ]; do 

      read -rp "Do you plan to use WiFi (unnesscary if using ethernet)? If no, please type \"1\" - if yes, please type \"2\": " WIFI_choice

      if [[ $WIFI_choice == "1" ]]; then
  
        echo
  
        echo "WiFi will therefore not be initialised"
    
        echo

        VALID_ENTRY_wifi=true

      elif [[ $WIFI_choice == "2" ]]; then

        echo

        echo "WiFi will therefore be initialised"
    
        echo

        VALID_ENTRY_wifi=true

      elif [[ $WIFI_choice -ne 1 ]] && [[ $WIFI_choice -ne 2 ]]; then 

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

      elif [[ $ENCRYPTION_choice == "2" ]]; then

        echo

        echo "The main partition will be encrypted"
    
        echo

        VALID_ENTRY_encryption=true

      elif [[ $ENCRYPTION_choice -ne 1 ]] && [[ $ENCRYPTION_choice -ne 2 ]]; then 

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
  
      elif [[ $SWAP_choice == "2" ]]; then

        echo

        echo "The size of the SWAP-partition will be set later on"
   
        echo

        VALID_ENTRY_swap=true

      elif [[ $SWAP_choice -ne 1 ]] && [[ $SWAP_choice -ne 2 ]]; then 

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
  
      elif [[ $SUBVOLUMES_choice == "2" ]]; then

        echo

        echo "The BTRFS-partition will consists of subvolumes"
    
        echo

        VALID_ENTRY_subvolumes=true    

      elif [[ $SUBVOLUMES_choice -ne 1 ]] && [[ $SUBVOLUMES_choice -ne 2 ]]; then 

        VALID_ENTRY_subvolumes=false
        
        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
      
    done
 
    echo

    echo "You have chosen the following choices: "

    more text

    until [ $VALID_ENTRY_intro_check == "true" ]; do 

      read -rp "Is everything fine? Type \"YES\" if yes, \"NO\" if no: " INTRO_choice

        if [[ $INTRO_choice == "YES" ]]; then 

          VALID_ENTRY_intro_check=true

          INTRO_proceed=true

        elif [[ $INTRO_choice == "NO" ]]; then  
 
          SWAP_choice=""
          ENCRYPTION_choice=""
          SUBVOLUMES_choice=""
          WIFI_choice=""
          INTRO_choice=""

          VALID_ENTRY_wifi=false
          VALID_ENTRY_swap=false
          VALID_ENTRY_encryption=false
          VALID_ENTRY_subvolumes=false

          VALID_ENTRY_intro_check=true

          INTRO_proceed=false

          echo

          echo "Back to square one!"

          echo

        elif [[ $INTRO_choice -ne "NO" ]] && [[ $INTRO_choice -ne "YES" ]]; then 

          VALID_ENTRY_intro_check=true

          echo 

          echo "Invalid answer. Please try again"

          echo

        fi
     
    done

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

    until [ "$WIFI_proceed" == "true" ]; do 

      read -rp "Please type the WIFI-name from the list above, which you wish to connect to: " WIFI_SSID
    
      echo
   
      until [ "$VALID_ENTRY_wifi_check" == "true" ]; do 

        read -rp "You have chosen $WIFI_SSID. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " WIFI_check

        echo

        if [[ $WIFI_check == "YES" ]]; then

          echo "You'll get a new prompt"

          WIFI_SSID=""

          WIFI_proceed=false

          VALID_ENTRY_wifi_check=true

          echo

        elif [[ $WIFI_check == "NO" ]]; then
        
          WIFI_proceed=true

          VALID_ENTRY_wifi_check=true

        elif [[ $WIFI_check -ne "NO" ]] && [[ $WIFI_check -ne "YES" ]]; then 

          VALID_ENTRY_wifi_check=false

          echo 

          echo "Invalid answer. Please try again"

          echo

        fi

      done

    done
    
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

  echo

  echo "Which drive do you want to partition?"

  until [ $VALID_ENTRY_drive == "true" ]; do 

    read -r DRIVE_LABEL
    OUTPUT="fdisk -l | sed -n "s/^.*\("$DRIVE_LABEL"\).*$/\1/p""

    if [[ $DRIVE_LABEL == "$OUTPUT" ]]; then 

      until [ $VALID_ENTRY_drive_choice == "true" ]; do 

        read -rp "You have chosen ""$DRIVE_LABEL"" - is that the correct drive? Type \"1\" for no, \"2\" for yes: " DRIVE_check

        if [[ $DRIVE_check == "1" ]]; then

          echo "You'll get a new prompt"

          VALID_ENTRY_drive_choice=true

          VALID_ENTRY_drive=false

        elif [[ $DRIVE_check == "2" ]]; then

          echo "You'll get a new prompt"

          VALID_ENTRY_drive_choice=true

          VALID_ENTRY_drive=true

        elif [[ $DRIVE_check -ne 1 ]] && [[ $DRIVE_check -ne 2 ]]; then 

          VALID_ENTRY_drive_choice=false

          echo 

          echo "Invalid answer. Please try again"

          echo

        fi

      done

    else
   
       echo 

       echo "Invalid drive. Please try again"

       echo

    fi

  done

  if [[ $SWAP_choice == "1" ]]; then

    DRIVE_LABEL_boot="$DRIVE_LABEL""1"
    DRIVE_LABEL_primary="$DRIVE_LABEL""2"

    badblocks -c 10240 -s -w -t random -v "$DRIVE_LABEL"

    until [ "$DRIVE_proceed" == "true" ]; do 

      until [ "$VALID_ENTRY_boot_size_format" == "true" ] && [ "$VALID_ENTRY_boot_size" == "true" ]; do 

        read -rp "Any favourite size for the boot-partition in MB? Though minimum 256MB; only type the size without units: " BOOT_size

        echo

        if ! [[ "$BOOT_size" =~ ^[0-9]+$ ]]; then

          echo "Sorry, only numbers please"

          echo

          BOOT_size=""
 
          VALID_ENTRY_boot_size_format=false

        elif ! [[ "$BOOT_size" -ge 256 ]]; then

          echo "Sorry, the boot-partition will not be large enough"

          echo

          BOOT_size=""
 
          VALID_ENTRY_boot_size_format=false

        else 

          VALID_ENTRY_boot_size_format=true

        fi
  
        echo

        if [ "$VALID_ENTRY_boot_size_format" == "true" ]; then

          until [ "$VALID_ENTRY_boot_size_check" == "true" ]; do 

            read -rp "The boot-partition will fill $BOOT_size. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " BOOT_size_check
  
            echo

            if [[ $BOOT_size_check == "YES" ]]; then

              echo "You'll get a new prompt"

              VALID_ENTRY_boot_size_check=true

              VALID_ENTRY_boot_size=false

              echo

            elif [[ $BOOT_size_check == "NO" ]]; then

              VALID_ENTRY_boot_size_check=true

              VALID_ENTRY_boot_size=true

              echo "The boot-partition is set to be $BOOT_size MiB"

              echo

            elif [[ $BOOT_size_check -ne "NO" ]] && [[ $BOOT_size_check -ne "YES" ]]; then 

              VALID_ENTRY_boot_size_check=false

              echo 

              echo "Invalid answer. Please try again"

              echo

            fi
  
          done

        fi
  
      done

      until [ "$VALID_ENTRY_boot_name" == "true" ]; do 

        read -rp "A special name for the boot-partition? " BOOT_label

        echo

        until [ "$VALID_ENTRY_boot_name_check" == "true" ]; do 

          read -rp "The boot-partition will be named $BOOT_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " BOOT_label_check

          echo

          if [[ $BOOT_label_check == "YES" ]]; then

            echo "You'll get a new prompt"

            VALID_ENTRY_boot_name_check=true

            VALID_ENTRY_boot_name=false

            echo

          elif [[ $BOOT_label_check == "NO" ]]; then

            VALID_ENTRY_boot_name_check=true

            VALID_ENTRY_boot_name=true

            echo "The boot-partition will be named $BOOT_label"

            echo

          elif [[ $BOOT_label_check -ne "NO" ]] && [[ $BOOT_label_check -ne "YES" ]]; then 

            VALID_ENTRY_boot_name_check=false

            echo 

            echo "Invalid answer. Please try again"
  
            echo

          fi
  
        done

      done

      echo

      until [ "$VALID_ENTRY_primary_name" == "true" ]; do 

        read -rp "A special name for the primary partition? " PRIMARY_label

        echo

        until [ "$VALID_ENTRY_primary_name_check" == "true" ]; do 

          read -rp "The primary partition will be named $PRIMARY_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " PRIMARY_label_check

          echo
  
          if [[ $PRIMARY_label_check == "YES" ]]; then

            echo "You'll get a new prompt"

            VALID_ENTRY_primary_name_check=true
 
            VALID_ENTRY_primary_name=false

            echo

          elif [[ $PRIMARY_label_check == "NO" ]]; then
  
            VALID_ENTRY_primary_name_check=true
 
            VALID_ENTRY_primary_name=true

            DRIVE_proceed=true

            echo "The primary partition will be named $PRIMARY_label"

            echo

          elif [[ $PRIMARY_label_check -ne "NO" ]] && [[ $PRIMARY_label_check -ne "YES" ]]; then 

            VALID_ENTRY_primary_name_check=false

            echo 

            echo "Invalid answer. Please try again"

            echo
  
          fi
  
        done

      done

    done

    echo

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

      until [ "$VALID_ENTRY_boot_size_format" == "true" ] && [ "$VALID_ENTRY_boot_size" == "true" ]; do 

        read -rp "Any favourite size for the boot-partition in MB? Though minimum 256MB; only type the size without units: " BOOT_size

        echo

        if ! [[ "$BOOT_size" =~ ^[0-9]+$ ]]; then

          echo "Sorry, only numbers please"

          echo

          BOOT_size=""
 
          VALID_ENTRY_boot_size_format=false

        elif ! [[ "$BOOT_size" -ge 256 ]]; then

          echo "Sorry, the boot-partition will not be large enough"

          echo

          BOOT_size=""
 
          VALID_ENTRY_boot_size_format=false

        else 

          VALID_ENTRY_boot_size_format=true

        fi
  
        echo

        if [ "$VALID_ENTRY_boot_size_format" == "true" ]; then

          until [ "$VALID_ENTRY_boot_size_check" == "true" ]; do 

            read -rp "The boot-partition will fill $BOOT_size. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " BOOT_size_check
  
            echo

            if [[ $BOOT_size_check == "YES" ]]; then

              echo "You'll get a new prompt"

              VALID_ENTRY_boot_size_check=true

              VALID_ENTRY_boot_size=false

              echo

            elif [[ $BOOT_size_check == "NO" ]]; then

              VALID_ENTRY_boot_size_check=true

              VALID_ENTRY_boot_size=true

              echo "The boot-partition is set to be $BOOT_size MiB"

              echo

            elif [[ $BOOT_size_check -ne "NO" ]] && [[ $BOOT_size_check -ne "YES" ]]; then 

              VALID_ENTRY_boot_size_check=false

              echo 

              echo "Invalid answer. Please try again"

              echo

            fi
  
          done

        fi
  
      done

      until [ "$VALID_ENTRY_boot_name" == "true" ]; do 

        read -rp "A special name for the boot-partition? " BOOT_label

        echo

        until [ "$VALID_ENTRY_boot_name_check" == "true" ]; do 

          read -rp "The boot-partition will be named $BOOT_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " BOOT_label_check

          echo

          if [[ $BOOT_label_check == "YES" ]]; then

            echo "You'll get a new prompt"

            VALID_ENTRY_boot_name_check=true

            VALID_ENTRY_boot_name=false

            echo

          elif [[ $BOOT_label_check == "NO" ]]; then

            VALID_ENTRY_boot_name_check=true

            VALID_ENTRY_boot_name=true

            echo "The boot-partition will be named $BOOT_label"

            echo

          elif [[ $BOOT_label_check -ne "NO" ]] && [[ $BOOT_label_check -ne "YES" ]]; then 

            VALID_ENTRY_boot_name_check=false

            echo 

            echo "Invalid answer. Please try again"
  
            echo

          fi
  
        done

      done

      echo

      until [ "$VALID_ENTRY_swap_size" == "true" ]; do 

        read -rp "Any favourite size for the SWAP-partition in MB? " SWAP_size

        echo

        until [ "$VALID_ENTRY_swap_size_check" == "true" ]; do 

          read -rp "The swap-partition will fill $SWAP_size. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " SWAP_size_check
  
          echo

          if [[ $SWAP_size_check == "YES" ]]; then

            echo "You'll get a new prompt"

            VALID_ENTRY_swap_size_check=true

            VALID_ENTRY_swap_size=false

            echo

          elif [[ $SWAP_size_check == "NO" ]]; then

            VALID_ENTRY_swap_size_check=true

            VALID_ENTRY_swap_size=true

            echo "The SWAP-partition is set to be $SWAP_size MiB"

            echo

          elif [[ $SWAP_size_check -ne "NO" ]] && [[ $SWAP_size_check -ne "YES" ]]; then 

            VALID_ENTRY_swap_size_check=false

            echo 

            echo "Invalid answer. Please try again"

            echo

          fi
  
        done
  
      done

      until [ "$VALID_ENTRY_swap_name" == "true" ]; do 

        read -rp "A special name for the SWAP-partition? " SWAP_label

        echo

        until [ "$VALID_ENTRY_swap_name_check" == "true" ]; do 

          read -rp "The boot-partition will be named $SWAP_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " SWAP_label_check

          echo

          if [[ $SWAP_label_check == "YES" ]]; then

            echo "You'll get a new prompt"

            VALID_ENTRY_swap_name_check=true

            VALID_ENTRY_swap_name=false

            echo

          elif [[ $SWAP_label_check == "NO" ]]; then

            VALID_ENTRY_swap_name_check=true

            VALID_ENTRY_swap_name=true

            echo "The SWAP-partition will be named $SWAP_label"

            echo

          elif [[ $SWAP_label_check -ne "NO" ]] && [[ $SWAP_label_check -ne "YES" ]]; then 

            VALID_ENTRY_swap_name_check=false

            echo 

            echo "Invalid answer. Please try again"
  
            echo

          fi
  
        done

      done
 
      echo

      until [ "$VALID_ENTRY_primary_name" == "true" ]; do 

        read -rp "A special name for the primary partition? " PRIMARY_label

        echo

        until [ "$VALID_ENTRY_primary_name_check" == "true" ]; do 

          read -rp "The primary partition will be named $PRIMARY_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " PRIMARY_label_check

          echo
  
          if [[ $PRIMARY_label_check == "YES" ]]; then

            echo "You'll get a new prompt"

            VALID_ENTRY_primary_name_check=true
 
            VALID_ENTRY_primary_name=false

            echo

          elif [[ $PRIMARY_label_check == "NO" ]]; then
  
            VALID_ENTRY_primary_name_check=true
 
            VALID_ENTRY_primary_name=true

            DRIVE_proceed=true

            echo "The primary partition will be named $PRIMARY_label"

            echo

          elif [[ $PRIMARY_label_check -ne "NO" ]] && [[ $PRIMARY_label_check -ne "YES" ]]; then 

            VALID_ENTRY_primary_name_check=false

            echo 

            echo "Invalid answer. Please try again"

            echo
  
          fi
  
        done

      done

    done

    echo

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

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# ROOT-encryption

  if [[ $ENCRYPTION_choice == 2 ]]; then

    more encryptions.txt

    echo

    echo "Please have your encryption-password ready "

    echo

    cryptsetup luksFormat --type luks1 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --use-random "$DRIVE_LABEL_primary"

    cryptsetup open /dev/DRIVE_LABEL_root cryptroot

    echo
    
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Drive-formatting

  more formatting.txt

  echo "A favourite filesystem for the root-drive? BTRFS of course!"

  mkfs.vfat -F32 "$DRIVE_LABEL_boot"

  mkswap -L "$SWAP_label" "$DRIVE_LABEL_swap"

  mkfs.btrfs -l "$PRIMARY_label" /dev/mapper/cryptroot

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

        echo
    
        more /mnt/etc/fstab

        echo

        until [ "$VALID_ENTRY_fstab_confirm_check" == "true" ]; do 

          read -rp "Does everything seems right? Type \"1\" for no, \"2\" for yes: " FSTAB_confirm

          if [[ $FSTAB_confirm == 1 ]]; then

            echo "Sorry, you have to execute the scipt again :("
      
            exit 1

          elif [[ $FSTAB_confirm == 2 ]]; then

            VALID_ENTRY_fstab_confirm_check=true

            FSTAB_proceed=true

          elif [[ $FSTAB_confirm -ne 1 ]] && [[ $FSTAB_check -ne 2 ]]; then 

            VALID_ENTRY_fstab_confirm_check=false

            echo 

            echo "Invalid answer. Please try again"

            echo

          fi
 
        done

      elif [[ $FSTAB_check -ne 1 ]] && [[ $FSTAB_check -ne 2 ]]; then 

        VALID_ENTRY_fstab_check=false

        echo 

        echo "Invalid answer. Please try again"

        echo
  
      fi
 
    done 

  done

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Chroot

  artix-chroot /mnt

  /bin/bash

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up time

VALID_ENTRY_time_check

  more time.txt

  echo

  until [ "$TIME_proceed" == "true" ]; do 

    echo "Do you know your local timezone?"

    echo "Example: Europe/Copenhagen"

    read -r TIMEZONE

    echo

    until [ "$VALID_ENTRY_time_check" == "true" ]; do 

      read -rp "You have chosen $TIMEZONE. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " TIME_check

      echo

      if [[ $TIME_check == "YES" ]]; then

        echo "You'll get a new prompt"

        TIMEZONE=""

        TIME_proceed=false

        VALID_ENTRY_time_check=true

        echo

      elif [[ $TIME_check == "NO" ]]; then
        
        TIME_proceed=true

        VALID_ENTRY_time_check=true

      elif [[ $TIME_check -ne "NO" ]] && [[ $TIME_check -ne "YES" ]]; then 

        VALID_ENTRY_time_check=false

        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
  
    done

  done

  echo

  ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
  hwclock --systoch

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals_languages

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

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up locals_keymap

  until [ "$KEYMAP_proceed" == "true" ]; do 

    echo "Any thoughts on the system-wide keymap?"

    echo "Example: dk-latin1"

    read -r KEYMAP

    echo

    until [ "$VALID_ENTRY_keymap_check" == "true" ]; do 

      read -rp "You have chosen $KEYMAP. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " KEYMAP_check

      echo

      if [[ $KEYMAP_check == "YES" ]]; then

        echo "You'll get a new prompt"

        TIMEZONE=""

        KEYMAP_proceed=false

        VALID_ENTRY_keymap_check=true

        echo

      elif [[ $KEYMAP_check == "NO" ]]; then
        
        KEYMAP_proceed=true

        VALID_ENTRY_keymap_check=true

      elif [[ $KEYMAP_check -ne "NO" ]] && [[ $KEYMAP_check -ne "YES" ]]; then 

        VALID_ENTRY_keymap_check=false

        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
  
    done

  done

  echo

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

  until [ "$BOOTLOADER_proceed" == "true" ]; do 

    read -rp "Any fitting name for the bootloader? " BOOTLOADER_label

    echo

    echo

    until [ "$VALID_ENTRY_bootloader_check" == "true" ]; do 

      read -rp "You have chosen $BOOTLOADER_label. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " BOOTLOADER_check

      echo

      if [[ $BOOTLOADER_check == "YES" ]]; then

        echo "You'll get a new prompt"

        BOOTLOADER_label=""

        BOOTLOADER_proceed=false

        VALID_ENTRY_bootloader_check=true

        echo

      elif [[ $BOOTLOADER_check == "NO" ]]; then
        
        BOOTLOADER_proceed=true

        VALID_ENTRY_bootloader_check=true

      elif [[ $BOOTLOADER_check -ne "NO" ]] && [[ $BOOTLOADER_check -ne "YES" ]]; then 

        VALID_ENTRY_bootloader_check=false

        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
  
    done

  done

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

  until [ "$ROOT_proceed" == "true" ]; do 

    echo "Any thoughts on a root-password"?

    read -r ROOT_passwd

    echo

    until [ "$VALID_ENTRY_root_check" == "true" ]; do 

      read -rp "You have chosen $ROOT_passwd. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " ROOT_check

      echo

      if [[ $ROOT_check == "YES" ]]; then

        echo "You'll get a new prompt"

        ROOT_passwd=""

        ROOT_proceed=false

        VALID_ENTRY_root_check=true

        echo

      elif [[ $ROOT_check == "NO" ]]; then
        
        ROOT_passwd=true

        VALID_ENTRY_root_check=true

      elif [[ $ROOT_check -ne "NO" ]] && [[ $ROOT_check -ne "YES" ]]; then 

        VALID_ENTRY_root_check=false

        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
  
    done

  done

  echo

  passwd
  $ROOT_passwd

  echo

  until [ "$USER_proceed" == "true" ]; do 

    echo "Can I suggest a username?"

    read -r USERNAME

    echo

    echo "A password too?"

    read -r USERNAME_passwd

    echo

    until [ "$VALID_ENTRY_user_check" == "true" ]; do 

      read -rp "You have chosen $USERNAME as username and $USERNAME_passwd as password. Do you want to change anyone of these? Type \"YES\" if yes, \"NO\" if no: " USER_check

      echo

      if [[ $USER_check == "YES" ]]; then

        echo "You'll get a new prompt"

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

        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
  
    done

  done

  useradd -m -G users -g video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,wheel "$USERNAME"

  passwd "$USERNAME"
  $USERNAME_passwd

  echo

#----------------------------------------------------------------------------------------------------------------------------------

# Setting up hostname

  more hostname.txt

  echo

  until [ "$LOCALS_proceed" == "true" ]; do 

    echo "Is there a name that you want to host?"

    read -r HOSTNAME

    echo

    until [ "$VALID_ENTRY_hostname_check" == "true" ]; do 

      read -rp "You have chosen $HOSTNAME. Do you want to change that? Type \"YES\" if yes, \"NO\" if no: " HOSTNAME_check

      echo

      if [[ $HOSTNAME_check == "YES" ]]; then

        echo "You'll get a new prompt"

        HOSTNAME=""

        LOCALS_proceed=false

        VALID_ENTRY_hostname_check=true

        echo

      elif [[ $HOSTNAME_check == "NO" ]]; then
        
        LOCALS_proceed=true

        VALID_ENTRY_hostname_check=true

      elif [[ $HOSTNAME_check -ne "NO" ]] && [[ $HOSTNAME_check -ne "YES" ]]; then 

        VALID_ENTRY_hostname_check=false

        echo 

        echo "Invalid answer. Please try again"

        echo

      fi
  
    done

  done

  echo

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
 
