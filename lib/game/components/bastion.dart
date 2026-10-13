import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../bonkhold_game.dart';
import '../../config/game_config.dart';
import '../../systems/damage_resolver.dart';
import 'damage_number.dart';
import 'projectile_component.dart';

/// The central tower at (0,0) defended by auto-targeting turrets.
class Bastion extends PositionComponent with HasGameReference<BonkholdGame> {
  Bastion()
      : super(
          position: Vector2.zero(),
          size: Vector2.all(32),
          anchor: Anchor.center,
          priority: 0,
        );

  static const double radius = 16.0;
  double _flashTimer = 0.0;
  double _spiritRingAngle = 0.0;

  static const Rect _bodyRect = Rect.fromLTWH(4, 4, 24, 24);
  static const Rect _coreRect = Rect.fromLTWH(12, 12, 8, 8);

  final Paint _body = Paint()..color = Palette.bastion;
  final Paint _core = Paint()..color = Palette.bastionCore;
  final Paint _flashPaint = Paint()..color = const Color(0xFFFFFFFF);
  final Paint _spiritFlamePaint = Paint()..color = const Color(0xFFFF9900);

  double _overclockCooldown = 0.0;

  /// Called when an enemy contacts the Bastion hull.
  void takeContactHit(double rawDamage) {
    final hit = DamageResolver.resolveIncomingHit(
      rawDamage: rawDamage,
      stats: game.runState.stats,
      rng: game.rng,
      maskOfRuinCount: game.runState.getItemCount('mask_of_ruin'),
    );

    if (hit.thornsDetonation && hit.thornsExplosionDamage > 0) {
      game.world.add(
        ExplosionBurstComponent(
          position: position.clone(),
          maxRadius: 32.0,
        ),
      );
    }

    if (hit.isDeflected) {
      game.world.add(
        DamageNumberComponent(
          position: position.clone()..y -= 12.0,
          damage: 0,
          isCrit: true,
        ),
      );
      return;
    }

    _flashTimer = 0.10;
    game.runState.applyDamage(hit.finalDamage);

    // Overclock Capacitor check: triggers emergency burst if HP < 40%
    final int overclockCount = game.runState.getItemCount('overclock_capacitor');
    if (overclockCount > 0 && _overclockCooldown <= 0) {
      final double hpRatio = game.runState.hp.value / math.max(1.0, game.runState.maxHp.value);
      if (hpRatio < 0.40) {
        _overclockCooldown = 60.0;
        game.world.add(
          ExplosionBurstComponent(
            position: position.clone(),
            maxRadius: 48.0,
          ),
        );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
    if (_overclockCooldown > 0) {
      _overclockCooldown -= dt;
    }
    _spiritRingAngle += 1.5 * dt;
  }

  @override
  void render(Canvas canvas) {
    if (_flashTimer > 0) {
      canvas.drawRect(_bodyRect, _flashPaint);
      canvas.drawRect(_coreRect, _flashPaint);
      return;
    }

    // Outer stone tower
    canvas.drawRect(_bodyRect, _body);

    // Inner glowing ruby core
    canvas.drawRect(_coreRect, _core);

    // Rotating spectral kitsune-bi spirit flame orbs
    final double r = 18.0;
    final double orb1X = 16.0 + r * math.cos(_spiritRingAngle);
    final double orb1Y = 16.0 + r * math.sin(_spiritRingAngle);
    final double orb2X = 16.0 + r * math.cos(_spiritRingAngle + math.pi);
    final double orb2Y = 16.0 + r * math.sin(_spiritRingAngle + math.pi);

    canvas.drawCircle(Offset(orb1X, orb1Y), 2.5, _spiritFlamePaint);
    canvas.drawCircle(Offset(orb2X, orb2Y), 2.5, _spiritFlamePaint);
  }
}
