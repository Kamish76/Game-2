import '../models/run_state.dart';
import '../models/stat_sheet.dart';

/// Recomputes flat StatSheet upon level-up or loadout changes.
/// Runs only when equipment or levels change, never on hot per-frame updates.
abstract final class StatEngine {
  static StatSheet recompute(RunState runState) {
    final char = runState.character;
    final int level = runState.level.value;

    // Innate character passive: +1.5% Luck per level-up
    final double levelLuckBonus = (level - 1) * char.luckPerLevel;
    double luck = char.baseLuck + levelLuckBonus;

    double maxHp = char.baseHp;
    const double hpRegen = 0.0;
    double armor = 0.0;
    const double evasion = 0.0;
    double shield = 0.0;
    const double lifesteal = 0.0;
    double thorns = 0.0;
    double xpGain = 0.0;
    double curse = 0.0;
    double attraction = char.attractionRadius;

    double damage = 1.0;
    double attackSpeed = 0.0;
    int quantity = 0;
    double size = 0.0;
    const double projSpeed = 0.0;
    const double duration = 0.0;
    const double critChance = 0.05;
    const double critDamage = 2.0;
    const double knockback = 0.0;

    // Sum equipped tome bonuses
    for (final tome in runState.tomes) {
      final double bonus = tome.totalBonus;
      switch (tome.def.statKey) {
        case 'damage':
          damage += bonus;
          break;
        case 'attackSpeed':
          attackSpeed += bonus;
          break;
        case 'quantity':
          quantity += bonus.round();
          break;
        case 'size':
          size += bonus;
          break;
        case 'luck':
          luck += bonus;
          break;
        case 'armor':
          armor += bonus;
          break;
        case 'xpGain':
          xpGain += bonus;
          break;
        case 'curse':
          curse += bonus;
          break;
        case 'attraction':
          attraction += bonus;
          break;
        case 'maxHp':
          maxHp += bonus;
          break;
        case 'shield':
          shield += bonus;
          break;
        case 'thorns':
          thorns += bonus;
          break;
      }
    }

    final newStats = StatSheet(
      maxHp: maxHp,
      hpRegen: hpRegen,
      armor: armor,
      evasion: evasion,
      shield: shield,
      lifesteal: lifesteal,
      thorns: thorns,
      luck: luck,
      xpGain: xpGain,
      curse: curse,
      attraction: attraction,
      damage: damage,
      attackSpeed: attackSpeed,
      quantity: quantity,
      size: size,
      projSpeed: projSpeed,
      duration: duration,
      critChance: critChance.clamp(0.0, 1.0),
      critDamage: critDamage,
      knockback: knockback,
    );

    runState.stats = newStats;
    runState.maxHp.value = maxHp;
    return newStats;
  }
}
