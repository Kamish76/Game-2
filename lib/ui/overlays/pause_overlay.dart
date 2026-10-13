import 'package:flutter/material.dart';

import '../../game/bonkhold_game.dart';
import 'overlay_ids.dart';

/// Pause menu modal allowing the player to resume or restart.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.80),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),

              // Resume button
              SizedBox(
                width: double.infinity,
                height: 44,
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
              const SizedBox(height: 12),

              // Restart button
              SizedBox(
                width: double.infinity,
                height: 44,
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
    );
  }
}
