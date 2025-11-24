#!/bin/bash

set -e

echo "Installing GNOME Keyring..."
sudo apt update
sudo apt install -y gnome-keyring libsecret-1-0 libsecret-1-dev

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
