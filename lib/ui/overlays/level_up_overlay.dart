import 'package:flutter/material.dart';

import '../../game/bonkhold_game.dart';
import '../../models/draft_card.dart';

/// Modal Level-Up drafting overlay presenting 3 distinct upgrade cards.
class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({super.key, required this.game});

  final BonkholdGame game;

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> {
  late final List<DraftCard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = widget.game.draftSystem.generateDraft(widget.game.runState);
  }

  void _onSelectCard(DraftCard card) {
    widget.game.draftSystem.applyCard(card, widget.game.runState);
    if (card.type == DraftCardType.newWeapon) {
      widget.game.refreshWeaponComponents();
    }
    widget.game.resumeFromLevelUp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Header
              const Text(
                'LEVEL UP!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose an upgrade to fortify the Bastion',
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // 3 Draft Cards
              Expanded(
                child: ListView.separated(
                  itemCount: _cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return _buildCard(card);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(DraftCard card) {
    final Color rarityColor = card.rarity.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSelectCard(card),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C2C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: rarityColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rarity Header Badge & Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: rarityColor, width: 0.8),
                    ),
                    child: Text(
                      '${card.rarity.label.toUpperCase()} ${card.rarity.multiplier}x',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: rarityColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    card.subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Card Title
              Text(
                card.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                card.description,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 6),

              // Stat Delta indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF262B44),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  card.deltaDescription,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF43D365),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
