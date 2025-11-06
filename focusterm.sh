#!/usr/bin/env bash
# focusterm: keep the cursor near the middle of the terminal
# Usage:
#   focusterm [n>=1]         → set scroll region with n as top margin (default = saved value)
#   focusterm --reset         → reset scroll region
#   focusterm --default [n]   → set a new default value for future calls
#   focusterm --enable        → enable scroll region (using default)
#   focusterm --disable       → disable scroll region (same as --reset)
#   (Each of --default, --enable, and --disable will reload the shell)

focusterm() {
  # Default top margin
  if [[ -z "${FOCUSTERM_DEFAULT+x}" ]]; then
    FOCUSTERM_DEFAULT=13
  fi

  reload_shell() {
    echo "Reloading shell..." >&2
    # Reload depending on shell type
    if [[ -n "$BASH_VERSION" ]]; then
      exec "$SHELL"
    elif [[ -n "$ZSH_VERSION" ]]; then
      exec "$SHELL"
    else
      echo "focusterm: unknown shell, please restart manually." >&2
    fi
  }

  case "$1" in
    --reset|--disable)
      printf '\e[r'   # Reset scroll region
      printf '\e[H'   # Move cursor to home
      reload_shell
      echo "focusterm: disabled" >&2
      return
      ;;
    --default)
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ && "$2" -ge 1 ]]; then
        export FOCUSTERM_DEFAULT="$2"
        echo "focusterm: default set to $2" >&2
        reload_shell
      else
        echo "Usage: focusterm --default [n>=1]" >&2
        return 1
      fi
      return
      ;;
    --enable)
      printf '\e[1;%sr' "$FOCUSTERM_DEFAULT"
      printf '\e[H'
      echo "focusterm: enabled (top margin = $FOCUSTERM_DEFAULT)" >&2
      reload_shell
      return
      ;;
  esac

  local n="${1:-$FOCUSTERM_DEFAULT}"
  if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Usage: focusterm [n>=1] | --reset | --default [n>=1] | --enable | --disable" >&2
    return 1
  fi

  printf '\e[1;%sr' "$n"  # Set scroll region
  printf '\e[H'           # Move cursor to home
}
