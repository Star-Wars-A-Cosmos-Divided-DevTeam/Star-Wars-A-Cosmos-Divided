# Star Wars: A Cosmos Divided

## Goal
- Deliver a data-driven Star Wars overhaul for Cosmoteer latest_builds (Currently 0.30.0–0.30.1) that feels native to the base game.
- This is a mod for the space strategy game Cosmoteer that adds a Star Wars theme to the game. The mod aims to bring the rich universe of Star Wars into the game, including ships, weapons, resources, and other elements that reflect the Star Wars universe.

## Scope
- Introduces Star Wars ship parts, weapons, hyperdrives, droids, shields, reactors, and supporting hull shapes.
- Adds custom resources (Agrinium, Durasteel, Doonium, Hypermatter, etc.) with effects, drop rates, and crafting integrations.
- Extends GUI/editor interactions (categories, stats widgets, indicators) so parts are discoverable and understandable.
- Bundles shared visual/audio effect registries to keep particle, sound, and shader usage consistent across assets.
- Add Style Customizations via UI Toggles to enhance user experience

## Non-Goals
- No changes to Cosmoteer’s core simulation, AI, or executable code. 
- Use and inherit base game assets minimally but where it makes sense to avoid incompatiblities and conflicts.
- Avoid diverging from vanilla balance philosophies beyond Star Wars flavor.
- Does not bundle the optional ship pack add-on.

## Success Criteria
- Mod metadata loads without errors; `Actions` successfully register SW_* lists and GUI integrations.
- Custom parts appear in designer groups with valid `Strings` entries and working stats toggles.
- Career/PvP modes recognize new resources, techs, and sector spawns.
- Shared effect registries resolve without missing assets or duplicate keys.


## Core Requirements and Goals
- Add authentic Star Wars themed content to Cosmoteer
- Maintain balance with existing game mechanics
- Create a cohesive Star Wars universe within the game
- Provide players with new strategic options and gameplay elements
- Follow Cosmoteer's development patterns and conventions

## Project Scope
This mod and its add-ons will include:
- Star Wars themed weapons and systems
- Star Wars themed resources and materials
- Star Wars themed factions and lore (Via Factions Add-on)
- Star Wars themed ship designs (Via Factions Add-on)
- Star Wars themed UI elements and effects