#!/usr/bin/env bash
# focusterm automatic installer
# Author: Saman Fekri
# Installs focusterm and sets it to auto-run in Zsh

set -e

REPO_URL="https://raw.githubusercontent.com/SamanFekri/focusterm/"
TARGET_DIR="$HOME/.local/bin"
TARGET_FILE="$TARGET_DIR/focusterm.sh"

echo "🔧 Installing focusterm..."

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Download the focusterm script
echo "⬇️  Downloading focusterm.sh..."
curl -fsSL "$REPO_URL/refs/heads/main/focusterm.sh" -o "$TARGET_FILE" || {
  echo "❌ Failed to download focusterm.sh"
  exit 1
}

chmod +x "$TARGET_FILE"

# Add to Zsh startup file only
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
  if ! grep -q 'source ~/.local/bin/focusterm.sh' "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# focusterm (auto-installed)" >> "$ZSHRC"
    echo 'source ~/.local/bin/focusterm.sh' >> "$ZSHRC"
    echo 'focusterm' >> "$ZSHRC"
    echo "✅ Added focusterm to $ZSHRC"
  fi
fi

echo ""
echo "✅ focusterm installed successfully!"
echo "📍 Location: $TARGET_FILE"
echo "💡 Restart your terminal or run 'source ~/.zshrc' to activate focusterm."
echo ""
