# Project Context

Goal:
- Deliver a Star Wars themed overhaul that feels native to Cosmoteer, targeting the latest unstable/release candidate builds.

Scope:
- Star Wars parts, weapons, shields, reactors, hyperdrives, droids, and hull shapes.
- Custom resources (hypermatter, durasteel, doonium, etc.) with effects and crafting.
- GUI/editor categories, stats widgets, and indicators for new systems.
- Shared SW_* effect registries (particles, sounds, shaders).

Non-goals:
- No changes to Cosmoteer executable or core simulation.
- Avoid large balance divergence unless intentional.

Success criteria:
- `mod.rules` Actions load without errors and register SW_* lists.
- Parts appear in designer groups with valid strings and stats toggles.
- Career/PvP modes recognize new resources and tech.
- Shared registries resolve without missing assets or duplicate keys.

Versioning:
- Base game updates are sequential; mirror latest unstable when possible.
- `CompatibleGameVersions` is available but not used yet.

Design intent:
- Authentic Star Wars aesthetics.
- Clear UI feedback for systems like hypermatter and overclock.
- Maintain parity with vanilla patterns.
