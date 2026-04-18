#!/bin/bash
# ~/.config/waybar/scripts/monitor-status.sh
# Outputs JSON for Waybar custom/monitor module

brightness=$(ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')
contrast=$(ddcutil getvcp 12 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')

if [[ -z "$brightness" || -z "$contrast" ]]; then
  echo '{"text": "󰍹", "tooltip": "Monitor: unavailable", "class": "unavailable"}'
else
  echo "{\"text\": \"󰍹\", \"tooltip\": \"Brightness: ${brightness}%\nContrast: ${contrast}%\", \"class\": \"active\"}"
fi
