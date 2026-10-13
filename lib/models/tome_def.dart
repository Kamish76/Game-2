/// Definition of a passive stat Tome in the game registry.
class TomeDef {
  const TomeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.statKey,
    required this.baseIncrement,
    this.maxLevel = 10,
    this.isMultiplier = false,
  });

  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final String statKey;
  final double baseIncrement;
  final int maxLevel;
  final bool isMultiplier;
}
