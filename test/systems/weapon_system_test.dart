import 'package:bonkhold/data/enemies.dart';
import 'package:bonkhold/data/weapons.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/projectile_component.dart';
import 'package:bonkhold/game/components/weapon_component.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Weapons System', () {
    testWithGame<BonkholdGame>(
      'Pulse Aura creates RadialShockwaveComponent and damages adjacent enemies',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Clear starting weapons, equip Pulse Aura
        for (final w in game.world.children.whereType<WeaponComponent>().toList()) {
          w.removeFromParent();
        }
        game.runState.weapons.clear();
        final pulseEq = EquippedWeapon(def: pulseAuraDef, stats: pulseAuraDef.baseStats);
        game.runState.weapons.add(pulseEq);
        final weaponComp = WeaponComponent(equippedWeapon: pulseEq);
        await game.world.add(weaponComp);
        await game.ready();

        // Spawn enemy within pulse radius (42px)
        game.spawnEnemy(swarmlingDef, 25.0, 0.0);
        await game.ready();

        final enemy = game.findEnemyById(1);
        expect(enemy, isNotNull);
        final double initialHp = enemy!.hp;

        // Advance time past cooldown (1.8s) in small 0.05s steps
        for (int i = 0; i < 40; i++) {
          game.update(0.05);
        }

        // Assert enemy took damage from pulse
        expect(enemy.hp, lessThan(initialHp));
      },
    );

    testWithGame<BonkholdGame>(
      'Rail Sniper targets enemy with highest maxHp within range',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Clear weapons, equip Rail Sniper
        for (final w in game.world.children.whereType<WeaponComponent>().toList()) {
          w.removeFromParent();
        }
        game.runState.weapons.clear();
        final railEq = EquippedWeapon(def: railSniperDef, stats: railSniperDef.baseStats);
        game.runState.weapons.add(railEq);
        final weaponComp = WeaponComponent(equippedWeapon: railEq);
        await game.world.add(weaponComp);
        await game.ready();

        // Spawn Swarmling (HP 18) closer to Bastion at (30, 0)
        game.spawnEnemy(swarmlingDef, 30.0, 0.0);
        // Spawn Brute (HP 90) further away at (60, 0)
        game.spawnEnemy(bruteDef, 60.0, 0.0);
        await game.ready();

        final brute = game.findEnemyById(2);
        expect(brute, isNotNull);
        final double bruteInitialHp = brute!.hp;

        // Advance time past Rail Sniper cooldown (2.4s) in small 0.05s steps
        for (int i = 0; i < 55; i++) {
          game.update(0.05);
        }

        // Assert Rail Sniper prioritized Brute (highest max HP)
        expect(brute.hp, lessThan(bruteInitialHp));
      },
    );

    testWithGame<BonkholdGame>(
      'Revolver Battery bullet pierces through multiple enemies',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Clear auto-firing weapons
        for (final w in game.world.children.whereType<WeaponComponent>().toList()) {
          w.removeFromParent();
        }
        game.runState.weapons.clear();

        final bullet = ProjectileComponent(
          position: Vector2.zero(),
          dirX: 1.0,
          dirY: 0.0,
          speed: 200.0,
          damage: 10.0,
          blastRadius: 0.0,
          knockback: 5.0,
          isCrit: false,
          maxDistance: 150.0,
          pierce: 1, // Can pierce 1 target (hits 2 targets total)
        );
        await game.world.add(bullet);

        // Spawn two Swarmlings in line of bullet travel
        game.spawnEnemy(swarmlingDef, 20.0, 0.0);
        game.spawnEnemy(swarmlingDef, 40.0, 0.0);
        await game.ready();

        final e1 = game.findEnemyById(1)!;
        final e2 = game.findEnemyById(2)!;

        // Tick bullet through both enemies
        for (int i = 0; i < 10; i++) {
          game.update(0.05);
        }

        // Both enemies took damage due to pierce = 1
        expect(e1.hp, lessThan(e1.maxHp));
        expect(e2.hp, lessThan(e2.maxHp));
      },
    );
  });
}
