---
name: SWACD – Repo Architecture
globs: ["**/*"]
description: High-level map of this repo to steer agent navigation & code search.
---

# Repository Architecture (SWACD)

The repo contains major content areas commonly referenced by Cosmoteer `.rules`:

- `./data/` – **root entry** for inheritance of parts & configs aggregation from the main unmodded game.
- `mod.rules` – **mod manifest/actions** entry point for mods.  Actions are used in the mod.rules to inject .rules configuration files into cosmoteer.rules (the main vanilla game). Actions may replace, remove, override, or add/addmany parts, configs, or other files.
to the game.

- Top-level asset/content folders for the main game (note the mod does not need to match these, but this is good to know for the general structure of a mod):
  - `factions/`, `ships/`, `resources/`, `Resources/`, `shots/`, `gui/`, `strings/`, `common_effects/`, `sw_effects/`, `statuses/`, `doodads/`, `modes/`, `roof_decals/`, `post_shaders/`, `wip_sketches/`, etc.

**Navigation guidance**
- When user asks “where is X defined?”, search in order:
  1. This branch's `mod.rules` to see a high level view of what is added/changed to the game through this mod.  You will need to follow the paths to find more useful details. 
  2. The relevant content folder (e.g., `ships/`, `factions/`, `resources/`, `shots/`)
  3. Shared tables/effects: `common_effects/`, `sw_effects/`, `statuses/`
  4. UI/strings: `gui/`, `strings/`
  5. A parts list for most mods can be found in `ships\terran\terran.rules`, you will need to view the individual files in that list to find detail of what that part entails.  A part may also reference, ui toggles, 'shots', 'effects', 'sounds', etc. you can find that from the individual part file.

**Notes**
- Keep path case-sensitivity in mind only for readibility, (`Gui/` vs `gui/`, `Resources/` vs `resources/` are both are interpretted the same way in the mod).
- Prefer **relative references** consistent with repo patterns.
