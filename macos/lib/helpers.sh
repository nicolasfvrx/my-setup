#!/usr/bin/env bash
# Fonctions partagées par les scripts de setup macOS.
# Sourcé par install.sh et par chaque script d'étape.

# --- Logs ---
info() { printf '\033[34m›\033[0m %s\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
err()  { printf '\033[31m✗\033[0m %s\n' "$*" >&2; }

# Version majeure de macOS (ex: 15, 26)
macos_major() { sw_vers -productVersion | cut -d. -f1; }

# En-tête du menu : infos OS + version/date du script (couche de version).
# Utilise SCRIPT_CODENAME / SCRIPT_VERSION / SCRIPT_UPDATED (meta.env).
print_header() {
  local name ver build chip host
  name="$(sw_vers -productName 2>/dev/null || echo macOS)"
  ver="$(sw_vers -productVersion 2>/dev/null || echo '?')"
  build="$(sw_vers -buildVersion 2>/dev/null || echo '?')"
  chip="$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo '?')"
  host="$(scutil --get ComputerName 2>/dev/null || hostname 2>/dev/null || echo '?')"

  local line='━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
  printf '\033[34m%s\033[0m\n' "$line"
  printf '  \033[1mmy-setup\033[0m  ·  %s %s\n' "$name" "${SCRIPT_CODENAME:-}"
  printf '  \033[2mOS\033[0m       %s %s  (build %s)\n' "$name" "$ver" "$build"
  printf '  \033[2mMachine\033[0m  %s · %s\n' "$host" "$chip"
  printf '  \033[2mScript\033[0m   v%s  ·  maj %s\n' "${SCRIPT_VERSION:-0.0.0}" "${SCRIPT_UPDATED:-—}"
  printf '\033[34m%s\033[0m\n' "$line"
}

# Installe Homebrew si absent puis le charge dans le PATH (Apple Silicon ou Intel).
ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installation de Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1 && ok "Homebrew prêt ($(brew --version | head -n1))"
}
