#!/usr/bin/env bash

set -euo pipefail

detect_pi_model() {
    if [ -f /proc/device-tree/model ]; then
        local model=$(tr -d '\0' < /proc/device-tree/model)
        echo "$model"

        if [[ "$model" == *"Raspberry Pi 5"* ]]; then
            return 5
        elif [[ "$model" == *"Raspberry Pi 4"* ]]; then
            return 4
        elif [[ "$model" == *"Raspberry Pi Compute Module 4"* ]]; then
            return 4
        else
            return 0
        fi
    else
        echo "Unknown"
        return 0
    fi
}

detect_ram_size() {
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_ram_gb=$((total_ram_kb / 1024 / 1024))
    echo "${total_ram_gb}GB"
}

get_recommended_swap() {
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_ram_gb=$((total_ram_kb / 1024 / 1024))

    if [ $total_ram_gb -ge 16 ]; then
        echo "1G"
    elif [ $total_ram_gb -ge 8 ]; then
        echo "2G"
    else
        echo "4G"
    fi
}

update_boot_config_for_pi5() {
    local config_file="/boot/firmware/config.txt"

    if [ ! -f "$config_file" ]; then
        echo "Warning: $config_file not found"
        return 1
    fi

    if grep -q "\[pi4\]" "$config_file"; then
        echo "Updating boot config for Pi 5..."
        sudo sed -i 's/\[pi4\]/[pi5]/' "$config_file"
        sudo sed -i '/arm_boost=1/d' "$config_file"
        echo "Boot config updated for Pi 5"
    fi
}

if [ "${1:-}" == "--model" ]; then
    detect_pi_model
elif [ "${1:-}" == "--ram" ]; then
    detect_ram_size
elif [ "${1:-}" == "--swap" ]; then
    get_recommended_swap
elif [ "${1:-}" == "--update-boot" ]; then
    detect_pi_model
    update_boot_config_for_pi5
elif [ "${1:-}" == "--info" ]; then
    echo "=== Hardware Detection ==="
    echo "Model: $(detect_pi_model)"
    echo "RAM: $(detect_ram_size)"
    echo "Recommended Swap: $(get_recommended_swap)"
else
    echo "Usage: $0 [--model|--ram|--swap|--update-boot|--info]"
    exit 1
fi
