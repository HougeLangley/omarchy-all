#!/bin/bash

# power.sh - Power management configuration
# Compatible with both Arch and Debian systems

# Install power management tools based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm power-profiles-daemon
        ;;
    debian)
        # Check if power-profiles-daemon is available in apt
        if apt list power-profiles-daemon 2>/dev/null | grep -q "power-profiles-daemon"; then
            sudo apt update && sudo apt install -y power-profiles-daemon
        else
            echo "power-profiles-daemon not available in repositories, trying alternative power management tools"
            # Install alternative power management tools for Debian
            sudo apt update && sudo apt install -y upower
        fi
        ;;
    *)
        echo "Unsupported distribution for power management configuration"
        exit 1
        ;;
esac

# Start and enable power-profiles-daemon service
if command -v powerprofilesctl &>/dev/null; then
    sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || true
    
    # Check if system has battery
    if ls /sys/class/power_supply/BAT* &>/dev/null; then
        # This computer runs on a battery
        echo "Battery detected, setting balanced power profile..."
        powerprofilesctl set balanced 2>/dev/null || echo "Warning: Failed to set balanced power profile"
        
        # Enable battery monitoring timer for low battery notifications if available
        if systemctl --user list-unit-files | grep -q omarchy-battery-monitor.timer; then
            systemctl --user enable --now omarchy-battery-monitor.timer 2>/dev/null || true
        else
            echo "Note: Omarchy battery monitor timer not found"
        fi
    else
        # This computer runs on power outlet
        echo "No battery detected, setting performance power profile..."
        powerprofilesctl set performance 2>/dev/null || echo "Warning: Failed to set performance power profile"
    fi
else
    echo "powerprofilesctl not available, skipping power profile configuration"
    
    # Alternative power management for Debian systems without power-profiles-daemon
    if [ "$DISTRO" = "debian" ]; then
        # Check if TLP is available as alternative
        if command -v tlp &>/dev/null; then
            sudo systemctl enable --now tlp.service 2>/dev/null || true
            echo "TLP power management enabled for Debian"
        fi
    fi
fi

# Additional Debian-specific power management optimizations
if [ "$DISTRO" = "debian" ]; then
    # Check if sysfsutils is installed for power management
    if dpkg -l | grep -q sysfsutils 2>/dev/null; then
        # Enable power saving features
        if [ -w /sys/module/snd_hda_intel/parameters/power_save ]; then
            echo 1 | sudo tee /sys/module/snd_hda_intel/parameters/power_save >/dev/null 2>&1 || true
        fi
    fi
fi

echo "Power management configuration completed"
