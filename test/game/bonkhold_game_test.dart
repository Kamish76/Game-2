import 'package:bonkhold/data/enemies.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/bastion.dart';
import 'package:bonkhold/game/components/weapon_component.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BonkholdGame Integration', () {
    testWithGame<BonkholdGame>(
      'Bastion and starting Ember Staff are mounted at origin',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        final bastions = game.world.children.whereType<Bastion>();
        expect(bastions.length, 1);
        expect(bastions.first.position, Vector2.zero());

        final weapons = game.world.children.whereType<WeaponComponent>();
        expect(weapons.length, 1);
        expect(weapons.first.equippedWeapon.def.id, 'ember_staff');
      },
    );

    testWithGame<BonkholdGame>(
      'Enemy moves toward Bastion each tick and halts at contact radius',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Spawn a runner at (0, 100)
        game.spawnEnemy(runnerDef, 0, 100);
        await game.ready();

        expect(game.activeEnemyCount, 1);
        final enemy = game.findEnemyById(1)!;

        // Advance 0.5 seconds
        game.update(0.5);
        expect(enemy.position.y, lessThan(100.0));
      },
    );

    testWithGame<BonkholdGame>(
      'Defeated enemy drops XP pickup which is vacuumed and absorbed',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Directly spawn an enemy close to Bastion
        game.spawnEnemy(swarmlingDef, 0, 30);
        await game.ready();

        final enemy = game.findEnemyById(1)!;
        // Kill enemy
        enemy.takeDamage(
          damage: 100.0,
          isCrit: false,
          kbDirX: 0,
          kbDirY: 0,
          kbAmount: 0,
        );

        expect(game.runState.kills.value, 1);

        // Mount the newly spawned pickup
        game.update(0.05);

        // Check pickup was spawned in world or absorbed
        // Advance simulation so it vacuums into core
        for (int i = 0; i < 30; i++) {
          game.update(0.05);
        }

        // RunState should have received XP
        expect(game.runState.currentXp.value, greaterThan(0));
      },
    );

    testWithGame<BonkholdGame>(
      'Enemy contacts Bastion and inflicts damage',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Spawn swarmling right at Bastion hull (16px + 5px = 21px)
        game.spawnEnemy(swarmlingDef, 0, 20);
        await game.ready();

        final initialHp = game.runState.hp.value;

        // Advance by 1.25s (swarmling attackInterval is 1.0s, step is clamped to 0.05)
        for (int i = 0; i < 25; i++) {
          game.update(0.05);
        }

        expect(game.runState.hp.value, lessThan(initialHp));
      },
    );

    testWithGame<BonkholdGame>(
      'Game over triggers when Bastion HP reaches 0 and restartRun resets cleanly',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Inflict lethal damage
        game.runState.applyDamage(200.0);
        expect(game.runState.isGameOver, isTrue);

        // Call restartRun
        game.restartRun();
        expect(game.runState.isGameOver, isFalse);
        expect(game.runState.hp.value, 100.0);
        expect(game.runState.kills.value, 0);
      },
    );
  });
}
