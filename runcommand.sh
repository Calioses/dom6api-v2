# Go to your home folder and create a folder for the app
mkdir -p ~/dom6api && cd ~/dom6api

# Download the tar from GitHub
curl -L -o dom6api_linux_bundle.tar.gz https://github.com/Calioses/dom6api-v2/raw/main/build/dom6api_linux_bundle.tar.gz

# Extract it
tar -xzf dom6api_linux_bundle.tar.gz

# Kill any existing dom6api_linux process
pkill dom6api_linux || true

# Run the start script in build mode
./dom6api_linux_bundle/start.sh build
