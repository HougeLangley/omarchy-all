#!/bin/bash

# firewall.sh - Firewall configuration
# Compatible with both Arch and Debian systems

# Check if ufw is already installed
if ! command -v ufw &>/dev/null; then
    case "$DISTRO" in
        arch)
            yay -S --noconfirm --needed ufw ufw-docker

            # Allow nothing in, everything out
            sudo ufw default deny incoming
            sudo ufw default allow outgoing

            # Allow ports for LocalSend
            sudo ufw allow 53317/udp
            sudo ufw allow 53317/tcp

            # Allow SSH in
            sudo ufw allow 22/tcp

            # Allow Docker containers to use DNS on host
            sudo ufw allow in on docker0 to any port 53

            # Turn on the firewall
            sudo ufw enable

            # Turn on Docker protections
            sudo ufw-docker install
            sudo ufw reload
            ;;
        debian)
            # Update package lists first
            sudo apt update
            
            # Install ufw
            sudo apt install -y ufw
            
            # Check if ufw-docker is available in repositories
            if apt list ufw-docker 2>/dev/null | grep -q "ufw-docker"; then
                sudo apt install -y ufw-docker
            else
                echo "Note: ufw-docker not available in repositories, installing manually..."
                # Install ufw-docker from GitHub
                if command -v curl &>/dev/null && command -v git &>/dev/null; then
                    # Try to install via git clone
                    if [ ! -f /usr/local/bin/ufw-docker ]; then
                        sudo curl -L https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker -o /usr/local/bin/ufw-docker
                        sudo chmod +x /usr/local/bin/ufw-docker
                    fi
                else
                    echo "curl or git not available, skipping ufw-docker installation"
                fi
            fi

            # Allow nothing in, everything out
            sudo ufw default deny incoming
            sudo ufw default allow outgoing

            # Allow ports for LocalSend
            sudo ufw allow 53317/udp
            sudo ufw allow 53317/tcp

            # Allow SSH in
            sudo ufw allow 22/tcp

            # Check if docker0 interface exists before configuring
            if ip link show docker0 &>/dev/null; then
                # Allow Docker containers to use DNS on host
                sudo ufw allow in on docker0 to any port 53
            else
                echo "Note: docker0 interface not found, skipping Docker DNS rule"
            fi

            # Turn on the firewall
            echo "y" | sudo ufw enable 2>/dev/null || echo "Note: Firewall enabled interactively, you may need to confirm"

            # Turn on Docker protections if ufw-docker is available
            if command -v ufw-docker &>/dev/null; then
                sudo ufw-docker install
                sudo ufw reload
            else
                echo "Note: ufw-docker not available, Docker-specific firewall rules not configured"
            fi
            ;;
        *)
            echo "Unsupported distribution for firewall configuration"
            exit 1
            ;;
    esac
    
    # Verify firewall status
    if command -v ufw &>/dev/null; then
        echo "Firewall configuration completed"
        sudo ufw status verbose
    else
        echo "Warning: Firewall configuration may have failed"
    fi
else
    echo "UFW is already installed"
    # Show current firewall status
    sudo ufw status verbose
fi
