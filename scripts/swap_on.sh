#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SWAP_SIZE="1G"
if [ -f "${SCRIPT_DIR}/detect_hardware.sh" ]; then
    SWAP_SIZE=$(bash "${SCRIPT_DIR}/detect_hardware.sh" --swap)
    echo "Detected hardware - using ${SWAP_SIZE} swap"
fi

if [ -f /swapfile ]; then
    echo "Swap file already exists. Removing old swap..."
    sudo swapoff /swapfile 2>/dev/null || true
    sudo rm /swapfile
fi

echo "Creating ${SWAP_SIZE} swap file..."
sudo fallocate -l ${SWAP_SIZE} /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
fi

sudo sysctl -w vm.swappiness=10

echo "Swap configured successfully"
swapon --show
