import '../models/item_def.dart';
import '../models/rarity.dart';

const ItemDef spikyBulwark = ItemDef(
  id: 'spiky_bulwark',
  name: 'Spiky Bulwark',
  description: 'Converts Armor into flat retaliatory Thorns (+2 Thorns per 1% Armor).',
  rarity: Rarity.uncommon,
  iconAsset: 'assets/images/items/spiky_bulwark.png',
  synergyTag: 'Armor',
);

const ItemDef maskOfRuin = ItemDef(
  id: 'mask_of_ruin',
  name: 'Mask of Ruin',
  description: 'Thorns damage has a 50% chance to trigger an AoE explosion.',
  rarity: Rarity.rare,
  iconAsset: 'assets/images/items/mask_of_ruin.png',
  synergyTag: 'Armor',
);

const ItemDef combustionElixir = ItemDef(
  id: 'combustion_elixir',
  name: 'Combustion Elixir',
  description: 'Critical hits have a 40% chance to detonate for 50% splash damage.',
  rarity: Rarity.rare,
  iconAsset: 'assets/images/items/combustion_elixir.png',
  synergyTag: 'Crit',
);

const ItemDef bloodfangDagger = ItemDef(
  id: 'bloodfang_dagger',
  name: 'Bloodfang Dagger',
  description: 'Critical strikes grant +20% chance to heal 1 HP.',
  rarity: Rarity.rare,
  iconAsset: 'assets/images/items/bloodfang_dagger.png',
  synergyTag: 'Crit',
);

const ItemDef overclockCapacitor = ItemDef(
  id: 'overclock_capacitor',
  name: 'Overclock Capacitor',
  description: 'When Bastion drops below 40% HP, triggers a 4s time warp (50% slow, 2x fire rate).',
  rarity: Rarity.epic,
  iconAsset: 'assets/images/items/overclock_capacitor.png',
  synergyTag: 'Survival',
);

const ItemDef luckyClover = ItemDef(
  id: 'lucky_clover',
  name: 'Lucky Clover',
  description: 'Grants flat +10% Luck to upgrade drafts and drop rolls.',
  rarity: Rarity.common,
  iconAsset: 'assets/images/items/lucky_clover.png',
  synergyTag: 'Fortune',
);

const ItemDef ironPlating = ItemDef(
  id: 'iron_plating',
  name: 'Iron Plating',
  description: 'Grants +25 Max HP and +5 Armor.',
  rarity: Rarity.common,
  iconAsset: 'assets/images/items/iron_plating.png',
  synergyTag: 'Defense',
);

const ItemDef magnetizedCore = ItemDef(
  id: 'magnetized_core',
  name: 'Magnetized Core',
  description: 'Increases pull vacuum speed by +50% and Gold drop rate by +10%.',
  rarity: Rarity.common,
  iconAsset: 'assets/images/items/magnetized_core.png',
  synergyTag: 'Economy',
);

const ItemDef volatileCask = ItemDef(
  id: 'volatile_cask',
  name: 'Volatile Cask',
  description: 'Leaving enemies near the tower causes a poison puddle dealing 4 dmg/s.',
  rarity: Rarity.uncommon,
  iconAsset: 'assets/images/items/volatile_cask.png',
  synergyTag: 'Area Denial',
);

const ItemDef heavySprings = ItemDef(
  id: 'heavy_springs',
  name: 'Heavy Springs',
  description: 'Increases knockback force on all weapon attacks by +35%.',
  rarity: Rarity.common,
  iconAsset: 'assets/images/items/heavy_springs.png',
  synergyTag: 'Crowd Control',
);

const ItemDef shatterCrystal = ItemDef(
  id: 'shatter_crystal',
  name: 'Shatter Crystal',
  description: 'Attacks have a 15% chance to freeze targets for 1.5s.',
  rarity: Rarity.epic,
  iconAsset: 'assets/images/items/shatter_crystal.png',
  synergyTag: 'Crowd Control',
);

const ItemDef cursedIdol = ItemDef(
  id: 'cursed_idol',
  name: 'Cursed Idol',
  description: 'Multiplies Gold and XP gained by 1.5x, but boosts enemy HP & speed by +20%.',
  rarity: Rarity.legendary,
  iconAsset: 'assets/images/items/cursed_idol.png',
  synergyTag: 'Greed',
);

const List<ItemDef> allItems = [
  spikyBulwark,
  maskOfRuin,
  combustionElixir,
  bloodfangDagger,
  overclockCapacitor,
  luckyClover,
  ironPlating,
  magnetizedCore,
  volatileCask,
  heavySprings,
  shatterCrystal,
  cursedIdol,
];

final Map<String, ItemDef> itemsById = {
  for (final item in allItems) item.id: item,
};

/// Rolls a random relic from the item registry, weighted by rarity and luck.
ItemDef rollChestRelic(dynamic rng, {bool isGolden = false, double luck = 0.0}) {
  final List<ItemDef> candidates = isGolden
      ? allItems
          .where((i) =>
              i.rarity == Rarity.rare ||
              i.rarity == Rarity.epic ||
              i.rarity == Rarity.legendary)
          .toList()
      : allItems;

  double totalWeight = 0.0;
  for (final item in candidates) {
    final double weight = item.rarity == Rarity.common
        ? item.rarity.baseWeight.toDouble()
        : item.rarity.baseWeight * (1.0 + luck);
    totalWeight += weight;
  }

  double roll = rng.nextDouble() * totalWeight;
  for (final item in candidates) {
    final double weight = item.rarity == Rarity.common
        ? item.rarity.baseWeight.toDouble()
        : item.rarity.baseWeight * (1.0 + luck);
    roll -= weight;
    if (roll <= 0) {
      return item;
    }
  }

  return candidates.first;
}
