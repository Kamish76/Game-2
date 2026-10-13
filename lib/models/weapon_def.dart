/// How a weapon selects its targets among threatening enemies.
enum TargetingMode {
  closestToBastion,
  highestMaxHp,
  densest,
  random,
}

/// Baseline or upgraded statistics for an equipped weapon.
class WeaponStats {
  const WeaponStats({
    required this.damage,
    required this.cooldown,
    this.projectiles = 1,
    this.projSpeed = 150.0,
    this.radius = 0.0,
    this.pierce = 0,
    this.range = 180.0,
    this.knockback = 10.0,
  });

  final double damage;
  final double cooldown;
  final int projectiles;
  final double projSpeed;
  final double radius;
  final int pierce;
  final double range;
  final double knockback;

  WeaponStats copyWith({
    double? damage,
    double? cooldown,
    int? projectiles,
    double? projSpeed,
    double? radius,
    int? pierce,
    double? range,
    double? knockback,
  }) {
    return WeaponStats(
      damage: damage ?? this.damage,
      cooldown: cooldown ?? this.cooldown,
      projectiles: projectiles ?? this.projectiles,
      projSpeed: projSpeed ?? this.projSpeed,
      radius: radius ?? this.radius,
      pierce: pierce ?? this.pierce,
      range: range ?? this.range,
      knockback: knockback ?? this.knockback,
    );
  }
}

/// A specific stat upgrade offered when leveling up an equipped weapon.
class WeaponStatUpgrade {
  const WeaponStatUpgrade({
    required this.statKey,
    required this.name,
    required this.baseIncrement,
    this.isMultiplier = false,
  });

  final String statKey;
  final String name;
  final double baseIncrement;
  final bool isMultiplier;
}

/// Canonical definition of a weapon in the game registry.
class WeaponDef {
  const WeaponDef({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.baseStats,
    required this.upgradePool,
    this.targeting = TargetingMode.closestToBastion,
  });

  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final WeaponStats baseStats;
  final List<WeaponStatUpgrade> upgradePool;
  final TargetingMode targeting;
}
