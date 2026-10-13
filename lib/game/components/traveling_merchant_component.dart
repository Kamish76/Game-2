import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../bonkhold_game.dart';
import '../../ui/overlays/overlay_ids.dart';

enum MerchantState {
  arriving,
  parked,
  departing,
}

/// The Traveling Merchant cart that periodically visits the Bastion.
/// Stays parked for a 15-second window. Tapping opens the Caravanserai Shop modal.
class TravelingMerchantComponent extends PositionComponent
    with HasGameReference<BonkholdGame>, TapCallbacks {
  TravelingMerchantComponent({
    required Vector2 position,
    this.dockRadius = 38.0,
    this.stayDuration = 15.0,
  })  : _remainingStay = stayDuration,
        super(
          position: position,
          size: Vector2.all(28.0),
          anchor: Anchor.center,
          priority: 26,
        );

  final double dockRadius;
  final double stayDuration;

  MerchantState state = MerchantState.arriving;
  double _remainingStay;
  final double _walkSpeed = 55.0;
  double _bobTimer = 0.0;
  double _approachAngle = 0.0;

  double get remainingStay => _remainingStay;

  // Visual paints
  final Paint _cartWoodPaint = Paint()..color = const Color(0xFF78350F);
  final Paint _canopyPaint = Paint()..color = const Color(0xFF0284C7);
  final Paint _canopyStripePaint = Paint()..color = const Color(0xFFF59E0B);
  final Paint _wheelPaint = Paint()..color = const Color(0xFF1E293B);
  final Paint _lanternPaint = Paint()..color = const Color(0xFFFBBF24);
  final Paint _shadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.35)
    ..style = PaintingStyle.fill;
  final Paint _timerRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  void onLoad() {
    super.onLoad();
    _approachAngle = math.atan2(position.y, position.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bobTimer += dt * 4.0;

    final double px = position.x;
    final double py = position.y;
    final double dist = math.sqrt(px * px + py * py);

    switch (state) {
      case MerchantState.arriving:
        if (dist > dockRadius) {
          final double step = _walkSpeed * dt;
          position.x -= (px / dist) * step;
          position.y -= (py / dist) * step;
        } else {
          // Dock at perimeter
          state = MerchantState.parked;
          position.x = dockRadius * math.cos(_approachAngle);
          position.y = dockRadius * math.sin(_approachAngle);
        }
        break;

      case MerchantState.parked:
        _remainingStay -= dt;
        if (_remainingStay <= 0) {
          state = MerchantState.departing;
        }
        break;

      case MerchantState.departing:
        // Walk back outward away from center
        final double step = _walkSpeed * dt;
        final double dirX = dist > 0.001 ? px / dist : math.cos(_approachAngle);
        final double dirY = dist > 0.001 ? py / dist : math.sin(_approachAngle);
        position.x += dirX * step;
        position.y += dirY * step;

        if (dist > 180.0) {
          game.onMerchantDeparted();
          removeFromParent();
        }
        break;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (state == MerchantState.parked || state == MerchantState.arriving) {
      // Pause game and open Caravanserai Shop
      game.runState.isPaused = true;
      game.pauseEngine();
      game.overlays.add(OverlayIds.merchant);
    }
  }

  @override
  void render(Canvas canvas) {
    final double bobOffset = math.sin(_bobTimer) * 1.0;

    // Drop shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(14.0, 25.0),
        width: 22.0,
        height: 7.0,
      ),
      _shadowPaint,
    );

    canvas.save();
    canvas.translate(0, bobOffset);

    // Cart body
    canvas.drawRect(const Rect.fromLTWH(4.0, 11.0, 20.0, 10.0), _cartWoodPaint);

    // Canopy roof with stripes
    final Path canopyPath = Path()
      ..moveTo(2.0, 11.0)
      ..lineTo(7.0, 3.0)
      ..lineTo(21.0, 3.0)
      ..lineTo(26.0, 11.0)
      ..close();
    canvas.drawPath(canopyPath, _canopyPaint);

    // Canopy stripes
    canvas.drawRect(const Rect.fromLTWH(9.0, 3.0, 4.0, 8.0), _canopyStripePaint);
    canvas.drawRect(const Rect.fromLTWH(16.0, 3.0, 4.0, 8.0), _canopyStripePaint);

    // Wagon wheels
    canvas.drawCircle(const Offset(7.0, 21.0), 3.5, _wheelPaint);
    canvas.drawCircle(const Offset(21.0, 21.0), 3.5, _wheelPaint);

    // Lantern hanging on side
    canvas.drawCircle(const Offset(25.0, 13.0), 2.5, _lanternPaint);

    canvas.restore();

    // Timer ring & "[SHOP]" banner when parked
    if (state == MerchantState.parked) {
      final double progress = (_remainingStay / stayDuration).clamp(0.0, 1.0);
      _timerRingPaint.color = progress > 0.3 ? const Color(0xFF38BDF8) : const Color(0xFFEF4444);

      // Arc countdown ring
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(14.0, -4.0), radius: 6.0),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        _timerRingPaint,
      );
    }
  }
}
