# Overclock Shot Implementation Guide

This guide explains how to author Cosmoteer overclock shot files using the reusable template stored at `memory-bank/docs/oc_overclock_shot_template.rules`. It captures the multi-parent inheritance pattern used throughout Star Wars: A Cosmos Divided and highlights where to scale damage, impulse, and structural values.

## When to Use
- Creating a new overclocked projectile that inherits base damage logic from an existing shot.
- Updating color variants (e.g., red/blue/green) that share a common `oc_base_shot.rules` but require boosted media effects.
- Porting a vanilla overclock implementation into the SWACD pipeline while keeping visuals defined in color-specific files.

## Recommended Workflow
1. **Copy the template** (`memory-bank/docs/oc_overclock_shot_template.rules`) into the target folder (e.g., `shots/laser/turret/turbo/CIS/overclock/`). Rename it to match your projectile (for example `oc_purple_shot.rules`).
2. **Wire the parents.**
   - `BASE` should point at the non-overclock parent (usually `../base_shot.rules`).
   - `OC_BASE` targets the shared overclock behavior file (`../overclock/oc_base_shot.rules`). If no shared OC layer exists yet, point it back to `BASE`.
   - `COLOR_BASE` references the visual variant (e.g., `../purple_shot.rules`) so you can borrow media effects when needed.
   - Update `COMPONENT_SOURCE` to the parent whose component tree you want to clone (`OC_BASE` by default).
3. **Fill in identifiers.** Replace `SW.example_overclock_shot` with a unique `SW.*` ID and adjust any localization keys or registry hooks in the referencing weapon file.
4. **Tune the scalar block.**
   - Set the percentage multipliers for area, shield, explosive, impulse, and structural damage at the top of the file.
   - The derived section auto-calculates the actual numbers using base-shot values, so you only need to tweak the scalars.
   - For radius overrides, you can leave the inherited path or replace it with literals (e.g., `5`).
5. **Enable hit variations.** Uncomment the blocks inside `HitOperational/HitEffects` to add explosive payloads, resource drains (e.g., disruptor bolts), status effects, or specialized system/EMP damage. Each block is pre-wired to the derived values so you only change the scalar or asset references.
6. **Mirror shield and structural logic.** The template already scales shield hits and structural spillover damage to match the operational values. Adjust `STRUCT_*` scalars if you need different ratios.
7. **Swap visuals as needed.** Uncomment the optional `MediaEffects` or `Sprite` sections to point at larger particles/sounds for the OC variant. Because the visuals are isolated in color files, keep shared media in the base color shot and only override what changes for the overclocked look.
8. **Hook the OC shot to parts.** Update the relevant weapon part (`cis_turbolaser_switchable.rules`, etc.) so the overclock toggle references the new shot ID.

## Tips & Patterns
- When scaling structural damage, the template multiplies the operational damage by the existing structural ratios taken from the base shot. This keeps the structural profile synchronized with the original projectile.
- Use the optional penetration block if the base shot already defines `PenetratingOperational`. Set `PENETRATION_DISTANCE` in the scalar section and uncomment the property.
- For heavy media overrides, inherit from the color parent instead of re-listing every particle. You can append new effects in the OC file while still pulling the base visuals with `&COLOR_BASE/Components/...`.
- Always confirm the resulting numbers with Cosmoteer’s debug inspector after loading the mod; the derived section makes it easy to tweak percentages without chasing nested nodes.

## Related References
- Vanilla overclock examples under `./Data/shots/*/overclock/` (see `laser_bolt_large_overclock.rules` for a baseline scaling pattern).
- Existing SWACD implementations in `shots/laser/turret/turbo/light/overclock/` and `shots/laser/turret/turbo/CIS/overclock/` for practical usage of the shared OC base.


