# Installation

How to bootstrap these dotfiles on a fresh system. Supported: Manjaro (Arch-based, primary) and PikaOS (Debian-based, **untested**).

## 1. Prerequisites

- `git`, `curl`, `sudo`
- On Manjaro/Arch: an AUR helper — the scripts use both `yay` and `paru`:
  ```bash
  sudo pacman -S --needed base-devel git
  git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si)
  yay -S paru
  ```

## 2. Install chezmoi and apply

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ioandev/dotfiles
```

This will:

1. Generate `~/.config/chezmoi/chezmoi.toml` from `.chezmoi.toml.tmpl` (VS Code diff/merge tooling — no manual setup needed). You'll be asked for a **machine profile** — `full` or `guest`. See [Machine profiles](#machine-profiles) below to choose the right one, preset it non-interactively, or change it later.
2. Run the `run_once_before_*` scripts first: full system update, then podman install. Expect sudo prompts.
3. Apply all dotfiles (`~/.config/niri`, `~/.config/noctalia`, `~/.local/state/noctalia/settings.toml`, `~/.config/hypr`, `~/.zshrc`, etc.).
4. Run every `run_once_install-*.sh` script — this installs the full application set (browsers, dev tools, VMs, etc.) and takes a while on first run.

Some templates are hostname-aware (`dot_config/niri/scripts/screens.yml.tmpl` matches hostnames `pikaoslenovo` / `pikaos`, with a fallback). Set your hostname before running `chezmoi apply` if you want a machine-specific config picked up:

```bash
hostnamectl set-hostname <name>
```

## Machine profiles

At init, chezmoi asks for a **machine profile** (a `promptChoiceOnce` in `.chezmoi.toml.tmpl`). The answer is written to `[data] profile` in `~/.config/chezmoi/chezmoi.toml` and drives what gets installed and how a few configs are templated.

| Profile | Use for |
|---|---|
| `full` | A physical / main machine — installs the complete app set |
| `guest` | A VM guest (GNOME Boxes / SPICE / virt-manager) — leaner and VM-aware |

### Install with a specific profile

Skip the interactive prompt by passing the answer with `--promptChoice` (matched on the prompt text `Machine profile`):

```bash
# Physical / main machine
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --promptChoice "Machine profile=full" ioandev/dotfiles

# VM guest
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --promptChoice "Machine profile=guest" ioandev/dotfiles
```

Omit `--promptChoice` to be asked interactively (the plain command in [step 2](#2-install-chezmoi-and-apply)).

### What the profile changes

| Area | `full` | `guest` |
|---|---|---|
| Noctalia color scheme (`private_dot_local/private_state/noctalia/settings.toml.tmpl`) | Ayu (v5 builtin) | Ember Red (custom palette) |
| SPICE clipboard stack (`run_once_install-spice-guest-tools`) | — | installed |
| niri `spice-vdagent` autostart (`dot_config/niri/…config.kdl.tmpl`) | — | yes |
| hypridle | left as-is | disabled (`run_once_disable-hypridle-if-enabled`) |
| Host-only apps — Android Studio, Steam, OBS, Ollama, ROCm, printer, Discord, EasyEffects, CoolerControl, lm-sensors, Tor Browser, GNOME Boxes, virt-manager, screencast-portal (`.chezmoiignore`) | installed | skipped |

### Change the profile later

`profile` uses `promptChoiceOnce`, so a normal `chezmoi init` / `chezmoi apply` won't re-prompt once it's set. To switch:

```bash
# Option A — edit the stored value, then re-apply
$EDITOR ~/.config/chezmoi/chezmoi.toml      # change the: profile = "…"  line
chezmoi apply

# Option B — re-init non-interactively, then apply
chezmoi init --promptChoice "Machine profile=guest"
chezmoi apply
```

Preview what a switch would touch before committing to it with `chezmoi diff`.

## 3. First-time niri setup

The run_once scripts install supporting pieces (xwayland-satellite, screencast portal, dolphin) and Noctalia itself, but **niri and the rest of the session bits are not installed by any script**. On Manjaro:

```bash
sudo pacman -S --needed niri swww mate-polkit gammastep \
    grim slurp swappy wl-clipboard playerctl \
    hypridle hyprlock
```

Noctalia itself **is** scripted — `run_once_install-noctalia.sh` does the whole thing:

- Picks a repos root: `/repos` if it exists, else `~/Documents/repos` (override with `NOCTALIA_REPOS_ROOT`).
  Checkouts land in `<root>/_external/`.
- Clones the `ioandev/noctalia` and `ioandev/community-plugins` forks, both on the `ioan` branch.
- Symlinks the dev plugins (`cpu-bars`) into `~/.local/share/noctalia-dev-plugins/`, which is the
  `devlocal` plugin source declared under `[plugins]` in `settings.toml`.
- Installs build deps and builds/installs Noctalia to `/usr/local`.
- Removes the v4 packages (`noctalia-shell`, `noctalia-qs`).

It **skips the build** if a v5 binary is already on `$PATH` (e.g. the AUR `noctalia-git`), so it won't
shadow a packaged install with a `/usr/local` build that then drifts. Force with `NOCTALIA_FORCE_BUILD=1`.

Both forks push over the `github-ioandev` SSH alias from `~/.ssh/config`; without that alias the script
clones over HTTPS, which is read-only until you re-point `origin`.

What each is for (all referenced by `~/.config/niri/config.kdl`):

| Package | Role |
|---|---|
| `niri` | The compositor itself |
| `noctalia` (v5, built from source — see above) | Bar, launcher (`Mod+Space`), control center (`Mod+S`), volume/brightness OSD, lock trigger |
| `swww` | Wallpaper daemon (placed in backdrop) |
| `mate-polkit` | Polkit auth agent, spawned at startup |
| `hypridle` / `hyprlock` | Idle daemon + lock screen (configs in `~/.config/hypr/`) |
| `gammastep` | Night-light (`gammastep-indicator` at startup) |
| `grim`, `slurp`, `swappy`, `wl-clipboard` | Screenshot keybinds (`Mod+Shift+S`, `Mod+Print`) |
| `playerctl` | Media keys |

Then:

1. **Log out and pick the "niri" session** in your display manager (GDM/SDDM), or run `niri-session` from a TTY.
2. **Adjust monitor outputs.** `~/.config/niri/config.kdl` hardcodes `DP-1` (3440x1440@165) and `HDMI-A-1` (1920x1080). List your outputs with `niri msg outputs` and edit the `output` blocks to match. Edit via chezmoi so changes survive re-apply:
   ```bash
   chezmoi edit ~/.config/niri/config.kdl
   chezmoi apply
   ```
3. **Reload config**: niri live-reloads `config.kdl` on save. Validate with `niri validate`.
4. **Set a wallpaper**: `swww img <path>`.

### Are you setting up a VM guest?

If this machine is a VM guest (GNOME Boxes / SPICE) — i.e. you picked the `guest` profile at init:

```bash
sudo pacman -S niri kitty        # kitty or terminal you want
```

The clipboard stack (spice-vdagent, xwayland-satellite, wl-clipboard, xclip, clipnotify + the `spice-vdagentd` service) is installed automatically by `run_once_install-spice-guest-tools.sh.tmpl` — it only runs on the `guest` profile. The niri config (guest profile) autostarts `spice-vdagent` and `clipboard-bridge.sh`, giving clipboard sync in both directions.

The `guest` profile automatically adds this to `~/.config/niri/config.kdl` (don't add it by hand — the file is chezmoi-managed and hand edits get overwritten on apply):

```kdl
spawn-at-startup "spice-vdagent"
```

That gives host↔guest clipboard sync: vdagent binds the Xwayland display (xwayland-satellite bridges X11↔Wayland clipboards). Log out/in to the niri session and test copy/paste both directions.

### Key bindings to know

- `Mod+Space` — launcher
- `Mod+S` — control center
- `Mod+Comma` — noctalia settings
- `Mod+E` — Dolphin file manager
- `Mod+O` — overview
- `Mod+Shift+Escape` — full hotkey overlay
- `Mod+Shift+E` / `Ctrl+Alt+Delete` — quit niri
- `Mod+Delete` — escape hatch when a fullscreen app inhibits shortcuts

Keyboard layout is `gb` — change in the `input.keyboard.xkb` block if needed.

### Noctalia v5 config layout

v5 is a native C++/Wayland shell (v4 was Quickshell-based). Its config lives in two layers,
and only some of it belongs under chezmoi:

| Path | What it is | Tracked |
|---|---|---|
| `~/.local/state/noctalia/settings.toml` | The layer the settings GUI writes. Overrides everything below it. | **yes** (`private_dot_local/private_state/noctalia/settings.toml.tmpl`) |
| `~/.config/noctalia/palettes/*.json` | Custom color palettes, ported from the v4 `colorschemes/` dir | **yes** |
| `~/.config/noctalia/*.toml` | Optional hand-authored declarative config; every `*.toml` here is merged alphabetically | no — not used by this setup |
| `~/.local/state/noctalia/` (everything else) | Clipboard history, notification history, cloned plugin repos, telemetry id, caches | no (`.chezmoiignore`) |
| `~/.config/niri/noctalia.kdl`, `~/.config/kitty/themes/noctalia.conf` | Generated by Noctalia's builtin theme templates on every scheme change | no (seeded once via `create_`) |

Because `settings.toml` is the GUI-written layer, it goes dirty in `chezmoi status` whenever you
change a setting in the UI — that's expected. Re-capture with `chezmoi re-add ~/.local/state/noctalia/settings.toml`,
but check the diff first: it also accumulates per-monitor keys (output names, lockscreen widget
coordinates) that are specific to the machine you captured it on.

Handy IPC verbs (the v4 `qs -c noctalia-shell ipc call <target> <method>` form is gone):

```bash
noctalia msg panel-toggle launcher     # or: control-center
noctalia msg settings-toggle
noctalia msg session lock              # lock | suspend | logout | reboot | shutdown
noctalia msg config-reload             # live-reload settings.toml, no restart
noctalia msg --help                    # full verb list
```

## 4. Post-install checks

- `chezmoi doctor` — sanity check.
- Run `chezmoi apply` again if any run_once script failed mid-way (state is per-script; completed ones won't re-run).
- To force all run_once scripts to re-run: `chezmoi state delete-bucket --bucket=scriptState`.

## Known issues

See [README.md](README.md) — notably Android Studio on niri/Wayland needs a window rule plus `-Dawt.toolkit.name=WLToolkit`.
