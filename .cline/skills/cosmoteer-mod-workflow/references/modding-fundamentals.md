# Cosmoteer Modding Fundamentals

- `.rules` files define most gameplay and content data.
- `mod.rules` is the mod entry point (ModInfo and actions).
- Content `.rules` files are aggregated via `cosmoteer.rules` or referenced by other rules.

When editing `.rules`:
- Validate brackets, indentation, and inheritance paths.
- Prefer inheriting from the closest vanilla part and override minimally.
- Verify components, graphics, and render layers when visuals misbehave.
- Confirm paths, Part/Projectile/Resources/Proxies/Text sprites match expected sections.
