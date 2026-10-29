# EP14 Direction: I Got Scammed

## 1. Five-Sentence Core Brief
- **Promise:** A desperate hunt for sold-out concert tickets leads to an expensive trap.
- **Want:** Get tickets to see her favorite band live at any cost.
- **Choice:** Buy black-market tickets online and convince herself she verified everything.
- **Consequence:** She sends the payment and gets instantly blocked.
- **Payoff:** Total silence at her desk with the brutal realization that she paid someone to block her.

---

## 2. Creative Concept & Narrative Escalation
- **Narrator:** Nemi (Canonical Sohee voice).
- **Core Comedy Engine:** The **Hubris Collapse** arc.
  - Phase 1 (Desperation): The visceral heartbreak of watching official ticket portals crash into "SOLD OUT" within a millisecond.
  - Phase 2 (The Bad Idea): Refusing to accept reality; turning to shady online resellers / black market tickets.
  - Phase 3 (The Detective Fantasy): Overcompensating for the sketchiness by doing "forensic verification"—asking for screenshots, timestamps, booking reference codes, convincing herself she is practically Sherlock Holmes.
  - Phase 4 (The Sudden Crash): Sending the money... and receiving the immediate error: *"Message failed to send. User not found. You have been blocked."*
  - Phase 5 (The Void Stare): 0-velocity comedic freeze. Staring dead-center into the camera lens with the phone resting on the desk.

---

## 3. Staging, Backgrounds & Color Palette
- Follows the approved **EP06 colour reference** (`docs/animation/STORYTIME_EPISODE_COLOUR_THEME.md`):
  - Cream paper canvas (`#faf7f2`), warm neutral floor (`#f2ebe0`).
  - Dark burgundy ink contours (`#2e1822`) and soft background linework (`#6b5763`).
  - Canonical color-mode Nemi (auburn hair, sage hoodie).
  - Background locations:
    - `studio_nemi`: Desk with laptop, drawing tablet, and coffee mug.
    - `thought`: Minimal cream space for abstract mental dilemmas and ticket searches.
    - `paper`: Pure paper background for the stark deadpan payoff.
  - Selective accent colors:
    - Vibrant red (`#c93b4a`) for the "SOLD OUT" banner and "BLOCKED" screen.
    - Cool blue/teal (`#3b82a6`) for the ticket portal interface and chat bubbles.
    - Warm coral blush (`#d97d88`) on Nemi's cheeks during confession.

---

## 4. Props & Hand Interactions
- **Laptop (`laptop`)**: Grounded on the desk surface, displaying ticket countdown and sold-out alerts.
- **Desk (`desk`)**: Grounded baseline at y717.
- **Smartphone (`phone`)**: Held during chat negotiation with the reseller; attached via Nemi's supported hand socket (`[0, 8]`).
- **Live Inking / Marks**:
  - Live drawing of ticket stub with dashed borders.
  - Bold red scratch-out over "SOLD OUT".
  - Checklist doodle: "Real profile? ✓ Timestamps? ✓ Bank details? ✓"
  - Scribbled cross-out over the scammer's handle upon getting blocked.

---

## 5. Camera & Visual Rhythm
- Thought-driven framing per `COMMON_CAMERA_STAGING.md`:
  - Medium wide for opening exposition and desk setup (`zoom: 1.0`, `center: [960, 540]`).
  - Reframe toward laptop screen for the countdown ticket rush (`zoom: 1.15`).
  - Medium portrait for Nemi's proud detective explanation (`zoom: 1.35`).
  - Hard punch-in on the exact moment the "BLOCKED" notification appears (`zoom: 1.55`).
  - Pull back to still portrait for the quiet, deadpan aftermath (`zoom: 1.25`).

---

## 6. Sound Architecture
- Root meme SFX and verified library clips:
  - `ui_click_tactile_01`: Keyboard clicks and mouse refresh.
  - `comedic_wrong_buzzer_01`: Ticket sold out fail buzz.
  - `drawing_scratch_scribble_01`: Verification checklist pen strokes.
  - `ui_confirm_chime_01`: Bank transfer send chime.
  - `bruh.mp3` (`viral_bruh`): Impact accent on getting blocked.
  - Sustained deadpan silence (1.5s+) after the block to let the embarrassment breathe.
