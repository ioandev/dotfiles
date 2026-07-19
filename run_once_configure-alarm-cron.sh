#!/bin/bash

set -e

REPO_DIR="/home/nordic/Documents/repos/alarm"
LOG_FILE="/home/nordic/.local/state/alarm.log"

# The alarm fires random bursts for two hours, or until its lock file is
# deleted (`rm ~/alarm.lock`) — whichever comes first. send_alarm.py owns the
# lock, including refusing to start a second run, so there is nothing to guard
# here. The venv interpreter is spelled out because cron's PATH finds a python
# without pyserial.
MARKER="send_alarm.py preset:random"
CRON_CMD="cd $REPO_DIR && $REPO_DIR/.venv/bin/python3 send_alarm.py preset:random duration:7200 >> $LOG_FILE 2>&1"
CRON_LINE="30 8 * * * $CRON_CMD"

echo "Configuring cron job for the alarm..."

if crontab -l 2>/dev/null | grep -qF "$CRON_LINE"; then
    echo "Cron job already up to date, skipping."
else
    # Drop any older version of the line rather than skip: the schedule and
    # duration live in it, so this script has to be able to change them.
    (crontab -l 2>/dev/null | grep -vF "$MARKER"; echo "$CRON_LINE") | crontab -
    echo "Cron job installed."
fi
