class_name NemiVectorGeometry
extends RefCounted

## Independent Native Vector Geometry for NEMI Carousel Character
## Zero external image generation, zero raster dependencies.
## Faithfully derives canonical proportions from references/main_character/nemi_sheet.png.

# Colors
const COLOR_PAPER := Color("#faf7f5")
const COLOR_INK := Color("#38101e")
const COLOR_HAIR := Color("#d64937")
const COLOR_HAIR_HIGHLIGHT := Color("#e86e58")
const COLOR_SKIN := Color("#fcf2e9")
const COLOR_SKIN_SHADOW := Color("#eed4c4")
const COLOR_EYE_IRIS := Color("#1fa363")
const COLOR_EYE_PUPIL := Color("#142b1f")
const COLOR_HOODIE := Color("#76987f")
const COLOR_HOODIE_SHADOW := Color("#5a7b63")
const COLOR_SKIRT := Color("#1d3d2c")
const COLOR_SKIRT_SHADOW := Color("#142b1f")
const COLOR_SNEAKER_SOLE := Color("#ede9e1")
const COLOR_BLUSH := Color("#f8b4a0")

# Head Base Polygon
static func get_head_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0))            # Chin
	c.add_point(Vector2(22, -10), Vector2(-6, 4), Vector2(7, -6))          # Lower jaw
	c.add_point(Vector2(44, -32), Vector2(-5, 12), Vector2(-1, -8))        # Cheek
	c.add_point(Vector2(40, -52), Vector2(2, 10), Vector2(-2, -10))        # Temple
	c.add_point(Vector2(26, -82), Vector2(8, 8), Vector2(-8, -6))          # Dome
	c.add_point(Vector2(0, -94), Vector2(14, 0), Vector2(-14, 0))          # Skull apex
	var right_pts := c.tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

# Jaw Outline
static func get_jaw_outline() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0))
	c.add_point(Vector2(22, -10), Vector2(-6, 4), Vector2(7, -6))
	c.add_point(Vector2(44, -32), Vector2(-5, 12), Vector2(-1, -8))
	c.add_point(Vector2(40, -50), Vector2(2, 10), Vector2(0, 0))
	var right_pts := c.tessellate(5, 1.5)
	
	var jaw := PackedVector2Array()
	for i in range(right_pts.size() - 1, 0, -1):
		jaw.append(Vector2(-right_pts[i].x, right_pts[i].y))
	for pt in right_pts:
		jaw.append(pt)
	return jaw

# Hair Back Volume Polygon
static func get_hair_back_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, -108), Vector2(-25, 0), Vector2(25, 0))          # Crown top
	c.add_point(Vector2(58, -80), Vector2(-15, -20), Vector2(10, 20))       # Right upper volume
	c.add_point(Vector2(64, -20), Vector2(5, -25), Vector2(-5, 25))        # Right shoulder flare
	c.add_point(Vector2(48, 30), Vector2(10, -15), Vector2(-10, 15))       # Right bottom tip
	c.add_point(Vector2(20, 20), Vector2(10, 5), Vector2(-10, -5))         # Right nape
	c.add_point(Vector2(0, 15), Vector2(10, 0), Vector2(-10, 0))           # Center nape
	var right_pts := c.tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

# Bangs & Front Locks
static func get_front_bangs_polygon() -> PackedVector2Array:
	var poly := PackedVector2Array([
		Vector2(-48, -75), Vector2(-42, -92), Vector2(0, -98), Vector2(42, -92), Vector2(48, -75),
		Vector2(46, -42), Vector2(38, -35), Vector2(32, -48),
		Vector2(24, -30), Vector2(16, -52), Vector2(8, -28), Vector2(0, -56),
		Vector2(-8, -30), Vector2(-16, -50), Vector2(-26, -32),
		Vector2(-34, -48), Vector2(-40, -36), Vector2(-48, -45)
	])
	return poly

# Ahoge Bounce Lock
static func get_ahoge_points() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(4, -102), Vector2(0, 0), Vector2(8, -18))
	c.add_point(Vector2(22, -126), Vector2(-12, 10), Vector2(15, -8))
	c.add_point(Vector2(38, -120), Vector2(-10, -10), Vector2(5, 15))
	c.add_point(Vector2(26, -108), Vector2(12, -4), Vector2(-6, 8))
	return c.tessellate(5, 1.5)

# Hooded Torso Polygon
static func get_hoodie_torso_polygon() -> PackedVector2Array:
	var poly := PackedVector2Array([
		Vector2(-32, 10), Vector2(-54, 30), Vector2(-48, 110), Vector2(-36, 135),
		Vector2(36, 135), Vector2(48, 110), Vector2(54, 30), Vector2(32, 10)
	])
	return poly

# Cowl Neck Collar
static func get_cowl_collar_polygon() -> PackedVector2Array:
	var poly := PackedVector2Array([
		Vector2(-32, -2), Vector2(32, -2), Vector2(38, 22), Vector2(18, 32),
		Vector2(0, 34), Vector2(-18, 32), Vector2(-38, 22)
	])
	return poly

# Skirt Polygon (knife pleated flared silhouette)
static func get_skirt_polygon() -> PackedVector2Array:
	var poly := PackedVector2Array([
		Vector2(-36, 135), Vector2(36, 135), Vector2(56, 195),
		Vector2(38, 198), Vector2(20, 196), Vector2(0, 199),
		Vector2(-20, 196), Vector2(-38, 198), Vector2(-56, 195)
	])
	return poly
