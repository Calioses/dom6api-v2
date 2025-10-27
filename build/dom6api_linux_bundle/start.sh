#!/usr/bin/env bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/dom6api"
chmod +x "$DIR/dom6api_linux"

sudo apt update -y
sudo apt install -y caddy python3 python3-pip python3-venv curl unzip wget git

pip install --upgrade pip
pip install playwright
python3 -m playwright install --with-deps

sudo mkdir -p "$INSTALL_DIR"
sudo cp "$DIR/dom6api_linux" "$INSTALL_DIR/"
sudo cp "$DIR/Caddyfile" /etc/caddy/Caddyfile
sudo cp "$DIR/create_tables.sql" "$INSTALL_DIR/create_tables.sql"
sudo systemctl restart caddy

cd "$INSTALL_DIR"
echo "Starting dom6api_linux with build mode..."
nohup "./dom6api_linux" build > "dom6api.log" 2>&1 &
echo "dom6api_linux started in build mode in background."
