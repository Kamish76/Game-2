import 'dart:ui';

/// Rarity tier for weapons, tomes, and upgrade rolls.
/// Multipliers scale upgrade increments from 1.0x (Common) to 2.0x (Legendary).
enum Rarity {
  common(1.0, Color(0xFFB0B0B0), 60, 'Common'),
  uncommon(1.2, Color(0xFF43D365), 25, 'Uncommon'),
  rare(1.4, Color(0xFF3B82F6), 10, 'Rare'),
  epic(1.6, Color(0xFFA855F7), 4, 'Epic'),
  legendary(2.0, Color(0xFFFBBF24), 1, 'Legendary');

  const Rarity(this.multiplier, this.color, this.baseWeight, this.label);

  final double multiplier;
  final Color color;
  final int baseWeight;
  final String label;
}
