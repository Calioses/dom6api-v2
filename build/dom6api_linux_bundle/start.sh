
#!/usr/bin/env bash
set -e

APP_NAME="dom6api"
OUTPUT="dom6api_linux"
DATA_FILE="create_tables.sql"
CADDY_FILE="Caddyfile"
DIR="/c/Users/leron/OneDrive/Desktop/dom6api"
INSTALL_DIR="/dom6api"
VENV_DIR="/venv"
LOCAL_CADDY="/caddy"

mkdir -p ""

# Copy Go binary, SQL, and Caddyfile locally
cp "/dom6api_linux" "/"
cp "/create_tables.sql" "/"
cp "/Caddyfile" "/"

# Local Python venv
python3 -m venv ""
source "/bin/activate"

pip install --upgrade pip
pip install playwright
python -m playwright install --with-deps

# Download Caddy binary locally (Linux amd64)
curl -L -o "" "https://github.com/caddyserver/caddy/releases/latest/download/caddy_linux_amd64.tar.gz"
tar -xzf "" -C "" caddy
chmod +x "/caddy"
rm ""

cd ""

# Start local Caddy serving current folder
nohup ./caddy run --config "Caddyfile" > caddy.log 2>&1 &

# Start Go binary in build mode
chmod +x "dom6api_linux"
nohup ./"dom6api_linux" build > "dom6api.log" 2>&1 &
echo "dom6api_linux and local Caddy started in background."

echo "All installed locally under "

