#!/bin/bash

# identification.sh - User identification configuration
# Compatible with both Arch and Debian systems

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "Error: gum is not installed. Please install gum to continue."
    echo "For Arch: sudo pacman -S gum"
    echo "For Debian/Ubuntu: sudo apt install gum"
    exit 1
fi

export OMARCHY_USER_NAME=$(gum input --placeholder "Enter full name" --prompt "Name> ")
export OMARCHY_USER_EMAIL=$(gum input --placeholder "Enter email address" --prompt "Email> ")

# Validate inputs
if [ -z "$OMARCHY_USER_NAME" ]; then
    echo "Error: Name cannot be empty"
    exit 1
fi

if [ -z "$OMARCHY_USER_EMAIL" ]; then
    echo "Error: Email cannot be empty"
    exit 1
fi

echo "User identification configured successfully"
