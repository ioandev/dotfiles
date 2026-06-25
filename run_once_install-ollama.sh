#!/bin/bash

# local LLM runtime
set -e

. /etc/os-release 2>/dev/null || true

if command -v ollama >/dev/null 2>&1; then
    echo "Ollama already installed, skipping install."
else
    echo "Installing Ollama..."
    if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
        sudo pacman -S --noconfirm ollama
    else
        curl -fsSL https://ollama.com/install.sh | sh
    fi
fi

# Raise parallel request slots (equivalent of `systemctl edit ollama.service`).
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null <<'EOF'
[Service]
Environment="OLLAMA_NUM_PARALLEL=10"
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
sudo systemctl restart ollama

# Verify systemd merged the override.
if systemctl show -p Environment ollama | grep -q "OLLAMA_NUM_PARALLEL=10"; then
    echo "OK: OLLAMA_NUM_PARALLEL=10 is set."
else
    echo "ERROR: OLLAMA_NUM_PARALLEL not set - check 'systemctl show -p Environment ollama'." >&2
    exit 1
fi

echo "Ollama installed"
