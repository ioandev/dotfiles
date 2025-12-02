
# Chezmoi dotenv

Note: this repo uses chezmoi. It is for my pikaos (debian based), using niri/noctalia/hypr.

## Post-install set up

~/.config/chezmoi/chezmoi.toml
```
[diff]
command = "code"
args = ["--wait", "--diff"]
```