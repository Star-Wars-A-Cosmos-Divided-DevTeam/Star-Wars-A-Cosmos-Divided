# Overclock Shot Implementation & Legacy Conversion Guide

This guide explains how to **convert a legacy shot into the modern overclockable format** used in *Star Wars: A Cosmos Divided* and other advanced Cosmoteer mods.  
You will create a clean inheritance chain (`base_shot` → color variants → overclock base → overclock color variants) that allows reusability, visual consistency, and overclock scaling.

The reusable snippet file at  
`memory-bank/docs/oc_overclock_shot_template.rules`  
contains example blocks for behaviors (e.g., EMP, status effects, drain, media overrides) — but it should be used **only as a reference**, *not as a template to copy wholesale*.

---

## When to Use
- You are **upgrading a legacy shot** (e.g., an old single `.rules` projectile) into the new modular format.
- You want to **add overclock functionality** with inherited behavior and clean color separation.
- You want to keep visuals consistent while scaling damage, impulse, and health for OC variants.

---

## Recommended Workflow

### 1. Copy the Existing Light Turbolaser Folder
Use `shots/laser/turret/turbo/heavy/` as your **base template** — this includes a complete inheritance-ready structure:
- `base_shot.rules` → shared projectile stats  
- `red_shot.rules`, `blue_shot.rules`, `green_shot.rules` → color-specific visuals  
- `overclock/` → contains `oc_base_shot.rules` and the OC color variants  

> 💡 *Do not copy `memory-bank/docs/oc_overclock_shot_template.rules` directly.*  
> Use it **only** to borrow snippets for special features (EMP, status, resource drain, etc.).

---

### 2. Create the Target Folder
Copy the contents of `heavy` folder from `shots/laser/turret/turbo/` (and its `overclock/` subfolder) into your new path, for example:

```

shots/laser/turret/turbo/CIS/

````

Then rename file names and internal `ID` strings accordingly.

---

### 3. Update IDs & Backward Compatibility
Inside each `.rules` file:

// Old (legacy)
ID = "SW.red_cis_laser_shot_common"

// New (modern)
ID = "SW.oc_red_cis_laser_shot_common"
OtherIDs = ["SW.red_cis_laser_shot_common_oc"] // for backwards compatibility
````

* Use the new naming convention `SW.turbolaser_turret_<size>_laser_<color>_shot[_overclock]`.
* Always add old IDs to `OtherIDs` if migrating legacy assets.

---

### 4. Set Up Inheritance References

Inside each overclock file (`oc_red_shot.rules`, etc.):

| Variable     | Purpose            | Typical Reference                    |
| ------------ | ------------------ | ------------------------------------ |
| `BASE`       | Core stats/physics | `&<../base_shot.rules>`              |
| `OC_BASE`    | Shared OC behavior | `&<../overclock/oc_base_shot.rules>` |
| `COLOR_BASE` | Visual variant     | `&<../red_shot.rules>`               |

Each OC color file inherits stats from `OC_BASE`, and reuses media/visuals from its `COLOR_BASE`.

---

### 5. Rebuild Legacy Shots into the New Format

If you’re starting from a single legacy `.rules` file (like the original *blue laser* example):

1. **Extract the universal data** (Range, Speed, BaseValue, Buffs, Sprite setup) → put this in `base_shot.rules`.
2. **Move color-specific MediaEffects and texture references** into each color file (e.g., `blue_shot.rules`).
3. **Create an `overclock/` folder** with:

   * `oc_base_shot.rules` → shared OC logic (AoE + scaling)
   * `oc_color_shot.rules` files → reapply visuals from the color variants

---

### 6. Understand the OC Behavior Model

The overclocked base (`oc_base_shot.rules`) switches from a **direct Damage hit model** to an **AoE AreaDamage** model for operational hits.

**Key changes vs. legacy:**

* Uses `Type = AreaDamage` with `Radius = DAMAGE_RADIUS`.
* Adds a shield-only mirror block (`: 0 { ... }`).
* Structural damage is automatically halved (`floor(DAMAGE / 2)`).
* `PenetratingOperational` removes direct damage and applies only impulse (to avoid double-hits).
* `ReduceEffectsByPenetration` is set to `false`.

> ⚠️ If you reorder the `HitEffects` list in the base shot, **update the index references** in the OC file (`: 0`, `../^/0/HitEffects/1`, etc.) so they align correctly.

---

### 7. Tune Scalars and Scaling Logic

In `oc_base_shot.rules`, tweak only the constants:


DAMAGE        = 175% * (&BASE/Components/Hit/HitOperational/HitEffects/0/Damage/BaseValue)
DAMAGE_SHIELD = 150% * (&BASE/Components/Hit/HitOperational/HitEffects/0/Damage/BaseValue)
IMPULSE       = 200% * (&BASE/Components/Hit/HitOperational/HitEffects/1/Impulse/BaseValue)
HEALTH        = 175% * (&BASE/Components/Targetable/Health)
DAMAGE_RADIUS = 3

> 💡 Adjust ratios if your base shot used a different operational–structural ratio.

---

### 8. Reapply Color-Specific Media in OC Color Files

In each `oc_<color>_shot.rules`, reapply the color’s hit/flash/sparks effects:

HitOperational : ^/0/HitOperational
{
  MediaEffects
  [
    &<particles/laser_bolt_large_overclock_hit_blue.rules>
    &<particles/laser_bolt_large_overclock_flash.rules>
    &<particles/laser_bolt_large_overclock_sparks.rules>
  ]
}

* Keep color visuals isolated — only override what’s necessary.
* Most OC visual changes belong in these files, not in `oc_base_shot.rules`.

---

### 9. Validate Buffs and Assets

* Confirm `ReceivableBuffs = [ElectronBuff]` points to an actual buff in your mod.
  If not, replace or remove it.
* Ensure all referenced files exist:

  * `particles/*.rules`
  * `sounds/*.wav`
* Verify texture and shader paths (especially in Sprite and GlowSprite blocks).

---

### 10. Verify Inherited Visuals

Each OC color shot should copy textures and glow data from its color parent:

Sprite : ^/0/Sprite
{
  Animation : ^/0/Animation
  {
    AtlasSprite : ^/0/AtlasSprite
    {
      Texture : ^/0/Texture
      {
        File = &~/BLUE/Components/Sprite/Animation/AtlasSprite/Texture/File
      }
    }
  }
}

Keep `ReduceScaleWith = Hit` active unless you adjust `FactorEffectsWith` on `MediaEffects`.

---

### 11. Hook the New Shots to Weapon Parts

Update your part files (e.g., `cis_turbolaser_switchable.rules`) to point to your new overclocked IDs under `OverclockedShot` or equivalent fields.

---

## Folder Layout (Reference)

```
shots/
└── laser/
    └── turret/
        └── turbo/
            └── CIS/
                ├── base_shot.rules
                ├── blue_shot.rules
                ├── red_shot.rules
                ├── green_shot.rules
                └── overclock/
                    ├── oc_base_shot.rules
                    ├── oc_blue_shot.rules
                    ├── oc_red_shot.rules
                    └── oc_green_shot.rules
```

---

## Testing & Validation Checklist

✅ Load the weapon in-game and inspect the projectile:

* `Health`, `Damage`, `Impulse`, and `Radius` reflect the OC multipliers.
* Shield vs hull impacts trigger the correct visuals.
* Penetration works as intended (AoE damage applies only once).
* No missing particle/sound path errors in the console.
* Structural impacts deal reduced damage (~50% of operational).

---

## Related References

* Snippet reference: `memory-bank/docs/oc_overclock_shot_template.rules`
* Example baseline: `shots/laser/turret/turbo/heavy/`
* Vanilla comparison: `./Data/shots/laser_bolt_large_overclock.rules`

---

```

---
