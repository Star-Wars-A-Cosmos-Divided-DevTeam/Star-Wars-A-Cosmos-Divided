# Shield Overclock Reference (Vanilla)

Summary of vanilla shield overclocking behavior (post-thermal network). Source paths are relative to the base game `Data` folder.

Shared overclock infrastructure (base_part_overclock.rules):
- Toggle: `thermal_overclock` with tweened `OverclockStateValue`.
- `IsOverclocked` drives `OverclockBuff` application.
- `OverclockReset` enforces cooldown after toggling off.
- Thermal ports and heat routing via `BASE_THERMAL_PORT`, `HEAT_TARGET_STORAGE`, and `OverflowHeatStorage`.
- Scorched status disables operation until cleared.

Key constants:
```
HEAT_TO_RESOURCE = &<./Data/statuses/heat/heat.rules>/STATUS_TO_RESOURCE_RATIO
HEAT_TO_STATUS   = &<./Data/statuses/heat/heat.rules>/RESOURCE_TO_STATUS_RATIO
```

Small shield generator highlights:
- Two modes: Extended and Reinforced via `overclock_shield` toggle.
- Mode ramping is clamped by `OverclockStateValue`.
- Uses `ShieldOverclockExtended` / `ShieldOverclockReinforced` buffs.
- Overload visuals are tied to `cosmoteer.shield_overload`.

Large shield generator highlights:
- Single overclock profile (`Overclock` buff).
- Heat and damage drain factors differ from small shield.
- Uses the same overload scaling block as small shield.

Status interactions:
- `cosmoteer.scorched` disables part operation and command usage.
- `cosmoteer.heat` drives heat damage and fire when high.
- `cosmoteer.shield_overload` scales drain and heat; also drives visuals.

Parity checklist for mod shields:
1. Include `ScorchedToggle` and `OverclockReset` logic.
2. Use vanilla naming for overclock UI and state (`thermal_overclock`, `OverclockStateValue`).
3. Route heat through `HEAT_TARGET_STORAGE` and thermal ports.
4. Apply status multipliers to `BatteryStorage` and `ResourceDrainPerDamage`.
5. Expose the correct buff types in `ReceivableBuffs`.
6. Keep command and power stats aligned unless intentionally diverging.
