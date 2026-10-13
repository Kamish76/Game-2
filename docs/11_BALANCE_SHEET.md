# 11: Master Balance Sheet

> [!NOTE]
> **LIVING / TUNABLE CONFIGURATION**
> All values here represent the initial baseline calibration for the prototype. As playtesting progresses, modifications to constants should be reflected here.

---

## 1. Bastion & Character Baseline

| Metric | Kitsune Spire (Starting) | Default Baseline | Unit / Scale |
|---|---|---|---|
| Max Structural HP | 100 | 100 | Points |
| Starting Shield | 0 | 0 | Points (5s out-of-combat recharge) |
| Starting Armor | 0 | 0 | Points ($A / (A + 100)$) |
| Starting Deflect | 0% | 0% | Points ($E / (E + 100)$) |
| Innate Luck | 15% | 0% | Percentage |
| Luck Scaling | +1.5% | 0% | Additive per Level-Up |
| Attraction Radius | 48 | 48 | Pixels (Fallback; standard drops vacuum globally) |
| Max Weapon Slots | 4 | 4 | Discrete Slots |
| Max Tome Slots | 4 | 4 | Discrete Slots |

---

## 2. Weapon Arsenal Baseline (Level 1 Common)

| Weapon | Damage | Cooldown | Projectiles | Proj Speed | Radius | Pierce | Range | Knockback |
|---|---|---|---|---|---|---|---|---|
| **Ember Staff** | 18.0 | 1.25s | 1 | 140 px/s | 28 px | 0 | 180 px | 12 px |
| **Revolver Battery** | 8.0 | 0.45s | 1 | 220 px/s | 0 px | 1 | 150 px | 6 px |
| **Pulse Aura** | 10.0 | 1.80s | 1 | 0 px/s | 42 px | $\infty$ | 42 px | 18 px |
| **Rail Sniper** | 40.0 | 2.40s | 1 | 320 px/s | 0 px | 3 | 220 px | 25 px |

### Upgrade Increment Scale (Common 1.0× baseline)
- **Ember Staff:** $+3.0\text{ Dmg}$, $+4\text{ px Radius}$, $-0.08\text{s CD}$.
- **Revolver Battery:** $+2.0\text{ Dmg}$, $+1\text{ Proj}$, $-0.04\text{s CD}$.
- **Pulse Aura:** $+2.5\text{ Dmg}$, $+6\text{ px Radius}$, $-0.12\text{s CD}$.
- **Rail Sniper:** $+8.0\text{ Dmg}$, $+1\text{ Pierce}$, $-0.15\text{s CD}$.

---

## 3. Global Tomes Calibration (Common 1.0× Increment)

| Tome | Target Stat | Base Increment | Max Level |
|---|---|---|---|
| **Damage Tome** | `damage` | +8% (+0.08×) | 10 |
| **Cooldown Tome** | `attackSpeed` | +7.5% | 10 |
| **Quantity Tome** | `quantity` | +1 Projectile | 5 |
| **Size Tome** | `size` | +10% | 10 |
| **Armor Tome** | `armor` | +12 Points | 10 |
| **Luck Tome** | `luck` | +8% | 10 |
| **XP Tome** | `xpGain` | +10% | 10 |
| **Cursed Tome** | `curse` | +5% | 10 |

---

## 4. Horde Enemy Scaling

| Enemy | Credit Cost | HP | Speed | Contact Dmg | Attack Interval | Knockback Resist |
|---|---|---|---|---|---|---|
| **Swarmling** | 1 | 18 | 48 px/s | 4 | 1.0s | 0% |
| **Runner** | 2 | 24 | 72 px/s | 6 | 0.8s | 10% |
| **Brute** | 6 | 90 | 32 px/s | 18 | 1.5s | 65% |
| **Spitter** | 5 | 45 | 40 px/s | 8 (proj) | 2.0s | 25% |
| **Yokai Goliath** | 50 | 1,500 | 22 px/s | 35 | 2.0s | 90% |

---

## 5. Economy & Escalation Curves
- **XP per Level:** $\text{xpToNext}(L) = \text{round}\left(5 + 4(L-1) + 0.6(L-1)^2\right)$.
- **Spawn Budget:** $\text{CreditsPerSec}(t) = 0.8 \times e^{0.008t} \times (1 + \text{Curse})$.
- **Overtime Surge (15:00+):** $+100\%$ Spawn credits rate, $+5\%\text{ HP}$ per 30s survived.
- **Boss HP Scaling:** $1,500 + 175 \times (\text{WaveCount} - 1)$.
