import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../config/game_config.dart';
import '../data/characters.dart';
import '../data/weapons.dart';
import '../models/enemy_def.dart';
import '../models/run_state.dart';
import '../systems/draft_system.dart';
import '../systems/spawn_director.dart';
import '../systems/spatial_hash.dart';
import '../systems/stat_engine.dart';
import '../ui/overlays/overlay_ids.dart';
import 'components/arena_background.dart';
import 'components/bastion.dart';
import 'components/enemy_component.dart';
import 'components/pickup_component.dart';
import 'components/weapon_component.dart';

/// Root Flame game orchestrating world entities, systems loop, and UI overlays.
class BonkholdGame extends FlameGame {
  BonkholdGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConfig.virtualWidth,
            height: GameConfig.virtualHeight,
          ),
        );

  final FpsComponent fpsCounter = FpsComponent();
  final math.Random rng = math.Random();

  late final RunState runState;
  late final SpatialHash spatialHash;
  late final SpawnDirector spawnDirector;
  late final DraftSystem draftSystem;

  late Bastion bastion;

  final Map<int, EnemyComponent> _activeEnemies = <int, EnemyComponent>{};
  int _nextEnemyId = 1;

  int get activeEnemyCount => _activeEnemies.length;
  EnemyComponent? findEnemyById(int id) => _activeEnemies[id];

  @override
  Color backgroundColor() => Palette.letterbox;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();

    spatialHash = SpatialHash(cellSize: 32.0);
    draftSystem = DraftSystem(rng: rng);

    _initRun();

    await world.add(ArenaBackground());
    await _setupWorldEntities();
    add(fpsCounter);
  }

  void _initRun() {
    runState = RunState(character: kitsuneSpireDef);
    // Equip starting weapon: Ember Staff
    runState.weapons.add(
      EquippedWeapon(def: emberStaffDef, stats: emberStaffDef.baseStats),
    );
    StatEngine.recompute(runState);

    spawnDirector = SpawnDirector(
      onSpawn: (def, x, y) => spawnEnemy(def, x, y),
      getActiveCount: () => activeEnemyCount,
      maxLiveCap: 400,
      rng: rng,
    );
  }

  Future<void> _setupWorldEntities() async {
    bastion = Bastion();
    await world.add(bastion);

    // Mount equipped weapons
    for (int i = 0; i < runState.weapons.length; i++) {
      final weapon = runState.weapons[i];
      await world.add(
        WeaponComponent(
          equippedWeapon: weapon,
          mountAngle: (i * (2 * math.pi / 4)),
        ),
      );
    }
  }

  /// Spawns a new enemy into the world and tracks it in the active map.
  void spawnEnemy(EnemyDef def, double x, double y) {
    if (runState.isGameOver) return;
    final int id = _nextEnemyId++;
    final enemy = EnemyComponent(
      id: id,
      def: def,
      position: Vector2(x, y),
    );
    _activeEnemies[id] = enemy;
    world.add(enemy);
  }

  /// Drops an XP shard or Gold coin at (x, y).
  void spawnPickup(double x, double y, int value, bool isGold) {
    world.add(
      PickupComponent(
        position: Vector2(x, y),
        value: value,
        isGold: isGold,
      ),
    );
  }

  void onEnemyKilled(EnemyComponent enemy) {
    _activeEnemies.remove(enemy.id);
    runState.addKill();
  }

  void onPickupAbsorbed(PickupComponent pickup) {
    if (pickup.isGold) {
      runState.addGold(pickup.value);
    } else {
      runState.addXp(pickup.value);
    }
  }

  @override
  void update(double dt) {
    if (runState.isPaused) return;

    final double step = dt.clamp(0.0, 1.0 / 20.0);

    if (runState.isGameOver) {
      if (!overlays.isActive(OverlayIds.gameOver)) {
        overlays.add(OverlayIds.gameOver);
      }
      return;
    }

    runState.elapsedSeconds.value += step;
    spawnDirector.update(step, runState.stats.curse);

    super.update(step);

    // Rebuild spatial hash with active enemies
    spatialHash.clear();
    for (final enemy in _activeEnemies.values) {
      if (enemy.isMounted) {
        spatialHash.insert(
          enemy.id,
          enemy.position.x,
          enemy.position.y,
          enemy.def.radius,
        );
      }
    }

    // Check level-up threshold
    if (runState.pendingLevelUps > 0 && !overlays.isActive(OverlayIds.levelUp)) {
      pauseForLevelUp();
    }
  }

  void pauseForLevelUp() {
    runState.isPaused = true;
    overlays.add(OverlayIds.levelUp);
  }

  void resumeFromLevelUp() {
    runState.pendingLevelUps = math.max(0, runState.pendingLevelUps - 1);
    overlays.remove(OverlayIds.levelUp);

    // If another level-up was queued, trigger it immediately
    if (runState.pendingLevelUps > 0) {
      overlays.add(OverlayIds.levelUp);
    } else {
      runState.isPaused = false;
    }
  }

  /// Refreshes mounted weapon components after drafting a new weapon.
  void refreshWeaponComponents() {
    // Remove existing weapon components
    final existing = world.children.whereType<WeaponComponent>().toList();
    for (final wc in existing) {
      wc.removeFromParent();
    }

    // Mount all currently equipped weapons
    for (int i = 0; i < runState.weapons.length; i++) {
      final weapon = runState.weapons[i];
      world.add(
        WeaponComponent(
          equippedWeapon: weapon,
          mountAngle: (i * (2 * math.pi / 4)),
        ),
      );
    }
  }

  /// Cleanly restarts the run.
  void restartRun() {
    overlays.remove(OverlayIds.gameOver);
    overlays.remove(OverlayIds.pause);
    overlays.remove(OverlayIds.levelUp);

    // Clear active dynamic components
    for (final enemy in _activeEnemies.values) {
      enemy.removeFromParent();
    }
    _activeEnemies.clear();

    final pickups = world.children.whereType<PickupComponent>().toList();
    for (final p in pickups) {
      p.removeFromParent();
    }

    final weapons = world.children.whereType<WeaponComponent>().toList();
    for (final w in weapons) {
      w.removeFromParent();
    }

    // Reset state & director
    runState.reset();
    runState.weapons.add(
      EquippedWeapon(def: emberStaffDef, stats: emberStaffDef.baseStats),
    );
    StatEngine.recompute(runState);
    spawnDirector.reset();

    // Re-mount weapon
    world.add(
      WeaponComponent(
        equippedWeapon: runState.weapons.first,
        mountAngle: 0.0,
      ),
    );
  }
}
