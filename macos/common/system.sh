#!/usr/bin/env bash
#
# Réglages système macOS via `defaults` — communs à toutes les versions.
# Chaque ligne est commentée : commente/décommente selon tes besoins.
#
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/helpers.sh"

info "Application des réglages système…"

# Ferme Réglages Système pour éviter qu'il n'écrase nos changements.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# === Clavier ===
defaults write NSGlobalDomain KeyRepeat -int 2              # répétition rapide
defaults write NSGlobalDomain InitialKeyRepeat -int 15      # délai avant répétition
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false  # maintien = répétition (pas le menu accents)

# === Trackpad ===
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true                 # taper pour cliquer
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# === Finder ===
defaults write com.apple.finder AppleShowAllFiles -bool true          # afficher les fichiers cachés
defaults write NSGlobalDomain AppleShowAllExtensions -bool true       # afficher les extensions
defaults write com.apple.finder ShowPathbar -bool true                # barre de chemin
defaults write com.apple.finder ShowStatusBar -bool true              # barre de statut
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # vue liste par défaut
defaults write com.apple.finder _FXSortFoldersFirst -bool true        # dossiers en premier
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # recherche = dossier courant
defaults write com.apple.finder FXRemoveOldTrashItems -bool true      # vider la corbeille après 30 j

# === Captures d'écran ===
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# === Saisie ===
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false        # pas de majuscule auto
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false    # pas de correction auto
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false    # pas de point auto

# === Divers ===
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true   # dialogues d'enregistrement déployés
defaults write com.apple.LaunchServices LSQuarantine -bool false              # pas de "voulez-vous ouvrir ?"

# Redémarre les apps impactées
for app in Finder; do killall "$app" 2>/dev/null || true; done
ok "Réglages système appliqués (certains nécessitent une déconnexion)."
