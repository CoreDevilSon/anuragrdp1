#!/bin/bash

# Free RDP Setup Script using Docker (dockurr/windows)
# Author: Anurag (Auto-generated)
# Run: chmod +x setup_rdp.sh && ./setup_rdp.sh

echo "Updating system packages..."
sudo apt update -y

echo "Installing Docker and Docker Compose..."
sudo apt install -y docker.io docker-compose

echo "Creating dockercom directory..."
mkdir -p dockercom && cd dockercom

echo "Creating windows10.yml file..."
cat <<EOF > windows10.yml
version: "3.8"
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

echo "=========================================================="
echo " ✅ Setup completed!"
echo " 📂 windows10.yml has been created inside dockercom/."
echo " ▶ To start the container, run:"
echo "     cd dockercom"
echo "     sudo docker-compose -f windows10.yml up -d"
echo "=========================================================="
