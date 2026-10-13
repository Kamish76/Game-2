import 'dart:math' as math;

import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/systems/spawn_director.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Overtime and Score Calculation', () {
    late RunState runState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      runState = RunState(character: kitsuneSpireDef);
    });

    test('creditsPerSecond doubles (+100%) when t >= 900s (15:00 Overtime)', () {
      final double preOvertimeRate = SpawnDirector.creditsPerSecond(899.0, 0.0);
      final double overtimeRate = SpawnDirector.creditsPerSecond(900.0, 0.0);

      // Base formula at 900s without 2x multiplier
      final double expectedBaseAt900 = 0.8 * math.exp(0.008 * 900.0);
      expect(overtimeRate, closeTo(expectedBaseAt900 * 2.0, 0.1));
      expect(overtimeRate, greaterThan(preOvertimeRate * 1.9));
    });

    test('computeFinalScore computes correctly pre-overtime', () {
      runState.elapsedSeconds.value = 600.0; // 10 minutes
      runState.kills.value = 300;
      runState.bossKills.value = 2;
      runState.gold.value = 150;

      // Score = (600*10 + 300*5 + 2*250 + 150*2) * 1.0
      // = (6000 + 1500 + 500 + 300) = 8300
      expect(runState.computeFinalScore(), 8300);
    });

    test('computeFinalScore applies Overtime bonus multiplier when surviving past 15:00', () {
      runState.elapsedSeconds.value = 960.0; // 16 minutes (60s into Overtime)
      runState.kills.value = 500;
      runState.bossKills.value = 4;
      runState.gold.value = 200;

      // OvertimeBonus = 1.0 + (60 / 60) = 2.0
      // Base = (960*10 + 500*5 + 4*250 + 200*2) = (9600 + 2500 + 1000 + 400) = 13500
      // Score = 13500 * 2.0 = 27000
      expect(runState.computeFinalScore(), 27000);
    });

    test('persists high score cleanly via SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bonkhold_high_score', 12000);

      final retrieved = prefs.getInt('bonkhold_high_score');
      expect(retrieved, 12000);
    });
  });
}
