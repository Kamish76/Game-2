import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Shard Merging Optimization', () {
    late BonkholdGame game;

    setUp(() async {
      game = BonkholdGame();
      await game.onLoad();
    });

    test('compresses adjacent low-tier shards when field exceeds 150 pickups', () async {
      // Spawn 149 shards spread out
      for (int i = 0; i < 149; i++) {
        game.spawnPickup(i.toDouble() * 2.0, 50.0, 1, false);
      }
      expect(game.activePickupCount, 149);

      // Now spawn a tight cluster of 5 shards within 10px of each other at (10, 10)
      for (int i = 0; i < 5; i++) {
        game.spawnPickup(10.0 + i * 2.0, 10.0, 1, false);
      }

      // The 150 limit was breached, triggering merge: 5x 1-XP -> 1x 5-XP
      // 149 + 5 = 154 before merge. Merging 5 into 1 reduces count by 4 -> 150!
      expect(game.activePickupCount, lessThanOrEqualTo(150));
    });
  });
}
