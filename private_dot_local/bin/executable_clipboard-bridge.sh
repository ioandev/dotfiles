#!/bin/bash
# Bidirectional clipboard bridge for a Wayland (niri) VM guest with SPICE.
# vdagent syncs host <-> X11 (xwayland-satellite display); satellite itself never
# syncs selections without a focused X window, so this bridges X11 <-> Wayland.
# Content comparison on both sides prevents an infinite ping-pong loop.
# Requires: wl-clipboard, xclip, clipnotify. Spawned by niri (guest profile only).

wayland_to_x() {
    # wl-paste --watch pipes the new content to the command's stdin on every change
    wl-paste --no-newline --watch sh -c '
        new=$(cat)
        cur=$(xclip -o -selection clipboard -t UTF8_STRING 2>/dev/null)
        [ "$new" != "$cur" ] && printf %s "$new" | xclip -i -selection clipboard
    '
}

x_to_wayland() {
    while clipnotify -s clipboard; do
        new=$(xclip -o -selection clipboard -t UTF8_STRING 2>/dev/null)
        cur=$(wl-paste --no-newline 2>/dev/null)
        [ "$new" != "$cur" ] && printf %s "$new" | wl-copy
    done
}

wayland_to_x &
x_to_wayland &
wait
