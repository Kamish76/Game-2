import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_talents.dart';

/// Persistence repository for permanent Silver currency and Shrine of Heritage talent ranks.
/// Decoupled from the Flame game loop and safe for asynchronous background reads/writes.
class MetaRepository {
  MetaRepository._();
  static final MetaRepository instance = MetaRepository._();

  SharedPreferences? _prefs;

  int _silver = 0;
  final Map<MetaTalentType, int> _ranks = <MetaTalentType, int>{};

  static const String _silverKey = 'bonkhold_meta_silver';
  static String _talentKey(MetaTalentType type) => 'bonkhold_meta_talent_${type.name}';

  int get silver => _silver;

  int getTalentRank(MetaTalentType type) => _ranks[type] ?? 0;

  /// Initializes the repository by loading saved silver and talent ranks.
  Future<void> init([SharedPreferences? preferences]) async {
    _prefs = preferences ?? await SharedPreferences.getInstance();
    _silver = _prefs?.getInt(_silverKey) ?? 0;

    for (final type in MetaTalentType.values) {
      _ranks[type] = _prefs?.getInt(_talentKey(type)) ?? 0;
    }
  }

  /// Adds Silver Coins earned from run completion or boss rewards.
  Future<void> addSilver(int amount) async {
    if (amount <= 0) return;
    _silver += amount;
    await _prefs?.setInt(_silverKey, _silver);
  }

  /// Attempts to spend Silver Coins. Returns `true` if successful.
  Future<bool> spendSilver(int amount) async {
    if (amount <= 0 || _silver < amount) return false;
    _silver -= amount;
    await _prefs?.setInt(_silverKey, _silver);
    return true;
  }

  /// Upgrades a talent by 1 rank if affordable and not capped.
  Future<bool> upgradeTalent(MetaTalentType type) async {
    final def = allMetaTalents[type];
    if (def == null) return false;

    final currentRank = getTalentRank(type);
    if (currentRank >= def.maxRank) return false;

    final cost = def.getCostForRank(currentRank);
    if (cost < 0 || _silver < cost) return false;

    _silver -= cost;
    _ranks[type] = currentRank + 1;

    await _prefs?.setInt(_silverKey, _silver);
    await _prefs?.setInt(_talentKey(type), _ranks[type]!);
    return true;
  }

  /// Resets all talent ranks to 0 and refunds the total silver spent.
  Future<void> resetTalents() async {
    int totalRefund = 0;
    for (final entry in _ranks.entries) {
      final def = allMetaTalents[entry.key];
      if (def == null) continue;
      for (int r = 0; r < entry.value; r++) {
        totalRefund += def.getCostForRank(r);
      }
      _ranks[entry.key] = 0;
      await _prefs?.setInt(_talentKey(entry.key), 0);
    }

    _silver += totalRefund;
    await _prefs?.setInt(_silverKey, _silver);
  }

  /// Clears all stored data (used for testing or hard data wipes).
  Future<void> clearAll() async {
    _silver = 0;
    _ranks.clear();
    for (final type in MetaTalentType.values) {
      _ranks[type] = 0;
    }
    await _prefs?.remove(_silverKey);
    for (final type in MetaTalentType.values) {
      await _prefs?.remove(_talentKey(type));
    }
  }

  /// Evaluates active passive stat multipliers from unlocked talent ranks.
  MetaProgressionStats getActiveStats() {
    return MetaProgressionStats.fromRanks(_ranks);
  }
}
