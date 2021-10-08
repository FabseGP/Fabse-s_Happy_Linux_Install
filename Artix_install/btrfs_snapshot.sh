#!/bin/bash

# max_snap is the highest number of snapshots that will be kept; that is alone for root and home
  max_snap=$((3 - 1))

# time_stamp is the date of snapshots
  time_stamp=$(date +"%Y-%m-%d_%H:%M:%S")

# Clean up older snapshots; first root and home, then finally packages_list
  for snapshots_total in $(ls /.snapshots/root | sort | grep backup | head -n -"$max_snap"); do
    btrfs subvolume delete /.snapshots/root/"$snapshots_total"
  done
  for snapshots_total in $(ls /.snapshots/home | sort | grep backup | head -n -"$max_snap"); do
    btrfs subvolume delete /.snapshots/home/"$snapshots_total"
  done
  cd /.snapshots/packages_list || exit
  packages_list_total=$(find . -type f -printf '%T+ %p\n' | sort | awk -F ' ' '{print $2}'  | cut -c 3- | wc -l)
  packages_list_oldest=$(find . -type f -printf '%T+ %p\n' | sort | awk -F ' ' '{print $2}'  | cut -c 3- | head -n 1)
  if [ "$packages_list_total" -gt $max_snap ] ; then
    rm "$packages_list_oldest"
  fi

# Create new snapshot + packages_list:
  btrfs subvolume snapshot / /.snapshots/root/backup-"$time_stamp" # root
  btrfs subvolume snapshot /home /.snapshots/home/backup-"$time_stamp" # home
  pacman -Qqe > /.snapshots/packages_list/pkglist-"$time_stamp".txt
