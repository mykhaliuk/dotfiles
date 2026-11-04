#!/usr/bin/env bash
# Battery widget — sets $icon, $pct, $batt_color

batt_line=$(pmset -g batt | grep InternalBattery)
pct=$(echo "$batt_line" | grep -o '[0-9]*%' | tr -d '%')
state=$(echo "$batt_line" | grep -oE 'charged|charging|discharging')

case "$state" in
  charged)
    icon='󰁹'
    batt_color='#a9dc76' ;;
  charging)
    if   [ "${pct:-0}" -ge 90 ]; then icon='󰂆'
    elif [ "${pct:-0}" -ge 80 ]; then icon='󰂇'
    elif [ "${pct:-0}" -ge 70 ]; then icon='󰂈'
    elif [ "${pct:-0}" -ge 60 ]; then icon='󰂉'
    elif [ "${pct:-0}" -ge 50 ]; then icon='󰂊'
    elif [ "${pct:-0}" -ge 40 ]; then icon='󰂋'
    elif [ "${pct:-0}" -ge 30 ]; then icon='󰂌'
    elif [ "${pct:-0}" -ge 20 ]; then icon='󰂍'
    else                               icon='󰂎'
    fi
    batt_color='#ffd866' ;;
  discharging|*)
    if   [ "${pct:-0}" -ge 90 ]; then icon='󰁹'
    elif [ "${pct:-0}" -ge 80 ]; then icon='󰂂'
    elif [ "${pct:-0}" -ge 70 ]; then icon='󰂁'
    elif [ "${pct:-0}" -ge 60 ]; then icon='󰁿'
    elif [ "${pct:-0}" -ge 50 ]; then icon='󰁾'
    elif [ "${pct:-0}" -ge 40 ]; then icon='󰁽'
    elif [ "${pct:-0}" -ge 30 ]; then icon='󰁼'
    elif [ "${pct:-0}" -ge 20 ]; then icon='󰁻'
    else                               icon='󰁺'
    fi
    [ "${pct:-100}" -le 20 ] && batt_color='#ff6188' || batt_color='#c0caf5' ;;
esac
