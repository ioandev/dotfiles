#!/bin/bash

. /etc/os-release 2>/dev/null || true

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm openssl pkgconf
else
    sudo apt-get install -y libssl-dev pkg-config
fi

echo "OpenSSL development packages installed successfully"
