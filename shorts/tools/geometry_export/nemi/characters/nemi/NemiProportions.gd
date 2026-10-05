class_name NemiProportions
extends RefCounted

## Master Proportion Constants for NEMI
## Centralizes all anatomical and stylistic dimensions to guarantee visual harmony.
## Designed for a hand-drawn creator avatar: cute, soft, expressive, and balanced.

# -------------------------------------------------------------------------
# HEAD & FACE PROPORTIONS (Local origin (0, 0) is Chin)
# -------------------------------------------------------------------------
const HEAD_HEIGHT: float = 92.0               # Chin to top of skull (compact cute anime skull)
const HEAD_WIDTH: float = 92.0                # Temple to temple width
const FACE_WIDTH_AT_CHEEKS: float = 90.0      # Youthful cheek fullness
const JAW_WIDTH: float = 48.0                 # Gentle soft taper to rounded chin
const CHIN_RADIUS: float = 18.0               # Soft, rounded chin curve (no sharp triangle)

const EYE_POS_Y: float = -44.0                # Eye center height relative to chin (youthful ~45% mark)
const EYE_OFFSET_X: float = 23.5              # Left eye center = -23.5, Right = +23.5
const EYE_WIDTH: float = 24.0                 # Total eye width
const EYE_HEIGHT: float = 18.0                # Total eye height
const INTEROCULAR_GAP: float = 23.0           # Gap between inner eye corners (~1 eye width)
const CHEEK_MARGIN: float = 10.0              # Space between outer eye corner and cheek outline

const NOSE_POS_Y: float = -24.0               # Delicate nose tick height
const MOUTH_POS_Y: float = -13.0              # Resting mouth height
const EYEBROW_POS_Y: float = -56.0            # Eyebrow arch height (framing eyes naturally)

# -------------------------------------------------------------------------
# HAIR SILHOUETTE (VOLUMINOUS DOME, SOFT BANGS, COMPACT CROWN)
# -------------------------------------------------------------------------
const HAIR_CROWN_Y: float = -104.0            # Crown apex height (soft voluminous dome above skull)
const HAIR_MAX_WIDTH: float = 118.0           # Generous horizontal fluff (width 118)
const HAIR_LENGTH: float = 185.0              # Vertical mane down the back
const AHOGE_HEIGHT: float = 34.0              # Crown cowlick flicking right
const AHOGE_OFFSET_X: float = 24.0            # Horizontal reach of ahoge tip

# -------------------------------------------------------------------------
# TORSO, SHOULDERS & GARMENTS (Hip / Pelvis is root origin (0, 0))
# -------------------------------------------------------------------------
const NECK_ROOT_Y: float = -74.0              # Top of torso / base of neck
const HEAD_ROOT_Y: float = -92.0              # Base of chin
const SHOULDER_WIDTH: float = 88.0            # Left shoulder = -44, Right = +44
const TORSO_WIDTH: float = 72.0               # Relaxed hoodie width at chest
const HOODIE_WAIST_WIDTH: float = 74.0        # Ribbed bottom hem band width
const HOODIE_LENGTH: float = 72.0             # Torso height

const SKIRT_ROOT_Y: float = 0.0               # High-waisted belt line
const SKIRT_LENGTH: float = 52.0              # Pleated tennis skirt length
const SKIRT_TOP_WIDTH: float = 62.0           # Waistband width
const SKIRT_HEM_WIDTH: float = 84.0           # Flared A-line hem width

# -------------------------------------------------------------------------
# LIMBS & SNEAKERS (Long, graceful anime legs)
# -------------------------------------------------------------------------
const UPPER_ARM_LENGTH: float = 62.0          # Shoulder to elbow
const LOWER_ARM_LENGTH: float = 58.0          # Elbow to wrist
const HAND_LENGTH: float = 20.0               # Wrist to fingertips

const THIGH_LENGTH: float = 82.0              # Hip to knee
const SHIN_LENGTH: float = 86.0               # Knee to ankle
const FOOT_HEIGHT: float = 26.0               # Ankle to sneaker sole
const TOTAL_LEG_LENGTH: float = 194.0         # Hip to ground line (82 + 86 + 26)

const TOTAL_HEIGHT: float = 430.0             # Sneaker sole (+194) to Ahoge tip (-138)
