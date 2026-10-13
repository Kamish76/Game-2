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

## Milestone 1: Tower Resilience & Off-Screen Horde (COMPLETED ✅)
- [x] Implement `Bastion` structural HP, Shield, and Armor data models.
- [x] Create `EnemyComponent` with directional vector movement toward $(0, 0)$.
- [x] Implement `SpawnDirector` with 360° off-screen perimeter circle ($R=200\text{ px}$).
- [x] Enemies detect contact with Bastion radius and inflict damage on attack interval.
- [x] Basic HUD displaying Bastion HP bar and run survival timer.
- [x] Trigger `GameOver` overlay when Bastion HP reaches 0.

---

## Milestone 2: Automated Combat & Spatial Acceleration (COMPLETED ✅)
- [x] Implement `SpatialHash` uniform grid for fast circle-circle queries.
- [x] Build `EmberStaff` component: auto-targeting enemy closest to $(0, 0)$.
- [x] Implement `ProjectileComponent` with collision and blast detection.
- [x] Add AoE detonation logic damaging all enemies within blast radius.
- [x] Enemy death handling: flashing, HP depletion, return to pool / world disposal.
- [x] Floating damage numbers overlay with critical strike highlights.

---

## Milestone 3: XP Vacuum & Level-Up Drafting (COMPLETED ✅)
- [x] Implement `PickupComponent` for XP shards.
- [x] Build gravitational acceleration vacuum pulling shards within Attraction radius.
- [x] Shard absorption into `RunState.xp` and level threshold evaluation.
- [x] Build `LevelUp` Flutter overlay: pauses game, displays 3 cards with rolled Rarity.
- [x] Apply Kitsune Spire passive: $+1.5\%$ Luck per level-up.
- [x] Unit test `DraftSystem` rarity distribution and slot boundaries.

---

## Milestone 4: Build Depth (Weapons & Tomes Arsenal) (IN PROGRESS ⏳)
- [x] Add remaining 3 weapons: `RevolverBattery`, `PulseAura`, `RailSniper` (registered & draftable).
- [ ] Complete all 8 global Tomes in draft registry (6 currently active, 2 pending).
- [x] Implement `StatEngine.recompute()` applying global multipliers to weapons and defense.
- [ ] Add Reroll, Skip, and Banish buttons to the draft screen.

---

## Milestone 5: Economy, Elites & Boss Encounters
- [x] Add Gold coin drops and collection into `RunState.gold`.
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
