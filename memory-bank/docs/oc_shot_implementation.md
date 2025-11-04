# Overclock Shot Standards & Conversion Workflow

This document defines how Star Wars: A Cosmos Divided standardizes projectile shots in the modern overclock (OC) format. Use it when building a brand-new shot, converting a legacy single-file shot, or auditing existing files to ensure they follow the same naming, inheritance, and variable patterns.

---

## Reference Materials at a Glance
- `memory-bank/examples/swacd_shot/` - working SW-ACD example that demonstrates the expected structure (`base_shot.rules`, color files, `overclock/`). Use this as the primary reference for variable placement and how OC files inherit.
- `memory-bank/docs/oc_overclock_shot_template.rules` - snippet library only. Copy *individual* behaviors (EMP, drain, etc.), not entire blocks.
- `memory-bank/examples/` - additional vanilla-aligned reference shots (flak, missiles, rails, etc.) for special behaviors.
- Vanilla OC shots under `./Data/shots/*/overclock/` - use these to confirm how the base game handles the mechanic you are mirroring.

---

## Workflow Overview
1. **Collect source data** from the legacy or target shot so you understand its damage model, visuals, and special mechanics.
2. **Pick comparison references** instead of duplicating folders. Start with the SW-ACD example, then the closest in-mod shot, then a vanilla OC shot.
3. **Establish the base/variant/OC inheritance chain**, keeping shared values at the top of `base_shot.rules` and overriding only what each layer needs.
4. **Tune OC behavior and visuals** by reusing data from the non-OC files and scaling via variables, not magic numbers.
5. **Validate naming, references, and part hooks** so the new IDs match the standards and existing parts point to the updated shots.

---

## Step-by-Step Details

### 1. Gather the Legacy Intent
- Export the legacy shot's current values (damage, impulse, resource drain, visuals, etc.).
- Identify unique mechanics (EMP, battery drain, AoE, PD traits) that need to persist.
- Note any existing IDs that players might still reference so you can preserve them in `OtherIDs` later.

### 2. Choose Comparison References (No Copy-Paste Folders)
- Begin with `memory-bank/examples/swacd_shot/base_shot.rules` to understand the expected variable block at the top and how components reference those variables.
- Locate the closest existing SW-ACD shot that behaves similarly and open it side-by-side. Pull ideas, but *do not duplicate its files*.
- Open the nearest **vanilla** OC shot (`Data/shots/.../overclock/...`) to see how Cosmoteer themselves solved the mechanic.
- Use the snippet library only to lift individual effect definitions you explicitly need.

### 3. Build or Update `base_shot.rules`
- Keep all editable constants (damage, impulse, drain, ranges, etc.) at the top, mirroring the SW-ACD example. Name variables clearly (`DAMAGE_BASE`, `IMPULSE_BASE`, etc.).
- Ensure the base file contains the complete physics, hit logic, sprites, and general behavior for the *non-overclocked* shot.
- Follow the naming scheme: `ID = "SW.<family>_<size>_<type>_<color>_shot"`. If migrating, list the previous ID(s) in `OtherIDs` for backward compatibility.

### 4. Configure Color Variants
- One file per color (`blue_shot.rules`, `red_shot.rules`, etc.), inheriting from the base via `BASE = &<../base_shot.rules>` or inline `Components : &<../base_shot.rules>/Components` as needed.
- Limit overrides to visuals (media effects, sprites, glow), or behavior differences that truly are color-specific.
- For multi-color sets, the light turbolaser family in SW-ACD shows the intended organization and naming patterns.

### 5. Create `overclock/oc_base_shot.rules`
- Point `BASE = &<../base_shot.rules>` and expose OC tuning variables (`DAMAGE`, `IMPULSE`, `HEALTH`, etc.) using scalar math against the base variables.
- Inherit the `Components` block and override only the `BaseValue` fields that scale in OC mode. Avoid copying entire hit/visual blocks; reuse the base structure just like the example file does.
- Include any new OC-only mechanics (AoE damage, additional drain, Death triggers) here so that color variants do not duplicate logic.

### 6. Build OC Color Files (`oc_<color>_shot.rules`)
- Each file should set `BASE`, `OC_BASE`, and `COLOR_BASE` (mirroring the pattern in `memory-bank/examples/swacd_shot/oc_blue_shot.rules`).
- Reapply or override color-specific media references here. Keep them in sync with their non-OC counterpart to prevent drift.
- Do not introduce new stats in the color files; if the OC color needs unique numbers, add scalars to `oc_base_shot.rules` instead and reference them.

### 7. Finalize Naming and Compatibility
- IDs for OC files should use the `_overclock` suffix (e.g., `SW.turbolaser_turret_xx9_laser_base_overclock`).
- Retain any legacy IDs inside `OtherIDs` arrays so existing blueprints keep working.
- Verify every `&<...>` reference resolves to an existing file. Pay special attention to media paths, since OC variants re-point to base visuals.

### 8. Hook Up Parts and Test
- Update the relevant part files (e.g., switchable turrets) so `Shot` and `OverclockedShot` point to the new IDs.
- In game, confirm health, damage, impulse, and AoE values match the OC scalars, visuals trigger correctly, and console logs show no missing asset errors.

---

## Scenario-Specific Guidance
- **Multi-color projectile sets** - use the SW-ACD light turbolaser files as the comparison sample. Keep shared logic in the base/OC base, and isolate color media in the individual files.
- **Ion / drain-focused single-color shots** - compare against the heavy ion cannon shot and its vanilla OC counterpart to validate drain timing and status applications.
- **Form-factor changes (projectile -> beam, etc.)** - start from the vanilla small laser OC implementation to see how the base game handles beam transitions, then adapt the SW-ACD structure.
- **Point-defense / flak mechanics** - review vanilla PD or flak OC shots to match projectile lifetimes, AoE slices, and media expectations before layering in SW-ACD-specific variables.

---

## Variable & Media Organization Checklist
- Shared values live at the top of `base_shot.rules` and `oc_base_shot.rules`; lower files reference them through variables instead of hard-coded numbers.
- OC files inherit component trees wherever possible (`Components : &BASE/Components { ... }`). Override minimal leaf nodes to avoid drift.
- Color files only override visuals unless a mechanic is truly color-dependent.
- Whenever you reorder arrays (e.g., `HitEffects`), update any OC indices (`: ../^/0/HitEffects/0`) that rely on their position.

---

## Quick Validation
- `OtherIDs` include every legacy ID you replaced.
- All `&<...>` references resolve (run a console check if unsure).
- OC scalars are expressed as percentages or formulas, never raw duplicates.
- Part files reference the new shot IDs for both standard and OC firing modes.

---

Following this workflow keeps every shot consistent with the SW-ACD overclock standards while avoiding copy/paste errors and redundant maintenance.
