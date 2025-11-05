#!/usr/bin/env bash

sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
