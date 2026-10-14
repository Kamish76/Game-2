import 'package:flutter/material.dart';

import '../../game/bonkhold_game.dart';
import '../../models/meta_talents.dart';
import '../../systems/meta_repository.dart';
import 'overlay_ids.dart';

/// Permanent talent tree overlay accessed between runs.
/// Allows spending permanent Silver currency on structural Bastion upgrades.
class ShrineOfHeritageOverlay extends StatefulWidget {
  const ShrineOfHeritageOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  State<ShrineOfHeritageOverlay> createState() => _ShrineOfHeritageOverlayState();
}

class _ShrineOfHeritageOverlayState extends State<ShrineOfHeritageOverlay> {
  final MetaRepository _repo = MetaRepository.instance;

  Future<void> _upgradeTalent(MetaTalentType type) async {
    final success = await _repo.upgradeTalent(type);
    if (success && mounted) {
      setState(() {});
    }
  }

  Future<void> _resetTalents() async {
    await _repo.resetTalents();
    if (mounted) {
      setState(() {});
    }
  }

  void _closeShrine() {
    widget.game.overlays.remove(OverlayIds.shrine);
  }

  @override
  Widget build(BuildContext context) {
    final int silver = _repo.silver;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, color: Color(0xFF818CF8), size: 22),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'SHRINE OF HERITAGE',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF818CF8),
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF818CF8).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF818CF8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.toll, color: Color(0xFF93C5FD), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$silver S',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF93C5FD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subtitle & Reset Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Permanent Bastion Talents',
                      style: TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                    TextButton(
                      onPressed: _resetTalents,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Colors.white38,
                      ),
                      child: const Text('RESET ALL', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Talent List
                Expanded(
                  child: ListView(
                    children: allMetaTalents.values.map((talent) {
                      final int rank = _repo.getTalentRank(talent.type);
                      final bool isMax = rank >= talent.maxRank;
                      final int cost = talent.getCostForRank(rank);
                      final bool canAfford = !isMax && silver >= cost;

                      return Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isMax
                                ? const Color(0xFF10B981).withValues(alpha: 0.5)
                                : const Color(0xFF334155),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          talent.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMax
                                              ? const Color(0xFF10B981).withValues(alpha: 0.25)
                                              : Colors.white12,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rank $rank/${talent.maxRank}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isMax
                                                ? const Color(0xFF10B981)
                                                : Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    talent.description,
                                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: canAfford ? () => _upgradeTalent(talent.type) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMax
                                    ? Colors.white12
                                    : const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: Text(
                                isMax ? 'MAX' : '$cost S',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _closeShrine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'BACK TO RESULTS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
