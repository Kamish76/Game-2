import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Floating pixel combat text displaying damage dealt to an enemy.
/// Rises upward and fades out over 0.5s.
class DamageNumberComponent extends PositionComponent {
  DamageNumberComponent({
    required Vector2 position,
    required double damage,
    required this.isCrit,
  }) : super(
          position: position,
          size: Vector2(24, 12),
          anchor: Anchor.center,
          priority: 50,
        ) {
    _damageText = damage.round().toString();
    _textColor = isCrit ? const Color(0xFFFFD700) : const Color(0xFFFFFFFF);
    _textPainter = TextPainter(
      text: TextSpan(
        text: _damageText,
        style: TextStyle(
          color: _textColor,
          fontSize: isCrit ? 8.0 : 6.0,
          fontWeight: isCrit ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  final bool isCrit;
  late final String _damageText;
  late final Color _textColor;
  late final TextPainter _textPainter;

  double _lifetime = 0.0;
  static const double _maxLifetime = 0.5;

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    position.y -= 18.0 * dt; // Rise slowly upward

    if (_lifetime >= _maxLifetime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final double alpha = (1.0 - (_lifetime / _maxLifetime)).clamp(0.0, 1.0);
    if (alpha <= 0.0) return;

    canvas.save();
    // Fade out text
    _textPainter.paint(
      canvas,
      Offset(-_textPainter.width / 2, -_textPainter.height / 2),
    );
    canvas.restore();
  }
}
