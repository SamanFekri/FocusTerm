#!/usr/bin/env bash
# focusterm: keep the cursor near the middle of the terminal
# Usage:
#   focusterm [n>=1]        → set scroll region with n as top margin (default = saved value)
#   focusterm --reset        → reset scroll region
#   focusterm --default [n]  → set a new default value for future calls
#   focusterm --enable       → enable focusterm globally
#   focusterm --disable      → disable focusterm globally

f# --- FOCUSTERM: FIX CURSOR POSITION + SAFE ZSH HOOKS ---

# Replace the scroll-region logic inside focusterm when called without flags:
#   - top margin = n
#   - bottom margin = terminal height
#   - put cursor on row n (column 1)
# You don't need to change your existing function body above; this wrapper
# keeps behavior but sets correct margins when called normally.
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
      printf '\e[r'    # reset scroll region
      printf '\e[H'    # home cursor
      return
      ;;
    --default)
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ && "$2" -ge 1 ]]; then
        export FOCUSTERM_DEFAULT="$2"
        echo "focusterm: default set to $2" >&2
        if grep -q "FOCUSTERM_DEFAULT=" ~/.zshenv 2>/dev/null; then
          sed -i '' "s/^export FOCUSTERM_DEFAULT=.*/export FOCUSTERM_DEFAULT=$2/" ~/.zshenv 2>/dev/null || \
          sed -i "s/^export FOCUSTERM_DEFAULT=.*/export FOCUSTERM_DEFAULT=$2/" ~/.zshenv
        else
          echo "export FOCUSTERM_DEFAULT=$2" >> ~/.zshenv
        fi
        # Reload zshenv to pick up default immediately
        [[ -f ~/.zshenv ]] && source ~/.zshenv
      else
        echo "Usage: focusterm --default [n>=1]" >&2
        return 1
      fi
      return
      ;;
    --enable)
      export FOCUSTERM_ENABLED=1
      echo "focusterm: enabled" >&2
      if grep -q "FOCUSTERM_ENABLED=" ~/.zshenv 2>/dev/null; then
        sed -i '' "s/^export FOCUSTERM_ENABLED=.*/export FOCUSTERM_ENABLED=1/" ~/.zshenv 2>/dev/null || \
        sed -i "s/^export FOCUSTERM_ENABLED=.*/export FOCUSTERM_ENABLED=1/" ~/.zshenv
      else
        echo "export FOCUSTERM_ENABLED=1" >> ~/.zshenv
      fi
      [[ -f ~/.zshenv ]] && source ~/.zshenv
      return
      ;;
    --disable)
      export FOCUSTERM_ENABLED=0
      echo "focusterm: disabled" >&2
      if grep -q "FOCUSTERM_ENABLED=" ~/.zshenv 2>/dev/null; then
        sed -i '' "s/^export FOCUSTERM_ENABLED=.*/export FOCUSTERM_ENABLED=0/" ~/.zshenv 2>/dev/null || \
        sed -i "s/^export FOCUSTERM_ENABLED=.*/export FOCUSTERM_ENABLED=0/" ~/.zshenv
      else
        echo "export FOCUSTERM_ENABLED=0" >> ~/.zshenv
      fi
      printf '\e[r'
      printf '\e[H'
      [[ -f ~/.zshenv ]] && source ~/.zshenv
      return
      ;;
  esac

  # If disabled, skip everything
  if [[ "${FOCUSTERM_ENABLED:-1}" -eq 0 ]]; then
    return
  fi

  local n rows
  n="${1:-$FOCUSTERM_DEFAULT}"

  if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Usage: focusterm [n>=1] | --reset | --default [n>=1] | --enable | --disable" >&2
    return 1
  fi

  # Prefer zsh's $LINES, fallback to tput
  rows="${LINES:-}"
  if ! [[ "$rows" =~ ^[0-9]+$ ]]; then
    rows="$(tput lines 2>/dev/null || echo 9999)"
  fi

  # Set scroll region from row n to bottom, then place cursor on row n
  printf '\e[%s;%sr' "$n" "$rows"
  printf '\e[%sH' "$n"
}

# --- ZSH INTEGRATION (only in interactive zsh) ---
if [[ -n "${ZSH_VERSION-}" ]] && [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook 2>/dev/null || true

  focusterm_precmd() {
    (( ${FOCUSTERM_ENABLED:-1} )) && focusterm
  }
  add-zsh-hook precmd focusterm_precmd 2>/dev/null || true

  TRAPWINCH() {
    (( ${FOCUSTERM_ENABLED:-1} )) && focusterm
    return 0
  }

  # Guard zle widget registration; it's only valid inside interactive shells
  focusterm_zle_line_init() {
    (( ${FOCUSTERM_ENABLED:-1} )) && focusterm
  }
  zle -N zle-line-init focusterm_zle_line_init 2>/dev/null || true
fi
# --- END FOCUSTERM BLOCK ---
