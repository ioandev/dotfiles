#!/bin/bash

# just command runner - https://github.com/casey/just
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing just..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm --needed just
else
    sudo apt install -y just
fi

echo "Installing shell completions..."

# zsh
if command -v zsh >/dev/null 2>&1; then
    sudo mkdir -p /usr/share/zsh/site-functions
    just --completions zsh | sudo tee /usr/share/zsh/site-functions/_just >/dev/null
fi

# bash
if command -v bash >/dev/null 2>&1; then
    sudo mkdir -p /usr/share/bash-completion/completions
    just --completions bash | sudo tee /usr/share/bash-completion/completions/just >/dev/null
fi

echo "just installation complete!"
