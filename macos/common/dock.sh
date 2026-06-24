#!/usr/bin/env bash
#
# Configuration du Dock : comportement + icônes (via dockutil).
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

command -v dockutil >/dev/null 2>&1 || { err "dockutil manquant — lance d'abord l'étape brew"; exit 1; }

info "Configuration du Dock…"

# === Comportement (defaults) ===
defaults write com.apple.dock tilesize -int 48                  # taille des icônes
defaults write com.apple.dock autohide -bool true               # masquage auto
defaults write com.apple.dock autohide-delay -float 0           # pas de délai avant apparition
defaults write com.apple.dock autohide-time-modifier -float 0.25 # animation rapide
defaults write com.apple.dock show-recents -bool false          # pas d'apps récentes
defaults write com.apple.dock minimize-to-application -bool true # réduire dans l'icône de l'app
defaults write com.apple.dock orientation -string "bottom"      # bottom | left | right
defaults write com.apple.dock mru-spaces -bool false            # ne pas réorganiser les Spaces

# === Icônes ===
# Liste ordonnée. Édite à ta convenance — les chemins absents sont ignorés.
APPS=(
  "/System/Applications/Launchpad.app"
  "/Applications/Safari.app"
  # "/Applications/Arc.app"
  # "/Applications/Ghostty.app"
  # "/Applications/Visual Studio Code.app"
  "/System/Applications/System Settings.app"
)

dockutil --no-restart --remove all >/dev/null 2>&1 || true
for app in "${APPS[@]}"; do
  if [[ -e "$app" ]]; then
    dockutil --no-restart --add "$app" >/dev/null
  else
    warn "introuvable, ignoré : $app"
  fi
done

# (optionnel) ajouter un dossier au Dock — ex. Téléchargements en grille :
# dockutil --no-restart --add "$HOME/Downloads" --view grid --display folder --sort dateadded

killall Dock
ok "Dock configuré."
