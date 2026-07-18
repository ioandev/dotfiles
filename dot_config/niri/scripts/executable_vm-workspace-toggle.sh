#!/usr/bin/env bash

# Win+Delete escape-from-VM toggle (host only):
#   - default: focus screen 1 (DP-1), then go to the next workspace
#   - if already on DP-1 workspace 2: go back to workspace 1 and focus virt-manager

OUTPUT="DP-1"

read -r cur_idx cur_out < <(
    niri msg -j workspaces | jq -r '
        .[] | select(.is_focused == true) | "\(.idx) \(.output)"
    ' | head -n1
)

if [ "$cur_out" = "$OUTPUT" ] && [ "$cur_idx" = "2" ]; then
    niri msg action focus-workspace 1
    win_id="$(
        niri msg -j windows | jq -r '
            [ .[] | select(.app_id != null and (.app_id | ascii_downcase | contains("virt-manager"))) ]
            | first | .id // empty
        '
    )"
    [ -n "$win_id" ] && niri msg action focus-window --id "$win_id"
else
    niri msg action focus-monitor "$OUTPUT"
    niri msg action focus-workspace-down
fi
