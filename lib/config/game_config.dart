import 'dart:ui';

/// Global constants for the prototype. See docs/02_TECH_ARCHITECTURE.md.
abstract final class GameConfig {
  /// Virtual pixel canvas (portrait). Everything in the world is authored
  /// in these units; the camera scales it to the device screen.
  static const double virtualWidth = 180;
  static const double virtualHeight = 320;

  /// Distance from the center (0,0) beyond the visible area where enemies
  /// spawn. Half-diagonal of 180x320 is ~184, plus a margin.
  static const double spawnRadius = 200;
}

/// Placeholder palette until the real pixel-art palette is chosen
/// (see docs/05_ART_PIXEL_ASSET_LIST.md).
abstract final class Palette {
  static const Color letterbox = Color(0xFF000000);
  static const Color arena = Color(0xFF1A1C2C);
  static const Color arenaGrid = Color(0xFF262B44);
  static const Color bastion = Color(0xFFF4B41B);
  static const Color bastionCore = Color(0xFFE43B44);
}
