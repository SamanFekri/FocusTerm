#!/usr/bin/env bash
# focusterm: keep the cursor near the middle of the terminal
# Usage:
#   focusterm [n>=1]        → set scroll region with n as top margin (default = saved value)
#   focusterm --reset        → reset scroll region
#   focusterm --default [n]  → set a new default value for future calls

focusterm() {
  # Default top margin
  if [[ -z "${FOCUSTERM_DEFAULT+x}" ]]; then
    FOCUSTERM_DEFAULT=13
  fi

  case "$1" in
    --reset)
      printf '\e[r'   # Reset scroll region
      printf '\e[H'   # Move cursor to home
      return
      ;;
    --default)
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ && "$2" -ge 1 ]]; then
        export FOCUSTERM_DEFAULT="$2"
        exec $SHELL
        echo "focusterm: default set to $2" >&2
      else
        echo "Usage: focusterm --default [n>=1]" >&2
        return 1
      fi
      return
      ;;
  esac

  local n="${1:-$FOCUSTERM_DEFAULT}"
  if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Usage: focusterm [n>=1] | --reset | --default [n>=1]" >&2
    return 1
  fi

  printf '\e[1;%sr' "$n"  # Set scroll region
  printf '\e[H'            # Move cursor to home
}