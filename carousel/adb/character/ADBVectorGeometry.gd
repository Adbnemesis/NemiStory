class_name ADBVectorGeometry
extends RefCounted

## Independent Native Vector Geometry for ADB Carousel Character
## Zero AI generation, zero raster dependencies, 100% Godot 4 vector drawing.
## Perfectly matches NEMI's carousel comic art style & proportion system:
## - Stylized ~3.5 to 4 heads tall proportion system (Head ~95px, Body ~265px)
## - Bold, expressive 3.2-3.8px ink line art
## - Canonical ADB visual identity from episode 8 & official reference:
##   * Sleek slate curtain-parted mop with two distinctive crown antenna tufts
##   * Sage green button-down shirt with open V-collar lapels & button placket
##   * Rolled-up sleeve cuffs with bare forearms
##   * Relaxed ecru / off-white linen trousers with center creases
##   * Dark canvas sneakers with off-white rubber toe caps
##   * Expressive almond anime eyes with corner hash accents

# --- PALETTE ---
const COLOR_PAPER := Color("#faf6ee")
const COLOR_INK := Color("#24252b")               # Deep warm charcoal comic ink
const COLOR_INK_HAIR := Color("#161820")          # Deep hair ink outline
const COLOR_HAIR := Color("#1e222d")              # Slate navy/black base hair
const COLOR_HAIR_HIGHLIGHT := Color("#3c465a")    # Cool slate glint
const COLOR_SKIN := Color("#fbf3eb")              # Fair warm peach anime skin
const COLOR_SKIN_SHADOW := Color("#eddccf")        # Soft warm shadow
const COLOR_BLUSH := Color("#f8b4a0")

# Shirt: Signature Sage Green
const COLOR_SHIRT := Color("#739879")             # Canonical sage green
const COLOR_SHIRT_SHADOW := Color("#587a5e")       # Olive-sage shadow
const COLOR_SHIRT_COLLAR := Color("#618667")       # Open collar lapels & cuffs
const COLOR_BUTTON := Color("#24252b")             # Small buttons

# Trousers: Relaxed Ecru Linen
const COLOR_TROUSERS := Color("#ece8df")          # Off-white / ecru
const COLOR_TROUSERS_SHADOW := Color("#dbd4c5")    # Soft shadow
const COLOR_TROUSER_SEAM := Color("#c7bfad")      # Tailored center crease

# Sneakers: Minimalist low-top canvas
const COLOR_SNEAKER_BASE := Color("#2a2c32")      # Dark canvas upper
const COLOR_SNEAKER_SOLE := Color("#ede9df")      # Off-white rubber toe cap & sole
const COLOR_SNEAKER_TREAD := Color("#8a7155")     # Gum sole accent

# Eyes
const COLOR_EYE_IRIS := Color("#263248")          # Slate navy anime iris
const COLOR_EYE_PUPIL := Color("#131a26")         # Pupil

# Line Weights
const LINE_WEIGHT_MAIN: float = 3.6
const LINE_WEIGHT_DETAIL: float = 2.0
const LINE_WEIGHT_BOLD: float = 4.0

# -------------------------------------------------------------------------
# HEAD & JAW (Origin (0, 0) is Chin Apex - Matching Nemi scale)
# -------------------------------------------------------------------------

static func get_head_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0))            # Chin apex
	c.add_point(Vector2(24, -12), Vector2(-7, 4), Vector2(8, -6))          # Lower jaw
	c.add_point(Vector2(44, -34), Vector2(-5, 12), Vector2(-1, -8))        # Cheek
	c.add_point(Vector2(40, -56), Vector2(2, 10), Vector2(-2, -10))        # Temple
	c.add_point(Vector2(26, -84), Vector2(8, 8), Vector2(-8, -6))          # Upper dome
	c.add_point(Vector2(0, -96), Vector2(14, 0), Vector2(-14, 0))          # Skull apex
	var right_pts := c.tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

static func get_jaw_outline() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0))
	c.add_point(Vector2(24, -12), Vector2(-7, 4), Vector2(8, -6))
	c.add_point(Vector2(44, -34), Vector2(-5, 12), Vector2(-1, -8))
	c.add_point(Vector2(40, -54), Vector2(2, 10), Vector2(0, 0))
	var right_pts := c.tessellate(5, 1.5)
	
	var jaw := PackedVector2Array()
	for i in range(right_pts.size() - 1, 0, -1):
		jaw.append(Vector2(-right_pts[i].x, right_pts[i].y))
	for pt in right_pts:
		jaw.append(pt)
	return jaw

# -------------------------------------------------------------------------
# HAIR: SIGNATURE CURTAIN BANGS & CROWN ANTENNA TUFTS
# -------------------------------------------------------------------------

static func get_hair_back_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, -112), Vector2(-25, 0), Vector2(25, 0))         # Crown top
	c.add_point(Vector2(58, -84), Vector2(-14, -18), Vector2(10, 18))      # Upper volume
	c.add_point(Vector2(62, -26), Vector2(5, -20), Vector2(-5, 20))        # Cheek flare
	c.add_point(Vector2(44, 20), Vector2(8, -12), Vector2(-8, 12))         # Lower nape flare
	c.add_point(Vector2(18, 14), Vector2(8, 4), Vector2(-8, -4))           # Nape
	c.add_point(Vector2(0, 10), Vector2(10, 0), Vector2(-10, 0))           # Center nape
	var right_pts := c.tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

## Curtain bangs: Solid crown covering top of head with genuine parted curtain swoops
static func get_front_curtain_bangs() -> PackedVector2Array:
	return PackedVector2Array([
		# Crown perimeter
		Vector2(0, -112), Vector2(32, -104), Vector2(52, -82), Vector2(56, -48),
		# Right curtain swoop framing cheek
		Vector2(52, -16), Vector2(44, -8), Vector2(36, -26),
		Vector2(26, -50), Vector2(14, -68),
		# Center part apex (triangle opening revealing forehead)
		Vector2(2, -82), Vector2(0, -80), Vector2(-2, -82),
		# Left curtain swoop framing cheek
		Vector2(-14, -68), Vector2(-26, -50), Vector2(-36, -26),
		Vector2(-44, -8), Vector2(-52, -16),
		# Left crown perimeter back to top
		Vector2(-56, -48), Vector2(-52, -82), Vector2(-32, -104)
	])

## ADB's Iconic Crown Antenna Tufts (the two signature flick horns)
static func get_crown_tufts() -> Array[PackedVector2Array]:
	var tufts: Array[PackedVector2Array] = []
	# Left antenna flick
	var t1 := PackedVector2Array([
		Vector2(-10, -104), Vector2(-28, -128), Vector2(-18, -126), Vector2(-4, -106)
	])
	tufts.append(t1)
	
	# Right antenna flick
	var t2 := PackedVector2Array([
		Vector2(4, -106), Vector2(18, -126), Vector2(28, -128), Vector2(10, -104)
	])
	tufts.append(t2)
	return tufts

# -------------------------------------------------------------------------
# SHIRT TORSO & OPEN COLLAR
# -------------------------------------------------------------------------

static func get_shirt_torso_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-26, 8),      # Left neck
		Vector2(-50, 24),     # Left drop-shoulder
		Vector2(-44, 65),     # Left armpit
		Vector2(-36, 115),    # Left waist / hem
		Vector2(0, 118),      # Center hem curve
		Vector2(36, 115),     # Right waist / hem
		Vector2(44, 65),      # Right armpit
		Vector2(50, 24),      # Right drop-shoulder
		Vector2(26, 8)        # Right neck
	])

static func get_collar_lapel_left() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-24, 6), Vector2(-14, 2), Vector2(-4, 28), Vector2(-16, 34)
	])

static func get_collar_lapel_right() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(24, 6), Vector2(14, 2), Vector2(4, 28), Vector2(16, 34)
	])

static func get_bare_neck_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-12, 0), Vector2(12, 0), Vector2(8, 20), Vector2(0, 28), Vector2(-8, 20)
	])

# -------------------------------------------------------------------------
# ECRU LINEN TROUSERS & SNEAKERS
# -------------------------------------------------------------------------

static func get_trousers_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-36, 115), Vector2(36, 115),
		Vector2(34, 175), Vector2(32, 245), Vector2(8, 245),
		Vector2(4, 165), Vector2(0, 155), Vector2(-4, 165),
		Vector2(-8, 245), Vector2(-32, 245), Vector2(-34, 175)
	])

static func get_sneaker_polygon(pos: Vector2, dir: float) -> PackedVector2Array:
	return PackedVector2Array([
		pos, pos + Vector2(28 * dir, 0), pos + Vector2(30 * dir, 18),
		pos + Vector2(-6 * dir, 18), pos + Vector2(-6 * dir, 6)
	])

static func get_sneaker_toe_cap(pos: Vector2, dir: float) -> PackedVector2Array:
	return PackedVector2Array([
		pos + Vector2(16 * dir, 0), pos + Vector2(28 * dir, 0),
		pos + Vector2(30 * dir, 18), pos + Vector2(14 * dir, 18),
		pos + Vector2(14 * dir, 8)
	])
