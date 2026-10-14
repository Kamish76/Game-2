/// Definition of permanent meta-talents upgradeable at the Shrine of Heritage.
enum MetaTalentType {
  reinforcedMasonry, // +2% Base Max HP per rank (max 10 ranks)
  forgedIron, // +1 Base Armor per rank (max 5 ranks)
  spiritBlessing, // +2% Base Luck per rank (max 10 ranks)
  goldenAura, // +5% In-Run Gold drop yield per rank (max 5 ranks)
  scribesWit, // +1 Starting Reroll, Skip, and Banish charge per rank (max 3 ranks)
}

/// Metadata and mathematical pricing curve for a meta-talent.
class MetaTalentDef {
  const MetaTalentDef({
    required this.type,
    required this.name,
    required this.description,
    required this.maxRank,
    required this.baseCost,
    required this.costPerRank,
    required this.effectPerRank,
  });

  final MetaTalentType type;
  final String name;
  final String description;
  final int maxRank;
  final int baseCost;
  final int costPerRank;
  final double effectPerRank;

  /// Returns Silver cost to upgrade from [currentRank] to [currentRank + 1].
  /// Returns -1 if already at [maxRank].
  int getCostForRank(int currentRank) {
    if (currentRank >= maxRank) return -1;
    return baseCost + (currentRank * costPerRank);
  }
}

/// Registry of all 5 permanent meta-progression talents.
const Map<MetaTalentType, MetaTalentDef> allMetaTalents = {
  MetaTalentType.reinforcedMasonry: MetaTalentDef(
    type: MetaTalentType.reinforcedMasonry,
    name: 'Reinforced Masonry',
    description: '+2% Bastion Max HP per rank',
    maxRank: 10,
    baseCost: 15,
    costPerRank: 10,
    effectPerRank: 0.02,
  ),
  MetaTalentType.forgedIron: MetaTalentDef(
    type: MetaTalentType.forgedIron,
    name: 'Forged Iron',
    description: '+1 Flat Armor per rank',
    maxRank: 5,
    baseCost: 25,
    costPerRank: 20,
    effectPerRank: 1.0,
  ),
  MetaTalentType.spiritBlessing: MetaTalentDef(
    type: MetaTalentType.spiritBlessing,
    name: 'Spirit Blessing',
    description: '+2% Base Luck per rank',
    maxRank: 10,
    baseCost: 20,
    costPerRank: 15,
    effectPerRank: 0.02,
  ),
  MetaTalentType.goldenAura: MetaTalentDef(
    type: MetaTalentType.goldenAura,
    name: 'Golden Aura',
    description: '+5% Gold drop yield per rank',
    maxRank: 5,
    baseCost: 30,
    costPerRank: 25,
    effectPerRank: 0.05,
  ),
  MetaTalentType.scribesWit: MetaTalentDef(
    type: MetaTalentType.scribesWit,
    name: "Scribe's Wit",
    description: '+1 Starting Reroll, Skip, and Banish charge per rank',
    maxRank: 3,
    baseCost: 50,
    costPerRank: 50,
    effectPerRank: 1.0,
  ),
};

/// Evaluated bonuses from all unlocked meta-talent ranks.
class MetaProgressionStats {
  const MetaProgressionStats({
    this.hpBonusPercent = 0.0,
    this.bonusArmor = 0.0,
    this.bonusLuck = 0.0,
    this.goldMultiplier = 1.0,
    this.extraDraftCharges = 0,
  });

  final double hpBonusPercent;
  final double bonusArmor;
  final double bonusLuck;
  final double goldMultiplier;
  final int extraDraftCharges;

  static const MetaProgressionStats zero = MetaProgressionStats();

  /// Computes evaluated stats from a map of talent ranks.
  factory MetaProgressionStats.fromRanks(Map<MetaTalentType, int> ranks) {
    double hpBonus = 0.0;
    double armor = 0.0;
    double luck = 0.0;
    double goldMult = 1.0;
    int draftCharges = 0;

    for (final entry in ranks.entries) {
      final def = allMetaTalents[entry.key];
      if (def == null) continue;
      final int rank = entry.value.clamp(0, def.maxRank);

      switch (entry.key) {
        case MetaTalentType.reinforcedMasonry:
          hpBonus += rank * def.effectPerRank;
          break;
        case MetaTalentType.forgedIron:
          armor += rank * def.effectPerRank;
          break;
        case MetaTalentType.spiritBlessing:
          luck += rank * def.effectPerRank;
          break;
        case MetaTalentType.goldenAura:
          goldMult += rank * def.effectPerRank;
          break;
        case MetaTalentType.scribesWit:
          draftCharges += (rank * def.effectPerRank).round();
          break;
      }
    }

    return MetaProgressionStats(
      hpBonusPercent: hpBonus,
      bonusArmor: armor,
      bonusLuck: luck,
      goldMultiplier: goldMult,
      extraDraftCharges: draftCharges,
    );
  }
}
