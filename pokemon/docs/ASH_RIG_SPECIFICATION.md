# Ash Ketchum Vector Rig Specification

## Overview
The Ash Ketchum character rig in `pokemon/characters/ash/` is a 100% native 2D vector rig capturing Ash's canonical Indigo League design in an organic pen-and-ink hand-drawn aesthetic, faithfully adhering to official anime reference art.

---

## Node Hierarchy & Z-Ordering

```
Ash (Ash.gd - Master Director)
└── AshVisual (AshVisual.gd - Coordinate & Pivot Manager)
    ├── Limbs (AshLimbs.gd, z_index = 0)
    │   ├── Denim Jeans (Slate Blue #7FA6C7) + Rolled White Cuffs (#F5F5F5)
    │   ├── High-Top Sneakers (Dark Gray #212529, Red Ankle Patches #D9383A, White Toe Caps)
    │   └── Arms & Hands (Skin Tone, Green Fingerless Gloves #2D6A4F, Mint Cuffs #74C69D)
    ├── Torso (AshTorso.gd, z_index = 1)
    │   ├── Canonical Green Traveler Backpack (Body: Leaf Green #4C8B3E, Side Pouch: Orange #E67E22)
    │   ├── Neck Base + Chiseled Throat Shadow Crease
    │   ├── Inner Crewneck Undershirt (Charcoal Black #212529)
    │   ├── Open Vest (Cobalt Blue #1D65A6, Yellow Trim #F4A261, Gold Buttons #F4A261)
    │   ├── Green Backpack Chest Straps (Straps: #5CA24C, Buckles: #CED4DA)
    │   ├── Stand-up Crisp White Vest Collar Lapels (#FBF8F3)
    │   └── Leather Belt (Dark Brown #723D1C) + Metallic Silver Buckle (#CED4DA)
    └── Head (Node2D, Pivot = Vector2(0, -145), z_index = 2)
        ├── Head & Cap Base (AshHead.gd, z_index = 0 relative to Head)
        │   ├── Back Spiky Hair Wings (Charcoal #1E1D24 radiating behind ears)
        │   ├── Canonical Indigo League Cap:
        │   │   ├── Red Crown Dome (#D9383A)
        │   │   ├── White Semi-Circular Front Panel (#FBF8F3)
        │   │   ├── Official Green Stylized League "C" Logo (#2A9D8F)
        │   │   ├── Red Cap Visor (#D9383A) + Crimson Underside Shadow (#8F2325)
        │   │   └── Backward Cap Toggle State (Visor reversed, red dome front, hair tuft reveal)
        │   ├── Ears (Skin Tone with Inner Cartilage Fold)
        │   └── Front Hair Bangs:
        │       ├── Signature Center Triangular Forehead Bang (reaching down to y = -2 between eyes)
        │       ├── Left & Right Forehead Spikes
        │       └── Temple Framing Locks / Sideburns
        └── Face (AshFace.gd, z_index = 1 relative to Head)
            ├── Anime Eyes (Tall 90s anime proportions, Dark Brown Iris #3D281D, Jet Pupil #262224)
            ├── Signature Vertical Pill Catchlight (Pure white capsule highlight on pupil)
            ├── Independent Eyebrows (Vertical & Angular Offsets for Acting)
            ├── Signature Horizontal "Z" Lightning Cheek Marks (Two horizontal jagged marks per cheek)
            ├── Nose (Sharp Small Triangular Hook with Warm Nostril Shadow)
            ├── Mouth Visemes (Smile, Confident Grin, Open Shout, etc.)
            └── Overlays (Diagonal Blush Patches, Anime Sweat Droplets)
```

---

## Part Specifications

### 1. Head, Hair & Indigo League Cap (`AshHead.gd`)
- **Hair System**:
  - **Center Forehead Bang**: Prominent sharp triangular hair clump positioned right between the eyes, extending down to $y = -2$ (just above the nose bridge).
  - **Flanking Forehead Spikes**: Additional hair tufts angling downward toward the eyebrows.
  - **Sideburns / Temple Locks**: Chunky black locks framing the face in front of the ears.
  - **Back Hair Wings**: Large dynamic wedges radiating laterally behind the ears.
- **Indigo League Cap**:
  - `is_cap_backward = false` (Standard Forward):
    - Red crown dome (`#D9383A`).
    - Crisp white front trapezoidal panel (`#FBF8F3`).
    - Stylized green Indigo League emblem (`#2A9D8F`).
    - Red visor with depth shadow (`#8F2325`) arching cleanly above the brows.
  - `is_cap_backward = true` (Battle Ready):
    - Visor swings to the back-left.
    - Red crown dome faces front with an arched cutout and black snapback strap over the forehead.

### 2. Facial Acting & Eyes (`AshFace.gd`)
- **Anime Eyes**:
  - Tall curved anime eye shape with pure white sclera.
  - Iris colored rich warm brown `#3D281D` with jet pupil `#262224`.
  - **Vertical Pill Catchlight**: Canonical 90s elongated vertical pill reflection on the pupil, plus a secondary lower specular highlight dot.
  - Upper eyelid is a bold calligraphic inking stroke slanting downwards toward the center.
- **Eyebrows**:
  - Thick athletic eyebrows at $y = -12$ responding independently to `left_brow_offset`, `right_brow_offset`, `left_brow_tilt`, and `right_brow_tilt`.
- **Horizontal "Z" Cheek Marks**:
  - Two distinct horizontal jagged lightning strokes on each cheek, drawn in organic warm ink `#262224`.
- **Nose**:
  - Sharp small triangular hook at $(0, 5)$ with soft warm nostril shadow underneath.
- **Mouth Visemes**:
  - `"smile"`, `"confident_grin"`, `"open_happy"`, `"open_shout"`, `"shock_o"`, `"wavy"`, `"dash"`, `"grit"`, `"frown"`, `"deadpan"`.

### 3. Torso, Canonical Vest & Green Backpack (`AshTorso.gd`)
- **Canonical Green Traveler Backpack**:
  - `show_bag = true` (default):
    - Main Pack Body: Leaf green (`#4C8B3E`) visible behind both shoulders with top carry handle.
    - Orange Utility Pouch: Warm golden-orange (`#E67E22`) pocket accent on the left pack bulge.
    - Front Chest Straps: Two green straps (`#5CA24C`) running down the chest over the vest, complete with silver adjustment buckles.
  - Toggle API: `ash.set_bag_visible(false)` to hide the bag if necessary.
- **Outfit**:
  - Dark inner crewneck shirt (`#212529`).
  - Open cobalt blue vest (`#1D65A6`) with crisp white collar lapels (`#FBF8F3`), yellow trim (`#F4A261`), and twin gold buttons.
  - Leather belt (`#723D1C`) with silver buckle (`#CED4DA`).
  - `torso_lean` transforms the entire upper body, bag, straps, and collar synchronously.

### 4. Directorial API Additions (`Ash.gd`)
```gdscript
# Bag Controls:
ash.set_bag_visible(true)     # Shows canonical green backpack & straps
ash.set_bag_visible(false)    # Hides backpack & straps
ash.is_bag_visible()          # Returns boolean status
```
