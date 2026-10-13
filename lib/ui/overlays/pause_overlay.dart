import 'package:flutter/material.dart';

import '../../data/items.dart';
import '../../game/bonkhold_game.dart';
import 'overlay_ids.dart';

/// Pause menu modal allowing the player to resume, restart, and inspect acquired Relics.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  Widget build(BuildContext context) {
    final ownedItems = game.runState.ownedItems;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),

                // Relics Section Header
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 16, color: Color(0xFFFBBF24)),
                    const SizedBox(width: 6),
                    Text(
                      'ACQUIRED RELICS (${ownedItems.values.fold<int>(0, (a, b) => a + b)})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFBBF24),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Relics List Container
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ownedItems.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'No relics acquired yet.\nDefeat Elites and Bosses to find Chests!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: ownedItems.length,
                          separatorBuilder: (context, _) => const Divider(
                            height: 10,
                            color: Colors.white12,
                          ),
                          itemBuilder: (context, index) {
                            final entry = ownedItems.entries.elementAt(index);
                            final item = itemsById[entry.key];
                            if (item == null) return const SizedBox.shrink();

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: item.rarity.color.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: item.rarity.color,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'x${entry.value}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.rarity.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),

                // Resume button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      game.runState.isPaused = false;
                      game.overlays.remove(OverlayIds.pause);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43D365),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'RESUME',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Restart button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      game.restartRun();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE43B44),
                      side: const BorderSide(color: Color(0xFFE43B44)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'RESTART RUN',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
