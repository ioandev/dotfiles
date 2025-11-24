#!/bin/bash

set -e

echo "Installing GNOME portal and setting dark theme..."
sudo apt install -y xdg-desktop-portal-gnome
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

echo "Dark theme setup complete!"
