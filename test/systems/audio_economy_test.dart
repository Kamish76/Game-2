import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bonkhold/audio/audio_manager.dart';
import 'package:bonkhold/data/characters.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/models/meta_talents.dart';
import 'package:bonkhold/models/run_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Audio Manager Tests', () {
    setUp(() {
      AudioManager.instance.isTestMode = true;
      AudioManager.instance.isMuted = false;
    });

    test('Plays all Phase 2 SFX without errors', () {
      final am = AudioManager.instance;
      expect(() => am.playSfx(SfxId.chestOpen), returnsNormally);
      expect(() => am.playSfx(SfxId.merchantArrive), returnsNormally);
      expect(() => am.playSfx(SfxId.merchantDepart), returnsNormally);
      expect(() => am.playSfx(SfxId.forgeHammer), returnsNormally);
      expect(() => am.playSfx(SfxId.relicProc), returnsNormally);
    });

    test('Mute toggle stops BGM and respects muted state', () {
      final am = AudioManager.instance;
      expect(am.isMuted, isFalse);

      am.toggleMute();
      expect(am.isMuted, isTrue);

      expect(() => am.playSfx(SfxId.chestOpen), returnsNormally);
      expect(() => am.playBgm(BgmId.mainEndless), returnsNormally);

      am.toggleMute();
      expect(am.isMuted, isFalse);
    });
  });

  group('Phase 2 Economy Balancing Tests', () {
    testWithGame<BonkholdGame>(
      'Golden Aura meta-talent scales in-run gold pickup absorption',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // 5 ranks Golden Aura = +25% Gold (goldMultiplier = 1.25)
        game.runState.metaStats = const MetaProgressionStats(goldMultiplier: 1.25);
        expect(game.runState.gold.value, 0);

        // Spawn a 20 Gold pickup
        game.spawnPickup(0, 50, 20, true);
        await game.ready();

        // Advance ticks so pickup vacuums into Bastion
        for (int i = 0; i < 30; i++) {
          game.update(0.05);
        }

        // Expected: round(20 * 1.25) = 25 Gold
        expect(game.runState.gold.value, 25);
      },
    );

    test('RunState allows gold addition and deductions for store purchases', () {
      final runState = RunState(character: kitsuneSpireDef);
      expect(runState.gold.value, 0);

      runState.addGold(100);
      expect(runState.gold.value, 100);

      // Buy emergency repairs (40 G)
      runState.gold.value -= 40;
      expect(runState.gold.value, 60);

      // Buy forge transmutation (50 G)
      runState.gold.value -= 50;
      expect(runState.gold.value, 10);
    });
  });
}
