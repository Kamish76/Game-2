# 04: Starter Factor Chassis: Kitsune Spire

> Megabonk Analog: **Fox** (Kitsune)

---

## 1. Character Identity & Theme
- **Name:** Kitsune Spire
- **Visual Motif:** A mystical Japanese stone shrine surmounted by a ruby fox totem, flanked by rotating spectral kitsune-bi (spirit flame) lanterns.
- **Tagline:** *"Fortune favors the bold."*
- **Role:** High-Luck high-variance scaling; snowballs upgrade draft quality over time.

---

## 2. Base Loadout & Stats

### 2.1 Starting Weapon
- **Ember Staff (Level 1):** Launches arcing fireballs that detonate in an AoE blast on impact with the closest threat to the Bastion. (See [3.4 Weapons](../03_systems/3.4_weapons.md)).

### 2.2 Passive Ability: Fortune's Favor
- **Effect:**
  - Begins the run with a baseline $+15\%$ Luck bonus.
  - Upon every Level-Up, automatically gains $+1.5\%$ Luck additively (uncapped).
- **Synergy:** Drastically shifts the probability curve in `DraftSystem` towards rolling **Epic** (1.6×) and **Legendary** (2.0×) weapon and tome cards as the run progresses.

### 2.3 Base Attributes
| Attribute | Value | Notes |
|---|---|---|
| **Max Structural HP** | 100 | Standard starting durability. |
| **Shield Buffer** | 0 | Unlocked via Shield upgrades or items. |
| **Armor Rating** | 0 | 0% baseline damage reduction. |
| **Deflection (Evasion)** | 0% | Baseline deflection rate. |
| **Attraction Radius** | 48 px | Radius within which XP shards and Gold are pulled. |
| **Starting Luck** | 15% | High base luck compared to standard 0%. |
| **Turret Hardpoints** | 4 | 1 Central Mount (Ember Staff) + 3 Satellite Mounts. |

---

## 3. Recommended Build Paths
1. **The Pure Pyromancer:**
   - Weapons: Ember Staff, Pulse Aura, Revolver Battery, Rail Sniper.
   - Tomes: Size Tome, Cooldown Tome, Quantity Tome, Damage Tome.
   - Strategy: Maximize blast radius and quantity so that multiple explosive fireballs blanket the entire perimeter.
2. **The Holy Trinity Snowball:**
   - Tomes: Luck Tome, XP Tome, Cursed Tome, Quantity Tome.
   - Strategy: Stack Kitsune's innate Luck with the Luck Tome to routinely draft Legendary cards, rapidly overpowering the escalated Cursed waves.

---

## 4. Implementation Checklist
- [ ] Define `kitsuneSpireDef` in `lib/data/characters.dart`.
- [ ] Hook the `+1.5% Luck` per level passive into `LevelUp` logic.
- [ ] Automatically assign Ember Staff to Weapon Slot 0 upon game initialization.
