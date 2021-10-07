#!/bin/bash

# max_snap is the highest number of snapshots that will be kept
  max_snap=$((3 - 1))

# time_stamp is the date of snapshots
  time_stamp=$(date +"%Y-%m-%d_%H:%M:%S")

# Clean up older snapshots:
  for snapshots_total in $(ls /.snapshots|sort |grep backup|head -n -"$max_snap"); do
    yay="btrfs subvolume delete /.snapshots/"$snapshots_total""
    "$yay" > /dev/null
  done

# Create new snapshot:
  yay="btrfs subvolume snapshot / /.snapshots/backup-"$time_stamp""
  "$yay" > /dev/null
  
