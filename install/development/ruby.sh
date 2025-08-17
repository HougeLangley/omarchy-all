#!/bin/bash

# ruby.sh - Ruby installation and configuration
# Compatible with both Arch and Debian systems

case "$DISTRO" in
    arch)
        # Install Ruby using gcc-14 for compatibility
        yay -S --noconfirm --needed gcc14
        mise settings set ruby.ruby_build_opts "CC=gcc-14 CXX=g++-14"

        # Trust .ruby-version
        mise settings add idiomatic_version_file_enable_tools ruby
        ;;
    debian)
        # Update package lists first
        sudo apt update
        
        # Check if gcc-14 is available, otherwise use default gcc
        if apt list gcc-14 2>/dev/null | grep -q "gcc-14"; then
            sudo apt install -y gcc-14 g++-14
            mise settings set ruby.ruby_build_opts "CC=gcc-14 CXX=g++-14"
        else
            # Use default gcc version available in Debian
            sudo apt install -y build-essential
            GCC_VERSION=$(gcc --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -c 1)
            if [ -n "$GCC_VERSION" ] && [ "$GCC_VERSION" -ge 9 ]; then
                # Use the default gcc if version is 9 or higher
                mise settings set ruby.ruby_build_opts "CC=gcc CXX=g++"
            else
                echo "Warning: GCC version may be too old for latest Ruby versions"
                # Fallback to basic build options
                mise settings set ruby.ruby_build_opts ""
            fi
        fi

        # Install Ruby development dependencies
        sudo apt install -y ruby-dev ruby-bundler rubygems
        
        # Install common Ruby build dependencies
        sudo apt install -y libssl-dev libreadline-dev zlib1g-dev libyaml-dev libsqlite3-dev

        # Trust .ruby-version if mise is available
        if command -v mise &>/dev/null; then
            mise settings add idiomatic_version_file_enable_tools ruby
        else
            echo "Note: mise not available, .ruby-version trust configuration skipped"
        fi
        ;;
    *)
        echo "Unsupported distribution for Ruby installation"
        exit 1
        ;;
esac

# Verify Ruby installation tools are available
if command -v ruby &>/dev/null; then
    echo "Ruby installation tools configured successfully"
    ruby --version
else
    echo "Ruby installation tools configuration completed"
    echo "Note: Ruby will be installed via mise when needed"
fi
