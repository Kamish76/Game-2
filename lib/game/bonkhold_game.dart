import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../config/game_config.dart';
import 'components/arena_background.dart';
import 'components/bastion.dart';

/// Root Flame game.
///
/// World coordinates: (0,0) is the center of the screen where the Bastion
/// stands. The camera shows a fixed 180x320 virtual area.
class BonkholdGame extends FlameGame {
  BonkholdGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: GameConfig.virtualWidth,
            height: GameConfig.virtualHeight,
          ),
        );

  /// Measured frames per second, read by the debug overlay.
  final FpsComponent fpsCounter = FpsComponent();

  late final Bastion bastion;

  @override
  Color backgroundColor() => Palette.letterbox;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2.zero();

    bastion = Bastion();
    await world.addAll([
      ArenaBackground(),
      bastion,
    ]);
    add(fpsCounter);
  }
}
