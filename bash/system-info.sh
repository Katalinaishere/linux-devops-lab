#!/usr/bin/env bash
set -euo pipefail
echo "===== System INFORMATION ====="

echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo "Current Directory: $(pwd)"
echo "Date $(date)"

echo "Linux Kernel:"
uname -r 
echo "==============="
