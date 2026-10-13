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

## Milestone 4: Build Depth (Weapons & Tomes Arsenal) (COMPLETED ✅)
- [x] Add remaining 3 weapons: `RevolverBattery`, `PulseAura`, `RailSniper` (registered, functional execution specialization, and draftable).
- [x] Complete all 8 global Tomes in draft registry (Might, Haste, Wisdom, Greed, Vitality, Scope, Agility, Fortune).
- [x] Implement `StatEngine.recompute()` applying global multipliers to weapons and defense.
- [x] Add Reroll (2), Skip (2), and Banish (1) utility actions to the draft screen with card exclusion.

---

## Milestone 5: Economy, Elites & Boss Encounters (COMPLETED ✅)
- [x] Add Gold coin drops and collection into `RunState.gold`.
- [x] Implement high-density XP shard merging (compressing adjacent low-tier shards if $>150$ on field).
- [x] Add Elite enemy variants ($3\times$ HP, $+30\%$ contact damage, $+25\%$ knockback resistance, golden aura, guaranteed drops).
- [x] Implement Spitter ranged enemy with $110\text{ px}$ kiting behavior and projectile attacks.
- [x] Implement Yokai Goliath Stage Boss at 3-minute marks with health bar UI, Seismic Slam, and minion summon abilities.

---

## Milestone 6: Endless Mode, Audio & Polish (COMPLETED ✅)
- [x] Implement Overtime (Final Swarm) mode at 15:00 with red border vignette, $+100\%$ spawn credit surge, and escalating stat scaling.
- [x] Integrate `flame_audio` via safe `AudioManager` service for combat SFX, level-up stingers, and background music.
- [x] Finalize Results / Game Over screen with persistent High Score via `shared_preferences` and detailed score breakdown.
- [x] Zero-allocation spatial queries and particle caching targeting steady 60 FPS.

---

## Phase 2: Field Interactables & Meta-Progression (FUTURE ROADMAP)
- [ ] Implement Chest drops and tap-to-open gold economy.
- [ ] Build Field Shrines (Charge Shrine, Moai, Greed, Boss Curse, Succ).
- [ ] Implement the Microwave / Alchemical Forge for item duplication.
- [ ] Implement the Warden drone for active spatial player agency.
- [ ] Build permanent Meta-Progression skill tree with Silver currency.
