# Base-Game Linking

Preferred local base-game path pattern:
- `X:/Program Files (x86)/Steam/steamapps/common/Cosmoteer/Data`

If a direct symlink requires admin rights on Windows, use a junction instead.

Recommended repo reference:
- `references/base-game` should point to the base-game `Data` folder.

PowerShell examples:
```
# Junction (no admin in most setups)
New-Item -ItemType Junction -Path "references/base-game" -Target "X:/Program Files (x86)/Steam/steamapps/common/Cosmoteer/Data"

# Symlink (may require admin)
New-Item -ItemType SymbolicLink -Path "references/base-game" -Target "X:/Program Files (x86)/Steam/steamapps/common/Cosmoteer/Data"
```

If the drive letter differs by machine, update the junction target.
