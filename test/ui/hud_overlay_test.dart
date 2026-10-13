import 'package:bonkhold/data/tomes.dart';
import 'package:bonkhold/data/weapons.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/systems/stat_engine.dart';
import 'package:bonkhold/ui/overlays/hud_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HudOverlay Widget Tests', () {
    testWidgets(
      'HudOverlay renders XP bar, Level, HP bar, and equipment trays with non-zero dimensions',
      (tester) async {
        final game = BonkholdGame();
        // Trigger onLoad to initialize runState and dependencies
        game.onLoad();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HudOverlay(game: game),
            ),
          ),
        );
        await tester.pump();

        // Level and XP bar text
        expect(find.text('LVL 1'), findsOneWidget);

        // Bastion HP bar text
        expect(find.text('BASTION HP: 100 / 100'), findsOneWidget);

        // Top counter elements
        expect(find.byIcon(Icons.pause), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
        expect(find.byIcon(Icons.flash_on), findsOneWidget);
        expect(find.byIcon(Icons.monetization_on), findsOneWidget);

        // 4 Weapon slots
        expect(find.text('W1: Ember L1'), findsOneWidget);
        expect(find.text('W2: --'), findsOneWidget);
        expect(find.text('W3: --'), findsOneWidget);
        expect(find.text('W4: --'), findsOneWidget);

        // 4 Tome slots
        expect(find.text('T1: --'), findsOneWidget);
        expect(find.text('T2: --'), findsOneWidget);
        expect(find.text('T3: --'), findsOneWidget);
        expect(find.text('T4: --'), findsOneWidget);

        // Verify widgets have positive non-zero size
        final xpBarFinder = find.text('LVL 1');
        final xpSize = tester.getSize(xpBarFinder);
        expect(xpSize.width, greaterThan(0));
        expect(xpSize.height, greaterThan(0));

        final hpBarFinder = find.text('BASTION HP: 100 / 100');
        final hpSize = tester.getSize(hpBarFinder);
        expect(hpSize.width, greaterThan(0));
        expect(hpSize.height, greaterThan(0));
      },
    );

    testWidgets(
      'Displays Shield indicator when Bastion has active shield integrity',
      (tester) async {
        final game = BonkholdGame();
        game.onLoad();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HudOverlay(game: game),
            ),
          ),
        );
        await tester.pump();

        // Initially no shield
        expect(find.textContaining('SHIELD'), findsNothing);

        // Grant shield
        game.runState.shield.value = 35.0;
        await tester.pump();

        expect(find.text('BASTION HP: 100 / 100  [SHIELD: 35]'), findsOneWidget);
      },
    );

    testWidgets(
      'Displays Boss health bar when activeBoss notifier is populated',
      (tester) async {
        final game = BonkholdGame();
        game.onLoad();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HudOverlay(game: game),
            ),
          ),
        );
        await tester.pump();

        // Initially no boss
        expect(find.textContaining('BOSS:'), findsNothing);

        // Spawn boss
        game.runState.activeBoss.value = const BossInfo(
          name: 'Yokai Goliath',
          hp: 800.0,
          maxHp: 1000.0,
        );
        await tester.pump();

        expect(find.text('BOSS: YOKAI GOLIATH (80%)'), findsOneWidget);

        // Boss defeated
        game.runState.activeBoss.value = null;
        await tester.pump();

        expect(find.textContaining('BOSS:'), findsNothing);
      },
    );

    testWidgets(
      'Equipment tray dynamically updates when new weapons or tomes are equipped',
      (tester) async {
        final game = BonkholdGame();
        game.onLoad();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HudOverlay(game: game),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('W1: Ember L1'), findsOneWidget);
        expect(find.text('W2: --'), findsOneWidget);
        expect(find.text('T1: --'), findsOneWidget);

        // Equip Revolver Battery into Slot 2
        game.runState.weapons.add(
          EquippedWeapon(def: revolverBatteryDef, stats: revolverBatteryDef.baseStats),
        );
        // Equip Tome of Might into Slot 1
        game.runState.tomes.add(
          EquippedTome(def: damageTome, level: 2, totalBonus: 0.16),
        );
        StatEngine.recompute(game.runState);
        await tester.pump();

        expect(find.text('W1: Ember L1'), findsOneWidget);
        expect(find.text('W2: Revolver L1'), findsOneWidget);
        expect(find.text('W3: --'), findsOneWidget);
        expect(find.text('T1: Might L2'), findsOneWidget);
        expect(find.text('T2: --'), findsOneWidget);
      },
    );
  });
}
