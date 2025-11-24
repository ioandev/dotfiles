#!/bin/bash

# Install Rust using rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source cargo environment for current session
source "$HOME/.cargo/env"

echo "Rust installed successfully"
rustc --version
cargo --version
