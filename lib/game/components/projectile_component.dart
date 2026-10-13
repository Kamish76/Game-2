import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';

/// Expanding visual shockwave / fireball burst on impact.
class ExplosionBurstComponent extends PositionComponent {
  ExplosionBurstComponent({
    required Vector2 position,
    required this.maxRadius,
  }) : super(
          position: position,
          size: Vector2.all(maxRadius * 2),
          anchor: Anchor.center,
          priority: 25,
        );

  final double maxRadius;
  double _lifetime = 0.0;
  static const double _duration = 0.22;

  final Paint _fillPaint = Paint()
    ..color = const Color(0x66FF5722)
    ..style = PaintingStyle.fill;

  final Paint _ringPaint = Paint()
    ..color = const Color(0xFFFFCC00)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    if (_lifetime >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final double progress = (_lifetime / _duration).clamp(0.0, 1.0);
    final double r = maxRadius * progress;
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);

    _fillPaint.color = const Color(0xFFFF5722).withValues(alpha: 0.4 * alpha);
    _ringPaint.color = const Color(0xFFFFD700).withValues(alpha: alpha);

    canvas.drawCircle(Offset(maxRadius, maxRadius), r, _fillPaint);
    canvas.drawCircle(Offset(maxRadius, maxRadius), r, _ringPaint);
  }
}

/// Projectile fired by weapons (e.g. Ember Staff fireball).
/// Explodes on impact, damaging all entities in blast radius.
class ProjectileComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  ProjectileComponent({
    required Vector2 position,
    required this.dirX,
    required this.dirY,
    required this.speed,
    required this.damage,
    required this.blastRadius,
    required this.knockback,
    required this.isCrit,
    required this.maxDistance,
  }) : super(
          position: position,
          size: Vector2.all(8.0),
          anchor: Anchor.center,
          priority: 20,
        );

  final double dirX;
  final double dirY;
  final double speed;
  final double damage;
  final double blastRadius;
  final double knockback;
  final bool isCrit;
  final double maxDistance;

  double _traveled = 0.0;

  // Pre-allocated reusable buffer for collision queries
  static final List<int> _hitBuffer = <int>[];

  final Paint _corePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _glowPaint = Paint()..color = const Color(0xFFFF5722);

  @override
  void update(double dt) {
    super.update(dt);

    final double step = speed * dt;
    position.x += dirX * step;
    position.y += dirY * step;
    _traveled += step;

    if (_traveled >= maxDistance) {
      removeFromParent();
      return;
    }

    // Check hit against enemies using SpatialHash
    game.spatialHash.queryRadius(position.x, position.y, 6.0, _hitBuffer);

    if (_hitBuffer.isNotEmpty) {
      _detonate();
    }
  }

  void _detonate() {
    // 1. Visual explosion
    final double effectiveBlast = blastRadius > 0 ? blastRadius : 12.0;
    game.world.add(
      ExplosionBurstComponent(
        position: position.clone(),
        maxRadius: effectiveBlast,
      ),
    );

    // 2. Query all enemies caught in blast radius
    game.spatialHash.queryRadius(position.x, position.y, effectiveBlast, _hitBuffer);

    for (int i = 0; i < _hitBuffer.length; i++) {
      final int enemyId = _hitBuffer[i];
      final enemy = game.findEnemyById(enemyId);
      if (enemy != null && enemy.isMounted) {
        // Compute knockback direction away from impact point
        final double dx = enemy.position.x - position.x;
        final double dy = enemy.position.y - position.y;
        final double dist = math.sqrt(dx * dx + dy * dy);
        final double kbDirX = dist > 0.001 ? dx / dist : dirX;
        final double kbDirY = dist > 0.001 ? dy / dist : dirY;

        enemy.takeDamage(
          damage: damage,
          isCrit: isCrit,
          kbDirX: kbDirX,
          kbDirY: kbDirY,
          kbAmount: knockback,
        );
      }
    }

    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final double halfW = size.x / 2;
    final double halfH = size.y / 2;

    // Glowing fireball
    canvas.drawCircle(Offset(halfW, halfH), halfW, _glowPaint);
    canvas.drawCircle(Offset(halfW, halfH), halfW * 0.45, _corePaint);
  }
}
