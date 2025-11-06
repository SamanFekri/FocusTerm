# focusterm

Keep your prompt **near the middle of your terminal** — instead of it being glued to the bottom line.  
`focusterm` makes your terminal more comfortable by adjusting the **scroll region** using ANSI escape codes (`DECSTBM`).

---

## 🧠 What it does

Normally, your terminal scrolls the whole screen, so your prompt always appears on the very bottom line.  
`focusterm` sets a **scroll region** limited to the top `n` lines — which keeps your prompt comfortably higher, centered for easier reading.

---

## ⚡️ Features

- Works with both **Bash** and **Zsh**
- Runs **automatically** when you start a new terminal
- Pure shell — no dependencies or binaries
- Compatible with tmux, iTerm2, kitty, Alacritty, GNOME Terminal, xterm, Windows Terminal, etc.
- Fully resettable and customizable per session

---
## Auto Install

Keep your terminal prompt comfortably **centered near the middle** instead of glued to the bottom line.  
`focusterm` automatically adjusts your terminal’s scroll region using ANSI escape codes so your eyes stay relaxed while working.

---

## 🚀 Quick Automatic Installation

You can install **focusterm** instantly with a single command — no cloning needed.

### Using `curl`
```bash
curl -fsSL https://raw.githubusercontent.com/SamanFekri/focusterm/main/install.sh
```

### Using `wget`
```bash
wget -qO- https://raw.githubusercontent.com/SamanFekri/focusterm/main/install.sh)
```

## ✅ Verify Installation

Once installed, you can verify that `focusterm` is working properly:

1. Check if the function is available:
```bash
type focusterm
```
You should see: `focusterm is a function`

2. Test it manually:
```bash
focusterm
```
You'll notice your prompt shifts closer to the center of your terminal window.

## 🧹 Uninstall

To remove `focusterm` and its auto-start configuration:

```bash
rm -f ~/.local/bin/focusterm.sh
sed -i '/focusterm/d' ~/.bashrc ~/.zshrc
exec $SHELL
```

This will:
- Remove the script file
- Clean up any `focusterm` references in your shell config files
- Restart your shell to restore normal terminal scroll behavior

## 🪄 Usage

After installation, `focusterm` runs automatically every time you open a new terminal.  
You can also use it manually to adjust, reset, or configure its behavior.

### ⚙️ Basic Commands

#### Keep your prompt centered (default)
```bash
focusterm
```
Runs with the default top margin (13 by default), keeping your cursor near the middle of the screen.

#### Set a custom scroll region
```bash
focusterm 15
```
Moves the scroll region so the bottom 15 lines stay static, keeping your prompt slightly lower or higher depending on your terminal height.

> 💡 Try values between 10–20 to find what feels most natural.

#### Change the session default
```bash
focusterm --default 18
```
Sets 18 as your new default margin for this session.
Every time you run `focusterm` without arguments, it'll use this number.

#### Reset to normal terminal behavior
```bash
focusterm --reset
```
Restores full-screen scrolling — your prompt will return to the very bottom of the terminal, as usual.

### 🧠 Command Summary

| Command | Description |
|---------|-------------|
| `focusterm` | Centers prompt using saved default (default = 13) |
| `focusterm [n]` | Sets scroll region with top margin n |
| `focusterm --default [n]` | Updates default margin for this session |
| `focusterm --reset` | Restores normal full-screen scrolling |

### 🧩 Example workflow
```bash
# Center your prompt
focusterm

# Adjust to slightly higher center
focusterm 10

# Save this height as your new default
focusterm --default 10

# Reset everything to normal
focusterm --reset
```

### ⚙️ Notes

- Works in Bash and Zsh
- Compatible with tmux, iTerm2, Alacritty, kitty, GNOME Terminal, xterm, and Windows Terminal
- Doesn't affect scrollback history — it only changes which visible lines scroll
- Safe to run multiple times — calling `focusterm` repeatedly won't break your session