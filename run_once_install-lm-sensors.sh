#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing lm_sensors..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed lm_sensors
else
    sudo apt install -y lm-sensors
fi

echo "Detecting sensors (auto-accept defaults)..."
sudo sensors-detect --auto

echo "lm_sensors installation complete!"
