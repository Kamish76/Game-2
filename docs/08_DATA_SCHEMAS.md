# 08: Data Schemas & Model Contracts

## Purpose
Defines the canonical Dart model signatures for game content registries (`weapons.dart`, `tomes.dart`, `enemies.dart`, `characters.dart`).

---

## 1. Rarity Enum & Multipliers

```dart
enum Rarity {
  common(1.0, Color(0xFFB0B0B0), 60),
  uncommon(1.2, Color(0xFF43D365), 25),
  rare(1.4, Color(0xFF3B82F6), 10),
  epic(1.6, Color(0xFFA855F7), 4),
  legendary(2.0, Color(0xFFFBBF24), 1);

  const Rarity(this.multiplier, this.color, this.baseWeight);

  final double multiplier;
  final Color color;
  final int baseWeight;
}
```

---

## 2. Weapon Schema (`WeaponDef`)

```dart
enum TargetingMode { closestToBastion, highestMaxHp, densest, random }

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
}

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
```

---

## 3. Tome Schema (`TomeDef`)

```dart
class TomeDef {
  const TomeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.statKey,
    required this.baseIncrement,
    this.maxLevel = 10,
  });

  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final String statKey;
  final double baseIncrement;
  final int maxLevel;
}
```

---

## 4. Enemy Schema (`EnemyDef`)

```dart
class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.name,
    required this.creditCost,
    required this.baseHp,
    required this.speed,
    required this.contactDamage,
    this.attackInterval = 1.0,
    this.knockbackResist = 0.0,
    this.isRanged = false,
    this.attackRange = 0.0,
  });

  final String id;
  final String name;
  final int creditCost;
  final double baseHp;
  final double speed;
  final double contactDamage;
  final double attackInterval;
  final double knockbackResist;
  final bool isRanged;
  final double attackRange;
}
```

---

## 5. Character Schema (`CharacterDef`)

```dart
class CharacterDef {
  const CharacterDef({
    required this.id,
    required this.name,
    required this.tagline,
    required this.startingWeaponId,
    required this.baseLuck,
    required this.luckPerLevel,
    required this.baseHp,
    required this.attractionRadius,
  });

  final String id;
  final String name;
  final String tagline;
  final String startingWeaponId;
  final double baseLuck;
  final double luckPerLevel;
  final double baseHp;
  final double attractionRadius;
}
```
