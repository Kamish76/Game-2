import 'rarity.dart';

/// Definition of a passive Item Relic in BONKHOLD.
class ItemDef {
  const ItemDef({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.iconAsset,
    this.maxStacks = 99,
    this.synergyTag = 'General',
  });

  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final String iconAsset;
  final int maxStacks;
  final String synergyTag;
}
