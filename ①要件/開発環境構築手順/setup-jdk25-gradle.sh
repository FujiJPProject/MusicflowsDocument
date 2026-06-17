#!/usr/bin/env bash
set -euo pipefail

echo "Java 25 and Gradle install script for WSL Ubuntu"
echo "Using Eclipse Temurin / Adoptium apt repository"
echo "Using Gradle official binary distribution"

# ------------------------------------------------------------
# 設定値
# ------------------------------------------------------------
GRADLE_VERSION="8.14.3"
GRADLE_INSTALL_DIR="/opt/gradle"
GRADLE_HOME="${GRADLE_INSTALL_DIR}/gradle-${GRADLE_VERSION}"
GRADLE_ZIP="gradle-${GRADLE_VERSION}-bin.zip"
GRADLE_DOWNLOAD_URL="https://services.gradle.org/distributions/${GRADLE_ZIP}"

# ------------------------------------------------------------
# 1. 必要パッケージのインストール
# ------------------------------------------------------------
echo "[1/8] Installing required packages..."

sudo apt update
sudo apt install -y \
  wget \
  curl \
  unzip \
  apt-transport-https \
  gpg \
  lsb-release \
  ca-certificates

# ------------------------------------------------------------
# 2. Adoptium GPGキーの登録
# ------------------------------------------------------------
echo "[2/8] Adding Adoptium GPG key..."

if [ ! -f /etc/apt/trusted.gpg.d/adoptium.gpg ]; then
  wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
    | gpg --dearmor \
    | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
else
  echo "Adoptium GPG key already exists. Skipping."
fi

# ------------------------------------------------------------
# 3. Adoptium apt repository の登録
# ------------------------------------------------------------
echo "[3/8] Adding Adoptium apt repository..."

UBUNTU_CODENAME="$(lsb_release -cs)"
ADOPTIUM_LIST="/etc/apt/sources.list.d/adoptium.list"

echo "Detected Ubuntu codename: ${UBUNTU_CODENAME}"

if [ ! -f "${ADOPTIUM_LIST}" ] || ! grep -q "packages.adoptium.net" "${ADOPTIUM_LIST}"; then
  echo "deb https://packages.adoptium.net/artifactory/deb ${UBUNTU_CODENAME} main" \
    | sudo tee "${ADOPTIUM_LIST}" > /dev/null
else
  echo "Adoptium apt repository already exists. Skipping."
fi

# ------------------------------------------------------------
# 4. Java 25 Temurin JDK のインストール
# ------------------------------------------------------------
echo "[4/8] Installing Temurin Java 25..."

sudo apt update

if dpkg -s temurin-25-jdk > /dev/null 2>&1; then
  echo "temurin-25-jdk is already installed. Skipping."
else
  sudo apt install -y temurin-25-jdk
fi

# ------------------------------------------------------------
# 5. JAVA_HOME の設定
# ------------------------------------------------------------
echo "[5/8] Setting JAVA_HOME..."

JAVA_HOME_PATH="$(dirname "$(dirname "$(readlink -f "$(which javac)")")")"

echo "Detected JAVA_HOME: ${JAVA_HOME_PATH}"

# 既存設定が増殖しないように削除してから追記
sed -i '/# Java 25 Temurin setting/d' "$HOME/.bashrc"
sed -i '/export JAVA_HOME=.*temurin.*25/d' "$HOME/.bashrc"
sed -i '/export PATH=\$JAVA_HOME\/bin:\$PATH/d' "$HOME/.bashrc"

{
  echo ""
  echo "# Java 25 Temurin setting"
  echo "export JAVA_HOME=${JAVA_HOME_PATH}"
  echo "export PATH=\$JAVA_HOME/bin:\$PATH"
} >> "$HOME/.bashrc"

export JAVA_HOME="${JAVA_HOME_PATH}"
export PATH="${JAVA_HOME}/bin:${PATH}"

# ------------------------------------------------------------
# 6. Gradle のインストール
# ------------------------------------------------------------
echo "[6/8] Installing Gradle ${GRADLE_VERSION}..."

if [ -d "${GRADLE_HOME}" ]; then
  echo "Gradle ${GRADLE_VERSION} is already installed at ${GRADLE_HOME}. Skipping download."
else
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "${TMP_DIR}"' EXIT

  echo "Downloading Gradle from ${GRADLE_DOWNLOAD_URL}..."
  wget -q -O "${TMP_DIR}/${GRADLE_ZIP}" "${GRADLE_DOWNLOAD_URL}"

  echo "Extracting Gradle..."
  sudo mkdir -p "${GRADLE_INSTALL_DIR}"
  sudo unzip -q "${TMP_DIR}/${GRADLE_ZIP}" -d "${GRADLE_INSTALL_DIR}"
fi

# ------------------------------------------------------------
# 7. GRADLE_HOME / PATH の設定
# ------------------------------------------------------------
echo "[7/8] Setting GRADLE_HOME..."

# 既存設定が増殖しないように削除してから追記
sed -i '/# Gradle setting/d' "$HOME/.bashrc"
sed -i '/export GRADLE_HOME=\/opt\/gradle\/gradle-.*/d' "$HOME/.bashrc"
sed -i '/export PATH=\$GRADLE_HOME\/bin:\$PATH/d' "$HOME/.bashrc"

{
  echo ""
  echo "# Gradle setting"
  echo "export GRADLE_HOME=${GRADLE_HOME}"
  echo "export PATH=\$GRADLE_HOME/bin:\$PATH"
} >> "$HOME/.bashrc"

export GRADLE_HOME="${GRADLE_HOME}"
export PATH="${GRADLE_HOME}/bin:${PATH}"

# ------------------------------------------------------------
# 8. インストール確認
# ------------------------------------------------------------
echo "[8/8] Checking installed versions..."

echo "---- Java ----"
java -version
javac -version
echo "JAVA_HOME=${JAVA_HOME}"

echo "---- Gradle ----"
gradle --version
echo "GRADLE_HOME=${GRADLE_HOME}"

echo "Java 25 and Gradle installation completed."
echo "Please restart your shell or run:"
echo "source ~/.bashrc"