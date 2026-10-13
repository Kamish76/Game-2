/// Flat evaluated statistics for the Bastion and global offensive multipliers.
/// Computed by StatEngine upon level-up or loadout changes and cached for fast access.
class StatSheet {
  const StatSheet({
    this.maxHp = 100.0,
    this.hpRegen = 0.0,
    this.armor = 0.0,
    this.evasion = 0.0,
    this.shield = 0.0,
    this.lifesteal = 0.0,
    this.thorns = 0.0,
    this.luck = 0.15,
    this.xpGain = 0.0,
    this.curse = 0.0,
    this.attraction = 48.0,
    this.damage = 1.0,
    this.attackSpeed = 0.0,
    this.quantity = 0,
    this.size = 0.0,
    this.projSpeed = 0.0,
    this.duration = 0.0,
    this.critChance = 0.05,
    this.critDamage = 2.0,
    this.knockback = 0.0,
  });

  // Defensive / Utility stats
  final double maxHp;
  final double hpRegen;
  final double armor;
  final double evasion;
  final double shield;
  final double lifesteal;
  final double thorns;
  final double luck;
  final double xpGain;
  final double curse;
  final double attraction;

  // Global Offensive multipliers
  final double damage;
  final double attackSpeed;
  final int quantity;
  final double size;
  final double projSpeed;
  final double duration;
  final double critChance;
  final double critDamage;
  final double knockback;

  StatSheet copyWith({
    double? maxHp,
    double? hpRegen,
    double? armor,
    double? evasion,
    double? shield,
    double? lifesteal,
    double? thorns,
    double? luck,
    double? xpGain,
    double? curse,
    double? attraction,
    double? damage,
    double? attackSpeed,
    int? quantity,
    double? size,
    double? projSpeed,
    double? duration,
    double? critChance,
    double? critDamage,
    double? knockback,
  }) {
    return StatSheet(
      maxHp: maxHp ?? this.maxHp,
      hpRegen: hpRegen ?? this.hpRegen,
      armor: armor ?? this.armor,
      evasion: evasion ?? this.evasion,
      shield: shield ?? this.shield,
      lifesteal: lifesteal ?? this.lifesteal,
      thorns: thorns ?? this.thorns,
      luck: luck ?? this.luck,
      xpGain: xpGain ?? this.xpGain,
      curse: curse ?? this.curse,
      attraction: attraction ?? this.attraction,
      damage: damage ?? this.damage,
      attackSpeed: attackSpeed ?? this.attackSpeed,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      projSpeed: projSpeed ?? this.projSpeed,
      duration: duration ?? this.duration,
      critChance: critChance ?? this.critChance,
      critDamage: critDamage ?? this.critDamage,
      knockback: knockback ?? this.knockback,
    );
  }
}
