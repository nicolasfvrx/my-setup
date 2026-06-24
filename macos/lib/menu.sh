#!/usr/bin/env bash
# Sélecteur multi-choix en bash pur — compatible bash 3.2 (macOS d'origine).
# Aucune dépendance externe (pas de dialog/whiptail/gum).
#
# Entrées (variables globales) :
#   MENU_LABELS    tableau des libellés à afficher
#   MENU_DEFAULTS  tableau "on"/"off" (présélection des items)
#   MENU_KIND      tableau "item"/"header" (optionnel ; défaut = item)
#                  un "header" = séparateur de catégorie, non sélectionnable
# Sortie (variable globale) :
#   MENU_SELECTED  tableau "true"/"false" (les headers restent "false")
# Code retour : 0 = validé (Entrée)  ·  1 = annulé (q)

# Déplace le curseur de $1 (+1/-1) en sautant les en-têtes (scope dynamique bash).
_menu_step() {
  local dir="$1" g=0
  while :; do
    cursor=$(( (cursor + dir + count) % count ))
    g=$(( g + 1 ))
    [[ "${MENU_KIND[$cursor]:-item}" == "item" ]] && break
    [[ $g -gt $count ]] && break        # que des headers → évite la boucle infinie
  done
}

multiselect() {
  local title="$1"
  local count=${#MENU_LABELS[@]}
  local i box picked items

  # Présélection (les headers ne sont jamais cochés)
  MENU_SELECTED=()
  for ((i = 0; i < count; i++)); do
    if [[ "${MENU_KIND[$i]:-item}" == "item" && "${MENU_DEFAULTS[$i]:-off}" == "on" ]]; then
      MENU_SELECTED[$i]="true"
    else
      MENU_SELECTED[$i]="false"
    fi
  done

  # Curseur initial sur le premier item (pas un header)
  local cursor=0 g=0
  while [[ "${MENU_KIND[$cursor]:-item}" == "header" ]]; do
    cursor=$((cursor + 1)); g=$((g + 1))
    [[ $cursor -ge $count || $g -gt $count ]] && { cursor=0; break; }
  done

  local total=$((count + 4))   # titre + aide + ligne vide + lignes + pied
  local first=1 key rest

  printf '\033[?25l'           # masque le curseur du terminal
  while true; do
    if [[ $first -eq 1 ]]; then first=0; else printf '\033[%dA' "$total"; fi

    printf '\033[1m%s\033[0m\033[K\n' "$title"
    printf '\033[2m  ↑/↓ ou j/k · espace: cocher · a: tout · n: rien · entrée: valider · q: annuler\033[0m\033[K\n'
    printf '\033[K\n'
    for ((i = 0; i < count; i++)); do
      if [[ "${MENU_KIND[$i]:-item}" == "header" ]]; then
        printf '  \033[2m──\033[0m \033[1m%s\033[0m \033[2m────────────\033[0m\033[K\n' "${MENU_LABELS[$i]}"
      else
        box="[ ]"; [[ "${MENU_SELECTED[$i]}" == "true" ]] && box="[x]"
        if [[ $i -eq $cursor ]]; then
          printf '\033[36m> %s %s\033[0m\033[K\n' "$box" "${MENU_LABELS[$i]}"
        else
          printf '  %s %s\033[K\n' "$box" "${MENU_LABELS[$i]}"
        fi
      fi
    done
    picked=0; items=0
    for ((i = 0; i < count; i++)); do
      [[ "${MENU_KIND[$i]:-item}" == "item" ]] || continue
      items=$((items + 1))
      [[ "${MENU_SELECTED[$i]}" == "true" ]] && picked=$((picked + 1))
    done
    printf '\033[2m  %d/%d sélectionné(s)\033[0m\033[K\n' "$picked" "$items"

    # Lecture d'une touche (gère les séquences d'échappement des flèches)
    IFS= read -rsn1 key || true
    if [[ "$key" == $'\e' ]]; then IFS= read -rsn2 rest || true; key="$key$rest"; fi

    case "$key" in
      $'\e[A' | 'k') _menu_step -1 ;;
      $'\e[B' | 'j') _menu_step +1 ;;
      ' ')
        if [[ "${MENU_KIND[$cursor]:-item}" == "item" ]]; then
          if [[ "${MENU_SELECTED[$cursor]}" == "true" ]]; then
            MENU_SELECTED[$cursor]="false"
          else
            MENU_SELECTED[$cursor]="true"
          fi
        fi ;;
      'a' | 'A') for ((i = 0; i < count; i++)); do [[ "${MENU_KIND[$i]:-item}" == "item" ]] && MENU_SELECTED[$i]="true"; done ;;
      'n' | 'N') for ((i = 0; i < count; i++)); do [[ "${MENU_KIND[$i]:-item}" == "item" ]] && MENU_SELECTED[$i]="false"; done ;;
      '')        printf '\033[?25h\n'; return 0 ;;   # Entrée → valide
      'q' | 'Q') printf '\033[?25h\n'; return 1 ;;   # q → annule
      *)         : ;;
    esac
  done
}
