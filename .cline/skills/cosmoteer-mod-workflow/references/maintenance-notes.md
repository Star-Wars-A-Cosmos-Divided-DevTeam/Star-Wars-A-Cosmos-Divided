# Maintenance Notes

Current focus:
- Keep SW_* registries and GUI integrations coherent whenever parts, effects, or resources change.
- Register new content through `mod.rules` so it lands in the correct lists.

Watch items:
- Check `cosmoteer.rules` for duplicate `SW_SHOTS` assignment.
- Review commented Actions in `mod.rules` (doors, SW_SHADERS).
- Monitor upstream path changes under `<./Data/>` after updates.

Hygiene:
- Audit localized strings whenever new keys are added.
- Move unused or old files into `_backup` folders in their original directories.
