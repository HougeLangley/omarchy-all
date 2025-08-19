#!/bin/bash

# terminal.sh - Terminal tools installation
# Compatible with both Arch and Debian systems

# Install terminal tools based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed \
          wget curl unzip inetutils impala \
          fd eza fzf ripgrep zoxide bat jq xmlstarlet \
          wl-clipboard fastfetch btop \
          man tldr less whois plocate bash-completion \
          alacritty
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Define package mappings for Debian
        # Some packages have different names in Debian
        ARCH_TO_DEBIAN_PACKAGES=(
            "wget:wget"
            "curl:curl"
            "unzip:unzip"
            "inetutils:inetutils-tools"
            "fd:fd-find"
            "eza:eza"
            "fzf:fzf"
            "ripgrep:ripgrep"
            "zoxide:zoxide"
            "bat:bat"
            "jq:jq"
            "xmlstarlet:xmlstarlet"
            "wl-clipboard:wl-clipboard"
            "fastfetch:fastfetch"
            "btop:btop"
            "man:man-db"
            "less:less"
            "whois:whois"
            "plocate:plocate"
            "bash-completion:bash-completion"
            "alacritty:alacritty"
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
            echo "Installing terminal tools for Debian..."
            sudo apt install -y "${DEBIAN_PACKAGES[@]}" 2>/dev/null || echo "Warning: Some packages may have failed to install"
        else
            echo "No valid packages found for installation"
        fi
        
        # Install build dependencies for compiling missing tools
        echo "Installing build dependencies for compiling missing tools..."
        sudo apt install -y build-essential cargo rustc python3-pip python3-venv \
          python3-shtab python3-colorama python3-termcolor \
          python3-build python3-installer python3-hatchling \
          python3-sphinx-argparse python3-wheel python3-pytest pipx || true
        
        # Install impala from source if not available in repositories
        if ! command -v impala &>/dev/null; then
            echo "Installing impala from source..."
            # Create temporary directory for building
            TMP_DIR=$(mktemp -d)
            cd "$TMP_DIR"
            
            # Clone impala
            git clone https://github.com/pythops/impala.git
            cd impala
            
            # Fetch dependencies first to avoid --frozen issues
            if command -v cargo &>/dev/null; then
                cargo fetch --target "$(rustc -vV | sed -n 's/host: //p')"
                
                # Build without --frozen flag to allow network access if needed
                cargo build --release
                
                # Install the built binary
                sudo install -Dm 755 "target/release/impala" "/usr/local/bin/impala"
                echo "impala installed successfully from source"
            else
                echo "cargo not available, skipping impala installation"
            fi
            
            # Clean up
            cd /
            rm -rf "$TMP_DIR"
        fi
        
        # Install tldr from source if not available in repositories
        if ! command -v tldr &>/dev/null; then
            echo "Installing tldr from source..."
            # Use pipx to install tldr python client (recommended approach for Debian)
            if command -v pipx &>/dev/null; then
                pipx install tldr
                echo "tldr installed successfully from source using pipx"
            else
                # Fallback to pip with --user flag if pipx is not available
                if command -v pip3 &>/dev/null; then
                    pip3 install --user tldr
                    # Add user bin to PATH if not already there
                    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                        export PATH="$HOME/.local/bin:$PATH"
                    fi
                    echo "tldr installed successfully from source using pip --user"
                else
                    echo "Neither pipx nor pip3 available, skipping tldr installation"
                fi
            fi
        fi
        
        # Additional setup for Debian
        # Create symlinks for tools with different names
        if command -v fdfind &>/dev/null; then
            # Create symlink for fd (Debian package is fdfind)
            if [ ! -f /usr/local/bin/fd ] && [ -f /usr/bin/fdfind ]; then
                sudo ln -s /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true
            fi
        fi
        
        if command -v batcat &>/dev/null; then
            # Create symlink for bat (Debian package is bat)
            if [ ! -f /usr/local/bin/bat ] && [ -f /usr/bin/batcat ]; then
                sudo ln -s /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
            fi
        fi
        ;;
    *)
        echo "Unsupported distribution for terminal tools installation"
        exit 1
        ;;
esac

echo "Terminal tools installation completed"
