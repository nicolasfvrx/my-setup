#!/usr/bin/env bash
#
# Bootstrap du setup macOS — à lancer sur une machine neuve :
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicolasfvrx/my-setup/master/macos/bootstrap.sh)"
#
# Récupère le repo (git si dispo, sinon archive .tar.gz) puis lance install.sh.
# Variables d'env optionnelles :
#   MY_SETUP_BRANCH  branche à récupérer        (défaut: master)
#   MY_SETUP_DIR     dossier cible              (défaut: ~/.my-setup)
#
set -euo pipefail

REPO="nicolasfvrx/my-setup"
BRANCH="${MY_SETUP_BRANCH:-master}"
DEST="${MY_SETUP_DIR:-$HOME/.my-setup}"

info() { printf '\033[34m›\033[0m %s\n' "$*"; }
err()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; }

# Garde-fous
if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  err "Ne lance pas ce script en root / avec sudo (Homebrew refuse de toute façon)."
  exit 1
fi
[[ "$(uname -s)" == "Darwin" ]] || { err "Ce bootstrap est pour macOS uniquement."; exit 1; }

info "Récupération de $REPO ($BRANCH) → $DEST"
if command -v git >/dev/null 2>&1; then
  rm -rf "$DEST"
  git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$DEST"
else
  # Mac fraîche : pas encore de git → on télécharge l'archive via curl + tar
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar xz -C "$tmp"
  src="$(find "$tmp" -maxdepth 1 -mindepth 1 -type d | head -n1)"
  [[ -n "$src" ]] || { err "Archive vide — branche '$BRANCH' introuvable ?"; exit 1; }
  rm -rf "$DEST"
  mv "$src" "$DEST"
  rm -rf "$tmp"
fi

info "Lancement de l'installeur interactif…"
exec /bin/bash "$DEST/macos/install.sh" "$@"
