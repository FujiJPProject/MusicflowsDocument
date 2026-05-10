#!/usr/bin/env bash
set -euo pipefail

# Gitユーザー名,パスワードの入力
read -rp "Git user.name: " GIT_USER_NAME
read -rp "Git user.email: " GIT_USER_EMAIL

# Gitのグローバル設定
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# 現在のGit設定を表示
echo "=== current git config ==="
git config --global --list

# SSH鍵を作成
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "=== generate SSH key ==="
  ssh-keygen -t ed25519 -C "$GIT_USER_EMAIL"
else
  echo "SSH key already exists: ~/.ssh/id_ed25519"
fi

echo ""
echo "Add this public key to GitHub:"
echo "GitHub -> Settings -> SSH and GPG keys -> New SSH key"
echo ""
cat "$HOME/.ssh/id_ed25519.pub"
echo ""
echo "After registering the key, test with:"
echo "  ssh -T git@github.com"