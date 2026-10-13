# BONKHOLD: Documentation Index

> Working title. 2D pixel-art roguelike tower defense for **mobile (portrait)**, tested mainly on **Web**.
> Built with **Flutter + Flame**. Mechanics are inspired by Megabonk and adapted to a single stationary tower.

## Reading order (new to the project?)
1. [01_GAME_DESIGN_DOCUMENT.md](01_GAME_DESIGN_DOCUMENT.md): what the game is
2. [04_characters/kitsune_spire.md](04_characters/kitsune_spire.md): the starter tower
3. [09_ROADMAP_AND_MILESTONES.md](09_ROADMAP_AND_MILESTONES.md): what to build next
4. [02_TECH_ARCHITECTURE.md](02_TECH_ARCHITECTURE.md): how the code is organized

## All documents

| # | Document | Purpose | Status |
|---|---|---|---|
| 01 | [Game Design Document](01_GAME_DESIGN_DOCUMENT.md) | Vision, pillars, core loop, scope | Implemented (Prototype) |
| 02 | [Tech Architecture](02_TECH_ARCHITECTURE.md) | Flutter/Flame structure, rendering, performance | Implemented |
| 3.1 | [Stats & Formulas](03_systems/3.1_stats_and_formulas.md) | Every stat and how it stacks | Implemented |
| 3.2 | [Combat & Damage Pipeline](03_systems/3.2_combat_and_damage_pipeline.md) | Hit resolution, crits, defense layers | Implemented |
| 3.3 | [Progression, Level-Up & Rarity](03_systems/3.3_progression_levelup_rarity.md) | XP curve, card draft, rarity rolls | Implemented |
| 3.4 | [Weapons](03_systems/3.4_weapons.md) | Weapon rules, targeting, roster | Implemented |
| 3.5 | [Tomes](03_systems/3.5_tomes.md) | Global stat books | Implemented |
| 3.6 | [Items](03_systems/3.6_items.md) | Passive items and procs (**Phase 2**) | On hold |
| 3.7 | [Enemies & Spawning](03_systems/3.7_enemies_and_spawning.md) | Enemy roster, spawn director | Implemented (Core Roster) |
| 3.8 | [Economy: XP, Gold, Chests](03_systems/3.8_economy_xp_gold_chests.md) | Pickups, vacuum, gold. Chests are **Phase 2** | Implemented (Vacuum & Drops) |
| 3.9 | [Endless Mode](03_systems/3.9_endless_mode.md) | Difficulty curve, bosses, score | In progress |
| 3.10 | [Meta Progression](03_systems/3.10_meta_progression.md) | Silver, unlocks (**Phase 2+**) | Stub |
| 3.11 | [Phase 2 Interactables](03_systems/3.11_phase2_interactables.md) | Chests, shrines, Microwave, Warden | On hold |
| 04 | [Kitsune Spire](04_characters/kitsune_spire.md) | Starter character (Fox-style) | Implemented |
| 05 | [Pixel Art Asset List](05_ART_PIXEL_ASSET_LIST.md) | Art spec + master checklist | Draft (Geometric Fallbacks Active) |
| 06 | [Audio Asset List](06_AUDIO_ASSET_LIST.md) | SFX/music checklist | Draft (Phase 6) |
| 07 | [UI/UX & Screens](07_UI_UX_AND_SCREENS.md) | Screen flow, HUD, level-up cards | Implemented |
| 08 | [Data Schemas](08_DATA_SCHEMAS.md) | Dart definitions for content | Implemented |
| 09 | [Roadmap & Milestones](09_ROADMAP_AND_MILESTONES.md) | Incremental build plan with checklists | Living (M0-M3 Complete) |
| 10 | [Coding Conventions & Testing](10_CODING_CONVENTIONS_AND_TESTING.md) | Style, tests, git | Implemented |
| 11 | [Balance Sheet](11_BALANCE_SHEET.md) | Starting numbers (tunable) | Implemented |
| — | [Decisions Log](DECISIONS_LOG.md) | Why we chose what we chose | Living |
| — | [Glossary](GLOSSARY.md) | Shared vocabulary | Living |

## Status legend
- **Draft**: written, may change while implementing
- **Locked**: agreed, change only with a Decisions Log entry
- **Implemented**: matches the code
- **On hold / Stub**: documented for a later phase, do not implement yet
