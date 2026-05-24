#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing yt-dlp..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm yt-dlp
else
    sudo apt install -y yt-dlp
fi

echo "yt-dlp installation complete!"
yt-dlp --version
