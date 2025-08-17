#!/bin/bash

# fix-fkeys.sh - Fix function keys behavior for Apple keyboards
# Compatible with both Arch and Debian systems

# Check if we're on a system with Apple keyboard
if lsmod | grep -q hid_apple; then
    echo "Apple keyboard detected, configuring function keys..."
    
    case "$DISTRO" in
        arch)
            # Arch Linux specific configuration
            if [[ ! -f /etc/modprobe.d/hid_apple.conf ]]; then
                echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
                echo "Apple keyboard configuration file created for Arch"
            else
                # Check if fnmode is already set correctly
                if ! grep -q "fnmode=2" /etc/modprobe.d/hid_apple.conf; then
                    echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
                    echo "Updated Apple keyboard configuration for Arch"
                else
                    echo "Apple keyboard configuration already set for Arch"
                fi
            fi
            
            # Note: initramfs rebuild will be handled by login.sh
            ;;
        debian)
            # Debian specific configuration
            if [[ ! -f /etc/modprobe.d/hid_apple.conf ]]; then
                echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
                echo "Apple keyboard configuration file created for Debian"
            else
                # Check if fnmode is already set correctly
                if ! grep -q "fnmode=2" /etc/modprobe.d/hid_apple.conf; then
                    echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf
                    echo "Updated Apple keyboard configuration for Debian"
                else
                    echo "Apple keyboard configuration already set for Debian"
                fi
            fi
            
            # Update initramfs on Debian
            if command -v update-initramfs &> /dev/null; then
                echo "Updating initramfs for Debian..."
                sudo update-initramfs -u 2>/dev/null || echo "Note: initramfs update may require manual execution after reboot"
            elif command -v update-initramfs &> /dev/null; then
                echo "Alternative initramfs tool detected, update may be needed after reboot"
            else
                echo "Note: No initramfs update tool found, manual update may be required"
            fi
            ;;
        *)
            echo "Unsupported distribution for Apple keyboard configuration"
            ;;
    esac
else
    echo "No Apple keyboard detected or hid_apple module not loaded"
fi

echo "Function keys configuration completed"
