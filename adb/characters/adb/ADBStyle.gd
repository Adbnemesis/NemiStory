class_name ADBStyle
extends RefCounted

## Master Visual Style & Palette Standards for ADB Character
## Completely independent from Nemi; matches ADB Model Sheet (adb/docs/adb_model_sheet.jpg).

# --- MASTER PALETTES ---
const INK_CONTOUR: Color = Color("#2b2623")              # Deep charcoal sepia contour line
const INK_INNER: Color = Color("#3a3430")                # Subtle inner fold ink
const INK_HAIR: Color = Color("#161922")                 # Deepest hair contour

# Skin tones (Warm, healthy peach-buff anime skin — distinct from paper-white background)
const SKIN_BASE: Color = Color("#f6d4be")                # Healthy warm peach-buff anime skin
const SKIN_SHADOW: Color = Color("#e2b59b")              # Warm amber-peach shadow
const BLUSH_COLOR: Color = Color(0.957, 0.48, 0.42, 0.55) # Watercolor cheek wash
const BLUSH_HATCH: Color = Color("#a83b3b")              # Flustered hatch lines

# Hair tones (Dark slate charcoal with indigo undertone)
const HAIR_BASE: Color = Color("#1e222d")                # Base hair volume
const HAIR_MIDTONE: Color = Color("#2d3545")            # Depth strand separation
const HAIR_GLINT: Color = Color("#4a5770")               # Specular hair highlight

# Outfit: Relaxed Sage Green Collared Shirt (matches Nemi's signature sage green)
const SHIRT_BASE: Color = Color("#739879")               # Signature sage green (same color as Nemi's hoodie)
const SHIRT_SHADOW: Color = Color("#55775b")             # Deeper olive-sage fold shadow
const SHIRT_COLLAR: Color = Color("#618667")             # Crisp shirt collar & cuffs
const INNER_TEE: Color = Color("#f5f4ef")                # Clean off-white crewneck undershirt
const BUTTON_COLOR: Color = Color("#2b2623")             # Subtle dark horn buttons

# Aliases for backward compatibility
const SWEATER_BASE: Color = SHIRT_BASE
const SWEATER_SHADOW: Color = SHIRT_SHADOW
const SWEATER_RIB: Color = SHIRT_COLLAR
const ZIPPER_HARDWARE: Color = BUTTON_COLOR

# Trousers: Wide-leg relaxed pants in off-white / ecru linen-cotton
const TROUSER_BASE: Color = Color("#ece8df")            # Warm off-white / light ecru
const TROUSER_SHADOW: Color = Color("#d8d2c4")          # Soft warm shadow in pant drape folds
const TROUSER_SEAM: Color = Color("#c7bfad")            # Subtle seam & crease line

# Sneakers: Minimalist low-top canvas with dark contrast upper & off-white rubber toe
const SNEAKER_BASE: Color = Color("#2a2c32")            # Dark charcoal canvas upper for contrast
const SNEAKER_SOLE: Color = Color("#ede9df")            # Clean off-white rubber sidewall & toe cap
const SNEAKER_TREAD: Color = Color("#8a7155")           # Warm gum rubber bottom contact line

# Line weights (1080p canvas)
const LINE_WEIGHT_MAIN: float = 3.2
const LINE_WEIGHT_DETAIL: float = 2.2
const LINE_WEIGHT_BOLD: float = 4.2
