#!/usr/bin/env bash
#
# Setup macOS — menu interactif d'installation (apps) et de configuration (OS).
# Détecte la version de macOS et applique la cascade : common/ -> <version>/
#
# Usage :
#   bash install.sh                 # menu interactif (header + sélection)
#   bash install.sh dock            # mode direct : une étape, sans menu
#   bash install.sh system dock     # mode direct : plusieurs étapes
#   bash install.sh -h              # aide
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/lib/helpers.sh"
source "$ROOT/lib/menu.sh"
source "$ROOT/lib/apps.sh"

trap 'printf "\033[?25h"' EXIT INT TERM   # ré-affiche le curseur quoi qu'il arrive

# --- Détection de la couche de version (dossier "<major>-*") ---
MAJOR="$(macos_major)"
VERSION_DIR=""
for d in "$ROOT/${MAJOR}-"*/; do
  [[ -d "$d" ]] && { VERSION_DIR="${d%/}"; break; }
done
LAYERS=("$ROOT/common")
[[ -n "$VERSION_DIR" ]] && LAYERS+=("$VERSION_DIR")

# --- Métadonnées (version + date de maj liées à la version d'OS) ---
SCRIPT_CODENAME=""; SCRIPT_VERSION="0.0.0"; SCRIPT_UPDATED="—"
[[ -n "$VERSION_DIR" && -f "$VERSION_DIR/meta.env" ]] && source "$VERSION_DIR/meta.env"

app_selected=()   # rempli par le menu ou par les défauts

usage() {
  cat <<EOF
Setup macOS — installe les apps (Homebrew) et configure l'OS.

  bash install.sh                 menu interactif
  bash install.sh ÉTAPE...        mode direct, sans menu
  bash install.sh -h | --help     cette aide

Étapes : brew  system  dock  wallpaper
EOF
}

# --- Briques ---
install_base_brew() {
  local layer
  for layer in "${LAYERS[@]}"; do
    [[ -f "$layer/Brewfile" ]] && {
      info "Outils requis → ${layer##*/}/Brewfile"
      brew bundle --file="$layer/Brewfile"
    }
  done
}

run_step() {
  local script="$1" layer
  for layer in "${LAYERS[@]}"; do
    [[ -f "$layer/$script" ]] && { info "→ ${layer##*/}/$script"; bash "$layer/$script"; }
  done
}

step_brew() {
  ensure_brew
  install_base_brew
  load_apps
  [[ ${#app_selected[@]} -eq 0 ]] && apps_select_defaults   # mode direct → défauts
  install_apps_from_selection
}

count_true() {
  local i n=0
  for ((i = 0; i < ${#app_selected[@]}; i++)); do
    [[ "${app_selected[$i]}" == "true" ]] && n=$((n + 1))
  done
  echo "$n"
}

# --- Mode direct (arguments) ---
run_steps() {
  local s
  for s in "$@"; do
    case "$s" in
      brew)      step_brew ;;
      system)    run_step system.sh ;;
      dock)      run_step dock.sh ;;
      wallpaper) run_step wallpaper.sh ;;
      *)         warn "Étape inconnue : $s  (brew | system | dock | wallpaper)" ;;
    esac
  done
}

# --- Mode interactif (menu) ---
interactive() {
  # 1) Quelles étapes ?
  MENU_LABELS=("Installer des applications" "Réglages système" "Dock (icônes + comportement)" "Fond d'écran")
  MENU_DEFAULTS=("on" "on" "on" "on")
  multiselect "Que veux-tu faire ?" || { warn "Annulé."; return 1; }
  local do_apps="${MENU_SELECTED[0]}" do_sys="${MENU_SELECTED[1]}"
  local do_dock="${MENU_SELECTED[2]}" do_wall="${MENU_SELECTED[3]}"

  # 2) Quelles applications ?
  if [[ "$do_apps" == "true" ]]; then
    load_apps
    if [[ ${#APP_TYPE[@]} -gt 0 ]]; then
      build_app_menu
      echo
      multiselect "Applications à installer" || { warn "Annulé."; return 1; }
      app_selected=("${MENU_SELECTED[@]}")
    else
      warn "Catalogue d'apps vide (apps.list) — étape ignorée."
      do_apps="false"
    fi
  fi

  # 3) Récapitulatif + confirmation
  echo
  info "Récapitulatif :"
  [[ "$do_apps" == "true" ]] && printf '   • %s application(s)\n' "$(count_true)"
  [[ "$do_sys"  == "true" ]] && printf '   • Réglages système\n'
  [[ "$do_dock" == "true" ]] && printf '   • Dock\n'
  [[ "$do_wall" == "true" ]] && printf "   • Fond d'écran\n"
  echo
  printf 'Lancer ? [O/n] '
  local ans=""; read -r ans || true
  case "$ans" in [Nn]*) warn "Abandon."; return 1 ;; esac

  # 4) Exécution
  if [[ "$do_apps" == "true" ]]; then
    ensure_brew
    install_base_brew
    install_apps_from_selection
  fi
  [[ "$do_sys"  == "true" ]] && run_step system.sh
  [[ "$do_dock" == "true" ]] && run_step dock.sh
  [[ "$do_wall" == "true" ]] && run_step wallpaper.sh
  ok "Terminé."
}

main() {
  case "${1:-}" in -h|--help) usage; return 0 ;; esac

  print_header

  if [[ $# -gt 0 ]]; then
    run_steps "$@"                     # mode direct
  elif [[ ! -t 0 || ! -t 1 ]]; then
    warn "Terminal non interactif — exécution complète avec les valeurs par défaut."
    run_steps brew system dock wallpaper
  else
    interactive                        # menu
  fi
}

main "$@"
