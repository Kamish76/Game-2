import 'dart:math' as math;

import '../config/game_config.dart';
import '../data/enemies.dart';
import '../models/enemy_def.dart';

typedef SpawnCallback = void Function(
  EnemyDef def,
  double x,
  double y, {
  bool isElite,
  double statMultiplierHp,
  double statMultiplierSpeed,
});

/// Controls wave pacing, credit replenishment, and 360° off-screen perimeter spawning.
class SpawnDirector {
  SpawnDirector({
    required this.onSpawn,
    required this.getActiveCount,
    this.maxLiveCap = 400,
    math.Random? rng,
  }) : rng = rng ?? math.Random();

  final SpawnCallback onSpawn;
  final int Function() getActiveCount;
  final int maxLiveCap;
  final math.Random rng;

  double _accumulatedCredits = 0.0;
  double _elapsedTime = 0.0;
  int _bossesSpawned = 0;

  double get elapsedTime => _elapsedTime;
  double get accumulatedCredits => _accumulatedCredits;
  int get bossesSpawned => _bossesSpawned;

  /// Calculates credits earned per second at elapsed time [t].
  /// Formula: (2.0 + 0.175*t + 0.0025*t^2) * (1 + curse)
  /// At t >= 900s (Overtime / Final Swarm): doubles by +100% (2.0x)
  static double creditsPerSecond(double t, double curse) {
    final double baseRate = 2.0 + 0.175 * t + 0.0025 * t * t;
    final double overtimeMult = t >= 900.0 ? 2.0 : 1.0;
    return baseRate * (1.0 + curse) * overtimeMult;
  }

  void update(double dt, double curse) {
    _elapsedTime += dt;
    final double rate = creditsPerSecond(_elapsedTime, curse);
    _accumulatedCredits += rate * dt;

    // Check 3-minute Boss spawn (180s, 360s, 540s, ...)
    final int targetBossCount = (_elapsedTime / 180.0).floor();
    if (targetBossCount > _bossesSpawned) {
      _spawnBoss();
    }

    if (getActiveCount() >= maxLiveCap) {
      // Throttle accumulation when screen is full
      _accumulatedCredits = math.min(_accumulatedCredits, 20.0);
      return;
    }

    _trySpawn(curse);
  }

  void _spawnBoss() {
    _bossesSpawned++;
    final double theta = rng.nextDouble() * 2 * math.pi;
    final double x = GameConfig.spawnRadius * math.cos(theta);
    final double y = GameConfig.spawnRadius * math.sin(theta);

    // Scaling base HP: 1500 + 175 * (wave - 1)
    final double hpScale = (1500.0 + 175.0 * (_bossesSpawned - 1)) / yokaiGoliathDef.baseHp;

    onSpawn(
      yokaiGoliathDef,
      x,
      y,
      isElite: false,
      statMultiplierHp: hpScale,
      statMultiplierSpeed: 1.0,
    );
  }

  void _trySpawn(double curse) {
    // Determine which enemy types can be picked based on elapsed time
    final List<EnemyDef> available = <EnemyDef>[swarmlingDef];
    if (_elapsedTime >= 20.0) {
      available.add(runnerDef);
    }
    if (_elapsedTime >= 50.0) {
      available.add(bruteDef);
    }
    if (_elapsedTime >= 80.0) {
      available.add(spitterDef);
    }

    // Overtime stat escalations: +5% HP and +2.5% speed per 30s past 900s
    double statHp = 1.0;
    double statSpeed = 1.0;
    if (_elapsedTime >= 900.0) {
      final int otCycles = ((_elapsedTime - 900.0) / 30.0).floor();
      statHp = 1.0 + (otCycles * 0.05);
      statSpeed = 1.0 + (otCycles * 0.025);
    }

    // Spawn while credits allow and under entity cap
    while (_accumulatedCredits >= 1.0 && getActiveCount() < maxLiveCap) {
      final affordable = available.where((e) => e.creditCost <= _accumulatedCredits).toList();
      if (affordable.isEmpty) break;

      final EnemyDef chosen = affordable[rng.nextInt(affordable.length)];
      _accumulatedCredits -= chosen.creditCost;

      // 360° angle on perimeter circle (R = 200px)
      final double theta = rng.nextDouble() * 2 * math.pi;
      final double x = GameConfig.spawnRadius * math.cos(theta);
      final double y = GameConfig.spawnRadius * math.sin(theta);

      // Elite probability: 3% * (1 + curse)
      final bool isElite = rng.nextDouble() < (0.03 * (1.0 + curse));

      onSpawn(
        chosen,
        x,
        y,
        isElite: isElite,
        statMultiplierHp: statHp,
        statMultiplierSpeed: statSpeed,
      );
    }
  }

  void reset() {
    _accumulatedCredits = 0.0;
    _elapsedTime = 0.0;
    _bossesSpawned = 0;
  }
}

