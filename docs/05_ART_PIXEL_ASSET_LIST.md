# 05: Pixel Art Asset Specification & Checklist

## Purpose
Establishes the pixel-art visual constraints, color palette, sprite dimensions, animation frames, and a master tracking checklist for all game art.

---

## 1. Technical Art Constraints
- **Virtual Viewport:** $180 \times 320$ pixels (Portrait).
- **Sampling Quality:** Hard nearest-neighbor (`FilterQuality.none`) with pixel snapping on non-interpolated positions.
- **Color Palette:** **Resurrect 64** or **Endesga 32** (high contrast, warm highlights, dark purples/blues for arena floors).
- **Outlines:** Dark 1-pixel selective outline (`#1a1c2c`) on interactive entities to separate foreground elements from the arena floor.
- **Export Standards:** Sprite sheets packed horizontally with 1px padding, named with standard convention:
  `{category}_{name}_{state}_{frame_count}f.png` (e.g. `enemy_swarmling_walk_4f.png`).

---

## 2. Placeholder Strategy for Prototype
Until dedicated sprites are delivered, all components render programmatically using `dart:ui` `Canvas` primitives with designated `Palette` colors:
- Bastion: Layered gold & crimson squares with core dot.
- Enemies: Colored diamond/square shapes with red eyes.
- Projectiles: Circular glowing shapes with motion tails.
- Pickups: Rotated diamond shards with solid borders.

---

## 3. Master Asset Checklist

### 3.1 Entities & Characters
| Asset ID | Description | Size | Frames | Priority | Status |
|---|---|---|---|---|---|
| `tower_kitsune_base` | Kitsune Spire stone base & torii shrine | 32×32 | 1 (static) | P0 | Placeholder |
| `tower_kitsune_flames` | Orbiting fox-fire lanterns | 8×8 | 4 (loop) | P1 | Planned |
| `enemy_swarmling_walk` | Small skittering imp/critter | 16×16 | 4 (walk) | P0 | Placeholder |
| `enemy_runner_walk` | Agile four-legged shadow fox | 16×16 | 4 (run) | P0 | Placeholder |
| `enemy_brute_walk` | Armored stone oni with club | 24×24 | 4 (walk) | P0 | Placeholder |
| `enemy_spitter_walk` | Cyclops blob / ranged yokai | 20×20 | 4 (walk) | P0 | Placeholder |
| `boss_goliath_walk` | Yokai Goliath colossal demon | 48×48 | 6 (walk) | P1 | Placeholder |
| `boss_goliath_attack` | Goliath shockwave slam animation | 48×48 | 4 (slam) | P1 | Planned |

### 3.2 Weapons & Projectiles
| Asset ID | Description | Size | Frames | Priority | Status |
|---|---|---|---|---|---|
| `proj_ember_fireball` | Swirling flame projectile | 8×8 | 4 (loop) | P0 | Placeholder |
| `vfx_ember_explosion` | Detonation blast for Ember Staff | 28×28 | 5 (burst) | P0 | Placeholder |
| `proj_revolver_bullet` | High-speed kinetic tracer | 6×3 | 1 (static) | P0 | Placeholder |
| `vfx_pulse_aura` | Expanding radial ripple ring | 64×64 | 4 (expand) | P0 | Placeholder |
| `proj_rail_beam` | Piercing particle laser beam | 16×4 | 2 (pulse) | P0 | Placeholder |

### 3.3 Pickups & VFX
| Asset ID | Description | Size | Frames | Priority | Status |
|---|---|---|---|---|---|
| `pickup_xp_green` | Lesser XP shard (1 XP) | 4×4 | 1 | P0 | Placeholder |
| `pickup_xp_blue` | Medium XP gem (5 XP) | 6×6 | 1 | P0 | Placeholder |
| `pickup_xp_gold` | Greater XP gem (25 XP) | 8×8 | 2 (sparkle) | P0 | Placeholder |
| `pickup_xp_red` | Mega XP crystal (100 XP) | 10×10 | 2 (sparkle) | P1 | Placeholder |
| `pickup_gold_coin` | Spinning bronze/gold coin | 6×6 | 4 (spin) | P0 | Placeholder |
| `vfx_hit_flash` | White damage flash overlay | Variable | 1 (single frame) | P0 | Code Shader |

### 3.4 UI & Card Assets
| Asset ID | Description | Size | Frames | Priority | Status |
|---|---|---|---|---|---|
| `ui_card_frame_common` | Card border - Common (Gray) | 48×64 | 1 | P0 | Flutter Widget |
| `ui_card_frame_uncommon`| Card border - Uncommon (Green) | 48×64 | 1 | P0 | Flutter Widget |
| `ui_card_frame_rare` | Card border - Rare (Blue) | 48×64 | 1 | P0 | Flutter Widget |
| `ui_card_frame_epic` | Card border - Epic (Purple) | 48×64 | 1 | P0 | Flutter Widget |
| `ui_card_frame_legendary`| Card border - Legendary (Gold) | 48×64 | 1 | P0 | Flutter Widget |
| `icon_weapon_ember` | Ember Staff card icon | 16×16 | 1 | P0 | Placeholder |
| `icon_weapon_revolver` | Revolver Battery card icon | 16×16 | 1 | P0 | Placeholder |
| `icon_weapon_aura` | Pulse Aura card icon | 16×16 | 1 | P0 | Placeholder |
| `icon_weapon_rail` | Rail Sniper card icon | 16×16 | 1 | P0 | Placeholder |
| `icon_tome_generic` | Tomes 1-8 card icons | 16×16 | 8 individual | P0 | Placeholder |
