import 'dart:async';

import 'package:flutter/material.dart';

import '../../game/bonkhold_game.dart';

/// Debug-only info panel (FPS for now). Entity counts and cheat buttons
/// (god mode, grant XP, spawn boss) are added in later milestones.
class DebugOverlay extends StatefulWidget {
  const DebugOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh at 4 Hz; no need to rebuild Flutter widgets every frame.
    _timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fps = widget.game.fpsCounter.fps;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          color: Colors.black54,
          child: Text(
            'FPS ${fps.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
