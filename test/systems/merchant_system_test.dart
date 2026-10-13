import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/traveling_merchant_component.dart';
import 'package:bonkhold/systems/merchant_director.dart';
import 'package:bonkhold/ui/overlays/merchant_overlay.dart';
import 'package:bonkhold/ui/overlays/overlay_ids.dart';

void main() {
  group('MerchantDirector Logic Tests', () {
    test('Schedules arrival at 180s intervals and respects active state', () {
      final director = MerchantDirector(initialArrival: 180.0, interval: 180.0);

      // Advance to 179s
      expect(director.update(179.0), isFalse);
      expect(director.isMerchantActive, isFalse);

      // Tick to 180s
      expect(director.update(1.0), isTrue);
      expect(director.isMerchantActive, isTrue);

      // Further ticks while active do not spawn another merchant
      expect(director.update(10.0), isFalse);
      expect(director.update(180.0), isFalse);

      // Depart
      director.onMerchantDeparted();
      expect(director.isMerchantActive, isFalse);

      // Advance to next 180s interval (360s total)
      expect(director.update(0.0), isTrue);
      expect(director.isMerchantActive, isTrue);
    });

    test('Reset clears elapsed time and merchant active state', () {
      final director = MerchantDirector(initialArrival: 180.0, interval: 180.0);
      director.update(180.0);
      expect(director.isMerchantActive, isTrue);

      director.reset();
      expect(director.elapsedSeconds, 0.0);
      expect(director.isMerchantActive, isFalse);
      expect(director.nextMerchantTime, 180.0);
    });
  });

  group('MerchantOverlay Widget Tests', () {
    testWidgets('Renders header, gold balance, tabs, and emergency repairs', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.runState.gold.value = 777;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('TRAVELING MERCHANT'), findsOneWidget);
      expect(find.text('777 G'), findsOneWidget);
      expect(find.text('RELIC MARKET'), findsOneWidget);
      expect(find.text('ALCHEMICAL FORGE'), findsOneWidget);
      expect(find.text('Emergency Field Repairs'), findsOneWidget);
      expect(find.text('RESUME COMBAT'), findsOneWidget);
    });

    testWidgets('Purchases relic with gold and disables button once bought', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.runState.gold.value = 500;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      expect(game.runState.ownedItems.isEmpty, isTrue);

      final anyPriceButtonFinder = find.byWidgetPredicate(
        (w) => w is ElevatedButton && (w.child is Text) && (w.child as Text).data!.contains(' G'),
      );

      // Tap the first relic price button (skip emergency repair 40G if needed)
      final buttons = tester.widgetList<ElevatedButton>(anyPriceButtonFinder).toList();
      expect(buttons.length, greaterThanOrEqualTo(2)); // Repairs + at least 1 relic

      // The last button in the list of G buttons will be a relic
      await tester.tap(anyPriceButtonFinder.last);
      await tester.pump();

      expect(game.runState.ownedItems.isNotEmpty, isTrue);
      expect(game.runState.gold.value, lessThan(500));
      expect(find.text('BOUGHT'), findsOneWidget);
    });

    testWidgets('Emergency repair restores 25% max HP and deducts 40 gold', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.runState.gold.value = 100;
      game.runState.hp.value = 50.0; // Damaged Bastion

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, '40 G'));
      await tester.pump();

      expect(game.runState.gold.value, 60);
      expect(game.runState.hp.value, 75.0); // 50 + 25% of 100 = 75
    });

    testWidgets('Alchemical Forge allows relic sacrifice and transmutation', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.runState.gold.value = 100;
      // Add combustion elixir to inventory
      game.runState.addItem('combustion_elixir');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      // Switch to Forge tab
      await tester.tap(find.text('ALCHEMICAL FORGE'));
      await tester.pumpAndSettle();

      expect(find.text('Alchemical Transmutation (Forge)'), findsOneWidget);

      // Open dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select Combustion Elixir
      final itemFinder = find.textContaining('Combustion Elixir').last;
      await tester.tap(itemFinder);
      await tester.pumpAndSettle();

      // Tap Transmute
      final transmuteBtnFinder = find.widgetWithText(ElevatedButton, 'TRANSMUTE (Cost: 50 G)');
      expect(transmuteBtnFinder, findsOneWidget);
      await tester.tap(transmuteBtnFinder);
      await tester.pumpAndSettle();

      expect(game.runState.gold.value, 50); // 100 - 50 = 50
      expect(find.textContaining('Transmuted Combustion Elixir'), findsOneWidget);
    });

    testWidgets('Resume combat button closes overlay and unpauses game', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.runState.isPaused = true;
      game.overlays.add(OverlayIds.merchant);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MerchantOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('RESUME COMBAT'));
      await tester.pump();

      expect(game.runState.isPaused, isFalse);
      expect(game.overlays.isActive(OverlayIds.merchant), isFalse);
    });
  });

  group('TravelingMerchantComponent Flame Tests', () {
    testWithGame<BonkholdGame>(
      'Merchant approaches Bastion, parks for duration, then departs arena',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Spawn merchant at (80, 0)
        game.spawnMerchant(x: 80.0, y: 0.0);
        await game.ready();

        expect(game.activeMerchant, isNotNull);
        final merchant = game.activeMerchant!;
        expect(merchant.state, MerchantState.arriving);

        // Advance ticks to walk inward towards Bastion (dockRadius = 38.0)
        for (int i = 0; i < 30; i++) {
          game.runState.isPaused = false;
          game.runState.pendingLevelUps = 0;
          game.update(0.05); // 1.5s * 55px/s = ~82px
        }

        expect(merchant.state, MerchantState.parked);
        expect(merchant.position.x, closeTo(38.0, 1.0));

        // Advance 15s to elapse parking window
        for (int i = 0; i < 320; i++) {
          game.runState.isPaused = false;
          game.runState.pendingLevelUps = 0;
          game.update(0.05);
        }

        expect(merchant.state, MerchantState.departing);

        // Advance ticks to walk past 180px departure distance
        for (int i = 0; i < 100; i++) {
          game.runState.isPaused = false;
          game.runState.pendingLevelUps = 0;
          game.update(0.05);
        }
        await game.ready();

        // Merchant despawns cleanly
        expect(game.activeMerchant, isNull);
        expect(game.merchantDirector.isMerchantActive, isFalse);
      },
    );

    testWithGame<BonkholdGame>(
      'Tapping merchant pauses game and opens merchant overlay',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        game.spawnMerchant(x: 38.0, y: 0.0);
        await game.ready();

        final merchant = game.activeMerchant!;
        // Force state to parked
        merchant.state = MerchantState.parked;

        // Simulate tap down event
        merchant.onTapDown(
          TapDownEvent(
            1,
            game,
            TapDownDetails(),
          ),
        );

        expect(game.runState.isPaused, isTrue);
        expect(game.overlays.isActive(OverlayIds.merchant), isTrue);
      },
    );
  });
}
