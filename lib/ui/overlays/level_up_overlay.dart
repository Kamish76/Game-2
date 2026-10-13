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
  late List<DraftCard> _cards;
  bool _isBanishMode = false;

  @override
  void initState() {
    super.initState();
    _cards = widget.game.draftSystem.generateDraft(widget.game.runState);
  }

  void _onSelectCard(DraftCard card) {
    if (_isBanishMode) {
      widget.game.draftSystem.banishItem(card.id, widget.game.runState);
      setState(() {
        _isBanishMode = false;
        _cards = widget.game.draftSystem.generateDraft(widget.game.runState);
      });
      return;
    }

    widget.game.draftSystem.applyCard(card, widget.game.runState);
    if (card.type == DraftCardType.newWeapon) {
      widget.game.refreshWeaponComponents();
    }
    widget.game.resumeFromLevelUp();
  }

  void _onReroll() {
    if (widget.game.runState.rerollCharges <= 0) return;
    setState(() {
      _isBanishMode = false;
      _cards = widget.game.draftSystem.rerollDraft(widget.game.runState);
    });
  }

  void _onSkip() {
    if (widget.game.runState.skipCharges <= 0) return;
    widget.game.draftSystem.skipDraft(widget.game.runState);
    widget.game.resumeFromLevelUp();
  }

  void _onToggleBanish() {
    if (widget.game.runState.banishCharges <= 0) return;
    setState(() {
      _isBanishMode = !_isBanishMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final runState = widget.game.runState;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Header
              Text(
                _isBanishMode ? 'SELECT CARD TO BANISH' : 'LEVEL UP!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isBanishMode ? const Color(0xFFEF4444) : const Color(0xFFFFD700),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isBanishMode
                    ? 'Card will be permanently removed from this run\'s draft pool'
                    : 'Choose an upgrade to fortify the Bastion',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
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

              const SizedBox(height: 12),

              // Utility Action Tray: Reroll, Skip, Banish
              Row(
                children: [
                  // Reroll Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: runState.rerollCharges > 0 ? _onReroll : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        side: BorderSide(
                          color: runState.rerollCharges > 0
                              ? const Color(0xFF38BDF8)
                              : Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Reroll (${runState.rerollCharges})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Skip Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: runState.skipCharges > 0 ? _onSkip : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF43D365),
                        side: BorderSide(
                          color: runState.skipCharges > 0
                              ? const Color(0xFF43D365)
                              : Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Skip (${runState.skipCharges})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Banish Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: runState.banishCharges > 0 ? _onToggleBanish : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isBanishMode ? Colors.white : const Color(0xFFEF4444),
                        backgroundColor: _isBanishMode ? const Color(0xFFEF4444) : Colors.transparent,
                        side: BorderSide(
                          color: runState.banishCharges > 0
                              ? const Color(0xFFEF4444)
                              : Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        _isBanishMode ? 'Cancel' : 'Banish (${runState.banishCharges})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCard(DraftCard card) {
    final Color rarityColor = _isBanishMode ? const Color(0xFFEF4444) : card.rarity.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSelectCard(card),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isBanishMode ? const Color(0xFF2A1515) : const Color(0xFF1A1C2C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: rarityColor, width: _isBanishMode ? 2.0 : 1.5),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.25),
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
                      _isBanishMode
                          ? 'BANISH ITEM'
                          : '${card.rarity.label.toUpperCase()} ${card.rarity.multiplier}x',
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
