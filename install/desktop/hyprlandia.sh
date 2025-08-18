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
        
        # If Hyprland is not available in repositories or if we want to ensure latest version,
        # install from Debian repositories directly without external repos
        if ! command -v hyprland &>/dev/null; then
            echo "Installing Hyprland from Debian repositories..."
            
            # Try to install Hyprland directly from Debian repositories
            if apt list hyprland 2>/dev/null | grep -q "hyprland"; then
                sudo apt install -y hyprland
            else
                echo "Hyprland not available in repositories, installing dependencies and compiling from source..."
                # Install all necessary dependencies including aquamarine and udis86
                sudo apt install -y build-essential cmake pkg-config libwayland-dev libegl1-mesa-dev libgles2-mesa-dev libdrm-dev libgbm-dev libx11-dev libx11-xcb-dev libxcb1-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev libxcb-composite0-dev libxcb-present-dev libxcb-sync-dev libxcb-dri3-dev libxcb-dri2-0-dev libxcb-randr0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libpixman-1-dev libjpeg-dev libpng-dev libwebp-dev libegl1-mesa-dev libgles2-mesa-dev libseat-dev libsystemd-dev libinput-dev libxcb-cursor-dev libxcb-errors-dev
                
                # Install additional dependencies needed for compilation
                sudo apt install -y meson ninja-build libffi-dev libglib2.0-dev libpixman-1-dev libvulkan-dev libpugixml-dev libwayland-protocols libdisplay-info-dev hwdata
                
                # Try to install hyprwayland-scanner from repositories first
                if apt list hyprwayland-scanner 2>/dev/null | grep -q "hyprwayland-scanner"; then
                    sudo apt install -y hyprwayland-scanner
                else
                    echo "Installing hyprwayland-scanner from source..."
                    # Install pugixml dependency first
                    sudo apt install -y libpugixml-dev
                    # Clone and build hyprwayland-scanner using CMake
                    git clone https://github.com/hyprwm/hyprwayland-scanner.git /tmp/hyprwayland-scanner
                    cd /tmp/hyprwayland-scanner
                    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .
                    make -j$(nproc)
                    sudo make install
                    cd -
                    rm -rf /tmp/hyprwayland-scanner
                fi
                
                # Try to install hyprutils from repositories first
                if apt list libhyprutils-dev 2>/dev/null | grep -q "libhyprutils-dev"; then
                    sudo apt install -y libhyprutils-dev
                else
                    echo "Installing hyprutils from source..."
                    # Clone and build hyprutils
                    git clone https://github.com/hyprwm/hyprutils.git /tmp/hyprutils
                    cd /tmp/hyprutils
                    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .
                    make -j$(nproc)
                    sudo make install
                    cd -
                    rm -rf /tmp/hyprutils
                fi
                
                # Try to install aquamarine from repositories first
                if apt list libaquamarine-dev 2>/dev/null | grep -q "libaquamarine-dev"; then
                    sudo apt install -y libaquamarine-dev
                else
                    echo "Installing aquamarine from source..."
                    # Install additional dependencies for aquamarine
                    sudo apt install -y libwayland-protocols-dev libdisplay-info-dev hwdata
                    # Clone and build aquamarine
                    git clone https://github.com/hyprwm/aquamarine.git /tmp/aquamarine
                    cd /tmp/aquamarine
                    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .
                    make -j$(nproc)
                    sudo make install
                    cd -
                    rm -rf /tmp/aquamarine
                fi
                
                # Try to install udis86 from repositories first
                if apt list libudis86-dev 2>/dev/null | grep -q "libudis86-dev"; then
                    sudo apt install -y libudis86-dev
                else
                    echo "Installing udis86 from source..."
                    # Clone and build udis86
                    git clone https://github.com/canihavesomecoffee/udis86.git /tmp/udis86
                    cd /tmp/udis86
                    git checkout 5336633af70f3917760a6d441ff02d93477b0c86
                    ./autogen.sh
                    ./configure --enable-shared --disable-static
                    make -j$(nproc)
                    sudo make install
                    cd -
                    rm -rf /tmp/udis86
                fi
                
                # Download and compile Hyprland
                if command -v git &>/dev/null; then
                    # Clone the latest Hyprland release
                    git clone --recursive https://github.com/hyprwm/Hyprland.git /tmp/Hyprland
                    cd /tmp/Hyprland
                    make all
                    sudo make install
                    cd -
                    rm -rf /tmp/Hyprland
                    echo "Hyprland installed successfully from source"
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
