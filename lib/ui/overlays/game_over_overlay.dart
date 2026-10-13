import 'package:flutter/material.dart';

import '../../game/bonkhold_game.dart';

/// Results and Game Over screen presented when Bastion HP reaches 0.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

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

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE43B44),
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'The Bastion has fallen.',
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 24),

              // Run Stats Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C2C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF262B44)),
                ),
                child: Column(
                  children: [
                    _statRow('Time Survived', _formatTime(runState.elapsedSeconds.value)),
                    const Divider(color: Colors.white12, height: 16),
                    _statRow('Enemies Slain', '${runState.kills.value}'),
                    const Divider(color: Colors.white12, height: 16),
                    _statRow('Level Reached', '${runState.level.value}'),
                    const Divider(color: Colors.white12, height: 16),
                    _statRow('Gold Collected', '${runState.gold.value}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Try Again Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => game.restartRun(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43B44),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
