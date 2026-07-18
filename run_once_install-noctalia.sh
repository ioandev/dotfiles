#!/bin/bash

set -e

# Noctalia v5 - the native C++/Wayland rewrite. Built from the personal fork's `ioan`
# branch rather than installed from the AUR, because that branch carries local work
# (taskbar/niri workspace labels, cpu-bars plugin) that upstream doesn't have. The
# matching community-plugins fork is cloned alongside it and symlinked into Noctalia's
# "devlocal" plugin source.
#
# AUR alternatives, for reference: `noctalia` (tagged release, currently 5.0.0_beta.3)
# or `noctalia-git` (upstream main). Neither has the fork's commits.
#
# Env overrides: NOCTALIA_REPOS_ROOT, NOCTALIA_REPO, NOCTALIA_PLUGINS_REPO,
#                NOCTALIA_BRANCH, NOCTALIA_FORCE_BUILD

. /etc/os-release 2>/dev/null || true

BRANCH="${NOCTALIA_BRANCH:-ioan}"

# Plugins symlinked from the community-plugins checkout into the devlocal source dir.
# Must match the ids enabled under [plugins] in settings.toml.
DEV_PLUGINS=(cpu-bars)
DEV_PLUGIN_DIR="$HOME/.local/share/noctalia-dev-plugins"

if [[ "$ID" != "manjaro" ]] && [[ "$ID_LIKE" != *"arch"* ]]; then
    echo "Noctalia install is only wired up for Arch-based distros; skipping." >&2
    echo "Build deps for other distros: https://github.com/noctalia-dev/noctalia#dependencies" >&2
    exit 0
fi

# ---------------------------------------------------------------- repo locations

# Checkouts live under <repos-root>/_external. This box uses /repos; other machines keep
# the same tree under ~/Documents/repos.
if [ -n "${NOCTALIA_REPOS_ROOT:-}" ]; then
    REPOS_ROOT="$NOCTALIA_REPOS_ROOT"
elif [ -d /repos ]; then
    REPOS_ROOT=/repos
elif [ -d "$HOME/Documents/repos" ]; then
    REPOS_ROOT="$HOME/Documents/repos"
else
    REPOS_ROOT="$HOME/Documents/repos"
    echo "No repos root found; creating $REPOS_ROOT"
fi

EXTERNAL="$REPOS_ROOT/_external"
REPO="${NOCTALIA_REPO:-$EXTERNAL/noctalia}"
PLUGINS_REPO="${NOCTALIA_PLUGINS_REPO:-$EXTERNAL/community-plugins}"

echo "Using repos root: $REPOS_ROOT"

# The forks' origins use a per-account SSH alias (github-ioandev) defined in ~/.ssh/config.
# Fall back to HTTPS when that alias isn't set up on this machine - clones still work, they
# just can't push until you re-point origin at the SSH URL.
if grep -qs 'Host github-ioandev' "$HOME/.ssh/config"; then
    git_url() { printf 'git@github-ioandev:ioandev/%s.git\n' "$1"; }
else
    git_url() { printf 'https://github.com/ioandev/%s.git\n' "$1"; }
    echo "note: no 'github-ioandev' SSH alias found; cloning over HTTPS (read-only)." >&2
fi

# clone_or_update <target-dir> <github-repo-name> <upstream-url-or-empty>
clone_or_update() {
    local dir="$1" name="$2" upstream="$3"
    if [ ! -d "$dir/.git" ]; then
        local parent
        parent="$(dirname "$dir")"
        if [ ! -d "$parent" ]; then
            mkdir -p "$parent" 2>/dev/null || { sudo mkdir -p "$parent"; sudo chown "$USER:$USER" "$parent"; }
        fi
        echo "Cloning $name into $dir..."
        git clone "$(git_url "$name")" "$dir"
        [ -n "$upstream" ] && git -C "$dir" remote add upstream "$upstream" 2>/dev/null || true
    else
        echo "$name already present at $dir; fetching..."
        git -C "$dir" fetch --all --prune
    fi
    git -C "$dir" checkout "$BRANCH"
}

# ---------------------------------------------------------------- v4 teardown

# v4 was Quickshell-based (`qs -c noctalia-shell`); v5 ships its own binary and shares no
# config with it. Leaving v4 installed just means a stale shell on $PATH.
for pkg in noctalia-shell noctalia-qs; do
    if pacman -Qq "$pkg" >/dev/null 2>&1; then
        echo "Removing Noctalia v4 package: $pkg"
        sudo pacman -Rns --noconfirm "$pkg" || \
            echo "warning: could not remove $pkg (something may still depend on it)" >&2
    fi
done

# ---------------------------------------------------------------- dev plugins

clone_or_update "$PLUGINS_REPO" "community-plugins" \
    "https://github.com/noctalia-dev/community-plugins.git"

# Noctalia's [[plugins.source]] named "devlocal" points at DEV_PLUGIN_DIR (kind = "path").
# One symlink per plugin, so only the plugins being worked on are exposed - not the whole
# ~30-plugin catalog.
mkdir -p "$DEV_PLUGIN_DIR"
for plugin in "${DEV_PLUGINS[@]}"; do
    if [ -d "$PLUGINS_REPO/$plugin" ]; then
        ln -sfn "$PLUGINS_REPO/$plugin" "$DEV_PLUGIN_DIR/$plugin"
        echo "Linked dev plugin: $plugin -> $PLUGINS_REPO/$plugin"
    else
        echo "warning: no such plugin '$plugin' in $PLUGINS_REPO" >&2
    fi
done

# ---------------------------------------------------------------- already installed?

# Don't build over a machine that already has v5 (e.g. the AUR noctalia-git package).
# `just install` lands in /usr/local/bin and would shadow a packaged /usr/bin/noctalia
# with a build that then drifts silently.
if [ "${NOCTALIA_FORCE_BUILD:-0}" != "1" ] && command -v noctalia >/dev/null 2>&1; then
    have="$(noctalia --version 2>&1 | head -1)"
    if [[ "$have" == *"v5."* ]]; then
        echo "Noctalia v5 already installed ($have) at $(command -v noctalia); skipping build."
        echo "Re-run with NOCTALIA_FORCE_BUILD=1 to build the fork from source anyway."
        exit 0
    fi
fi

# ---------------------------------------------------------------- build deps

echo "Installing Noctalia v5 build dependencies..."
sudo pacman -S --noconfirm --needed \
    meson gcc just git \
    wayland wayland-protocols \
    libglvnd freetype2 fontconfig \
    cairo pango harfbuzz \
    libxkbcommon glib2 \
    sdbus-cpp libpipewire wireplumber polkit \
    pam curl libwebp librsvg \
    libqalculate libxml2 \
    md4c tomlplusplus \
    nlohmann-json stb \
    jemalloc

# ---------------------------------------------------------------- build + install

clone_or_update "$REPO" "noctalia" "https://github.com/noctalia-dev/noctalia.git"

echo "Building Noctalia (release) - this takes a while..."
cd "$REPO"
just configure release
just build release

echo "Installing Noctalia to /usr/local..."
sudo "$(command -v just)" install release

echo "Noctalia $(noctalia --version 2>&1 | head -1) installed."
