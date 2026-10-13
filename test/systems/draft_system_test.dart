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
  });
}
