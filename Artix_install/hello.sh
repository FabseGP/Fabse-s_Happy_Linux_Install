#!/usr/bin/bash

# Parameters

  identity=""
  identity_command=""

#----------------------------------------------------------------------------------------------------------------------------------

# Doas or sudo

  read -rp "Are you, sir, using either "doas" or "sudo"? " identity
  if [ "$identity" == doas ]; then
    identity_command="doas -u fabse"
  elif [ "$identity" == sudo ]; then
    identity_command="sudo --user=fabse"
  fi

#----------------------------------------------------------------------------------------------------------------------------------

# Package-installation

  pacman -Syu cups-runit syncthing-runit nftables-runit libvirt-runit lm_sensors-runit chrony-runit cpupower-runit intel-undervolt-runit tlp-runit thermald-runit avahi-runit

#----------------------------------------------------------------------------------------------------------------------------------

# Runit + intel-undervolt + hostname resolution + snapper + libvirt + tty login prompt + firecfg

  ln -s /etc/runit/sv/cupsd /run/runit/service/ 
  ln -s /etc/runit/sv/syncthing /run/runit/service/
  ln -s /etc/runit/sv/nftables /run/runit/service/
  ln -s /etc/runit/sv/libvirtd /run/runit/service/
  ln -s /etc/runit/sv/lm_sensors /run/runit/service/
  ln -s /etc/runit/sv/chrony /run/runit/service/
  ln -s /etc/runit/sv/cpupower /run/runit/service/
  ln -s /etc/runit/sv/intel-undervolt /run/runit/service/
  ln -s /etc/runit/sv/tlp /run/runit/service/
  ln -s /etc/runit/sv/thermald /run/runit/service
  ln -s /etc/runit/sv/avahi-daemon /run/runit/service
  sensors-detect
  sv start intel-undervolt
  sv start avahi-daemon
  mv /home/fabse/Setup_and_configs/Laptop_ARTIX/intel-undervolt.conf /etc/intel-undervolt.conf
  intel-undervolt apply
  sed -i 's/hosts: files resolve [!UNAVAIL=return] dns/hosts: files mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns/' /etc/nsswitch.conf
  usermod -a -G libvirt fabse
  cat << EOF | tee -a /etc/issue > /dev/null

This object that you sir are using is property of Fabse Inc. - expect therefore puns! 

EOF

#----------------------------------------------------------------------------------------------------------------------------------

# yay-installation

  mv /home/fabse/Setup_and_configs/Laptop_ARTIX/makepkg.conf /etc/makepkg.conf

#----------------------------------------------------------------------------------------------------------------------------------

# Files for stm32x

  "$identity_command" xdg-open https://www.st.com/en/development-tools/stm32cubeide.html
  "$identity_command" xdg-open https://www.st.com/en/development-tools/stm32cubemx.html
  read -rp "Are you ready again? Type anything for yes: " STM32_ready

#----------------------------------------------------------------------------------------------------------------------------------

# Installation of packages from AUR; cnrdrvcups-lb only because of Brother-printer

  yay -S bastet cbonsai nerd-fonts-git clipman macchina 

#----------------------------------------------------------------------------------------------------------------------------------

# ZSH-theme + fonts + ZSH-config (wayland-related)

  chsh -s /usr/bin/zsh fabse
  chsh -s /usr/bin/zsh root
  "$identity_command" touch /home/fabse/.zshenv
  "$identity_command" touch /home/fabse/.zshrc
  "$identity_command" touch /home/fabse/.zhistory
  cat << EOF | "$identity_command" tee -a /home/fabse/.zshenv > /dev/null

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:/usr/local/bin"
fi

export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland

export _JAVA_AWT_WM_NONREPARENTING=1

export EDITOR="nvim"
export VISUAL="nvim"

export XDG_SESSION_TYPE=wayland
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

export HISTFILE="home/fabse/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

EOF
  cat << EOF | "$identity_command" tee -a /home/fabse/.zshrc > /dev/null

autoload -U compinit; compinit
zstyle ':completion::complete:*' gain-privileges 1

exit_zsh() { exit }
zle -N exit_zsh
bindkey '^D' exit_zsh

_comp_options+=(globdots) # With hidden files

cbonsai -p

bindkey -v
export KEYTIMEOUT=1

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

alias fabse=macchina
alias rm='rm -i'

EOF
  "$identity_command" mkdir ~/.local/share/fonts

#----------------------------------------------------------------------------------------------------------------------------------

# Grub-theme

  "$identity_command" git clone https://github.com/vinceliuice/grub2-themes.git
  "$identity_command" cd grub2-themes || return
  ./install.sh -b -t tela
  "$identity_command" cd /home/fabse || return

#----------------------------------------------------------------------------------------------------------------------------------

# Reveal.js + chart.js + slides.js

#  "$identity_command" npm install browserify
#  "$identity_command" git clone https://github.com/hakimel/reveal.js.git
#  "$identity_command" cd reveal.js && npm install
#  "$identity_command" cd /home/fabse || return
#  "$identity_command" npm install chart.js

#----------------------------------------------------------------------------------------------------------------------------------

# Maple + chemsketch

#  "$identity_command" xdg-open https://www.acdlabs.com/resources/freeware/chemsketch/download.php
#  read -rp "Are you ready again? Type anything for yes: " Science_ready
#  "$identity_command" unzip /home/fabse/Hentet/ACDLabs202021_ChemSketchFree_Install.zip
#  "$identity_command" wine /home/fabse/Hentet/ACDLabs202021_ChemSketchFree_Install/setup.exe

#----------------------------------------------------------------------------------------------------------------------------------

# Pulseeffects-presets + pipewire-config
  
  cp /home/fabse/Setup_and_configs/Laptop_ARTIX/pipewire.conf /etc/pipewire.conf

# Sway-related

  "$identity_command" cd /home/fabse || return
  "$identity_command" mkdir -p .config/{sway,swappy,mako,i3status-rust,alacritty,macchina/ascii}
  "$identity_command" mkdir -p .local/share/macchina/themes
  "$identity_command" mkdir /home/fabse/Scripts
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/config_sway .config/sway/config
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/config_swappy .config/swappy/config
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/config_mako .config/mako/config
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/config.toml .config/i3status-rust/config.toml
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/macchina.toml .config/macchina/macchina.toml
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/Fabse.json .local/share/macchina/themes/Fabse.json
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/fabse.ascii .config/macchina/ascii/fabse.ascii
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/alacritty.yml .config/alacritty/alacritty.yml
  "$identity_command" git clone https://github.com/hexive/sunpaper.git
  "$identity_command" rm -rf !(images) /home/fabse/sunpaper/*
  "$identity_command" mv -r /home/fabse/Setup_and_configs/Laptop_ARTIX/sway/sunpaper.sh /home/fabse/Scripts
  "$identity_command" chmod u+x /home/fabse/Scripts/*
  "$identity_command" rm -rf /home/fabse/Setup_and_configs
  
