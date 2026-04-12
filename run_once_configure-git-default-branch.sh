#!/bin/bash

set -e

echo "Configuring git default branch to 'main'..."

git config --global init.defaultBranch main

echo "Git default branch configured!"
