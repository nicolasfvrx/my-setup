#!/usr/bin/env bash
#
# Définit le fond d'écran sur tous les bureaux / écrans.
#
# Usage :
#   bash wallpaper.sh                 # utilise assets/wallpaper/wallpaper.jpg
#   bash wallpaper.sh /chemin/img.png # image explicite
#
set -euo pipefail
MACOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$MACOS_DIR/lib/helpers.sh"

WALLPAPER="${1:-$MACOS_DIR/assets/wallpaper/wallpaper.jpg}"

if [[ ! -f "$WALLPAPER" ]]; then
  warn "Aucun fond d'écran trouvé ($WALLPAPER) — étape ignorée."
  warn "Dépose une image dans macos/assets/wallpaper/wallpaper.jpg"
  exit 0
fi

info "Application du fond d'écran : $WALLPAPER"
osascript -e "tell application \"System Events\" to set picture of every desktop to \"$WALLPAPER\""
ok "Fond d'écran appliqué."
