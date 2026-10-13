import '../models/tome_def.dart';

const TomeDef damageTome = TomeDef(
  id: 'damage_tome',
  name: 'Tome of Might',
  description: 'Increases all weapon damage globally.',
  iconAsset: 'assets/images/tomes/might.png',
  statKey: 'damage',
  baseIncrement: 0.08,
  isMultiplier: true,
);

const TomeDef speedTome = TomeDef(
  id: 'speed_tome',
  name: 'Tome of Haste',
  description: 'Increases weapon attack speed (reduces cooldown).',
  iconAsset: 'assets/images/tomes/haste.png',
  statKey: 'attackSpeed',
  baseIncrement: 0.075,
  isMultiplier: true,
);

const TomeDef quantityTome = TomeDef(
  id: 'quantity_tome',
  name: 'Tome of Volley',
  description: 'Adds extra projectiles per volley to weapons.',
  iconAsset: 'assets/images/tomes/volley.png',
  statKey: 'quantity',
  baseIncrement: 1.0,
  maxLevel: 5,
);

const TomeDef sizeTome = TomeDef(
  id: 'size_tome',
  name: 'Tome of Expansion',
  description: 'Increases projectile and explosion blast radius.',
  iconAsset: 'assets/images/tomes/expansion.png',
  statKey: 'size',
  baseIncrement: 0.10,
  isMultiplier: true,
);

const TomeDef luckTome = TomeDef(
  id: 'luck_tome',
  name: 'Tome of Fortune',
  description: 'Improves odds of rolling higher rarity cards.',
  iconAsset: 'assets/images/tomes/fortune.png',
  statKey: 'luck',
  baseIncrement: 0.08,
  isMultiplier: true,
);

const TomeDef armorTome = TomeDef(
  id: 'armor_tome',
  name: 'Tome of Aegis',
  description: 'Grants flat Armor points to reduce incoming damage.',
  iconAsset: 'assets/images/tomes/aegis.png',
  statKey: 'armor',
  baseIncrement: 12.0,
);

const TomeDef xpTome = TomeDef(
  id: 'xp_tome',
  name: 'Tome of Wisdom',
  description: 'Increases XP gained from collected shards.',
  iconAsset: 'assets/images/tomes/wisdom.png',
  statKey: 'xpGain',
  baseIncrement: 0.10,
  isMultiplier: true,
);

const TomeDef cursedTome = TomeDef(
  id: 'cursed_tome',
  name: 'Tome of Calamity',
  description: 'Increases horde density & difficulty for higher thrills.',
  iconAsset: 'assets/images/tomes/calamity.png',
  statKey: 'curse',
  baseIncrement: 0.05,
  isMultiplier: true,
);

const List<TomeDef> allTomes = [
  damageTome,
  speedTome,
  quantityTome,
  sizeTome,
  luckTome,
  armorTome,
  xpTome,
  cursedTome,
];
