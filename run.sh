#!/bin/bash
# Script to set up Windows with RDP access inside Docker

# Update and install docker + docker-compose
sudo apt update && sudo apt install -y docker.io docker-compose

# Make a project folder
mkdir -p ~/windows-desktop
cd ~/windows-desktop

# Create docker-compose.yml
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

# Start the container
sudo docker-compose up -d

echo "✅ Windows Desktop is running!"
echo "🌐 Access it in your browser: http://localhost:8006"
echo "🔑 From next time execute windows-start command"
