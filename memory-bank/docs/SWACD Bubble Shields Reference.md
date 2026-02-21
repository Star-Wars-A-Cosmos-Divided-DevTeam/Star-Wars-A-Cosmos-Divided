# SWACD Bubble Shields Reference

This note captures the current structure, behaviour, and balance considerations for the Star Wars “bubble” shield generators (`shield_1`, `shield_2`, `shield_4`, `shield_8`). It builds on the vanilla shield analysis so we can keep mod parity in sight.

## Architecture Overview

- **Base stack** – Every shield inherits the SW-specific wrappers down to vanilla:
  - `ships/terran/base_part_terran_sw.rules` → vanilla `Data/ships/terran/base_part_terran.rules`.
  - `ships/terran/base_part_terran_sw_operational.rules` adds the shared `CommandToggle` plumbing.
  - `ships/terran/base_part_terran_sw_scorched.rules` introduces `ScorchedToggle` gating and scorch FX.
  - `ships/terran/base_part_terran_sw_overclock.rules` extends the vanilla overclock contract (thermal ports, `OverclockReset`, `OverclockStateValue`, self-applied `Overclock` buff).
  - `ships/terran/shields/base_part_terran_shields.rules` is the local fork used by all bubble shields.
- **Shield profiles** – `shield_1.rules`, `shield_2.rules`, `shield_4.rules`, `shield_8.rules` define the gameplay stats, thermal routing, FX toggles, editor details, and Stats blocks for each footprint.
- **Colour modules** – Each shield footprint has a folder of colour variants (`shield_X/shield_X_blue.rules`, …). The parent part toggles these components based on `SW.shield_color_type`.
- **ShieldTuner** – `ships/terran/shields/ShieldTuner.rules` centralises per-class geometry (radius, placement), penetration resistance, shader tuning, and shared colour palettes.
- **Additional helpers** – Larger shields add optional travel blocking (`shield_8/shield_8_additional.rules`) and rely on custom textures (`shield_energy.png`, `shield_mask.png`, etc.) inside the same directory.

## Base Part Stack Details

- `base_part_terran_sw_overclock.rules` retains vanilla overclock behaviour (thermal ports, `HeatDistributionStorage`, auto-reset timers) and exposes the `thermal_overclock` toggle UI.
- `base_part_terran_sw_scorched.rules` ensures scorched parts refuse to operate or consume crew commands until the status clears.
- `base_part_terran_shields.rules` simply inherits the overclock layer but clears the default type/category lists so each shield can redefine them.

## ShieldTuner Highlights

The tuner provides reusable data blocks consumed by every colour variant:

| Classification | Radius | Penetration Resistance | Wave Speed | Size vector |
|----------------|--------|------------------------|------------|-------------|
| `Small`        | 10     | `[4, 0]`               | 2.00       | `[0, 1.6875]` |
| `Med`          | 20     | `[16, 0]`              | 1.50       | `[0, 3.375]` |
| `Huge` (4×4)   | 40     | `[64, 0]`              | 1.00       | `[0, 6.75]`  |
| `Giga` (8×8)   | 80     | `[256, 0]`             | 0.81       | `[0, 13.5]`  |

Other shared settings:

- `All` sets the base arc geometry (`Arc = 186°`, `HitArc = 18.6°`), keeps shields from being blocked by operational parts, and defines the `ResourceDrainPerDamage` block with the built-in overclock multiplier (`BuffType = Overclock`, `RemapTo = [1, 1/3]`).
- Colour entries define `_fullPowerColor*` / `_lowPowerColor*` pairs for both the main wave and outline, plus optional waveform tweaks (e.g. `Invis` slows the wave, `OC_ORANGE` and `OL_ORANGE` feed the overclock/overload FX).

## Colour Module Structure

Each colour file inserts the actual `ArcShield` component and FX for the parent part. Core pieces:

- `ArcShield` references tuner values for radius, location, penetration resistance, and resource drain.
- `ShieldMediaEffects` + `HitMediaEffects` reuse vanilla shaders but re-tint them via the selected colour block.
- `OverclockEffect` and `OverloadEffect` are `ShieldArcsMimic` components chained to the base shield, swapping to the orange OC texture or overload shader when the relevant toggles are active.
- `EmitterEffect` draws the concentric ring above the generator; it respects `ShieldEmitterEffectToggle` so players can disable the visual only.

Because colour components are wrapped in `ToggledComponents`, the gameplay behaviour is identical whichever colour set is active.

## Shield Profiles

### 1×1 Bubble Generator (`shield_1.rules`)

- **Footprint / Cost**: 1×1 tile; 32 steel, 45 coil, 8 coil₂, 8 zersium, 1 processor.
- **Power / HP**: `BatteryStorage.MaxResources = 2000`, yielding 5 000 shield HP at baseline (`2000 / 0.4`). Overclock cuts drain to ~0.133 ⇒ 15 000 HP. No continuous `PowerDrain`, so it consumes power only when hit.
- **Penetration Resist**: 4 (from the `Small` tuner block).
- **Heat & Overclock**: Single-mode overclock; `HEAT_PER_SECOND = 20`, `HEAT_PER_DAMAGE = 0.5`. Heat is generated only while overclocked via `OverclockHeatProducer`/`OverclockHitHeatProducer`.
- **Command & Crew**: `CommandPoints = 2`; recommended crew/power stats scale from the automatically computed `ShieldStatBase`.
- **Thermal Network**: Three ports (`Port_Thermal_Up`, `_Right`, `_Left`) routed off the base template to support sinks in any direction.
- **UX Extras**: Colour toggle (`SW.shield_color_type`), emitter toggle, sound loops, blueprint arcs showing both halves of the bubble.
- **Vanilla comparison**: Closest benchmark is the vanilla small arc shield. That part carries 6 000 capacity, 25 penetration resist, 100 power/sec upkeep, and 90° coverage (135° in extended mode). The bubble trades a third of the HP and much lower penetration for a 360° envelope, zero idle drain, and a footprint six times smaller. Overclock parity is weaker (15 k vs 30 k HP) but vastly cheaper to sustain due to the low heat.

### 2×2 Bubble Generator (`shield_2.rules`)

- **Footprint / Cost**: 2×2; 64 steel, 69 coil, 16 coil₂, 20 zersium, 3 diamond, 3 processor.
- **Power / HP**: `BatteryStorage.MaxResources = 8 000` ⇒ 20 000 HP base, 60 000 HP while overclocked. Continuous drain pulls 200 power/sec.
- **Penetration Resist**: 16.
- **Heat & Overclock**: Same `HEAT_PER_SECOND = 20` / `HEAT_PER_DAMAGE = 0.5` as the small shield, so sustaining overclock on a much larger envelope still only produces the small-shield heat load.
- **Command & Crew**: `CommandPoints = 8`.
- **Thermal Network**: Six ports covering both axes (top-left/right, bottom-left/right) letting you attach multiple thermal sinks.
- **Vanilla comparison**: There is no 2×2 vanilla analogue; the nearest competitor by tech tier and total protection is the vanilla large shield. That part has 18 000 capacity (45 000 HP base, 90 000 OC), 75 penetration resist, 200 power/sec upkeep, and 160° cover. Our medium bubble therefore offers cheaper HP (20 k base) but with perfect wrap-around, triple HP on overclock, and the same idle drain as the vanilla large despite holding more effective coverage. Heat generation remains dramatically lower (20 vs 80).

### 4×4 Bubble Generator (`shield_4.rules`)

- **Footprint / Cost**: 4×4; 256 steel, 130 coil, 64 coil₂, 64 zersium, 8 diamond, 6 processor.
- **Power / HP**: `MaxResources = 32 000` (split into left/right storages) ⇒ 80 000 HP base, 240 000 overclocked. Idle drain 500 power/sec.
- **Penetration Resist**: 64.
- **Heat & Overclock**: Still fixed at 20 heat/sec + 0.5 heat/damage, so thermal load is one quarter of vanilla large shields despite triple HP during overclock and a much larger radius (40).
- **Command & Crew**: `CommandPoints = 24`. The part runs off the combined battery storage so crew can service both sides. Blueprint/FX assets mirror the medium version at a larger scale.
- **Thermal Network**: Ten ports distributed around the perimeter (top/bottom edges plus mid side ports) to hook into radiators or heat pumps at multiple points.
- **Movement Impact**: Optional blocked travel settings live in `shield_4/shield_4_additional.rules` (currently commented out).
- **Vanilla comparison**: Again the closest single vanilla part is the large arc shield. The bubble wins on footprint (16 tiles vs 18), raw HP (80 k vs 45 k base), and overclocked HP (240 k vs 90 k) while paying 2.5× the idle power. Coverage is full 360° and penetration resist is only slightly lower (64 vs 75). Heat production is only 25% of vanilla overclock load, which makes it trivial to sustain unless you deliberately scale it up.

### 8×8 Bubble Generator (`shield_8.rules`)

- **Footprint / Cost**: 8×8; 1 024 steel, 256 coil, 128 coil₂, 92 zersium, 32 diamond, 12 processor.
- **Power / HP**: `MaxResources = 128 000` (left/right combined) ⇒ 320 000 HP base, 960 000 HP on overclock. Idle drain 1 000 power/sec.
- **Penetration Resist**: 256.
- **Heat & Overclock**: Same 20 heat/sec / 0.5 heat per damage. The heat-to-hull ratio is dramatically lower than vanilla scaling (a vanilla large would need 4× the heat to hold equivalent HP).
- **Command & Crew**: `CommandPoints = 96`. Operational FX duplicate the smaller shields but with higher-intensity emitters and dozens of thermal ports along the edges.
- **Thermal Network**: Twenty-one ports encircle the footprint, giving plenty of connection points to thermal networks. Large blocked travel arrays are defined in `shield_8_additional.rules`, preventing routing through the interior.
- **Vanilla comparison**: No vanilla part matches this footprint; the best benchmark is stacking four large arc shields (4 × 45 k = 180 k HP base, 360 k OC) for comparable coverage. The giga bubble doubles that base HP and nearly triples the overclock HP, while generating only a fraction of the heat and using a single part footprint. Power upkeep is higher than four separate shields (1 000 vs 4 × 200) but still easy to sustain relative to the protection provided.

## Overclock & Heat Model

- All bubble shields use a single overclock mode (`BuffType = Overclock`) with `EMP_RESIST = 50%` and `DAMAGE_DRAIN_FACTOR = 1/3`. There is no extended/reinforced split.
- `OverclockHeatProducer` ticks every 0.5 s, feeding `ceil(20 × interval)` heat units into the network. Because `HEAT_PER_SECOND` is constant, the thermal output does **not** scale with shield size or HP.
- `OverclockHitHeatProducer` multiplies `round(0.5 × 1000)` by incoming post-resistance damage and by the overclock buff amount. That means only overclocked bubbles generate heat on impact.
- Scorched behaviour mirrors vanilla: the scorched status disables operation and command consumption until cleared, and scorched FX ride on the base SW scorch helpers.

## Balance Snapshot vs Vanilla

| Shield | Footprint | Battery (HP base) | HP overclock | Pen Resist | Idle drain | Heat/sec (OC) | Vanilla reference | Key differences |
|--------|-----------|-------------------|--------------|------------|------------|---------------|-------------------|-----------------|
| Bubble Small | 1×1 | 2 000 (5 000 HP) | 15 000 | 4 | 0 | 20 | `shield_gen_small` | 360° coverage, zero upkeep, far smaller footprint but much lower penetration and total HP. |
| Bubble Medium | 2×2 | 8 000 (20 000 HP) | 60 000 | 16 | 200 | 20 | `shield_gen_large` | 360° coverage, 44% HP of vanilla large at base, 67% at OC, same upkeep but ¼ heat. |
| Bubble Large | 4×4 | 32 000 (80 000 HP) | 240 000 | 64 | 500 | 20 | `shield_gen_large` | 78% more base HP and 2.7× OC HP vs vanilla large, yet heat load is still ¼. |
| Bubble Giga | 8×8 | 128 000 (320 000 HP) | 960 000 | 256 | 1 000 | 20 | ~4× `shield_gen_large` | Roughly double the base HP of four large shields, 2.7× OC HP, heat budget is drastically lower. |

**Heat scaling gap** – Vanilla shields double heat/sec between small (40) and large (80). Our bubbles keep heat/sec fixed at 20 regardless of footprint or HP, so sustaining overclock on larger domes is trivially easy compared to vanilla.

**Overclock efficiency** – `DAMAGE_DRAIN_FACTOR = 1/3` triples effective HP. Vanilla large shields only double HP under overclock, and vanilla small shields hit 2× in reinforced mode. Combined with the low heat, bubble overclocking is both stronger and cheaper to sustain.

**Penetration** – The 1×1 shield’s penetration resistance (4) is far lower than vanilla’s 25, making it vulnerable to high-pen weapons despite the 360° envelope. Larger bubbles (64/256) sit closer to vanilla large (75) but still deliver higher HP density.

**Idle power** – Aside from the missing drain on the 1×1 shield, upkeep scales faster than vanilla (e.g., 500 for 4×4). Per-tile upkeep actually falls as shields scale up, making the largest dome very cost-effective.

## Recommendations

1. **Scale heat with size** – Match or exceed vanilla totals (e.g., 20 / 40 / 60 / 80 heat per second, or scale off `MaxResources`). Consider increasing `HEAT_PER_DAMAGE` on larger domes (0.5 → 0.6 → 0.75) so sustained fire actually stresses the thermal network.
2. **Revisit `DAMAGE_DRAIN_FACTOR`** – Dropping the multiplier to ½ for large/giga domes (and maybe 0.6 for medium) would keep overclock powerful but closer to vanilla efficiency. Alternatively, tie the multiplier to classification in `ShieldTuner.rules`.
3. **Add idle drain to the 1×1 shield** – A baseline 100 power/sec drain brings it back in line with vanilla upkeep expectations and prevents “free” permanent shields.
4. **Rebalance penetration** – Consider raising the small shield’s penetration resistance (towards ~20) so it does not evaporate instantly, or lower the larger domes slightly to offset their HP advantage.
5. **Expose buff types if needed** – If any downstream systems expect `ReceivableBuffs` to list `Overclock`, add it back in `shield_X.rules` (currently only `ElectronDebuff` is declared).
6. **Document blocked travel settings** – Decide whether to enable the commented travel restrictions in `shield_4_additional.rules` to match the 8×8 behaviour, or remove the helper files if unused.

These tweaks should keep the bubble shields feeling like an upgrade over vanilla while aligning their thermal and balance footprint with current game expectations.

