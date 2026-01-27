---
name: cosmoteer-mod-workflow
description: Cosmoteer modding workflow for SWACD. Use when editing or auditing .rules, strings, parts, shots, shields, UI, and balance; importing new base-game features; refactoring for readability; or preparing migration-ready changes. Triggers on tasks like "update to latest release", "rebalance parts", "add overclock behavior", "merge vanilla features into a custom part", and "clean up large rules files with lots of cross-file references".
---

# Cosmoteer Mod Workflow

## Overview

Use this skill to plan and execute safe, minimal, well-referenced changes to Cosmoteer mod content, especially when files are large, chained, or derived from base-game behavior.

## Workflow Decision Tree

Pick the path that matches the request:

- **Feature import from base game** -> Use "Feature Import Workflow".
- **Rebalance existing parts** -> Use "Rebalance Workflow".
- **Readability refactor / style cleanup** -> Use "Refactor Workflow".
- **Production migration prep** -> Use "Migration Workflow".
- **Composite parts (new behaviors)** -> Use "Composite Part Workflow".

## Intake Checklist (always)

1. Identify the exact target files (open them; do not assume structure).
2. List the current inheritance chain and key references (`BASE`, `Components`, `Shot`, `OverclockedShot`, etc.).
3. Note any cross-file dependencies (shots, particles, strings, buffs, statuses, GUI).
4. Confirm which base-game version or reference to mirror (local install vs GitHub).
5. Ask for missing constraints (balance targets, compatibility needs, migration timeline).

## Base-Game Reference Selection

Preferred order:

1. **Local install** under `Cosmoteer/Data` (best fidelity).
2. **GitHub mirror** for unstable (`Rojamahorse/CosmoteerUpdates`).
3. **Standard Mods** (local) for implementation examples.

If local path is missing or differs by machine, ask for the exact path.

## Feature Import Workflow (base game -> mod)

1. Find the vanilla file(s) that implement the feature.
2. Identify the minimal set of blocks to add or override.
3. Map each block to the mod's structure (existing inheritance, shared helpers, custom variables).
4. Update any dependent files (shots, statuses, buffs, GUI, strings).
5. Validate references and only then add new data.

## Rebalance Workflow

1. Extract current stats into a short summary table.
2. Identify which stats are inherited vs locally defined.
3. Change the minimal set of values needed (prefer top-level variables).
4. If multiple variants exist, update each variant explicitly (no blind copy).

## Refactor Workflow (readability / standardization)

1. Preserve behavior; only reorder or rename where safe.
2. Introduce shared variables only if the data truly exists in the target.
3. Avoid adding new blocks that the target file never had.
4. Keep diffs minimal and localized.

## Migration Workflow (production prep)

1. Confirm the base-game version you are migrating to.
2. Identify breaking changes and new features in vanilla.
3. Apply updates in dependency order (core helpers -> shots -> parts -> UI/strings).
4. Keep compatibility mappings (`OtherIDs`, legacy keys) when needed.

## Composite Part Workflow (new behaviors)

1. Enumerate each behavior and its source reference.
2. Confirm the target part already includes or can safely add the required blocks.
3. Wire behavior per component (do not assume one block applies to all).
4. Validate all shot/overclock references for each firing mode.

## Guardrails (avoid common AI failures)

- **No assumptions**: Open the target file and verify what exists before adding new blocks.
- **No blind standardization**: Only add "base stats" blocks when the target has matching fields.
- **Shot references**: If a weapon uses multiple shot files, each needs its own OC linkage.
- **Cross-file chains**: Track each `&<...>` and confirm it resolves.

## Large File Handling

When a file is huge:
1. Use `rg` to locate the precise node(s).
2. Open only the relevant sections.
3. Produce minimal diffs scoped to those sections.

## References (load as needed)

- `references/project-context.md`: Mod goals, scope, and success criteria.
- `references/system-patterns.md`: Entry points, Actions patterns, registries, syntax gotchas.
- `references/maintenance-notes.md`: Watch items and hygiene.
- `references/base-game-linking.md`: Local base-game path and junction/symlink guidance.
- `references/modding-fundamentals.md`: Mod structure, entry points.
- `references/rules-language-style.md`: Rules syntax, path and inheritance safety.
- `references/strings-guide.md`: Strings formatting and tags.
- `references/oc-shot-implementation.md`: Overclock shot workflow.
- `references/oc-overclock-shot-template.rules`: OC shot snippet library.
- `references/shield-overclock-reference.md`: Vanilla shield overclock details.
- `references/swacd-bubble-shields-reference.md`: SWACD shield architecture and balance notes.
