#!/usr/bin/env bash
#
# Réglages spécifiques à macOS 26 (Tahoe).
# Tout ce qui est commun à toutes les versions va dans ../common/system.sh.
# Ce script est exécuté APRÈS common/system.sh (il peut donc surcharger).
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

info "Réglages spécifiques Tahoe…"

# Exemple : macOS 26 introduit le thème « Liquid Glass » / nouvelles options d'apparence.
# Ajouter ici les `defaults` propres à Tahoe au fur et à mesure.

ok "Réglages Tahoe appliqués (rien d'actif pour l'instant)."
