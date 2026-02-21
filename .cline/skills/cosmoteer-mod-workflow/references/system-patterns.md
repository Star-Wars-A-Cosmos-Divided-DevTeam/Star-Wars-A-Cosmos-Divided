# System Patterns

Entry points:
- `mod.rules` is the mod manifest and Actions entry point.
- `cosmoteer.rules` acts as the registry hub for SW_* lists.

Actions patterns:
- `Overrides` replace specific `<./Data/...>` sections.
- `Add`/`AddMany` inject new nodes; use `OnlyIfNotExisting` for idempotence.
- `foldercreater.rules` is intentionally empty and used to seed lists.

Reference conventions:
- `<./Data/...>` points to base-game rules.
- `<folder/file.rules>` resolves inside the mod.
- `&<path>` copies data; no `&` means a live reference.
- Leading `=` assigns a symbol (e.g., `SW_COLORS = ...`).

Content modules:
- `ships/terran/terran.rules` curates exposed parts by category.
- `Resources/*.rules` define mining items and drop tables.
- `Gui/game/designer` extends editor groups and stat widgets.
- `common_effects`, `sw_effects`, `shots`, `statuses` hold shared assets.
- `modes/career` and `modes/pvp` integrate tech and resources.
- `strings/*.rules` include 10 languages; keep keys consistent.

Known syntax gotchas:
- Inline maps need semicolons between fields.
- Avoid duplicate `=` assignments on the same line.
- Arrays use `[a, b]`, objects use `{ Key = Value }`.
- Comments use `//` or `/* */` (no nested block comments).

Naming:
- Keep ID and key naming aligned with SWACD (e.g., `SW.` IDs, `SW_` keys).
