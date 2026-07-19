#!/usr/bin/env bash

# "Close" the current workspace if it has no windows.
#
# Niri keeps named workspaces around even when empty; unnaming an empty one
# lets niri garbage-collect it like any other empty dynamic workspace.
# Equivalent to running `n` (no args) while focused on that workspace.

ws_id="$(niri msg -j workspaces | jq -r '.[] | select(.is_focused == true) | .id')"

has_windows="$(niri msg -j windows | jq --argjson ws "$ws_id" 'any(.[]; .workspace_id == $ws)')"

if [ "$has_windows" = "false" ]; then
    niri msg action unset-workspace-name
fi
