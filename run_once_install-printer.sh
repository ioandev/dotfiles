#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing printer stack (CUPS + drivers)..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed cups

    # splix + samsung-unified-driver live in the AUR
    if command -v yay &>/dev/null; then
        yay -S --noconfirm --needed splix samsung-unified-driver
    elif command -v pamac &>/dev/null; then
        pamac install --no-confirm splix samsung-unified-driver
    else
        echo "Need yay or pamac for AUR (splix, samsung-unified-driver). Install one first."
        exit 1
    fi
else
    sudo apt install -y cups printer-driver-splix
    echo "samsung-unified-driver: not packaged for Debian/Ubuntu, install manually if needed."
fi

echo "Enabling cups service..."
sudo systemctl enable --now cups.service

echo "Printer installation complete!"
