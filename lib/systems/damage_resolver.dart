import 'dart:math' as math;

import '../models/stat_sheet.dart';

class OutgoingHitResult {
  const OutgoingHitResult({
    required this.damage,
    required this.isCrit,
    required this.knockback,
  });

  final double damage;
  final bool isCrit;
  final double knockback;
}

class IncomingHitResult {
  const IncomingHitResult({
    required this.finalDamage,
    required this.isDeflected,
    required this.thornsDamage,
  });

  final double finalDamage;
  final bool isDeflected;
  final double thornsDamage;
}

/// Pure math resolver for combat interactions.
abstract final class DamageResolver {
  /// Resolves outgoing damage from a weapon hit.
  static OutgoingHitResult resolveOutgoingHit({
    required double weaponDamage,
    required double weaponKnockback,
    required StatSheet stats,
    required math.Random rng,
  }) {
    final bool isCrit = rng.nextDouble() < stats.critChance;
    final double critMult = isCrit ? stats.critDamage : 1.0;
    final double finalDamage = weaponDamage * stats.damage * critMult;
    final double finalKnockback = weaponKnockback * (1.0 + stats.knockback);

    return OutgoingHitResult(
      damage: finalDamage,
      isCrit: isCrit,
      knockback: finalKnockback,
    );
  }

  /// Resolves incoming damage from an enemy attacking the Bastion.
  static IncomingHitResult resolveIncomingHit({
    required double rawDamage,
    required StatSheet stats,
    required math.Random rng,
  }) {
    // 1. Deflection check: E / (E + 100)
    if (stats.evasion > 0) {
      final double deflectChance = stats.evasion / (stats.evasion + 100.0);
      if (rng.nextDouble() < deflectChance) {
        return IncomingHitResult(
          finalDamage: 0.0,
          isDeflected: true,
          thornsDamage: stats.thorns,
        );
      }
    }

    // 2. Armor reduction: dmg * (1 - A / (A + 100))
    double reduced = rawDamage;
    if (stats.armor > 0) {
      final double armorReduction = stats.armor / (stats.armor + 100.0);
      reduced = rawDamage * (1.0 - armorReduction);
    }

    // 3. Minimum damage floor is 1.0
    final double finalDamage = math.max(1.0, reduced);

    return IncomingHitResult(
      finalDamage: finalDamage,
      isDeflected: false,
      thornsDamage: stats.thorns,
    );
  }
}
