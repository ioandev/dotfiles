#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Google Chrome..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm google-chrome
else
    wget -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y /tmp/google-chrome-stable.deb
    rm /tmp/google-chrome-stable.deb
fi

echo "Google Chrome installation complete!"
