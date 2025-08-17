#!/bin/bash

# printer.sh - Printer configuration
# Compatible with both Arch and Debian systems

# Install printer packages based on distribution
case "$DISTRO" in
    arch)
        sudo pacman -S --noconfirm cups cups-pdf cups-filters cups-browsed system-config-printer avahi nss-mdns
        sudo systemctl enable --now cups.service

        # Disable multicast dns in resolved. Avahi will provide this for better network printer discovery
        sudo mkdir -p /etc/systemd/resolved.conf.d
        echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf
        sudo systemctl enable --now avahi-daemon.service

        # Enable automatically adding remote printers
        if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf; then
            echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf
        fi

        sudo systemctl enable --now cups-browsed.service
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Install printer packages for Debian
        PRINTER_PACKAGES=(
            "cups"
            "cups-pdf"
            "cups-filters"
            "cups-browsed"
            "system-config-printer"
            "avahi-daemon"
            "libnss-mdns"
        )
        
        # Install packages with error handling
        echo "Installing printer packages for Debian..."
        sudo apt install -y "${PRINTER_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some printer packages may have failed to install"
        
        # Check if systemd-resolved is available and active
        if systemctl is-active systemd-resolved &>/dev/null; then
            # Disable multicast dns in resolved. Avahi will provide this for better network printer discovery
            sudo mkdir -p /etc/systemd/resolved.conf.d 2>/dev/null || true
            echo -e "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf
            
            # Restart resolved service to apply changes
            sudo systemctl restart systemd-resolved.service 2>/dev/null || echo "Note: Failed to restart systemd-resolved"
        else
            echo "Note: systemd-resolved not active, skipping multicast DNS configuration"
        fi
        
        # Start and enable CUPS service
        if systemctl list-unit-files | grep -q cups.service; then
            sudo systemctl enable --now cups.service 2>/dev/null || echo "Warning: Failed to enable cups.service"
        else
            echo "Note: cups.service not found"
        fi
        
        # Start and enable Avahi daemon
        if systemctl list-unit-files | grep -q avahi-daemon.service; then
            sudo systemctl enable --now avahi-daemon.service 2>/dev/null || echo "Warning: Failed to enable avahi-daemon.service"
        else
            echo "Note: avahi-daemon.service not found"
        fi
        
        # Enable automatically adding remote printers
        if [ -f /etc/cups/cups-browsed.conf ]; then
            if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf; then
                echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf
            fi
        else
            echo "Note: cups-browsed.conf not found, creating basic configuration"
            sudo mkdir -p /etc/cups 2>/dev/null || true
            echo 'CreateRemotePrinters Yes' | sudo tee /etc/cups/cups-browsed.conf
        fi
        
        # Start and enable cups-browsed service
        if systemctl list-unit-files | grep -q cups-browsed.service; then
            sudo systemctl enable --now cups-browsed.service 2>/dev/null || echo "Warning: Failed to enable cups-browsed.service"
        else
            echo "Note: cups-browsed.service not found"
        fi
        
        # Additional Debian-specific printer setup
        # Add user to lpadmin group if it exists
        if getent group lpadmin > /dev/null 2>&1; then
            sudo usermod -aG lpadmin ${USER} 2>/dev/null || echo "Note: Failed to add user to lpadmin group"
        fi
        
        # Check if usermod command is available
        if ! command -v usermod &>/dev/null; then
            echo "Note: usermod not available, skipping group membership configuration"
        fi
        ;;
    *)
        echo "Unsupported distribution for printer configuration"
        exit 1
        ;;
esac

# Verify printer services
echo "Printer configuration completed"
SERVICES_TO_CHECK=("cups" "avahi-daemon" "cups-browsed")
for service in "${SERVICES_TO_CHECK[@]}"; do
    if systemctl is-active "${service}.service" &>/dev/null; then
        echo "${service}.service is running"
    else
        echo "${service}.service is not running or not available"
    fi
done
