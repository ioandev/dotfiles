#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing and enabling Bluetooth..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm bluez bluez-utils
else
    sudo apt install -y bluez bluez-tools
fi

sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service

echo "Bluetooth setup complete!"
