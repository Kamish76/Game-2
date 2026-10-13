import 'dart:math' as math;

import '../config/game_config.dart';
import '../data/enemies.dart';
import '../models/enemy_def.dart';

typedef SpawnCallback = void Function(EnemyDef def, double x, double y);

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

  double get elapsedTime => _elapsedTime;
  double get accumulatedCredits => _accumulatedCredits;

  /// Calculates credits earned per second at elapsed time [t].
  /// Formula: (4 + 0.35*t + 0.005*t^2) * (1 + curse)
  static double creditsPerSecond(double t, double curse) {
    final double baseRate = 4.0 + 0.35 * t + 0.005 * t * t;
    return baseRate * (1.0 + curse);
  }

  void update(double dt, double curse) {
    _elapsedTime += dt;
    final double rate = creditsPerSecond(_elapsedTime, curse);
    _accumulatedCredits += rate * dt;

    if (getActiveCount() >= maxLiveCap) {
      // Throttle accumulation when screen is full
      _accumulatedCredits = math.min(_accumulatedCredits, 20.0);
      return;
    }

    _trySpawn();
  }

  void _trySpawn() {
    // Determine which enemy types can be picked based on elapsed time
    final List<EnemyDef> available = <EnemyDef>[swarmlingDef];
    if (_elapsedTime >= 20.0) {
      available.add(runnerDef);
    }
    if (_elapsedTime >= 50.0) {
      available.add(bruteDef);
    }

    // Spawn while credits allow and under entity cap
    while (_accumulatedCredits >= 1.0 && getActiveCount() < maxLiveCap) {
      // Pick affordable enemy type
      final affordable = available.where((e) => e.creditCost <= _accumulatedCredits).toList();
      if (affordable.isEmpty) break;

      final EnemyDef chosen = affordable[rng.nextInt(affordable.length)];
      _accumulatedCredits -= chosen.creditCost;

      // 360° angle on perimeter circle (R = 200px)
      final double theta = rng.nextDouble() * 2 * math.pi;
      final double x = GameConfig.spawnRadius * math.cos(theta);
      final double y = GameConfig.spawnRadius * math.sin(theta);

      onSpawn(chosen, x, y);
    }
  }

  void reset() {
    _accumulatedCredits = 0.0;
    _elapsedTime = 0.0;
  }
}
