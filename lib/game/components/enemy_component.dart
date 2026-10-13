import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';
import '../../data/enemies.dart';
import '../../models/enemy_def.dart';
import '../../models/run_state.dart';
import 'damage_number.dart';
import 'projectile_component.dart';

/// Enemy unit moving from off-screen perimeter towards the Bastion at (0, 0).
/// Supports Standard, Elite, Ranged Spitter, and Stage Boss behaviors.
class EnemyComponent extends PositionComponent with HasGameReference<BonkholdGame> {
  EnemyComponent({
    required this.id,
    required this.def,
    required Vector2 position,
    this.isElite = false,
    this.statMultiplierHp = 1.0,
    this.statMultiplierSpeed = 1.0,
  }) : super(
          position: position,
          size: Vector2.all(def.radius * 2 * (isElite ? 1.4 : 1.0)),
          anchor: Anchor.center,
          priority: def.isBoss ? 12 : 10,
        ) {
    final double eliteHpMult = isElite ? 3.0 : 1.0;
    maxHp = def.baseHp * eliteHpMult * statMultiplierHp;
    hp = maxHp;
    effectiveSpeed = def.speed * statMultiplierSpeed;
    effectiveKnockbackResist = isElite
        ? (def.knockbackResist + 0.25).clamp(0.0, 0.95)
        : def.knockbackResist;
    effectiveContactDamage = def.contactDamage * (isElite ? 1.3 : 1.0);

    _initPaints();
  }

  final int id;
  final EnemyDef def;
  final bool isElite;
  final double statMultiplierHp;
  final double statMultiplierSpeed;

  late double maxHp;
  late double hp;
  late double effectiveSpeed;
  late double effectiveKnockbackResist;
  late double effectiveContactDamage;

  double _attackTimer = 0.0;
  double _flashTimer = 0.0;

  // Boss ability timers
  double _slamTimer = 0.0;
  double _summonTimer = 0.0;

  double _kbDirX = 0.0;
  double _kbDirY = 0.0;
  double _kbSpeed = 0.0;
  double _kbTimeRemaining = 0.0;

  late final Paint _bodyPaint;
  final Paint _flashPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _eyePaint = Paint()..color = const Color(0xFF111111);
  final Paint _bossEyePaint = Paint()..color = const Color(0xFFFFCC00);
  final Paint _auraPaint = Paint()
    ..color = const Color(0xFFFFD700)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  void _initPaints() {
    _bodyPaint = Paint()..color = Color(def.colorHex);
  }

  @override
  void onMount() {
    super.onMount();
    if (def.isBoss) {
      game.runState.activeBoss.value = BossInfo(
        name: def.name,
        hp: hp,
        maxHp: maxHp,
      );
    }
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

    // Radial distance calculation towards Bastion at (0, 0)
    final double px = position.x;
    final double py = position.y;
    final double dist = math.sqrt(px * px + py * py);
    const double bastionRadius = 16.0;
    final double contactDistance = bastionRadius + def.radius;

    // Boss special abilities
    if (def.isBoss) {
      _updateBossAbilities(dt, dist);
    }

    // Movement & Attack behavior
    if (def.isRanged && dist <= def.preferredDistance) {
      // Spitter halts at preferred distance and fires ranged projectiles
      _attackTimer += dt;
      if (_attackTimer >= def.attackInterval) {
        if (dist > 0.001) {
          game.world.add(
            EnemyProjectileComponent(
              position: position.clone(),
              dirX: -px / dist,
              dirY: -py / dist,
              speed: def.projectileSpeed,
              damage: def.projectileDamage * (isElite ? 1.3 : 1.0),
            ),
          );
        }
        _attackTimer = 0.0;
      }
    } else if (dist > contactDistance) {
      // March towards center
      final double step = effectiveSpeed * dt;
      position.x -= (px / dist) * step;
      position.y -= (py / dist) * step;
    } else {
      // Reached Bastion hull: melee attack on cadence
      _attackTimer += dt;
      if (_attackTimer >= def.attackInterval) {
        game.bastion.takeContactHit(effectiveContactDamage);
        _attackTimer = 0.0;
      }
    }
  }

  void _updateBossAbilities(double dt, double distToBastion) {
    // 1. Seismic Slam: every 6s, launches shockwave
    _slamTimer += dt;
    if (_slamTimer >= 6.0) {
      _slamTimer = 0.0;
      game.world.add(
        ExplosionBurstComponent(
          position: position.clone(),
          maxRadius: 40.0,
        ),
      );
      if (distToBastion <= 120.0) {
        game.bastion.takeContactHit(effectiveContactDamage * 0.75);
      }
    }

    // 2. Minion Summon: every 10s, summons a ring of 6 Swarmlings around itself
    _summonTimer += dt;
    if (_summonTimer >= 10.0) {
      _summonTimer = 0.0;
      for (int i = 0; i < 6; i++) {
        final double theta = (i / 6.0) * 2 * math.pi;
        final double spawnX = position.x + math.cos(theta) * 24.0;
        final double spawnY = position.y + math.sin(theta) * 24.0;
        game.spawnEnemy(swarmlingDef, spawnX, spawnY);
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

    if (def.isBoss) {
      game.runState.activeBoss.value = BossInfo(
        name: def.name,
        hp: math.max(0.0, hp),
        maxHp: maxHp,
      );
    }

    // Apply knockback factoring in resistance
    final double effectiveKb = kbAmount * (1.0 - effectiveKnockbackResist);
    if (effectiveKb > 0) {
      _kbDirX = kbDirX;
      _kbDirY = kbDirY;
      _kbSpeed = effectiveKb * 8.0;
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
    if (def.isBoss) {
      // Boss rewards: 2x Mega Shards (100 XP each) and 25 Gold
      game.spawnPickup(position.x - 6.0, position.y, 100, false);
      game.spawnPickup(position.x + 6.0, position.y, 100, false);
      game.spawnPickup(position.x, position.y, 25, true);
      game.runState.addBossKill();
      game.runState.activeBoss.value = null;
    } else if (isElite) {
      // Elite rewards: Greater shard (25 XP) + guaranteed gold
      game.spawnPickup(position.x, position.y, 25, false);
      game.spawnPickup(position.x + 4.0, position.y + 4.0, 2, true);
      game.runState.addEliteKill();
    } else {
      // Standard rewards
      game.spawnPickup(position.x, position.y, def.xpValue, false);
      final double goldChance = def.id == 'brute' ? 0.5 : (def.id == 'spitter' ? 0.4 : 0.2);
      if (game.rng.nextDouble() < goldChance) {
        game.spawnPickup(position.x + 3.0, position.y + 3.0, 1, true);
      }
    }

    game.onEnemyKilled(this);
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final Paint activePaint = _flashTimer > 0 ? _flashPaint : _bodyPaint;
    final double r = def.radius * (isElite ? 1.4 : 1.0);
    final double angle = math.atan2(-position.y, -position.x);

    canvas.save();
    canvas.translate(r, r);
    canvas.rotate(angle);

    // Elite golden aura ring
    if (isElite) {
      canvas.drawCircle(Offset.zero, r * 1.25, _auraPaint);
    }

    if (def.isBoss) {
      // Massive Yokai Goliath: large horned diamond with glowing yellow eyes
      final path = Path()
        ..moveTo(r * 1.2, 0)
        ..lineTo(0, -r)
        ..lineTo(-r * 0.8, -r * 0.5)
        ..lineTo(-r * 0.4, 0)
        ..lineTo(-r * 0.8, r * 0.5)
        ..lineTo(0, r)
        ..close();
      canvas.drawPath(path, activePaint);
      canvas.drawCircle(Offset(r * 0.3, -r * 0.3), 2.5, _bossEyePaint);
      canvas.drawCircle(Offset(r * 0.3, r * 0.3), 2.5, _bossEyePaint);
    } else if (def.id == 'runner') {
      // Fast flyer
      final path = Path()
        ..moveTo(r, 0)
        ..lineTo(-r, -r * 0.7)
        ..lineTo(-r * 0.4, 0)
        ..lineTo(-r, r * 0.7)
        ..close();
      canvas.drawPath(path, activePaint);
    } else if (def.id == 'brute') {
      // Heavy blocky tank
      canvas.drawRect(Rect.fromLTWH(-r, -r, r * 2, r * 2), activePaint);
      canvas.drawCircle(Offset(r * 0.4, -r * 0.3), 1.5, _eyePaint);
      canvas.drawCircle(Offset(r * 0.4, r * 0.3), 1.5, _eyePaint);
    } else if (def.id == 'spitter') {
      // Turquoise Spitter with central gem
      final path = Path()
        ..moveTo(r, 0)
        ..lineTo(0, -r * 0.8)
        ..lineTo(-r * 0.6, 0)
        ..lineTo(0, r * 0.8)
        ..close();
      canvas.drawPath(path, activePaint);
      canvas.drawCircle(Offset.zero, 2.0, _eyePaint);
    } else {
      // Swarmling
      canvas.drawCircle(Offset.zero, r, activePaint);
      canvas.drawCircle(Offset(r * 0.3, 0), 1.5, _eyePaint);
    }

    canvas.restore();
  }
}

