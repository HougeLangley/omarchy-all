#!/bin/bash

# webapps.sh - Web applications installation
# Compatible with both Arch and Debian systems

# Check if omarchy-webapp-install function is available
if ! command -v omarchy-webapp-install &>/dev/null; then
    echo "omarchy-webapp-install function not found, skipping web app installation"
    exit 0
fi

if [ -z "$OMARCHY_BARE" ]; then
    # Define web apps to install
    WEB_APPS=(
        "HEY|https://app.hey.com|https://www.hey.com/assets/images/general/hey.png"
        "Basecamp|https://launchpad.37signals.com|https://basecamp.com/assets/images/general/basecamp.png"
        "WhatsApp|https://web.whatsapp.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/whatsapp.png"
        "Google Photos|https://photos.google.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-photos.png"
        "Google Contacts|https://contacts.google.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-contacts.png"
        "Google Messages|https://messages.google.com/web/conversations|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/google-messages.png"
        "ChatGPT|https://chatgpt.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png"
        "YouTube|https://youtube.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png"
        "GitHub|https://github.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png"
        "X|https://x.com/|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/x-light.png"
        "Figma|https://figma.com/|https://www.veryicon.com/download/png/application/app-icon-7/figma-1?s=256"
        "Discord|https://discord.com/channels/@me|https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/discord.png"
    )
    
    # Install web apps
    for app in "${WEB_APPS[@]}"; do
        name=$(echo "$app" | cut -d'|' -f1)
        url=$(echo "$app" | cut -d'|' -f2)
        icon=$(echo "$app" | cut -d'|' -f3)
        
        echo "Installing web app: $name"
        
        # Check if the web app is already installed
        if [ -d "$HOME/.local/share/applications" ] && ls "$HOME/.local/share/applications"/*"$name"* 2>/dev/null 1>&2; then
            echo "Web app $name already installed, skipping"
            continue
        fi
        
        # Call the omarchy-webapp-install function
        if omarchy-webapp-install "$name" "$url" "$icon"; then
            echo "Successfully installed web app: $name"
        else
            echo "Warning: Failed to install web app: $name"
        fi
    done
    
    # Additional Debian-specific web app setup
    case "$DISTRO" in
        debian)
            # Check if native web app tools are available
            if ! command -v nativefier &>/dev/null; then
                echo "Note: nativefier not available for advanced web app packaging on Debian"
            fi
            
            # Ensure desktop database is updated
            if command -v update-desktop-database &>/dev/null; then
                update-desktop-database ~/.local/share/applications 2>/dev/null || true
            fi
            
            # Check if mime database update is needed
            if command -v update-mime-database &>/dev/null; then
                update-mime-database ~/.local/share/mime 2>/dev/null || true
            fi
            ;;
    esac
else
    echo "OMARCHY_BARE is set, skipping web app installation"
fi

echo "Web applications installation completed"
