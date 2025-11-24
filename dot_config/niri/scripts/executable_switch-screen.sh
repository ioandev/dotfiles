#!/bin/bash

# Monitor Switch Script for Niri
# Toggles focus between primary and secondary monitors

PRIMARY_MONITOR="DP-1"
SECONDARY_MONITOR="HDMI-A-1"

# Get the currently focused output
current_output=$(niri msg focused-output | grep -oP 'Output ".*" \(\K[^)]+')

# Switch to the other monitor
if [ "$current_output" = "$PRIMARY_MONITOR" ]; then
    niri msg action focus-monitor "$SECONDARY_MONITOR"
elif [ "$current_output" = "$SECONDARY_MONITOR" ]; then
    niri msg action focus-monitor "$PRIMARY_MONITOR"
else
    # Fallback: if we can't determine current monitor, go to primary
    niri msg action focus-monitor "$PRIMARY_MONITOR"
fi
