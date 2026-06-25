#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing CoolerControl..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    if command -v yay &>/dev/null; then
        yay -S --noconfirm --needed coolercontrol
    elif command -v pamac &>/dev/null; then
        pamac install --no-confirm coolercontrol
    else
        echo "Need yay or pamac for AUR. Install one first."
        exit 1
    fi
else
    echo "CoolerControl: see https://gitlab.com/coolercontrol/coolercontrol for non-Arch install."
    exit 1
fi

echo "Enabling coolercontrold service..."
sudo systemctl enable --now coolercontrold.service

echo "CoolerControl installation complete!"
