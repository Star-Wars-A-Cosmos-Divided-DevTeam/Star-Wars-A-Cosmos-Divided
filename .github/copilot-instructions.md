## Quick orientation — Star Wars: A Cosmos Divided (SWACD)

This file contains concise, actionable notes for AI coding agents working on the SWACD Cosmoteer mod. Read the Memory Bank files before making changes and use the examples below to keep edits safe and consistent.

### Must-read context (always at session start)
- `memory-bank/` (especially: `projectbrief.md`, `systemPatterns.md`, `techContext.md`, `docs/Cosmoteer – Rules Language & Style.md`). These describe project intent, rules DSL patterns, and the special workflows used here. See `memory-bank/` for OC (overclock) shot templates and other domain-specific docs.

### Big-picture architecture (short)
- `mod.rules` is the integration manifest. Its `Actions` list injects/overrides content into the game (`<cosmoteer.rules>` and other vanilla files) — think of it as the single orchestrator for the mod.
- Content lives organized under the mod's `Data/` subfolders: `ships/`, `shots/`, `common_effects/`, `sw_effects/`, `strings/`, `gui/`, `modes/`, etc.
- The mod exposes registries (e.g. `SW_COLORS`, `SW_PARTICLES`, `SW_SHOTS`, `SW_SOUNDS`, `SW_GRAPHICS`) declared via `mod.rules` and consumed across the codebase via copy-references.

### Key patterns & conventions (concrete)
- ID/name prefixes: use `SW.` (mod ID) and `SW_` keys for shared registries and category names already in the repo.
- Paths & referencing:
  - Copy data: `&<path/to/file.rules>/Node` (copies data into your file).
  - Reference data: `<path/to/file.rules>/Node` (links to the original object).
  - Common path markers: `./` (mod root Data), `<>` wrapper for file paths in Actions, `~/` and `~/:` used inside some rules for local-root operations. See `memory-bank/docs/Cosmoteer – Rules Language & Style.md` for details.
- Use `Add`, `AddMany`, `Overrides`, `Replace` actions in `mod.rules` to inject items. Always target the exact vanilla path in `OverrideIn`/`AddTo` to avoid clobbering unrelated data.
- Localization: edit `Strings/` (per-language files like `Strings/en.rules`) whenever you change `NameKey`/`DescriptionKey`.

### Examples (copy into edits or PR descriptions)
- Add a shot into the SW registry (typical):
  - define projectile under `shots/` (e.g. `shots/sw_shots.rules`) and then wire it in `mod.rules` using `OverrideIn = <cosmoteer.rules>/SW_SHOTS` and `Overrides = &<shots/sw_shots.rules>` (see actions //12 and //13 in `mod.rules`).
- Minimal diff style preferred when suggesting fixes (show Replace/With sections rather than full-file rewrites). Example reference shot folder at: `shots/laser/turret/turbo/light/*` and references at `memory-bank/docs/oc_overclock_shot_template.rules`.

### Common pitfalls and error modes (what to check)
- Missing/case-mismatched asset (png/sound) paths — sprite files typically sit next to the `.rules` that reference them.
- Incorrect use of `&` vs plain reference: use `&` when you want the data copied into the consuming registry; omit if you mean a live reference.
- Overriding vanilla arrays without exact path may remove unrelated entries. Double-check `OverrideIn` target paths.
- If you change keys shown to players, ensure matching entries exist in `Strings/*` for all supported languages.

### Developer workflow (how to test & validate)
- There is no build step. Edit `.rules` files directly.
- To validate quickly:
  1. Enable the mod in Cosmoteer (place under `Saved Games/Cosmoteer/<steamid>/Mods` or use Workshop install). `mod.rules` actions run on game load.
  2. Restart the game after edits. A full reload is often required for Actions/registries to re-run.
  3. Watch the game's log files for parsing errors or missing references (check `Documents/My Games/Cosmoteer/` for logs and crash output).
  4. For content changes, enable only the minimal set of mods to isolate failures.
- Useful local tools: `Cosmoteer-Helper-Toolkit/` contains scripts (e.g., Tech Rules Generator) that read `mod.rules` and help generate or validate `Techs` and other lists.

### Where to change what (short map)
- `mod.rules` — manifest & Actions (entry point). Example path: `mod.rules` at repository root.
- `Strings/` — localization keys (e.g. `Strings/en.rules`).
- `shots/` — projectile definitions and templates (`sw_shots.rules`, OC templates in `memory-bank/docs`).
- `common_effects/`, `sw_effects/` — particles, sounds, visual effects registered into SW_* registries.
- `gui/` — editor groups, toggles and icon references; changes often require localized keys and icons.

### Good-to-follow agent contract (inputs / outputs / success)
- Inputs: target `.rules` filepath(s); required asset paths (png/sfx); optional Strings updates.
- Outputs: small `.rules` edits (minimal diffs), updated `Strings/*` entries, and a test plan (how you validated in-game).
- Success: game starts with the mod enabled and no parsing errors in logs; new content visible in the designer with localized labels present.

If any of the above files or memory-bank docs are missing for your task, flag it and update `memory-bank/` with the discovered facts so future sessions start cleanly.

---
Please review any unclear or incomplete items you'd like added (examples, file paths, or workflows) and I will iterate the instructions.

## Concrete examples & checklists (use these when editing shots or part files)

### 1) Ensuring the Stats block at the end of a part file is accurate
- Pattern used in this repo: Parts expose `Stats` and `StatsByCategory` objects, often reusing a shared `TurretStats` block.
- Typical fields parts expect:
  - `RecPower`, `MinPower`, `PowerPerSecond` (power draw)
  - `ROF` (fire rate), `DamagePerShot`, `DamagePerSecond`, `ShieldDamagePerSecond`
  - `AIFirepowerRating` (usually set to `&~/Part/StatsByCategory/X/Stats/DamagePerSecond`)

Checklist to validate a part's Stats block:
 1. Confirm `StatsByCategory` points at a valid `TurretStats` or specific stats object (e.g. `&~/TurretStats`).
 2. Confirm any computed values use available symbols (e.g. `DamagePerShot`, `ROF`) and that those symbols come from the shot or turret parent.
 3. Ensure `RecPower` and `MinPower` reference `../StatsByCategory/N/Stats/PowerPerSecond` or an explicit numeric fallback.
 4. Update `AIFirepowerRating` to the correct Stats path so AI builds use the intended DPS.

Minimal diff example: replace an incorrect Stats block with a canonical one. (Keep diffs minimal — only the changed `Stats` section.)

Replace this (broken/missing values):
- Stats
- {
-     RecPower = 0
-     // ... other fields missing or hardcoded
- }

With this canonical, reference-based block:
- Stats
- {
-     RecPower = &../StatsByCategory/1/Stats/PowerPerSecond
-     MinPower = (&../StatsByCategory/1/Stats/PowerPerSecond) / 2
-     AIFirepowerRating = &~/Part/StatsByCategory/1/Stats/DamagePerSecond
- }

Notes: use `&../...` when stats live in a sibling file; use `&<some_part.rules>/Part/Stats` when reusing another part's canonical stats.

### 2) OC shot layout — recommended folder & file structure
Goal: single standard format with reusable code and color-visual separation.

Structure (recommended):
- shots/<weapon-type>/base_shot.rules           # primary, non-OC behavior
- shots/<weapon-type>/overclock/oc_base_shot.rules  # shared OC behavior & scalars
- shots/<weapon-type>/color_red_shot.rules       # visuals & media for red variant
- shots/<weapon-type>/overclock/oc_red_shot.rules # OC variant: wire OC_BASE + COLOR_BASE

Wiring example (top of an OC file):
BASE       = &<../base_shot.rules>
OC_BASE    = &<../overclock/oc_base_shot.rules>
COLOR_BASE = &<../red_shot.rules>

Then choose which component tree to inherit:
COMPONENT_SOURCE = &OC_BASE/Components   // often preferred for OC files

Why this works: `oc_base_shot.rules` contains the scalar tuning and derived calculations. Color files keep particle/sound overrides so you can reuse the same OC logic with different visuals.

### 3) Using the OC template (quick how-to)
1. Copy `memory-bank/docs/oc_overclock_shot_template.rules` into the appropriate `shots/.../overclock/` folder and rename.
2. Set `BASE`, `OC_BASE`, `COLOR_BASE` as shown above.
3. Tune the `PRIMARY_*`, `EXPLOSIVE_*`, `IMPULSE_*`, and `PROJECTILE_HEALTH` scalar percentages at the top.
4. Keep media overrides commented until you confirm behavior in-game. If you need bright, large particles for OC, override `MediaEffects` in the OC file and reference `&COLOR_BASE` particles where possible.
5. Update the weapon part file (e.g., `ships/.../cis_turbolaser_switchable.rules`) to point at the new `SW.*` shot ID for the OC toggle.

Minimal OC parent wiring example (diff):
- // Old: color-only overclock
- BASE = &<../red_shot.rules>
- // New (recommended):
- BASE = &<../base_shot.rules>
- OC_BASE = &<../overclock/oc_base_shot.rules>
- COLOR_BASE = &<../red_shot.rules>

### 4) Tracing inheritance and resolving relative paths
Follow these steps to trace an inherited value back to its definition:
1. Open the child file and locate the expression (e.g., `&BASE/Components/Hit/HitOperational/HitEffects/0/Damage/BaseValue`).
2. Identify the symbol (`BASE`) and find where it was assigned in the same file (top of the file usually: `BASE = &<../base_shot.rules>`).
3. Resolve the relative path: `&<../base_shot.rules>/...` means "open `base_shot.rules` in the parent folder". Use your editor to open that file.
4. Repeat: if the parent uses `^/0/HitOperational` or another alias, follow `^/` resolution to the node named earlier in the component tree.
5. If you see `&<path>` vs `<path>`: `&` copies the node into the consumer (you can edit safely in the consumer), while plain `<path>` references the original (editing original will change behavior everywhere).

Pro-tips for tracing:
- Use a quick grep for the exact node name (e.g., search for `HitOperational` or `Damage/BaseValue`) — many shots share the same structure.
- Remember `../` moves up one folder level; `./` is the current folder; `<>` wraps filesystem-like paths.
- When you reach `cosmoteer.rules` registries (e.g., `SW_SHOTS`), open the registry to see how items are collected.

### 5) PR checklist for shot/part changes
- Update `shots/...` files (base + oc_base + color + oc_color as needed).
- Wire new shots into `mod.rules` or `shots/sw_shots.rules` so the `SW_SHOTS` registry picks them up.
- Add/update `Strings/en.rules` (and other languages) for any `NameKey`/`DescriptionKey` changes.
- Run a local game load (enable only this mod) and review `Documents/My Games/Cosmoteer/` logs for missing references.
- Verify UI: new shot appears in part toggles and stats reflect the new values.

If you'd like, I can append a few real minimal diffs taken from `shots/laser/turret/concussion/heavy/overclock/` (OC parent wiring + part Stats block fix) so you can copy-paste them into your PRs — tell me which shot and part to target and I'll prepare the diffs.

### Real minimal-diff examples (turbo light) — copy/paste-ready
Below are two concrete, minimal diffs you can use as templates. They use the `shots/laser/turret/turbo/light/` layout (already present in the repo) and the older `sw_effects` color-shot files (attached). The diffs are intentionally small — they show only the changed top-level wiring and the Stats block replacement pattern.

1) Move/normalize a color shot from `sw_effects` into the new shots layout (minimal example)

Replace the old file header (example file: `sw_effects/shots/turbolaser_turret_light_laser_blue_shot.rules`) with a new `shots` file that centralizes the non-OC base + color + OC wiring. This is a minimal example — keep the original component tree below unchanged when copying.

Replace this (old header in `sw_effects/.../turbolaser_turret_light_laser_blue_shot.rules`):
- ID = SW.turbolaser_turret_light_laser_blue_shot //TURRET WEAPONSHOT
-
- Range = 400
- IdealRange = [120, 400]
- IdealRadius = [5, 50]
- Speed = 140 
-
- Components
- {
-    ...existing component tree...
- }

With a new base/color layout under `shots/laser/turret/turbo/light/`:
- File: `shots/laser/turret/turbo/light/base_shot.rules` (create once; copy the full Components tree from the old file)
- File: `shots/laser/turret/turbo/light/blue_shot.rules` (color-only visuals/media overrides)

Minimal `blue_shot.rules` header example (new file):
- BASE = &<./base_shot.rules>
- ID = "SW.turbolaser_turret_light_laser_blue_shot"
- Range = &BASE/Range
- IdealRange = &BASE/IdealRange
- IdealRadius = &BASE/IdealRadius
- Speed = &BASE/Speed
- Components : &BASE/Components
- {
-    // ... no change to the actual component tree here; keep visuals/media overrides only if needed
- }

Notes:
- Copy the full `Components` block from the old `sw_effects` file into `base_shot.rules` (one-time). Then keep `blue_shot.rules` as a thin file that references `&<./base_shot.rules>` and overrides only `Sprite`/`MediaEffects` where color-specific assets differ.

2) Create an OC file that reuses `oc_base_shot.rules` (minimal example)

Place the shared OC scalars in `shots/laser/turret/turbo/light/overclock/oc_base_shot.rules` (you already have this). Then create a color-specific OC file (`oc_blue_shot.rules`) that wires to the three parents.

Minimal `oc_blue_shot.rules` header example:
- BASE       = &<../base_shot.rules>
- OC_BASE    = &<../overclock/oc_base_shot.rules>
- COLOR_BASE = &<../blue_shot.rules>
- COMPONENT_SOURCE = &OC_BASE/Components
- ID = "SW.turbolaser_turret_light_laser_blue_overclock"
- Range = &BASE/Range
- Speed = &BASE/Speed
- // Scalars live in OC_BASE; color visuals are in COLOR_BASE

Why this is minimal: `OC_BASE` contains the derived damage/impulse/health scalars (see `memory-bank/docs/oc_overclock_shot_template.rules`). `oc_blue_shot.rules` only wires the parents and optionally overrides visual `MediaEffects` or `Sprite` to use brighter particles.

3) Example: minimal change to `mod.rules` to register the new shots into `SW_SHOTS` (small patch)

Replace or add into `mod.rules` Actions section (example minimal snippet):
- {
-     Action = Overrides
-     OverrideIn = <cosmoteer.rules>/SW_SHOTS
-     Overrides = &<shots/sw_shots.rules>
- }

Where `shots/sw_shots.rules` gathers the shots and may include `&<shots/laser/turret/turbo/light/blue_shot.rules>` and the OC files.

4) Canonical Stats block replacement (real example)
If a part's `Stats` block is missing references or hard-coded numbers, replace only the `Stats` section to point at the canonical `TurretStats` used across the mod.

Example: Replace this broken block in a weapon part file (e.g. `ships/.../cis_turbolaser_switchable.rules`):
- Stats
- {
-     RecPower = 0
-     MinPower = 0
-     AIFirepowerRating = 0
- }

With this canonical block (minimal, reference-based):
- Stats
- {
-     RecPower = &../StatsByCategory/1/Stats/PowerPerSecond
-     MinPower = (&../StatsByCategory/1/Stats/PowerPerSecond) / 2
-     AIFirepowerRating = &~/Part/StatsByCategory/1/Stats/DamagePerSecond
- }

Notes on indices: `StatsByCategory/1` is commonly used for the turret damage category in this repo (verify by opening the part file's `StatsByCategory` and confirming which index corresponds to `&~/TurretStats`). If your part uses a different `StatsByCategory` ordering, adjust the `../StatsByCategory/N` index accordingly.

5) Tracing a value example (step-by-step using the turbo-light files)
- Suppose you see `&BASE/Components/Hit/HitOperational/HitEffects/0/Damage/BaseValue` referenced by `oc_base_shot.rules`.
- Step 1: open the OC file and find `BASE = &<../base_shot.rules>`.
- Step 2: open `shots/laser/turret/turbo/light/base_shot.rules` and navigate to `Components/Hit/HitOperational/HitEffects/0/Damage/BaseValue` to see the numeric base.
- Step 3: if the base is itself a copy-reference (e.g., `&<../../something.rules>/...`), follow that file accordingly.

### 6) Converting turret parts to support OverClock (example)

When upgrading turret part files to be OC-capable you generally:
- Add a small, editable `OVERCLOCK` block at the top with tunables (fire rate, damage, health, heat, etc.).
- Keep the original turret as `BASE` and provide an OC inheritance layer that modifies behavior.
- Add or update `Toggles` / `Emitters` / `Shots` wiring so the part can switch to the OC shot ID at runtime.
- Update `Stats` or `SecondaryToolTip` paths to compute OC values (e.g., `SHOT_HEAT_PER_SECOND`) using `&~/OVERCLOCK` scalars.

Why: This pattern keeps gameplay tuning in one place (OVERCLOCK scalars) and ensures the OC variant is a small override rather than a full copy of the turret.

Quick checklist before editing a turret file:
1. Open the backup (old) version and the current file side-by-side (you provided `Turbolasers_Light/backup/*` — use it as the source of truth for what changed).
2. Identify the weapon's `Shot` ID(s) and where they are referenced in `Components/Emit`/`Components/Targeter`/`ToolTip` blocks.
3. Decide which values should be tunable (ROF, DamagePerShot, ProjectileHealth, HEAT_PER_SHOT, etc.).
4. Add `OVERCLOCK` scalars and wire derived values in `Stats` or `SecondaryToolTip`.
5. Add a simple toggle mapping so the builder UI can switch to the OC shot ID.

Minimal turret edits (pattern)

- Add an OVERCLOCK block near the top (symbol table style):

- OVERCLOCK
- {
-     ENABLED = true // default on/off for local testing
-     FIRE_RATE_FACTOR = 75%    // percent (set <100 to faster if your DSL ~multipliers)
-     DAMAGE_FACTOR = 125%
-     SHIELD_DAMAGE_FACTOR = 125%
-     PROJECTILE_HEALTH_FACTOR = 175%
-     HEAT_PER_SHOT = 0.5
- }

- Wire the derived stat(s) inside the turret file (example `SecondaryToolTip` or `StatsByCategory` usage):

- // Old: fixed value or direct reference to base shot
- SHOT_HEAT_PER_SECOND = 0
-
- // New (derived using OVERCLOCK)
- SHOT_HEAT_PER_SECOND = (&~/OVERCLOCK/HEAT_PER_SHOT) * (&~/Part/SecondaryToolTip/StatsByCategory/0/Stats/ROF)

Toggle wiring minimal example (make the OC shot selectable)

- // Old: single-shot reference
- ShotID = "SW.turbolaser_turret_light_laser_blue_shot"
-
- // New: allow a toggle to choose between normal and OC shots (pseudocode)
- Shots
- {
-     Normal = "SW.turbolaser_turret_light_laser_blue_shot"
-     Overclock = "SW.turbolaser_turret_light_laser_blue_overclock"
- }
-
- // Then in the part's Components that emit the shot, switch to &~/Shots/Overclock when the toggle is active.

Minimal diff example (apply to `ships/terran/weapons/turbolasers/Turbolasers_Light/light_turbolaser_switchable.rules`)

Replace this (simplified):
- // near the top of the file
- // ...existing header and constants...
-
- // hardcoded heat/dps
- SHOT_HEAT_PER_SECOND = 0
-
- // Shot reference used by the weapon
- ShotID = "SW.turbolaser_turret_light_laser_blue_shot"

With this (minimal, reference-based):
- // ...existing header and constants...
-
- OVERCLOCK
- {
-     ENABLED = true
-     FIRE_RATE_FACTOR = 75%
-     DAMAGE_FACTOR = 125%
-     PROJECTILE_HEALTH_FACTOR = 175%
-     HEAT_PER_SHOT = 0.5
- }
-
- // Derived heat uses the turret's ROF and the OVERCLOCK scalar
- SHOT_HEAT_PER_SECOND = (&~/OVERCLOCK/HEAT_PER_SHOT) * (&~/Part/SecondaryToolTip/StatsByCategory/0/Stats/ROF)
-
- Shots
- {
-     Normal = "SW.turbolaser_turret_light_laser_blue_shot"
-     Overclock = "SW.turbolaser_turret_light_laser_blue_overclock"
- }
-
- // In the emitter component use the selected shot based on toggle (psuedocode)
- // EmitterShot = &~/Shots/Overclock  // when OC toggle true

Notes & assumptions:
- This example uses the repo's common convention of storing derived stats on `SecondaryToolTip` / `StatsByCategory`. Your actual file may use `PrimaryToolTip` or inline `Stats` — adapt accordingly.
- The DSL doesn't have a single standard toggle API across mods; the important part is to centralize the shot IDs under a small `Shots` or `OVERCLOCK` table so you only change wiring in the emitter/shot reference once.
- If the turret uses explicit `Toggle` nodes in `Gui/PartToggles`, add a new toggle entry and ensure `mod.rules` adds the GUI toggle definitions (see existing `gui/game/parts/SW_part_toggles.rules`).

Tracing what the backup changed (how to diffs quickly):
1. Open `Turbolasers_Light/backup/light_turbolaser_light.rules` (or the actual backup copy) and the new `light_turbolaser_switchable.rules`.
2. Grep for `OVERCLOCK`, `ShotID`, `Shot` and `HEAT_PER_SHOT` differences.
3. Copy the small `OVERCLOCK` block and the `Shots` mapping into the new file, then update emitters to read from the mapping.

If you want, I can:
- Generate the exact minimal patches replacing the header and emitter references in `light_turbolaser_switchable.rules` (I will read both the backup and current file and produce a ready-to-apply patch).
- Or create an example OC turret in `ships/terran/weapons/turbolasers/Turbolasers_Light/` with `OVERCLOCK` wired and toggles added so you can test in-game.
