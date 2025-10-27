# Cosmoteer – Shield Overclock Reference

This note summarizes how the vanilla Cosmoteer shield generators implement overclocking, heat, and scorched behaviour as of the 0.27 (post-thermal network) rulesets. Source paths are relative to the base game data directory (e.g. `Data/ships/terran/shield_gen_small/shield_gen_small.rules` on a default Steam install).

## Shared Overclock Infrastructure

Vanilla shields inherit from `Data/ships/base_part_overclock.rules`, which layers on top of `base_part.rules`. The overclock base provides three pillars that every thermal-capable part now shares:

- **UI & State Flow (`base_part_overclock.rules:24-88`)**  
  - `OverclockModeToggle` (`ToggleID = "thermal_overclock"`, default 0) is the player-facing control.  
  - `OverclockStateValue` is a tweened ramp (1 s on, 0.1 s off) so shield stats lerp in/out instead of snapping.  
  - `IsOverclocked` is a threshold toggle on `OverclockStateValue`. When on, `OverclockBuff` injects the `Overclock` buff (or, for the small shield, its derived buffs).  
  - `OverclockReset` enforces a 3 s cooldown after turning the toggle off; the part cannot return to full operation until the timer expires. The progress bar tied to `OverclockReset` drives the in-game “resetting” indicator.

- **Thermal Network Contracts (`base_part_overclock.rules:6-22`, `94-156`)**  
  - `BASE_THERMAL_PORT` is the reusable `NetworkPort` template. Parts clone it to create actual ports (e.g. `Port_BL`). Ports only connect to thermal sinks on the output side.  
  - `HEAT_TARGET_STORAGE` is the `MultiResourceStorage` that hands heat to the thermal network (`NetworkHeatInput`) and, if saturated, to `OverflowHeatStorage`.  
  - `OverflowHeatStorage` feeds `OverheatEffects`, which apply the `cosmoteer.heat` status to the part’s tiles. Heat is propagated to the ship via the thermal network unless sinks (pumps/radiators) remove it.

- **Status Hooks**  
  - Every inheritor should add `ScorchedToggle` (status `cosmoteer.scorched`) to its `IsOperational` block so scorched parts hard-disable.  
  - When scorched clears, the base toggle allows operation again.

Key conversion constants live at the top of each part file:

```rules
HEAT_TO_RESOURCE = &<./Data/statuses/heat/heat.rules>/STATUS_TO_RESOURCE_RATIO   // 1000
HEAT_TO_STATUS   = &<./Data/statuses/heat/heat.rules>/RESOURCE_TO_STATUS_RATIO   // 0.001
```

Consequence: generating 20 “heat” resources pushes 0.02 status value onto affected tiles.

## Small Shield Generator (`shield_gen_small.rules`)

### Overclock Modes

The small generator extends the base buff system with two mutually exclusive modes, exposed through `Overclock_ShieldModeToggle` (`ToggleID = "overclock_shield"`, default “Extended”). Tweened mode values (`Overclock_ExtendedModeRawValue`, `Overclock_ReinforcedModeRawValue`) are clamped by the main `OverclockStateValue`, so mode ramping never outruns the global overclock tween.

Mode characteristics (`lines 1-23`):

| Mode | Arc Factor | Radius Factor | Damage Drain Factor | EMP Resist | Heat / Damage |
|------|------------|---------------|---------------------|------------|---------------|
| Extended | 150 % | 150 % | 1.0 (unchanged) | 0 | 0.5 |
| Reinforced | 55 % | 100 % (unchanged) | ½ (double effective HP) | 33 % | 0.6 |

Both modes inherit the base `HEAT_PER_SECOND = 40`. Switching modes takes the shared `MODE_SWITCH_TIME = 1` second because the mode toggles reuse the same tween durations.

### Buff Delivery

- `Overclock_ExtendedModeBuff` / `Overclock_ReinforcedModeBuff` apply the `ShieldOverclockExtended` / `ShieldOverclockReinforced` buff types (defined at `Data/buffs/buffs.rules:175-176`).  
- `ReceivableBuffs` exposes those types so crew/commands can see them (`shield_gen_small.rules:41-44`).

### Core Components

- **Arc Shield (`shield_gen_small.rules:210-273`)**  
  - `Arc` and `Radius` pull multipliers from the active buff.  
  - `ResourceDrainPerDamage` multiplies by `OVERCLOCK/REINFORCED/DAMAGE_DRAIN_FACTOR` if the reinforced buff is active, and by `cosmoteer.shield_overload` status value—overloaded shields leak more power.  
  - `PenetrationResistance = [25, 0]` as base.

- **Battery & Command**  
  - `BatteryStorage` is 6 000 power with `DrainResistance` adding EMP resist while reinforced.  
  - `CommandConsumer` costs 3 command points when operational.

- **Scorched Fail-safe (`lines 58-82`)**  
  - `ScorchedToggle` inverts the status check; `IsOperational` only resolves true when the part is both powered and not scorched.

- **Overload Visuals (`lines 598-795`)**  
  - `OverloadValue` reads the `cosmoteer.shield_overload` status directly.  
  - `OverloadEffect`, `Overclock_OverloadEffect_Extended`, and `_Reinforced` mimic the main ArcShield with distinct shaders (`shield_overload.shader`, `shield_overload_oc.png`). Vertex colour intensity is driven by the overload status.

### Heat Flow

- `OverclockHeatProducer` ticks every 0.5 s and injects `ceil(40 * Interval) = 20` heat units, which becomes 20 000 heat resource (20 status) before routing through the thermal network.  
- `OverclockHitHeatProducer` listens to `ArcShield` hits via `Overclock_ArcShieldProxy`. Heat per damage is mode-dependent and is multiplied when the shield carries `cosmoteer.shield_overload`.  
- Ports `Port_BL`, `Port_BR`, `Port_BD0`, `Port_BD1` clone `BASE_THERMAL_PORT`, exposing the part to thermal sinks.

### Example: Extended Mode Burst

1. Player enables overclock and keeps the default extended mode.  
2. After 1 s, `OverclockStateValue` reaches 1.0; the shield now projects 150 % arc + radius.  
3. Heat per second → 40 × HEAT_TO_RESOURCE (1000) = 40 000 resource (40 status) per second, halved across the two 0.5 s ticks.  
4. Each incoming damage point adds 0.5 × 1000 = 500 resource (0.5 status).  
5. If overload builds up to 2.0, per-damage heat doubles to 1.0 (1 000 resource) until the status decays.

## Large Shield Generator (`shield_gen_large.rules`)

The large generator inherits `base_large_part_terran_overclock.rules` but keeps a single overclock profile (`ReceivableBuffs` only lists `Overclock`).

### Overclock Parameters (`lines 1-8`)

- `ARC_FACTOR = 50 %` (halves coverage while overclocked).  
- `DAMAGE_DRAIN_FACTOR = 1 / 200 % ≈ 0.5`, making the shield twice as power-efficient per damage taken.  
- `EMP_RESIST = 33 %`, identical to the small reinforced mode.  
- `HEAT_PER_SECOND = 80` and `HEAT_PER_DAMAGE = 0.6`.

### Components

- `ArcShield` radius is static (13 units). Only the arc shrinks under the overclock buff.  
- `ResourceDrainPerDamage` multiplies by the same overload status and damage drain factor as the small shield.  
- `BatteryStorage` is 18 000 power and gains EMP resist from the `Overclock` buff.  
- `CommandConsumer` draws 6 command points while active.  
- `OverclockHitHeatProducer` imports the modifier block from the small shield (`line 613`), so overload scaling and other multipliers stay consistent.

### Thermal Topology

- Ports mirror the base layout but spread across three tiles (`Port_BL/BR` at `[0,5]`/`[2,5]`, `Port_BD0-2` for the aft edge).  
- `OverheatEffects` reuse the base implementation with a central location `[1.5,3]`.

### Example: Sustained Overclock

- At full overclock, the part generates `80 * 1000 = 80 000` heat resource per second. Without cooling, `OverflowHeatStorage` begins applying `cosmoteer.heat` after roughly 4–5 seconds (once the thermal network storage saturates).  
- A 2 000 damage volley while overloaded (status ≈ 3) converts `0.6 * 3 * 1000 = 1 800` heat resource per damage point—1.8 M resource total—virtually guaranteeing a heat spike that must be dumped by radiators or pumps.

## Status Interactions

### `cosmoteer.scorched` (`Data/statuses/scorched/scorched.rules`)

- Value range [0,1]; parts become inoperable when ≥ 1.  
- Adds fire resistance while active and slowly self-repairs (SoftRepair) back to 0.  
- Shields include `ScorchedToggle` in both their operational and command-consumption chains, so even crew resupply halts when scorched.

### `cosmoteer.heat` (`Data/statuses/heat/heat.rules`)

- Converted from stored heat via `RESOURCE_TO_STATUS_RATIO`.  
- Starts ticking effects at value 350 (damage-over-time, fire ignition).  
- Diffuses through structure tiles and can trigger fires, which in turn accelerate scorched build-up.

### `cosmoteer.shield_overload` (`Data/statuses/shield_overload/shield_overload.rules`)

- Applied by shield-specific hit effects (e.g. resonance beams or overload projectiles).  
- The status value directly feeds `OverloadValue`, which colours the shield arcs and increases power drain & per-damage heat through multiplicative modifiers.

## Parity Checklist for Mod Shields

When reviewing custom shields against vanilla, ensure the following hooks are present:

1. **Operational toggles** include both `ScorchedToggle` and the inherited `OVERCLOCK_OPERATIONAL` timer from `base_part_overclock.rules`.  
2. **Overclock UI & Buffs** follow the vanilla naming (`thermal_overclock`, `OverclockStateValue`), so shared UI and hotkeys work.  
3. **Heat routing** uses `HEAT_TARGET_STORAGE`, `OverclockHeatProducer`, `OverclockHitHeatProducer`, and clones of `BASE_THERMAL_PORT`.  
4. **Status-based multipliers** (`shield_overload`, AMP/EMP resist) are wired into `BatteryStorage` and `ResourceDrainPerDamage`.  
5. **Receivable buffs** cover `ShieldOverclockExtended`/`ShieldOverclockReinforced` (small) or `Overclock` (large) so crew can activate the new vanilla modes.  
6. **Command costs & power stats** reflect vanilla baselines unless intentionally diverging, as they influence recommended crew/power stats shown in the tooltip (`StatsByCategory`).

Missing any of the above is a likely source of behavioural drift between the mod and current vanilla shields.

