import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'character_def.dart';
import 'stat_sheet.dart';
import 'tome_def.dart';
import 'weapon_def.dart';

class EquippedWeapon {
  EquippedWeapon({
    required this.def,
    required this.stats,
    this.level = 1,
  });

  final WeaponDef def;
  WeaponStats stats;
  int level;
}

class EquippedTome {
  EquippedTome({
    required this.def,
    this.level = 1,
    this.totalBonus = 0.0,
  });

  final TomeDef def;
  int level;
  double totalBonus;
}

class BossInfo {
  const BossInfo({
    required this.name,
    required this.hp,
    required this.maxHp,
  });

  final String name;
  final double hp;
  final double maxHp;
}

/// Runtime state of an active game run.
/// Exposes ValueNotifiers so Flutter UI overlays refresh efficiently on change.
class RunState {
  RunState({required this.character}) {
    maxHp.value = character.baseHp;
    hp.value = character.baseHp;
    requiredXp.value = xpForLevel(1);
    xpProgress.value = 0.0;
  }

  final CharacterDef character;

  // Reactive notifiers for the HUD
  final ValueNotifier<double> hp = ValueNotifier<double>(100.0);
  final ValueNotifier<double> maxHp = ValueNotifier<double>(100.0);
  final ValueNotifier<double> shield = ValueNotifier<double>(0.0);

  final ValueNotifier<int> currentXp = ValueNotifier<int>(0);
  final ValueNotifier<int> requiredXp = ValueNotifier<int>(5);
  final ValueNotifier<double> xpProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<int> level = ValueNotifier<int>(1);

  final ValueNotifier<int> gold = ValueNotifier<int>(0);
  final ValueNotifier<int> kills = ValueNotifier<int>(0);
  final ValueNotifier<double> elapsedSeconds = ValueNotifier<double>(0.0);

  // Elite and Boss tracking
  final ValueNotifier<int> eliteKills = ValueNotifier<int>(0);
  final ValueNotifier<int> bossKills = ValueNotifier<int>(0);
  final ValueNotifier<BossInfo?> activeBoss = ValueNotifier<BossInfo?>(null);

  // Overtime state
  final ValueNotifier<bool> isOvertime = ValueNotifier<bool>(false);
  double overtimeDuration = 0.0;

  // Draft utility charges (v1: 2 reroll, 2 skip, 1 banish)
  int rerollCharges = 2;
  int skipCharges = 2;
  int banishCharges = 1;
  final Set<String> banishedIds = <String>{};

  bool isPaused = false;
  bool isGameOver = false;

  // Equipment slots (max 4 each)
  final List<EquippedWeapon> weapons = <EquippedWeapon>[];
  final List<EquippedTome> tomes = <EquippedTome>[];

  // Cached evaluated stats
  StatSheet stats = const StatSheet();

  // Pending level-ups queued
  int pendingLevelUps = 0;


  /// Calculate XP required to advance from [lvl] to [lvl + 1].
  /// Formula: round(5 + 4*(L-1) + 0.6*(L-1)^2)
  static int xpForLevel(int lvl) {
    if (lvl <= 1) return 5;
    final double l = (lvl - 1).toDouble();
    return (5.0 + 4.0 * l + 0.6 * l * l).round();
  }

  /// Adds XP, evaluating level thresholds and queuing level-ups.
  void addXp(int amount) {
    if (isGameOver) return;
    final int gained = (amount * (1.0 + stats.xpGain)).round().clamp(1, 99999);
    int curr = currentXp.value + gained;
    int req = requiredXp.value;
    int curLvl = level.value;

    while (curr >= req) {
      curr -= req;
      curLvl++;
      pendingLevelUps++;
      req = xpForLevel(curLvl);
    }

    currentXp.value = curr;
    requiredXp.value = req;
    level.value = curLvl;
    xpProgress.value = (curr / req).clamp(0.0, 1.0);
  }

  void addGold(int amount) {
    gold.value += amount;
  }

  void addKill() {
    kills.value++;
  }

  void addEliteKill() {
    eliteKills.value++;
  }

  void addBossKill() {
    bossKills.value++;
  }

  /// Calculates final run score according to design spec:
  /// (Time_sec * 10 + Kills * 5 + BossKills * 250 + Gold * 2) * OvertimeBonus
  /// where OvertimeBonus = 1.0 (if t < 900) or 1.0 + (t - 900) / 60
  int computeFinalScore() {
    final double t = elapsedSeconds.value;
    final int k = kills.value;
    final int bk = bossKills.value;
    final int g = gold.value;
    final double overtimeBonus = t >= 900.0 ? 1.0 + ((t - 900.0) / 60.0) : 1.0;
    return ((t * 10 + k * 5 + bk * 250 + g * 2) * overtimeBonus).round();
  }

  /// Applies damage directly to the Bastion (called after DamageResolver).
  void applyDamage(double damage) {
    if (isGameOver) return;
    double remaining = damage;
    if (shield.value > 0) {
      final double absorbed = math.min(shield.value, remaining);
      shield.value -= absorbed;
      // Shield absorbs hit without spillover per spec
      remaining = 0;
    }

    if (remaining > 0) {
      hp.value = math.max(0.0, hp.value - remaining);
      if (hp.value <= 0) {
        isGameOver = true;
      }
    }
  }

  void heal(double amount) {
    if (isGameOver) return;
    hp.value = math.min(maxHp.value, hp.value + amount);
  }

  void reset() {
    isPaused = false;
    isGameOver = false;
    pendingLevelUps = 0;
    maxHp.value = character.baseHp;
    hp.value = character.baseHp;
    shield.value = 0.0;
    currentXp.value = 0;
    level.value = 1;
    requiredXp.value = xpForLevel(1);
    xpProgress.value = 0.0;
    gold.value = 0;
    kills.value = 0;
    eliteKills.value = 0;
    bossKills.value = 0;
    activeBoss.value = null;
    isOvertime.value = false;
    overtimeDuration = 0.0;
    rerollCharges = 2;
    skipCharges = 2;
    banishCharges = 1;
    banishedIds.clear();
    elapsedSeconds.value = 0.0;
    weapons.clear();
    tomes.clear();
    stats = const StatSheet();
  }

  void dispose() {
    hp.dispose();
    maxHp.dispose();
    shield.dispose();
    currentXp.dispose();
    requiredXp.dispose();
    xpProgress.dispose();
    level.dispose();
    gold.dispose();
    kills.dispose();
    eliteKills.dispose();
    bossKills.dispose();
    activeBoss.dispose();
    isOvertime.dispose();
    elapsedSeconds.dispose();
  }
}

