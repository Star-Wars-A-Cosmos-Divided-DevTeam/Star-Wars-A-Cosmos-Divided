# AGENTS.md

## Scope
This repo is the Star Wars: A Cosmos Divided (SWACD) Cosmoteer mod. Use the skill `cosmoteer-mod-workflow` for any changes to `.rules`, strings, parts, shots, shields, UI, or balance.

## Base-game references
Preferred order for vanilla references:
1. Local install: `<Cosmoteer>/Data` (ask for exact path if not known).
2. GitHub mirror (unstable): `Rojamahorse/CosmoteerUpdates` branch `main-unstable`.
3. Standard Mods under local install for examples.

If the local path differs by machine, ask for it. The game data always lives under `Cosmoteer/Data` once the root is known.
On Windows, use a junction at `references/base-game` pointing to `X:/Program Files (x86)/Steam/steamapps/common/Cosmoteer/Data` (update drive letter as needed).

## Guardrails
- Open and inspect the target file before making changes. Do not assume missing blocks exist.
- If standardizing stats, verify that each target part actually has the fields before adding them.
- Weapons may reference multiple shot files; each shot must be updated for OC or other changes.
- Track cross-file chains (`&<...>` references) and confirm every reference resolves.
- For large files, use `rg` to narrow scope and edit only the relevant sections.

## Local references
- Skill references live in `.cline/skills/cosmoteer-mod-workflow/references/`.
- Additional notes are under `memory-bank/` and can be consulted as needed.

## Entry points
- `mod.rules` is the mod entry point. Use it to locate content additions and updates.
