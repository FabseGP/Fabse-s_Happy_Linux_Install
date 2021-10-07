#!/bin/bash

  NOW=$(date +"%Y-%m-%d_%H:%M:%S")
  if [ ! -e /mnt/backup ]; then
    mkdir -p /mnt/backup
  fi
  cd /
  /bin/btrfs subvolume snapshot / "/mnt/backup/backup_${NOW}"
