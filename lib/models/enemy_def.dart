/// Static configuration for an enemy archetype.
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
    this.radius = 8.0,
    this.xpValue = 1,
    this.colorHex = 0xFFE43B44,
    this.isRanged = false,
    this.preferredDistance = 0.0,
    this.projectileSpeed = 0.0,
    this.projectileDamage = 0.0,
    this.isBoss = false,
  });

  final String id;
  final String name;
  final int creditCost;
  final double baseHp;
  final double speed;
  final double contactDamage;
  final double attackInterval;
  final double knockbackResist;
  final double radius;
  final int xpValue;
  final int colorHex;
  final bool isRanged;
  final double preferredDistance;
  final double projectileSpeed;
  final double projectileDamage;
  final bool isBoss;
}
