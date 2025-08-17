#!/bin/bash

# network.sh - Network configuration setup
# Compatible with both Arch and Debian systems

# Handle wireless networking tools based on distribution
case "$DISTRO" in
    arch)
        # Install iwd explicitly if it wasn't included in archinstall
        # This can happen if archinstall used ethernet
        if ! command -v iwctl &>/dev/null; then
            yay -S --noconfirm --needed iwd
            sudo systemctl enable --now iwd.service
        else
            # Ensure iwd service is enabled and running
            if systemctl is-enabled iwd.service &>/dev/null; then
                sudo systemctl enable --now iwd.service 2>/dev/null || true
            fi
        fi
        ;;
    debian)
        # Check if wireless tools are needed and install appropriate packages
        if command -v lspci &>/dev/null; then
            if lspci | grep -i wireless &>/dev/null; then
                # Install network-manager for Debian wireless support
                if ! command -v nmcli &>/dev/null; then
                    echo "Installing NetworkManager for wireless support on Debian..."
                    sudo apt update && sudo apt install -y network-manager
                    sudo systemctl enable --now NetworkManager.service
                else
                    # Ensure NetworkManager is enabled and running
                    if ! systemctl is-active NetworkManager.service &>/dev/null; then
                        sudo systemctl enable --now NetworkManager.service 2>/dev/null || true
                    fi
                fi
            fi
        fi
        ;;
    *)
        echo "Unsupported distribution for network configuration"
        ;;
esac

# Prevent systemd-networkd-wait-online timeout on boot
# Check if systemd-networkd-wait-online service exists
if systemctl list-unit-files | grep -q systemd-networkd-wait-online.service; then
    sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true
    sudo systemctl mask systemd-networkd-wait-online.service 2>/dev/null || true
    echo "Disabled systemd-networkd-wait-online service to prevent boot timeouts"
else
    echo "systemd-networkd-wait-online service not found, skipping disable"
fi

# Additional Debian-specific network optimizations
if [ "$DISTRO" = "debian" ]; then
    # Check if NetworkManager configuration directory exists
    if [ -d /etc/NetworkManager/conf.d/ ]; then
        # Create configuration to manage WiFi powersave
        sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf >/dev/null <<EOF
[connection]
wifi.powersave = 2
EOF
        echo "Configured WiFi power management for Debian"
    fi
fi

echo "Network configuration completed"
