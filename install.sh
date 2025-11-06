#!/usr/bin/env bash
# focusterm automatic installer
# Author: Saman Fekri
# Installs focusterm and sets it to auto-run in Bash and Zsh

set -e

REPO_URL="https://raw.githubusercontent.com/SamanFekri/focusterm/main"
TARGET_DIR="$HOME/.local/bin"
TARGET_FILE="$TARGET_DIR/focusterm.sh"

echo "🔧 Installing focusterm..."

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Download the focusterm script
echo "⬇️  Downloading focusterm.sh..."
curl -fsSL "$REPO_URL/focusterm.sh" -o "$TARGET_FILE" || {
  echo "❌ Failed to download focusterm.sh"
  exit 1
}

chmod +x "$TARGET_FILE"

# Add to shell startup files
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$rc" ]]; then
    if ! grep -q 'source ~/.local/bin/focusterm.sh' "$rc"; then
      echo "" >> "$rc"
      echo "# focusterm (auto-installed)" >> "$rc"
      echo 'source ~/.local/bin/focusterm.sh' >> "$rc"
      echo 'focusterm' >> "$rc"
      echo "✅ Added focusterm to $rc"
    fi
  fi
done

echo ""
echo "✅ focusterm installed successfully!"
echo "📍 Location: $TARGET_FILE"
echo "💡 Restart your terminal or run 'exec \$SHELL' to activate focusterm."
echo ""
