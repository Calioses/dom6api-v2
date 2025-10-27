#!/usr/bin/env bash
set -e

APP_NAME="dom6api"
DATA_FILE="create_tables.sql"
CADDY_FILE="Caddyfile"

PLATFORMS=(
  "linux amd64 dom6api_linux"
  # "darwin amd64 dom6api_mac"
  # "windows amd64 dom6api_win.exe"
)

rm -rf build
mkdir -p build

for plat in "${PLATFORMS[@]}"; do
  read -r GOOS GOARCH OUTPUT <<< "$plat"
  echo "Building for $GOOS/$GOARCH -> $OUTPUT"

  BUNDLE_DIR="build/${OUTPUT}_bundle"
  mkdir -p "$BUNDLE_DIR"

  env CGO_ENABLED=0 GOOS=$GOOS GOARCH=$GOARCH go build -trimpath -ldflags="-s -w" -o "$BUNDLE_DIR/$OUTPUT" .

  cp "$DATA_FILE" "$BUNDLE_DIR/$DATA_FILE"
  cp "$CADDY_FILE" "$BUNDLE_DIR/$CADDY_FILE"

  cat <<EOF > "$BUNDLE_DIR/start.sh"
#!/usr/bin/env bash
set -e
DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/opt/${APP_NAME}"
chmod +x "\$DIR/$OUTPUT"

sudo apt update -y
sudo apt install -y caddy python3 python3-pip python3-venv curl unzip wget git

pip install --upgrade pip
pip install playwright
python3 -m playwright install --with-deps

sudo mkdir -p "\$INSTALL_DIR"
sudo cp "\$DIR/$OUTPUT" "\$INSTALL_DIR/"
sudo cp "\$DIR/$CADDY_FILE" /etc/caddy/Caddyfile
sudo cp "\$DIR/$DATA_FILE" "\$INSTALL_DIR/$DATA_FILE"
sudo systemctl restart caddy

cd "\$INSTALL_DIR"
echo "Starting $OUTPUT with build mode..."
nohup "./$OUTPUT" build > "${APP_NAME}.log" 2>&1 &
echo "$OUTPUT started in build mode in background."
EOF

  chmod +x "$BUNDLE_DIR/start.sh"

  tar -czf "build/${OUTPUT}_bundle.tar.gz" -C build "${OUTPUT}_bundle"
done

echo "Build complete. Bundles are in the 'build' folder as .tar.gz files."
