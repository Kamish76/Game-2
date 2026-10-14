import 'package:flutter/material.dart';

import '../../audio/audio_manager.dart';
import '../../data/items.dart';
import '../../game/bonkhold_game.dart';
import '../../models/item_def.dart';
import '../../models/rarity.dart';
import '../../systems/stat_engine.dart';
import 'overlay_ids.dart';

class MerchantOverlay extends StatefulWidget {
  const MerchantOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  State<MerchantOverlay> createState() => _MerchantOverlayState();
}

class _MerchantOverlayState extends State<MerchantOverlay>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<ItemDef> _shopInventory;
  final Set<String> _purchasedItemIds = <String>{};
  String? _selectedSacrificeId;
  String? _forgeResultMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initShopInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initShopInventory() {
    // Pick 3 distinct random items for the shop
    final pool = List<ItemDef>.from(allItems)..shuffle(widget.game.rng);
    _shopInventory = pool.take(3).toList();
  }

  int _getPrice(ItemDef item) {
    switch (item.rarity) {
      case Rarity.common:
        return 30;
      case Rarity.uncommon:
        return 60;
      case Rarity.rare:
        return 100;
      case Rarity.epic:
        return 175;
      case Rarity.legendary:
        return 300;
    }
  }

  void _buyItem(ItemDef item) {
    final runState = widget.game.runState;
    final int price = _getPrice(item);

    if (runState.gold.value >= price && !_purchasedItemIds.contains(item.id)) {
      setState(() {
        runState.gold.value -= price;
        _purchasedItemIds.add(item.id);
        runState.addItem(item.id);
        StatEngine.recompute(runState);
      });
    }
  }

  void _buyFieldRepair() {
    final runState = widget.game.runState;
    const int repairCost = 40;

    if (runState.gold.value >= repairCost) {
      setState(() {
        runState.gold.value -= repairCost;
        final double healAmount = runState.maxHp.value * 0.25;
        runState.heal(healAmount);
      });
    }
  }

  void _transmuteItem() {
    final runState = widget.game.runState;
    const int forgeCost = 50;

    if (_selectedSacrificeId == null) return;
    if (runState.gold.value < forgeCost) return;

    final sacrificed = itemsById[_selectedSacrificeId];
    if (sacrificed == null) return;

    // Find candidate items of equal rarity
    final candidates = allItems
        .where((i) => i.rarity == sacrificed.rarity && i.id != sacrificed.id)
        .toList();

    final replacement = candidates.isNotEmpty
        ? candidates[widget.game.rng.nextInt(candidates.length)]
        : sacrificed;

    setState(() {
      runState.gold.value -= forgeCost;
      runState.removeItem(sacrificed.id);
      runState.addItem(replacement.id);
      StatEngine.recompute(runState);

      _forgeResultMessage = 'Transmuted ${sacrificed.name} -> ${replacement.name}!';
      _selectedSacrificeId = null;
    });

    AudioManager.instance.playSfx(SfxId.forgeHammer);
  }

  void _resumeCombat() {
    widget.game.runState.isPaused = false;
    widget.game.resumeEngine();
    widget.game.overlays.remove(OverlayIds.merchant);
  }

  @override
  Widget build(BuildContext context) {
    final runState = widget.game.runState;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.storefront, color: Color(0xFFFBBF24), size: 20),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'TRAVELING MERCHANT',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFBBF24),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: runState.gold,
                      builder: (context, gold, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFBBF24)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Color(0xFFFBBF24), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$gold G',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFBBF24),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Navigation Tabs
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFFBBF24),
                  labelColor: const Color(0xFFFBBF24),
                  unselectedLabelColor: Colors.white54,
                  tabs: const [
                    Tab(text: 'RELIC MARKET'),
                    Tab(text: 'ALCHEMICAL FORGE'),
                  ],
                ),
                const SizedBox(height: 12),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMarketTab(runState),
                      _buildForgeTab(runState),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Resume Combat Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _resumeCombat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43D365),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'RESUME COMBAT',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketTab(dynamic runState) {
    return ValueListenableBuilder<int>(
      valueListenable: runState.gold,
      builder: (context, currentGold, _) {
        return ListView(
          children: [
            // Emergency Provisions Card
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.healing, color: Color(0xFF38BDF8), size: 28),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Field Repairs',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Instantly restores +25% Bastion Max HP.',
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: currentGold >= 40 ? _buyFieldRepair : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text('40 G', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Relic Cards
            ..._shopInventory.map((item) {
              final int price = _getPrice(item);
              final bool isBought = _purchasedItemIds.contains(item.id);
              final bool canAfford = currentGold >= price;

              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.rarity.color.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.rarity.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.rarity.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: item.rarity.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: (!isBought && canAfford) ? () => _buyItem(item) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBBF24),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: Text(
                        isBought ? 'BOUGHT' : '$price G',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildForgeTab(dynamic runState) {
    final Map<String, int> owned = runState.ownedItems;
    final int gold = runState.gold.value;
    const int forgeCost = 50;

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alchemical Transmutation (Forge)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sacrifice 1 owned Relic and pay 50 Gold to forge a random Relic of equivalent rarity tier.',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 12),

              if (owned.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No Relics in inventory to sacrifice.',
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  ),
                )
              else ...[
                const Text(
                  'Select Relic to Sacrifice:',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSacrificeId,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0F172A),
                      hint: const Text('Choose a relic...', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      items: owned.keys.map((id) {
                        final item = itemsById[id];
                        final count = owned[id] ?? 0;
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            '${item?.name ?? id} (x$count) - ${item?.rarity.label ?? ""}',
                            style: TextStyle(fontSize: 12, color: item?.rarity.color ?? Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSacrificeId = val;
                          _forgeResultMessage = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: (_selectedSacrificeId != null && gold >= forgeCost)
                        ? _transmuteItem
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA855F7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'TRANSMUTE (Cost: $forgeCost G)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],

              if (_forgeResultMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Center(
                    child: Text(
                      _forgeResultMessage!,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
