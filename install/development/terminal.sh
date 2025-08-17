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
            "impala:impala"
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
            "tldr:tldr"
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
