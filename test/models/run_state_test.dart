import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/models/stat_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunState Level Scaling and XP Progression', () {
    late RunState runState;

    setUp(() {
      runState = RunState(character: kitsuneSpireDef);
    });

    tearDown(() {
      runState.dispose();
    });

    test('initial state begins at level 1 with 5 required XP', () {
      expect(runState.level.value, 1);
      expect(runState.currentXp.value, 0);
      expect(runState.requiredXp.value, 5);
      expect(runState.xpProgress.value, 0.0);
      expect(runState.pendingLevelUps, 0);
    });

    test('xpForLevel formula produces tuned early-game thresholds', () {
      // Level 1 -> 2: 5 XP
      expect(RunState.xpForLevel(1), 5);
      // Level 2 -> 3: 5 + 2*1 + 0.25*1 = 7.25 -> 7 XP
      expect(RunState.xpForLevel(2), 7);
      // Level 3 -> 4: 5 + 2*2 + 0.25*4 = 10 XP
      expect(RunState.xpForLevel(3), 10);
      // Level 4 -> 5: 5 + 2*3 + 0.25*9 = 13.25 -> 13 XP
      expect(RunState.xpForLevel(4), 13);
      // Level 5 -> 6: 5 + 2*4 + 0.25*16 = 17 XP
      expect(RunState.xpForLevel(5), 17);
      // Level 6 -> 7: 5 + 2*5 + 0.25*25 = 21.25 -> 21 XP
      expect(RunState.xpForLevel(6), 21);
      // Level 7 -> 8: 5 + 2*6 + 0.25*36 = 26 XP
      expect(RunState.xpForLevel(7), 26);
      // Level 8 -> 9: 5 + 2*7 + 0.25*49 = 31.25 -> 31 XP
      expect(RunState.xpForLevel(8), 31);
      // Level 9 -> 10: 5 + 2*8 + 0.25*64 = 37 XP
      expect(RunState.xpForLevel(9), 37);
      // Level 10 -> 11: 5 + 2*9 + 0.25*81 = 43.25 -> 43 XP
      expect(RunState.xpForLevel(10), 43);
      // Level 11 -> 12: 5 + 2*10 + 0.25*100 = 50 XP
      expect(RunState.xpForLevel(11), 50);
    });

    test('reaches level 11 under 250 cumulative XP, allowing high power by minute 3', () {
      int cumulativeXp = 0;
      for (int lvl = 1; lvl <= 10; lvl++) {
        cumulativeXp += RunState.xpForLevel(lvl);
      }
      // Cumulative XP for level 1 -> 11:
      // 5 + 7 + 10 + 13 + 17 + 21 + 26 + 31 + 37 + 43 = 210 XP
      expect(cumulativeXp, 210);
      expect(cumulativeXp, lessThanOrEqualTo(250),
          reason: 'Player should comfortably reach level 11 before 3m mark');
    });

    test('addXp increments level and queues pendingLevelUps', () {
      runState.addXp(3);
      expect(runState.level.value, 1);
      expect(runState.currentXp.value, 3);
      expect(runState.requiredXp.value, 5);
      expect(runState.xpProgress.value, closeTo(3.0 / 5.0, 0.001));
      expect(runState.pendingLevelUps, 0);

      // Add 3 more XP (total 6 XP). Exceeds level 1 requirement (5), reaching level 2 with 1 leftover XP
      runState.addXp(3);
      expect(runState.level.value, 2);
      expect(runState.currentXp.value, 1);
      expect(runState.requiredXp.value, 7); // Level 2 requires 7 XP
      expect(runState.xpProgress.value, closeTo(1.0 / 7.0, 0.001));
      expect(runState.pendingLevelUps, 1);
    });

    test('large XP chunk (e.g., 25 XP Greater Shard) triggers multiple level-ups correctly', () {
      // 25 XP from elite Greater Shard:
      // Level 1 -> 2 (needs 5 XP, 20 remain)
      // Level 2 -> 3 (needs 7 XP, 13 remain)
      // Level 3 -> 4 (needs 10 XP, 3 remain)
      // Level 4 requires 13 XP, current = 3
      runState.addXp(25);
      expect(runState.level.value, 4);
      expect(runState.pendingLevelUps, 3);
      expect(runState.currentXp.value, 3);
      expect(runState.requiredXp.value, 13);
    });

    test('xpGain stat increases XP collected from pickups', () {
      // Equip +50% XP Gain
      runState.stats = const StatSheet(xpGain: 0.50);

      // Collect 10 XP -> 10 * 1.5 = 15 XP
      runState.addXp(10);

      // Level 1 -> 2 (5 XP, 10 remain)
      // Level 2 -> 3 (7 XP, 3 remain)
      expect(runState.level.value, 3);
      expect(runState.pendingLevelUps, 2);
      expect(runState.currentXp.value, 3);
      expect(runState.requiredXp.value, 10);
    });

    test('reset clears XP progress and resets required XP to level 1', () {
      runState.addXp(50);
      expect(runState.level.value, greaterThan(1));

      runState.reset();
      expect(runState.level.value, 1);
      expect(runState.currentXp.value, 0);
      expect(runState.requiredXp.value, 5);
      expect(runState.xpProgress.value, 0.0);
      expect(runState.pendingLevelUps, 0);
    });
  });
}
