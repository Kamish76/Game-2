import 'package:bonkhold/game/bonkhold_game.dart';
import 'package:bonkhold/game/components/bastion.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWithGame<BonkholdGame>(
    'Bastion is spawned at the world origin',
    BonkholdGame.new,
    (game) async {
      await game.ready();
      final bastions = game.world.children.whereType<Bastion>();
      expect(bastions.length, 1);
      expect(bastions.first.position, Vector2.zero());
    },
  );
}
