#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

export PATH="$HOME/.local/share/omarchy/bin:$PATH"
OMARCHY_INSTALL=~/.local/share/omarchy/install

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            arch)
                DISTRO="arch"
                ;;
            debian|ubuntu)
                DISTRO="debian"
                ;;
            *)
                echo "Unsupported distribution: $ID"
                exit 1
                ;;
        esac
    else
        echo "Cannot detect distribution"
        exit 1
    fi
}

# Package manager abstraction
install_package() {
    case "$DISTRO" in
        arch)
            sudo pacman -S --noconfirm --needed "$@"
            ;;
        debian)
            sudo apt update && sudo apt install -y "$@"
            ;;
    esac
}

update_system() {
    case "$DISTRO" in
        arch)
            yay -Syu --noconfirm --ignore uwsm
            ;;
        debian)
            sudo apt update && sudo apt upgrade -y
            ;;
    esac
}

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mOmarchy installation failed!\e[0m"
  echo "You can retry by running: bash ~/.local/share/omarchy/install.sh"
  echo "Get help from the community: https://discord.gg/tXFUdasqhY"
}

trap catch_errors ERR

show_logo() {
  clear
  # tte -i ~/.local/share/omarchy/logo.txt --frame-rate ${2:-120} ${1:-expand}
  cat <~/.local/share/omarchy/logo.txt
  echo
}

show_subtext() {
  echo "$1" # | tte --frame-rate ${3:-640} ${2:-wipe}
  echo
}

# Detect the distribution
detect_distro

# Install prerequisites
source $OMARCHY_INSTALL/preflight/guard.sh
case "$DISTRO" in
    arch)
        source $OMARCHY_INSTALL/preflight/aur.sh
        ;;
    debian)
        source $OMARCHY_INSTALL/preflight/apt.sh
        ;;
esac
source $OMARCHY_INSTALL/preflight/presentation.sh
source $OMARCHY_INSTALL/preflight/migrations.sh

# Configuration
show_logo beams 240
show_subtext "Let's install Omarchy! [1/5]"
source $OMARCHY_INSTALL/config/identification.sh
source $OMARCHY_INSTALL/config/config.sh
source $OMARCHY_INSTALL/config/detect-keyboard-layout.sh
source $OMARCHY_INSTALL/config/fix-fkeys.sh
source $OMARCHY_INSTALL/config/network.sh
source $OMARCHY_INSTALL/config/power.sh
source $OMARCHY_INSTALL/config/timezones.sh
source $OMARCHY_INSTALL/config/login.sh
source $OMARCHY_INSTALL/config/nvidia.sh

# Development
show_logo decrypt 920
show_subtext "Installing terminal tools [2/5]"
source $OMARCHY_INSTALL/development/terminal.sh
source $OMARCHY_INSTALL/development/development.sh
source $OMARCHY_INSTALL/development/nvim.sh
source $OMARCHY_INSTALL/development/ruby.sh
source $OMARCHY_INSTALL/development/docker.sh
source $OMARCHY_INSTALL/development/firewall.sh

# Desktop
show_logo slice 60
show_subtext "Installing desktop tools [3/5]"
source $OMARCHY_INSTALL/desktop/desktop.sh
source $OMARCHY_INSTALL/desktop/hyprlandia.sh
source $OMARCHY_INSTALL/desktop/theme.sh
source $OMARCHY_INSTALL/desktop/bluetooth.sh
source $OMARCHY_INSTALL/desktop/asdcontrol.sh
source $OMARCHY_INSTALL/desktop/fonts.sh
source $OMARCHY_INSTALL/desktop/printer.sh

# Apps
show_logo expand
show_subtext "Installing default applications [4/5]"
source $OMARCHY_INSTALL/apps/webapps.sh
source $OMARCHY_INSTALL/apps/xtras.sh
source $OMARCHY_INSTALL/apps/mimetypes.sh

# Updates
show_logo highlight
show_subtext "Updating system packages [5/5]"
sudo updatedb
update_system

# Reboot
show_logo laseretch 920
show_subtext "You're done! So we'll be rebooting now..."
sleep 2
reboot
