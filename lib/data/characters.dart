import '../models/character_def.dart';

const CharacterDef kitsuneSpireDef = CharacterDef(
  id: 'kitsune_spire',
  name: 'Kitsune Spire',
  tagline: 'Fortune favors the bold.',
  startingWeaponId: 'ember_staff',
  baseLuck: 0.15,
  luckPerLevel: 0.015,
  baseHp: 100.0,
  attractionRadius: 48.0,
);

const List<CharacterDef> allCharacters = [
  kitsuneSpireDef,
];
