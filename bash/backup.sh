
#!/usr/bin/env bash

set -euo pipefail

SOURCE="$HOME/projects/linux-lab"
BACKUP_DIR="$HOME/backups"
LOG_FILE="$BACKUP_DIR/backup.log"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/linux-lab-$TIMESTAMP.tar.gz"
TEMP_FILE="$BACKUP_FILE.tmp"
KEEP_BACKUPS=7

mkdir -p "$BACKUP_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

cleanup() {
    if [[ -f "$TEMP_FILE" ]]; then
        rm -f -- "$TEMP_FILE"
        log "Removed incomplete temporary archive."
    fi
}

trap cleanup EXIT

log "Starting backup."

if [[ ! -d "$SOURCE" ]]; then
    log "ERROR: Project directory not found: $SOURCE"
    exit 1
fi

if [[ -e "$BACKUP_FILE" || -e "$TEMP_FILE" ]]; then
    log "ERROR: Backup filename already exists."
    exit 1
fi

if tar -czf "$TEMP_FILE" -C "$HOME/projects" linux-lab; then
    log "Temporary archive created."
else
    log "ERROR: Backup creation failed."
    exit 1
fi

if tar -tzf "$TEMP_FILE" > /dev/null; then
    log "Archive verification passed."
else
    log "ERROR: Archive verification failed."
    exit 1
fi

mv -- "$TEMP_FILE" "$BACKUP_FILE"
log "SUCCESS: Backup saved to $BACKUP_FILE"

mapfile -t BACKUPS < <(
    find "$BACKUP_DIR" -maxdepth 1 -type f \
        -name 'linux-lab-*.tar.gz' -printf '%f\n' |
    sort -r
)

if (( ${#BACKUPS[@]} > KEEP_BACKUPS )); then
    for OLD_BACKUP in "${BACKUPS[@]:KEEP_BACKUPS}"; do
        rm -f -- "$BACKUP_DIR/$OLD_BACKUP"
        log "Removed old backup: $OLD_BACKUP"
    done
fi

log "Backup completed successfully."
