#!/usr/bin/env bash
# Catalogue d'applications : lecture des fichiers apps.list et installation
# de la sélection via un Brewfile temporaire.
# Dépend de : LAYERS (tableau), helpers.sh (logs), menu.sh.

# Charge le catalogue de toutes les couches dans des tableaux parallèles :
#   APP_TYPE  APP_ID  APP_LABEL  APP_DEFAULT
# Format d'une ligne apps.list :  type|identifiant|libellé|on|off
load_apps() {
  APP_TYPE=(); APP_ID=(); APP_LABEL=(); APP_DEFAULT=()
  local layer f type id label def
  for layer in "${LAYERS[@]}"; do
    f="$layer/apps.list"
    [[ -f "$f" ]] || continue
    while IFS='|' read -r type id label def || [[ -n "$type" ]]; do
      type="${type%$'\r'}"; def="${def%$'\r'}"   # tolère un CR résiduel
      case "$type" in ''|'#'*) continue ;; esac   # ignore vides + commentaires
      APP_TYPE+=("$type")
      APP_ID+=("$id")
      APP_LABEL+=("$label")
      if [[ "$def" == "on" ]]; then APP_DEFAULT+=("on"); else APP_DEFAULT+=("off"); fi
    done < "$f"
  done
}

# Prépare le menu (MENU_LABELS / MENU_DEFAULTS) à partir du catalogue chargé.
build_app_menu() {
  MENU_LABELS=(); MENU_DEFAULTS=()
  local i
  for ((i = 0; i < ${#APP_TYPE[@]}; i++)); do
    MENU_LABELS+=("${APP_LABEL[$i]} (${APP_TYPE[$i]})")
    MENU_DEFAULTS+=("${APP_DEFAULT[$i]}")
  done
}

# Initialise app_selected depuis les valeurs par défaut du catalogue
# (utilisé en mode non interactif).
apps_select_defaults() {
  app_selected=()
  local i
  for ((i = 0; i < ${#APP_TYPE[@]}; i++)); do
    if [[ "${APP_DEFAULT[$i]}" == "on" ]]; then app_selected+=("true"); else app_selected+=("false"); fi
  done
}

# Installe les apps cochées (tableau global app_selected) via brew bundle.
install_apps_from_selection() {
  local tmp i type id label printed=0
  tmp="$(mktemp "${TMPDIR:-/tmp}/brewfile.XXXXXX")"
  for ((i = 0; i < ${#APP_TYPE[@]}; i++)); do
    [[ "${app_selected[$i]:-false}" == "true" ]] || continue
    type="${APP_TYPE[$i]}"; id="${APP_ID[$i]}"; label="${APP_LABEL[$i]}"
    case "$type" in
      brew) printf 'brew "%s"\n'           "$id"          >> "$tmp" ;;
      cask) printf 'cask "%s"\n'           "$id"          >> "$tmp" ;;
      mas)  printf 'mas "%s", id: %s\n'    "$label" "$id" >> "$tmp" ;;
      tap)  printf 'tap "%s"\n'            "$id"          >> "$tmp" ;;
      *)    warn "type inconnu ignoré : $type ($id)" ;;
    esac
    printed=1
  done
  if [[ $printed -eq 1 ]]; then
    info "Installation des applications sélectionnées…"
    brew bundle --file="$tmp"
    ok "Applications installées."
  else
    warn "Aucune application sélectionnée — rien à installer."
  fi
  rm -f "$tmp"
}
