#!/bin/bash

# mimetypes.sh - MIME types configuration
# Compatible with both Arch and Debian systems

# Update desktop database
if command -v update-desktop-database &>/dev/null; then
    update-desktop-database ~/.local/share/applications 2>/dev/null || echo "Note: Failed to update desktop database"
else
    echo "Note: update-desktop-database not available"
fi

# Check if xdg-mime is available
if ! command -v xdg-mime &>/dev/null; then
    echo "xdg-mime not available, skipping MIME type configuration"
    exit 0
fi

# Open all images with imv
IMAGE_MIME_TYPES=(
    "image/png"
    "image/jpeg"
    "image/gif"
    "image/webp"
    "image/bmp"
    "image/tiff"
)

for mime_type in "${IMAGE_MIME_TYPES[@]}"; do
    if xdg-mime query default "$mime_type" 2>/dev/null | grep -q "imv.desktop"; then
        echo "Image MIME type $mime_type already configured for imv"
    else
        xdg-mime default imv.desktop "$mime_type" 2>/dev/null || echo "Warning: Failed to set imv for $mime_type"
    fi
done

# Open PDFs with the Document Viewer
PDF_MIME_TYPE="application/pdf"
case "$DISTRO" in
    arch)
        PDF_VIEWER="org.gnome.Evince.desktop"
        ;;
    debian)
        # Check if Evince is available, otherwise use default PDF viewer
        if [ -f "/usr/share/applications/org.gnome.Evince.desktop" ]; then
            PDF_VIEWER="org.gnome.Evince.desktop"
        elif [ -f "/usr/share/applications/evince.desktop" ]; then
            PDF_VIEWER="evince.desktop"
        else
            # Try to find available PDF viewer
            AVAILABLE_PDF_VIEWERS=("org.gnome.Evince.desktop" "evince.desktop" "atril.desktop" "okular.desktop")
            PDF_VIEWER=""
            for viewer in "${AVAILABLE_PDF_VIEWERS[@]}"; do
                if [ -f "/usr/share/applications/$viewer" ]; then
                    PDF_VIEWER="$viewer"
                    break
                fi
            done
            
            if [ -z "$PDF_VIEWER" ]; then
                echo "Note: No suitable PDF viewer found"
                PDF_VIEWER="org.gnome.Evince.desktop"  # Default fallback
            fi
        fi
        ;;
    *)
        PDF_VIEWER="org.gnome.Evince.desktop"
        ;;
esac

if [ -n "$PDF_VIEWER" ]; then
    if xdg-mime query default "$PDF_MIME_TYPE" 2>/dev/null | grep -q "$PDF_VIEWER"; then
        echo "PDF MIME type already configured for $PDF_VIEWER"
    else
        xdg-mime default "$PDF_VIEWER" "$PDF_MIME_TYPE" 2>/dev/null || echo "Warning: Failed to set $PDF_VIEWER for PDFs"
    fi
else
    echo "Note: Skipping PDF viewer configuration"
fi

# Use Chromium as the default browser
BROWSER_DESKTOP_FILE=""
case "$DISTRO" in
    arch)
        BROWSER_DESKTOP_FILE="chromium.desktop"
        ;;
    debian)
        # Check available Chromium/Chrome options
        if [ -f "/usr/share/applications/chromium.desktop" ]; then
            BROWSER_DESKTOP_FILE="chromium.desktop"
        elif [ -f "/usr/share/applications/google-chrome.desktop" ]; then
            BROWSER_DESKTOP_FILE="google-chrome.desktop"
        elif [ -f "/usr/share/applications/chromium-browser.desktop" ]; then
            BROWSER_DESKTOP_FILE="chromium-browser.desktop"
        else
            echo "Note: Chromium/Chrome desktop file not found"
            BROWSER_DESKTOP_FILE="chromium.desktop"  # Default fallback
        fi
        ;;
    *)
        BROWSER_DESKTOP_FILE="chromium.desktop"
        ;;
esac

# Configure web browser
if [ -n "$BROWSER_DESKTOP_FILE" ] && [ -f "/usr/share/applications/$BROWSER_DESKTOP_FILE" ]; then
    if command -v xdg-settings &>/dev/null; then
        CURRENT_BROWSER=$(xdg-settings get default-web-browser 2>/dev/null || echo "")
        if [ "$CURRENT_BROWSER" != "$BROWSER_DESKTOP_FILE" ]; then
            xdg-settings set default-web-browser "$BROWSER_DESKTOP_FILE" 2>/dev/null || echo "Warning: Failed to set default web browser"
        else
            echo "Default web browser already set to $BROWSER_DESKTOP_FILE"
        fi
    else
        echo "Note: xdg-settings not available"
    fi
    
    # Set MIME types for web protocols
    WEB_PROTOCOLS=("x-scheme-handler/http" "x-scheme-handler/https")
    for protocol in "${WEB_PROTOCOLS[@]}"; do
        if xdg-mime query default "$protocol" 2>/dev/null | grep -q "$BROWSER_DESKTOP_FILE"; then
            echo "Web protocol $protocol already configured for $BROWSER_DESKTOP_FILE"
        else
            xdg-mime default "$BROWSER_DESKTOP_FILE" "$protocol" 2>/dev/null || echo "Warning: Failed to set $BROWSER_DESKTOP_FILE for $protocol"
        fi
    done
else
    echo "Note: Browser desktop file $BROWSER_DESKTOP_FILE not found, skipping browser configuration"
fi

# Open video files with mpv
VIDEO_MIME_TYPES=(
    "video/mp4"
    "video/x-msvideo"
    "video/x-matroska"
    "video/x-flv"
    "video/x-ms-wmv"
    "video/mpeg"
    "video/ogg"
    "video/webm"
    "video/quicktime"
    "video/3gpp"
    "video/3gpp2"
    "video/x-ms-asf"
    "video/x-ogm+ogg"
    "video/x-theora+ogg"
    "application/ogg"
)

for mime_type in "${VIDEO_MIME_TYPES[@]}"; do
    if xdg-mime query default "$mime_type" 2>/dev/null | grep -q "mpv.desktop"; then
        echo "Video MIME type $mime_type already configured for mpv"
    else
        xdg-mime default mpv.desktop "$mime_type" 2>/dev/null || echo "Warning: Failed to set mpv for $mime_type"
    fi
done

# Additional Debian-specific MIME type setup
case "$DISTRO" in
    debian)
        # Update MIME database if available
        if command -v update-mime-database &>/dev/null; then
            update-mime-database ~/.local/share/mime 2>/dev/null || true
        fi
        
        # Check if desktop files exist
        DESKTOP_FILES_TO_CHECK=("imv.desktop" "mpv.desktop" "$BROWSER_DESKTOP_FILE" "$PDF_VIEWER")
        for desktop_file in "${DESKTOP_FILES_TO_CHECK[@]}"; do
            if [ -n "$desktop_file" ] && [ ! -f "/usr/share/applications/$desktop_file" ]; then
                echo "Note: Desktop file $desktop_file not found"
            fi
        done
        ;;
esac

echo "MIME types configuration completed"
