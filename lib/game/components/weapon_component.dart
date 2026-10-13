import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';
import '../../models/run_state.dart';
import '../../models/weapon_def.dart';
import '../../systems/damage_resolver.dart';
import 'enemy_component.dart';
import 'projectile_component.dart';

/// Central weapon component mounted on the Bastion.
/// Auto-targets threats according to weapon targeting mode and fires projectiles / pulses.
class WeaponComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  WeaponComponent({
    required this.equippedWeapon,
    this.mountAngle = 0.0,
  }) : super(
          position: Vector2.zero(),
          size: Vector2.all(16.0),
          anchor: Anchor.center,
          priority: 15,
        ) {
    _initPaints();
  }

  final EquippedWeapon equippedWeapon;
  final double mountAngle;

  double _cooldownTimer = 0.0;
  double _aimAngle = 0.0;

  static final List<int> _targetBuffer = <int>[];

  late final Paint _mountPaint;
  late final Paint _barrelPaint;

  void _initPaints() {
    Color mountColor = const Color(0xFFFF5722);
    Color barrelColor = const Color(0xFFFFCC00);

    switch (equippedWeapon.def.id) {
      case 'revolver_battery':
        mountColor = const Color(0xFFD97706);
        barrelColor = const Color(0xFFFDE68A);
        break;
      case 'pulse_aura':
        mountColor = const Color(0xFF0284C7);
        barrelColor = const Color(0xFF38BDF8);
        break;
      case 'rail_sniper':
        mountColor = const Color(0xFF4F46E5);
        barrelColor = const Color(0xFF22D3EE);
        break;
      case 'ember_staff':
      default:
        mountColor = const Color(0xFFFF5722);
        barrelColor = const Color(0xFFFFCC00);
        break;
    }

    _mountPaint = Paint()..color = mountColor;
    _barrelPaint = Paint()
      ..color = barrelColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
  }

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
    // 1. Special handling for Pulse Aura: radial 360° shockwave centered on Bastion
    if (equippedWeapon.def.id == 'pulse_aura') {
      final double effectiveRadius = equippedWeapon.stats.radius * (1.0 + game.runState.stats.size);
      // Check if any enemy is within blast radius
      game.spatialHash.queryRadius(0, 0, effectiveRadius, _targetBuffer);
      if (_targetBuffer.isEmpty) return;

      final hit = DamageResolver.resolveOutgoingHit(
        weaponDamage: equippedWeapon.stats.damage,
        weaponKnockback: equippedWeapon.stats.knockback,
        stats: game.runState.stats,
        rng: game.rng,
      );

      game.world.add(
        RadialShockwaveComponent(
          maxRadius: effectiveRadius,
          damage: hit.damage,
          knockback: hit.knockback,
          isCrit: hit.isCrit,
        ),
      );

      _cooldownTimer = 0.0;
      return;
    }

    // 2. Standard projectile weapons (Ember Staff, Revolver, Rail Sniper)
    final double range = equippedWeapon.stats.range;
    EnemyComponent? target;

    if (equippedWeapon.def.targeting == TargetingMode.highestMaxHp) {
      // Find enemy with highest maxHp within range
      game.spatialHash.queryRadius(0, 0, range, _targetBuffer);
      double highestHp = -1.0;
      int? bestId;

      for (int i = 0; i < _targetBuffer.length; i++) {
        final candidate = game.findEnemyById(_targetBuffer[i]);
        if (candidate != null && candidate.isMounted && candidate.maxHp > highestHp) {
          highestHp = candidate.maxHp;
          bestId = candidate.id;
        }
      }

      if (bestId != null) {
        target = game.findEnemyById(bestId);
      }
    } else {
      // Closest to Bastion
      final int? targetId = game.spatialHash.findNearest(0, 0, range);
      if (targetId != null) {
        target = game.findEnemyById(targetId);
      }
    }

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
    final double blastRadius = equippedWeapon.stats.radius > 0
        ? equippedWeapon.stats.radius * (1.0 + game.runState.stats.size)
        : 0.0;

    // Fire volley
    for (int p = 0; p < totalProjs; p++) {
      double pDirX = baseDirX;
      double pDirY = baseDirY;

      if (totalProjs > 1) {
        // Spread projectiles
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
          pierce: equippedWeapon.stats.pierce,
        ),
      );
    }

    _cooldownTimer = 0.0;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(_aimAngle);

    final double barrelLength = equippedWeapon.def.id == 'rail_sniper' ? 22.0 : 17.0;

    // Turret orb and barrel
    canvas.drawCircle(const Offset(12, 0), 3.5, _mountPaint);
    canvas.drawLine(const Offset(12, 0), Offset(barrelLength, 0), _barrelPaint);

    canvas.restore();
  }
}

