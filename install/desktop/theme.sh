#!/bin/bash

# theme.sh - Desktop theme configuration
# Compatible with both Arch and Debian systems

# Install theme packages based on distribution
case "$DISTRO" in
    arch)
        # Use dark mode for QT apps too (like kdenlive)
        if ! yay -Q kvantum-qt5 &>/dev/null; then
            yay -S --noconfirm kvantum-qt5
        fi

        # Prefer dark mode everything
        if ! yay -Q gnome-themes-extra &>/dev/null; then
            yay -S --noconfirm gnome-themes-extra # Adds Adwaita-dark theme
        fi

        # Allow icons to match the theme
        if ! yay -Q yaru-icon-theme &>/dev/null; then
            yay -S --noconfirm yaru-icon-theme
        fi
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Install KVantum for Qt theme support
        if ! dpkg -l | grep -q qt5-style-kvantum; then
            sudo apt install -y qt5-style-kvantum kvantum-qt5 2>/dev/null || echo "Warning: KVantum installation failed"
        fi

        # Install GNOME themes extra for Adwaita-dark theme
        if ! dpkg -l | grep -q gnome-themes-extra; then
            sudo apt install -y gnome-themes-extra 2>/dev/null || echo "Warning: gnome-themes-extra installation failed"
        fi

        # Install Yaru icon theme
        if ! dpkg -l | grep -q yaru-theme-icon; then
            sudo apt install -y yaru-theme-icon 2>/dev/null || echo "Warning: Yaru icon theme installation failed"
        fi

        # Install additional theme dependencies
        sudo apt install -y gtk2-engines gtk2-engines-murrine 2>/dev/null || true
        ;;
    *)
        echo "Unsupported distribution for theme configuration"
        exit 1
        ;;
esac

# Apply theme settings using gsettings
# Check if gsettings is available
if command -v gsettings &>/dev/null; then
    # Set GTK theme to dark mode
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || echo "Note: Failed to set GTK theme"
    
    # Prefer dark color scheme
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || echo "Note: Failed to set color scheme"
    
    # Set icon theme
    case "$DISTRO" in
        arch)
            gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue" 2>/dev/null || echo "Note: Failed to set icon theme"
            ;;
        debian)
            # Use default Yaru theme for Debian
            gsettings set org.gnome.desktop.interface icon-theme "Yaru" 2>/dev/null || echo "Note: Failed to set icon theme"
            ;;
    esac
else
    echo "gsettings not available, skipping theme configuration"
fi

# Setup theme links
mkdir -p ~/.config/omarchy/themes 2>/dev/null || true
if [ -d ~/.local/share/omarchy/themes/ ]; then
    for f in ~/.local/share/omarchy/themes/*; do 
        if [ -e "$f" ]; then
            ln -nfs "$f" ~/.config/omarchy/themes/ 2>/dev/null || echo "Warning: Failed to create theme link for $f"
        fi
    done
else
    echo "Note: Omarchy themes directory not found"
fi

# Set initial theme
mkdir -p ~/.config/omarchy/current 2>/dev/null || true

# Check if tokyo-night theme exists before linking
if [ -d ~/.config/omarchy/themes/tokyo-night/ ]; then
    ln -snf ~/.config/omarchy/themes/tokyo-night ~/.config/omarchy/current/theme 2>/dev/null || echo "Warning: Failed to set current theme"
    
    # Set background if it exists
    if [ -f ~/.config/omarchy/themes/tokyo-night/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png ]; then
        ln -snf ~/.config/omarchy/themes/tokyo-night/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png ~/.config/omarchy/current/background 2>/dev/null || echo "Warning: Failed to set background"
    else
        echo "Note: Default background not found"
    fi
else
    echo "Note: Tokyo Night theme not found, using system defaults"
fi

# Set specific app links for current theme
# Neovim theme
if [ -d ~/.config/nvim/lua/plugins/ ]; then
    if [ -f ~/.config/omarchy/current/theme/neovim.lua ]; then
        ln -snf ~/.config/omarchy/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua 2>/dev/null || echo "Warning: Failed to set neovim theme"
    else
        echo "Note: Neovim theme file not found"
    fi
else
    echo "Note: Neovim config directory not found"
fi

# Btop theme
mkdir -p ~/.config/btop/themes 2>/dev/null || true
if [ -f ~/.config/omarchy/current/theme/btop.theme ]; then
    ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme 2>/dev/null || echo "Warning: Failed to set btop theme"
else
    echo "Note: Btop theme file not found"
fi

# Mako notification daemon theme
mkdir -p ~/.config/mako 2>/dev/null || true
if [ -f ~/.config/omarchy/current/theme/mako.ini ]; then
    ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config 2>/dev/null || echo "Warning: Failed to set mako theme"
else
    echo "Note: Mako theme file not found"
fi

echo "Theme configuration completed"
