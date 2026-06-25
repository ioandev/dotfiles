#!/bin/bash

set -e

REPO_DIR="/home/nordic/Documents/repos/ioandev-sidequests"
CRON_CMD="cd $REPO_DIR && podman compose -f ./docker-compose.ollama.amd.yml up -d"
CRON_LINE="* * * * * $CRON_CMD"

echo "Configuring cron job for ollama compose..."

if crontab -l 2>/dev/null | grep -qF "$CRON_CMD"; then
    echo "Cron job already exists, skipping."
else
    (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
    echo "Cron job added."
fi
