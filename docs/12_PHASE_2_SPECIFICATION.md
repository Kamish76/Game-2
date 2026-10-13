# 12: Phase 2 Specification — The Fortress & The Peddler

## 1. Overview & Vision
Phase 2 builds upon the validated stationary tower defense core of BONKHOLD v1. Rather than compromising the one-thumb mobile casual ergonomics with a complex virtual joystick drone, Phase 2 doubles down on the **pure stationary Bastion** identity. 

All interaction is streamlined to snappy, tactile taps:
- Defeated Elites and Bosses drop sealed Chests that vacuum to the Bastion's moat ring to be cracked open at leisure.
- A Traveling Merchant cart approaches the Bastion periodically, offering Item Relics and an Alchemical Forge for in-run Gold.
- An uncapped Item Relic system introduces rich proc synergies (`onHit`, `onCrit`, `onDamaged`, `onDeflect`, `onKill`).
- Silver Coins earned post-run unlock permanent account talents in the **Shrine of Heritage**.

---

## 2. Core Architecture Invariants & Changes

| Subsystem | v1 Status | Phase 2 Implementation |
|---|---|---|
| **Bastion Movement** | Stationary at `(0, 0)` | **Stationary at `(0, 0)`** (No drone or manual traversal) |
| **Active Player Abilities** | None | **None** (Deferred to Phase 3) |
| **Chests** | Deferred | **Moat Chests:** Vacuum into Bastion moat ring ($R=32\text{ px}$), tap-to-open |
| **Off-Screen Interactables** | None | **None** (All loot and merchants travel to the Bastion) |
| **Shrines & Altars** | Deferred | **Deferred to Phase 3** |
| **The Microwave** | Deferred | **Alchemical Forge Tab** inside Traveling Merchant |
| **Item Relics** | Deferred | **12 Core Relics**, uncapped stacking, zero-allocation procs |
| **Gold Sinks** | Storage only | **Traveling Merchant:** buy relics, forge transmutations, repair hull |
| **Meta-Progression** | Stub | **Silver Currency** + **Shrine of Heritage** talent tree |
| **Additional Towers** | Kitsune Spire only | **Deferred to Phase 3** |

---

## 3. System Specifications

### 3.1 Moat Chests & Tap-to-Open Rewards
1. **Drop Logic:**
   - **Elite Enemies:** $20\%$ chance on death to drop a Chest.
   - **Stage Bosses:** $100\%$ guaranteed drop of a Golden Chest.
2. **Vacuum Physics:**
   - Chests drop at the death location and immediately auto-vacuum toward the Bastion at $350\text{ px/s}^2$ (matching pickup physics).
   - Upon reaching the Bastion perimeter ($R \approx 32\text{ px}$), the chest stops and parks in an available radial slot around the moat.
3. **Stacking & Retention:**
   - Multiple chests can stack around the moat ring simultaneously without despawning.
   - Chests do not impede enemy movement, projectile pathing, or Bastion firing.
4. **Opening Interaction:**
   - Tapping a parked chest triggers an immediate unlock animation and awards an Item Relic (choice of 2 relics or instant drop).
   - Chest opening is **free** (a direct reward for defeating high-tier threats).

---

### 3.2 The Traveling Merchant (Transient In-Run Shop & Forge)
1. **Arrival Cadence:**
   - Arrives every 3 minutes (immediately following each Boss encounter) or after clearing wave milestones.
   - Approaches from off-screen, docks at the Bastion moat ring, and plays a welcoming chime.
2. **Transient Countdown:**
   - Stays parked for a **15-second window**, indicated by a circular timer badge.
   - If not interacted with, the merchant packs up and departs off-screen ("player's loss").
3. **Tap Interaction (Shop Overlay):**
   - Tapping the parked merchant pauses gameplay and displays the **Caravanserai Modal**:
     - **Relic Market:** 3 randomized Item Relics available for Gold purchase (prices scale by rarity: Common $30\text{g}$, Uncommon $60\text{g}$, Rare $100\text{g}$, Epic $175\text{g}$, Legendary $300\text{g}$).
     - **Alchemical Forge:** Spend Gold ($50\text{g}$) to sacrifice 1 owned relic and duplicate/reroll another relic of equal tier.
     - **Emergency Field Repairs:** Spend Gold ($40\text{g}$) to repair $+25\%$ Bastion HP.

---

### 3.3 Passive Item Relics & Zero-Allocation Proc Engine
1. **Inventory Capacity:**
   - Uncapped item inventory with additive stacking counters (`Map<String, int>` / flat array).
2. **Zero-Allocation Proc Hooks:**
   - Handled directly within `DamageResolver` and `CombatSystem`:
     - `onHit(target, damage, isCrit)`
     - `onCrit(target, damage)`
     - `onKill(target)`
     - `onIncomingHit(incomingDamage, isDeflected)`
     - `onInterval(seconds)`
3. **Initial 12 Core Relics Roster:**
   - **Spiky Bulwark:** Converts Armor to flat Retaliatory Thorns ($+2\text{ Thorns}$ per $1\%\text{ Armor}$).
   - **Mask of Ruin:** Thorns damage has a $50\%$ chance to trigger an AoE explosion ($50\%$ thorns dmg).
   - **Combustion Elixir:** Critical hits have a $40\%$ chance to detonate for $50\%$ splash damage.
   - **Bloodfang Dagger:** Critical strikes grant $+20\%$ chance to heal $1\text{ HP}$.
   - **Overclock Capacitor:** When Bastion drops below $40\%$ HP, triggers a 4s time warp ($50\%$ enemy slow, $2\times$ fire rate). 60s cooldown.
   - **Lucky Clover:** Grants flat $+10\%$ Luck.
   - **Iron Plating:** Grants $+25$ Max HP and $+5$ Armor.
   - **Magnetized Core:** $+50\%$ Attraction pull speed and $+10\%$ Gold drop rate.
   - **Volatile Cask:** Leaving enemies near the tower causes a poison puddle dealing $4\text{ dmg/s}$ for 4s.
   - **Heavy Springs:** Increases knockback force on all attacks by $+35\%$.
   - **Shatter Crystal:** Attacks have $15\%$ chance to freeze targets for 1.5s. Frozen targets take $+25\%$ damage.
   - **Cursed Idol:** Multiplies total Gold and XP gained by $1.5\times$, but increases enemy health and speed by $+20\%$.

---

### 3.4 Permanent Meta-Progression (Silver & Shrine of Heritage)
1. **Silver Currency Formula:**
   $$\text{Silver} = \lfloor \text{SurvivalSeconds} \times 0.2 \rfloor + (\text{ElitesKilled} \times 2) + (\text{BossesKilled} \times 10)$$
2. **The Shrine of Heritage (Permanent Talent Tree):**
   - **Reinforced Masonry:** $+2\%$ Base Max HP per rank (10 ranks).
   - **Forged Iron:** $+1$ Base Armor per rank (5 ranks).
   - **Spirit Blessing:** $+2\%$ Base Luck per rank (10 ranks).
   - **Golden Aura:** $+5\%$ In-Run Gold drop yield per rank (5 ranks).
   - **Scribe's Wit:** $+1$ Starting Reroll, Skip, or Banish charge.
3. **Persistence:**
   - Handled via `MetaRepository` using `SharedPreferences`, decoupled from the Flame game loop.

---

## 4. Phase 2 Incremental Milestones

```markdown
- [ ] Milestone 7: Item Relic Engine & Moat Chests
      - Implement ItemDef, ItemInstance, and 12 Core Relics
      - Build zero-allocation proc hooks in DamageResolver
      - Add Elite/Boss chest drops that auto-vacuum to the Bastion moat
      - Add tap-to-open chest interaction with visual fanfare
      - Build Pause Overlay Relic Inspector

- [ ] Milestone 8: The Traveling Merchant & Alchemical Forge
      - Build MerchantDirector: approaches Bastion at intervals
      - Implement 15s departure countdown timer
      - Build Merchant Shop Overlay (Buy Relics with Gold)
      - Implement Alchemical Forge tab (sacrifice/duplicate items for Gold)

- [ ] Milestone 9: Permanent Meta-Progression (Silver Economy)
      - Implement MetaRepository backed by SharedPreferences
      - Add Silver calculation formula to GameOver / Results screen
      - Build Main Menu / Shrine of Heritage upgrade tree
      - Feed unlocked meta-stats into StatEngine.recompute()

- [ ] Milestone 10: Phase 2 Economy Polish, Audio & Verification
      - Balance gold generation against merchant pricing and forge costs
      - Integrate SFX: chest creak/open, merchant chime/departure, forge hammer
      - Comprehensive unit and Flame tests across all new components
```

---

## 5. Phase 3 Scope Deferrals
The following features are formally moved to **Phase 3**:
- Additional Tower Chassis (Obsidian Fortress, Raiden Pagoda, Necro Spire)
- Field Shrines & Altars (Charge Shrines, Greed Shrine, Boss Curse Shrine)
- Mobile Warden Drone & Active Player Abilities
