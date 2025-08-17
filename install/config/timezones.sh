#!/bin/bash

# timezones.sh - Timezone configuration setup
# Compatible with both Arch and Debian systems

# Install timezone update tools based on distribution
case "$DISTRO" in
    arch)
        if ! command -v tzupdate &>/dev/null; then
            yay -S --noconfirm --needed tzupdate
            # Configure sudo permissions for timezone update
            if getent group wheel > /dev/null 2>&1; then
                sudo tee /etc/sudoers.d/omarchy-tzupdate >/dev/null <<EOF
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
                sudo chmod 0440 /etc/sudoers.d/omarchy-tzupdate
            else
                echo "Warning: wheel group not found, skipping sudo configuration"
            fi
        fi
        ;;
    debian)
        # Check if tzupdate is available in apt repositories
        if ! command -v tzupdate &>/dev/null; then
            if apt list tzupdate 2>/dev/null | grep -q "tzupdate"; then
                sudo apt update && sudo apt install -y tzupdate
            else
                echo "tzupdate not available in Debian repositories, using timedatectl instead"
                # Ensure systemd tools are available
                if ! command -v timedatectl &>/dev/null; then
                    sudo apt update && sudo apt install -y systemd
                fi
            fi
        fi
        
        # Configure sudo permissions for timezone update on Debian
        # Debian typically uses sudo group instead of wheel
        if getent group sudo > /dev/null 2>&1; then
            sudo tee /etc/sudoers.d/omarchy-tzupdate >/dev/null <<EOF
%sudo ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
            sudo chmod 0440 /etc/sudoers.d/omarchy-tzupdate
        elif getent group wheel > /dev/null 2>&1; then
            # Fallback to wheel group if it exists
            sudo tee /etc/sudoers.d/omarchy-tzupdate >/dev/null <<EOF
%wheel ALL=(root) NOPASSWD: /usr/bin/tzupdate, /usr/bin/timedatectl
EOF
            sudo chmod 0440 /etc/sudoers.d/omarchy-tzupdate
        else
            echo "Warning: Neither sudo nor wheel group found, skipping sudo configuration"
        fi
        ;;
    *)
        echo "Unsupported distribution for timezone configuration"
        exit 1
        ;;
esac

# Update timezone if tzupdate is available
if command -v tzupdate &>/dev/null; then
    echo "Updating timezone using tzupdate..."
    tzupdate 2>/dev/null || echo "Warning: Failed to update timezone with tzupdate"
else
    # Fallback to timedatectl for automatic timezone detection
    if command -v timedatectl &>/dev/null; then
        echo "Using timedatectl for timezone configuration..."
        # Note: timedatectl requires manual timezone selection or geolocation service
        echo "Note: Automatic timezone detection may require additional geolocation services"
    else
        echo "Warning: No timezone update tools available"
    fi
fi

echo "Timezone configuration completed"
