#!/bin/bash

set -e

. /etc/os-release 2>/dev/null || true

echo "Installing stress-ng..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -Sy --noconfirm stress-ng
else
    sudo apt install -y stress-ng
fi

echo "stress-ng installation complete!"
echo ""
echo "Usage:"
echo "  stress-ng --cpu 0 --timeout 60s                       # all cores, 60s"
echo "  stress-ng --cpu 0 --cpu-method matrixprod --timeout 60s  # heavy FPU load"
echo "  stress-ng --cpu 0 --metrics --timeout 60s             # print stats after"
echo "  stress-ng --cpu 4 --timeout 30s                       # 4 cores, 30s"
