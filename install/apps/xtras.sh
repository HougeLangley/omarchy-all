#!/bin/bash

# xtras.sh - Extra applications installation
# Compatible with both Arch and Debian systems

if [ -z "$OMARCHY_BARE" ]; then
    case "$DISTRO" in
        arch)
            yay -S --noconfirm --needed \
                gnome-calculator gnome-keyring signal-desktop \
                obsidian-bin libreoffice obs-studio kdenlive \
                xournalpp localsend-bin

            # Packages known to be flaky or having key signing issues are run one-by-one
            for pkg in pinta typora spotify zoom; do
                yay -S --noconfirm --needed "$pkg" ||
                    echo -e "\e[31mFailed to install $pkg. Continuing without!\e[0m"
            done

            yay -S --noconfirm --needed 1password-beta 1password-cli ||
                echo -e "\e[31mFailed to install 1password. Continuing without!\e[0m"
            ;;
        debian)
            # Update package lists first
            sudo apt update
            
            # Define package mappings for Debian
            ARCH_TO_DEBIAN_PACKAGES=(
                "gnome-calculator:gnome-calculator"
                "gnome-keyring:gnome-keyring"
                "signal-desktop:signal-desktop"
                "libreoffice:libreoffice"
                "obs-studio:obs-studio"
                "kdenlive:kdenlive"
                "xournalpp:xournalpp"
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
                echo "Installing extra applications for Debian..."
                sudo apt install -y "${DEBIAN_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some packages may have failed to install"
            else
                echo "No valid packages found for installation"
            fi
            
            # Install packages known to be flaky or having issues one-by-one
            FLAKY_PACKAGES=("pinta" "spotify-client" "zoom" "typora")
            for pkg in "${FLAKY_PACKAGES[@]}"; do
                if apt list "$pkg" 2>/dev/null | grep -q "$pkg"; then
                    sudo apt install -y "$pkg" ||
                        echo -e "\e[31mFailed to install $pkg. Continuing without!\e[0m"
                else
                    echo "Note: Package $pkg not available in repositories"
                fi
            done
            
            # Install 1Password from official repository
            if ! command -v 1password &>/dev/null; then
                echo "Installing 1Password from official repository..."
                # Add 1Password repository
                sudo apt install -y curl gnupg
                curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
                sudo apt update
                sudo apt install -y 1password 1password-cli ||
                    echo -e "\e[31mFailed to install 1password. Continuing without!\e[0m"
            fi
            
            # Install OBSidian from official source if not in repositories
            if ! command -v obsidian &>/dev/null; then
                echo "Installing Obsidian from official source..."
                if command -v curl &>/dev/null && command -v tar &>/dev/null; then
                    # Check if AppImage is preferred
                    if [ ! -f "/usr/local/bin/obsidian" ]; then
                        echo "Note: Obsidian may need to be installed manually from https://obsidian.md/"
                    fi
                fi
            fi
            
            # Install LocalSend from GitHub if not in repositories
            if ! command -v localsend &>/dev/null; then
                echo "Installing LocalSend from GitHub releases..."
                if command -v curl &>/dev/null; then
                    # This would require downloading and installing from GitHub
                    echo "Note: LocalSend may need to be installed manually from https://github.com/localsend/localsend"
                fi
            fi
            
            # Additional Debian-specific setup
            # Install flatpak for additional app support
            if ! command -v flatpak &>/dev/null; then
                sudo apt install -y flatpak 2>/dev/null || true
                if command -v flatpak &>/dev/null; then
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
                fi
            fi
            ;;
        *)
            echo "Unsupported distribution for extra applications installation"
            exit 1
            ;;
    esac
else
    echo "OMARCHY_BARE is set, skipping extra applications installation"
fi

# Copy over Omarchy applications
if [ -f "omarchy-refresh-applications" ]; then
    source omarchy-refresh-applications || true
else
    echo "Note: omarchy-refresh-applications script not found"
fi

echo "Extra applications installation completed"
