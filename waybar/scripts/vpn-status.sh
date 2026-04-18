#!/bin/bash
# Outputs JSON for Waybar custom module

declare -A COUNTRY_NAMES=(
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

active=""
for iface in $(wg show interfaces 2>/dev/null); do
  if [[ "$iface" == proton-* ]]; then
    active="$iface"
    break
  fi
done

if [[ -n "$active" ]]; then
  code="${active#proton-}"
  country="${COUNTRY_NAMES[$code]:-$code}"
  echo "{\"text\":\"󰦝\", \"tooltip\":\"VPN: $country\\nLeft-click to disconnect\", \"class\":\"connected\"}"
else
  echo "{\"text\":\"󰦞\", \"tooltip\":\"VPN: Off\\nLeft-click to connect\", \"class\":\"disconnected\"}"
fi
