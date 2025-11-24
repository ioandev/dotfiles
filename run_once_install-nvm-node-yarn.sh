#!/bin/bash

set -e

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Load nvm without restarting shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Installing Node.js 25..."
nvm install 25

echo "Setting Node.js 25 as default..."
nvm alias default 25

echo "Verifying Node.js version..."
node -v

echo "Installing Corepack..."
npm install -g corepack

echo "Enabling Yarn via Corepack..."
corepack enable yarn

echo "Verifying Yarn version..."
yarn -v

echo "Setup complete!"
