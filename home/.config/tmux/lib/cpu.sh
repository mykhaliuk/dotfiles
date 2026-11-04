#!/usr/bin/env bash
# CPU usage widget — sets $cpu_part
# Uses two top samples (1s apart) for accurate CPU utilisation percentage,
# plus a 4-cell braille sparkline of recent history (8 samples, 2 cols/cell).

HISTORY_FILE="$HOME/.cache/tmux-cpu-history"
MAX_SAMPLES=16

cpu_pct=$(top -l 2 -n 0 -s 1 | awk '/CPU usage/ {gsub(/%/,""); last=100-$7} END {printf "%d", last}')

# Persist history (oldest → newest, last $MAX_SAMPLES kept)
{
  [ -f "$HISTORY_FILE" ] && cat "$HISTORY_FILE"
  echo "${cpu_pct:-0}"
} | tail -n "$MAX_SAMPLES" > "${HISTORY_FILE}.tmp" && mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

# Read samples (portable, no mapfile — works in bash 3.2)
samples=()
while IFS= read -r line; do samples+=("$line"); done < "$HISTORY_FILE"

# Left-pad with zeros if we have fewer than MAX_SAMPLES on first runs
while [ "${#samples[@]}" -lt "$MAX_SAMPLES" ]; do
  samples=(0 "${samples[@]}")
done

# Braille dot masks per column height (0..4)
# Layout per cell:  1 4
#                   2 5
#                   3 6
#                   7 8
# Left col bottom-up: dots 7,3,2,1 → bits 0x40, 0x44, 0x46, 0x47
# Right col bottom-up: dots 8,6,5,4 → bits 0x80, 0xA0, 0xB0, 0xB8
left_masks=(0x00 0x40 0x44 0x46 0x47)
right_masks=(0x00 0x80 0xA0 0xB0 0xB8)

sparkline=""
for cell in 0 1 2 3 4 5 6 7; do
  l_pct=${samples[$((cell * 2))]:-0}
  r_pct=${samples[$((cell * 2 + 1))]:-0}
  l_lvl=$(( (l_pct + 12) / 25 ))
  r_lvl=$(( (r_pct + 12) / 25 ))
  [ $l_lvl -gt 4 ] && l_lvl=4
  [ $r_lvl -gt 4 ] && r_lvl=4
  mask=$(( ${left_masks[$l_lvl]} | ${right_masks[$r_lvl]} ))
  # U+2800 + mask → 3-byte UTF-8: 0xE2 (0xA0|top2(mask)) (0x80|low6(mask))
  b2=$(printf '%02x' "$((0xA0 + (mask >> 6)))")
  b3=$(printf '%02x' "$((0x80 + (mask & 0x3F)))")
  sparkline+=$(printf "\xe2\x${b2}\x${b3}")
done

if   [ "${cpu_pct:-0}" -ge 80 ]; then cpu_color="#f7767e"
elif [ "${cpu_pct:-0}" -ge 50 ]; then cpu_color="#ff9e64"
else                                   cpu_color="#9ece6a"
fi

cpu_part="#[fg=${cpu_color}]󰘚 ${sparkline} ${cpu_pct}%#[default]"
