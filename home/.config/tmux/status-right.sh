#!/usr/bin/env bash
# Tmux right status: CPU + Claude Code limits (API) + battery

LIB="$(dirname "$0")/lib"

# shellcheck source=lib/helpers.sh
source "$LIB/helpers.sh"
# shellcheck source=lib/cpu.sh
source "$LIB/cpu.sh"
# shellcheck source=lib/claude.sh
[[ -f "$LIB/claude.sh" ]] && source "$LIB/claude.sh"
# shellcheck source=lib/battery.sh
source "$LIB/battery.sh"

# ─── Output ──────────────────────────────────────────────────────────────────
SEP=" #[fg=#565f89]│ #[default]"

if [[ -n "$claude_part" ]]; then
  echo "${cpu_part}${SEP}${claude_part}${SEP}#[fg=${batt_color}]${icon} ${pct}%"
else
  echo "${cpu_part}${SEP}#[fg=${batt_color}]${icon} ${pct}%"
fi
