#!/bin/bash
# ==========================================
# Church App - Cross-Platform Server Setup
# ==========================================

REPO_URL="https://github.com/donrapidcodecrafters/Churchapp.git"
APP_DIR="/opt/church-app"

echo "🚀 Starting server setup..."

# Detect OS
OS=$(uname -s)
DISTRO=""

if [ "$OS" = "Linux" ]; then
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  fi
else
  echo "❌ Unsupported OS: $OS"
  exit 1
fi

echo "📋 Detected OS: $DISTRO"

# Install required packages
case "$DISTRO" in
  ubuntu|debian)
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y docker.io docker-compose git
    ;;
  centos|rhel|fedora)
    sudo yum update -y
    sudo yum install -y docker docker-compose git
    ;;
  amzn|amazon)
    sudo yum update -y
    sudo amazon-linux-extras install docker -y
    sudo yum install -y docker docker-compose git
    ;;
  alpine)
    sudo apk update
    sudo apk add docker docker-compose git
    ;;
  *)
    echo "⚠️ Unknown distro: $DISTRO. Please install Docker, Docker Compose, and Git manually."
    exit 1
    ;;
esac

# Enable & start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Clone or update repo
if [ -d "$APP_DIR" ]; then
  echo "🔄 Repo exists, pulling latest..."
  cd $APP_DIR
  sudo git pull origin main
else
  echo "📥 Cloning repository..."
  sudo mkdir -p $APP_DIR
  sudo git clone $REPO_URL $APP_DIR
  cd $APP_DIR
fi

# Run Docker stack
echo "🐳 Building and starting containers..."
sudo docker-compose up -d --build

echo "✅ Setup complete!"
echo "API available at: https://yourdomain.com"
echo "Chromecast Receiver: https://yourdomain.com/receiver/receiver.html"
echo "AirPlay/Web Receiver: https://yourdomain.com/airplay.html"
