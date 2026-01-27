# SWACD Bubble Shields Reference

Applies to `shield_1`, `shield_2`, `shield_4`, `shield_8`.

Architecture overview:
- Base stack: `base_part_terran_sw.rules` -> `base_part_terran_sw_operational.rules` -> `base_part_terran_sw_scorched.rules` -> `base_part_terran_sw_overclock.rules` -> `base_part_terran_shields.rules`.
- Shield profiles define stats, thermal routing, FX toggles, and stats blocks.
- Color modules live under `shield_X/` and are toggled by `SW.shield_color_type`.
- `ShieldTuner.rules` centralizes geometry, penetration, shaders, and shared color palettes.

ShieldTuner highlights:
- Classification blocks define radius, penetration resistance, wave speed, and size vector.
- `All` sets base arc geometry and resource drain rules.
- Color entries define full/low power colors and OC/overload palettes.

Color module structure:
- `ArcShield` uses tuner values for radius, location, and penetration.
- `ShieldMediaEffects` and `HitMediaEffects` use vanilla shaders with recolor.
- `OverclockEffect` and `OverloadEffect` mimic base shield with OC textures.
- `EmitterEffect` is gated by `ShieldEmitterEffectToggle`.

Footprint summaries (current):
- 1x1: 2000 battery (5000 HP), 0 idle drain, heat 20/sec, heat 0.5/dmg, pen 4.
- 2x2: 8000 battery (20000 HP), 200 idle drain, heat 20/sec, pen 16.
- 4x4: 32000 battery (80000 HP), 500 idle drain, heat 20/sec, pen 64.
- 8x8: 128000 battery (320000 HP), 1000 idle drain, heat 20/sec, pen 256.

Overclock and heat model:
- Single overclock mode (`Overclock` buff), no extended/reinforced split.
- Heat per second does not scale with size.
- Heat per damage only applies while overclocked.

Balance notes (current gaps vs vanilla):
- Heat scaling is low for large domes (fixed 20/sec across sizes).
- Overclock efficiency is strong (DAMAGE_DRAIN_FACTOR = 1/3).
- Small shield penetration is very low compared to vanilla small shield.

Recommendations:
1. Scale heat with size (or by MaxResources).
2. Consider lowering overclock efficiency on larger domes.
3. Add idle drain to 1x1 shield if parity is desired.
4. Rebalance penetration to avoid extreme small shield weakness.
5. Ensure `ReceivableBuffs` includes `Overclock` where needed.
