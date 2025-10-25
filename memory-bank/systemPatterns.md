# System Patterns

## Entry Points & Actions
- `mod.rules` â€“ **mod manifest/actions** entry point for mods.  Actions are used in the mod.rules to inject .rules configuration files into cosmoteer.rules (the main vanilla game). Actions may replace, remove, override, or add/addmany parts, configs, or other files.
to the game.
  - `mod.rules` defines metadata and orchestrates integration through `Actions`.
  - `Overrides` targets `<./Data/...>` slices (buffs, GUI arrays) to replace vanilla sections.
  - `Add`/`AddMany` inject new nodes or lists, often gated by `OnlyIfNotExisting` so reloads stay idempotent.
  - Actions seed `<cosmoteer.rules>` with registries (`SW_COLORS`, `SW_PARTICLES`, `SW_SHOTS`, `SW_SOUNDS`, `SW_GRAPHICS`) that other files dereference.
- `cosmoteer.rules` is the mod-wide registry hub; consuming files use `&/SW_*` paths to pull shared assets.
- `./data/` â€“ **root entry** for inheritance of parts & configs aggregation from the main unmodded game.


## Reference & Inheritance Conventions
- `<./Data/...>` points at Cosmoteerâ€™s built-in rules; treat these as read-only parents when inheriting.
- `<folder/file.rules>` resolves inside the mod directory.
- `&<path>` clones/embeds rule blocks; `&/Path` traverses previously exported registries.
- Leading `=` assigns a symbol that other rules can read (e.g., `SW_COLORS = ...`).
- Base part hierarchy (under `ships/common/common_code/bases`) layers functionality:
  - `base_part_terran_sw.rules` inherits `./Data/ships/terran/base_part_terran.rules`.
  - Variants such as `_operational`, `_scorched`, `_overclock` add toggles, thermal networks, and status handling.
- See `memory-bank\docs\Cosmoteer â€“ Rules Language & Style.md` for more information.

## Content Modules
- `ships/terran/terran.rules` curates exposed parts by category, each referencing fully-defined part files via `&<Weapons/...>/Part` or similar.
- `Resources/*.rules` define mining items with sprite atlases, stack visuals, and pickup effects; drop tables reuse vanilla lists like `VeryCommonMaterialDropRates`.
- `Gui/game/designer` extends editor groups, stat widgets, and toggles; corresponding PNG icons live alongside the rules. This also includes custom UI toggles.
- `common_effects`, `sw_effects`, `shots`, and `statuses` encapsulate reusable particles, sounds, projectiles, and status effects, all accessed through SW_* registries.
- `modes/career` and `modes/pvp` adjust tech trees, sectors, and build-battle tech availability to integrate new resources.
- `strings/*.rules` supply localized text (en, de, es, fr, it, ja, pt-br, ru, tr, zh-cn) for every referenced key. See `memory-bank\docs\Cosmoteer â€“ Strings Guide.md` For more details. 

## Integration Nuances
- `foldercreater.rules` stays intentionally empty; `Add` Actions use it to instantiate named lists before populating them.
- When overriding vanilla arrays, always target the exact `<./Data/...>` path to avoid clobbering unrelated entries.
- GUI stat widgets require both a rule definition and an icon; ensure new stats include localized label keys.
- Commented Actions in `mod.rules` (e.g., additional doors, SW_SHADERS) serve as future/old expansion templates.
- Overclock shot workflow documented in `memory-bank/docs/oc_shot_implementation.md`; use `memory-bank/docs/oc_overclock_shot_template.rules` as the starting point for new OC projectile variants.
- The mod attempts to follow Cosmoteer's established architecture and patterns with some custom optimizations

## Known Syntax Gotchas
- Inline maps need semicolons between fields (e.g., `Category=SW_Hyperdrives;`).
- Avoid duplicate `=` assignments on the same line; `cosmoteer.rules` currently has `SW_SHOTS` with two `=` tokens that should be normalized.
- Arrays use `[value, value]`, objects use `{ Key = Value }`; comments can be `//` or `/* ... */` but block comments do not nest.
- Top-level asset/content folders for the main game (note the mod does not need to match these, but this is good to know for the general structure of a mod):
  - `factions/`, `ships/`, `resources/`, `Resources/`, `shots/`, `gui/`, `strings/`, `common_effects/`, `sw_effects/`, `statuses/`, `doodads/`, `modes/`, `roof_decals/`, `post_shaders/`, `wip_sketches/`, etc.
- Keep naming aligned with existing SWACD IDs and keys (e.g., Use prefixes like `SW.` for IDs and `SW_` for keys and files where already used).
- Cross-check any **tier/tech** assumptions with the main `cosmoteer.rules`.
- Multi-line Comments are handled with `/* */` and single/EOL comments by leading with `//`


