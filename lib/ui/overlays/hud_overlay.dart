import 'package:flutter/material.dart';

import '../../game/bonkhold_game.dart';
import '../../models/run_state.dart';
import 'overlay_ids.dart';

/// Responsive In-Game HUD overlay displaying run timer, kills, gold, XP bar,
/// Bastion hull integrity (HP & Shield), and structured equipment trays.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final BonkholdGame game;

  String _formatTime(double totalSeconds) {
    final int sec = totalSeconds.toInt();
    final int minutes = sec ~/ 60;
    final int remainingSec = sec % 60;
    final String mStr = minutes.toString().padLeft(2, '0');
    final String sStr = remainingSec.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final runState = game.runState;

    return SizedBox.expand(
      child: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Top HUD Bar & XP Bar
                Positioned(
                  top: 4,
                  left: 8,
                  right: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top controls & counters
                      Row(
                        children: [
                          // Pause button
                          InkWell(
                            onTap: () {
                              runState.isPaused = true;
                              game.overlays.add(OverlayIds.pause);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Icon(Icons.pause, size: 16, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Run Timer
                          ValueListenableBuilder<double>(
                            valueListenable: runState.elapsedSeconds,
                            builder: (context, seconds, _) {
                              return _hudBadge(
                                icon: Icons.timer_outlined,
                                text: _formatTime(seconds),
                                color: Colors.white,
                              );
                            },
                          ),
                          const Spacer(),

                          // Kills counter
                          ValueListenableBuilder<int>(
                            valueListenable: runState.kills,
                            builder: (context, kills, _) {
                              return _hudBadge(
                                icon: Icons.flash_on,
                                text: '$kills',
                                color: const Color(0xFFE43B44),
                              );
                            },
                          ),
                          const SizedBox(width: 6),

                          // Gold counter
                          ValueListenableBuilder<int>(
                            valueListenable: runState.gold,
                            builder: (context, gold, _) {
                              return _hudBadge(
                                icon: Icons.monetization_on,
                                text: '$gold',
                                color: const Color(0xFFFFD700),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Full-width XP Bar & Level
                      ValueListenableBuilder<int>(
                        valueListenable: runState.level,
                        builder: (context, level, _) {
                          return ValueListenableBuilder<double>(
                            valueListenable: runState.xpProgress,
                            builder: (context, progress, _) {
                              return Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: const Color(0xFF43D365).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: progress.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF43D365),
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF43D365).withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        'LVL $level',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Boss Health Bar (appears when a Boss is alive)
                      ValueListenableBuilder<BossInfo?>(
                        valueListenable: runState.activeBoss,
                        builder: (context, boss, _) {
                          if (boss == null) return const SizedBox.shrink();
                          final double fraction = (boss.hp / boss.maxHp).clamp(0.0, 1.0);
                          return Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: const Color(0xFF8A2BE2), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8A2BE2).withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: fraction,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8A2BE2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'BOSS: ${boss.name.toUpperCase()} (${(fraction * 100).toInt()}%)',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFD700),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Overtime vignette pulse overlay
                Positioned.fill(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: runState.isOvertime,
                    builder: (context, isOvertime, _) {
                      if (!isOvertime) return const SizedBox.shrink();
                      return IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                              width: 4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Hull Status Bar & Equipment Trays
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Equipment trays: 4 Weapons and 4 Tomes
                      ValueListenableBuilder<int>(
                        valueListenable: runState.loadoutVersion,
                        builder: (context, _, _) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Weapons row (4 slots)
                              Row(
                                children: [
                                  for (int i = 0; i < 4; i++) ...[
                                    if (i > 0) const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildEquipmentSlot(
                                        prefix: 'W${i + 1}',
                                        name: i < runState.weapons.length
                                            ? runState.weapons[i].def.name.split(' ').first
                                            : '--',
                                        level: i < runState.weapons.length
                                            ? runState.weapons[i].level
                                            : null,
                                        color: const Color(0xFFFF5722),
                                        bgColor: const Color(0xFF262B44),
                                        isOccupied: i < runState.weapons.length,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              // Tomes row (4 slots)
                              Row(
                                children: [
                                  for (int i = 0; i < 4; i++) ...[
                                    if (i > 0) const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildEquipmentSlot(
                                        prefix: 'T${i + 1}',
                                        name: i < runState.tomes.length
                                            ? runState.tomes[i].def.name.split(' ').last
                                            : '--',
                                        level: i < runState.tomes.length
                                            ? runState.tomes[i].level
                                            : null,
                                        color: const Color(0xFF38BDF8),
                                        bgColor: const Color(0xFF1E293B),
                                        isOccupied: i < runState.tomes.length,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 5),

                      // Bastion HP Bar & Shield
                      ValueListenableBuilder<double>(
                        valueListenable: runState.maxHp,
                        builder: (context, maxHp, _) {
                          return ValueListenableBuilder<double>(
                            valueListenable: runState.hp,
                            builder: (context, hp, _) {
                              return ValueListenableBuilder<double>(
                                valueListenable: runState.shield,
                                builder: (context, shield, _) {
                                  final double fraction = (hp / maxHp).clamp(0.0, 1.0);
                                  final bool hasShield = shield > 0;
                                  return Container(
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: hasShield
                                            ? const Color(0xFF38BDF8)
                                            : const Color(0xFFE43B44),
                                        width: 1,
                                      ),
                                      boxShadow: hasShield
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                                blurRadius: 4,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        FractionallySizedBox(
                                          widthFactor: fraction,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE43B44),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            hasShield
                                                ? 'BASTION HP: ${hp.round()} / ${maxHp.round()}  [SHIELD: ${shield.round()}]'
                                                : 'BASTION HP: ${hp.round()} / ${maxHp.round()}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentSlot({
    required String prefix,
    required String name,
    required int? level,
    required Color color,
    required Color bgColor,
    required bool isOccupied,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isOccupied ? bgColor : Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isOccupied ? color.withValues(alpha: 0.8) : Colors.white12,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          level != null ? '$prefix: $name L$level' : '$prefix: --',
          style: TextStyle(
            fontSize: 8,
            fontWeight: isOccupied ? FontWeight.bold : FontWeight.normal,
            color: isOccupied ? Colors.white : Colors.white30,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _hudBadge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
