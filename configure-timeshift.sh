#!/usr/bin/env bash
#
# Configure Timeshift: RSYNC mode, snapshots stored on the /home disk (/dev/vdc1),
# weekly schedule (keep 3) + a snapshot before every pacman upgrade.
#
set -euo pipefail

CONF=/etc/timeshift/timeshift.json
AUTOSNAP=/etc/timeshift-autosnap.conf
CRON=/etc/cron.d/timeshift-hourly
DEV_UUID=d42b1284-fcde-4e74-a0c7-b5e27d3e123b   # /dev/vdc1  = the /home disk

if [[ $EUID -ne 0 ]]; then echo "Please run with sudo."; exit 1; fi

echo ">> [1/5] Backing up existing config -> ${CONF}.bak.$(date +%Y%m%d-%H%M%S)"
cp -a "$CONF" "${CONF}.bak.$(date +%Y%m%d-%H%M%S)"

echo ">> [2/5] Writing new Timeshift config (RSYNC, target=/home disk, weekly x3)"
cat > "$CONF" <<'JSON'
{
  "backup_device_uuid" : "d42b1284-fcde-4e74-a0c7-b5e27d3e123b",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "false",
  "include_btrfs_home" : "false",
  "stop_cron_emails" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly" : "true",
  "schedule_daily" : "false",
  "schedule_hourly" : "false",
  "schedule_boot" : "false",
  "count_monthly" : "2",
  "count_weekly" : "3",
  "count_daily" : "5",
  "count_hourly" : "6",
  "count_boot" : "5",
  "snapshot_size" : "0",
  "snapshot_count" : "0",
  "exclude" : [
  ],
  "exclude-apps" : [
  ]
}
JSON

echo ">> [3/5] Enabling pre-upgrade snapshots in rsync mode (skipRsyncAutosnap=false)"
sed -i 's/^skipRsyncAutosnap=true/skipRsyncAutosnap=false/' "$AUTOSNAP"
grep -n '^skipRsyncAutosnap' "$AUTOSNAP"

echo ">> [4/5] Installing hourly cron that fires due weekly snapshots"
cat > "$CRON" <<'CRONJOB'
# Timeshift: hourly check for due scheduled (weekly) snapshots
@hourly root /usr/bin/timeshift --check --scripted
CRONJOB
chmod 644 "$CRON"

echo ">> [5/5] Creating initial baseline snapshot (rsync of root; first run copies"
echo "         ~15-20 GB and can take a few minutes)..."
timeshift --rsync --snapshot-device "$DEV_UUID" --create \
          --comments "initial baseline (setup)" --tags O --scripted --yes

echo
echo "==================== RESULT ===================="
timeshift --list
echo "Snapshots are stored on the /home disk here:"
ls -la /home/timeshift/snapshots 2>/dev/null | tail -n +1 || true
echo "================================================"
