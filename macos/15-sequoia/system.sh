#!/usr/bin/env bash
#
# Réglages spécifiques à macOS 15 (Sequoia).
# Tout ce qui est commun à toutes les versions va dans ../common/system.sh.
# Ce script est exécuté APRÈS common/system.sh (il peut donc surcharger).
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

info "Réglages spécifiques Sequoia…"

# Exemple : Sequoia a introduit le tuilage des fenêtres (window tiling).
# Marges entre fenêtres tuilées :
# defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

ok "Réglages Sequoia appliqués (rien d'actif pour l'instant)."
