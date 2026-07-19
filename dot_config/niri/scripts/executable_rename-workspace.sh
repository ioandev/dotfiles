#!/usr/bin/env bash

# Prompt for a workspace name and set/unset it on the focused workspace.
# GUI equivalent of the `n` zsh function (dot_zshrc.tmpl) for triggering
# from a niri keybind instead of a terminal.

name="$(zenity --entry --title="Rename Workspace" --text="Workspace name (blank to unset):")" || exit 0

if [ -z "$name" ]; then
    niri msg action unset-workspace-name
else
    niri msg action set-workspace-name -- "- $name -"
fi
