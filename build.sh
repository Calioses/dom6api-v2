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

APP_NAME="dom6api"
OUTPUT="dom6api_linux"
DATA_FILE="create_tables.sql"
CADDY_FILE="Caddyfile"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$DIR/$APP_NAME"
VENV_DIR="$INSTALL_DIR/venv"
CADDY_TAR="$INSTALL_DIR/caddy.tar.gz"
LOCAL_CADDY="$INSTALL_DIR/caddy"

mkdir -p "$INSTALL_DIR"

# Copy Go binary, SQL, and Caddyfile locally
cp "$DIR/$OUTPUT" "$INSTALL_DIR/"
cp "$DIR/$DATA_FILE" "$INSTALL_DIR/"
cp "$DIR/$CADDY_FILE" "$INSTALL_DIR/"

# Local Python venv
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --upgrade pip
pip install playwright
python -m playwright install --with-deps

# Download Caddy binary locally (Linux amd64)
curl -L -o "$CADDY_TAR" "https://github.com/caddyserver/caddy/releases/latest/download/caddy_linux_amd64.tar.gz"
tar -xzf "$CADDY_TAR" -C "$INSTALL_DIR"
chmod +x "$LOCAL_CADDY"
rm "$CADDY_TAR"

cd "$INSTALL_DIR"

# Start local Caddy serving current folder
nohup ./caddy run --config "$CADDY_FILE" > caddy.log 2>&1 &

# Start Go binary in build mode
chmod +x "$OUTPUT"
nohup ./"$OUTPUT" build > "${APP_NAME}.log" 2>&1 &
echo "$OUTPUT and local Caddy started in background."

echo "All installed locally under $INSTALL_DIR"


EOF

  chmod +x "$BUNDLE_DIR/start.sh"

  tar -czf "build/${OUTPUT}_bundle.tar.gz" -C build "${OUTPUT}_bundle"
done

echo "Build complete. Bundles are in the 'build' folder as .tar.gz files."
