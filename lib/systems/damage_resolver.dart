import 'dart:math' as math;

import '../models/stat_sheet.dart';

class OutgoingHitResult {
  const OutgoingHitResult({
    required this.damage,
    required this.isCrit,
    required this.knockback,
    this.combustionDetonation = false,
    this.combustionDamage = 0.0,
    this.isFrozen = false,
    this.healAmount = 0.0,
  });

  final double damage;
  final bool isCrit;
  final double knockback;
  final bool combustionDetonation;
  final double combustionDamage;
  final bool isFrozen;
  final double healAmount;
}

class IncomingHitResult {
  const IncomingHitResult({
    required this.finalDamage,
    required this.isDeflected,
    required this.thornsDamage,
    this.thornsDetonation = false,
    this.thornsExplosionDamage = 0.0,
  });

  final double finalDamage;
  final bool isDeflected;
  final double thornsDamage;
  final bool thornsDetonation;
  final double thornsExplosionDamage;
}

/// Pure math resolver for combat interactions.
abstract final class DamageResolver {
  /// Resolves outgoing damage from a weapon hit.
  static OutgoingHitResult resolveOutgoingHit({
    required double weaponDamage,
    required double weaponKnockback,
    required StatSheet stats,
    required math.Random rng,
    int combustionCount = 0,
    int shatterCount = 0,
    int bloodfangCount = 0,
  }) {
    final bool isCrit = rng.nextDouble() < stats.critChance;
    final double critMult = isCrit ? stats.critDamage : 1.0;
    final double finalDamage = weaponDamage * stats.damage * critMult;
    final double finalKnockback = weaponKnockback * (1.0 + stats.knockback);

    bool combustionDetonation = false;
    double combustionDamage = 0.0;
    if (isCrit && combustionCount > 0) {
      final double combustionChance = (0.40 * combustionCount).clamp(0.0, 1.0);
      if (rng.nextDouble() < combustionChance) {
        combustionDetonation = true;
        combustionDamage = finalDamage * 0.50;
      }
    }

    bool isFrozen = false;
    if (shatterCount > 0) {
      final double freezeChance = (0.15 * shatterCount).clamp(0.0, 1.0);
      if (rng.nextDouble() < freezeChance) {
        isFrozen = true;
      }
    }

    double healAmount = 0.0;
    if (isCrit && bloodfangCount > 0) {
      final double healChance = (0.20 * bloodfangCount).clamp(0.0, 1.0);
      if (rng.nextDouble() < healChance) {
        healAmount = 1.0;
      }
    }

    return OutgoingHitResult(
      damage: finalDamage,
      isCrit: isCrit,
      knockback: finalKnockback,
      combustionDetonation: combustionDetonation,
      combustionDamage: combustionDamage,
      isFrozen: isFrozen,
      healAmount: healAmount,
    );
  }

  /// Resolves incoming damage from an enemy attacking the Bastion.
  static IncomingHitResult resolveIncomingHit({
    required double rawDamage,
    required StatSheet stats,
    required math.Random rng,
    int maskOfRuinCount = 0,
  }) {
    bool thornsDetonation = false;
    double thornsExplosionDamage = 0.0;
    if (stats.thorns > 0 && maskOfRuinCount > 0) {
      final double explodeChance = (0.50 * maskOfRuinCount).clamp(0.0, 1.0);
      if (rng.nextDouble() < explodeChance) {
        thornsDetonation = true;
        thornsExplosionDamage = stats.thorns * 0.50;
      }
    }

    // 1. Deflection check: E / (E + 100)
    if (stats.evasion > 0) {
      final double deflectChance = stats.evasion / (stats.evasion + 100.0);
      if (rng.nextDouble() < deflectChance) {
        return IncomingHitResult(
          finalDamage: 0.0,
          isDeflected: true,
          thornsDamage: stats.thorns,
          thornsDetonation: thornsDetonation,
          thornsExplosionDamage: thornsExplosionDamage,
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
      thornsDetonation: thornsDetonation,
      thornsExplosionDamage: thornsExplosionDamage,
    );
  }
}
