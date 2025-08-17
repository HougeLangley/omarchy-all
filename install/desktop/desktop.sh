#!/bin/bash

# desktop.sh - Desktop tools installation
# Compatible with both Arch and Debian systems

# Install desktop tools based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed \
          brightnessctl playerctl pamixer wiremix wireplumber \
          fcitx5 fcitx5-gtk fcitx5-qt wl-clip-persist \
          nautilus sushi ffmpegthumbnailer gvfs-mtp \
          slurp satty \
          mpv evince imv \
          chromium

        # Add screen recorder based on GPU
        if lspci | grep -qi 'nvidia'; then
        yay -S --noconfirm --needed wf-recorder
        else
        yay -S --noconfirm --needed wl-screenrec
        fi
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Define package mappings for Debian
        ARCH_TO_DEBIAN_PACKAGES=(
            "brightnessctl:brightnessctl"
            "playerctl:playerctl"
            "pamixer:pamixer"
            "wiremix:wireplumber"
            "wireplumber:wireplumber"
            "fcitx5:fcitx5"
            "fcitx5-gtk:fcitx5-gtk"
            "fcitx5-qt:fcitx5-qt"
            "wl-clip-persist:wl-clip-persist"
            "nautilus:nautilus"
            "sushi:sushi"
            "ffmpegthumbnailer:ffmpegthumbnailer"
            "gvfs-mtp:gvfs-fuse gvfs-backends"
            "slurp:slurp"
            "satty:satty"
            "mpv:mpv"
            "evince:evince"
            "imv:imv"
            "chromium:chromium"
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
                
                # Try alternative package names
                case "$arch_pkg" in
                    "wl-clip-persist")
                        if apt list "wl-clipboard" 2>/dev/null | grep -q "wl-clipboard"; then
                            DEBIAN_PACKAGES+=("wl-clipboard")
                        fi
                        ;;
                    "satty")
                        echo "Note: satty may need to be installed from GitHub releases or source"
                        ;;
                esac
            fi
        done
        
        # Install packages with error handling
        if [ ${#DEBIAN_PACKAGES[@]} -gt 0 ]; then
            echo "Installing desktop tools for Debian..."
            sudo apt install -y "${DEBIAN_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some packages may have failed to install"
        else
            echo "No valid packages found for installation"
        fi
        
        # Install screen recorder based on GPU
        if lspci | grep -qi 'nvidia'; then
            # Check if wf-recorder is available
            if apt list wf-recorder 2>/dev/null | grep -q "wf-recorder"; then
                sudo apt install -y wf-recorder
            else
                echo "Installing wf-recorder from GitHub releases..."
                if command -v curl &>/dev/null && command -v tar &>/dev/null; then
                    WF_RECORDER_VERSION=$(curl -s "https://api.github.com/repos/ammen99/wf-recorder/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                    if [ -n "$WF_RECORDER_VERSION" ]; then
                        curl -Lo wf-recorder.tar.gz "https://github.com/ammen99/wf-recorder/releases/download/v${WF_RECORDER_VERSION}/wf-recorder-${WF_RECORDER_VERSION}.tar.xz"
                        if command -v tar &>/dev/null && command -v meson &>/dev/null && command -v ninja &>/dev/null; then
                            tar -xf wf-recorder.tar.gz
                            cd "wf-recorder-${WF_RECORDER_VERSION}"
                            meson build
                            ninja -C build
                            sudo ninja -C build install
                            cd ..
                            rm -rf "wf-recorder-${WF_RECORDER_VERSION}" wf-recorder.tar.gz
                            echo "wf-recorder installed successfully"
                        else
                            echo "Build tools not available, installing dependencies..."
                            sudo apt install -y meson ninja-build libwayland-dev libavutil-dev libavformat-dev libavfilter-dev libavdevice-dev
                            # Retry installation
                        fi
                    else
                        echo "Failed to fetch wf-recorder version"
                    fi
                else
                    echo "curl or tar not available, skipping wf-recorder installation"
                fi
            fi
        else
            # Check if wl-screenrec is available
            if apt list wl-screenrec 2>/dev/null | grep -q "wl-screenrec"; then
                sudo apt install -y wl-screenrec
            else
                echo "Installing alternative screen recorder..."
                # Install obs-studio as alternative
                sudo apt install -y obs-studio
            fi
        fi
        
        # Additional setup for Debian
        # Install missing gvfs components
        sudo apt install -y gvfs gvfs-common 2>/dev/null || true
        
        # Install additional MIME type support
        sudo apt install -y shared-mime-info 2>/dev/null || true
        ;;
    *)
        echo "Unsupported distribution for desktop tools installation"
        exit 1
        ;;
esac

echo "Desktop tools installation completed"
