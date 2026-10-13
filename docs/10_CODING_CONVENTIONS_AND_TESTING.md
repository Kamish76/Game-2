# 10: Coding Conventions & Testing Standards

## Purpose
Establishes coding practices, performance hygiene rules, and testing requirements for the BONKHOLD codebase.

---

## 1. Code Style & Architecture Hygiene

### 1.1 Separation of Concerns
- **Flame Components:** Responsible exclusively for spatial transformation, sprite/canvas rendering, and reading computed data.
- **Pure Dart Systems:** All gameplay rules, stat resolution, draft algorithms, and damage math live in plain Dart classes under `lib/systems/` or `lib/models/`.
- **UI Overlays:** Flutter widgets that react to `ValueNotifier` state exposed by `RunState`. Never put game physics inside Flutter widget trees.

### 1.2 Performance & Memory Rules (Hot Path Discipline)
- **Zero Allocations in `update()`:** Never instantiate new `Vector2()`, `Paint()`, closures, or list literals inside `update()` or `render()`. Pre-allocate and reuse vectors/paints.
- **No `print()`:** Use Dart `logging` or assertions. `avoid_print` is enforced by linter.
- **Const Constructors:** Use `const` wherever possible to facilitate widget and model caching.
- **Avoid Flame Built-in Collision Detection on Swarms:** Use the custom `SpatialHash` for O(1) proximity queries instead of the O(N²) collision component tree.

---

## 2. Testing Guidelines

### 2.1 Pure Dart Unit Tests (`test/systems/`)
Every system calculation must have comprehensive automated test coverage:
- **`StatEngine` Tests:** Verify additive percentages, hyperbolic armor curves, and cooldown clamping.
- **`DamageResolver` Tests:** Verify deflect rolls, shield non-spillover, minimum damage floors, and thorns reflection.
- **`DraftSystem` Tests:** Verify that 4-slot limits are respected, offered cards are distinct, and rarity distribution matches expected probabilities.

### 2.2 Flame Integration Tests (`test/game/`)
Use `flame_test` (`testWithGame`) to verify component lifecycles, mounting, and world hierarchies without needing a physical screen:

- **Mandatory `testWithGame` Harness:** Never instantiate raw `game = BonkholdGame(); await game.onLoad();` in unit tests, as `game.isMounted` and child lifecycle flags will remain `false`.
- **Lifecycle Mounting Synchronization:** Components added via `world.add(...)` or `spawnEnemy(...)` are queued in Flame's pending lifecycle list. Call `await game.ready();` before advancing simulation ticks or asserting on spatial queries and world state.
- **Step-Clamped Simulation Ticking:** The core game loop clamps `dt` to `dt.clamp(0.0, 1.0 / 20.0)` ($0.05\text{s}$). Integration tests simulating durations or cadence intervals MUST advance time in small loops (e.g., `for (int i = 0; i < N; i++) game.update(0.05);`), never with a single large `dt`.

```dart
testWithGame<BonkholdGame>(
  'Enemy advances toward Bastion each tick',
  BonkholdGame.new,
  (game) async {
    await game.ready();
    final enemy = EnemyComponent(position: Vector2(0, 100));
    await game.world.add(enemy);
    await game.ready();
    for (int i = 0; i < 20; i++) {
      game.update(0.05);
    }
    expect(enemy.position.y, lessThan(100));
  },
);
```

### 2.3 Flutter Overlay Widget Tests (`test/ui/`)
Tests verifying UI overlays layered over Flame (`HudOverlay`, `LevelUpOverlay`, `PauseOverlay`, etc.):
- **Harness & Initialization:**
  - Instantiate `BonkholdGame` and call `await game.onLoad()` to initialize `RunState` and audio services safely without entering a live game loop ticker (avoiding deadlocks in widget test runners).
  - Wrap the target overlay in `MaterialApp(home: Scaffold(body: HudOverlay(game: game)))`.
  - Set explicit test view dimensions matching mobile portrait (e.g. `tester.view.physicalSize = const Size(360, 640); tester.view.devicePixelRatio = 1.0;`).
- **Required Assertions:**
  - **Bounded Non-Zero Dimensions:** Verify that root widgets and sub-bars evaluate to non-zero width and height (`expect(tester.getSize(find.byKey(...)).width, greaterThan(0))`).
  - **Reactive State Propagation:** Verify `ValueListenableBuilder` triggers upon mutating `runState.xpProgress`, `runState.hp`, `runState.shield`, `runState.bossHealthRatio`, and `runState.loadoutVersion`.
  - **Touch Target Integrity:** Ensure interactive overlay targets (e.g., Pause button, Level-up cards) satisfy minimum dimensions ($\ge 48 \times 48\text{ dp}$).

---

## 3. Verification Workflow
Prior to merging or committing any milestone increment:
1. `flutter analyze` must report 0 issues.
2. `flutter test` must pass 100% of tests.
3. `flutter build web` must compile cleanly.

---

## 4. Git & Branching Strategy
- **`dev` (Active Development):** Primary working branch. All feature work, bug fixes, experiments, and daily milestone commits land on `dev`.
- **`main` (Production / Stable Releases):** Protected release branch. Only merged from `dev` when a complete milestone release or public build is validated.

