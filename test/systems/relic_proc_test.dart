import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/data/items.dart';
import 'package:bonkhold/models/rarity.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/models/stat_sheet.dart';
import 'package:bonkhold/systems/damage_resolver.dart';
import 'package:bonkhold/systems/stat_engine.dart';

void main() {
  group('Item Relic System & Proc Tests', () {
    test('All 12 Core Relics are defined with valid properties', () {
      expect(allItems.length, 12);
      expect(itemsById.length, 12);

      for (final item in allItems) {
        expect(item.id.isNotEmpty, isTrue);
        expect(item.name.isNotEmpty, isTrue);
        expect(item.description.isNotEmpty, isTrue);
        expect(item.rarity, isNotNull);
        expect(item.maxStacks, greaterThan(0));
      }
    });

    test('StatEngine stacks passive relic stat bonuses additively', () {
      final runState = RunState(character: kitsuneSpireDef);
      final initialStats = StatEngine.recompute(runState);

      // Add 2 Lucky Clovers (+0.10 luck each = +0.20)
      runState.addItem('lucky_clover');
      runState.addItem('lucky_clover');

      // Add 1 Iron Plating (+25 maxHp, +5 armor)
      runState.addItem('iron_plating');

      // Add 1 Heavy Springs (+0.35 knockback)
      runState.addItem('heavy_springs');

      // Add 1 Spiky Bulwark (Armor * 2.0 Thorns = 5 * 2 = 10 thorns)
      runState.addItem('spiky_bulwark');

      // Add 1 Cursed Idol (+0.20 curse, +0.50 xpGain)
      runState.addItem('cursed_idol');

      final upgradedStats = StatEngine.recompute(runState);

      expect(upgradedStats.luck, closeTo(initialStats.luck + 0.20, 0.001));
      expect(upgradedStats.maxHp, closeTo(initialStats.maxHp + 25.0, 0.001));
      expect(upgradedStats.armor, closeTo(5.0, 0.001));
      expect(upgradedStats.knockback, closeTo(0.35, 0.001));
      expect(upgradedStats.thorns, closeTo(10.0, 0.001));
      expect(upgradedStats.curse, closeTo(0.20, 0.001));
      expect(upgradedStats.xpGain, closeTo(0.50, 0.001));
    });

    test('DamageResolver procs Combustion Elixir on critical hits', () {
      const stats = StatSheet(
        critChance: 1.0, // Guaranteed crit
        critDamage: 2.0,
        damage: 1.0,
      );

      // 0 stacks -> no combustion
      final hit0 = DamageResolver.resolveOutgoingHit(
        weaponDamage: 20.0,
        weaponKnockback: 5.0,
        stats: stats,
        rng: math.Random(42),
        combustionCount: 0,
      );
      expect(hit0.isCrit, isTrue);
      expect(hit0.combustionDetonation, isFalse);

      // 3 stacks -> 100% combustion chance (0.40 * 3 = 1.2 clamped to 1.0)
      final hitProc = DamageResolver.resolveOutgoingHit(
        weaponDamage: 20.0,
        weaponKnockback: 5.0,
        stats: stats,
        rng: math.Random(42),
        combustionCount: 3,
      );
      expect(hitProc.isCrit, isTrue);
      expect(hitProc.combustionDetonation, isTrue);
      expect(hitProc.combustionDamage, closeTo(hitProc.damage * 0.50, 0.001));
    });

    test('DamageResolver procs Shatter Crystal freeze chance', () {
      const stats = StatSheet(critChance: 0.0);

      // 10 stacks -> 100% freeze chance (0.15 * 10 = 1.5 clamped to 1.0)
      final hit = DamageResolver.resolveOutgoingHit(
        weaponDamage: 10.0,
        weaponKnockback: 5.0,
        stats: stats,
        rng: math.Random(1),
        shatterCount: 10,
      );
      expect(hit.isFrozen, isTrue);
    });

    test('DamageResolver procs Bloodfang Dagger heal on critical hit', () {
      const stats = StatSheet(
        critChance: 1.0,
        critDamage: 2.0,
      );

      // 5 stacks -> 100% heal chance (0.20 * 5 = 1.0)
      final hit = DamageResolver.resolveOutgoingHit(
        weaponDamage: 10.0,
        weaponKnockback: 5.0,
        stats: stats,
        rng: math.Random(1),
        bloodfangCount: 5,
      );
      expect(hit.healAmount, 1.0);
    });

    test('DamageResolver procs Mask of Ruin thorns explosion on incoming hit', () {
      const stats = StatSheet(
        armor: 50.0,
        thorns: 20.0,
      );

      // 2 stacks -> 100% thorns explosion chance (0.50 * 2 = 1.0)
      final hit = DamageResolver.resolveIncomingHit(
        rawDamage: 15.0,
        stats: stats,
        rng: math.Random(1),
        maskOfRuinCount: 2,
      );
      expect(hit.thornsDetonation, isTrue);
      expect(hit.thornsExplosionDamage, closeTo(10.0, 0.001)); // 50% of 20 thorns
    });

    test('rollChestRelic rolls from restricted high tier pool for golden chests', () {
      final rng = math.Random(12345);
      for (int i = 0; i < 50; i++) {
        final relic = rollChestRelic(rng, isGolden: true, luck: 0.5);
        expect(
          relic.rarity == Rarity.rare ||
              relic.rarity == Rarity.epic ||
              relic.rarity == Rarity.legendary,
          isTrue,
        );
      }
    });
  });
}
