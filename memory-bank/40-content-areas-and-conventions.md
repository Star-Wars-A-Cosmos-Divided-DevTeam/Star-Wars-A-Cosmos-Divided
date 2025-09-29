---
name: SWACD – Content Areas & Conventions
globs: ["factions/**/*", "ships/**/*", "resources/**/*", "Resources/**/*", "shots/**/*", "gui/**/*", "Gui/**/*", "strings/**/*", "common_effects/**/*", "sw_effects/**/*", "statuses/**/*"]
description: Where to look and how to modify safely in each area.
---

# Content Areas (What to check before you edit)

- **factions/** – Faction definitions. Ensure references to ship families and spawn lists exist.
- **ships/** – Ship families & variants. Confirm `Part` availability and sprite atlases.
- **resources/** or **Resources/** – Resource definitions (watch case). Ensure producers/consumers match gameplay balance.
- **shots/** – Projectile defs (`Projectile` and components). Check damage, speed, effects tables.
- **common_effects/** & **sw_effects/** – Shared effects. Ensure reference paths are stable before reuse.
- **gui/** or **Gui/** – HUD & icons. Match render layers and positioning.
- **strings/** – Localization/keys. Keep keys unique and consistent.

## Naming & consistency
- Keep naming aligned with existing SWACD IDs and keys (e.g., Use prefixes like `SW.` for IDs and `SW_` for keys and files where already used).
- Cross-check any **tier/tech** assumptions with the main `cosmoteer.rules`.
