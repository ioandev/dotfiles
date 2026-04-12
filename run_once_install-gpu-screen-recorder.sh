#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing GPU Screen Recorder..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm gpu-screen-recorder
else
    sudo apt install -y gpu-screen-recorder
fi

echo "GPU Screen Recorder installation complete!"
