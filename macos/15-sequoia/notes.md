# macOS 15 — Sequoia

Notes et particularités propres à cette version.

## Nouveautés exploitables par script
- **Window tiling** : `com.apple.WindowManager` (`EnableTiledWindowMargins`, etc.).
- **iPhone Mirroring** : pas de réglage `defaults` documenté.

## Limites connues (non scriptables proprement)
- **Widgets du bureau** : leur disposition est stockée dans une base interne
  (`~/Library/Application Support/com.apple.chronod` / board), **sans clé `defaults`
  stable**. Pas d'API CLI fiable → à poser **à la main** pour l'instant.
  Piste : ajouter/retirer des widgets se fait via le menu contextuel du bureau.
- Certains réglages de **Confidentialité & sécurité** (TCC) exigent une action
  manuelle de l'utilisateur — non automatisables sans désactiver le SIP.

## À faire / TODO
- [ ] Lister les apps réellement utilisées → remplir `../common/Brewfile`.
- [ ] Déposer le wallpaper dans `../assets/wallpaper/wallpaper.jpg`.
- [ ] Définir la liste finale des icônes du Dock dans `../common/dock.sh`.
