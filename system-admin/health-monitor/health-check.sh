
#!/usr/bin/env bash

set -euo pipefail


DISK_WARNING=80
MEMORY_WARNING=80

TEST_MODE="${1:-normal}"
LOG_DIR="$HOME/projects/linux-lab/logs"
LOG_FILE="$LOG_DIR/health-check.log"

mkdir -p "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}
# Check disk usage
if [[ "$TEST_MODE" == "test-disk" ]]; then
    DISK_USAGE=90
else
    DISK_USAGE=$(df -P / | awk 'NR==2 {
        gsub("%", "", $5)
        print $5
    }')
fi


if [[ "$TEST_MODE" == "test-memory" ]]; then
    MEMORY_USAGE=90
else
    read -r TOTAL_MEM AVAILABLE_MEM < <(
        free -b | awk '/^Mem:/ {
            print $2, $7
        }'
    )

    MEMORY_USAGE=$(( (TOTAL_MEM - AVAILABLE_MEM) * 100 / TOTAL_MEM ))
fi


CPU_COUNT=$(nproc)
HAS_WARNING=0

log "========== HEALTH CHECK =========="
log "Hostname: $(hostname)"
log "Disk usage: ${DISK_USAGE}%"

if (( DISK_USAGE >= DISK_WARNING )); then
    log "WARNING: Disk usage is high!"
    HAS_WARNING=1
else
    log "OK: Disk usage is within limits."
fi

log "Memory usage: ${MEMORY_USAGE}%"

if (( MEMORY_USAGE >= MEMORY_WARNING )); then
    log "WARNING: Memory usage is high!"
    HAS_WARNING=1
else
    log "OK: Memory usage is within limits."
fi

log "Available CPU count: $CPU_COUNT"

if (( HAS_WARNING == 1 )); then
    log "RESULT: WARNING"
    exit 1
fi

log "RESULT: HEALTHY"
exit 0
