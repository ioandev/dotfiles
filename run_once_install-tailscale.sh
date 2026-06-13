#!/bin/bash

# tunnel
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Tailscale..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm tailscale
    sudo systemctl enable --now tailscaled
else
    curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "Tailscale installation complete!"
echo ""
echo "NOTE: Run 'sudo tailscale up' to authenticate and connect to your Tailscale network."
