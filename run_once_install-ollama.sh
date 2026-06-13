#!/bin/bash

# local LLM runtime
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing Ollama..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    sudo pacman -S --noconfirm ollama
else
    curl -fsSL https://ollama.com/install.sh | sh
fi

echo "Configuring Ollama to listen on 0.0.0.0..."

OVERRIDE_DIR=/etc/systemd/system/ollama.service.d
OVERRIDE_FILE=$OVERRIDE_DIR/override.conf

sudo mkdir -p "$OVERRIDE_DIR"
sudo tee "$OVERRIDE_FILE" >/dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ollama
sudo systemctl restart ollama

echo "Ollama installed and listening on 0.0.0.0"
