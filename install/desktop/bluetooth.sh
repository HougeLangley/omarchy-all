#!/bin/bash

# bluetooth.sh - Bluetooth configuration
# Compatible with both Arch and Debian systems

# Install bluetooth controls based on distribution
case "$DISTRO" in
    arch)
        # Install bluetooth controls
        yay -S --noconfirm --needed blueberry

        # Turn on bluetooth by default
        sudo systemctl enable --now bluetooth.service
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Check if blueberry is available in Debian repositories
        if apt list blueberry 2>/dev/null | grep -q "blueberry"; then
            sudo apt install -y blueberry
        else
            echo "blueberry not available in repositories, installing alternative Bluetooth tools..."
            # Install alternative Bluetooth management tools
            sudo apt install -y blueman 2>/dev/null || echo "Warning: Blueman installation failed"
        fi

        # Install core Bluetooth packages
        sudo apt install -y bluez bluez-tools 2>/dev/null || echo "Warning: Core Bluetooth packages installation failed"

        # Check if Bluetooth service is available
        if systemctl list-unit-files | grep -q bluetooth.service; then
            # Turn on bluetooth by default
            sudo systemctl enable --now bluetooth.service 2>/dev/null || echo "Warning: Failed to enable Bluetooth service"
            
            # Check if service started successfully
            if systemctl is-active bluetooth.service &>/dev/null; then
                echo "Bluetooth service enabled and started successfully"
            else
                echo "Bluetooth service enabled but may not be running"
            fi
        else
            echo "Bluetooth service not found, Bluetooth may not be supported on this system"
        fi

        # Additional Debian-specific Bluetooth setup
        # Add user to bluetooth group if it exists
        if getent group bluetooth > /dev/null 2>&1; then
            sudo usermod -aG bluetooth ${USER} 2>/dev/null || echo "Note: Failed to add user to bluetooth group"
        fi

        # Check if rfkill is available and unblock Bluetooth
        if command -v rfkill &>/dev/null; then
            sudo rfkill unblock bluetooth 2>/dev/null || echo "Note: Failed to unblock Bluetooth with rfkill"
        fi
        ;;
    *)
        echo "Unsupported distribution for Bluetooth configuration"
        exit 1
        ;;
esac

# Verify Bluetooth installation
if command -v bluetoothctl &>/dev/null; then
    echo "Bluetooth tools installed successfully"
else
    echo "Warning: Bluetooth tools may not be properly installed"
fi

# Check if Bluetooth GUI tool is available
case "$DISTRO" in
    arch)
        if command -v blueberry &>/dev/null; then
            echo "Blueberry Bluetooth manager installed"
        fi
        ;;
    debian)
        if command -v blueberry &>/dev/null; then
            echo "Blueberry Bluetooth manager installed"
        elif command -v blueman &>/dev/null; then
            echo "Blueman Bluetooth manager installed"
        else
            echo "Note: No Bluetooth GUI manager found"
        fi
        ;;
esac
