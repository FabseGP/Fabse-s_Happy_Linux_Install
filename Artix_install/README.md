# Artix Linux with runit as init

System-installation of Artix Linux, which can be customized during installation, or by editing the script; 
after customizing the install, then it should be as simple as flashing an ISO to an USB-drive and executing the script within the live Artix-system :)

By default the following can be customized during install:
  - Utilising a SWAP-partition or not; if yes, it wille be encrypted using cryptsetup
  - Choice of configuring LUKS2-encryption; at the moment of writing, GRUB2 has *limited* support for LUKS2, which results with interacting with grub-shell. Though that is only regarding these two commands:
    - "cryptomount -a" to unlock the encrypted partition, since /boot is also encrypted; usually "cryptomount -u UUID", but there's no drawback of using -a, since it's (hopefully) is your only encrypted partition
    - "normal" to boot into the system; by default a keyfile will also be added to the partition to skip unlocking the partition twice
  - Anything that's related to the user: Keymap, languages to be generated, users + passwords, packages to install before rebooting etc.
