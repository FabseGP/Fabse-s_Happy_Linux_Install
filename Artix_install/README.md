# Artix Linux with runit as init

System-installation of Artix Linux, which can be customized during installation, or by editing the script; 
after customizing the install, then it should be as simple as flashing an ISO to an USB-drive and executing the script within the live Artix-system :)

By default the system will be set up with:
- A boot drive formatted as FAT32, a swap-partition and a BTRFS-partition, which will fill the whole drive;
the sizes of these partitions is adjusted when executing the script
- Optional LUKS-encryption and subvolumes for the BTRFS-partition
- A user with your preferred username and password, as well as a custom root-password
- A custom hostname, your preferred timezone, your preferred language and your preferred keyboard layout 
