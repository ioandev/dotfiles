#!/bin/bash

set -e

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Load nvm without restarting shell (check both common install locations)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"
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

echo "Adding nvm init to .bashrc..."
BASHRC="$HOME/.bashrc"
if ! grep -qF "# >>> nvm initialize >>>" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# >>> nvm initialize >>>
export NVM_DIR="$HOME/.nvm"
[ -d "$HOME/.config/nvm" ] && export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
# <<< nvm initialize <<<
EOF
else
    echo "nvm init already in .bashrc, skipping."
fi

echo "Setup complete!"
