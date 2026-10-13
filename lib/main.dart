import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/bonkhold_game.dart';
import 'ui/overlays/debug_overlay.dart';
import 'ui/overlays/overlay_ids.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait-locked on mobile. No-op on web (the canvas is letterboxed instead).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const BonkholdApp());
}

class BonkholdApp extends StatelessWidget {
  const BonkholdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BONKHOLD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const GameScreen(),
    );
  }
}

/// Hosts the Flame game and its Flutter overlays (HUD, menus, debug).
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Created once so hot reload / rebuilds do not restart the run.
  late final BonkholdGame _game = BonkholdGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<BonkholdGame>(
        game: _game,
        overlayBuilderMap: {
          OverlayIds.debug: (context, game) => DebugOverlay(game: game),
        },
        initialActiveOverlays: [if (kDebugMode) OverlayIds.debug],
      ),
    );
  }
}
