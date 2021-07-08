# Alpine Raspberry PI

System-installation of Artix Linux, which can be customized by editing the script; 
after customizing the install, then it should be as simple as flashing an ISO to an USB-drive and executing the script within the live Artix-system :)

By default the system will be set up with
- A 321M boot drive formatted as FAT32, 8GB swap-partition and a BTRFS-partition, which will fill the whole drive
- LUKS-encryption and subvolumes for the BTRFS-partition
- An user with following credentials: "runit" as username and "Alpine12345" as password
- "localhost" as hostname, UTC as timezone and "dk" as keyboard layout
