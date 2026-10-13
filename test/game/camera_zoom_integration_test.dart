import 'dart:math' as math;

import 'package:bonkhold/config/game_config.dart';
import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/enemy_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Camera Zoom Integration Tests', () {
    testWithGame<BonkholdGame>(
      'Initial camera zoom is 1.0 and initial spawn radius is 200px',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        expect(game.camera.viewfinder.zoom, 1.0);
        expect(game.cameraDirector.currentZoom, 1.0);
        expect(game.spawnDirector.currentSpawnRadius, GameConfig.spawnRadius);
      },
    );

    testWithGame<BonkholdGame>(
      'Leveling up triggers smooth camera zoom-out and proportionally expands spawn perimeter',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Level up to level 12 and advance 60 seconds
        game.runState.level.value = 12;
        game.runState.elapsedSeconds.value = 60.0;

        // Advance simulation ticks (step-clamped to 0.05s)
        for (int i = 0; i < 40; i++) {
          game.update(0.05);
        }

        // Camera should have smoothly zoomed out below 1.0
        final zoom = game.camera.viewfinder.zoom;
        expect(zoom, lessThan(1.0));
        expect(zoom, greaterThanOrEqualTo(GameConfig.minCameraZoom));

        // Spawn radius should have expanded proportionally (200 / zoom)
        final expectedRadius = GameConfig.spawnRadius / zoom;
        expect(game.spawnDirector.currentSpawnRadius, closeTo(expectedRadius, 0.01));
        expect(game.spawnDirector.currentSpawnRadius, greaterThan(GameConfig.spawnRadius));
      },
    );

    testWithGame<BonkholdGame>(
      'Enemies spawn at the expanded perimeter circle when camera is zoomed out',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Advance to high level
        game.runState.level.value = 25;
        game.runState.elapsedSeconds.value = 450.0;

        // Converge zoom
        for (int i = 0; i < 40; i++) {
          game.update(0.05);
        }

        final currentZoom = game.camera.viewfinder.zoom;
        expect(currentZoom, lessThan(0.90));

        final expectedSpawnDist = GameConfig.spawnRadius / currentZoom;

        // Clear any enemies that moved inward during the zoom convergence ticks
        for (final enemy in game.world.children.whereType<EnemyComponent>().toList()) {
          enemy.removeFromParent();
        }
        await game.ready();

        // Spawn new enemies at the converged zoom radius
        game.spawnDirector.update(1.0, 0.0);
        await game.ready();

        final enemies = game.world.children.whereType<EnemyComponent>().toList();
        expect(enemies, isNotEmpty);

        for (final enemy in enemies) {
          final dist = math.sqrt(
            enemy.position.x * enemy.position.x + enemy.position.y * enemy.position.y,
          );
          expect(dist, closeTo(expectedSpawnDist, 0.05));
        }
      },
    );

    testWithGame<BonkholdGame>(
      'restartRun restores camera zoom to 1.0 and resets spawn perimeter to 200px',
      BonkholdGame.new,
      (game) async {
        await game.ready();

        // Zoom out
        game.runState.level.value = 20;
        for (int i = 0; i < 30; i++) {
          game.update(0.05);
        }
        expect(game.camera.viewfinder.zoom, lessThan(1.0));

        // Restart run
        game.restartRun();

        expect(game.camera.viewfinder.zoom, 1.0);
        expect(game.cameraDirector.currentZoom, 1.0);
        expect(game.cameraDirector.targetZoom, 1.0);
        expect(game.spawnDirector.currentSpawnRadius, GameConfig.spawnRadius);
      },
    );
  });
}
