import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/game_config.dart';

/// The tower at the center of the arena. Placeholder rendering only (M0).
///
/// Future milestones add: HP / shield (M1), weapon mounts (M2), stats (M4).
/// See docs/04_characters/kitsune_spire.md.
class Bastion extends PositionComponent {
  Bastion()
      : super(
          position: Vector2.zero(),
          size: Vector2.all(32),
          anchor: Anchor.center,
        );

  static const Rect _bodyRect = Rect.fromLTWH(4, 4, 24, 24);
  static const Rect _coreRect = Rect.fromLTWH(12, 12, 8, 8);
  final Paint _body = Paint()..color = Palette.bastion;
  final Paint _core = Paint()..color = Palette.bastionCore;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(_bodyRect, _body);
    canvas.drawRect(_coreRect, _core);
  }
}
