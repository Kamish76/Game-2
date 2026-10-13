import '../models/weapon_def.dart';

const WeaponDef emberStaffDef = WeaponDef(
  id: 'ember_staff',
  name: 'Ember Staff',
  description: 'Launches arcing fireballs that detonate in an AoE blast.',
  iconAsset: 'assets/images/weapons/ember_staff.png',
  baseStats: WeaponStats(
    damage: 18.0,
    cooldown: 1.125,
    projectiles: 1,
    projSpeed: 140.0,
    radius: 28.0,
    pierce: 0,
    range: 180.0,
    knockback: 12.0,
  ),
  upgradePool: [
    WeaponStatUpgrade(
      statKey: 'damage',
      name: 'Damage',
      baseIncrement: 3.0,
    ),
    WeaponStatUpgrade(
      statKey: 'radius',
      name: 'Blast Radius',
      baseIncrement: 4.0,
    ),
    WeaponStatUpgrade(
      statKey: 'cooldown',
      name: 'Cooldown',
      baseIncrement: -0.08,
    ),
    WeaponStatUpgrade(
      statKey: 'projectiles',
      name: 'Projectiles',
      baseIncrement: 1.0,
    ),
  ],
  targeting: TargetingMode.closestToBastion,
);

const WeaponDef revolverBatteryDef = WeaponDef(
  id: 'revolver_battery',
  name: 'Revolver Battery',
  description: 'Rapid-fire piercing bullets aimed at the nearest threat.',
  iconAsset: 'assets/images/weapons/revolver_battery.png',
  baseStats: WeaponStats(
    damage: 8.0,
    cooldown: 0.45,
    projectiles: 1,
    projSpeed: 220.0,
    radius: 0.0,
    pierce: 1,
    range: 150.0,
    knockback: 6.0,
  ),
  upgradePool: [
    WeaponStatUpgrade(statKey: 'damage', name: 'Damage', baseIncrement: 2.0),
    WeaponStatUpgrade(statKey: 'cooldown', name: 'Cooldown', baseIncrement: -0.04),
    WeaponStatUpgrade(statKey: 'pierce', name: 'Pierce', baseIncrement: 1.0),
  ],
  targeting: TargetingMode.closestToBastion,
);

const WeaponDef pulseAuraDef = WeaponDef(
  id: 'pulse_aura',
  name: 'Pulse Aura',
  description: 'Radiates a 360° shockwave knocking back all adjacent enemies.',
  iconAsset: 'assets/images/weapons/pulse_aura.png',
  baseStats: WeaponStats(
    damage: 10.0,
    cooldown: 1.8,
    projectiles: 1,
    projSpeed: 0.0,
    radius: 42.0,
    pierce: 999,
    range: 42.0,
    knockback: 18.0,
  ),
  upgradePool: [
    WeaponStatUpgrade(statKey: 'damage', name: 'Damage', baseIncrement: 2.5),
    WeaponStatUpgrade(statKey: 'radius', name: 'Radius', baseIncrement: 6.0),
    WeaponStatUpgrade(statKey: 'cooldown', name: 'Cooldown', baseIncrement: -0.12),
  ],
  targeting: TargetingMode.closestToBastion,
);

const WeaponDef railSniperDef = WeaponDef(
  id: 'rail_sniper',
  name: 'Rail Sniper',
  description: 'Heavy piercing beam targeting the toughest enemy.',
  iconAsset: 'assets/images/weapons/rail_sniper.png',
  baseStats: WeaponStats(
    damage: 40.0,
    cooldown: 2.4,
    projectiles: 1,
    projSpeed: 320.0,
    radius: 0.0,
    pierce: 3,
    range: 220.0,
    knockback: 25.0,
  ),
  upgradePool: [
    WeaponStatUpgrade(statKey: 'damage', name: 'Damage', baseIncrement: 8.0),
    WeaponStatUpgrade(statKey: 'cooldown', name: 'Cooldown', baseIncrement: -0.15),
    WeaponStatUpgrade(statKey: 'pierce', name: 'Pierce', baseIncrement: 1.0),
  ],
  targeting: TargetingMode.highestMaxHp,
);

const List<WeaponDef> allWeapons = [
  emberStaffDef,
  revolverBatteryDef,
  pulseAuraDef,
  railSniperDef,
];
