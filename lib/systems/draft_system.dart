import 'dart:math' as math;

import '../data/tomes.dart';
import '../data/weapons.dart';
import '../models/draft_card.dart';
import '../models/rarity.dart';
import '../models/run_state.dart';
import '../models/tome_def.dart';
import '../models/weapon_def.dart';
import 'stat_engine.dart';

/// Generates 3 distinct upgrade cards upon level-up and rolls Luck-weighted rarity tiers.
class DraftSystem {
  DraftSystem({math.Random? rng}) : rng = rng ?? math.Random();

  final math.Random rng;

  /// Rolls a rarity tier using the Megabonk / Bonkhold Luck formula:
  /// weight(tier) = baseWeight(tier) * (1 + luck)^tierIndex
  Rarity rollRarity(double luck) {
    final double safeLuck = math.max(0.0, luck);
    final List<double> weights = <double>[];
    double totalWeight = 0.0;

    for (int i = 0; i < Rarity.values.length; i++) {
      final Rarity r = Rarity.values[i];
      final double w = (r.baseWeight * math.pow(1.0 + safeLuck, i)).toDouble();
      weights.add(w);
      totalWeight += w;
    }

    final double roll = rng.nextDouble() * totalWeight;
    double cumulative = 0.0;

    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (roll <= cumulative) {
        return Rarity.values[i];
      }
    }

    return Rarity.common;
  }

  /// Generates 3 distinct draft choices based on currently equipped weapons and tomes.
  List<DraftCard> generateDraft(RunState runState) {
    final List<DraftCard> candidates = <DraftCard>[];
    final Set<String> usedIds = <String>{};
    final double luck = runState.stats.luck;

    // 1. Weapon upgrades for currently equipped weapons
    for (int i = 0; i < runState.weapons.length; i++) {
      final EquippedWeapon eq = runState.weapons[i];
      if (usedIds.contains(eq.def.id)) continue;

      final Rarity rarity = rollRarity(luck);
      final WeaponStatUpgrade upgrade = eq.def.upgradePool[rng.nextInt(eq.def.upgradePool.length)];
      final double delta = (upgrade.baseIncrement * rarity.multiplier);

      double before = 0.0;
      switch (upgrade.statKey) {
        case 'damage':
          before = eq.stats.damage;
          break;
        case 'cooldown':
          before = eq.stats.cooldown;
          break;
        case 'radius':
          before = eq.stats.radius;
          break;
        case 'projectiles':
          before = eq.stats.projectiles.toDouble();
          break;
        case 'pierce':
          before = eq.stats.pierce.toDouble();
          break;
      }
      final double after = upgrade.statKey == 'cooldown'
          ? math.max(0.08, before + delta)
          : before + delta;

      candidates.add(
        DraftCard(
          type: DraftCardType.weaponUpgrade,
          id: eq.def.id,
          title: eq.def.name,
          subtitle: 'Weapon Upgrade (Lv ${eq.level} -> ${eq.level + 1})',
          description: '+${delta.toStringAsFixed(1)} ${upgrade.name}',
          rarity: rarity,
          statKey: upgrade.statKey,
          beforeValue: before,
          afterValue: after,
          deltaDescription: '${upgrade.name}: ${before.toStringAsFixed(1)} -> ${after.toStringAsFixed(1)}',
          targetWeaponIndex: i,
        ),
      );
    }

    // 2. New weapons if slots available (< 4)
    if (runState.weapons.length < 4) {
      final ownedWeaponIds = runState.weapons.map((w) => w.def.id).toSet();
      for (final def in allWeapons) {
        if (!ownedWeaponIds.contains(def.id) && !usedIds.contains(def.id)) {
          candidates.add(
            DraftCard(
              type: DraftCardType.newWeapon,
              id: def.id,
              title: def.name,
              subtitle: 'New Weapon (Slot ${runState.weapons.length + 1}/4)',
              description: def.description,
              rarity: Rarity.common, // New weapons start at base stats
              deltaDescription: 'Damage: ${def.baseStats.damage.toStringAsFixed(0)} | CD: ${def.baseStats.cooldown.toStringAsFixed(2)}s',
            ),
          );
        }
      }
    }

    // 3. Tome upgrades for currently equipped tomes
    for (final tome in runState.tomes) {
      if (usedIds.contains(tome.def.id) || tome.level >= tome.def.maxLevel) continue;
      final Rarity rarity = rollRarity(luck);
      final double delta = (tome.def.baseIncrement * rarity.multiplier);
      final double before = tome.totalBonus;
      final double after = before + delta;

      final String deltaStr = tome.def.isMultiplier
          ? '+${(delta * 100).toStringAsFixed(0)}%'
          : '+${delta.toStringAsFixed(1)}';

      candidates.add(
        DraftCard(
          type: DraftCardType.tomeUpgrade,
          id: tome.def.id,
          title: tome.def.name,
          subtitle: 'Tome Upgrade (Lv ${tome.level} -> ${tome.level + 1})',
          description: '$deltaStr ${tome.def.name}',
          rarity: rarity,
          statKey: tome.def.statKey,
          beforeValue: before,
          afterValue: after,
          deltaDescription: '${tome.def.name} ($deltaStr)',
        ),
      );
    }

    // 4. New tomes if slots available (< 4)
    if (runState.tomes.length < 4) {
      final ownedTomeIds = runState.tomes.map((t) => t.def.id).toSet();
      for (final def in allTomes) {
        if (!ownedTomeIds.contains(def.id) && !usedIds.contains(def.id)) {
          final Rarity rarity = rollRarity(luck);
          final double delta = (def.baseIncrement * rarity.multiplier);
          final String deltaStr = def.isMultiplier
              ? '+${(delta * 100).toStringAsFixed(0)}%'
              : '+${delta.toStringAsFixed(1)}';

          candidates.add(
            DraftCard(
              type: DraftCardType.newTome,
              id: def.id,
              title: def.name,
              subtitle: 'New Tome (Slot ${runState.tomes.length + 1}/4)',
              description: def.description,
              rarity: rarity,
              statKey: def.statKey,
              afterValue: delta,
              deltaDescription: '$deltaStr to ${def.statKey}',
            ),
          );
        }
      }
    }

    // Fallback if candidates pool is exhausted
    if (candidates.isEmpty) {
      return [
        const DraftCard(
          type: DraftCardType.fallbackHeal,
          id: 'field_repair',
          title: 'Field Repairs',
          subtitle: 'Emergency Restoration',
          description: 'Restores 25% of Bastion maximum HP.',
          rarity: Rarity.common,
          deltaDescription: '+25% Structural HP',
        ),
      ];
    }

    // Shuffle and pick up to 3 distinct cards
    candidates.shuffle(rng);
    final List<DraftCard> result = <DraftCard>[];
    final Set<String> pickedIds = <String>{};

    for (final card in candidates) {
      if (pickedIds.add(card.id)) {
        result.add(card);
        if (result.length == 3) break;
      }
    }

    return result;
  }

  /// Applies the selected card to the player's run state and recomputes stats.
  void applyCard(DraftCard card, RunState runState) {
    switch (card.type) {
      case DraftCardType.newWeapon:
        final WeaponDef def = allWeapons.firstWhere((w) => w.id == card.id);
        runState.weapons.add(
          EquippedWeapon(def: def, stats: def.baseStats),
        );
        break;

      case DraftCardType.weaponUpgrade:
        final int index = card.targetWeaponIndex ??
            runState.weapons.indexWhere((w) => w.def.id == card.id);
        if (index != -1) {
          final eq = runState.weapons[index];
          eq.level++;
          final statKey = card.statKey;
          final after = card.afterValue ?? 0.0;
          switch (statKey) {
            case 'damage':
              eq.stats = eq.stats.copyWith(damage: after);
              break;
            case 'cooldown':
              eq.stats = eq.stats.copyWith(cooldown: after);
              break;
            case 'radius':
              eq.stats = eq.stats.copyWith(radius: after);
              break;
            case 'projectiles':
              eq.stats = eq.stats.copyWith(projectiles: after.round());
              break;
            case 'pierce':
              eq.stats = eq.stats.copyWith(pierce: after.round());
              break;
          }
        }
        break;

      case DraftCardType.newTome:
        final TomeDef def = allTomes.firstWhere((t) => t.id == card.id);
        runState.tomes.add(
          EquippedTome(
            def: def,
            level: 1,
            totalBonus: card.afterValue ?? def.baseIncrement,
          ),
        );
        break;

      case DraftCardType.tomeUpgrade:
        final tome = runState.tomes.firstWhere((t) => t.def.id == card.id);
        tome.level++;
        tome.totalBonus = card.afterValue ?? tome.totalBonus;
        break;

      case DraftCardType.fallbackHeal:
        runState.heal(runState.maxHp.value * 0.25);
        break;
    }

    // Recompute stats through StatEngine
    StatEngine.recompute(runState);
  }
}
