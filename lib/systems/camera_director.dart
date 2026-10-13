import 'dart:math' as math;

import '../config/game_config.dart';

/// Pure-Dart system orchestrating dynamic camera zoom-out as the player
/// levels up and time progresses.
///
/// Follows the architecture principle: "Components render and move. Systems decide."
/// Zero allocations on update.
class CameraDirector {
  CameraDirector({
    this.baseZoom = GameConfig.baseCameraZoom,
    this.minZoom = GameConfig.minCameraZoom,
    this.lerpSpeed = GameConfig.cameraZoomLerpSpeed,
  })  : currentZoom = baseZoom,
        targetZoom = baseZoom;

  final double baseZoom;
  final double minZoom;
  final double lerpSpeed;

  double currentZoom;
  double targetZoom;

  /// Max reduction awarded by Level progression (up to -0.20).
  static const double maxLevelReduction = 0.20;

  /// Max reduction awarded by elapsed survival time (up to -0.10 across 15 min / 900s).
  static const double maxTimeReduction = 0.10;

  /// Calculates the target camera zoom for a given [level] and [elapsedSeconds].
  ///
  /// - Level progress uses an asymptotic curve (1 - exp(-0.06 * (L - 1))),
  ///   providing noticeable early expansion that naturally flattens around level 30+.
  /// - Time progress linearly tracks survival up to 900s (15:00 Overtime).
  /// - Result is strictly clamped between [minZoom] and [baseZoom].
  static double calculateTargetZoom({
    required int level,
    required double elapsedSeconds,
    double baseZoom = GameConfig.baseCameraZoom,
    double minZoom = GameConfig.minCameraZoom,
  }) {
    // 1. Level progress component: reaches full 1.0 progress at level 30+
    // with a concave power curve (power 0.7) for responsive early progression.
    final double levelNorm = ((level - 1) / 29.0).clamp(0.0, 1.0);
    final double levelProgress = level <= 1
        ? 0.0
        : math.pow(levelNorm, 0.7).toDouble();
    final double levelDelta = maxLevelReduction * levelProgress;

    // 2. Elapsed time component: reaches full 1.0 progress at 15:00 / 900s
    final double timeProgress = elapsedSeconds <= 0.0
        ? 0.0
        : (elapsedSeconds / 900.0).clamp(0.0, 1.0);
    final double timeDelta = maxTimeReduction * timeProgress;

    final double target = baseZoom - (levelDelta + timeDelta);
    return target.clamp(minZoom, baseZoom);
  }

  /// Advances camera interpolation towards target zoom over [dt] seconds.
  void update(
    double dt, {
    required int level,
    required double elapsedSeconds,
  }) {
    targetZoom = calculateTargetZoom(
      level: level,
      elapsedSeconds: elapsedSeconds,
      baseZoom: baseZoom,
      minZoom: minZoom,
    );

    if (dt <= 0.0) return;

    // Frame-rate independent exponential smoothing
    final double t = 1.0 - math.exp(-lerpSpeed * dt);
    currentZoom += (targetZoom - currentZoom) * t;
    currentZoom = currentZoom.clamp(minZoom, baseZoom);
  }

  /// Snaps current zoom directly to target zoom (useful for initialization/testing).
  void snapToTarget() {
    currentZoom = targetZoom;
  }

  /// Resets camera director back to initial base zoom.
  void reset() {
    currentZoom = baseZoom;
    targetZoom = baseZoom;
  }
}
