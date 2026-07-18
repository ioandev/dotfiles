
# Chezmoi dotenv

Note: this repo uses chezmoi. It supports PikaOS (Debian-based) **untested** and Manjaro (Arch-based), using niri/noctalia/hypr.

## Install

See [INSTALLATION.md](INSTALLATION.md). Fresh bootstrap:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply ioandev/dotfiles
```

At init you pick a **machine profile** — `full` (physical/main machine) or `guest` (VM). It controls the installed app set and a few templated configs (e.g. the Noctalia color scheme: Ayu on `full`, Ember Red on `guest`). Preset it non-interactively with `--promptChoice "Machine profile=guest"`. Details and the full per-profile breakdown: [Machine profiles](INSTALLATION.md#machine-profiles).

## Known Issues & Fixes

### Android Studio on niri (Wayland)

Android Studio shows the splash screen then the main window never appears. Two things are required:

1. Add a window rule to `~/.config/niri/config.kdl` to let Android Studio pick its own initial size (similar to the WezTerm configure event bug):
```kdl
window-rule {
    match app-id="jetbrains-studio"
    default-column-width {}
}
```

2. Force Android Studio to use JBR's native Wayland toolkit by adding this to `~/.config/Google/AndroidStudio2025.3.2/studio64.vmoptions`:
```
-Dawt.toolkit.name=WLToolkit
```

## Post-install set up

~/.config/chezmoi/chezmoi.toml
```
[diff]
command = "code"
args = ["--wait", "--diff"]
```