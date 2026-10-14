import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../audio/audio_manager.dart';
import '../config/game_config.dart';
import '../data/characters.dart';
import '../data/items.dart';
import '../data/weapons.dart';
import '../models/enemy_def.dart';
import '../models/run_state.dart';
import '../systems/camera_director.dart';
import '../systems/draft_system.dart';
import '../systems/merchant_director.dart';
import '../systems/meta_repository.dart';
import '../systems/spawn_director.dart';
import '../systems/spatial_hash.dart';
import '../systems/stat_engine.dart';
import '../ui/overlays/overlay_ids.dart';
import 'components/arena_background.dart';
import 'components/bastion.dart';
import 'components/chest_component.dart';
import 'components/damage_number.dart';
import 'components/enemy_component.dart';
import 'components/pickup_component.dart';
import 'components/projectile_component.dart';
import 'components/traveling_merchant_component.dart';
import 'components/weapon_component.dart';

/// Root Flame game orchestrating world entities, systems loop, and UI overlays.
class BonkholdGame extends FlameGame with TapCallbacks {
  BonkholdGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConfig.virtualWidth,
            height: GameConfig.virtualHeight,
          ),
        );

  final FpsComponent fpsCounter = FpsComponent();
  final math.Random rng = math.Random();
  final CameraDirector cameraDirector = CameraDirector();

  late final RunState runState;
  late final SpatialHash spatialHash;
  late final SpawnDirector spawnDirector;
  late final DraftSystem draftSystem;
  late final MerchantDirector merchantDirector;

  late Bastion bastion;

  final Map<int, EnemyComponent> _activeEnemies = <int, EnemyComponent>{};
  final List<PickupComponent> _activePickups = <PickupComponent>[];
  final List<ChestComponent> _activeChests = <ChestComponent>[];
  TravelingMerchantComponent? _activeMerchant;
  int _nextEnemyId = 1;

  int get activeEnemyCount => _activeEnemies.length;
  int get activePickupCount => _activePickups.length;
  int get activeChestCount => _activeChests.length;
  TravelingMerchantComponent? get activeMerchant => _activeMerchant;
  EnemyComponent? findEnemyById(int id) => _activeEnemies[id];

  @override
  Color backgroundColor() => Palette.letterbox;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();

    spatialHash = SpatialHash(cellSize: 32.0);
    draftSystem = DraftSystem(rng: rng);
    merchantDirector = MerchantDirector();

    // Register fallback overlay builder stubs so headless tests can trigger overlays safely
    for (final id in [
      OverlayIds.hud,
      OverlayIds.levelUp,
      OverlayIds.pause,
      OverlayIds.gameOver,
      OverlayIds.merchant,
      OverlayIds.shrine,
    ]) {
      overlays.addEntry(id, (_, _) => const SizedBox.shrink());
    }

    _initRun();

    await world.add(ArenaBackground());
    await _setupWorldEntities();
    add(fpsCounter);
  }

  void _initRun() {
    runState = RunState(
      character: kitsuneSpireDef,
      metaStats: MetaRepository.instance.getActiveStats(),
    );
    // Equip starting weapon: Ember Staff
    runState.weapons.add(
      EquippedWeapon(def: emberStaffDef, stats: emberStaffDef.baseStats),
    );
    StatEngine.recompute(runState);

    spawnDirector = SpawnDirector(
      onSpawn: (def, x, y, {bool isElite = false, double statMultiplierHp = 1.0, double statMultiplierSpeed = 1.0}) =>
          spawnEnemy(
            def,
            x,
            y,
            isElite: isElite,
            statMultiplierHp: statMultiplierHp,
            statMultiplierSpeed: statMultiplierSpeed,
          ),
      getActiveCount: () => activeEnemyCount,
      maxLiveCap: 400,
      rng: rng,
      getSpawnRadius: () => GameConfig.spawnRadius / cameraDirector.currentZoom,
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
  void spawnEnemy(
    EnemyDef def,
    double x,
    double y, {
    bool isElite = false,
    double statMultiplierHp = 1.0,
    double statMultiplierSpeed = 1.0,
  }) {
    if (runState.isGameOver) return;
    final int id = _nextEnemyId++;
    final enemy = EnemyComponent(
      id: id,
      def: def,
      position: Vector2(x, y),
      isElite: isElite,
      statMultiplierHp: statMultiplierHp,
      statMultiplierSpeed: statMultiplierSpeed,
    );
    _activeEnemies[id] = enemy;
    world.add(enemy);

    if (def.isBoss) {
      runState.activeBoss.value = BossInfo(
        name: def.name,
        hp: enemy.hp,
        maxHp: enemy.maxHp,
      );
    }
  }

  /// Drops an XP shard or Gold coin at (x, y).
  void spawnPickup(double x, double y, int value, bool isGold, {bool autoCollect = true}) {
    final pickup = PickupComponent(
      position: Vector2(x, y),
      value: value,
      isGold: isGold,
      autoCollect: autoCollect,
    );
    _activePickups.add(pickup);
    world.add(pickup);

    // High-density optimization: merge low-tier shards if > 150 pickups on field
    _checkShardMerging();
  }

  /// Compresses adjacent low-tier XP shards within 32px when active count exceeds 150.
  void _checkShardMerging() {
    if (_activePickups.length <= 150) return;

    // Filter candidate low-tier XP shards
    final lowTierShards = _activePickups
        .where((p) => !p.isGold && (p.value == 1 || p.value == 5))
        .toList();

    if (lowTierShards.length < 5) return;

    for (int i = 0; i < lowTierShards.length; i++) {
      final center = lowTierShards[i];

      final cluster = <PickupComponent>[center];
      for (int j = 0; j < lowTierShards.length; j++) {
        if (i == j) continue;
        final candidate = lowTierShards[j];
        if (candidate.value != center.value) continue;

        final double dx = candidate.position.x - center.position.x;
        final double dy = candidate.position.y - center.position.y;
        if (dx * dx + dy * dy <= 32.0 * 32.0) {
          cluster.add(candidate);
          if (cluster.length == 5) break;
        }
      }

      if (cluster.length >= 5) {
        // Merge 5x 1-XP into 1x 5-XP, or 5x 5-XP into 1x 25-XP
        final int newValue = center.value == 1 ? 5 : 25;
        final double avgX = center.position.x;
        final double avgY = center.position.y;

        for (final p in cluster) {
          _activePickups.remove(p);
          p.removeFromParent();
        }

        final merged = PickupComponent(
          position: Vector2(avgX, avgY),
          value: newValue,
          isGold: false,
        );
        _activePickups.add(merged);
        world.add(merged);

        if (_activePickups.length <= 150) break;
      }
    }
  }

  void onEnemyKilled(EnemyComponent enemy) {
    _activeEnemies.remove(enemy.id);
    runState.addKill();
    if (enemy.def.isBoss) {
      runState.activeBoss.value = null;
    }
  }

  void onPickupAbsorbed(PickupComponent pickup) {
    _activePickups.remove(pickup);
    if (pickup.isGold) {
      final int value = (pickup.value * runState.metaStats.goldMultiplier).round();
      runState.addGold(value);
    } else {
      runState.addXp(pickup.value);
    }
  }

  /// Drops a ChestComponent at (x, y) that vacuums towards the Bastion moat.
  void spawnChest(double x, double y, {bool isGolden = false}) {
    final chest = ChestComponent(
      position: Vector2(x, y),
      isGolden: isGolden,
    );
    _activeChests.add(chest);
    world.add(chest);
  }

  /// Hook called when a chest arrives and parks on the moat ring.
  void onChestParked(ChestComponent chest) {
    // Registered on moat circle
  }

  /// Cracks open a parked chest, awarding an Item Relic.
  void openChest(ChestComponent chest) {
    if (!chest.isMounted) return;
    _activeChests.remove(chest);
    chest.removeFromParent();

    // Roll item relic weighted by rarity and player luck
    final relic = rollChestRelic(
      rng,
      isGolden: chest.isGolden,
      luck: runState.stats.luck,
    );
    runState.addItem(relic.id);
    StatEngine.recompute(runState);
    AudioManager.instance.playSfx(SfxId.chestOpen);

    // Visual fanfare
    world.add(
      ExplosionBurstComponent(
        position: chest.position.clone(),
        maxRadius: 28.0,
      ),
    );
    world.add(
      DamageNumberComponent(
        position: chest.position.clone()..y -= 10.0,
        damage: 0,
        isCrit: true,
      ),
    );
  }

  /// Spawns the Traveling Merchant cart heading for the Bastion.
  void spawnMerchant({double? x, double? y}) {
    if (runState.isGameOver) return;
    if (_activeMerchant != null && _activeMerchant!.isMounted) return;
    final double spawnX = x ?? (rng.nextBool() ? 120.0 : -120.0);
    final double spawnY = y ?? (rng.nextDouble() * 200.0 - 100.0);
    final merchant = TravelingMerchantComponent(position: Vector2(spawnX, spawnY));
    _activeMerchant = merchant;
    world.add(merchant);
  }

  /// Hook called when the merchant departs from the arena.
  void onMerchantDeparted() {
    _activeMerchant = null;
    merchantDirector.onMerchantDeparted();
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

    // Overtime mode trigger at 15:00 (900 seconds)
    if (runState.elapsedSeconds.value >= 900.0) {
      if (!runState.isOvertime.value) {
        runState.isOvertime.value = true;
      }
      runState.overtimeDuration += step;
    }

    spawnDirector.update(step, runState.stats.curse);

    // Traveling Merchant periodic arrival check
    if (merchantDirector.update(step)) {
      spawnMerchant();
    }

    // Rebuild spatial hash with active enemies before child updates
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

    // Advance dynamic camera zoom-out based on level and survival duration
    cameraDirector.update(
      step,
      level: runState.level.value,
      elapsedSeconds: runState.elapsedSeconds.value,
    );
    camera.viewfinder.zoom = cameraDirector.currentZoom;

    super.update(step);


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
    overlays.remove(OverlayIds.merchant);
    overlays.remove(OverlayIds.shrine);

    // Clear active dynamic components
    for (final enemy in _activeEnemies.values) {
      enemy.removeFromParent();
    }
    _activeEnemies.clear();

    final pickups = world.children.whereType<PickupComponent>().toList();
    for (final p in pickups) {
      p.removeFromParent();
    }
    _activePickups.clear();

    final chests = world.children.whereType<ChestComponent>().toList();
    for (final c in chests) {
      c.removeFromParent();
    }
    _activeChests.clear();

    if (_activeMerchant != null) {
      _activeMerchant!.removeFromParent();
      _activeMerchant = null;
    }

    final weapons = world.children.whereType<WeaponComponent>().toList();
    for (final w in weapons) {
      w.removeFromParent();
    }

    // Reset state & director with updated meta-progression stats
    runState.metaStats = MetaRepository.instance.getActiveStats();
    runState.reset();
    runState.weapons.add(
      EquippedWeapon(def: emberStaffDef, stats: emberStaffDef.baseStats),
    );
    StatEngine.recompute(runState);
    spawnDirector.reset();
    merchantDirector.reset();
    cameraDirector.reset();
    camera.viewfinder.zoom = cameraDirector.currentZoom;

    // Re-mount weapon
    world.add(
      WeaponComponent(
        equippedWeapon: runState.weapons.first,
        mountAngle: 0.0,
      ),
    );
  }
}
