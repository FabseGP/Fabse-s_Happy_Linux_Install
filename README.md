<p align="center">
  <img src="https://media.giphy.com/media/2jMtpIi8mhE8ctiMtK/giphy.gif">
</p>
<hr>
<Br>
<h1>About this repo! 😎</h1>

- A interactive script to install Artix Linux with either OpenRC or Runit
- Without modification, the following choices are always constant:
  * Filesystem = btrfs with BTRFS-snapshots taken each day at 13:00 local time
  * Repositories = galaxy (stable) + gremlins (testing) + multilib + arch
  * NetworkManager + fcron + chrony + dhcpcd at boot
  * IF CHOSEN: paru as AUR-helper, though with alias yay=paru

In order to clone the repository, these commands must be used beforehand
  - loadkeys YOUR_KEYMAP
  - (If using ethernet, just skip these 'sub-commands' under this line)
    - rfkill unblock wifi
    - connmanctl
    - enable wifi
    - scan wifi
    - services
    - agent on
    - connect YOUR_WIFI_ID # Remember that connmanctl has tab-completion regarding the WiFi-ID's; I didn't knew that for a lomg time :(
    - exit
  - pacman -Syy --noconfirm git && git clone https://github.com/FabseGP/Fabse-s_Happy_Linux_Install.git
  - cd Fabse-s_Happy_Linux_Install/Artix_install
  - chmod u+x artix_runit_*
  - ./artix_runit_pre_chroot.sh

  And off you go! 
    

<Br>
<hr>
<Br>
<h1>A Little Joke at the End! 🤣</h1>
<Br>

<p align="center">
  <img src="https://media.giphy.com/media/zqTOkUhWIGC3DaFo4j/giphy.gif"/>
