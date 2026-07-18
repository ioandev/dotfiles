#!/bin/bash

set -e

# Load nvm so npm is available (node is managed by nvm on this system)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found (nvm/node not installed yet); skipping lefthook install." >&2
    exit 0
fi

echo "Installing lefthook..."
npm install -g lefthook

echo "Verifying lefthook version..."
lefthook version

echo "lefthook installation complete!"
