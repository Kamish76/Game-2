import 'dart:math' as math;

import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/data/tomes.dart';
import 'package:bonkhold/data/weapons.dart';
import 'package:bonkhold/models/draft_card.dart';
import 'package:bonkhold/models/rarity.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/systems/draft_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraftSystem', () {
    late DraftSystem draftSystem;
    late RunState runState;

    setUp(() {
      draftSystem = DraftSystem(rng: math.Random(42));
      runState = RunState(character: kitsuneSpireDef);
      runState.weapons.add(
        EquippedWeapon(def: emberStaffDef, stats: emberStaffDef.baseStats),
      );
    });

    test('generates up to 3 distinct cards', () {
      final cards = draftSystem.generateDraft(runState);
      expect(cards.length, inInclusiveRange(1, 3));

      final ids = cards.map((c) => c.id).toSet();
      expect(ids.length, cards.length, reason: 'Offered cards must have distinct IDs');
    });

    test('applies weapon upgrade and increments weapon level and stat', () {
      const card = DraftCard(
        type: DraftCardType.weaponUpgrade,
        id: 'ember_staff',
        title: 'Ember Staff',
        subtitle: 'Upgrade',
        description: '+3 Damage',
        rarity: Rarity.rare,
        statKey: 'damage',
        beforeValue: 14.0,
        afterValue: 18.2,
      );

      draftSystem.applyCard(card, runState);
      expect(runState.weapons.first.level, 2);
      expect(runState.weapons.first.stats.damage, closeTo(18.2, 0.01));
    });

    test('respects weapon slot limit of 4', () {
      // Fill all 4 slots
      for (final def in allWeapons) {
        if (!runState.weapons.any((w) => w.def.id == def.id)) {
          runState.weapons.add(EquippedWeapon(def: def, stats: def.baseStats));
        }
      }
      expect(runState.weapons.length, 4);

      final cards = draftSystem.generateDraft(runState);
      final newWeaponCards = cards.where((c) => c.type == DraftCardType.newWeapon);
      expect(newWeaponCards, isEmpty);
    });

    test('respects tome slot limit of 4', () {
      // Fill all 4 tome slots
      for (int i = 0; i < 4; i++) {
        runState.tomes.add(EquippedTome(def: allTomes[i], level: 1, totalBonus: 0.1));
      }
      expect(runState.tomes.length, 4);

      final cards = draftSystem.generateDraft(runState);
      final newTomeCards = cards.where((c) => c.type == DraftCardType.newTome);
      expect(newTomeCards, isEmpty);
    });

    test('reroll decrements charges and generates new draft', () {
      expect(runState.rerollCharges, 2);
      final cards = draftSystem.rerollDraft(runState);
      expect(runState.rerollCharges, 1);
      expect(cards.isNotEmpty, isTrue);
    });

    test('skip decrements charges and applies fallback heal', () {
      expect(runState.skipCharges, 2);
      runState.hp.value = 50.0;
      draftSystem.skipDraft(runState);
      expect(runState.skipCharges, 1);
      expect(runState.hp.value, 75.0); // +25% maxHp (25 points)
    });

    test('banish decrements charges and permanently removes item from draft candidates', () {
      expect(runState.banishCharges, 1);
      const String targetTomeId = 'damage_tome';

      draftSystem.banishItem(targetTomeId, runState);
      expect(runState.banishCharges, 0);
      expect(runState.banishedIds.contains(targetTomeId), isTrue);

      // Repeated drafts should never contain the banished item
      for (int i = 0; i < 20; i++) {
        final cards = draftSystem.generateDraft(runState);
        expect(cards.any((c) => c.id == targetTomeId), isFalse);
      }
    });

    test('all 8 global Tomes are defined and present in registry', () {
      expect(allTomes.length, 8);
      final tomeIds = allTomes.map((t) => t.id).toSet();
      expect(
        tomeIds,
        containsAll([
          'damage_tome',
          'speed_tome',
          'quantity_tome',
          'size_tome',
          'luck_tome',
          'armor_tome',
          'xp_tome',
          'cursed_tome',
        ]),
      );
    });

    test('rarity distribution over 100k rolls matches formula within +/- 1%', () {
      final counts = <Rarity, int>{};
      for (final r in Rarity.values) {
        counts[r] = 0;
      }

      const int trials = 100000;
      for (int i = 0; i < trials; i++) {
        final r = draftSystem.rollRarity(0.0);
        counts[r] = counts[r]! + 1;
      }

      expect(counts[Rarity.common]! / trials, closeTo(0.60, 0.01));
      expect(counts[Rarity.uncommon]! / trials, closeTo(0.25, 0.01));
      expect(counts[Rarity.rare]! / trials, closeTo(0.10, 0.01));
      expect(counts[Rarity.epic]! / trials, closeTo(0.04, 0.01));
      expect(counts[Rarity.legendary]! / trials, closeTo(0.01, 0.005));
    });
  });
}

