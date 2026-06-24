#!/usr/bin/env bash
# Sélecteur multi-choix en bash pur — compatible bash 3.2 (macOS d'origine).
# Aucune dépendance externe (pas de dialog/whiptail/gum).
#
# Entrées (variables globales) :
#   MENU_LABELS    tableau des libellés à afficher
#   MENU_DEFAULTS  tableau "on"/"off" (présélection), même taille
# Sortie (variable globale) :
#   MENU_SELECTED  tableau "true"/"false", même taille
# Code retour : 0 = validé (Entrée)  ·  1 = annulé (q)

multiselect() {
  local title="$1"
  local count=${#MENU_LABELS[@]}
  local i box picked

  # Présélection depuis MENU_DEFAULTS
  MENU_SELECTED=()
  for ((i = 0; i < count; i++)); do
    if [[ "${MENU_DEFAULTS[$i]:-off}" == "on" ]]; then
      MENU_SELECTED[$i]="true"
    else
      MENU_SELECTED[$i]="false"
    fi
  done

  local cursor=0
  local total=$((count + 4))   # titre + aide + ligne vide + items + pied
  local first=1 key rest

  printf '\033[?25l'           # masque le curseur du terminal
  while true; do
    # Repositionne en haut du bloc pour redessiner par-dessus
    if [[ $first -eq 1 ]]; then first=0; else printf '\033[%dA' "$total"; fi

    printf '\033[1m%s\033[0m\033[K\n' "$title"
    printf '\033[2m  ↑/↓ ou j/k · espace: cocher · a: tout · n: rien · entrée: valider · q: annuler\033[0m\033[K\n'
    printf '\033[K\n'
    for ((i = 0; i < count; i++)); do
      box="[ ]"; [[ "${MENU_SELECTED[$i]}" == "true" ]] && box="[x]"
      if [[ $i -eq $cursor ]]; then
        printf '\033[36m> %s %s\033[0m\033[K\n' "$box" "${MENU_LABELS[$i]}"
      else
        printf '  %s %s\033[K\n' "$box" "${MENU_LABELS[$i]}"
      fi
    done
    picked=0
    for ((i = 0; i < count; i++)); do
      [[ "${MENU_SELECTED[$i]}" == "true" ]] && picked=$((picked + 1))
    done
    printf '\033[2m  %d/%d sélectionné(s)\033[0m\033[K\n' "$picked" "$count"

    # Lecture d'une touche (gère les séquences d'échappement des flèches)
    IFS= read -rsn1 key || true
    if [[ "$key" == $'\e' ]]; then IFS= read -rsn2 rest || true; key="$key$rest"; fi

    case "$key" in
      $'\e[A' | 'k') cursor=$(( (cursor - 1 + count) % count )) ;;
      $'\e[B' | 'j') cursor=$(( (cursor + 1) % count )) ;;
      ' ')
        if [[ "${MENU_SELECTED[$cursor]}" == "true" ]]; then
          MENU_SELECTED[$cursor]="false"
        else
          MENU_SELECTED[$cursor]="true"
        fi ;;
      'a' | 'A') for ((i = 0; i < count; i++)); do MENU_SELECTED[$i]="true"; done ;;
      'n' | 'N') for ((i = 0; i < count; i++)); do MENU_SELECTED[$i]="false"; done ;;
      '')        printf '\033[?25h\n'; return 0 ;;   # Entrée → valide
      'q' | 'Q') printf '\033[?25h\n'; return 1 ;;   # q → annule
      *)         : ;;
    esac
  done
}
