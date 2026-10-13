import 'dart:math' as math;
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bonkhold/data/enemies.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/chest_component.dart';

void main() {
  group('Moat Chest System Tests', () {
    testWithGame<BonkholdGame>(
      'Spawned chest auto-vacuums towards Bastion and parks at moat ring radius',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Spawn a chest at (50, 50) -> distance ~ 70.7px
        game.spawnChest(50.0, 50.0, isGolden: false);
        await game.ready();

        expect(game.activeChestCount, 1);
        final chest = game.world.children.whereType<ChestComponent>().first;
        expect(chest.isParked, isFalse);

        // Advance simulation in step-clamped ticks
        for (int i = 0; i < 30; i++) {
          game.update(0.05);
        }

        // Chest should now have vacuumed and parked on the moat ring (R=32px)
        expect(chest.isParked, isTrue);
        final double dist = math.sqrt(chest.position.x * chest.position.x + chest.position.y * chest.position.y);
        expect(dist, closeTo(ChestComponent.moatRadius, 0.5));
      },
    );

    testWithGame<BonkholdGame>(
      'Opening a chest removes it and awards an Item Relic into RunState',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        expect(game.runState.ownedItems.isEmpty, isTrue);

        game.spawnChest(20.0, 20.0, isGolden: true);
        await game.ready();

        final chest = game.world.children.whereType<ChestComponent>().first;

        // Open chest
        game.openChest(chest);
        await game.ready();

        expect(game.activeChestCount, 0);
        expect(game.runState.ownedItems.isNotEmpty, isTrue);
        final totalRelics = game.runState.ownedItems.values.fold<int>(0, (a, b) => a + b);
        expect(totalRelics, 1);
      },
    );

    testWithGame<BonkholdGame>(
      'Yokai Goliath Boss drops guaranteed Golden Chest upon defeat',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Spawn Goliath Boss at (40, 40)
        game.spawnEnemy(yokaiGoliathDef, 40.0, 40.0);
        await game.ready();

        final boss = game.findEnemyById(1)!;

        // Kill Boss
        boss.takeDamage(
          damage: 99999.0,
          isCrit: false,
          kbDirX: 0.0,
          kbDirY: 0.0,
          kbAmount: 0.0,
        );
        await game.ready();

        // Verify golden chest was spawned
        expect(game.activeChestCount, 1);
        final chest = game.world.children.whereType<ChestComponent>().first;
        expect(chest.isGolden, isTrue);
      },
    );

    testWithGame<BonkholdGame>(
      'restartRun cleans up active chests completely',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        game.spawnChest(30.0, 30.0);
        game.spawnChest(-30.0, -30.0);
        await game.ready();

        expect(game.activeChestCount, 2);

        game.restartRun();
        await game.ready();

        expect(game.activeChestCount, 0);
        expect(game.world.children.whereType<ChestComponent>().isEmpty, isTrue);
        expect(game.runState.ownedItems.isEmpty, isTrue);
      },
    );
  });
}
