import 'package:bonkhold/config/game_config.dart';
import 'package:bonkhold/systems/camera_director.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraDirector System Tests', () {
    test('calculateTargetZoom at level 1, t = 0 returns baseZoom (1.0)', () {
      final zoom = CameraDirector.calculateTargetZoom(level: 1, elapsedSeconds: 0.0);
      expect(zoom, equals(GameConfig.baseCameraZoom));
      expect(zoom, 1.0);
    });

    test('calculateTargetZoom decreases monotonically with higher level', () {
      final z1 = CameraDirector.calculateTargetZoom(level: 1, elapsedSeconds: 0.0);
      final z5 = CameraDirector.calculateTargetZoom(level: 5, elapsedSeconds: 0.0);
      final z15 = CameraDirector.calculateTargetZoom(level: 15, elapsedSeconds: 0.0);
      final z30 = CameraDirector.calculateTargetZoom(level: 30, elapsedSeconds: 0.0);

      expect(z5, lessThan(z1));
      expect(z15, lessThan(z5));
      expect(z30, lessThan(z15));
      expect(z30, greaterThanOrEqualTo(GameConfig.minCameraZoom));
    });

    test('calculateTargetZoom decreases monotonically with elapsed survival time', () {
      final z0 = CameraDirector.calculateTargetZoom(level: 1, elapsedSeconds: 0.0);
      final z180 = CameraDirector.calculateTargetZoom(level: 1, elapsedSeconds: 180.0);
      final z450 = CameraDirector.calculateTargetZoom(level: 1, elapsedSeconds: 450.0);
      final z900 = CameraDirector.calculateTargetZoom(level: 1, elapsedSeconds: 900.0);

      expect(z180, lessThan(z0));
      expect(z450, lessThan(z180));
      expect(z900, lessThan(z450));
      expect(z900, greaterThanOrEqualTo(GameConfig.minCameraZoom));
    });

    test('calculateTargetZoom strictly respects minCameraZoom clamp at extreme scale', () {
      final extreme = CameraDirector.calculateTargetZoom(
        level: 100,
        elapsedSeconds: 3600.0,
      );
      expect(extreme, equals(GameConfig.minCameraZoom));
      expect(extreme, 0.70);
    });

    test('update smoothly interpolates towards targetZoom without discontinuous jumps', () {
      final director = CameraDirector(lerpSpeed: 2.0);
      expect(director.currentZoom, 1.0);

      // Trigger high level & time
      // Target zoom will be ~0.70
      final target = CameraDirector.calculateTargetZoom(level: 35, elapsedSeconds: 900.0);
      expect(target, closeTo(0.70, 0.05));

      // Advance one tick of 0.05s
      director.update(0.05, level: 35, elapsedSeconds: 900.0);
      expect(director.currentZoom, lessThan(1.0));
      expect(director.currentZoom, greaterThan(target));

      // Advance 40 ticks (2.0 seconds) -> should have smoothly converged close to target
      for (int i = 0; i < 40; i++) {
        director.update(0.05, level: 35, elapsedSeconds: 900.0);
      }
      expect(director.currentZoom, closeTo(target, 0.02));
    });

    test('snapToTarget sets currentZoom directly to targetZoom', () {
      final director = CameraDirector();
      director.update(0.0, level: 20, elapsedSeconds: 300.0);
      expect(director.currentZoom, 1.0);
      expect(director.targetZoom, lessThan(1.0));

      director.snapToTarget();
      expect(director.currentZoom, equals(director.targetZoom));
    });

    test('reset restores currentZoom and targetZoom to baseZoom (1.0)', () {
      final director = CameraDirector();
      for (int i = 0; i < 30; i++) {
        director.update(0.05, level: 10, elapsedSeconds: 300.0);
      }
      expect(director.currentZoom, lessThan(1.0));

      director.reset();
      expect(director.currentZoom, 1.0);
      expect(director.targetZoom, 1.0);
    });
  });
}
