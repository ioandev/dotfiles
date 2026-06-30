#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Brave Browser..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    yay -S --noconfirm brave-bin
else
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# Brave reads brave-flags.conf; point it at the chezmoi-managed chrome-flags.conf
# so the wayland/dark-mode/vaapi flags apply without duplicating the file.
if [[ -f "$HOME/.config/chrome-flags.conf" ]]; then
    ln -sf ./chrome-flags.conf "$HOME/.config/brave-flags.conf"
fi

echo "Brave Browser installation complete!"
