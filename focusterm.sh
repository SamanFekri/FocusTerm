#!/usr/bin/env bash
# focusterm: keep the cursor near the middle of the terminal
# Usage:
#   focusterm [n>=1]        → set scroll region with n as top margin (default = saved value)
#   focusterm --reset        → reset scroll region
#   focusterm --default [n]  → set a new default value for future calls
#   focusterm --enable       → enable focusterm globally
#   focusterm --disable      → disable focusterm globally

focusterm() {
  # Use global defaults if not already set
  if [[ -z "${FOCUSTERM_DEFAULT+x}" ]]; then
    export FOCUSTERM_DEFAULT=13
  fi
  if [[ -z "${FOCUSTERM_ENABLED+x}" ]]; then
    export FOCUSTERM_ENABLED=1
  fi

  case "$1" in
    --reset)
      printf '\e[r'
      printf '\e[H'
      return
      ;;
    --default)
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ && "$2" -ge 1 ]]; then
        export FOCUSTERM_DEFAULT="$2"
        echo "focusterm: default set to $2" >&2
        # Update global environment variable permanently
        if grep -q "FOCUSTERM_DEFAULT=" ~/.zshenv; then
          sed -i '' "s/^export FOCUSTERM_DEFAULT=.*/export FOCUSTERM_DEFAULT=$2/" ~/.zshenv
        else
          echo "export FOCUSTERM_DEFAULT=$2" >> ~/.zshenv
        fi
        source ~/.zshrc
      else
        echo "Usage: focusterm --default [n>=1]" >&2
        return 1
      fi
      return
      ;;
    --enable)
      export FOCUSTERM_ENABLED=1
      echo "focusterm: enabled" >&2
      if grep -q "FOCUSTERM_ENABLED=" ~/.zshenv; then
        sed -i '' "s/^export FOCUSTERM_ENABLED=.*/export FOCUSTERM_ENABLED=1/" ~/.zshenv
      else
        echo "export FOCUSTERM_ENABLED=1" >> ~/.zshenv
      fi
      source ~/.zshrc
      return
      ;;
    --disable)
      export FOCUSTERM_ENABLED=0
      echo "focusterm: disabled" >&2
      if grep -q "FOCUSTERM_ENABLED=" ~/.zshenv; then
        sed -i '' "s/^export FOCUSTERM_ENABLED=.*/export FOCUSTERM_ENABLED=0/" ~/.zshenv
      else
        echo "export FOCUSTERM_ENABLED=0" >> ~/.zshenv
      fi
      printf '\e[r'
      printf '\e[H'
      source ~/.zshrc
      return
      ;;
  esac

  # If disabled, skip everything
  if [[ "$FOCUSTERM_ENABLED" -eq 0 ]]; then
    return
  fi

  local n="${1:-$FOCUSTERM_DEFAULT}"
  if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Usage: focusterm [n>=1] | --reset | --default [n>=1] | --enable | --disable" >&2
    return 1
  fi

  printf '\e[1;%sr' "$n"
  printf '\e[H'
}
