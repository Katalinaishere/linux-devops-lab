#!/usr/bin/env bash

set -euo pipefail

PROJECT="$HOME/projects/linux-lab"

echo "Checking project directory..."

if [[ -d "$PROJECT" ]]; then
    echo "SUCCESS: Project directory exists."
    echo "Contents:"
    ls "$PROJECT"
else
    echo "ERROR: Project directory does not exist."
    exit 1
fi

echo "Check complete."
