#!/usr/bin/env bash
# focusterm: keep the cursor near the middle of the terminal
# Usage:
#   focusterm [n>=1]         → set scroll region with n as top margin (default = saved value)
#   focusterm --reset         → reset scroll region
#   focusterm --default [n]   → set a new default value for future calls
#   focusterm --enable        → enable scroll region (using default)
#   focusterm --disable       → disable scroll region (same as --reset)
#   focusterm --uninstall     → reset, unset env, and remove the function from the current shell
#
# Notes:
# - We use (top=n, bottom=$LINES) to match the docstring where n is the top margin.
# - Reset also clears origin mode for consistency across terminals.

focusterm() {
  # Default top margin
  if [[ -z "${FOCUSTERM_DEFAULT+x}" ]]; then
    FOCUSTERM_DEFAULT=13
  fi

  # Determine terminal height safely
  local rows
  if [[ -n "$LINES" && "$LINES" =~ ^[0-9]+$ && "$LINES" -gt 0 ]]; then
    rows="$LINES"
  else
    rows="$(tput lines 2>/dev/null || echo 0)"
  fi
  if ! [[ "$rows" =~ ^[0-9]+$ ]] || (( rows < 2 )); then
    rows=24
  fi

  reload_shell() {
    # Reload depending on shell type
    if [[ -n "$BASH_VERSION" || -n "$ZSH_VERSION" ]]; then
      exec "$SHELL"
    else
      printf 'focusterm: unknown shell, please restart manually.\n' >&2
    fi
  }

  # Low-level helpers
  _apply_region() {  # $1 = top
    local top="$1"
    printf '\e[%s;%sr' "$top" "$rows"  # DECSTBM: set scroll region top..bottom
    printf '\e[H'                       # Cursor home
  }
  _reset_region() {
    printf '\e[?6l'    # DECOM off (origin mode off)
    printf '\e[r'      # Reset scroll region to full screen
    printf '\e[H'      # Cursor home
  }

  case "$1" in
    --reset|--disable)
      _reset_region
      printf 'focusterm: disabled\n' >&2
      return
      ;;
    --default)
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ && "$2" -ge 1 ]]; then
        export FOCUSTERM_DEFAULT="$2"
        printf 'focusterm: default set to %s\n' "$2" >&2
        reload_shell
      else
        printf 'Usage: focusterm --default [n>=1]\n' >&2
        return 1
      fi
      return
      ;;
    --enable)
      _apply_region "$FOCUSTERM_DEFAULT"
      printf 'focusterm: enabled (top margin = %s)\n' "$FOCUSTERM_DEFAULT" >&2
      return
      ;;
    --uninstall)
      # Best-effort cleanup
      _reset_region
      unset FOCUSTERM_DEFAULT
      # Remove function from current shell
      if declare -F focusterm >/dev/null 2>&1; then
        unset -f focusterm 2>/dev/null || true
      fi
      if typeset -f focusterm >/dev/null 2>&1; then
        unset -f focusterm 2>/dev/null || true
      fi
      printf 'focusterm: uninstalled from current shell.\n' >&2
      printf 'If you added focusterm to your shell rc (~/.bashrc or ~/.zshrc), remove its definition there to prevent it from loading next time.\n' >&2
      return
      ;;
  esac

  # Positional form: focusterm [n>=1]
  local n="${1:-$FOCUSTERM_DEFAULT}"
  if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    printf 'Usage: focusterm [n>=1] | --reset | --default [n>=1] | --enable | --disable | --uninstall\n' >&2
    return 1
  fi

  # Clamp n so it's not beyond last line
  if (( n >= rows )); then
    n=$(( rows - 1 ))
  fi

  _apply_region "$n"
}

