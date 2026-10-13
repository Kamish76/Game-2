# BONKHOLD: 2D Roguelike Tower Defense

A fast-paced, pixel-art **roguelike tower defense** built with **Flutter + Flame**, inspired by the emergent item scaling and build depth of **Megabonk**.

A magical stationary Bastion stands in the center of the screen as endless enemy swarms converge from all 360° directions. Auto-targeting turrets defend the core while you draft weapons, global stat tomes, and high-rarity synergies to withstand escalating hordes.

---

## 🎮 Features & Philosophy
- **Mobile-First Portrait:** One-thumb casual playstyle rendered on an integer-scaled $180 \times 320$ virtual pixel canvas.
- **Megabonk-Inspired Scaling:** Level-up drafting, 4 weapon slots, 4 tome slots, and Rarity Factors (Common $1.0\times$ to Legendary $2.0\times$) skewed by Luck.
- **High-Density Swarms:** Optimized with custom Spatial Hash grids and zero-allocation object pools to support 400+ concurrent enemies on mobile hardware.
- **Endless Survival Mode:** Progressive difficulty waves leading up to the 15:00 **Overtime** surge.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.47+ (Dart 3.13+)
- Chrome (for web testing) or Android / iOS device / simulator

### Run Locally
```bash
# Run web preview (Chrome)
flutter run -d chrome

# Run on connected mobile device
flutter run

# Run automated tests
flutter test

# Run static analysis
flutter analyze
```

---

## 📚 Documentation Sitemap

Comprehensive documentation is available in the [`docs/`](docs/) directory:

- [**Documentation Index**](docs/00_INDEX.md) — Master table of contents and reading guide
- [**01. Game Design Document (GDD)**](docs/01_GAME_DESIGN_DOCUMENT.md) — Vision, loop, and translation breakdown
- [**02. Technical Architecture**](docs/02_TECH_ARCHITECTURE.md) — Flutter/Flame integration, systems loop, and performance
- **Core Systems:**
  - [3.1 Stats & Formulas](docs/03_systems/3.1_stats_and_formulas.md)
  - [3.2 Combat & Damage Pipeline](docs/03_systems/3.2_combat_and_damage_pipeline.md)
  - [3.3 Progression, Level-Up & Rarity](docs/03_systems/3.3_progression_levelup_rarity.md)
  - [3.4 Weapons](docs/03_systems/3.4_weapons.md)
  - [3.5 Tomes](docs/03_systems/3.5_tomes.md)
  - [3.6 Items & Relics *(Phase 2 - On Hold)*](docs/03_systems/3.6_items.md)
  - [3.7 Enemies & Spawning](docs/03_systems/3.7_enemies_and_spawning.md)
  - [3.8 Economy: XP, Gold & Pickups](docs/03_systems/3.8_economy_xp_gold_chests.md)
  - [3.9 Endless Mode](docs/03_systems/3.9_endless_mode.md)
  - [3.10 Meta-Progression *(Phase 2+ - Stub)*](docs/03_systems/3.10_meta_progression.md)
  - [3.11 Field Interactables & The Warden *(Phase 2 - On Hold)*](docs/03_systems/3.11_phase2_interactables.md)
- [**04. Starter Factor: Kitsune Spire**](docs/04_characters/kitsune_spire.md) — Fox-analog starting character
- [**05. Pixel Art Asset Checklist**](docs/05_ART_PIXEL_ASSET_LIST.md) — Visual specs and sprite tracking
- [**06. Audio Asset Checklist**](docs/06_AUDIO_ASSET_LIST.md) — SFX and music design
- [**07. UI / UX & Screens**](docs/07_UI_UX_AND_SCREENS.md) — HUD wireframes and screen flows
- [**08. Data Schemas**](docs/08_DATA_SCHEMAS.md) — Dart contracts for content definitions
- [**09. Roadmap & Milestones**](docs/09_ROADMAP_AND_MILESTONES.md) — Incremental prototype delivery stages
- [**10. Coding Conventions & Testing**](docs/10_CODING_CONVENTIONS_AND_TESTING.md) — Hot path guidelines and testing rules
- [**11. Master Balance Sheet**](docs/11_BALANCE_SHEET.md) — Baseline tunable values
- [**Architecture Decisions Log (ADR)**](docs/DECISIONS_LOG.md) — Design rationales
- [**Glossary**](docs/GLOSSARY.md) — Core vocabulary

---

## 📈 Roadmap Status
- **Milestone 0: Foundation & Scaffold** — ✅ Complete (Flutter + Flame running, fixed-resolution pixel camera, tests passing, web build verified, docs complete).
- **Milestone 1: Tower & Off-Screen Horde** — ⏳ Next up (Bastion HP/Shield, 360° enemy spawns, contact damage, Game Over).
