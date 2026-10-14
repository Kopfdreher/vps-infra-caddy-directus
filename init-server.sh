#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring 2 GB Swap..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    sysctl vm.swappiness=10
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi

echo "==> Installing Docker..."
apt-get update -y
apt-get install -y curl ca-certificates rsync
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
fi

echo "==> Creating project directories..."
mkdir -p /opt/webstack/{directus/database,directus/uploads,frontends/brother,frontends/wife}
chown -R 1000:1000 /opt/webstack/directus

echo "==> Server initialization complete!"
