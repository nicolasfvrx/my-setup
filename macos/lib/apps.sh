#!/usr/bin/env bash
# Catalogue d'applications : lecture des fichiers apps.list et installation
# de la sélection via un Brewfile temporaire.
# Dépend de : LAYERS (tableau), helpers.sh (logs), menu.sh.

# Charge le catalogue de toutes les couches.
# Apps (items)        : APP_TYPE  APP_ID  APP_LABEL  APP_DEFAULT
# Plan du menu (rows) : CAT_KIND  CAT_TEXT  CAT_APP  CAT_DEFAULT
#   - une ligne "# --- Nom ---" devient un en-tête (CAT_KIND=header)
#   - une ligne "type|id|libellé|on/off" devient un item, lié à un index APP_*
load_apps() {
  APP_TYPE=(); APP_ID=(); APP_LABEL=(); APP_DEFAULT=()
  CAT_KIND=(); CAT_TEXT=(); CAT_APP=(); CAT_DEFAULT=()
  local layer f line trimmed type id label def appidx
  for layer in "${LAYERS[@]}"; do
    f="$layer/apps.list"
    [[ -f "$f" ]] || continue
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%$'\r'}"

      # En-tête de catégorie :  # --- Nom ---
      if [[ "$line" =~ ^[[:space:]]*#[[:space:]]*-+[[:space:]]+(.+)[[:space:]]+-+[[:space:]]*$ ]]; then
        CAT_KIND+=("header"); CAT_TEXT+=("${BASH_REMATCH[1]}"); CAT_APP+=("-1"); CAT_DEFAULT+=("")
        continue
      fi

      # Commentaire simple ou ligne vide → ignore
      trimmed="${line#"${line%%[![:space:]]*}"}"
      [[ -z "$trimmed" || "$trimmed" == '#'* ]] && continue

      # Ligne d'app : type|id|libellé|on/off
      IFS='|' read -r type id label def <<< "$line"
      [[ -z "$type" ]] && continue
      APP_TYPE+=("$type"); APP_ID+=("$id"); APP_LABEL+=("$label")
      if [[ "$def" == "on" ]]; then APP_DEFAULT+=("on"); else APP_DEFAULT+=("off"); fi

      appidx=$(( ${#APP_TYPE[@]} - 1 ))
      CAT_KIND+=("item"); CAT_TEXT+=("$label ($type)"); CAT_APP+=("$appidx"); CAT_DEFAULT+=("${APP_DEFAULT[$appidx]}")
    done < "$f"
  done
}

# Prépare le menu (MENU_*) à partir du plan chargé (en-têtes inclus).
build_app_menu() {
  MENU_LABELS=(); MENU_DEFAULTS=(); MENU_KIND=(); MENU_APP=()
  local i
  for ((i = 0; i < ${#CAT_KIND[@]}; i++)); do
    MENU_KIND+=("${CAT_KIND[$i]}")
    MENU_LABELS+=("${CAT_TEXT[$i]}")
    MENU_DEFAULTS+=("${CAT_DEFAULT[$i]:-off}")
    MENU_APP+=("${CAT_APP[$i]}")
  done
}

# Initialise app_selected depuis les valeurs par défaut (mode non interactif).
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
