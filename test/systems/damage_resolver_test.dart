import 'dart:math' as math;

import 'package:bonkhold/models/stat_sheet.dart';
import 'package:bonkhold/systems/damage_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRandom implements math.Random {
  MockRandom(this._next);
  final double _next;

  @override
  double nextDouble() => _next;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => true;
}

void main() {
  group('DamageResolver', () {
    test('outgoing hit applies crit multiplier when roll succeeds', () {
      final stats = const StatSheet(
        damage: 1.5,
        critChance: 0.5,
        critDamage: 2.0,
      );

      // Roll 0.1 < 0.5 -> crit!
      final critResult = DamageResolver.resolveOutgoingHit(
        weaponDamage: 10.0,
        weaponKnockback: 5.0,
        stats: stats,
        rng: MockRandom(0.1),
      );
      expect(critResult.isCrit, isTrue);
      expect(critResult.damage, 10.0 * 1.5 * 2.0); // 30.0

      // Roll 0.8 >= 0.5 -> no crit
      final nonCritResult = DamageResolver.resolveOutgoingHit(
        weaponDamage: 10.0,
        weaponKnockback: 5.0,
        stats: stats,
        rng: MockRandom(0.8),
      );
      expect(nonCritResult.isCrit, isFalse);
      expect(nonCritResult.damage, 10.0 * 1.5); // 15.0
    });

    test('incoming hit deflects when roll succeeds', () {
      final stats = const StatSheet(
        evasion: 100.0, // 100 / (100 + 100) = 50% deflect chance
        thorns: 5.0,
      );

      final deflectResult = DamageResolver.resolveIncomingHit(
        rawDamage: 20.0,
        stats: stats,
        rng: MockRandom(0.2), // < 0.5
      );
      expect(deflectResult.isDeflected, isTrue);
      expect(deflectResult.finalDamage, 0.0);
      expect(deflectResult.thornsDamage, 5.0);
    });

    test('armor reduces damage according to hyperbolic formula', () {
      final stats = const StatSheet(
        armor: 100.0, // 100 / (100 + 100) = 50% reduction
      );

      final hitResult = DamageResolver.resolveIncomingHit(
        rawDamage: 20.0,
        stats: stats,
        rng: MockRandom(0.9),
      );
      expect(hitResult.isDeflected, isFalse);
      expect(hitResult.finalDamage, 10.0); // 20 * (1 - 0.5)
    });

    test('minimum damage is clamped to 1.0', () {
      final stats = const StatSheet(
        armor: 999.0, // ~90% reduction
      );

      final hitResult = DamageResolver.resolveIncomingHit(
        rawDamage: 2.0,
        stats: stats,
        rng: MockRandom(0.9),
      );
      expect(hitResult.finalDamage, 1.0);
    });
  });
}
