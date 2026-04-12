#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GNOME portal and setting dark theme..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm xdg-desktop-portal-gnome
else
    sudo apt install -y xdg-desktop-portal-gnome
fi

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

echo "Dark theme setup complete!"
