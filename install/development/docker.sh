#!/bin/bash

# docker.sh - Docker installation and configuration
# Compatible with both Arch and Debian systems

# Install Docker based on distribution
case "$DISTRO" in
    arch)
        yay -S --noconfirm --needed docker docker-compose docker-buildx

        # Limit log size to avoid running out of disk
        sudo mkdir -p /etc/docker
        echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

        # Start Docker automatically
        sudo systemctl enable docker

        # Give this user privileged Docker access
        sudo usermod -aG docker ${USER}

        # Prevent Docker from preventing boot for network-online.target
        sudo mkdir -p /etc/systemd/system/docker.service.d
        sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

        sudo systemctl daemon-reload
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Install Docker using official Docker repository for better compatibility
        # First install prerequisites
        sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Update package index again
        sudo apt update
        
        # Install Docker Engine and related tools from official repository
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
        
        # Limit log size to avoid running out of disk
        sudo mkdir -p /etc/docker
        echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

        # Start Docker automatically
        sudo systemctl enable docker
        sudo systemctl start docker

        # Give this user privileged Docker access
        # Check if docker group exists, create if not
        if ! getent group docker > /dev/null 2>&1; then
            sudo groupadd docker
        fi
        sudo usermod -aG docker ${USER}

        # Prevent Docker from preventing boot for network-online.target
        sudo mkdir -p /etc/systemd/system/docker.service.d
        sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

        sudo systemctl daemon-reload
        ;;
    *)
        echo "Unsupported distribution for Docker installation"
        exit 1
        ;;
esac

# Verify Docker installation
if command -v docker &>/dev/null; then
    echo "Docker installation completed successfully"
    # Test Docker access
    if docker version &>/dev/null; then
        echo "Docker is running and accessible"
    else
        echo "Docker is installed but may require user logout/login to access"
    fi
else
    echo "Warning: Docker installation may have failed"
fi
