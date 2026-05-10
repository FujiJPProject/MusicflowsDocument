#!/usr/bin/env bash
set -euo pipefail # コマンド失敗時に終了、未定義変数の使用時に終了、パイプライン途中のエラーの検知

# Ubuntuのパッケージ一覧を更新
echo "=== apt update ==="
sudo apt-get update

# 基本パッケージのインストール
echo "=== install basic packages ==="
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  unzip \
  zip \
  build-essential

# 古いDocker関連パッケージを削除
echo "=== remove old docker packages if exists ==="
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  # パッケージが入っていれば削除、なければ無視
  sudo apt-get remove -y "$pkg" 2>/dev/null || true
done

# Docker公式GPGキーを追加
echo "=== add Docker official GPG key ==="
# Docker公式GPGキーを保存するディレクトリを作成(同時に権限も付与)
sudo install -m 0755 -d /etc/apt/keyrings

# 作成したディレクトリに公式からGPGキーを取得(途中でエラーを検知するように考慮)
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

# 読込権限を付与
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker公式aptリポジトリを追加
echo "=== add Docker apt repository ==="
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker EngineとCompose Pluginをインストール
echo "=== install Docker Engine and Compose plugin ==="
# Docker公式リポジトリを追加したため
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Dockerサービスを有効化・起動
echo "=== enable docker service if systemd is available ==="
if command -v systemctl >/dev/null 2>&1; then
  # Dockerサービスを自動起動対象
  sudo systemctl enable docker || true
  # Dockerサービスを今すぐ起動
  sudo systemctl start docker || true
fi

# 現在のユーザーをdockerグループに追加
echo "=== add current user to docker group ==="
sudo usermod -aG docker "$USER"

# Dockerバージョンの確認
echo "=== docker version ==="
docker --version || true
docker compose version || true

echo ""
echo "Setup completed."
echo "Please restart WSL with the following command from PowerShell:"
echo "  wsl --shutdown"