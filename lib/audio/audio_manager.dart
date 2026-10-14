import 'dart:io' show Platform;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Master list of game sound effect identifiers.
enum SfxId {
  shootEmber,
  shootRevolver,
  pulseAura,
  shootRail,
  critImpact,
  bastionHit,
  enemyDeath,
  pickupXp,
  pickupGold,
  levelUp,
  shardMerge,
  bossSpawn,
  gameOver,
  chestOpen,
  merchantArrive,
  merchantDepart,
  forgeHammer,
  relicProc,
}

/// Master list of background music tracks.
enum BgmId {
  mainEndless,
  bossEncounter,
  overtime,
}

/// Central audio manager service handling SFX and BGM channels.
/// Provides resilient fallbacks for tests and environments without audio hardware.
class AudioManager {
  AudioManager._() {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        isTestMode = true;
      }
    } catch (_) {}
  }
  static final AudioManager instance = AudioManager._();

  bool isMuted = false;
  bool isTestMode = false;

  final Map<SfxId, String> _sfxFiles = {
    SfxId.shootEmber: 'sfx_shoot_ember.ogg',
    SfxId.shootRevolver: 'sfx_shoot_revolver.ogg',
    SfxId.pulseAura: 'sfx_pulse_aura.ogg',
    SfxId.shootRail: 'sfx_shoot_rail.ogg',
    SfxId.critImpact: 'sfx_crit_impact.ogg',
    SfxId.bastionHit: 'sfx_bastion_hit.ogg',
    SfxId.enemyDeath: 'sfx_enemy_death.ogg',
    SfxId.pickupXp: 'sfx_pickup_xp.ogg',
    SfxId.pickupGold: 'sfx_pickup_gold.ogg',
    SfxId.levelUp: 'sfx_levelup_jingle.ogg',
    SfxId.shardMerge: 'sfx_shard_merge.ogg',
    SfxId.bossSpawn: 'sfx_enemy_death_large.ogg',
    SfxId.gameOver: 'sfx_bastion_destroyed.ogg',
    SfxId.chestOpen: 'sfx_chest_open.ogg',
    SfxId.merchantArrive: 'sfx_merchant_arrive.ogg',
    SfxId.merchantDepart: 'sfx_merchant_depart.ogg',
    SfxId.forgeHammer: 'sfx_forge_hammer.ogg',
    SfxId.relicProc: 'sfx_relic_proc.ogg',
  };

  final Map<BgmId, String> _bgmFiles = {
    BgmId.mainEndless: 'bgm_endless_main.ogg',
    BgmId.bossEncounter: 'bgm_boss_encounter.ogg',
    BgmId.overtime: 'bgm_overtime_surge.ogg',
  };

  /// Plays a sound effect by ID. Fails silently if sound file is not present or in test mode.
  void playSfx(SfxId id) {
    if (isMuted || isTestMode) return;
    final file = _sfxFiles[id];
    if (file == null) return;

    try {
      FlameAudio.play(file).ignore();
    } catch (_) {
      // Graceful fallback for test or unbundled asset environments
    }
  }

  /// Plays a looping background music track.
  void playBgm(BgmId id) {
    if (isMuted || isTestMode) return;
    final file = _bgmFiles[id];
    if (file == null) return;

    try {
      FlameAudio.bgm.play(file).ignore();
    } catch (_) {
      // Graceful fallback
    }
  }

  /// Stops current background music.
  void stopBgm() {
    if (isTestMode) return;
    try {
      FlameAudio.bgm.stop().ignore();
    } catch (_) {
      // Graceful fallback
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      stopBgm();
    }
  }
}
