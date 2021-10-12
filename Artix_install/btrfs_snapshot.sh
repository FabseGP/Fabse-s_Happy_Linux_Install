#!/bin/bash

# max_snap is the highest number of snapshots that will be kept; that is alone for root and home
  max_snap=$((3 - 1))

# time_stamp is the date of snapshots
  time_stamp=$(date +"%Y-%m-%d_%H:%M:%S")

# Clean up older snapshots
  for snapshots_total in $(ls /.snapshots/ | sort | grep backup | head -n -"$max_snap"); do
    btrfs subvolume delete /.snapshots/"$snapshots_total"
  done

# Create new snapshot + packages_list:
  btrfs subvolume snapshot / /.snapshots/backup-"$time_stamp" # root
  rm -r /.snapshots/backup-"$time_stamp"/home
  btrfs subvolume snapshot /home /.snapshots/backup-"$time_stamp"/home # home
  mkdir /.snapshots/backup-"$time_stamp"/packages_list
  pacman -Qqe > /.snapshots/backup-"$time_stamp"/packages_list/pkglist-"$time_stamp".txt

# Updates grub-menu
  cd /etc/grub.d
  ./41_snapshots-btrfs
  grub-mkconfig -o /boot/grub/grub.cfg
