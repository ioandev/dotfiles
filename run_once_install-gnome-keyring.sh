#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GNOME Keyring..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm gnome-keyring libsecret
else
    sudo apt update
    sudo apt install -y gnome-keyring libsecret-1-0 libsecret-1-dev
fi

echo "GNOME Keyring installation complete!"
echo ""
echo "NOTE: To configure VS Code to use GNOME Keyring:"
echo "1. Open VS Code"
echo "2. Go to File > Preferences > Settings (or use Ctrl+,)"
echo "3. Search for 'password-store'"
echo "4. Set 'Password Store' to 'gnome-libsecret'"
echo ""
echo "Alternatively, edit ~/.config/Code/User/settings.json and add:"
echo '  "password-store": "gnome-libsecret"'
