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

1. Generate `~/.config/chezmoi/chezmoi.toml` from `.chezmoi.toml.tmpl` (VS Code diff/merge tooling — no manual setup needed). You'll be asked for a **machine profile**:
   - `full` — everything
   - `guest` — for VMs; skips Android Studio (see `.chezmoiignore`)

   The answer is stored in `[data]` in `~/.config/chezmoi/chezmoi.toml`. To change it later, edit that file and re-run `chezmoi apply`, or re-init non-interactively: `chezmoi init --promptChoice "Machine profile=guest"`.
2. Run the `run_once_before_*` scripts first: full system update, then podman install. Expect sudo prompts.
3. Apply all dotfiles (`~/.config/niri`, `~/.config/noctalia`, `~/.config/hypr`, `~/.zshrc`, etc.).
4. Run every `run_once_install-*.sh` script — this installs the full application set (browsers, dev tools, VMs, etc.) and takes a while on first run.

Some templates are hostname-aware (`dot_config/niri/scripts/screens.yml.tmpl` matches hostnames `pikaoslenovo` / `pikaos`, with a fallback). Set your hostname before running `chezmoi apply` if you want a machine-specific config picked up:

```bash
hostnamectl set-hostname <name>
```

## 3. First-time niri setup

The run_once scripts install supporting pieces (xwayland-satellite, screencast portal, dolphin), but **niri itself and the shell around it are not installed by any script**. On Manjaro:

```bash
sudo pacman -S --needed niri swww mate-polkit gammastep \
    grim slurp swappy wl-clipboard playerctl \
    hypridle hyprlock
yay -S noctalia-shell   # Quickshell-based bar/launcher used by the config ("qs -c noctalia-shell")
```

What each is for (all referenced by `~/.config/niri/config.kdl`):

| Package | Role |
|---|---|
| `niri` | The compositor itself |
| `noctalia-shell` (+ `quickshell` dep) | Bar, launcher (`Mod+Space`), control center (`Mod+S`), volume/brightness OSD, lock trigger |
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
sudo pacman -S spice-vdagent xwayland-satellite wl-clipboard xclip clipnotify
sudo systemctl enable --now spice-vdagentd
```

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

## 4. Post-install checks

- `chezmoi doctor` — sanity check.
- Run `chezmoi apply` again if any run_once script failed mid-way (state is per-script; completed ones won't re-run).
- To force all run_once scripts to re-run: `chezmoi state delete-bucket --bucket=scriptState`.

## Known issues

See [README.md](README.md) — notably Android Studio on niri/Wayland needs a window rule plus `-Dawt.toolkit.name=WLToolkit`.
