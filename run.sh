#!/bin/bash
# Script to set up Ubuntu Desktop with RDP access inside Docker

# Update and install docker + docker-compose
sudo apt update && sudo apt install -y docker.io docker-compose

# Make a project folder
mkdir -p ~/docker-ubuntu-desktop
cd ~/docker-ubuntu-desktop

# Create docker-compose.yml
cat > docker-compose.yml <<'EOF'
version: "3.8"
services:
  ubuntu-desktop:
    image: dorowu/ubuntu-desktop-lxde-vnc
    container_name: ubuntu-desktop
    ports:
      - "6080:80"     # Web browser access
      - "5900:5900"   # VNC access
    environment:
      USER: "docker"
      PASSWORD: "docker"
    shm_size: "2g"
EOF

# Start the container
sudo docker-compose up -d

echo "✅ Ubuntu Desktop is running!"
echo "🌐 Access it in your browser: http://localhost:6080"
echo "🔑 VNC access: localhost:5900 (password: docker)"
