import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/game_config.dart';

/// Placeholder arena floor: fills the 180x320 virtual canvas with a
/// 16px grid so pixel scaling is easy to eyeball.
class ArenaBackground extends PositionComponent {
  ArenaBackground()
      : super(
          size: Vector2(GameConfig.virtualWidth, GameConfig.virtualHeight),
          anchor: Anchor.center,
          priority: -100,
        );

  static const double _cell = 16;
  final Paint _fill = Paint()..color = Palette.arena;
  final Paint _grid = Paint()
    ..color = Palette.arenaGrid
    ..strokeWidth = 1;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _fill);
    for (double x = 0; x <= size.x; x += _cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _grid);
    }
    for (double y = 0; y <= size.y; y += _cell) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _grid);
    }
  }
}
