#!/bin/bash

# Python 3.12 - parallel install alongside system python (Arch ships 3.14).
# Provides the `python3.12` binary for projects pinned to 3.12.
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Python 3.12..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    # python312 is AUR only - system `python` is the latest release.
    if command -v paru >/dev/null 2>&1; then
        paru -S --noconfirm --needed python312
    elif command -v yay >/dev/null 2>&1; then
        yay -S --noconfirm --needed python312
    else
        echo "ERROR: no AUR helper (paru/yay) found - cannot install python312." >&2
        exit 1
    fi
else
    sudo apt install -y python3.12 python3.12-venv
fi

echo "Python 3.12 installation complete! Run with 'python3.12'."
