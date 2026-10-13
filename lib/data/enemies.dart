import '../models/enemy_def.dart';

const EnemyDef swarmlingDef = EnemyDef(
  id: 'swarmling',
  name: 'Swarmling',
  creditCost: 1,
  baseHp: 18.0,
  speed: 48.0,
  contactDamage: 4.0,
  attackInterval: 1.0,
  knockbackResist: 0.0,
  radius: 5.0,
  xpValue: 1,
  colorHex: 0xFFE43B44,
);

const EnemyDef runnerDef = EnemyDef(
  id: 'runner',
  name: 'Runner',
  creditCost: 2,
  baseHp: 24.0,
  speed: 72.0,
  contactDamage: 6.0,
  attackInterval: 0.8,
  knockbackResist: 0.10,
  radius: 6.0,
  xpValue: 2,
  colorHex: 0xFFF77622,
);

const EnemyDef bruteDef = EnemyDef(
  id: 'brute',
  name: 'Brute',
  creditCost: 6,
  baseHp: 90.0,
  speed: 32.0,
  contactDamage: 18.0,
  attackInterval: 1.5,
  knockbackResist: 0.65,
  radius: 9.0,
  xpValue: 5,
  colorHex: 0xFF993D64,
);

const EnemyDef spitterDef = EnemyDef(
  id: 'spitter',
  name: 'Spitter',
  creditCost: 5,
  baseHp: 45.0,
  speed: 40.0,
  contactDamage: 4.0,
  attackInterval: 2.0,
  knockbackResist: 0.25,
  radius: 7.0,
  xpValue: 3,
  colorHex: 0xFF2CE8F5,
  isRanged: true,
  preferredDistance: 110.0,
  projectileSpeed: 100.0,
  projectileDamage: 8.0,
);

const EnemyDef yokaiGoliathDef = EnemyDef(
  id: 'yokai_goliath',
  name: 'Yokai Goliath',
  creditCost: 999,
  baseHp: 1500.0,
  speed: 22.0,
  contactDamage: 30.0,
  attackInterval: 1.5,
  knockbackResist: 0.90,
  radius: 18.0,
  xpValue: 50,
  colorHex: 0xFF8A2BE2,
  isBoss: true,
);

const List<EnemyDef> allEnemies = [
  swarmlingDef,
  runnerDef,
  bruteDef,
  spitterDef,
  yokaiGoliathDef,
];

