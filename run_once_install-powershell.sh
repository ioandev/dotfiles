#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing PowerShell..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm powershell-bin
else
    wget -q "https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
    sudo dpkg -i /tmp/packages-microsoft-prod.deb
    rm /tmp/packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y powershell
fi

echo "PowerShell installation complete!"
