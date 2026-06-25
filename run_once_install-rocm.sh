#!/bin/bash

# ROCm HIP SDK + PyTorch with ROCm backend (AMD GPU compute).
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing ROCm + PyTorch (ROCm)..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    # sudo pacman -S --noconfirm --needed rocm-hip-sdk python-pytorch-rocm
echo "Skippind due to size: ROCm + PyTorch (ROCm)..."
else
    echo "ERROR: ROCm packages here target Arch only." >&2
    exit 1
fi

echo "ROCm installation complete!"
