# macOS setup

Installe les applications (Homebrew) et configure l'OS (réglages système, Dock,
fond d'écran) via un **menu interactif**, de façon **idempotente** (rejouable
sans casse) et **par couches de version**.

## Démarrage rapide (one-liner)

Sur une machine neuve, une seule commande récupère le repo et lance le menu :

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nicolasfvrx/my-setup/master/macos/bootstrap.sh)"
```

> Utilise bien la forme `bash -c "$(curl …)"` (pas `curl … | bash`) : elle garde
> ton terminal sur l'entrée standard, donc le menu interactif fonctionne.
> Le repo est cloné dans `~/.my-setup`. Pour tester une autre branche :
> `MY_SETUP_BRANCH=W.I.P /bin/bash -c "$(curl -fsSL …/W.I.P/macos/bootstrap.sh)"`.

## Prérequis

- Un **compte administrateur** (Homebrew utilise `sudo` en interne pour créer
  `/opt/homebrew`). Vérifier : `id -Gn | tr ' ' '\n' | grep -qx admin && echo OK`.
- Lancer le script **sans `sudo`** : Homebrew refuse de tourner en root.
  Le script refuse d'ailleurs de démarrer en root et le rappelle.
- Quand l'installeur Homebrew demande ton mot de passe, c'est normal — saisis-le.

## Lancer

```sh
# depuis le dossier macos/
bash install.sh                 # menu interactif (recommandé)
bash install.sh dock            # mode direct : une étape, sans menu
bash install.sh system dock     # mode direct : plusieurs étapes
bash install.sh -h              # aide
```

> Sur une VM neuve : copie le repo, `cd macos`, puis `bash install.sh`.
> Homebrew est installé automatiquement s'il manque. Aucune dépendance pour le
> menu (bash pur, marche même avec le bash 3.2 d'origine de macOS).

## Le menu

Au lancement, un en-tête affiche les infos de la machine et **la version du
script + sa date de mise à jour** (liées à la version de macOS détectée) :

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  my-setup  ·  macOS Sequoia
  OS       macOS 15.5  (build 24F74)
  Machine  Mac de Nicolas · Apple M3
  Script   v1.0.0  ·  maj 2026-06-25
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Que veux-tu faire ?
  ↑/↓ ou j/k · espace: cocher · a: tout · n: rien · entrée: valider · q: annuler
> [x] Installer des applications
  [x] Réglages système
  [x] Dock (icônes + comportement)
  [x] Fond d'écran
```

Si « Installer des applications » est coché, un second menu liste le catalogue
(cases à cocher), puis un récap demande confirmation avant d'exécuter.

## Comment ça marche — les couches

`install.sh` détecte la version (`sw_vers`) et applique, dans l'ordre :

1. `common/` — partagé par toutes les versions de macOS
2. `<major>-<nom>/` — deltas de la version détectée (ex. `15-sequoia/`)

Le second **complète/surcharge** le premier (scripts, `Brewfile`, `apps.list`).
Ajouter une version (Tahoe…) = créer `26-tahoe/` avec seulement ses différences
et son `meta.env`.

## Structure

```
macos/
├── install.sh          # orchestrateur : header + menu + cascade
├── lib/
│   ├── helpers.sh      # logs, header, détection version, install Homebrew
│   ├── menu.sh         # sélecteur multi-choix (bash pur)
│   └── apps.sh         # lecture du catalogue + install de la sélection
├── assets/wallpaper/   # déposer wallpaper.jpg ici
├── common/             # commun à toutes les versions
│   ├── Brewfile        # outils OBLIGATOIRES du setup (dockutil, mas)
│   ├── apps.list       # catalogue d'apps OPTIONNELLES (menu)
│   ├── system.sh       # réglages système (defaults)
│   ├── dock.sh         # comportement + icônes du Dock (dockutil)
│   ├── wallpaper.sh    # fond d'écran
│   └── config/         # dotfiles d'apps spécifiques mac
└── 15-sequoia/         # deltas Sequoia
    ├── meta.env        # version + date de maj affichées dans le header
    ├── Brewfile
    ├── apps.list
    ├── system.sh
    └── notes.md
```

## Personnaliser

| Quoi | Où |
|------|-----|
| Apps proposées dans le menu | `common/apps.list` (`type\|id\|libellé\|on/off`) |
| Apps propres à une version | `15-sequoia/apps.list` |
| Outils toujours installés | `common/Brewfile` |
| Réglages système | `common/system.sh` (commenter/décommenter) |
| Icônes & comportement du Dock | `common/dock.sh` (tableau `APPS`) |
| Fond d'écran | `assets/wallpaper/wallpaper.jpg` |
| Version / date affichées | `15-sequoia/meta.env` |

### Format de `apps.list`

```
type|identifiant|libellé|défaut
```
- `type` : `cask` (app GUI) · `brew` (CLI) · `mas` (Mac App Store) · `tap`
- `mas` : l'identifiant est l'id numérique (`mas search "Nom"`)
- `défaut` : `on` (présélectionné) ou `off`

Astuce : pour partir de ta machine actuelle, `brew bundle dump --describe`
génère un Brewfile que tu peux convertir en lignes `apps.list`.

## Notes

- **Widgets du bureau** : pas d'API CLI fiable sur Sequoia — voir
  [`15-sequoia/notes.md`](15-sequoia/notes.md). À poser manuellement pour l'instant.
- Certains réglages ne s'appliquent qu'après **déconnexion/redémarrage**.
- Les permissions de confidentialité (TCC) ne sont pas automatisables sans toucher au SIP.
