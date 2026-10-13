/// Pure Dart director scheduling the periodic arrival of the Traveling Merchant.
/// Scheduled at 3-minute (180s) intervals aligned with Boss wave completions.
class MerchantDirector {
  MerchantDirector({
    this.initialArrival = 180.0,
    this.interval = 180.0,
  }) : nextMerchantTime = initialArrival;

  final double initialArrival;
  final double interval;

  double elapsedSeconds = 0.0;
  double nextMerchantTime;
  bool isMerchantActive = false;

  /// Advances time. Returns `true` on the exact tick the merchant should spawn.
  bool update(double dt) {
    elapsedSeconds += dt;
    if (elapsedSeconds >= nextMerchantTime && !isMerchantActive) {
      isMerchantActive = true;
      nextMerchantTime += interval;
      return true;
    }
    return false;
  }

  /// Hook called when the merchant departs or despawns from the arena.
  void onMerchantDeparted() {
    isMerchantActive = false;
  }

  void reset() {
    elapsedSeconds = 0.0;
    nextMerchantTime = initialArrival;
    isMerchantActive = false;
  }
}
