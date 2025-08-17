#!/bin/bash

# Install gum based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed gum
        ;;
    debian)
        # Check if gum is available in apt repository
        if apt list --installed 2>/dev/null | grep -q gum; then
            echo "gum is already installed"
        else
            # Try to install from repository first
            if sudo apt update && sudo apt install -y gum; then
                echo "gum installed successfully from repository"
            else
                echo "Failed to install gum from repository"
                exit 1
            fi
        fi
        ;;
    *)
        echo "Unsupported distribution for gum installation"
        exit 1
        ;;
esac
