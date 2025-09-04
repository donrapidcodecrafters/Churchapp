# ==========================================
# Church App - Windows Server Setup Script
# ==========================================

$repoUrl = "https://github.com/donrapidcodecrafters/Churchapp.git"
$appDir = "C:\church-app"

Write-Host "🚀 Starting server setup..."

# 1. Check for Docker Desktop
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker not found. Please install Docker Desktop manually:"
    Write-Host "👉 https://www.docker.com/products/docker-desktop/"
    exit 1
}

# 2. Clone or update repo
if (Test-Path $appDir) {
    Write-Host "🔄 Repo exists, pulling latest..."
    Set-Location $appDir
    git pull origin main
} else {
    Write-Host "📥 Cloning repository..."
    git clone $repoUrl $appDir
    Set-Location $appDir
}

# 3. Run Docker stack
Write-Host "🐳 Building and starting containers..."
docker-compose up -d --build

Write-Host "✅ Setup complete!"
Write-Host "API available at: https://yourdomain.com"
Write-Host "Chromecast Receiver: https://yourdomain.com/receiver/receiver.html"
Write-Host "AirPlay/Web Receiver: https://yourdomain.com/airplay.html"
