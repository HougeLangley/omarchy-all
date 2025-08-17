#!/bin/bash

# migrations.sh - Handle migration state tracking
# Compatible with both Arch and Debian systems

omarchy_migrations_state_path=~/.local/state/omarchy/migrations
mkdir -p "$omarchy_migrations_state_path"

# Check if migrations directory exists and has files
if [ -d ~/.local/share/omarchy/migrations ] && [ -n "$(ls -A ~/.local/share/omarchy/migrations/*.sh 2>/dev/null)" ]; then
    for file in ~/.local/share/omarchy/migrations/*.sh; do
        # Check if file exists (in case no .sh files are found)
        if [ -f "$file" ]; then
            touch "$omarchy_migrations_state_path/$(basename "$file")"
        fi
    done
else
    echo "No migrations found or migrations directory does not exist"
fi

echo "Migration state tracking initialized"
