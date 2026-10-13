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

/// Radial shockwave emitted by Pulse Aura centered at Bastion.
class RadialShockwaveComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  RadialShockwaveComponent({
    required this.maxRadius,
    required this.damage,
    required this.knockback,
    required this.isCrit,
  }) : super(
          position: Vector2.zero(),
          size: Vector2.all(maxRadius * 2),
          anchor: Anchor.center,
          priority: 22,
        );

  final double maxRadius;
  final double damage;
  final double knockback;
  final bool isCrit;

  double _lifetime = 0.0;
  static const double _duration = 0.25;
  final Set<int> _hitEnemyIds = <int>{};

  static final List<int> _queryBuffer = <int>[];

  final Paint _ringPaint = Paint()
    ..color = const Color(0xFF38BDF8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  final Paint _fillPaint = Paint()
    ..color = const Color(0x3338BDF8)
    ..style = PaintingStyle.fill;

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    final double progress = (_lifetime / _duration).clamp(0.0, 1.0);
    final double currentRadius = maxRadius * progress;

    // Hit enemies caught in expanding perimeter
    game.spatialHash.queryRadius(0, 0, currentRadius, _queryBuffer);
    for (int i = 0; i < _queryBuffer.length; i++) {
      final int enemyId = _queryBuffer[i];
      if (_hitEnemyIds.add(enemyId)) {
        final enemy = game.findEnemyById(enemyId);
        if (enemy != null && enemy.isMounted) {
          final double ex = enemy.position.x;
          final double ey = enemy.position.y;
          final double dist = math.sqrt(ex * ex + ey * ey);
          final double kbDirX = dist > 0.001 ? ex / dist : 1.0;
          final double kbDirY = dist > 0.001 ? ey / dist : 0.0;

          enemy.takeDamage(
            damage: damage,
            isCrit: isCrit,
            kbDirX: kbDirX,
            kbDirY: kbDirY,
            kbAmount: knockback,
          );
        }
      }
    }

    if (_lifetime >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final double progress = (_lifetime / _duration).clamp(0.0, 1.0);
    final double r = maxRadius * progress;
    final double alpha = (1.0 - progress).clamp(0.0, 1.0);

    _ringPaint.color = const Color(0xFF38BDF8).withValues(alpha: alpha);
    _fillPaint.color = const Color(0xFF0284C7).withValues(alpha: 0.25 * alpha);

    canvas.drawCircle(Offset(maxRadius, maxRadius), r, _fillPaint);
    canvas.drawCircle(Offset(maxRadius, maxRadius), r, _ringPaint);
  }
}

/// Projectile fired by weapons (e.g. Ember Staff fireball, Revolver bullet, Rail Sniper beam).
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
    this.pierce = 0,
    this.combustionDetonation = false,
    this.combustionDamage = 0.0,
    this.isFrozen = false,
  }) : remainingPierce = pierce,
       super(
          position: position,
          size: Vector2.all(speed >= 300 ? 10.0 : (blastRadius > 0 ? 8.0 : 6.0)),
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
  final int pierce;
  final bool combustionDetonation;
  final double combustionDamage;
  final bool isFrozen;

  int remainingPierce;
  double _traveled = 0.0;
  final Set<int> _hitEnemyIds = <int>{};

  // Pre-allocated reusable buffer for collision queries
  static final List<int> _hitBuffer = <int>[];

  final Paint _corePaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _glowPaint = Paint()..color = const Color(0xFFFF5722);
  final Paint _beamPaint = Paint()
    ..color = const Color(0xFF22D3EE)
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;

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
    game.spatialHash.queryRadius(position.x, position.y, blastRadius > 0 ? 6.0 : 5.0, _hitBuffer);

    if (_hitBuffer.isNotEmpty) {
      if (blastRadius > 0) {
        _detonate();
      } else {
        _pierceThrough();
      }
    }
  }

  void _detonate() {
    final double effectiveBlast = blastRadius > 0 ? blastRadius : 12.0;
    game.world.add(
      ExplosionBurstComponent(
        position: position.clone(),
        maxRadius: effectiveBlast,
      ),
    );

    game.spatialHash.queryRadius(position.x, position.y, effectiveBlast, _hitBuffer);
    for (int i = 0; i < _hitBuffer.length; i++) {
      final int enemyId = _hitBuffer[i];
      final enemy = game.findEnemyById(enemyId);
      if (enemy != null && enemy.isMounted) {
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
          isFrozen: isFrozen,
        );
      }
    }

    if (combustionDetonation && combustionDamage > 0) {
      game.world.add(
        ExplosionBurstComponent(
          position: position.clone(),
          maxRadius: 28.0,
        ),
      );
    }

    removeFromParent();
  }

  void _pierceThrough() {
    for (int i = 0; i < _hitBuffer.length; i++) {
      final int enemyId = _hitBuffer[i];
      if (_hitEnemyIds.add(enemyId)) {
        final enemy = game.findEnemyById(enemyId);
        if (enemy != null && enemy.isMounted) {
          enemy.takeDamage(
            damage: damage,
            isCrit: isCrit,
            kbDirX: dirX,
            kbDirY: dirY,
            kbAmount: knockback,
            isFrozen: isFrozen,
          );

          if (combustionDetonation && combustionDamage > 0) {
            game.world.add(
              ExplosionBurstComponent(
                position: enemy.position.clone(),
                maxRadius: 24.0,
              ),
            );
          }

          remainingPierce--;
          if (remainingPierce < 0) {
            removeFromParent();
            return;
          }
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final double halfW = size.x / 2;
    final double halfH = size.y / 2;

    if (speed >= 300) {
      // Rail Sniper beam bolt
      canvas.drawLine(
        Offset(halfW - dirX * 6, halfH - dirY * 6),
        Offset(halfW + dirX * 6, halfH + dirY * 6),
        _beamPaint,
      );
      canvas.drawCircle(Offset(halfW, halfH), 2.5, _corePaint);
    } else if (blastRadius > 0) {
      // Ember Staff fireball
      _glowPaint.color = const Color(0xFFFF5722);
      canvas.drawCircle(Offset(halfW, halfH), halfW, _glowPaint);
      canvas.drawCircle(Offset(halfW, halfH), halfW * 0.45, _corePaint);
    } else {
      // Revolver kinetic bullet
      _glowPaint.color = const Color(0xFFFFCC00);
      canvas.drawCircle(Offset(halfW, halfH), halfW * 0.7, _glowPaint);
      canvas.drawCircle(Offset(halfW, halfH), halfW * 0.35, _corePaint);
    }
  }
}

/// Projectile fired by ranged enemies (Spitters) towards the Bastion at (0, 0).
class EnemyProjectileComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  EnemyProjectileComponent({
    required Vector2 position,
    required this.dirX,
    required this.dirY,
    required this.speed,
    required this.damage,
    this.maxDistance = 200.0,
  }) : super(
          position: position,
          size: Vector2.all(6.0),
          anchor: Anchor.center,
          priority: 18,
        );

  final double dirX;
  final double dirY;
  final double speed;
  final double damage;
  final double maxDistance;

  double _traveled = 0.0;
  final Paint _paint = Paint()..color = const Color(0xFF2CE8F5);
  final Paint _corePaint = Paint()..color = const Color(0xFFFFFFFF);

  @override
  void update(double dt) {
    super.update(dt);

    final double step = speed * dt;
    position.x += dirX * step;
    position.y += dirY * step;
    _traveled += step;

    // Check contact with Bastion at (0, 0)
    final double distSq = position.x * position.x + position.y * position.y;
    if (distSq <= 16.0 * 16.0) {
      game.bastion.takeContactHit(damage);
      removeFromParent();
      return;
    }

    if (_traveled >= maxDistance) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final double halfW = size.x / 2;
    final double halfH = size.y / 2;
    canvas.drawCircle(Offset(halfW, halfH), halfW, _paint);
    canvas.drawCircle(Offset(halfW, halfH), halfW * 0.5, _corePaint);
  }
}

