import 'package:bonkhold/data/enemies.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/enemy_component.dart';
import 'package:bonkhold/game/components/projectile_component.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Boss and Elite Encounters', () {
    test('Elite enemy has 3x HP, boosted damage, and increased knockback resistance', () {
      final elite = EnemyComponent(
        id: 10,
        def: bruteDef,
        position: Vector2(100, 0),
        isElite: true,
      );

      // Base Brute: HP 90, Contact Damage 18, Knockback Resist 0.65
      // Elite: 3x HP = 270, 1.3x Dmg = 23.4, Knockback Resist + 0.25 = 0.90
      expect(elite.maxHp, 270.0);
      expect(elite.hp, 270.0);
      expect(elite.effectiveContactDamage, closeTo(23.4, 0.01));
      expect(elite.effectiveKnockbackResist, closeTo(0.90, 0.01));
    });

    testWithGame<BonkholdGame>(
      'Spitter halts at 110px distance from Bastion and fires ranged projectiles',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        game.spawnEnemy(spitterDef, 150.0, 0.0);
        await game.ready();

        final spitter = game.findEnemyById(1)!;

        // Advance time until spitter reaches 110px
        for (int i = 0; i < 30; i++) {
          game.update(0.05);
        }

        // Should halt at 110px (within small delta)
        expect(spitter.position.x, closeTo(110.0, 5.0));

        // Advance time past attackInterval (2.0s = 40 ticks of 0.05s) to fire projectile
        for (int i = 0; i < 45; i++) {
          game.update(0.05);
        }

        final enemyProj = game.world.children.whereType<EnemyProjectileComponent>();
        expect(enemyProj, isNotEmpty);
      },
    );

    testWithGame<BonkholdGame>(
      'Yokai Goliath Boss updates activeBoss notifier and awards boss kill on defeat',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        game.spawnEnemy(yokaiGoliathDef, 180.0, 0.0);
        await game.ready();

        final boss = game.findEnemyById(1)!;
        expect(game.runState.activeBoss.value, isNotNull);
        expect(game.runState.activeBoss.value!.name, 'Yokai Goliath');

        // Deal lethal damage to boss
        boss.takeDamage(
          damage: 2000.0,
          isCrit: false,
          kbDirX: 1.0,
          kbDirY: 0.0,
          kbAmount: 0.0,
        );
        game.update(0.05);

        expect(game.runState.bossKills.value, 1);
        expect(game.runState.activeBoss.value, isNull);
      },
    );

    testWithGame<BonkholdGame>(
      'SpawnDirector spawns Yokai Goliath Boss at 3-minute (180s) marks',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Advance time to 180s
        for (int i = 0; i < 3600; i++) {
          game.spawnDirector.update(0.05, 0.0);
        }
        expect(game.spawnDirector.bossesSpawned, 1);
      },
    );
  });
}
