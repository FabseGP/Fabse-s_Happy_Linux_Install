# Alpine Raspberry PI

System-installation of Artix Linux, which can be customized by editing the script; 
after customizing the install, then it should be as simple as flashing an ISO to an USB-drive and executing the script within the live Artix-system :)

By default the system will be set up with
- A boot drive formatted as FAT32, a swap-partition and a BTRFS-partition, which will fill the whole drive;
the sizes of these partitions must be set beforehand with cfdisk, where the first partition is the boot-, 
the second is the swap- and the last is the BTRFS-partition
- LUKS-encryption and subvolumes for the BTRFS-partition
- An user with following credentials: "runit" as username and "Alpine12345" as password; the root user has the password "root1234"
- "localhost" as hostname, "Europe/Copenhagen" as timezone, "da_DK.UTF-8" as language and "dk-winkeys" as keyboard layout
