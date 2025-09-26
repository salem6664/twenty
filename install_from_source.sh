#!/bin/bash

echo "🔧 Checking dependencies..."
if ! command -v docker &>/dev/null; then
  echo "❌ Docker not installed. Please install Docker first."
  exit 1
fi
if ! docker compose version &>/dev/null; then
  echo "❌ Docker Compose plugin not installed. Install it first."
  exit 1
fi
if ! docker info &>/dev/null; then
  echo "❌ Docker is not running. Please start Docker."
  exit 1
fi
if ! command -v git &>/dev/null; then
  echo "❌ Git is not installed. Run: sudo apt install git -y"
  exit 1
fi

# Directory setup
dir_name="twenty"
read -p "📁 Enter directory name for project (default: $dir_name): " answer
if [ -n "$answer" ]; then
  dir_name=$answer
fi

if [ -d "$dir_name" ]; then
  read -p "🚫 Directory '$dir_name' already exists. Overwrite? (y/N): " confirm
  if [ "$confirm" != "y" ]; then
    echo "❌ Cancelled."
    exit 1
  fi
  rm -rf "$dir_name"
fi

echo "📥 Cloning Twenty source code..."
git clone https://github.com/twentyhq/twenty.git "$dir_name"
cd "$dir_name" || exit 1

echo "⚙️ Setting up docker-compose (dev mode)..."
cp packages/twenty-docker/docker-compose.dev.yml docker-compose.yml
cp packages/twenty-docker/.env.example .env

# Generate secrets
echo "# === Secrets ===" >> .env
echo "APP_SECRET=$(openssl rand -base64 32)" >> .env
echo "PG_DATABASE_PASSWORD=$(openssl rand -hex 32)" >> .env

echo "🐳 Building containers (this may take a while)..."
docker compose build

read -p "🚀 Do you want to start the project now? (Y/n): " start
if [ "$start" != "n" ]; then
  docker compose up -d
  echo "✅ Twenty is running at http://localhost:3000"
else
  echo "✅ Setup completed. Run 'docker compose up -d' to start later."
fi
