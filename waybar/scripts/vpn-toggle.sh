#!/bin/bash
# ~/.config/waybar/scripts/vpn-toggle.sh
# VPN connect/disconnect menu for Waybar click action

WG_DIR="/etc/wireguard"

declare -A ISO_NAMES=(
  ["al"]="Albania" ["ar"]="Argentina" ["at"]="Austria" ["au"]="Australia"
  ["ba"]="Bosnia" ["be"]="Belgium" ["bg"]="Bulgaria" ["br"]="Brazil"
  ["ca"]="Canada" ["ch"]="Switzerland" ["cl"]="Chile" ["co"]="Colombia"
  ["cy"]="Cyprus" ["cz"]="Czech Republic" ["de"]="Germany" ["dk"]="Denmark"
  ["ee"]="Estonia" ["eg"]="Egypt" ["es"]="Spain" ["fi"]="Finland"
  ["fr"]="France" ["gb"]="United Kingdom" ["ge"]="Georgia" ["gr"]="Greece"
  ["hk"]="Hong Kong" ["hr"]="Croatia" ["hu"]="Hungary" ["id"]="Indonesia"
  ["ie"]="Ireland" ["il"]="Israel" ["in"]="India" ["is"]="Iceland"
  ["it"]="Italy" ["jp"]="Japan" ["kr"]="South Korea" ["lt"]="Lithuania"
  ["lu"]="Luxembourg" ["lv"]="Latvia" ["md"]="Moldova" ["mk"]="North Macedonia"
  ["mx"]="Mexico" ["my"]="Malaysia" ["ng"]="Nigeria" ["nl"]="Netherlands"
  ["no"]="Norway" ["nz"]="New Zealand" ["pl"]="Poland" ["pt"]="Portugal"
  ["ro"]="Romania" ["rs"]="Serbia" ["se"]="Sweden" ["sg"]="Singapore"
  ["si"]="Slovenia" ["sk"]="Slovakia" ["th"]="Thailand" ["tr"]="Turkey"
  ["tw"]="Taiwan" ["ua"]="Ukraine" ["us"]="United States" ["vn"]="Vietnam"
  ["za"]="South Africa"
)

get_active_iface() {
  wg show interfaces 2>/dev/null | tr ' ' '\n' | grep '^proton-' | head -1
}

active=$(get_active_iface)

if [[ -n "$active" ]]; then
  code="${active#proton-}"
  country="${ISO_NAMES[$code]:-${code^^}}"
  echo ""
  echo "  Connected → $country"
  echo ""
  read -rp "  Disconnect? [y/N]: " answer
  if [[ "${answer,,}" == "y" ]]; then
    echo ""
    sudo vpnUp off
  fi
else
  # Build list by parsing vpnUp --list (avoids needing direct /etc/wireguard access)
  declare -a CODES=()
  while IFS= read -r line; do
    code=$(echo "$line" | awk '{print $1}')
    [[ "$code" =~ ^[a-z]{2}$ ]] && CODES+=("$code")
  done < <(sudo vpnUp --list 2>/dev/null | grep -E '^\s+[a-z]{2}\s')

  if [[ ${#CODES[@]} -eq 0 ]]; then
    echo ""
    echo "  No VPN configs found. Run vpnSetup.sh first."
    echo ""
    read -rp "  Press Enter to close..." _
    exit 1
  fi

  echo ""
  echo "  Select a country to connect:"
  echo ""

  for i in "${!CODES[@]}"; do
    code="${CODES[$i]}"
    name="${ISO_NAMES[$code]:-${code^^}}"
    printf "  [%d] %-6s %s\n" "$((i+1))" "$code" "$name"
  done

  echo ""
  read -rp "  Enter number (or 'q' to cancel): " choice

  [[ "$choice" == "q" || -z "$choice" ]] && exit 0

  if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#CODES[@]} )); then
    echo "  Invalid selection."
    sleep 1
    exit 1
  fi

  selected="${CODES[$((choice-1))]}"
  echo ""
  sudo vpnUp "$selected"
fi

# Signal Waybar to refresh the VPN module
pkill -SIGRTMIN+11 waybar
