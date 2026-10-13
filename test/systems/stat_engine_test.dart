import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/data/tomes.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/systems/stat_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatEngine', () {
    test('computes base stats and scales Kitsune Luck with level', () {
      final runState = RunState(character: kitsuneSpireDef);
      final statsLvl1 = StatEngine.recompute(runState);

      expect(statsLvl1.luck, closeTo(0.15, 0.001));
      expect(statsLvl1.maxHp, 100.0);
      expect(statsLvl1.damage, 1.0);

      // Advance to level 5: +1.5% per level -> 4 levels gained * 0.015 = +0.06
      runState.level.value = 5;
      final statsLvl5 = StatEngine.recompute(runState);
      expect(statsLvl5.luck, closeTo(0.21, 0.001));
    });

    test('stacks tome bonuses additively', () {
      final runState = RunState(character: kitsuneSpireDef);
      runState.tomes.add(
        EquippedTome(def: damageTome, level: 2, totalBonus: 0.25),
      );
      runState.tomes.add(
        EquippedTome(def: armorTome, level: 1, totalBonus: 10.0),
      );

      final stats = StatEngine.recompute(runState);
      expect(stats.damage, closeTo(1.25, 0.001));
      expect(stats.armor, 10.0);
    });
  });
}
