#!/usr/bin/env bash

set -euo pipefail

if [ -f /swapfile ]; then
    echo "Disabling swap..."
    sudo swapoff -v /swapfile 2>/dev/null || true
    sudo rm /swapfile
    echo "Swap removed successfully"
else
    echo "No swap file found at /swapfile"
fi
