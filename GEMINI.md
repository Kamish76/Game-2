# BONKHOLD Workspace Rules

## 1. Git Branching Strategy
- **Active Branch (`dev`):** All feature development, bug fixes, refactoring, tests, and milestone commits MUST occur on the `dev` branch.
- **Release Branch (`main`):** The `main` branch is strictly reserved for milestone releases. Never commit directly to `main` unless performing an authorized milestone release merge.

## 2. Core Game Architecture Invariants
- **Platform & Orientation:** Flutter + Flame 2D pixel-art roguelike tower defense locked to portrait orientation ($180 \times 320$ virtual canvas).
- **Automated Combat (v1):** Turrets auto-target threats heading for the Bastion. No manual character traversal or aiming in the core combat loop.
- **Gravitational Auto-Vacuum (Global Range):** Defeated enemies drop XP and Gold that are pulled automatically toward the Bastion at `(0, 0)` from any range across the map (`autoCollect = true` by default). Because the Bastion is stationary, pickup collection must never be restricted to a local proximity radius.
- **Phase 2 Scope Deferral:** Field interactables (Chests, Shrines, Microwave, mobile Warden drone, and meta-progression) are intentionally deferred to Phase 2. Focus on validating core combat, wave escalation, and level-up drafting first.

## 3. Performance & Hot-Path Hygiene
- **Zero Allocations on Hot Paths:** No `new Vector2()`, closures, or list instantiations inside `update()` or `render()`.
- **Custom Spatial Grid:** Use `SpatialHash` and object pools for swarm entities; do not use Flame's built-in collision detection for 300+ enemy swarms.

## 4. Environment Execution
- On this macOS workstation, running `flutter` CLI commands requires `BypassSandbox: true` to execute without sandbox permission errors.

## 5. Flame Testing & Simulation Ticking Hygiene
- **Mandatory `testWithGame` Test Harness:** Any Flame test asserting on component behavior, spatial indexing, weapon auto-firing, or enemy AI MUST use `testWithGame<BonkholdGame>('...', BonkholdGame.new, (game) async { ... });` from `package:flame_test/flame_test.dart`. Never instantiate raw `game = BonkholdGame(); await game.onLoad();` in unit tests, as `game.isMounted` and child `isMounted` flags will remain `false`.
- **Flutter UI Overlay Testing:** When testing Flutter overlays (e.g. `HudOverlay`, `LevelUpOverlay`, `PauseOverlay`), use standard `testWidgets('...', (tester) async { ... })` and mount the overlay directly inside `MaterialApp(home: Scaffold(body: OverlayWidget(game: game)))` after calling `game.onLoad()`. Do NOT use `testWithGame` for widget assertions (which lacks `tester`), and do NOT wrap overlays in a live `GameWidget` (whose continuous game ticker causes widget tests to hang).
- **Lifecycle Mounting Synchronization:** Components added via `world.add(...)` or `spawnEnemy(...)` are queued in Flame's pending lifecycle list. Call `await game.ready();` before advancing simulation ticks or asserting on spatial queries and world state.
- **Step-Clamped Testing:** The core game loop clamps `dt` to `dt.clamp(0.0, 1.0 / 20.0)` ($0.05\text{s}$). Integration tests simulating durations or cadence intervals MUST advance time in small loops (e.g., `for (int i = 0; i < N; i++) game.update(0.05);`), never with a single large `dt`.

## 6. Modern Flutter & Flame Conventions
- **Color Alpha:** Use `Color.withValues(alpha: ...)` instead of deprecated `Color.withOpacity(...)`.
- **Button Event Handlers:** Use `onPressed:` on `ElevatedButton`, `OutlinedButton`, and `TextButton`, reserving `onTap:` for `InkWell` and `GestureDetector`.

