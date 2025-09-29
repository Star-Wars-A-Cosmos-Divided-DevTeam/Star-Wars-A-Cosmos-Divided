---
name: Cosmoteer – Modding Fundamentals
globs: ["**/*.rules", "**/*.txt", "**/*.png"]
description: Reminders about Cosmoteer mod structure so suggestions stay valid.
---

# Cosmoteer Modding – Fundamentals

- **`.rules` files** are Cosmoteer’s primary building blocks for gameplay & content. Use the wiki’s canonical format and actions. 
- `mod.rules` is the mod’s **entry point** (ModInfo) defining metadata and actions.
- `.rules` in content areas (parts, projectiles, resources, etc.) define game objects that are aggregated via `cosmoteer.rules` or referenced by other rules.

## When editing `.rules`:
- Validate brackets, indentation, and inheritance paths.
- Check **Paths**, **Part**, **Projectile**, **Resources**, **Proxies**, **Text sprites**, etc., per wiki sections.
- Prefer inheriting from a closest vanilla part and **override fields** minimally.
- Verify **components**, **graphics**, and **render layers** are correct when visuals misbehave.
- Ensure path structures and inheritance are accurately used!!
