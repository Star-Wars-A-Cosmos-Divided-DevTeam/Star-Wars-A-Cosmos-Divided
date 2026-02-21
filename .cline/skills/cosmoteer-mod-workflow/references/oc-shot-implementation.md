# Overclock Shot Standards and Conversion Workflow

Use this when building a new shot, converting a legacy shot, or auditing shots for OC consistency.

Reference materials:
- `memory-bank/examples/swacd_shot/` for expected structure (`base_shot.rules`, color files, `overclock/`).
- `references/oc-overclock-shot-template.rules` as a snippet library (copy individual behaviors only).
- `memory-bank/examples/` for vanilla-aligned reference shots.
- Vanilla OC shots under `Data/shots/*/overclock/`.

Workflow:
1. Collect source data (damage, impulse, drain, visuals, special mechanics).
2. Pick comparison references (SWACD example, closest in-mod shot, vanilla OC).
3. Build the base/variant/OC inheritance chain.
4. Tune OC behavior via variables, not duplicated numbers.
5. Validate naming, references, and part hooks.

Base shot rules:
- Keep editable constants at the top (e.g., `DAMAGE_BASE`, `IMPULSE_BASE`).
- Use `ID = "SW.<family>_<size>_<type>_<color>_shot"` and put old IDs in `OtherIDs`.

Color variants:
- One file per color, inheriting from the base.
- Overrides should be visual unless truly color-specific.

OC base:
- `BASE = &<../base_shot.rules>`.
- Expose OC scalars in `oc_base_shot.rules` and override only minimal leaf nodes.

OC color files:
- Set `BASE`, `OC_BASE`, and `COLOR_BASE`.
- Keep visual overrides in sync with non-OC counterparts.
- Avoid new stats here; use `oc_base_shot.rules` instead.

Naming and compatibility:
- OC IDs use `_overclock` suffix.
- Preserve legacy IDs in `OtherIDs`.

Part hook-up:
- Update both `Shot` and `OverclockedShot` in parts.

Validation checklist:
- All `&<...>` references resolve.
- OC scalars are formulas or percentages, not raw duplicates.
- Color files only override visuals.
- If arrays are reordered, update any index-based references.
