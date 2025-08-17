#!/bin/bash

# development.sh - Development tools installation
# Compatible with both Arch and Debian systems

# Install development tools based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed \
          cargo clang llvm mise \
          imagemagick \
          mariadb-libs postgresql-libs \
          github-cli \
          lazygit lazydocker-bin
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Define package mappings for Debian
        ARCH_TO_DEBIAN_PACKAGES=(
            "cargo:cargo"
            "clang:clang"
            "llvm:llvm"
            "mise:mise"
            "imagemagick:imagemagick"
            "mariadb-libs:libmariadb-dev"
            "postgresql-libs:libpq-dev"
            "github-cli:gh"
            "lazygit:lazygit"
            "lazydocker-bin:lazydocker"
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
                
                # Try alternative package names for common tools
                case "$arch_pkg" in
                    "lazygit")
                        if apt list "lazygit" 2>/dev/null | grep -q "lazygit"; then
                            DEBIAN_PACKAGES+=("lazygit")
                        else
                            echo "Note: lazygit may need to be installed from GitHub releases or source"
                        fi
                        ;;
                    "lazydocker-bin")
                        if apt list "lazydocker" 2>/dev/null | grep -q "lazydocker"; then
                            DEBIAN_PACKAGES+=("lazydocker")
                        else
                            echo "Note: lazydocker may need to be installed from GitHub releases or source"
                        fi
                        ;;
                    "mise")
                        if ! command -v mise &>/dev/null; then
                            echo "Installing mise via official installer..."
                            curl -sSL https://mise.run | sh
                            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                        fi
                        ;;
                esac
            fi
        done
        
        # Install packages with error handling
        if [ ${#DEBIAN_PACKAGES[@]} -gt 0 ]; then
            echo "Installing development tools for Debian..."
            sudo apt install -y "${DEBIAN_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some packages may have failed to install"
        else
            echo "No valid packages found for installation"
        fi
        
        # Additional setup for Debian
        # Install mise if not available in repositories
        if ! command -v mise &>/dev/null; then
            echo "Installing mise via official installer..."
            if command -v curl &>/dev/null; then
                curl -sSL https://mise.run | sh
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            else
                echo "curl not available, skipping mise installation"
            fi
        fi
        
        # Install lazygit from GitHub if not available in repositories
        if ! command -v lazygit &>/dev/null; then
            echo "Installing lazygit from GitHub releases..."
            if command -v curl &>/dev/null && command -v tar &>/dev/null; then
                LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                if [ -n "$LAZYGIT_VERSION" ]; then
                    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                    sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
                    rm lazygit.tar.gz
                    echo "lazygit installed successfully"
                else
                    echo "Failed to fetch lazygit version"
                fi
            else
                echo "curl or tar not available, skipping lazygit installation"
            fi
        fi
        
        # Install lazydocker from GitHub if not available in repositories
        if ! command -v lazydocker &>/dev/null; then
            echo "Installing lazydocker from GitHub releases..."
            if command -v curl &>/dev/null && command -v tar &>/dev/null; then
                LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                if [ -n "$LAZYDOCKER_VERSION" ]; then
                    curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
                    sudo tar xf lazydocker.tar.gz -C /usr/local/bin lazydocker
                    rm lazydocker.tar.gz
                    echo "lazydocker installed successfully"
                else
                    echo "Failed to fetch lazydocker version"
                fi
            else
                echo "curl or tar not available, skipping lazydocker installation"
            fi
        fi
        ;;
    *)
        echo "Unsupported distribution for development tools installation"
        exit 1
        ;;
esac

echo "Development tools installation completed"
