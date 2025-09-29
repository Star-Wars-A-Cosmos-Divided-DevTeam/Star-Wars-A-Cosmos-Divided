# Tech Context

## Engine & Compatibility
- Targets Cosmoteer versions (currently 0.30.0–0.30.1), as declared in `mod.rules`.
- Lives under `Saved Games/Cosmoteer/.../Mods`; Cosmoteer loads `mod.rules` data on startup. 
- Version compatiblity control can be activated by including additional `*_mod.rules` files anywhere in the workspace. This is activated by using `CompatibleGameVersions`.  Note this functionality is not currently utilized in this mod. 

## Languages & Formats
- Must follow Cosmoteer's rules file syntax and structure
- `.rules` files follow Cosmoteer’s HJSON-like DSL (assignments, arrays, nested objects, comments).
- Art assets are `.png`; shaders referenced by name (e.g., `post_shaders/*.shader`); audio referenced through sound registries.
- Localization uses `.rules` with `Key = "Translation"` pairs per language.

## Tooling Expectations
- Authored in text editors/IDEs (VS Code + Cline); no compiling step.
- Maintain ASCII when possible; UTF-8 allowed for localized text already in repo.
- In-game dev tool, part tester and ship designer are the primary validation tools.

## External Dependencies
- Heavy reliance on vanilla data via `<./Data/...>` for inherited parts, shaders, materials, and drop tables.
- Asset pipelines (image/audio editors) are external but not tracked in the repo.
- SWACD: Factions (Add-on) Mod depends on Common Effects, toggles and buffs, within this mod.

## Build & Validation
- Enable the mod in Cosmoteer and restart after edits so `Actions` re-run.
- Watch Cosmoteer logs (in `Documents/My Games/Cosmoteer/`) for syntax errors or missing references.
- GUI and effect adjustments typically require a full game reload to ensure new assets are registered.
