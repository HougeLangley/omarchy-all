#!/bin/bash

# detect-keyboard-layout.sh - Detect and configure keyboard layout
# Compatible with both Arch and Debian systems

conf="/etc/default/keyboard"
hyprconf="$HOME/.config/hypr/hyprland.conf"

# Check if keyboard configuration file exists
if [ ! -f "$conf" ]; then
    echo "Warning: Keyboard configuration file not found at $conf"
    echo "Creating default keyboard configuration..."
    
    # Create default configuration based on distribution
    case "$DISTRO" in
        arch)
            sudo touch /etc/vconsole.conf
            conf="/etc/vconsole.conf"
            ;;
        debian)
            sudo touch /etc/default/keyboard
            conf="/etc/default/keyboard"
            ;;
    esac
fi

# Detect distribution and parse keyboard layout accordingly
case "$DISTRO" in
    arch)
        # Arch uses /etc/vconsole.conf format
        conf="/etc/vconsole.conf"
        if [ -f "$conf" ]; then
            layout=$(grep '^KEYMAP=' "$conf" | cut -d= -f2 | tr -d '"')
        fi
        ;;
    debian)
        # Debian uses /etc/default/keyboard format
        if [ -f "$conf" ]; then
            layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
            variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
        fi
        ;;
    *)
        echo "Unsupported distribution for keyboard layout detection"
        exit 1
        ;;
esac

# Check if Hyprland configuration exists
if [ ! -f "$hyprconf" ]; then
    echo "Warning: Hyprland configuration not found at $hyprconf"
    echo "Skipping keyboard layout configuration for Hyprland"
else
    # Backup original configuration
    cp "$hyprconf" "$hyprconf.bak"
    
    # Add keyboard layout configuration to Hyprland
    if [[ -n "$layout" ]]; then
        # Check if kb_layout line already exists
        if grep -q "^[[:space:]]*kb_layout" "$hyprconf"; then
            sed -i "s|^[[:space:]]*kb_layout.*|  kb_layout = $layout|" "$hyprconf"
        else
            # Insert before kb_options line or at the end of input section
            if grep -q "^[[:space:]]*kb_options" "$hyprconf"; then
                sed -i "/^[[:space:]]*kb_options/i\  kb_layout = $layout" "$hyprconf"
            else
                # Append to the end of file or appropriate section
                echo "  kb_layout = $layout" >> "$hyprconf"
            fi
        fi
    fi
    
    if [[ -n "$variant" ]]; then
        # Check if kb_variant line already exists
        if grep -q "^[[:space:]*kb_variant" "$hyprconf"; then
            sed -i "s|^[[:space:]]*kb_variant.*|  kb_variant = $variant|" "$hyprconf"
        else
            # Insert before kb_options line or at the end of input section
            if grep -q "^[[:space:]]*kb_options" "$hyprconf"; then
                sed -i "/^[[:space:]]*kb_options/i\  kb_variant = $variant" "$hyprconf"
            else
                # Append to the end of file or appropriate section
                echo "  kb_variant = $variant" >> "$hyprconf"
            fi
        fi
    fi
fi

echo "Keyboard layout detection and configuration completed"
