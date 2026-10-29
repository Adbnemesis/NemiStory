# I Got Scammed — EP14 Script & Beat Sheet (Revision 3, Conversational & Scaled)

**Story:** Nemi tells the painfully embarrassing story of how her desperate scramble for sold-out concert tickets turned into getting scammed online. Sitting at three laptops counting down to 10 AM, she watches the official portal sell out in 12 seconds. Rather than accepting defeat, her brain convinces her she is an undercover genius capable of buying tickets "in black." Finding a reseller offering VIP passes, she goes "full FBI mode"—demanding screen recordings of confirmation emails, checking profile histories, and verifying timestamps until everything seems foolproof. But when the scammer drops a 5-minute urgency countdown, all her detective logic evaporates into panic. She transfers $300 of her savings, texts for the tickets, and is instantly greeted by a red exclamation mark and a blank, deleted avatar. Left sitting at her desk with a $12 bank balance, she delivers the hard-learned lesson: when tickets sell out, just stay home.

**Target Duration:** 151.93 seconds (~2 minutes 31 seconds, 4,558 frames @ 30 FPS).  
**Narrator:** Nemi (Canonical Sohee Qwen3-TTS voice, 24kHz, 321 words, paced 1.04–1.12x).  
**Direction Brief:**
- **Promise:** Understand how desperation and online ticket panic override common sense.
- **Want:** Get tickets to her favorite band's only tour date in the city.
- **Choice:** Trust a sketchy online reseller and pay money before receiving tickets.
- **Consequence:** The scammer takes the payment, deletes the listing, and blocks her instantly.
- **Payoff:** Face the empty bank account and share the hard-learned lesson to never buy in black.

---

### Shot & Environment Architecture (Prominent Character Scaling & 6 Cycling Sets)

| Shot | Time (s) | Focus / Narrative Beat | Environment | Camera Framing | Nemi Scale & Placement | Custom Vector Art / Props | SFX Accent |
|---|---|---|---|---|---|---|---|
| **00** | 0.00 – 8.67 | The Admission: Please don't judge me | `nemi_creator_studio` | Portrait (Z: 2.05) | Scale: 1.75 @ `[620, 570]` | `tabs`, text: *"COMMON SENSE: 404"*, `scratch` | `click.mp3` |
| **01** | 8.67 – 17.90 | Tour Announcement & Obsession | `bedroom_evening_r4` | Medium (Z: 1.60) | Scale: 1.80 @ `[540, 580]` | `scam_concert_poster`, `sparkle_stars`, text: *"1 NIGHT ONLY"* | `chime.mp3`, `ping.mp3` |
| **02** | 17.90 – 28.44 | Drop Morning: Sold Out in 12s | `room` | Medium (Z: 1.60) | Scale: 1.80 @ `[540, 580]` | `scam_sold_out_screen`, text: *"SOLD OUT IN 12s"* | `key-press.mp3`, `click.mp3`, `clock-ticking.mp3`, `error.mp3` |
| **03** | 28.44 – 42.42 | The Denial: Buying in Black | `thought` | Portrait (Z: 2.05) | Scale: 1.75 @ `[620, 570]` | `action_burst_mistake`, text: *"BUY IN BLACK"*, `underline` | `ping.mp3` |
| **04** | 42.42 – 52.88 | Shady Resale Forums | `lane_night_r4` | Medium (Z: 1.60) | Scale: 1.80 @ `[540, 580]` | `scam_resale_listing`, `arrow`, text: *"2 VIP PASSES"* | `notification.mp3` |
| **05** | 52.88 – 66.10 | Private Investigator: Full FBI Mode | `bedroom_evening_r4` | Portrait (Z: 2.05) | Scale: 1.75 @ `[620, 570]` | `scam_detective_badge`, `scam_sherlock_pipe`, text: *"FULL FBI MODE"* | `click.mp3`, `chime.mp3` |
| **06** | 66.10 – 80.94 | Smug Hubris: I Am Actually a Genius | `room` | Medium (Z: 1.60) | Scale: 1.80 @ `[540, 580]` | `scam_concert_poster`, `sparkle_stars`, text: *"I'M A GENIUS"* | `ping.mp3` |
| **07** | 80.94 – 96.76 | Scammer's Trap: 5-Minute Timer | `evening` | Portrait (Z: 2.05) | Scale: 1.75 @ `[620, 570]` | `scam_urgency_timer`, `sweat_drops`, text: *"5 MINUTES LEFT"* | `notification.mp3`, `clock-ticking.mp3` |
| **08** | 96.76 – 107.44 | Panic Transfer: Savings Sent | `thought` | Medium (Z: 1.60) | Scale: 1.80 @ `[540, 580]` | `scam_bank_transfer`, text: *"-300.00"*, `spark` | `key-press.mp3`, `click.mp3` |
| **09** | 107.44 – 121.17 | The Red Exclamation: Instant Block | `lane_night_r4` | Portrait (Z: 2.05) | Scale: 1.75 @ `[620, 570]` | `scam_blocked_alert`, text: *"USER NOT FOUND"* | `error.mp3`, `bruh.mp3` (hero punch) |
| **10** | 121.17 – 133.38 | The Aftermath: Staring at $12 | `bedroom_evening_r4` | Medium (Z: 1.60) | Scale: 1.80 @ `[540, 580]` | `scam_empty_wallet`, text: *"BALANCE: 12.00"* | `pop.mp3` |
| **11** | 133.38 – 151.93 | The Hard Moral: Just Stay Home | `nemi_creator_studio` | Portrait (Z: 2.05) | Scale: 1.75 @ `[620, 570]` | `desk`, `mug`, `scam_ghost_soul`, text: *"JUST STAY HOME"*, `underline` | `click.mp3` |

---

### Acting & Performance Flow (38 Authored Transitions)
- **Character Presence:** Nemi strictly commands 60%–80% of vertical screen height across all shots, eliminating the miniature/tiny doll appearance.
- **Eyes & Poses:** Eyes lead before head/body settles, utilizing canonical Nemi performance recipes (`school_confide`, `explaining`, `soft_shrug`, `pleased`, `school_point`, `passenger_worried`, `passenger_deadpan`, `school_recoil`, `overwhelmed`, `realization`, `school_resolve`, `school_question`, `skeptical`, `prop_present`, `embarrassed`, `quiet_recoil`, `school_brace`, `uncertain`, `school_shame`, `school_relief`, `school_gasp`, `deadpan`).
- **Mouth Synchronization:** 588 phoneme intervals mapped to Whisper word timings, utilizing verified Nemi mouth shapes (`closed`, `o_u`, `ae`, `small_open`), bounded strictly inside non-overlapping spoken turns.
- **Captions:** 87 chunked caption cards (maximum 5 words per card) formatted for readable mobile & desktop viewing, strictly tracking measured speech times with zero drift.
- **Sound Design:** 18 event-linked SFX cues calibrated via EBU R128 (`-18.0 LUFS` integrated loudness target, `-1.5 dBFS` true peak headroom). All assets sourced from verified root MP3 inventory.
