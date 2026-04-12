#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing DBeaver..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm dbeaver
else
    # Download latest DBeaver .deb package
    wget -O /tmp/dbeaver.deb https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    sudo apt install -y /tmp/dbeaver.deb
    rm /tmp/dbeaver.deb
fi

echo "DBeaver installation complete!"

echo "DBeaver installation complete!"
