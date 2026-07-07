#!/usr/bin/env bash

# Focus the terminal living on the "terminals" workspace.
#
# The terminal is normally a single fullscreen window on its own named
# workspace. niri 26.04 does not expose a per-window fullscreen flag over IPC,
# so we identify the terminal by app_id on that workspace rather than by its
# fullscreen state. If more than one terminal is present we focus the FIRST one
# in the workspace's scrolling layout (leftmost column, then topmost).
#
# Focuses all three levels explicitly, as requested:
#   1. the screen  (output the workspace lives on)  -> focus-monitor
#   2. the workspace                                 -> focus-workspace <id>
#   3. the terminal window                           -> focus-window --id
#
# (In niri, focus-window alone would pull the workspace and output active too,
# but we do each step so the script still lands on the right screen+workspace
# even when the terminal window can't be found.)

WORKSPACE_NAME="terminals"   # matched case-insensitively
TERM_APP_ID="Alacritty"      # app_id of the terminal to focus

workspaces_json="$(niri msg -j workspaces)"
windows_json="$(niri msg -j windows)"

# Resolve the workspace by name (case-insensitive) -> its id and output.
read -r ws_id ws_output < <(
    jq -rn --argjson wss "$workspaces_json" --arg name "$WORKSPACE_NAME" '
        $wss[]
        | select((.name // "" | ascii_downcase) == ($name | ascii_downcase))
        | "\(.id)\t\(.output)"
    ' | head -n1 | tr '\t' ' '
)

if [ -z "$ws_id" ]; then
    echo "No workspace named '$WORKSPACE_NAME' found." >&2
    exit 1
fi

# 1. Focus the screen the workspace is on (output can be null if disconnected).
if [ -n "$ws_output" ] && [ "$ws_output" != "null" ]; then
    niri msg action focus-monitor "$ws_output"
fi

# 2. Focus the workspace itself (by id — robust to the name's casing).
niri msg action focus-workspace "$ws_id"

# 3. Find the terminal window on that workspace: the terminal app_id, picking
#    the FIRST in the scrolling layout if several exist. pos_in_scrolling_layout
#    is [column, row]; sorting the array lexicographically gives leftmost-then-
#    topmost. Windows with no layout position sort last.
term_id="$(
    jq -rn \
        --argjson wins "$windows_json" \
        --argjson ws "$ws_id" \
        --arg app "$TERM_APP_ID" '
        [ $wins[]
          | select(.workspace_id == $ws and .app_id == $app) ]
        | sort_by(.layout.pos_in_scrolling_layout // [1e9, 1e9])
        | first
        | .id // empty
    '
)"

if [ -z "$term_id" ]; then
    echo "No '$TERM_APP_ID' window on workspace '$WORKSPACE_NAME' (id $ws_id); focused the workspace only." >&2
    exit 0
fi

niri msg action focus-window --id "$term_id"
