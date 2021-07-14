#!/usr/bin/bash

# Parameters

  STM32_ready=""
  Science_ready=""
  Brave_ready=""
  Spotify_ready=""
  Firefox_ready=""

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation

  sudo cp /home/fabse/Konfiguration/Scripts/Installation/Config/pacman.conf /etc/pacman.conf

  sudo pacman -S terminator git-lfs nautilus kdialog spellcheck i3status-rust fzf btrfs-progs git curl wget gammastep tlp-runit foliate neovim zsh zsh-autosuggestions zsh-syntax-highlighting bashtop spectacle zathura zathura-pdf-poppler pipewire pipewire-alsa pipewire-pulse pulseeffects pavucontrol sway swaylock arduino arduino-avr-core openshot mousepad wine wine-mono wine-gecko kicad-library kicad-library-3d links gnome-sudoku gnome-mahjongg gnome-calculator cups-runit dolphin dolphin-plugins qutebrowser geogebra kalzium step neofetch gthumb unrar unzip bc lz4 texlive-most atom libreoffice-fresh ark sddm-runit nodejs rclone syncthing-runit discord wayland gimp plasma ffmpegthumbs kdegraphics-thumbnailers linux-firmware alsa-utils networkmanager-runit alacritty stlink rsync asp lutris qemu virt-manager libvirt libvirt-python virt-install xdg-desktop-portal-kde xdg-desktop-portal-wlr pipewire-media-session gnuplot python3 realtime-privileges libva-intel-driver brightnessctl wl-clipboard ld-lsb lsd imv freecad artools iso-profiles aisleriot bsd-games vlc ufw brave obs-studio firefox kicad libpipewire02 polkit-gnome waybar moc artix-archlinux-support fcron-runit steam mypaint slurp grim android-tools qemu-user-static figlet

#----------------------------------------------------------------------------------------------------------------------------------

# yay-installation

  cd /opt || return
  sudo git clone https://aur.archlinux.org/yay-git.git
  sudo chown -R fabse:wheel ./yay-git
  cd yay-git || return
  makepkg -si

  cd /home/fabse || return

  sudo cp /home/fabse/Konfiguration/Scripts/Installation/Config/makepkg.conf /etc/makepkg.conf

#----------------------------------------------------------------------------------------------------------------------------------

# Files for stm32x

  xdg-open https://www.st.com/en/development-tools/stm32cubeprog.html
  xdg-open https://www.st.com/en/development-tools/stm32cubeide.html
  xdg-open https://www.st.com/en/development-tools/stm32cubemx.html

  read -rp "Are you ready again? Type anything for yes: " STM32_ready

#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR

  yay -S spicetify-cli spotify stm32cubemx stm32flash bastet cbonsai stm32cubeprog stm32cubeide openrgb osp-tracker balena-etcher bitwarden-bin onlyoffice-bin standardnotes-bin toilet

#----------------------------------------------------------------------------------------------------------------------------------

# ZSH-theme + fonts

  sudo chsh -s /usr/bin/zsh fabse
  sudo chsh -s /usr/bin/zsh root

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

  wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  mv 'MesloLGS NF Regular.ttf' MesloLGS.ttf
  wget https://www.opensans.com/download/open-sans.zip
  unzip open-sans.zip

  mkdir ~/.local/share/fonts
  mv OpenSans-Regular.ttf ~/.local/share/fonts/OpenSans.ttf
  mv MesloLGS.ttf ~/.local/share/fonts/MesloLGS.ttf

  fc-cache -f -v

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  git clone https://github.com/vinceliuice/grub2-themes.git
  cd grub2-themes || return

  sudo ./install.sh -b -t tela
  cd /home/fabse || return

#----------------------------------------------------------------------------------------------------------------------------------

# Reveal.js + chart.js + slides.js

  npm install browserify

  git clone https://github.com/hakimel/reveal.js.git
  cd reveal.js && npm install

  cd /home/fabse || return

  npm install --save slides-js
  npm install chart.js

#----------------------------------------------------------------------------------------------------------------------------------

# Maple + chemsketch

  xdg-open https://www.acdlabs.com/resources/freeware/chemsketch/download.php
  xdg-open https://portfolio.otg.dk/otgnet/adm/restr/portfolio_v2/swdl.asp?sw=\Linux\Maple\Maple2020\Software\Maple2020.0LinuxX64Installer.run
  xdg-open https://portfolio.otg.dk/otgnet/adm/restr/portfolio_v2/swdl.asp?sw=\Linux\Maple\Maple2020\Gympakken\Maple2020LinuxX64GYMUpgrade.run
  xdg-open https://portfolio.otg.dk/otgnet/adm/restr/portfolio_v2/swdl.asp?sw=\Linux\Maple\Maple2020\Software\Kode2020.txt

  read -rp "Are you ready again? Type anything for yes: " Science_ready

  chmod u+x Hentet/*
  ./Hentet/Maple2020.0LinuxX64Installer.run
  ./Hentet/Maple2020LinuxX64GYMUpgrade.run

  unzip /home/fabse/Hentet/ACDLabs202021_ChemSketchFree_Install.zip
  wine /home/fabse/Hentet/ACDLabs202021_ChemSketchFree_Install/setup.exe

#----------------------------------------------------------------------------------------------------------------------------------

# Pulseeffects-presets + pipewire-config
  
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"

  sudo cp /home/fabse/Konfiguration/Scripts/Installation/Config/pipewire.conf /etc/pipewire.conf

#----------------------------------------------------------------------------------------------------------------------------------

# Brave-theme

  xdg-open https://www.deviantart.com/sublime9-design/art/Nord-Theme-for-Chrome-V2-837463227

  read -rp "Are you ready again? Type anything for yes: " Brave_ready

#----------------------------------------------------------------------------------------------------------------------------------

# Firefox-theme

  firefox about:support &

  read -rp "Is the path copied? Then type the full path here: " Firefox_ready

  cp -r /home/fabse/Konfiguration/Scripts/Installation/Config "$Firefox_ready"
  cp -r /home/fabse/Konfiguration/Scripts/Installation/user.js "$Firefox_ready"

#----------------------------------------------------------------------------------------------------------------------------------

# Spicetify

  spotify

  read -rp "Are you ready again? Type anything for yes: " Spotify_ready

  sudo chmod a+wr /opt/spotify
  sudo chmod a+wr /opt/spotify/Apps -R

  git clone https://github.com/morpheusthewhite/spicetify-themes.git
  cd spicetify-themes || return
  cp -r -- * ~/.config/spicetify/Themes

  cd "$(dirname "$(spicetify -c)")/Themes/DribbblishDynamic" || return
  mkdir -p ../../Extensions
  cp dribbblish-dynamic.js ../../Extensions/.
  spicetify config extensions dribbblish-dynamic.js
  spicetify config current_theme DribbblishDynamic color_scheme dark
  spicetify config inject_css 1 replace_colors 1 overwrite_assets 1
  spicetify apply

  cd /home/fabse || return

#----------------------------------------------------------------------------------------------------------------------------------

# User groups + Runit

  sudo usermod -a -G video,audio,input,power,storage,optical,lp,scanner,dbus,daemon,disk,uucp,vboxusers,realtime,wheel fabse 

  sudo ln -s /etc/runit/sv/cupsd /run/runit/service/ 
  sudo ln -s /etc/runit/sv/syncthing /run/runit/service/
  sudo ln -s /etc/runit/sv/fcron /run/runit/service/
  sudo ln -s /etc/runit/sv/tlp /run/runit/service/                                                                                                                                                   
  sudo ln -s /etc/runit/sv/ufw /run/runit/service/

#----------------------------------------------------------------------------------------------------------------------------------

# Sway-config

  cd /home/fabse || return

  cp -r /home/fabse/Konfiguration/Scripts/Installation/Config/i3status-rust .config
  cp -r /home/fabse/Konfiguration/Scripts/Installation/Config/sway .config

#----------------------------------------------------------------------------------------------------------------------------------

# KDE-config

  xdg-open https://store.kde.org/p/1298955/
