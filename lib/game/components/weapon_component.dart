import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';
import '../../models/run_state.dart';
import '../../systems/damage_resolver.dart';
import 'projectile_component.dart';

/// Central weapon component mounted on the Bastion.
/// Auto-targets nearest threats and fires projectiles.
class WeaponComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  WeaponComponent({
    required this.equippedWeapon,
    this.mountAngle = 0.0,
  }) : super(
          position: Vector2.zero(),
          size: Vector2.all(16.0),
          anchor: Anchor.center,
          priority: 15,
        );

  final EquippedWeapon equippedWeapon;
  final double mountAngle;

  double _cooldownTimer = 0.0;
  double _aimAngle = 0.0;

  final Paint _mountPaint = Paint()..color = const Color(0xFFFF5722);
  final Paint _barrelPaint = Paint()
    ..color = const Color(0xFFFFCC00)
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke;

  @override
  void update(double dt) {
    super.update(dt);

    final globalStats = game.runState.stats;
    final double effCooldown = math.max(
      0.08,
      equippedWeapon.stats.cooldown / (1.0 + globalStats.attackSpeed),
    );

    _cooldownTimer += dt;
    if (_cooldownTimer >= effCooldown) {
      _tryFire(globalStats);
    }
  }

  void _tryFire(dynamic globalStats) {
    final double range = equippedWeapon.stats.range;
    final int? targetId = game.spatialHash.findNearest(0, 0, range);
    if (targetId == null) return;

    final target = game.findEnemyById(targetId);
    if (target == null || !target.isMounted) return;

    // Aim toward target
    final double dx = target.position.x;
    final double dy = target.position.y;
    final double dist = math.sqrt(dx * dx + dy * dy);
    if (dist <= 0.001) return;

    _aimAngle = math.atan2(dy, dx);
    final double baseDirX = dx / dist;
    final double baseDirY = dy / dist;

    // Resolve damage math
    final hit = DamageResolver.resolveOutgoingHit(
      weaponDamage: equippedWeapon.stats.damage,
      weaponKnockback: equippedWeapon.stats.knockback,
      stats: game.runState.stats,
      rng: game.rng,
    );

    final int totalProjs = equippedWeapon.stats.projectiles + game.runState.stats.quantity;
    final double blastRadius = equippedWeapon.stats.radius * (1.0 + game.runState.stats.size);

    // Fire volley
    for (int p = 0; p < totalProjs; p++) {
      double pDirX = baseDirX;
      double pDirY = baseDirY;

      if (totalProjs > 1) {
        // Spread projectiles by +/- 8 degrees
        final double spreadAngle = (p - (totalProjs - 1) / 2.0) * 0.15;
        final double angle = _aimAngle + spreadAngle;
        pDirX = math.cos(angle);
        pDirY = math.sin(angle);
      }

      game.world.add(
        ProjectileComponent(
          position: Vector2.zero(),
          dirX: pDirX,
          dirY: pDirY,
          speed: equippedWeapon.stats.projSpeed,
          damage: hit.damage,
          blastRadius: blastRadius,
          knockback: hit.knockback,
          isCrit: hit.isCrit,
          maxDistance: range,
        ),
      );
    }

    _cooldownTimer = 0.0;
  }

  @override
  void render(Canvas canvas) {
    // Render orbiting turret hardpoint pointing in aim direction
    canvas.save();
    canvas.rotate(_aimAngle);

    // Small glowing turret orb
    canvas.drawCircle(const Offset(12, 0), 3.5, _mountPaint);
    canvas.drawLine(const Offset(12, 0), const Offset(17, 0), _barrelPaint);

    canvas.restore();
  }
}
