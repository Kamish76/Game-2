# 09: Roadmap & Incremental Milestones

## Overview
Every milestone delivers a fully functional, testable build increment. Work progresses sequentially to ensure foundational systems are verified before building higher-order mechanics.

---

## Milestone 0: Architecture & Foundation (COMPLETED ✅)
- [x] Initialize Flutter + Flame cross-platform scaffold (`android, ios, web`).
- [x] Configure portrait orientation lock and virtual pixel canvas ($180 \times 320$).
- [x] Establish lint rules (`prefer_single_quotes`, `avoid_print`, `prefer_const_constructors`).
- [x] Implement fixed-resolution `CameraComponent` and placeholder `Bastion` component.
- [x] Set up FPS debug overlay.
- [x] Verify automated test suite and web build compilation.
- [x] Write comprehensive architectural and systems documentation.

---

## Milestone 1: Tower Resilience & Off-Screen Horde
- [ ] Implement `Bastion` structural HP, Shield, and Armor data models.
- [ ] Create `EnemyComponent` with directional vector movement toward $(0, 0)$.
- [ ] Implement `SpawnDirector` with 360° off-screen perimeter circle ($R=200\text{ px}$).
- [ ] Enemies detect contact with Bastion radius and inflict damage on attack interval.
- [ ] Basic HUD displaying Bastion HP bar and run survival timer.
- [ ] Trigger `GameOver` overlay when Bastion HP reaches 0.

---

## Milestone 2: Automated Combat & Spatial Acceleration
- [ ] Implement `SpatialHash` uniform grid for fast circle-circle queries.
- [ ] Build `EmberStaff` component: auto-targeting enemy closest to $(0, 0)$.
- [ ] Implement `ProjectileComponent` with object pooling.
- [ ] Add AoE detonation logic damaging all enemies within blast radius.
- [ ] Enemy death handling: flashing, HP depletion, return to pool.
- [ ] Floating damage numbers overlay with pooling.

---

## Milestone 3: XP Vacuum & Level-Up Drafting
- [ ] Implement `PickupComponent` for XP shards.
- [ ] Build gravitational acceleration vacuum pulling shards within Attraction radius.
- [ ] Shard absorption into `RunState.xp` and level threshold evaluation.
- [ ] Build `LevelUp` Flutter overlay: pauses game, displays 3 cards with rolled Rarity.
- [ ] Apply Kitsune Spire passive: $+1.5\%$ Luck per level-up.
- [ ] Unit test `DraftSystem` rarity distribution and slot boundaries.

---

## Milestone 4: Build Depth (Weapons & Tomes Arsenal)
- [ ] Add remaining 3 weapons: `RevolverBattery`, `PulseAura`, `RailSniper`.
- [ ] Add 8 global Tomes to draft registry with 4-slot limit.
- [ ] Implement `StatEngine.recompute()` applying global multipliers to weapons and defense.
- [ ] Add Reroll, Skip, and Banish buttons to the draft screen.

---

## Milestone 5: Economy, Elites & Boss Encounters
- [ ] Add Gold coin drops and collection into `RunState.gold`.
- [ ] Implement high-density XP shard merging (compressing low-tier shards if $>150$ on field).
- [ ] Add Elite enemy variants ($+200\%$ HP, enlarged scale, aura tint).
- [ ] Implement Yokai Goliath Stage Boss at 3-minute marks with health bar UI.

---

## Milestone 6: Endless Mode, Audio & Polish
- [ ] Implement Overtime (Final Swarm) mode at 15:00 with red screen tint and spawn surge.
- [ ] Integrate `flame_audio` for combat SFX, level-up stingers, and background music.
- [ ] Finalize Results / Game Over screen with high score persistence.
- [ ] Perform frame profiling on physical Android/iOS devices targeting steady 60 FPS.

---

## Phase 2: Field Interactables & Meta-Progression (FUTURE ROADMAP)
- [ ] Implement Chest drops and tap-to-open gold economy.
- [ ] Build Field Shrines (Charge Shrine, Moai, Greed, Boss Curse, Succ).
- [ ] Implement the Microwave / Alchemical Forge for item duplication.
- [ ] Implement the Warden drone for active spatial player agency.
- [ ] Build permanent Meta-Progression skill tree with Silver currency.
