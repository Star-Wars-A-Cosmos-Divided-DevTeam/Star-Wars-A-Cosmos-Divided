# Progress

## Working Configuration
- Metadata and core `Actions` are set up to register SW_* effect lists, GUI hooks, and resource placeholders.
- Designer integrations (editor groups, stat widgets, toggles) reference existing GUI assets under `Gui/game/designer`.
- Career and PvP rule sets enumerate custom resources, tech unlocks, and sector asteroid mixes to surface new materials.

## Needs Attention
- `cosmoteer.rules` contains a malformed `SW_SHOTS` line (`= ... , = ...`); confirm runtime behavior and normalize when convenient.
- Several Actions in `mod.rules` remain commented placeholders and/or old disabled functionality (additional door categories, shader registry); determine whether to implement or remove.
- Many copies of vanilla files and folders are in the workspace but currently not necessary for use, as we should find opportunity to call these out for removal when we notice a file is inactive/disabled.  
- `foldercreater.rules` is intentionally empty—document this for contributors so the helper file is not deleted.
- The 0.30 "Meltdown Update" brought a new "overclocking" functionality that is currently partially implemented in this mod. Most Weapons and many Thrusters and Utility parts requires require updated code to include this. See working examples in: `ships\terran\weapons\turbolasers\Turbolasers_Siege_12x12\siege_turbolaser12x12.rules` and `ships\terran\reactor\battery\reactor_large\reactor_large.rules
- `sw_effects\` is in the process of being migrated to their appropriate `common_effects` and `shots` folders for a more standardized/consistent structure. To implement:
  - A complete list of currently used shots and effects needs to be identified for migration.
  - direct references to these shots and effects will need to be adjusted where appropriate. 
  - NOTE: Balance for Shields and Weapons needs to be adjusted/scaled to be more relative to vanilla Cosmoteer. Shot code should be cleaned up to allow for easier maintenance/updates. 

## Outstanding Work
- Re-verify compatibility and load order after each Cosmoteer update.
- Audit localized strings whenever new keys are introduced.
- Build a regression checklist covering asset additions (icons, particles, sounds, GUI wiring) to avoid missed references.
- Remove unused Vanilla copies of files.  For unreferenced or unused custom files (usually called out with .bak, "old", "bak", or "backup" in the file name) we should add a _backup folder in their existing dir and move them there.  

## Notes
- `memory-bank-init.rules` already summarizes many points; keep it synchronized with these files or retire it to avoid conflicting documentation.


