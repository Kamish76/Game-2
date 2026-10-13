import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';

/// An XP shard or Gold coin on the field that auto-vacuums towards the Bastion at (0, 0).
class PickupComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  PickupComponent({
    required Vector2 position,
    required this.value,
    this.isGold = false,
  }) : super(
          position: position,
          size: Vector2.all(isGold ? 6.0 : (value >= 25 ? 8.0 : (value >= 5 ? 6.0 : 4.0))),
          anchor: Anchor.center,
          priority: 5,
        ) {
    _initColors();
  }

  final int value;
  final bool isGold;

  double _vx = 0.0;
  double _vy = 0.0;
  bool _isAttracted = false;

  late final Paint _fillPaint;
  late final Paint _corePaint;

  void _initColors() {
    _fillPaint = Paint();
    _corePaint = Paint()..color = const Color(0xFFFFFFFF);

    if (isGold) {
      _fillPaint.color = const Color(0xFFFFD700);
    } else if (value >= 25) {
      _fillPaint.color = const Color(0xFFFF9900); // Gold / orange radiant gem
    } else if (value >= 5) {
      _fillPaint.color = const Color(0xFF3B82F6); // Sapphire blue
    } else {
      _fillPaint.color = const Color(0xFF43D365); // Emerald green
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    final double px = position.x;
    final double py = position.y;
    final double distSq = px * px + py * py;
    final double dist = math.sqrt(distSq);

    // Check absorption into Bastion core
    if (dist <= 12.0) {
      game.onPickupAbsorbed(this);
      removeFromParent();
      return;
    }

    // Check attraction radius
    final double attractRadius = game.runState.stats.attraction;
    if (!_isAttracted && dist <= attractRadius) {
      _isAttracted = true;
    }

    if (_isAttracted) {
      // Accelerate toward (0,0) at 300 px/s^2
      const double accel = 350.0;
      if (dist > 0.001) {
        final double dirX = -px / dist;
        final double dirY = -py / dist;
        _vx += dirX * accel * dt;
        _vy += dirY * accel * dt;
      }
      position.x += _vx * dt;
      position.y += _vy * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final double halfW = size.x / 2;
    final double halfH = size.y / 2;

    if (isGold) {
      // Round coin
      canvas.drawCircle(Offset(halfW, halfH), halfW, _fillPaint);
      canvas.drawCircle(Offset(halfW, halfH), halfW * 0.4, _corePaint);
    } else {
      // Diamond shard
      canvas.save();
      canvas.translate(halfW, halfH);
      canvas.rotate(math.pi / 4);
      final double r = halfW * 0.9;
      canvas.drawRect(Rect.fromLTWH(-r, -r, r * 2, r * 2), _fillPaint);
      canvas.drawRect(Rect.fromLTWH(-r * 0.4, -r * 0.4, r * 0.8, r * 0.8), _corePaint);
      canvas.restore();
    }
  }
}
