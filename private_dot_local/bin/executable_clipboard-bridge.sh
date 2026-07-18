#!/bin/bash
# Bidirectional clipboard bridge for a Wayland (niri) VM guest with SPICE.
# vdagent syncs host <-> X11 (xwayland-satellite display); satellite itself never
# syncs selections without a focused X window, so this bridges X11 <-> Wayland.
#
# TEXT: content comparison on both sides prevents an infinite ping-pong loop, and
# empty selections are never propagated: apps (zellij, VSCode, ...) clear-then-set
# the clipboard on copy, and mirroring that transient empty lets it race back across
# the bridge (~40ms round-trip) and clobber the value you just copied -> the copy
# "vanishes" until you copy again. Dropping empties breaks that feedback loop.
#
# IMAGES: screenshots (niri `Print`, `grim | wl-copy`, swappy) land ONLY on the
# Wayland clipboard, but tools that paste images read the X11 CLIPBOARD via xclip
# (Claude Code's image paste included). So mirror image/png Wayland -> X11 too.
# This is one-way on purpose: x_to_wayland stays text-only, which is what keeps the
# image push from ping-ponging back and clobbering the Wayland image. It gates on the
# X11 TARGETS list (an image advertises no text target) rather than on read emptiness,
# because an xclip image owner will hand back its raw bytes even for a UTF8_STRING
# request -- reading that as "text" would corrupt the clipboard.
#
# Requires: wl-clipboard, xclip, clipnotify. Spawned by niri (guest profile only).

wayland_to_x() {
    # Fires on every Wayland clipboard change; re-reads the current content by type.
    wl-paste --watch sh -c '
        types=$(wl-paste --list-types 2>/dev/null)
        case "$types" in
            *text/plain*)
                new=$(wl-paste --no-newline --type text/plain 2>/dev/null)
                [ -z "$new" ] && exit 0   # ignore transient empty (see header)
                cur=$(xclip -o -selection clipboard -t UTF8_STRING 2>/dev/null)
                [ "$new" != "$cur" ] && printf %s "$new" | xclip -i -selection clipboard
                ;;
            *image/png*)
                # Mirror the image to X11 so xclip-based readers (Claude Code) can paste it.
                tmp=$(mktemp) || exit 0
                wl-paste --type image/png > "$tmp" 2>/dev/null
                [ -s "$tmp" ] && xclip -i -selection clipboard -t image/png "$tmp"
                rm -f "$tmp"
                ;;
        esac
    '
}

x_to_wayland() {
    # Text only, on purpose (see header): this is what stops a Wayland->X11 image push
    # from looping back and clobbering the Wayland image. An xclip image owner serves
    # its bytes even for a UTF8_STRING request, so we must gate on the TARGETS list
    # (not on emptiness) -- an image offers no UTF8_STRING/STRING target, so skip it.
    while clipnotify -s clipboard; do
        targets=$(xclip -o -selection clipboard -t TARGETS 2>/dev/null)
        case "$targets" in
            *UTF8_STRING*|*STRING*) : ;;   # has a text target -> handle below
            *) continue ;;                 # image / non-text -> leave it alone
        esac
        new=$(xclip -o -selection clipboard -t UTF8_STRING 2>/dev/null)
        [ -z "$new" ] && continue   # ignore transient empty (see header)
        cur=$(wl-paste --no-newline --type text/plain 2>/dev/null)
        [ "$new" != "$cur" ] && printf %s "$new" | wl-copy
    done
}

wayland_to_x &
x_to_wayland &
wait
