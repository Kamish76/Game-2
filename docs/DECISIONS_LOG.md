# Architecture Decisions Log (ADR)

## ADR 001: Flutter + Flame Game Framework
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Need rapid cross-platform development targeting mobile devices with frictionless browser testing.
- **Decision:** Use Flutter with Flame (1.38.x). Game loop handled by Flame; all UI, HUD overlays, card drafting, and menus handled by Flutter widgets.
- **Consequences:** Superb developer velocity and UI tooling; requires care around game loop allocations on mobile hot paths.

---

## ADR 002: Portrait Orientation Lock
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Mobile roguelike experience requires comfortable one-thumb casual ergonomics.
- **Decision:** Lock device orientation to Portrait (`DeviceOrientation.portraitUp`). On web, letterbox within canvas.
- **Consequences:** Top and bottom enemy approach paths are longer than lateral paths; spawner uses radial spawn distance ($R=200\text{ px}$) to normalize perimeter pressure.

---

## ADR 003: Fixed Virtual Resolution Canvas ($180 \times 320$)
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Authentic pixel-art aesthetic without sub-pixel jitter or uneven distortion.
- **Decision:** Render world inside Flame's `CameraComponent.withFixedResolution(width: 180, height: 320)` with `FilterQuality.none`.
- **Consequences:** Simplifies coordinate calculations; ensures uniform asset scale across any device resolution.

---

## ADR 004: Decoupled Pure Dart Systems
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Complex roguelike stat interactions and RNG draft systems require rapid testing without rendering overhead.
- **Decision:** Core game rules (`StatEngine`, `DamageResolver`, `DraftSystem`, `SpawnDirector`) are pure Dart classes without Flame dependencies.
- **Consequences:** High testability and instant execution of test suites in CLI.

---

## ADR 005: Custom Spatial Hash Grid for Swarm Queries
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Flame's `HasCollisionDetection` performs pairwise checks that degrade under 300+ live entities.
- **Decision:** Build a lightweight uniform 2D grid (`SpatialHash`, 32px cell size) updated each tick.
- **Consequences:** O(1) proximity lookups for auto-targeting, AoE blasts, and vacuum attraction.

---

## ADR 006: Temporary Deferral of Field Interactables
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** In Megabonk, interactables (chests, shrines, microwave) rely on player movement. v1 focuses on stationary automated defense.
- **Decision:** Defer Chests, Shrines, Microwave, and the mobile Warden drone to Phase 2. Prototype relies on automated level-up card drafting.
- **Consequences:** Allows instant validation of combat, wave scaling, and upgrade math without UX clutter.

---

## ADR 007: Gravitational Auto-Vacuum for Loot Pickups (Amended)
- **Date:** 2026-10-13
- **Status:** Accepted (Amended to Global Vacuum)
- **Context:** Because the Bastion is stationary at `(0, 0)` and cannot move, limiting pickup collection to a local Attraction radius ($48\text{ px}$) caused drops from enemies killed at long range ($80\text{--}200\text{ px}$) to be permanently stranded and uncollectible.
- **Decision:** All standard dropables (XP shards and Gold coins) default to global auto-vacuum (`autoCollect = true`) from any distance across the arena, accelerating smoothly toward `(0, 0)` at $350\text{ px/s}^2$ and absorbing at the Bastion hull ($16\text{ px}$). The base `attraction` stat is retained as a fallback query distance for future non-autocollect interactables.
- **Consequences:** Eliminates stranded resources while maintaining satisfying visual vacuum streams and preserving zero-allocation hot paths.

---

## ADR 008: Hyperbolic Defense Formula Normalization
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Megabonk uses an internal $A / (0.75 + A)$ curve where armor is represented as small decimal values.
- **Decision:** Scale armor and deflect into integer points: $\text{Reduction} = \frac{\text{Points}}{\text{Points} + 100}$.
- **Consequences:** Intuitive readability for players (e.g. 100 Armor = 50% reduction, 300 Armor = 75% reduction) with identical mathematical diminishing returns.

---

## ADR 009: IP-Safe Content Nomenclature
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Avoid copyright conflicts with Megabonk while preserving identical mathematical depth.
- **Decision:** Adopt Japanese folklore / mystical tower aesthetics: Fox $\rightarrow$ Kitsune Spire, Firestaff $\rightarrow$ Ember Staff, etc.
- **Consequences:** Unique game brand identity ready for future store releases.

---

## ADR 010: Gentle Exponential Difficulty Scaling & Baseline Damage Calibration
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** The initial quadratic spawn credit budget ($(4 + 0.35t + 0.005t^2) \times (1 + \text{Curse})$) ramped too aggressively in early run phases, spawning up to 4 enemies/s at $t=0$ and overwhelming players before initial level-ups could be acquired. Baseline weapon damage was also insufficient to one-shot basic Swarmlings ($18\text{ HP}$).
- **Decision:**
  1. Replace quadratic scaling with a gentle exponential curve: $\text{CreditsPerSec}(t) = 0.8 \times e^{0.008t} \times (1 + \text{Curse})$.
  2. Pace enemy archetype unlocks: Swarmlings ($0\text{s}$), Runners ($30\text{s}$), Brutes ($60\text{s}$), Spitters ($90\text{s}$).
  3. Increase all baseline weapon damages by +25% rounded up: Ember Staff ($14 \to 18$), Revolver Battery ($6 \to 8$), Pulse Aura ($8 \to 10$), Rail Sniper ($32 \to 40$).
  4. Halve Boss HP wave increment ($+350 \to +175$) and Overtime stat growth ($+5\%\text{ HP}$, $+2.5\%\text{ Speed}$ per 30s).
- **Consequences:** Smooth early-game onboarding allowing players to one-shot early fodder, draft synergies, and experience an exponential but sustainable horde escalation.

---

## ADR 011: Bounded Overlay Architecture & Responsive HUD Anchoring
- **Date:** 2026-10-13
- **Status:** Accepted
- **Context:** Flame's `GameWidget` supplies loose constraints (`0.0 <= w <= screenWidth, 0.0 <= h <= screenHeight`) to Flutter overlay builders. A `Stack(fit: StackFit.loose)` containing only `Positioned` children evaluates to `Size(0.0, 0.0)`, causing `Positioned(left: 8, right: 8)` children to collapse to 0 width and rendering the XP bar, level indicator, Bastion HP bar, and Boss health bar completely invisible. Additionally, widescreen web displays stretched HUD elements across the monitor away from the centered portrait game arena.
- **Decision:**
  - Enforce bounded overlay layout: `SizedBox.expand -> SafeArea -> Align(center) -> ConstrainedBox(maxWidth: 480) -> Stack(fit: StackFit.expand)`.
  - Wrap Overtime vignette in `Positioned.fill` so it does not alter stack sizing.
  - Implement structured 4-slot Weapon (`W1`-`W4`) and 4-slot Tome (`T1`-`T4`) trays using `Expanded` flex blocks with placeholder chips (`--`), eliminating `RenderFlex` overflows.
  - Add reactive `RunState.loadoutVersion` notifier to update equipment trays immediately upon drafting new weapons or tomes.
  - Display active Shield integrity (`[SHIELD: X]`) with a cyan border and glow (`#38BDF8`) when `shield > 0`.
  - Relocate debug FPS counter to `Alignment.topRight` with an offset (`top: 46`) to prevent overlapping top-left Pause and Timer controls.
- **Consequences:** Zero layout overflows, guaranteed non-zero render dimensions on all screen sizes, perfect mobile portrait ergonomics, and cohesive desktop/web centering aligned with the $180 \times 320$ virtual canvas.
