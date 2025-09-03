#!/bin/bash
# Script to set up Windows with RDP access inside Docker
# and add Ubuntu + Windows shortcuts in ~/.bashrc

BASHRC=~/.bashrc
LOOP_SCRIPT=/workspaces/codespaces-blank/loop.sh
LOOP_PID=/workspaces/codespaces-blank/loop.pid
DOCKER_DIR=/workspaces/codespaces-blank/windows-desktop

# ---------------------------
# 1. First-time setup check
# ---------------------------
if ! command -v docker &>/dev/null; then
    echo "📦 Installing Docker & Compose..."
    sudo apt update && sudo apt install -y docker.io docker-compose
fi

# ---------------------------
# 2. Windows Desktop Container
# ---------------------------
mkdir -p $DOCKER_DIR
cd $DOCKER_DIR

if [ ! -f docker-compose.yml ]; then
    cat > docker-compose.yml <<'EOF'
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "10"
      USERNAME: "MASTER"
      PASSWORD: "admin@123"
      RAM_SIZE: "4G"
      CPU_CORES: "4"
      DISK_SIZE: "400G"
      DISK2_SIZE: "100G"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
      - "3389:3389/udp"
    stop_grace_period: 2m
EOF
    echo "✅ docker-compose.yml created."
fi

# ---------------------------
# 3. Create loop.sh script
# ---------------------------
if [ ! -f "$LOOP_SCRIPT" ]; then
    cat > "$LOOP_SCRIPT" <<'LOOP'
#!/bin/bash
cd /workspaces/codespaces-blank/
while true; do
    mkdir -p test_dir
    echo "Directory created"
    sleep 1
    rm -rf test_dir
    echo "Directory deleted"
    sleep 1
done
LOOP
    chmod +x "$LOOP_SCRIPT"
    echo "✅ loop.sh created."
fi

# ---------------------------
# 4. Add aliases for shortcuts
# ---------------------------

# Start Windows + run loop.sh in background (PID tracked)
grep -qxF 'alias start-windows="sudo docker-compose -f ~/windows-desktop/docker-compose.yml up -d && echo 📦 Waiting for Windows to boot... && until [ \$(sudo docker inspect -f {{.State.Running}} windows 2>/dev/null) == true ]; do sleep 2; done && echo 🚀 Windows is running! && sudo docker-compose -f ~/windows-desktop/docker-compose.yml logs -f & /workspaces/codespaces-blank/loop.sh & echo \$! > /workspaces/codespaces-blank/loop.pid"' $BASHRC \
  || echo 'alias start-windows="sudo docker-compose -f ~/windows-desktop/docker-compose.yml up -d && echo 📦 Waiting for Windows to boot... && until [ \$(sudo docker inspect -f {{.State.Running}} windows 2>/dev/null) == true ]; do sleep 2; done && echo 🚀 Windows is running! && sudo docker-compose -f ~/windows-desktop/docker-compose.yml logs -f & /workspaces/codespaces-blank/loop.sh & echo \$! > /workspaces/codespaces-blank/loop.pid"' >> $BASHRC

# Stop Windows + kill loop.sh if running
grep -qxF 'alias stop-windows="sudo docker-compose -f ~/windows-desktop/docker-compose.yml down && echo ⏹️ Stopping Windows... && if [ -f /workspaces/codespaces-blank/loop.pid ]; then kill \$(cat /workspaces/codespaces-blank/loop.pid) 2>/dev/null && rm /workspaces/codespaces-blank/loop.pid; fi && echo ✅ Windows stopped"' $BASHRC \
  || echo 'alias stop-windows="sudo docker-compose -f ~/windows-desktop/docker-compose.yml down && echo ⏹️ Stopping Windows... && if [ -f /workspaces/codespaces-blank/loop.pid ]; then kill \$(cat /workspaces/codespaces-blank/loop.pid) 2>/dev/null && rm /workspaces/codespaces-blank/loop.pid; fi && echo ✅ Windows stopped"' >> $BASHRC

# Restart shortcut (waits again + streams logs)
grep -qxF 'alias restart-windows="stop-windows && start-windows"' $BASHRC \
  || echo 'alias restart-windows="stop-windows && start-windows"' >> $BASHRC

# Logs shortcut (waits until container is up first)
grep -qxF 'alias logs-windows="echo 📜 Waiting for Windows logs... && until [ \$(sudo docker inspect -f {{.State.Running}} windows 2>/dev/null) == true ]; do sleep 2; done && sudo docker-compose -f ~/windows-desktop/docker-compose.yml logs -f"' $BASHRC \
  || echo 'alias logs-windows="echo 📜 Waiting for Windows logs... && until [ \$(sudo docker inspect -f {{.State.Running}} windows 2>/dev/null) == true ]; do sleep 2; done && sudo docker-compose -f ~/windows-desktop/docker-compose.yml logs -f"' >> $BASHRC


# Reload bashrc so aliases are available immediately
source $BASHRC

# ---------------------------
# 5. First-time container start
# ---------------------------
if ! sudo docker ps -a --format '{{.Names}}' | grep -q "^windows$"; then
    echo "🚀 First-time start: launching Windows container and loop.sh..."
    start-windows
else
    echo "ℹ️ Setup complete. Use: start-windows | stop-windows | restart-windows | logs-windows"
    echo "🌐 Access RDP in browser: http://localhost:8006"
fi
