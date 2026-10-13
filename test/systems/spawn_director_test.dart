import 'dart:math' as math;

import 'package:bonkhold/config/game_config.dart';
import 'package:bonkhold/models/enemy_def.dart';
import 'package:bonkhold/systems/spawn_director.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpawnDirector', () {
    test('credits formula matches design specifications', () {
      // (4 + 0.35*t + 0.005*t^2) * (1 + curse)
      final rate0 = SpawnDirector.creditsPerSecond(0.0, 0.0);
      expect(rate0, closeTo(4.0, 0.001));

      final rate100 = SpawnDirector.creditsPerSecond(100.0, 0.0);
      // 4 + 35 + 50 = 89.0
      expect(rate100, closeTo(89.0, 0.001));
    });

    test('spawns enemies on 200px perimeter circle', () {
      final spawned = <EnemyDef>[];
      final coords = <math.Point<double>>[];
      int activeCount = 0;

      final director = SpawnDirector(
        onSpawn: (def, x, y) {
          spawned.add(def);
          coords.add(math.Point(x, y));
          activeCount++;
        },
        getActiveCount: () => activeCount,
        maxLiveCap: 400,
        rng: math.Random(123),
      );

      // Advance by 2.0s -> at t=0 to 2s, rate ~ 4 cr/s -> ~8 credits -> should spawn several enemies
      director.update(2.0, 0.0);

      expect(spawned, isNotEmpty);
      for (final point in coords) {
        final dist = math.sqrt(point.x * point.x + point.y * point.y);
        expect(dist, closeTo(GameConfig.spawnRadius, 0.01));
      }
    });

    test('throttles when active count reaches maxLiveCap', () {
      const int activeCount = 400; // Cap reached
      int spawnCalls = 0;

      final director = SpawnDirector(
        onSpawn: (def, x, y) {
          spawnCalls++;
        },
        getActiveCount: () => activeCount,
        maxLiveCap: 400,
      );

      director.update(10.0, 0.0);
      expect(spawnCalls, 0);
    });
  });
}
