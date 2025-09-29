# Active Context

## Current Focus
- Maintain authoritative Memory Bank documentation so each fresh session reconstructs how the mod hooks into Cosmoteer’s systems.
- Keep the SW_* registries and GUI integrations coherent whenever parts, effects, or resources change.

## Recent Insights
- Registry creation follows `Add -> Overrides` to seed empty collections before populating them with actual effect lists.
- Localization coverage spans ten languages; new keys should be added consistently or documented for follow-up.

## Open Questions / Watch Items
- Investigate the duplicate assignment in `cosmoteer.rules` for `SW_SHOTS` to confirm parser tolerance and correct if necessary.
- Review commented-out Actions in `mod.rules` (doors, SW_SHADERS) to decide whether they are future work or legacy cruft.
- Monitor Cosmoteer updates beyond 0.30.1; upstream path changes under `<./Data/>` may require adjustments.

## Immediate Next Steps
- Register any new content through `mod.rules` so it lands in the appropriate SW_* collection and GUI categories.
- Update this Memory Bank whenever structural changes occur to prevent drift.
