# Artix Linux with runit as init

System-installation of Artix Linux, which can be customized by editing the script; 
after customizing the install, then it should be as simple as flashing an ISO to an USB-drive and executing the script within the live Artix-system :)

By default the system will be set up with
- A boot drive formatted as FAT32, a swap-partition and a BTRFS-partition, which will fill the whole drive;
the sizes of these partitions is respectively 325M, 8GB and the rest of the drive
- LUKS-encryption and subvolumes for the BTRFS-partition
- An user with following credentials: "runit" as username and "Alpine12345" as password; the root user has the password "root1234"
- "alpine_host" as hostname, "Europe/Copenhagen" as timezone, "da_DK.UTF-8" as language and "dk-winkeys" as keyboard layout
