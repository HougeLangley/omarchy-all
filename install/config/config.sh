#!/bin/bash

# config.sh - Configuration setup for Omarchy
# Compatible with both Arch and Debian systems

# Ensure ~/.config directory exists before copying configs
mkdir -p ~/.config

# Copy over Omarchy configs
cp -R ~/.local/share/omarchy/config/* ~/.config/

# Use default bashrc from Omarchy
cp ~/.local/share/omarchy/default/bashrc ~/.bashrc

# Ensure application directory exists for update-desktop-database
mkdir -p ~/.local/share/applications

# If bare install, allow a way for its exclusions to not get added in updates
if [ -n "$OMARCHY_BARE" ]; then
  mkdir -p ~/.local/state/omarchy
  touch ~/.local/state/omarchy/bare.mode
fi

# Setup GPG configuration with multiple keyservers for better reliability
# Check if gnupg directory exists, create if not
if [ "$DISTRO" = "debian" ]; then
    sudo mkdir -p /etc/gnupg
else
    sudo mkdir -p /etc/gnupg
fi

# Only copy dirmngr.conf if it exists in Omarchy defaults
if [ -f ~/.local/share/omarchy/default/gpg/dirmngr.conf ]; then
    sudo cp ~/.local/share/omarchy/default/gpg/dirmngr.conf /etc/gnupg/
    sudo chmod 644 /etc/gnupg/dirmngr.conf
    # Restart dirmngr service if running
    if command -v gpgconf &> /dev/null; then
        sudo gpgconf --kill dirmngr 2>/dev/null || true
        sudo gpgconf --launch dirmngr 2>/dev/null || true
    fi
fi

# Increase lockout limit to 10 and decrease timeout to 2 minutes
# Check if PAM configuration files exist
if [ -f "/etc/pam.d/system-auth" ]; then
    sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
    sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
elif [ -f "/etc/pam.d/common-auth" ] && [ "$DISTRO" = "debian" ]; then
    # Debian uses different PAM configuration structure
    echo "Note: PAM configuration may need manual adjustment on Debian systems"
fi

# Set Cloudflare as primary DNS (with Google as backup)
# Check if systemd-resolved is available
if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    if [ -f ~/.local/share/omarchy/default/systemd/resolved.conf ]; then
        sudo cp ~/.local/share/omarchy/default/systemd/resolved.conf /etc/systemd/
    fi
else
    echo "Note: systemd-resolved not active, DNS configuration skipped"
fi

# Solve common flakiness with SSH
# Check if sysctl.d directory exists
if [ -d /etc/sysctl.d ]; then
    echo "net.ipv4.tcp_mtu_probing=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf >/dev/null
else
    echo "Note: /etc/sysctl.d directory not found, SSH optimization skipped"
fi

# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch master

# Set identification from install inputs
if [[ -n "${OMARCHY_USER_NAME//[[:space:]]/}" ]]; then
  git config --global user.name "$OMARCHY_USER_NAME"
fi

if [[ -n "${OMARCHY_USER_EMAIL//[[:space:]]/}" ]]; then
  git config --global user.email "$OMARCHY_USER_EMAIL"
fi

# Set default XCompose that is triggered with CapsLock
# Check if .XCompose file can be created
if [ -w "$HOME" ]; then
    tee ~/.XCompose >/dev/null <<EOF
include "%H/.local/share/omarchy/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$OMARCHY_USER_NAME"
<Multi_key> <space> <e> : "$OMARCHY_USER_EMAIL"
EOF
else
    echo "Warning: Cannot create ~/.XCompose file, check permissions"
fi

echo "Configuration setup completed"
