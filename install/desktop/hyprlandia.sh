#!/bin/bash

# hyprlandia.sh - Hyprland desktop environment installation
# Compatible with both Arch and Debian systems

# Install Hyprland and related tools based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed \
          hyprland hyprshot hyprpicker hyprlock hypridle hyprsunset polkit-gnome hyprland-qtutils \
          walker-bin libqalculate waybar mako swaybg swayosd \
          xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Check Debian version for Hyprland availability
        DEBIAN_VERSION=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)
        
        # For newer Debian versions (bookworm and later), Hyprland may be available in repositories
        if [ "$(echo "$DEBIAN_VERSION >= 12" | bc -l 2>/dev/null)" = "1" ] 2>/dev/null || [ "$DEBIAN_VERSION" = "bookworm" ] || [ "$DEBIAN_VERSION" = "trixie" ]; then
            # Define package mappings for Debian
            ARCH_TO_DEBIAN_PACKAGES=(
                "hyprland:hyprland"
                "hyprshot:hyprshot"
                "hyprpicker:hyprpicker"
                "hyprlock:hyprlock"
                "hypridle:hypridle"
                "hyprsunset:hyprsunset"
                "polkit-gnome:polkit-gnome"
                "walker-bin:walker"
                "libqalculate:libqalculate-dev"
                "waybar:waybar"
                "mako:mako-notifier"
                "swaybg:swaybg"
                "swayosd:swayosd"
                "xdg-desktop-portal-hyprland:xdg-desktop-portal-hyprland"
                "xdg-desktop-portal-gtk:xdg-desktop-portal-gtk"
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
                echo "Installing Hyprland components for Debian..."
                sudo apt install -y "${DEBIAN_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some packages may have failed to install"
            else
                echo "No valid packages found in repositories, installing from alternative sources..."
            fi
        else
            echo "Older Debian version detected, installing Hyprland from alternative sources..."
        fi
        
        # If Hyprland is not available in repositories, install from official sources
        if ! command -v hyprland &>/dev/null; then
            echo "Installing Hyprland from official repository..."
            
            # Add Hyprland repository for Debian
            sudo apt install -y curl ca-certificates
            curl -fsSL https://hyprland.org/hyprland.gpg | sudo gpg --dearmor -o /usr/share/keyrings/hyprland.gpg
            echo "deb [signed-by=/usr/share/keyrings/hyprland.gpg] https://hyprland.org/debian/ bookworm main" | sudo tee /etc/apt/sources.list.d/hyprland.list
            
            # Update package lists again
            sudo apt update
            
            # Try to install Hyprland again
            if apt list hyprland 2>/dev/null | grep -q "hyprland"; then
                sudo apt install -y hyprland
            else
                echo "Installing Hyprland from GitHub releases..."
                # Install dependencies first
                sudo apt install -y build-essential cmake pkg-config libwayland-dev libegl1-mesa-dev libgles2-mesa-dev libdrm-dev libgbm-dev libx11-dev libx11-xcb-dev libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev libxcb-present-dev libxcb-sync-dev libxcb-dri3-dev libxcb-dri2-0-dev libxcb-randr0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libpixman-1-dev libjpeg-dev libpng-dev libwebp-dev libegl1-mesa-dev libgles2-mesa-dev libseat-dev libsystemd-dev libinput-dev libxcb-cursor-dev libxcb-errors-dev
                
                # Download and compile Hyprland
                if command -v git &>/dev/null; then
                    git clone --recursive https://github.com/hyprwm/Hyprland.git /tmp/Hyprland
                    cd /tmp/Hyprland
                    make all
                    sudo make install
                    cd -
                    rm -rf /tmp/Hyprland
                else
                    echo "git not available, skipping Hyprland compilation"
                fi
            fi
        fi
        
        # Install other essential components
        sudo apt install -y polkitd libqalculate-dev waybar mako-notifier swaybg \
            xdg-desktop-portal-hyprland xdg-desktop-portal-gtk 2>/dev/null || true
        
        # Install additional tools if available
        if apt list swayosd 2>/dev/null | grep -q "swayosd"; then
            sudo apt install -y swayosd
        fi
        
        if apt list hyprpicker 2>/dev/null | grep -q "hyprpicker"; then
            sudo apt install -y hyprpicker
        fi
        
        if apt list hyprshot 2>/dev/null | grep -q "hyprshot"; then
            sudo apt install -y hyprshot
        fi
        
        # Install polkit-gnome if available
        if apt list polkit-gnome 2>/dev/null | grep -q "polkit-gnome"; then
            sudo apt install -y polkit-gnome
        else
            # Install alternative polkit agent
            sudo apt install -y lxpolkit 2>/dev/null || true
        fi
        
        # Additional setup for Debian
        # Create necessary directories
        mkdir -p ~/.config/hypr 2>/dev/null || true
        
        # Install build dependencies for compiling missing tools
        sudo apt install -y meson ninja-build 2>/dev/null || true
        ;;
    *)
        echo "Unsupported distribution for Hyprland installation"
        exit 1
        ;;
esac

# Verify Hyprland installation
if command -v hyprland &>/dev/null; then
    echo "Hyprland installation completed successfully"
    hyprland --version
else
    echo "Warning: Hyprland installation may have failed"
fi
