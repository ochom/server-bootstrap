# Ubuntu Server Bootstrap Script

This repository contains a simple bootstrap script for provisioning a fresh Ubuntu server.  
It installs essential tools and prepares a basic Docker-based application hosting environment.

The goal is to make it easy to set up a new server quickly and consistently.

---

# Features

The setup script performs the following tasks:

- Updates the system package list
- Installs Docker Engine
- Installs Docker Compose plugin
- Adds useful Docker aliases
- Creates a standard applications directory
- Deploys a sample Docker application
- Installs Caddy web server
- Configures Caddy as a reverse proxy to the sample app

---

# Docker Installation

The script installs the official Docker packages:

- docker-ce
- docker-ce-cli
- containerd
- docker compose plugin

Docker is enabled and started automatically.

---

# Docker Aliases

To simplify Docker Compose usage, the script adds the following aliases to `~/.bashrc`:

```bash
alias dc='docker compose'
alias dcl='dc logs -f'
alias dcu='dc up -d'
alias dcr='dc up -d --force-recreate'
```

Example usage:

Start containers:

```bash
dcu
```

View logs:

```bash
dcl
```

Recreate containers:

```bash
dcr
```

---

# Application Directory Structure

The script creates a base directory for applications:

```
/var/apps
```

Each application should be placed in its own directory inside `/var/apps`.

Example:

```
/var/apps
  ├── first
  │   └── docker-compose.yaml
  ├── app2
  └── app3
```

---

# Sample Application

A sample application called **first** is created automatically:

```
/var/apps/first/docker-compose.yaml
```

This runs a simple NGINX web server using Docker.

Example configuration:

```yaml
services:
  web:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "8080:80"
```

After setup, the application will be available at:

```
http://SERVER_IP:8080
```

---

# Caddy Installation

The script installs **Caddy**, a modern web server and reverse proxy.

Caddy provides:

- simple configuration
- automatic HTTPS
- reverse proxy support

---

# Default Caddy Configuration

A default `Caddyfile` is created:

```
/etc/caddy/Caddyfile
```

Example configuration:

```
:80 {
    reverse_proxy localhost:8080
}
```

This means:

```
Internet → Caddy → first app (port 8080)
```

---

# Running the Script

Clone the repository and run the setup script:

```bash
git clone https://github.com/yourusername/server-bootstrap.git
cd server-bootstrap
bash server-bootstrap.sh
```

Or run it directly from GitHub:

```bash
curl -sSL https://raw.githubusercontent.com/yourusername/server-bootstrap/main/server-bootstrap.sh | bash
```

---

# Deploying Additional Applications

To deploy a new application:

Create a directory:

```bash
mkdir /var/apps/my-app
cd /var/apps/my-app
```

Create a `docker-compose.yaml` file.

Example:

```yaml
services:
  app:
    image: node:20
    ports:
      - "3000:3000"
```

Start the application:

```bash
dcu
```

---

# Adding Reverse Proxy Routes

Edit the Caddy configuration:

```bash
sudo nano /etc/caddy/Caddyfile
```

Example:

```
example.com {
    reverse_proxy localhost:3000
}
```

Reload Caddy:

```bash
sudo systemctl reload caddy
```

---

# Requirements

- Ubuntu 20.04, 22.04 or newer
- A user with sudo privileges
- Internet access

---

# Summary

After running the script, your server will have:

- Docker installed and running
- Docker Compose available
- Helpful Docker command aliases
- `/var/apps` directory for hosting applications
- A sample Docker web application
- Caddy configured as a reverse proxy

This provides a simple base for hosting multiple Docker applications on a single Ubuntu server.
