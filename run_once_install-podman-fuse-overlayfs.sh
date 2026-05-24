#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing fuse-overlayfs..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm fuse-overlayfs
else
    sudo apt install -y fuse-overlayfs
fi

if [ -f /etc/containers/storage.conf ]; then
    echo "Enabling fuse-overlayfs in storage.conf..."
    sudo sed -i 's|^#\s*mount_program\s*=.*|mount_program = "/usr/bin/fuse-overlayfs"|' /etc/containers/storage.conf
fi

echo "fuse-overlayfs installation complete!"
