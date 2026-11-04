#!/usr/bin/env bash
# Shared palette and utility functions

# Tokyo Night Storm palette (tmux format)
C_RED="#[fg=#f7767e]"
C_ORANGE="#[fg=#ff9e64]"
C_GREEN="#[fg=#9ece6a]"
C_GRAY="#[fg=#565f89]"
C_RESET="#[default]"

get_pct_color() {
  local pct="$1"
  if [[ $pct -gt 75 ]]; then
    echo "$C_RED"
  elif [[ $pct -gt 50 ]]; then
    echo "$C_ORANGE"
  else
    echo "$C_GREEN"
  fi
}

make_bar() {
  local pct="$1"
  local color="$2"
  local width=10
  local steps=$((width * 8))
  local sub=$((pct * steps / 100))
  [[ $sub -gt $steps ]] && sub=$steps
  [[ $sub -lt 0 ]] && sub=0

  local full=$((sub / 8))
  local rem=$((sub % 8))
  local has_partial=0
  [[ $rem -gt 0 ]] && has_partial=1
  local empty=$((width - full - has_partial))

  local partials=("" "⡀" "⡄" "⡆" "⡇" "⣇" "⣧" "⣷")

  local bar="" i
  for ((i=0; i<full;  i++)); do bar+="⣿"; done
  [[ $has_partial -eq 1 ]] && bar+="${partials[$rem]}"
  for ((i=0; i<empty; i++)); do bar+="⠀"; done

  printf "${color}%s${C_RESET}" "$bar"
}

get_file_age() {
  local file="$1"
  local mod_time=$(stat -f '%m' "$file" 2>/dev/null)
  local now=$(date +%s)
  echo $((now - mod_time))
}

format_remaining_time() {
  local seconds="$1"
  if [[ $seconds -le 0 ]]; then echo "0m"; return; fi
  local hours=$((seconds / 3600))
  local mins=$(((seconds % 3600) / 60))
  [[ $hours -gt 0 ]] && echo "${hours}h${mins}m" || echo "${mins}m"
}

format_remaining_time_days() {
  local seconds="$1"
  if [[ $seconds -le 0 ]]; then echo "0m"; return; fi
  local days=$((seconds / 86400))
  local hours=$(((seconds % 86400) / 3600))
  local mins=$(((seconds % 3600) / 60))
  if   [[ $days  -gt 0 ]]; then echo "${days}d${hours}h"
  elif [[ $hours -gt 0 ]]; then echo "${hours}h${mins}m"
  else                          echo "${mins}m"
  fi
}

parse_iso_to_seconds_left() {
  local iso_date="$1"
  local clean_date=$(echo "$iso_date" | sed 's/\.[0-9]*//; s/+00:00//; s/Z$//')
  local reset_ts=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$clean_date" "+%s" 2>/dev/null)
  if [[ -n "$reset_ts" ]]; then
    local now=$(date +%s)
    echo $((reset_ts - now))
  else
    echo ""
  fi
}
