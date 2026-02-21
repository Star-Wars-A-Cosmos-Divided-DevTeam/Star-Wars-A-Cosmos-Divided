# Rules Language: Style and Safety Checks

When proposing `.rules` changes:

1) Inheritance and references
- Confirm parent paths exist by opening the parent file.
- Avoid copy/paste bloat; prefer inheritance with clear overrides.
- Paths act like file paths but allow extra notation for mod flexibility.

2) Paths and notation
- `&` at the start means copy-reference (copy data).
- No `&` means actual reference (link to the original object).
- `./` starts at the game data root.
- `../` goes up one level from the current node.
- `~/` starts at the top of the current rules file.
- `^/` references inherited data from the parent node.
- `{}` denotes a node, `[]` denotes a list (index from 0).

3) Inheritance syntax
- `:` means inherit and modify a node.
- `{}` after `:` is required, even if empty.
- If you want a full replacement, use `=` instead of `:`.

4) Strings and localization
- If changing `NameKey` or `DescriptionKey`, add entries under `strings/`.

5) Assets and graphics
- Match sprite paths and dimensions.
- Re-check render layers and Z order if sprites do not show.

6) Testing
- Load the mod with only required mods enabled.
- Check logs for missing references.

Example path usage:

```
MaxStackSize = (&<./Data/resources/carbon/carbon.rules>/MaxStackSize)
NormalsFile = "silver_normals.png"
```

Example copy vs reference:

```
&<super_armor/super_armor.rules>/Part   // copy
<super_armor/super_armor.rules>/Part    // reference
```
