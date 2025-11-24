#!/bin/bash

# Set EDITOR to code (VS Code)
if ! grep -q "export EDITOR=code" ~/.bashrc; then
    echo 'export EDITOR=code' >> ~/.bashrc
    echo "Added EDITOR=code to ~/.bashrc"
fi

# Also set it for the current session
export EDITOR=code
echo "EDITOR is now set to: $EDITOR"
