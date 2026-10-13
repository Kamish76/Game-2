# 06: Audio Asset Specification & Checklist

## Purpose
Outlines sound design directions, file formats, and master checklists for sound effects (SFX) and musical tracks.

---

## 1. Technical Audio Constraints
- **Audio Engine:** `flame_audio` (utilizing `audioplayers` underneath).
- **Format:**
  - SFX: `.ogg` (Vorbis) for Android/Web; `.wav` or `.caf` fallbacks for iOS. 44.1 kHz, 16-bit mono.
  - Music: Seamlessly looping `.ogg`, compressed, stereo, under 4 MB per track.
- **Sound Design Style:** Chunky 16-bit arcade aesthetic—crisp square/saw waves, punchy FM bass impacts, and resonant harmonic chimes for level-ups.

---

## 2. Master Audio Checklist

### 2.1 Weapon & Combat SFX
| Asset ID | Description | Style / Reference | Priority | Status |
|---|---|---|---|---|
| `sfx_shoot_ember` | Fireball launch whoosh | Low-pass filtered flame pop | P0 | Planned |
| `sfx_explode_ember` | Detonation blast on enemy hit | Muffled explosive crump | P0 | Planned |
| `sfx_shoot_revolver` | Snappy gunshot crack | High-pitched metallic snap | P0 | Planned |
| `sfx_pulse_aura` | Radial harmonic energy surge | Low resonant sub-sweep | P0 | Planned |
| `sfx_shoot_rail` | High-voltage railgun discharge | Electric laser discharge | P0 | Planned |
| `sfx_crit_impact` | High-frequency critical strike chime | Bright crystal chime ping | P0 | Planned |

### 2.2 Bastion & Defense SFX
| Asset ID | Description | Style / Reference | Priority | Status |
|---|---|---|---|---|
| `sfx_bastion_hit` | Enemy strikes the tower hull | Heavy wooden/stone impact | P0 | Planned |
| `sfx_bastion_deflect` | Attack glanced by Deflect matrix | Metallic ping / deflect spark | P0 | Planned |
| `sfx_shield_absorb` | Energy shield takes damage | High-tech fizzle / hum | P0 | Planned |
| `sfx_bastion_destroyed` | Tower integrity reaches 0 | Crumbling stone catastrophe | P0 | Planned |

### 2.3 Enemies & Pickups
| Asset ID | Description | Style / Reference | Priority | Status |
|---|---|---|---|---|
| `sfx_enemy_death_small`| Swarmling/Runner killed | Squishy crunch / pop | P0 | Planned |
| `sfx_enemy_death_large`| Brute/Goliath killed | Heavy bass rumble | P0 | Planned |
| `sfx_pickup_xp` | XP shard vacuumed into tower | High ascending pitched blip | P0 | Planned |
| `sfx_pickup_gold` | Gold coin collected | Classic arcade dual-tone ding | P0 | Planned |
| `sfx_shard_merge` | Low-tier shards merge into gem | Electric synthesis shimmer | P1 | Planned |

### 2.4 UI & Fanfares
| Asset ID | Description | Style / Reference | Priority | Status |
|---|---|---|---|---|
| `sfx_ui_click` | Button pressed / menu tap | Subtle wooden tap | P0 | Planned |
| `sfx_levelup_jingle` | XP bar filled, Level-Up screen opens | Glorious ascending arpeggio | P0 | Planned |
| `sfx_card_reveal_legend`| Legendary rarity card revealed | Thundering golden choir stinger| P0 | Planned |

### 2.5 Music Tracks
| Asset ID | Usage | BPM / Mood | Priority | Status |
|---|---|---|---|---|
| `bgm_endless_main` | Core endless gameplay (00:00 - 15:00) | 128 BPM, driving synthwave with traditional shamisen accents | P0 | Planned |
| `bgm_boss_encounter` | 3-minute boss encounters | 140 BPM, urgent rhythmic percussion | P1 | Planned |
| `bgm_overtime_surge` | Final Swarm overtime (15:00+) | 150 BPM, intense distorted bassline | P1 | Planned |
