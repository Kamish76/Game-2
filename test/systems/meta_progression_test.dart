import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/models/meta_talents.dart';
import 'package:bonkhold/models/run_state.dart';
import 'package:bonkhold/systems/meta_repository.dart';
import 'package:bonkhold/systems/stat_engine.dart';
import 'package:bonkhold/ui/overlays/game_over_overlay.dart';
import 'package:bonkhold/ui/overlays/overlay_ids.dart';
import 'package:bonkhold/ui/overlays/shrine_of_heritage_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await MetaRepository.instance.init();
    await MetaRepository.instance.clearAll();
  });

  group('Silver Currency Calculation Tests', () {
    test('computeSilverEarned matches exact design formula', () {
      final runState = RunState(character: kitsuneSpireDef);

      // t = 300.0s -> floor(300 * 0.2) = 60
      runState.elapsedSeconds.value = 300.0;
      // 5 elites -> 5 * 2 = 10
      for (int i = 0; i < 5; i++) {
        runState.addEliteKill();
      }
      // 2 bosses -> 2 * 10 = 20
      for (int i = 0; i < 2; i++) {
        runState.addBossKill();
      }

      // Total expected = 60 + 10 + 20 = 90
      expect(runState.computeSilverEarned(), 90);
    });

    test('computeSilverEarned handles zero stats cleanly', () {
      final runState = RunState(character: kitsuneSpireDef);
      expect(runState.computeSilverEarned(), 0);
    });
  });

  group('MetaRepository Persistence & Talent Upgrades', () {
    test('Adds, spends, and persists Silver currency', () async {
      final repo = MetaRepository.instance;
      expect(repo.silver, 0);

      await repo.addSilver(100);
      expect(repo.silver, 100);

      final spent = await repo.spendSilver(40);
      expect(spent, isTrue);
      expect(repo.silver, 60);

      final overspent = await repo.spendSilver(1000);
      expect(overspent, isFalse);
      expect(repo.silver, 60);
    });

    test('Upgrades talent rank and consumes correct silver amount', () async {
      final repo = MetaRepository.instance;
      // Reinforced Masonry base cost is 15
      await repo.addSilver(50);

      expect(repo.getTalentRank(MetaTalentType.reinforcedMasonry), 0);

      final upgraded = await repo.upgradeTalent(MetaTalentType.reinforcedMasonry);
      expect(upgraded, isTrue);
      expect(repo.getTalentRank(MetaTalentType.reinforcedMasonry), 1);
      expect(repo.silver, 35); // 50 - 15 = 35

      // Second rank cost: 15 + (1 * 10) = 25
      final upgraded2 = await repo.upgradeTalent(MetaTalentType.reinforcedMasonry);
      expect(upgraded2, isTrue);
      expect(repo.getTalentRank(MetaTalentType.reinforcedMasonry), 2);
      expect(repo.silver, 10); // 35 - 25 = 10

      // Third rank cost: 15 + (2 * 10) = 35 (cannot afford with 10 silver)
      final upgraded3 = await repo.upgradeTalent(MetaTalentType.reinforcedMasonry);
      expect(upgraded3, isFalse);
      expect(repo.getTalentRank(MetaTalentType.reinforcedMasonry), 2);
      expect(repo.silver, 10);
    });

    test('Prevents upgrading beyond talent max rank', () async {
      final repo = MetaRepository.instance;
      // Scribe's Wit max rank is 3
      await repo.addSilver(10000);

      for (int i = 0; i < 3; i++) {
        expect(await repo.upgradeTalent(MetaTalentType.scribesWit), isTrue);
      }
      expect(repo.getTalentRank(MetaTalentType.scribesWit), 3);

      // Attempt rank 4
      final overMax = await repo.upgradeTalent(MetaTalentType.scribesWit);
      expect(overMax, isFalse);
      expect(repo.getTalentRank(MetaTalentType.scribesWit), 3);
    });

    test('resetTalents refunds total spent silver and zeroes all ranks', () async {
      final repo = MetaRepository.instance;
      await repo.addSilver(200);

      // Upgrade Masonry (15) and Forged Iron (25) -> 40 spent
      await repo.upgradeTalent(MetaTalentType.reinforcedMasonry);
      await repo.upgradeTalent(MetaTalentType.forgedIron);
      expect(repo.silver, 160);

      await repo.resetTalents();
      expect(repo.silver, 200); // 160 + 40 refunded
      expect(repo.getTalentRank(MetaTalentType.reinforcedMasonry), 0);
      expect(repo.getTalentRank(MetaTalentType.forgedIron), 0);
    });

    test('getActiveStats correctly computes aggregate passive modifiers', () async {
      final repo = MetaRepository.instance;
      await repo.addSilver(10000);

      // 2 ranks Reinforced Masonry (+4% HP)
      await repo.upgradeTalent(MetaTalentType.reinforcedMasonry);
      await repo.upgradeTalent(MetaTalentType.reinforcedMasonry);

      // 3 ranks Forged Iron (+3 Armor)
      await repo.upgradeTalent(MetaTalentType.forgedIron);
      await repo.upgradeTalent(MetaTalentType.forgedIron);
      await repo.upgradeTalent(MetaTalentType.forgedIron);

      // 1 rank Golden Aura (+5% Gold)
      await repo.upgradeTalent(MetaTalentType.goldenAura);

      // 2 ranks Scribe's Wit (+2 Draft Charges)
      await repo.upgradeTalent(MetaTalentType.scribesWit);
      await repo.upgradeTalent(MetaTalentType.scribesWit);

      final stats = repo.getActiveStats();
      expect(stats.hpBonusPercent, closeTo(0.04, 0.0001));
      expect(stats.bonusArmor, 3.0);
      expect(stats.goldMultiplier, closeTo(1.05, 0.0001));
      expect(stats.extraDraftCharges, 2);
    });
  });

  group('StatEngine Meta-Talent Integration Tests', () {
    test('StatEngine applies meta-progression HP, Armor, Luck, and Draft charges', () {
      const meta = MetaProgressionStats(
        hpBonusPercent: 0.10, // +10% Max HP (110 on Kitsune 100 base)
        bonusArmor: 4.0,
        bonusLuck: 0.06,
        goldMultiplier: 1.15,
        extraDraftCharges: 2,
      );

      final runState = RunState(
        character: kitsuneSpireDef,
        metaStats: meta,
      );

      // Initial draft charges: 2 base + 2 meta = 4 reroll/skip, 1 base + 2 meta = 3 banish
      expect(runState.rerollCharges, 4);
      expect(runState.skipCharges, 4);
      expect(runState.banishCharges, 3);

      final stats = StatEngine.recompute(runState);
      expect(stats.maxHp, closeTo(110.0, 0.001));
      expect(runState.maxHp.value, closeTo(110.0, 0.001));
      expect(stats.armor, 4.0);
      expect(stats.luck, closeTo(kitsuneSpireDef.baseLuck + 0.06, 0.001));
    });
  });

  group('ShrineOfHeritageOverlay Widget Tests', () {
    testWidgets('Renders talent list, silver balance, and handles upgrades', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();

      await MetaRepository.instance.addSilver(100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShrineOfHeritageOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SHRINE OF HERITAGE'), findsOneWidget);
      expect(find.text('100 S'), findsOneWidget);
      expect(find.text('Reinforced Masonry'), findsOneWidget);
      expect(find.text('Forged Iron'), findsOneWidget);
      expect(find.text("Scribe's Wit"), findsOneWidget);
      expect(find.text('BACK TO RESULTS'), findsOneWidget);

      // Tap first upgrade button (Reinforced Masonry: 15 S)
      final upgradeBtn = find.widgetWithText(ElevatedButton, '15 S');
      expect(upgradeBtn, findsOneWidget);
      await tester.tap(upgradeBtn);
      await tester.pumpAndSettle();

      // Silver deducted: 100 - 15 = 85 S
      expect(find.text('85 S'), findsOneWidget);
      expect(find.text('Rank 1/10'), findsOneWidget);
    });

    testWidgets('Close button removes shrine overlay', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.overlays.add(OverlayIds.shrine);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShrineOfHeritageOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('BACK TO RESULTS'));
      await tester.pump();

      expect(game.overlays.isActive(OverlayIds.shrine), isFalse);
    });
  });

  group('GameOverOverlay Meta-Progression Tests', () {
    testWidgets('Displays Silver Earned and offers Shrine of Heritage button', (tester) async {
      final game = BonkholdGame();
      await game.onLoad();
      game.runState.elapsedSeconds.value = 120.0; // floor(120 * 0.2) = 24
      game.runState.addEliteKill(); // 1 * 2 = 2
      // Total silver: 26

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(game: game),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.text('+26 Silver'), findsOneWidget);
      expect(find.text('SHRINE OF HERITAGE'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);

      // Tap Shrine button opens shrine overlay
      await tester.tap(find.text('SHRINE OF HERITAGE'));
      await tester.pump();

      expect(game.overlays.isActive(OverlayIds.shrine), isTrue);
    });
  });
}
