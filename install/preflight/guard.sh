#!/bin/bash

abort() {
  echo -e "\e[31mOmarchy install requires: $1\e[0m"
  echo
  gum confirm "Proceed anyway on your own accord and without assistance?" || exit 1
}

# Check for supported distributions
case "$DISTRO" in
    arch)
        # Must be an Arch distro
        [[ -f /etc/arch-release ]] || abort "Vanilla Arch"
        
        # Must not be an Arch derivative distro
        for marker in /etc/cachyos-release /etc/eos-release /etc/garuda-release /etc/manjaro-release; do
            [[ -f "$marker" ]] && abort "Vanilla Arch"
        done
        
        # Must not have Gnome or KDE already installed
        pacman -Qe gnome-shell &>/dev/null && abort "Fresh + Vanilla Arch"
        pacman -Qe plasma-desktop &>/dev/null && abort "Fresh + Vanilla Arch"
        ;;
    debian)
        # Check for Debian-based system
        if ! grep -q "Debian\|Ubuntu" /etc/os-release; then
            abort "Debian/Ubuntu based system"
        fi
        
        # Must not have Gnome or KDE already installed
        dpkg -l | grep -q "^ii  gnome-shell " && abort "Fresh system without desktop environment"
        dpkg -l | grep -q "^ii  kde-standard " && abort "Fresh system without desktop environment"
        ;;
    *)
        abort "Supported Linux distribution (Arch/Debian/Ubuntu)"
        ;;
esac

# Must not be running as root (common check for all distros)
[ "$EUID" -eq 0 ] && abort "Running as user (not root)"

# Must be x86 only to fully work (common check for all distros)
[ "$(uname -m)" != "x86_64" ] && abort "x86_64 CPU"

# Cleared all guards
echo "Guards: OK"
