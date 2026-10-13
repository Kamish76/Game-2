import 'rarity.dart';

enum DraftCardType {
  newWeapon,
  weaponUpgrade,
  newTome,
  tomeUpgrade,
  fallbackHeal,
}

/// Represents a rolled upgrade card displayed on the Level-Up screen.
class DraftCard {
  const DraftCard({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.rarity,
    this.statKey,
    this.beforeValue,
    this.afterValue,
    this.deltaDescription = '',
    this.targetWeaponIndex,
  });

  final DraftCardType type;
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final Rarity rarity;
  final String? statKey;
  final double? beforeValue;
  final double? afterValue;
  final String deltaDescription;
  final int? targetWeaponIndex;
}
