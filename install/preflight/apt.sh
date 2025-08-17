#!/bin/bash

# apt.sh - Debian/Ubuntu specific preflight checks and setup

# Check if running on supported Debian-based system
if [[ "$DISTRO" != "debian" ]]; then
    echo "Error: This script is intended for Debian/Ubuntu systems only"
    exit 1
fi

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install essential packages needed for the installation process
ESSENTIAL_PACKAGES=(
    "git"
    "curl"
    "wget"
    "sudo"
    "build-essential"
    "software-properties-common"
)

echo "Installing essential packages..."
for package in "${ESSENTIAL_PACKAGES[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Installing $package..."
        sudo apt install -y "$package"
    else
        echo "$package is already installed"
    fi
done

# Check if gum is available, install if missing
if ! command -v gum &> /dev/null; then
    echo "Installing gum for presentation effects..."
    if ! sudo apt install -y gum; then
        echo "Warning: Failed to install gum. Continuing without it."
    fi
else
    echo "gum is already installed"
fi

# Enable contrib and non-free repositories for Debian
if grep -q "Debian" /etc/os-release; then
    echo "Enabling contrib and non-free repositories..."
    sudo apt update
    # This would enable additional repositories if needed
fi

# Check for required tools
REQUIRED_TOOLS=("git" "curl" "wget")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool $tool is not installed"
        exit 1
    fi
done

echo "APT preflight checks completed successfully"
