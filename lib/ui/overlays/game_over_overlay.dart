import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../game/bonkhold_game.dart';

/// Results and Game Over screen presented when Bastion HP reaches 0.
/// Displays master score formula results and persists all-time high score.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  int _highScore = 0;
  bool _isNewHighScore = false;
  late final int _finalScore;

  static const String _highScoreKey = 'bonkhold_high_score';

  @override
  void initState() {
    super.initState();
    _finalScore = widget.game.runState.computeFinalScore();
    _loadAndSaveHighScore();
  }

  Future<void> _loadAndSaveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prevHigh = prefs.getInt(_highScoreKey) ?? 0;
      if (_finalScore > prevHigh) {
        await prefs.setInt(_highScoreKey, _finalScore);
        if (mounted) {
          setState(() {
            _highScore = _finalScore;
            _isNewHighScore = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _highScore = prevHigh;
            _isNewHighScore = false;
          });
        }
      }
    } catch (_) {
      // Graceful fallback for test environments without SharedPreferences mock
      if (mounted) {
        setState(() {
          _highScore = _finalScore;
        });
      }
    }
  }

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
    final runState = widget.game.runState;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE43B44),
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'The Bastion has fallen.',
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
                const SizedBox(height: 16),

                // Final Score Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262B44),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isNewHighScore ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isNewHighScore ? '★ NEW HIGH SCORE! ★' : 'FINAL SCORE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isNewHighScore ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_finalScore',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'All-Time Best: $_highScore',
                        style: const TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Run Stats Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C2C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF262B44)),
                  ),
                  child: Column(
                    children: [
                      _statRow('Time Survived', _formatTime(runState.elapsedSeconds.value)),
                      const Divider(color: Colors.white12, height: 14),
                      _statRow(
                        'Enemies Slain',
                        '${runState.kills.value} (Elites: ${runState.eliteKills.value}, Bosses: ${runState.bossKills.value})',
                      ),
                      const Divider(color: Colors.white12, height: 14),
                      _statRow('Level Reached', '${runState.level.value}'),
                      const Divider(color: Colors.white12, height: 14),
                      _statRow('Gold Collected', '${runState.gold.value}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Try Again Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => widget.game.restartRun(),
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
                        fontSize: 13,
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
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

