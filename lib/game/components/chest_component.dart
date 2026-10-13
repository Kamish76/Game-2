import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../bonkhold_game.dart';

/// Sealed chest dropped by Elites and Bosses.
/// Vacuums towards the Bastion and parks on the moat ring (R=32px) until tapped.
class ChestComponent extends PositionComponent
    with HasGameReference<BonkholdGame>, TapCallbacks {
  ChestComponent({
    required Vector2 position,
    this.isGolden = false,
  }) : super(
          position: position,
          size: Vector2.all(22.0),
          anchor: Anchor.center,
          priority: 25,
        );

  final bool isGolden;

  bool isParked = false;
  double _currentSpeed = 0.0;
  double _bobTimer = 0.0;

  static const double moatRadius = 32.0;
  static const double vacuumAccel = 350.0;
  static const double maxVacuumSpeed = 220.0;

  final Paint _woodPaint = Paint()..color = const Color(0xFF8B4513);
  final Paint _goldPaint = Paint()..color = const Color(0xFFF59E0B);
  final Paint _trimPaint = Paint()..color = const Color(0xFFFBBF24);
  final Paint _ironTrimPaint = Paint()..color = const Color(0xFF475569);
  final Paint _lockPaint = Paint()..color = const Color(0xFFFEF08A);
  final Paint _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.35)
    ..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);

    if (!isParked) {
      final double px = position.x;
      final double py = position.y;
      final double dist = math.sqrt(px * px + py * py);

      if (dist > moatRadius) {
        _currentSpeed = math.min(maxVacuumSpeed, _currentSpeed + vacuumAccel * dt);
        final double step = _currentSpeed * dt;
        position.x -= (px / dist) * step;
        position.y -= (py / dist) * step;
      } else {
        // Park neatly on the moat circle
        isParked = true;
        final double angle = math.atan2(py, px);
        position.x = moatRadius * math.cos(angle);
        position.y = moatRadius * math.sin(angle);
        game.onChestParked(this);
      }
    } else {
      _bobTimer += dt * 3.5;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    game.openChest(this);
  }

  @override
  void render(Canvas canvas) {
    final double bobOffset = isParked ? math.sin(_bobTimer) * 1.5 : 0.0;

    // Subtle drop shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(11.0, 19.0),
        width: 16.0,
        height: 6.0,
      ),
      _shadowPaint,
    );

    canvas.save();
    canvas.translate(0, bobOffset);

    final Paint bodyPaint = isGolden ? _goldPaint : _woodPaint;
    final Paint trimPaint = isGolden ? _trimPaint : _ironTrimPaint;

    // Chest base
    const Rect baseRect = Rect.fromLTWH(3.0, 7.0, 16.0, 11.0);
    canvas.drawRect(baseRect, bodyPaint);

    // Chest lid (rounded top)
    final RRect lidRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.0, 2.0, 18.0, 7.0),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(lidRect, bodyPaint);

    // Trims and bands
    canvas.drawRect(const Rect.fromLTWH(2.0, 2.0, 2.0, 16.0), trimPaint);
    canvas.drawRect(const Rect.fromLTWH(18.0, 2.0, 2.0, 16.0), trimPaint);
    canvas.drawRect(const Rect.fromLTWH(2.0, 7.0, 18.0, 1.8), trimPaint);

    // Center latch / keyhole
    const Rect latchRect = Rect.fromLTWH(9.5, 6.5, 3.0, 4.0);
    canvas.drawRect(latchRect, _lockPaint);

    // Golden glow ring if golden chest
    if (isGolden) {
      final Paint glowPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.35 + 0.15 * math.sin(_bobTimer))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(const Offset(11.0, 10.0), 12.0, glowPaint);
    }

    canvas.restore();
  }
}
