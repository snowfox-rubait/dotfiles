#!/bin/bash
# ~/.config/waybar/scripts/monitor-set.sh

current_brightness=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')
current_contrast=$(ddcutil getvcp 12 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')

read -rp "Brightness (current: ${current_brightness:-?}, 0-100, Enter to skip): " brightness
read -rp "Contrast   (current: ${current_contrast:-?}, 0-100, Enter to skip): " contrast

if [[ -n "$brightness" && "$brightness" =~ ^[0-9]+$ && "$brightness" -le 100 ]]; then
  ddcutil setvcp 10 "$brightness"
fi

if [[ -n "$contrast" && "$contrast" =~ ^[0-9]+$ && "$contrast" -le 100 ]]; then
  ddcutil setvcp 12 "$contrast"
fi

pkill -SIGRTMIN+11 waybar
