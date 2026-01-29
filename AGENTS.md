# SWACD AGENTS

This file defines AI guidance for the Star Wars: A Cosmos Divided (SWACD) Cosmoteer mod repo.

## Scope and Purpose
- Repo: SWACD main mod for Cosmoteer.
- Goal: Provide best-practice instructions so AI and contributors understand the folder structure, how to
  connect to vanilla Cosmoteer data, and how to safely edit .rules with cross-file references.
- Status: Repo is mid-migration; parts and features may be incomplete, commented out, or partially wired.
  Treat missing references as expected; do not assume intended behavior.

## Non-Negotiable Workflow (applies to any edits)
1. Open and inspect the exact target file before editing. Do not assume missing blocks exist.
2. Trace the inheritance chain and cross-file references (`BASE`, `Components`, `Shot`, `OverclockedShot`,
   `&<...>`, `&/SW_*`) before making changes.
3. If multiple shot files are referenced by a weapon, each shot must be updated consistently.
4. Use `rg` to narrow scope in large files; edit only the relevant sections.
5. If a local base-game path is not known, ask for it before referencing vanilla data.

## Base-Game References (preferred order)
1. Local install: `<Cosmoteer>/Data` (ask for exact path if not known).
2. GitHub mirror (unstable): `Rojamahorse/CosmoteerUpdates` branch `main-unstable`.
3. Standard Mods under the local install for examples.

On Windows, use a junction at `references/base-game` pointing to
`X:/Program Files (x86)/Steam/steamapps/common/Cosmoteer/Data` (update drive letter as needed).

### Local Base-Game Path (this machine)
- Local install root: `D:/SteamLibrary/steamapps/common/Cosmoteer`
- Junction target: `references/base-game` -> `D:/SteamLibrary/steamapps/common/Cosmoteer/Data`

### Suggested local-paths setup (multi-developer)
Keep machine-specific paths out of versioned files.
- Create `references/local-paths.example.md` with placeholder paths.
- Each developer keeps `references/local-paths.local.md` (gitignored) with their actual paths.
This keeps guidance in-repo without hardcoding one machine.

### Local-paths bootstrap (agent behavior)
- On startup or before any base-game lookup, check for `references/local-paths.local.md`.
- If missing, copy `references/local-paths.example.md` to `references/local-paths.local.md`
  and prompt the developer to fill in their local paths.

### Junction setup (Windows)
- Use the `COSMOTEER_DATA` path from `references/local-paths.local.md`.
- If `references/base-game` does not exist, create a junction:
```powershell
$paths = Get-Content .\references\local-paths.local.md
$data = ($paths | Where-Object { $_ -match '^COSMOTEER_DATA\\s*=\\s*\"(.+)\"' }) -replace '^.*\"','' -replace '\"$',''
if ($data) { cmd /c mklink /J "$PWD\\references\\base-game" "$data" }
```

## Entry Points and Registries
- `mod.rules` is the mod entry point (metadata + Actions for injecting/overriding vanilla data).
- `cosmoteer.rules` is the mod-wide registry hub (SW_* lists and shared assets).
- `foldercreater.rules` is intentionally empty; used to instantiate registries via Actions.

### Shared Registries (current)
- `SW_COLORS` -> `common_effects/mod-colors.rules`
- `SW_PARTICLES` -> `SW_effects/mod-particles.rules`, `common_effects/mod-particles.rules`
- `SW_SHOTS` -> `SW_effects/mod-shots.rules`, `shots/sw_shots.rules`
- `SW_SOUNDS` -> `common_effects/mod-sounds.rules`
- `SW_GRAPHICS` -> `ships/common/common_sprites/common_sprites.rules`

Note: `cosmoteer.rules` currently has a duplicate `=` in `SW_SHOTS` definition; treat as a known quirk during edits.
The first entry takes precedence; this is intentional during migration from the legacy shots layout to the new one.

## Folder Map (repo root)
- `buffs/` - custom buffs injected into `<./Data/buffs/buffs.rules>`.
- `common_effects/` - shared particles/sounds/helpers referenced via SW_* registries.
- `context_portal/` - context/UI content (verify exact usage before edits).
- `doodads/` - custom doodads, asteroid conversions, and mining add-ons.
- `factions/` - faction data (also used by the separate Factions add-on).
- `Gui/` - UI extensions: designer groups, stats widgets, toggles, icons.
- `modes/` - career/PvP rules, sector and tech integrations.
- `Resources/` - resource definitions and sprites (note case; used by Actions).
- `ships/` - parts and ship definitions; common bases under `ships/common/...`.
- `shots/` - projectile definitions.
- `statuses/` - status effects and condition handling.
- `strings/` - localized strings (StringsFolder in `mod.rules` points to "Strings").
- `sw_effects/` - Star Wars-specific effects library.
- `scripts/` - tooling or automation (inspect before use).
- `wip_sketches/`, `_backup/` - WIP and archival content (not authoritative).

### Common Content Folders (observed)
- `ships/common/common_code/` - shared component bases and helpers (`bases/`, `components/`).
- `ships/common/common_sprites/` - shared sprite registries referenced by `SW_GRAPHICS`.
- `common_effects/` + `sw_effects/` - shared particles/sounds/shot helpers via SW_* registries.
- `shots/` - SW shot definitions, including OC variants and nested particle assets.

### Case Sensitivity
- Folder case is mixed (`Gui/`, `Resources/`, `Doodads/` in Actions). On Windows this is OK,
  but avoid changing case or introducing conflicting paths for portability.

### Non-Shipping / Dev-Only Folders
- `wip_sketches/` and `_backup/` should be removed before Steam production builds to avoid bloat.
- `context_portal/` is dev tooling and can be ignored by mod packaging.

## Rules Language Conventions (quick reference)
- `<./Data/...>` targets vanilla Cosmoteer rules (read-only parents).
- `<folder/file.rules>` resolves within this mod folder.
- `&<path>` clones/embeds rule blocks; `&/Path` traverses previously exported registries.
- Arrays use `[a, b]`, objects use `{ Key = Value }`. Inline maps require semicolons between fields.
- Avoid duplicate `=` assignments on the same line; check for legacy patterns.

## Strings and Localization
- Every user-facing name/tooltip/stat label should use a strings key.
- Ensure each new key exists in every active locale in `strings/*.rules`.
- If a key is intentionally missing, document it inline or in a TODO section.

## Parts, Shots, and Overclock (OC) Basics
- Parts typically inherit from SWACD base parts under `ships/terran/` (see base chain below).
- Shots live in `shots/` and are referenced by weapons; overclocked variants must exist per shot.
- OC workflow and templates live under:
  - `.cline/skills/cosmoteer-mod-workflow/references/oc-shot-implementation.md`
  - `.cline/skills/cosmoteer-mod-workflow/references/oc-overclock-shot-template.rules`
- If a weapon has multiple firing modes or linked shots, update every shot definition.

### Base Part Chain (observed)
- `ships/terran/base_part_terran_sw.rules` -> `<./Data/ships/terran/base_part_terran.rules>`
- `ships/terran/base_part_terran_sw_operational.rules` -> SW base
- `ships/terran/base_part_terran_sw_scorched.rules` -> operational base
- `ships/terran/base_part_terran_sw_overclock.rules` -> scorched base
- Category bases (examples):
  - `ships/terran/weapons/base_part_terran_weapons.rules`
  - `ships/terran/weapons/base_part_terran_weapons_overclock.rules`
  - `ships/terran/control_rooms/base_part_terran_control_rooms.rules`
  - `ships/terran/armor/base_part_terran_armor.rules`
  - `ships/terran/structures/*/base_part_terran_structure.rules`

When adding new parts, pick the closest existing base in `ships/terran/` and follow its chain.

### OC Coverage
- Not every shot currently has an OC variant. Goal is to add OC coverage over time.
- Do not assume OC exists; verify per-shot before wiring.

### Base Chain Hygiene (best practice)
- Prefer complete, consistent base chains; missing base links often omit critical attributes.
- When in doubt, trace the vanilla part chain to the top and mirror required fields.
- Use shared base blocks for truly invariant logic to reduce duplication.
- Avoid cross-folder references that depend on assets not present in the target folder.

### Vanilla Chain Reference (how to compare)
- Use `references/base-game` (local junction) to open vanilla parts and follow their chain:
  - Example: `references/base-game/ships/terran/<part>/<part>.rules` -> `base_part_terran.rules`
- Compare fields at each level of the vanilla chain; only add fields your target part actually uses.
- If a SWACD base chain skips a vanilla layer, explicitly verify the missing attributes are
  reintroduced elsewhere in SWACD (or accept the omission intentionally).

## GUI and Editor Integration
- Editor groups and stat widgets are injected via `mod.rules` Actions into GUI rules.
- Any new stat widget should include an icon and localized label key.
- Part toggles and colors live under `Gui/game/parts/` and must be referenced in Actions.

### GUI Chaining (observed)
- `Gui/game/designer/build_gui.rules` references `editor_groups.rules` and `stat_widgets.rules`.
- `Gui/game/game_gui.rules` binds `SW_part_*` registries (toggles, colors, triggers, targeters, features).

## Repo Relationships (known)
- Main mod: this repo (SWACD core).
- Optional add-ons with local paths (this machine):
  - `SW-ACD-Factions`: `C:/Users/Rojamahorse/Saved Games/Cosmoteer/76561197993324838/Mods/SW-ACD-Factions`
  - `SW-ACD-Music`: `C:/Users/Rojamahorse/Saved Games/Cosmoteer/76561197993324838/Mods/SW-ACD-Music`
  - `SW-ACD-Decals`: `C:/Users/Rojamahorse/Saved Games/Cosmoteer/76561197993324838/Mods/SW-ACD-Decals`
  - `SW-ACD-Expanded-Vanilla-Armors`: `C:/Users/Rojamahorse/Saved Games/Cosmoteer/76561197993324838/Mods/SW-ACD-Expanded-Vanilla-Armors`
  - `SW-ACD-Prerequisites`: `C:/Users/Rojamahorse/Saved Games/Cosmoteer/76561197993324838/Mods/SW-ACD-Prerequisites`
    - Note: separate branch of the main mod; must stay in its own folder with its own git due to dependencies.
  - These repos have cross-dependencies; ask for exact directionality when editing shared assets.

## Migration Reality (important)
- Repo is mid-migration from older Cosmoteer versions.
- Expect commented-out Actions, partially defined parts, and unresolved references.
- Do not "standardize" or add missing fields unless they are present in the target file.

## Task Checklists

### Before editing .rules or strings
- Identify exact file(s) and open them.
- Trace cross-file references and inheritance.
- Confirm which base-game version to mirror.
- Decide minimal change set that preserves current behavior.

### After editing
- Re-scan changed blocks for unresolved `&<...>` or `<./Data/...>` references.
- Verify any shot or OC references have matching definitions.
- Ensure new strings keys exist in all locales in `strings/`.

## Balance / Stats Guidance (current practice)
- For weapons or balance-sensitive parts, include a stats block at the top of the file.
- Use the established variable names already used in SWACD; do not invent new names.
- Ensure stat formulas are mathematically sound and reference the correct variables.

### Stats Style Guide (vanilla-aligned)
- Always start from the closest vanilla part (via `references/base-game`) to confirm:
  - Which stats actually exist for that part class.
  - The variable names and formula patterns vanilla uses.
- Do not add stats that the vanilla part does not have unless the SWACD part explicitly adds
  the underlying mechanics for those stats.
- Prefer the same terminology, units, and math style as vanilla (function usage, rounding,
  per-tick vs per-second conventions).
- If a SWACD part extends vanilla behavior, document the delta in the stats block but keep
  the vanilla naming style intact.
- When reusing a stats block, copy from the closest SWACD part of the same class (turret,
  beam, missile, reactor, shield) and only then adjust values.

#### Example (pattern only, not a template)
- Reference vanilla `cannon_med.rules` (or nearest vanilla weapon of the same type) to see:
  - `OVERCLOCK` block structure, `HEAT_TO_RESOURCE/STATUS` references, and how `BULLET` is derived.
  - This is a style example only; do not copy fields that do not exist in the SWACD part.

### Stats Block Checklist (apply per-part)
- Identify part class (weapon type, power vs ammo, turret vs fixed) and select closest vanilla reference.
- Confirm each stat key exists in the part/component chain before adding it.
- Use SWACD's standard variable names for that class; do not rename for clarity.
- Verify formula inputs resolve to real paths (e.g., `Components/Turret/FireInterval`).
- Keep rounding style consistent with vanilla (e.g., `ceil`, `floor`, `deg` usage).
- If a stat is derived from a shot, reference the actual shot file used by the part.

#### Example selection note (do not copy literally)
- For SWACD XX9 (energy turret), vanilla `laser_blaster_large.rules` is the closest *style* reference.
- If you need footprint/layout comparison, `cannon_large.rules` can inform sizing only, but it is ammo-based
  and should not drive power/heat or overclock stat conventions.

## Notes from Maintainers
- `modes/` is used by the Factions add-on to inject parts and career functionality.
- `factions/` is mostly unused by the main mod but heavily used by the Factions add-on.
- `strings/` is required for any user-facing name, tooltip, or stat label.
- Cross-folder references (`../../../ships/...`) exist; prefer common content folders but refactor cautiously.
  - Only consolidate when the referenced block is truly shared and does not rely on local assets.

## Local References (in-repo)
- Skill references: `.cline/skills/cosmoteer-mod-workflow/references/`
- High-level context: `memory-bank/projectbrief.md`, `memory-bank/systemPatterns.md`

## TODO (fill as repo stabilizes)
- Canonical base-game path for this machine.
- Current target Cosmoteer version and migration delta.
- Definitive list of active sub-mod repos and their entry points.
- Rules-style linting or validation checks (if any).
