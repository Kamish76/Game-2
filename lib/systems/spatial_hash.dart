/// Fast, uniform grid spatial partitioning for high-density enemy swarms.
/// Avoids Flame's O(N^2) collision detection overhead.
/// Supports zero-allocation queries via caller-provided result buffers.
class SpatialHash {
  SpatialHash({this.cellSize = 32.0});

  final double cellSize;

  // Grid storage: cellKey -> List of entity IDs
  final Map<int, List<int>> _cells = <int, List<int>>{};

  // Pre-allocated cell list pool to avoid re-allocating inner lists
  final List<List<int>> _cellListPool = <List<int>>[];

  // Entity lookup: entity ID -> (x, y, radius)
  final Map<int, double> _x = <int, double>{};
  final Map<int, double> _y = <int, double>{};
  final Map<int, double> _r = <int, double>{};

  // Reusable query set to deduplicate entity IDs spanning multiple cells
  final Set<int> _dedup = <int>{};

  static int _cellCoord(double pos, double size) => (pos / size).floor();

  static int _hash(int cx, int cy) {
    // 32-bit Cantor-like spatial key
    return ((cx & 0xFFFF) << 16) | (cy & 0xFFFF);
  }

  /// Clears the spatial hash. Pools empty lists to avoid GC.
  void clear() {
    for (final entry in _cells.entries) {
      entry.value.clear();
      _cellListPool.add(entry.value);
    }
    _cells.clear();
    _x.clear();
    _y.clear();
    _r.clear();
  }

  /// Registers an entity in the spatial hash.
  void insert(int id, double x, double y, double radius) {
    _x[id] = x;
    _y[id] = y;
    _r[id] = radius;

    final int minCx = _cellCoord(x - radius, cellSize);
    final int maxCx = _cellCoord(x + radius, cellSize);
    final int minCy = _cellCoord(y - radius, cellSize);
    final int maxCy = _cellCoord(y + radius, cellSize);

    for (int cx = minCx; cx <= maxCx; cx++) {
      for (int cy = minCy; cy <= maxCy; cy++) {
        final int key = _hash(cx, cy);
        List<int>? list = _cells[key];
        if (list == null) {
          list = _cellListPool.isNotEmpty ? _cellListPool.removeLast() : <int>[];
          _cells[key] = list;
        }
        list.add(id);
      }
    }
  }

  /// Queries all entities overlapping a circle at (x, y) with [radius].
  /// Writes matching entity IDs into [resultBuffer] without heap allocations.
  void queryRadius(double x, double y, double radius, List<int> resultBuffer) {
    resultBuffer.clear();
    _dedup.clear();

    final int minCx = _cellCoord(x - radius, cellSize);
    final int maxCx = _cellCoord(x + radius, cellSize);
    final int minCy = _cellCoord(y - radius, cellSize);
    final int maxCy = _cellCoord(y + radius, cellSize);

    for (int cx = minCx; cx <= maxCx; cx++) {
      for (int cy = minCy; cy <= maxCy; cy++) {
        final int key = _hash(cx, cy);
        final List<int>? cell = _cells[key];
        if (cell == null) continue;

        for (int i = 0; i < cell.length; i++) {
          final int id = cell[i];
          if (_dedup.add(id)) {
            final double ex = _x[id]!;
            final double ey = _y[id]!;
            final double er = _r[id]!;
            final double totalR = radius + er;

            final double dx = ex - x;
            final double dy = ey - y;
            final double distSq = dx * dx + dy * dy;

            if (distSq <= totalR * totalR) {
              resultBuffer.add(id);
            }
          }
        }
      }
    }
  }

  /// Finds the entity nearest to (x, y) within [maxRange].
  /// Returns the entity ID or null if no entity is in range.
  int? findNearest(double x, double y, double maxRange) {
    int? nearestId;
    double nearestDistSq = maxRange * maxRange;

    _dedup.clear();

    final int minCx = _cellCoord(x - maxRange, cellSize);
    final int maxCx = _cellCoord(x + maxRange, cellSize);
    final int minCy = _cellCoord(y - maxRange, cellSize);
    final int maxCy = _cellCoord(y + maxRange, cellSize);

    for (int cx = minCx; cx <= maxCx; cx++) {
      for (int cy = minCy; cy <= maxCy; cy++) {
        final int key = _hash(cx, cy);
        final List<int>? cell = _cells[key];
        if (cell == null) continue;

        for (int i = 0; i < cell.length; i++) {
          final int id = cell[i];
          if (_dedup.add(id)) {
            final double ex = _x[id]!;
            final double ey = _y[id]!;
            final double dx = ex - x;
            final double dy = ey - y;
            final double distSq = dx * dx + dy * dy;

            if (distSq < nearestDistSq) {
              nearestDistSq = distSq;
              nearestId = id;
            }
          }
        }
      }
    }

    return nearestId;
  }
}
