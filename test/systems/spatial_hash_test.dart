import 'package:bonkhold/systems/spatial_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpatialHash', () {
    late SpatialHash grid;

    setUp(() {
      grid = SpatialHash(cellSize: 32.0);
    });

    test('inserts and queries entities within radius', () {
      grid.insert(1, 0, 0, 8);
      grid.insert(2, 20, 0, 8);
      grid.insert(3, 100, 100, 8);

      final result = <int>[];
      grid.queryRadius(0, 0, 15, result);

      expect(result.contains(1), isTrue);
      // Entity 2 is at distance 20. Total radii = 15 + 8 = 23 -> within distance!
      expect(result.contains(2), isTrue);
      expect(result.contains(3), isFalse);
    });

    test('findNearest returns closest entity within maxRange', () {
      grid.insert(10, 0, 50, 5);
      grid.insert(20, 0, 25, 5);
      grid.insert(30, 0, 80, 5);

      final nearest = grid.findNearest(0, 0, 100);
      expect(nearest, 20);

      final outOfRange = grid.findNearest(0, 0, 10);
      expect(outOfRange, isNull);
    });

    test('clear wipes previous entities and allows re-population', () {
      grid.insert(1, 10, 10, 5);
      grid.clear();

      final result = <int>[];
      grid.queryRadius(10, 10, 20, result);
      expect(result, isEmpty);

      grid.insert(2, 10, 10, 5);
      grid.queryRadius(10, 10, 20, result);
      expect(result, [2]);
    });
  });
}
