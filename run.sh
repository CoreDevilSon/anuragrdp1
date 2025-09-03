#!/bin/bash
# Script to set up Windows with RDP access inside Docker
# and add Ubuntu + Windows shortcuts in ~/.bashrc

# ---------------------------
# 1. Install Docker & Compose
# ---------------------------
sudo apt update && sudo apt install -y docker.io docker-compose

# ---------------------------
# 2. Windows Desktop Container
# ---------------------------
mkdir -p ~/windows-desktop
cd ~/windows-desktop

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

# Start the Windows container
sudo docker-compose up -d

# ---------------------------
# 3. Create loop.sh script (in existing /workspaces/codespaces-blank)
# ---------------------------
cat > /workspaces/codespaces-blank/loop.sh <<'LOOP'
#!/bin/bash
while true; do
    mkdir test_dir
    echo "Directory created"
    sleep 1
    rm -r test_dir
    echo "Directory deleted"
    sleep 1
done
LOOP

chmod +x /workspaces/codespaces-blank/loop.sh

# Run loop.sh in background (first-time setup only)
nohup /workspaces/codespaces-blank/loop.sh >/dev/null 2>&1 &

# ---------------------------
# 4. Add aliases for shortcuts
# ---------------------------
BASHRC=~/.bashrc

# Windows aliases (start also triggers loop.sh)
grep -qxF 'alias start-windows="cd ~/windows-desktop && sudo docker-compose up -d && /workspaces/codespaces-blank/loop.sh &"' $BASHRC \
  || echo 'alias start-windows="cd ~/windows-desktop && sudo docker-compose up -d && /workspaces/codespaces-blank/loop.sh &"' >> $BASHRC
grep -qxF 'alias stop-windows="cd ~/windows-desktop && sudo docker-compose down"' $BASHRC \
  || echo 'alias stop-windows="cd ~/windows-desktop && sudo docker-compose down"' >> $BASHRC

# Reload bashrc so aliases are available immediately
source $BASHRC

echo "✅ Windows Desktop is running!"
echo "🌐 Access it in your browser: http://localhost:8006"
echo "🔑 Next time, use 'start-windows' commands"
