#!/bin/bash

# asdcontrol.sh - Apple Display brightness control installation
# Compatible with both Arch and Debian systems

# Install asdcontrol for controlling brightness on Apple Displays
if [ -z "$OMARCHY_BARE" ] && ! command -v asdcontrol &>/dev/null; then
    # Clone the repository
    if command -v git &>/dev/null; then
        git clone https://github.com/nikosdion/asdcontrol.git /tmp/asdcontrol
        cd /tmp/asdcontrol
        
        # Check distribution and install dependencies
        case "$DISTRO" in
            arch)
                # Install build dependencies for Arch
                yay -S --noconfirm --needed gcc make libusbhid libusb
                
                # Build and install
                make
                sudo make install
                
                # Setup sudo-less controls
                echo "$USER ALL=(ALL) NOPASSWD: /usr/local/bin/asdcontrol" | sudo tee /etc/sudoers.d/asdcontrol
                sudo chmod 440 /etc/sudoers.d/asdcontrol
                ;;
            debian)
                # Update package lists first
                sudo apt update
                
                # Install build dependencies for Debian
                sudo apt install -y gcc make libusb-1.0-0-dev libusbhid-dev 2>/dev/null || echo "Warning: Some dependencies may have failed to install"
                
                # Build and install
                if make 2>/dev/null; then
                    sudo make install
                    
                    # Setup sudo-less controls
                    # Check if sudoers.d directory exists
                    if [ -d /etc/sudoers.d/ ]; then
                        echo "$USER ALL=(ALL) NOPASSWD: /usr/local/bin/asdcontrol" | sudo tee /etc/sudoers.d/asdcontrol
                        sudo chmod 440 /etc/sudoers.d/asdcontrol
                    else
                        echo "Note: /etc/sudoers.d/ directory not found, sudo-less controls not configured"
                    fi
                else
                    echo "Warning: Failed to build asdcontrol, installation may have failed"
                fi
                ;;
            *)
                echo "Unsupported distribution for asdcontrol installation"
                ;;
        esac
        
        # Clean up
        cd -
        rm -rf /tmp/asdcontrol
    else
        echo "git not available, skipping asdcontrol installation"
    fi
else
    if command -v asdcontrol &>/dev/null; then
        echo "asdcontrol is already installed"
    else
        echo "OMARCHY_BARE is set, skipping asdcontrol installation"
    fi
fi

# Verify installation
if command -v asdcontrol &>/dev/null; then
    echo "asdcontrol installation completed successfully"
else
    echo "Note: asdcontrol may not be properly installed or is not needed on this system"
fi
