import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';
import '../../models/enemy_def.dart';
import 'damage_number.dart';

/// Enemy unit moving from off-screen perimeter towards the Bastion at (0, 0).
class EnemyComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  EnemyComponent({
    required this.id,
    required this.def,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(def.radius * 2),
          anchor: Anchor.center,
          priority: 10,
        ) {
    maxHp = def.baseHp;
    hp = def.baseHp;
    _initPaints();
  }

  final int id;
  final EnemyDef def;
  late double maxHp;
  late double hp;

  double _attackTimer = 0.0;
  double _flashTimer = 0.0;

  double _kbDirX = 0.0;
  double _kbDirY = 0.0;
  double _kbSpeed = 0.0;
  double _kbTimeRemaining = 0.0;

  late final Paint _bodyPaint;
  final Paint _flashPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _eyePaint = Paint()..color = const Color(0xFF111111);

  void _initPaints() {
    _bodyPaint = Paint()..color = Color(def.colorHex);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Hit flash timer
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }

    // Knockback movement
    if (_kbTimeRemaining > 0) {
      position.x += _kbDirX * _kbSpeed * dt;
      position.y += _kbDirY * _kbSpeed * dt;
      _kbTimeRemaining -= dt;
    }

    // Directional translation towards (0, 0)
    final double px = position.x;
    final double py = position.y;
    final double dist = math.sqrt(px * px + py * py);
    const double bastionRadius = 16.0;
    final double contactDistance = bastionRadius + def.radius;

    if (dist > contactDistance) {
      // March towards center
      final double step = def.speed * dt;
      position.x -= (px / dist) * step;
      position.y -= (py / dist) * step;
    } else {
      // Reached Bastion hull: attack on cadence
      _attackTimer += dt;
      if (_attackTimer >= def.attackInterval) {
        game.bastion.takeContactHit(def.contactDamage);
        _attackTimer = 0.0;
      }
    }
  }

  /// Called when hit by a projectile or AoE blast.
  void takeDamage({
    required double damage,
    required bool isCrit,
    required double kbDirX,
    required double kbDirY,
    required double kbAmount,
  }) {
    hp -= damage;
    _flashTimer = 0.08;

    // Apply knockback factoring in resistance
    final double effectiveKb = kbAmount * (1.0 - def.knockbackResist);
    if (effectiveKb > 0) {
      _kbDirX = kbDirX;
      _kbDirY = kbDirY;
      _kbSpeed = effectiveKb * 8.0; // Rapid impulse
      _kbTimeRemaining = 0.12;
    }

    // Spawn floating damage text
    game.world.add(
      DamageNumberComponent(
        position: position.clone(),
        damage: damage,
        isCrit: isCrit,
      ),
    );

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    // 1. Drop XP shard
    game.spawnPickup(position.x, position.y, def.xpValue, false);

    // 2. Drop Gold coin chance
    final double goldChance = def.id == 'brute' ? 0.5 : 0.2;
    if (game.rng.nextDouble() < goldChance) {
      game.spawnPickup(position.x + 3.0, position.y + 3.0, 1, true);
    }

    // 3. Register kill
    game.onEnemyKilled(this);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final Paint activePaint = _flashTimer > 0 ? _flashPaint : _bodyPaint;
    final double r = def.radius;

    final double angle = math.atan2(-position.y, -position.x);

    canvas.save();
    canvas.translate(r, r);
    canvas.rotate(angle);

    if (def.id == 'runner') {
      // Triangular fast flyer pointing forward
      final path = Path()
        ..moveTo(r, 0)
        ..lineTo(-r, -r * 0.7)
        ..lineTo(-r * 0.4, 0)
        ..lineTo(-r, r * 0.7)
        ..close();
      canvas.drawPath(path, activePaint);
    } else if (def.id == 'brute') {
      // Heavy blocky horned tank
      canvas.drawRect(Rect.fromLTWH(-r, -r, r * 2, r * 2), activePaint);
      canvas.drawCircle(Offset(r * 0.4, -r * 0.3), 1.5, _eyePaint);
      canvas.drawCircle(Offset(r * 0.4, r * 0.3), 1.5, _eyePaint);
    } else {
      // Diamond Swarmling
      canvas.drawCircle(Offset.zero, r, activePaint);
      canvas.drawCircle(Offset(r * 0.3, 0), 1.5, _eyePaint);
    }

    canvas.restore();
  }
}
