#!/usr/bin/env bash
# Build the local noctalia checkout and swap the running shell over to it.
#
# The build always runs before anything is killed, so a broken build leaves your current
# bar alone instead of dropping you to a bare desktop.
#
# Usage:
#   noctalia-dev.sh            build, then replace the running shell
#   noctalia-dev.sh -t         also run the test suite before replacing
#   noctalia-dev.sh -n         skip the build, just restart the current binary
#   noctalia-dev.sh -b         build only, leave the running shell alone
#
# Env overrides: NOCTALIA_REPOS_ROOT, NOCTALIA_REPO, NOCTALIA_BUILD_DIR, NOCTALIA_DEV_LOG

set -euo pipefail

# Checkouts live under <repos-root>/_external - /repos on this box, ~/Documents/repos
# on machines that keep the tree in $HOME.
if [ -n "${NOCTALIA_REPOS_ROOT:-}" ]; then
  REPOS_ROOT="$NOCTALIA_REPOS_ROOT"
elif [ -d /repos ]; then
  REPOS_ROOT=/repos
else
  REPOS_ROOT="$HOME/Documents/repos"
fi

REPO="${NOCTALIA_REPO:-$REPOS_ROOT/_external/noctalia}"
BUILD_DIR="${NOCTALIA_BUILD_DIR:-build-debug}"
LOG="${NOCTALIA_DEV_LOG:-${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/dev-run.log}"
BIN="$REPO/$BUILD_DIR/noctalia"

do_build=1
run_tests=0
do_replace=1

while getopts ":tnbh" opt; do
  case "$opt" in
    t) run_tests=1 ;;
    n) do_build=0 ;;
    b) do_replace=0 ;;
    h) sed -n '2,14p' "$0" | sed 's/^# \?//'; exit 0 ;;
    \?) echo "unknown option -$OPTARG (try -h)" >&2; exit 2 ;;
  esac
done

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

[ -d "$REPO" ] || die "no such repo: $REPO"
cd "$REPO"

# ---------------------------------------------------------------- build

if [ "$do_build" -eq 1 ]; then
  if [ ! -d "$BUILD_DIR" ]; then
    say "configuring $BUILD_DIR"
    just configure debug
  fi
  say "building"
  # Deliberately unguarded: set -e aborts here, before anything is killed.
  just build
fi

[ -x "$BIN" ] || die "no binary at $BIN — run without -n to build it"

if [ "$run_tests" -eq 1 ]; then
  say "running tests"
  meson test -C "$BUILD_DIR" --print-errorlogs
fi

if [ "$do_replace" -eq 0 ]; then
  say "build only; running shell untouched"
  exit 0
fi

# ---------------------------------------------------------------- replace

# A single-instance flock at $XDG_RUNTIME_DIR/noctalia-<display>.lock means the new
# process cannot start until the old one has fully exited, so wait for it rather than
# racing.
old_pids="$(pgrep -x noctalia || true)"
if [ -n "$old_pids" ]; then
  for pid in $old_pids; do
    exe="$(readlink -f "/proc/$pid/exe" 2>/dev/null || echo '?')"
    say "stopping pid $pid ($exe)"
  done
  pkill -x noctalia || true
  for _ in $(seq 1 100); do
    pgrep -x noctalia >/dev/null || break
    sleep 0.1
  done
  if pgrep -x noctalia >/dev/null; then
    say "still alive after 10s; sending SIGKILL"
    pkill -9 -x noctalia || true
    sleep 1
  fi
else
  say "no running instance"
fi

mkdir -p "$(dirname "$LOG")"

# setsid + disown so the shell survives this script exiting or its terminal closing.
# Deliberately not --daemon: that double-forks and sends stdio to /dev/null, losing logs.
say "starting $BIN"
setsid nohup "$BIN" > "$LOG" 2>&1 < /dev/null &
disown

for _ in $(seq 1 100); do
  pgrep -x noctalia >/dev/null && break
  sleep 0.1
done

new_pid="$(pgrep -x noctalia | head -1 || true)"
[ -n "$new_pid" ] || die "shell did not come up — see $LOG"

running_exe="$(readlink -f "/proc/$new_pid/exe" 2>/dev/null || echo '?')"
if [ "$running_exe" != "$(readlink -f "$BIN")" ]; then
  die "pid $new_pid is $running_exe, not the build we just made"
fi

say "running pid $new_pid — $("$BIN" --version 2>&1 | head -1)"
say "log: $LOG"

# Surface startup failures that leave the process alive but the shell broken.
sleep 2
if grep -qiE '\[ERR|error:' "$LOG"; then
  say "errors in the log:"
  grep -iE '\[ERR|error:' "$LOG" | head -5
fi
