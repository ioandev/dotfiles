#!/bin/bash

# Email / Gmail backup deps: mbsync (isync) + OAuth2 (XOAUTH2) + notmuch.
# See INSTALL doc in mail/ for the full rationale.
set -e

. /etc/os-release 2>/dev/null || true

echo "Installing email tools..."

if [[ "$ID" == "manjaro" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
    # isync(mbsync), SASL framework, gpg for token encryption, notmuch indexer.
    sudo pacman -S --noconfirm --needed isync cyrus-sasl gnupg notmuch

    # XOAUTH2 SASL mechanism Gmail requires - AUR only.
    if ! [[ -f /usr/lib/sasl2/libxoauth2.so ]]; then
        if command -v paru >/dev/null 2>&1; then
            paru -S --noconfirm --needed cyrus-sasl-xoauth2-git
        elif command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm --needed cyrus-sasl-xoauth2-git
        else
            echo "WARNING: no AUR helper (paru/yay) found." >&2
            echo "Install cyrus-sasl-xoauth2-git manually or Gmail XOAUTH2 will fail." >&2
        fi
    fi
else
    sudo apt install -y isync libsasl2-modules gnupg notmuch
    echo "NOTE: Debian has no XOAUTH2 SASL module package - build it manually if needed." >&2
fi

echo "Email tools installation complete!"
