# BONKHOLD Workspace Rules

## 1. Git Branching Strategy
- **Active Branch (`dev`):** All feature development, bug fixes, refactoring, tests, and milestone commits MUST occur on the `dev` branch.
- **Release Branch (`main`):** The `main` branch is strictly reserved for milestone releases. Never commit directly to `main` unless performing an authorized milestone release merge.

## 2. Core Game Architecture Invariants
- **Platform & Orientation:** Flutter + Flame 2D pixel-art roguelike tower defense locked to portrait orientation ($180 \times 320$ virtual canvas).
- **Automated Combat (v1):** Turrets auto-target threats heading for the Bastion. No manual character traversal or aiming in the core combat loop.
- **Gravitational Auto-Vacuum:** Defeated enemies drop XP and Gold that are pulled automatically toward the Bastion at `(0, 0)`.
- **Phase 2 Scope Deferral:** Field interactables (Chests, Shrines, Microwave, mobile Warden drone, and meta-progression) are intentionally deferred to Phase 2. Focus on validating core combat, wave escalation, and level-up drafting first.

## 3. Performance & Hot-Path Hygiene
- **Zero Allocations on Hot Paths:** No `new Vector2()`, closures, or list instantiations inside `update()` or `render()`.
- **Custom Spatial Grid:** Use `SpatialHash` and object pools for swarm entities; do not use Flame's built-in collision detection for 300+ enemy swarms.

## 4. Environment Execution
- On this macOS workstation, running `flutter` CLI commands requires `BypassSandbox: true` to execute without sandbox permission errors.
