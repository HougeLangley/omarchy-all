#!/bin/bash

# fonts.sh - Font installation
# Compatible with both Arch and Debian systems

# Install fonts based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed ttf-font-awesome ttf-cascadia-mono-nerd ttf-ia-writer noto-fonts noto-fonts-emoji

        if [ -z "$OMARCHY_BARE" ]; then
            yay -S --noconfirm --needed ttf-jetbrains-mono noto-fonts-cjk noto-fonts-extra
        fi
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Define package mappings for Debian
        ARCH_TO_DEBIAN_PACKAGES=(
            "ttf-font-awesome:fonts-font-awesome"
            "ttf-cascadia-mono-nerd:fonts-cascadia-code"
            "ttf-ia-writer:fonts-ia-writer"
            "noto-fonts:fonts-noto-core"
            "noto-fonts-emoji:fonts-noto-color-emoji"
        )
        
        # Build package list for Debian
        DEBIAN_PACKAGES=()
        
        for mapping in "${ARCH_TO_DEBIAN_PACKAGES[@]}"; do
            arch_pkg="${mapping%%:*}"
            debian_pkg="${mapping#*:}"
            
            # Check if package is available in Debian repositories
            if apt list "$debian_pkg" 2>/dev/null | grep -q "$debian_pkg"; then
                DEBIAN_PACKAGES+=("$debian_pkg")
            else
                echo "Warning: Package $debian_pkg (for $arch_pkg) not found in repositories"
            fi
        done
        
        # Install packages with error handling
        if [ ${#DEBIAN_PACKAGES[@]} -gt 0 ]; then
            echo "Installing fonts for Debian..."
            sudo apt install -y "${DEBIAN_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some font packages may have failed to install"
        else
            echo "No valid font packages found for installation"
        fi
        
        # Install additional fonts if not in bare mode
        if [ -z "$OMARCHY_BARE" ]; then
            ADDITIONAL_PACKAGES=(
                "fonts-jetbrains-mono"  # JetBrains Mono font
                "fonts-noto-cjk"        # Noto CJK fonts
                "fonts-noto-extra"      # Noto extra fonts
            )
            
            # Check and install additional packages
            for package in "${ADDITIONAL_PACKAGES[@]}"; do
                if apt list "$package" 2>/dev/null | grep -q "$package"; then
                    sudo apt install -y "$package" 2>/dev/null || echo "Warning: Failed to install $package"
                else
                    echo "Note: Package $package not available in repositories"
                fi
            done
        fi
        
        # Additional Debian-specific font setup
        # Update font cache
        if command -v fc-cache &>/dev/null; then
            echo "Updating font cache..."
            fc-cache -fv 2>/dev/null || echo "Note: Font cache update failed"
        fi
        
        # Install fontconfig if not present
        if ! dpkg -l | grep -q fontconfig; then
            sudo apt install -y fontconfig 2>/dev/null || echo "Warning: Failed to install fontconfig"
        fi
        ;;
    *)
        echo "Unsupported distribution for font installation"
        exit 1
        ;;
esac

# Verify font installation
echo "Font installation completed"
if command -v fc-list &>/dev/null; then
    echo "Available fonts:"
    fc-list : family | head -10 | sort
    echo "... (showing first 10 font families)"
else
    echo "Note: fc-list not available to show installed fonts"
fi
