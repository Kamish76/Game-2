/// Definition of a playable tower chassis / character.
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
