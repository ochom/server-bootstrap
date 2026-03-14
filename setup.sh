#!/usr/bin/env bash

set -e

echo "Updating system..."
sudo apt update -y

############################################
# Install Docker
############################################

echo "Installing Docker..."

sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

############################################
# Add Docker aliases
############################################

echo "Adding docker aliases..."

if ! grep -q "alias dc=" ~/.bashrc; then
cat <<EOF >> ~/.bashrc

# Docker shortcuts
alias dc='docker compose'
alias dcl='dc logs -f'
alias dcu='dc up -d'
alias dcr='dc up -d --force-recreate'
EOF
fi

############################################
# Create apps directory
############################################

echo "Creating /var/apps directory..."

sudo mkdir -p /var/apps/first
sudo chown -R $USER:$USER /var/apps

############################################
# Create first docker app
############################################

echo "Creating first app..."

cat <<EOF > /var/apps/first/docker-compose.yaml
services:
  web:
    image: nginx:alpine
    container_name: first_app
    restart: unless-stopped
    ports:
      - "8080:80"
EOF

############################################
# Start first app
############################################

echo "Starting first docker app..."

cd /var/apps/first
docker compose up -d

############################################
# Install Caddy
############################################

echo "Installing Caddy..."

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
| sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
| sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install -y caddy

############################################
# Configure Caddy
############################################

echo "Configuring Caddy reverse proxy..."

sudo bash -c 'cat <<EOF > /etc/caddy/Caddyfile
:80 {
    reverse_proxy localhost:8080
}
EOF'

sudo systemctl reload caddy

echo "-------------------------------------"
echo "Server setup complete."
echo "First app running at:"
echo "http://SERVER_IP"
echo "Apps directory:"
echo "/var/apps"
echo "-------------------------------------"