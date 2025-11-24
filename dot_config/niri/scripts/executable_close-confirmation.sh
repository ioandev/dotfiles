#!/usr/bin/env bash

focused_window=$(niri msg -j focused-window)
app_id=$(jq -r '.app_id' <<< "$focused_window")
id=$(jq -r '.id' <<< "$focused_window")

pattern="^steam_app_[0-9]+$"

if [[ $app_id =~ $pattern ]]; then
    zenity --question --text="Are you sure you want to close this game?" --title="Confirm Close"
    
    # If user clicks "Yes" (exit code 0)
    if [ $? -eq 0 ]; then
        niri msg action close-window --id "$id"
    fi
else
    niri msg action close-window --id "$id"
fi