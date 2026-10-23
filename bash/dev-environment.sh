#!/usr/bin/env bash
set -euo pipefail

echo "DEV ENV CHECK"

for tool in git curl wget nano; do 
    if command -v "$tool" >/dev/null 2>&1; then
       echo "[OK] $tool is installed"
   else 
echo "[MISSING] $tool is not installed"
fi
 done

echo "========="
