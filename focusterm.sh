#!/usr/bin/env bash
# focusterm: keep cursor near the middle/top of the terminal
# Usage:
#   focusterm [n>=1]         → keep cursor around n-th line from top
#   focusterm --reset|--disable
#   focusterm --default [n]
#   focusterm --enable
#   focusterm --uninstall

focusterm() {
  # Default
  if [[ -z "${FOCUSTERM_DEFAULT+x}" ]]; then
    FOCUSTERM_DEFAULT=13
  fi

  local rows
  rows=$(tput lines 2>/dev/null || echo 24)

  # Helpers
  _set_region() {  # keep n lines above, scroll below
    local n="$1"
    local top=$((n))
    local bottom=$((rows))
    printf '\e[%s;%sr\e[%sH' "$top" "$bottom" "$top"
  }
  _reset_region() {
    printf '\e[r\e[H'
  }

  case "$1" in
    --reset|--disable)
      _reset_region
      echo "focusterm: disabled" >&2
      return
      ;;
    --default)
      if [[ -n "$2" && "$2" =~ ^[0-9]+$ && "$2" -ge 1 ]]; then
        export FOCUSTERM_DEFAULT="$2"
        echo "focusterm: default set to $2" >&2
      else
        echo "Usage: focusterm --default [n>=1]" >&2
        return 1
      fi
      return
      ;;
    --enable)
      _set_region "$FOCUSTERM_DEFAULT"
      echo "focusterm: enabled (cursor ~line $FOCUSTERM_DEFAULT)" >&2
      return
      ;;
    --uninstall)
      _reset_region
      unset FOCUSTERM_DEFAULT
      unset -f focusterm
      echo "focusterm: uninstalled from current shell."
      echo "Remove it from your rc file to stop loading it automatically."
      return
      ;;
  esac

  local n="${1:-$FOCUSTERM_DEFAULT}"
  if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
    echo "Usage: focusterm [n>=1] | --reset | --default [n>=1] | --enable | --disable | --uninstall" >&2
    return 1
  fi
  (( n >= rows )) && n=$((rows - 1))

  _set_region "$n"
}
