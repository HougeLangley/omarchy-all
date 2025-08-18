#!/bin/bash

# nvim.sh - Neovim installation and configuration
# Compatible with both Arch and Debian systems

# Check if nvim is already installed
if ! command -v nvim &>/dev/null; then
    case "$DISTRO" in
        arch)
            yay -S --noconfirm --needed nvim luarocks tree-sitter-cli

            # Install LazyVim
            rm -rf ~/.config/nvim
            git clone https://github.com/LazyVim/starter ~/.config/nvim
            cp -R ~/.local/share/omarchy/config/nvim/* ~/.config/nvim/
            rm -rf ~/.config/nvim/.git
            echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua
            ;;
        debian)
            # Update package lists first
            sudo apt update
            
            # Check if neovim is available in default repositories
            if apt list neovim 2>/dev/null | grep -q "neovim"; then
                # Install neovim and related tools
                # Fixed package name from lua-rocks to luarocks
                # Using lua5.3 instead of lua5.1 for better compatibility
                sudo apt install -y neovim lua5.3 luarocks tree-sitter-cli npm
            else
                # Install from snap or alternative methods
                echo "Installing neovim from alternative sources..."
                
                # Check if snap is available
                if command -v snap &>/dev/null; then
                    sudo snap install nvim --classic
                else
                    # Install from AppImage or GitHub releases
                    echo "Installing neovim from GitHub releases..."
                    if command -v curl &>/dev/null && command -v tar &>/dev/null; then
                        NVIM_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                        if [ -n "$NVIM_VERSION" ]; then
                            curl -Lo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
                            sudo tar -C /opt -xzf nvim.tar.gz
                            sudo ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                            rm nvim.tar.gz
                            echo "Neovim installed successfully"
                        else
                            echo "Failed to fetch neovim version"
                        fi
                    else
                        echo "curl or tar not available, skipping neovim installation"
                    fi
                fi
                
                # Install luarocks and tree-sitter-cli via npm if not available via apt
                if ! command -v luarocks &>/dev/null; then
                    if command -v npm &>/dev/null; then
                        sudo npm install -g luarocks
                    fi
                fi
                
                if ! command -v tree-sitter &>/dev/null; then
                    if command -v npm &>/dev/null; then
                        sudo npm install -g tree-sitter-cli
                    fi
                fi
            fi

            # Install LazyVim
            rm -rf ~/.config/nvim 2>/dev/null || true
            if command -v git &>/dev/null; then
                git clone https://github.com/LazyVim/starter ~/.config/nvim
                # Copy Omarchy configuration if it exists
                if [ -d ~/.local/share/omarchy/config/nvim/ ]; then
                    cp -R ~/.local/share/omarchy/config/nvim/* ~/.config/nvim/ 2>/dev/null || true
                fi
                rm -rf ~/.config/nvim/.git 2>/dev/null || true
                
                # Check if options.lua exists before appending
                if [ -f ~/.config/nvim/lua/config/options.lua ]; then
                    echo "vim.opt.relativenumber = false" >>~/.config/nvim/lua/config/options.lua
                else
                    # Create the file if it doesn't exist
                    mkdir -p ~/.config/nvim/lua/config
                    echo "vim.opt.relativenumber = false" >~/.config/nvim/lua/config/options.lua
                fi
            else
                echo "git not available, skipping LazyVim installation"
            fi
            ;;
        *)
            echo "Unsupported distribution for neovim installation"
            exit 1
            ;;
    esac
    
    # Verify installation
    if command -v nvim &>/dev/null; then
        echo "Neovim installation completed successfully"
    else
        echo "Warning: Neovim installation may have failed"
    fi
else
    echo "Neovim is already installed"
fi
