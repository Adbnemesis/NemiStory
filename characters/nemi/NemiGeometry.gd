class_name NemiGeometry
extends RefCounted

## Master Organic Vector Geometry Definitions for NEMI
## 100% Godot-native drawing geometry powered by Curve2D cubic Bézier splines
## and Geometry2D ribbon offset & boolean operations.
## Strictly adheres to NemiProportions.gd for character silhouette harmony.

const NemiProportions = preload("res://characters/nemi/NemiProportions.gd")

## Utility: Flips a 2D polygon across the Y axis while preserving vertex winding order
static func mirror_polygon(poly: PackedVector2Array) -> PackedVector2Array:
	var mirrored := PackedVector2Array()
	var n := poly.size()
	mirrored.resize(n)
	for i in range(n):
		var pt: Vector2 = poly[n - 1 - i]
		mirrored[i] = Vector2(-pt.x, pt.y)
	return mirrored

# -------------------------------------------------------------------------
# HEAD & JAW (Local origin (0, 0) is Chin)
# -------------------------------------------------------------------------

## Generates the soft, youthful curved anime head base (Chin at (0, 0), Top of skull at (0, -92))
## Mathematically symmetric across X = 0
static func get_head_base_polygon() -> PackedVector2Array:
	var right_c := Curve2D.new()
	right_c.add_point(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0))            # Chin apex
	right_c.add_point(Vector2(22, -10), Vector2(-6, 4), Vector2(7, -6))           # Lower jaw
	right_c.add_point(Vector2(43, -32), Vector2(-5, 12), Vector2(-1, -8))         # Soft anime cheek
	right_c.add_point(Vector2(40, -52), Vector2(2, 10), Vector2(-2, -10))         # Temple
	right_c.add_point(Vector2(26, -82), Vector2(8, 8), Vector2(-8, -6))           # Skull upper dome
	right_c.add_point(Vector2(0, -92), Vector2(14, 0), Vector2(-14, 0))           # Skull apex
	var right_pts := right_c.tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	# Chin to skull apex along right side
	for pt in right_pts:
		poly.append(pt)
	# Skull apex down to chin along left side (mirrored)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

## Prominent calligraphic jawline contour from temple to temple with soft tapered ends
## Perfectly matches head base polygon jawline
static func get_jaw_outline() -> PackedVector2Array:
	var right_c := Curve2D.new()
	right_c.add_point(Vector2(0, 0), Vector2(-10, 0), Vector2(10, 0))            # Chin
	right_c.add_point(Vector2(22, -10), Vector2(-6, 4), Vector2(7, -6))           # Lower jaw
	right_c.add_point(Vector2(43, -32), Vector2(-5, 12), Vector2(-1, -8))         # Cheek
	right_c.add_point(Vector2(40, -50), Vector2(2, 10), Vector2(0, 0))            # Temple
	var right_pts := right_c.tessellate(5, 1.5)
	
	var jaw := PackedVector2Array()
	# Left temple down to chin
	for i in range(right_pts.size() - 1, 0, -1):
		jaw.append(Vector2(-right_pts[i].x, right_pts[i].y))
	# Chin up to right temple
	for pt in right_pts:
		jaw.append(pt)
	return jaw

## Cute ear lobe polygon (tucked subtly behind side hair)
static func get_ear_polygon(is_left: bool = false) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(38, -48), Vector2(0, 0), Vector2(3, -2))
	c.add_point(Vector2(45, -40), Vector2(-2, -4), Vector2(2, 4))
	c.add_point(Vector2(43, -30), Vector2(2, -3), Vector2(-2, 3))
	c.add_point(Vector2(37, -26), Vector2(3, 2), Vector2(0, 0))
	var base := c.tessellate(4, 2.0)
	return mirror_polygon(base) if is_left else base

## Cute inner ear crease line
static func get_ear_crease(is_left: bool = false) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(40, -44), Vector2(0, 0), Vector2(1, -1))
	c.add_point(Vector2(42, -38), Vector2(-1, -2), Vector2(1, 2))
	c.add_point(Vector2(39, -32), Vector2(1, -1), Vector2(0, 0))
	var base := c.tessellate(4, 2.0)
	if is_left:
		var mir := PackedVector2Array()
		for pt in base:
			mir.append(Vector2(-pt.x, pt.y))
		return mir
	return base

# -------------------------------------------------------------------------
# NECK (Local origin (0, 0) is base of neck; chin is at (0, -18))
# -------------------------------------------------------------------------

static func get_neck_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-8, -20),
		Vector2(8, -20),
		Vector2(10, 4),
		Vector2(-10, 4)
	])

## Soft crescent cast shadow under chin
static func get_neck_shadow_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-8, -20), Vector2(0, 0), Vector2(5, 2))
	c.add_point(Vector2(8, -20), Vector2(-5, 2), Vector2(0, 0))
	c.add_point(Vector2(7, -10), Vector2(2, -3), Vector2(-3, 3))
	c.add_point(Vector2(0, -6), Vector2(4, 0), Vector2(-4, 0))
	c.add_point(Vector2(-7, -10), Vector2(3, 3), Vector2(-2, -3))
	return c.tessellate(4, 2.0)

# -------------------------------------------------------------------------
# HAIR MASSES (Local origin (0, 0) is Chin; skull apex is at (0, -92))
# -------------------------------------------------------------------------

## Back hair: Flowing wavy mane cascading behind shoulders and torso,
## width 108, cascading down to y = 138 with soft layered clumps.
static func get_hair_back_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-46, -48), Vector2(0, 0), Vector2(-4, 18))
	c.add_point(Vector2(-54, 0), Vector2(3, -24), Vector2(-2, 28))
	c.add_point(Vector2(-50, 65), Vector2(-1, -25), Vector2(2, 22))
	c.add_point(Vector2(-42, 105), Vector2(-2, -18), Vector2(1, 14))
	
	# Layered wavy bottom hem clumps
	c.add_point(Vector2(-35, 126), Vector2(-2, -8), Vector2(2, 0))
	c.add_point(Vector2(-26, 120), Vector2(-2, 2), Vector2(2, -2)) # Notch
	c.add_point(Vector2(-16, 135), Vector2(-2, -6), Vector2(2, 0))
	c.add_point(Vector2(-7, 126), Vector2(-2, 2), Vector2(2, -2))  # Notch
	c.add_point(Vector2(0, 130), Vector2(-3, 0), Vector2(3, 0))    # Center soft wave
	c.add_point(Vector2(7, 126), Vector2(-2, -2), Vector2(2, 2))   # Notch
	c.add_point(Vector2(16, 135), Vector2(-2, 0), Vector2(2, -6))
	c.add_point(Vector2(26, 120), Vector2(-2, -2), Vector2(2, 2))  # Notch
	c.add_point(Vector2(35, 126), Vector2(-2, 0), Vector2(2, -8))
	
	# Right silhouette going up
	c.add_point(Vector2(42, 105), Vector2(-1, 14), Vector2(2, -18))
	c.add_point(Vector2(50, 65), Vector2(-2, 22), Vector2(1, -25))
	c.add_point(Vector2(54, 0), Vector2(2, 28), Vector2(-3, -24))
	c.add_point(Vector2(46, -48), Vector2(4, 18), Vector2(0, 0))
	return c.tessellate(5, 1.5)

## Back hair left outer calligraphic silhouette path
static func get_hair_back_left_silhouette() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-46, -48), Vector2(0, 0), Vector2(-4, 18))
	c.add_point(Vector2(-54, 0), Vector2(3, -24), Vector2(-2, 28))
	c.add_point(Vector2(-50, 65), Vector2(-1, -25), Vector2(2, 22))
	c.add_point(Vector2(-42, 105), Vector2(-2, -18), Vector2(1, 14))
	c.add_point(Vector2(-35, 126), Vector2(-2, -8), Vector2(0, 0))
	return c.tessellate(5, 1.5)

## Back hair right outer calligraphic silhouette path
static func get_hair_back_right_silhouette() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(46, -48), Vector2(0, 0), Vector2(4, 18))
	c.add_point(Vector2(54, 0), Vector2(-3, -24), Vector2(2, 28))
	c.add_point(Vector2(50, 65), Vector2(1, -25), Vector2(-2, 22))
	c.add_point(Vector2(42, 105), Vector2(2, -18), Vector2(-1, 14))
	c.add_point(Vector2(35, 126), Vector2(2, -8), Vector2(0, 0))
	return c.tessellate(5, 1.5)

## Back hair bottom clumping hem path
static func get_hair_back_bottom_hem() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-35, 126), Vector2(0, 0), Vector2(2, 0))
	c.add_point(Vector2(-26, 120), Vector2(-2, 2), Vector2(2, -2))
	c.add_point(Vector2(-16, 135), Vector2(-2, -6), Vector2(2, 0))
	c.add_point(Vector2(-7, 126), Vector2(-2, 2), Vector2(2, -2))
	c.add_point(Vector2(0, 130), Vector2(-3, 0), Vector2(3, 0))
	c.add_point(Vector2(7, 126), Vector2(-2, -2), Vector2(2, 2))
	c.add_point(Vector2(16, 135), Vector2(-2, 0), Vector2(2, -6))
	c.add_point(Vector2(26, 120), Vector2(-2, -2), Vector2(2, 2))
	c.add_point(Vector2(35, 126), Vector2(-2, 0), Vector2(0, 0))
	return c.tessellate(4, 2.0)

## Internal flowing hair crease lines for back hair
static func get_hair_back_creases() -> Array[PackedVector2Array]:
	var f1 := Curve2D.new()
	f1.add_point(Vector2(32, -5), Vector2(0, 0), Vector2(-2, 25))
	f1.add_point(Vector2(20, 105), Vector2(1, -25), Vector2(0, 0))
	
	var f2 := Curve2D.new()
	f2.add_point(Vector2(-32, -5), Vector2(0, 0), Vector2(2, 25))
	f2.add_point(Vector2(-20, 105), Vector2(-1, -25), Vector2(0, 0))
	
	var f3 := Curve2D.new()
	f3.add_point(Vector2(0, 20), Vector2(0, 0), Vector2(0, 35))
	f3.add_point(Vector2(0, 115), Vector2(0, -20), Vector2(0, 0))
	
	return [f1.tessellate(4, 2.0), f2.tessellate(4, 2.0), f3.tessellate(4, 2.0)]

## Front Bangs & Crown Curve:
## Broad, fluffy, smooth anime crown dome (Width 96, Apex at -96)
static func get_hair_crown_curve() -> Curve2D:
	var c := Curve2D.new()
	c.add_point(Vector2(-48, -48), Vector2(0, 0), Vector2(0, -26))
	c.add_point(Vector2(0, -96), Vector2(-28, 0), Vector2(28, 0))
	c.add_point(Vector2(48, -48), Vector2(0, -26), Vector2(0, 0))
	return c

## Front Bangs Fringe Curve (soft, organic, layered anime locks framing eyes and cheeks)
static func get_hair_fringe_curve() -> Curve2D:
	var c := Curve2D.new()
	# Starts at right temple
	c.add_point(Vector2(48, -48), Vector2(0, 0), Vector2(-2, 8))
	# Right cheek framing lock (sweeps down along right cheek to soften jaw)
	c.add_point(Vector2(42, -32), Vector2(2, -6), Vector2(-2, 8))
	c.add_point(Vector2(37, -22), Vector2(2, -4), Vector2(-1, 0)) # Cheek lock tip
	c.add_point(Vector2(33, -36), Vector2(1, 4), Vector2(-1, -6))
	# Right outer eyebrow lock (sweeps down, gently framing brow)
	c.add_point(Vector2(25, -46), Vector2(2, -3), Vector2(-2, 3))
	c.add_point(Vector2(17, -54), Vector2(2, 2), Vector2(-2, 2))  # Notch
	# Center-right fringe lock
	c.add_point(Vector2(9, -47), Vector2(2, -3), Vector2(-2, 3))
	c.add_point(Vector2(1, -56), Vector2(2, 2), Vector2(-2, 2))   # Parting notch
	# Signature center sweeping lock (arched lock curving towards center/left)
	c.add_point(Vector2(-8, -46), Vector2(2, -3), Vector2(-2, 3))
	c.add_point(Vector2(-17, -54), Vector2(2, 2), Vector2(-2, 2)) # Notch
	# Left outer eyebrow fringe lock
	c.add_point(Vector2(-25, -46), Vector2(2, -3), Vector2(-2, 3))
	# Left cheek framing lock (sweeps down along left cheek)
	c.add_point(Vector2(-33, -36), Vector2(1, -6), Vector2(-1, 4))
	c.add_point(Vector2(-37, -22), Vector2(1, 0), Vector2(-2, -4)) # Cheek lock tip
	c.add_point(Vector2(-42, -32), Vector2(2, 8), Vector2(-2, -6))
	c.add_point(Vector2(-48, -48), Vector2(2, 8), Vector2(0, 0))
	return c

## Generates the unified bangs polygon by combining crown dome and fringe curves
static func get_hair_bangs_polygon() -> PackedVector2Array:
	var crown_pts := get_hair_crown_curve().tessellate(5, 1.5)
	var fringe_pts := get_hair_fringe_curve().tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	for pt in crown_pts:
		poly.append(pt)
	for i in range(1, fringe_pts.size() - 1):
		poly.append(fringe_pts[i])
	return poly

static func get_hair_crown_stroke() -> PackedVector2Array:
	return get_hair_crown_curve().tessellate(5, 1.5)

static func get_bangs_fringe_stroke() -> PackedVector2Array:
	return get_hair_fringe_curve().tessellate(5, 1.5)

## Bang strand interior separation creases (authored locks)
static func get_bangs_creases() -> Array[PackedVector2Array]:
	var c1 := Curve2D.new()
	c1.add_point(Vector2(-4, -68), Vector2(0, 0), Vector2(-2, 10))
	c1.add_point(Vector2(-9, -50), Vector2(1, -5), Vector2(0, 0))
	
	var c2 := Curve2D.new()
	c2.add_point(Vector2(3, -66), Vector2(0, 0), Vector2(2, 8))
	c2.add_point(Vector2(7, -49), Vector2(-1, -5), Vector2(0, 0))
	
	var c3 := Curve2D.new()
	c3.add_point(Vector2(19, -65), Vector2(0, 0), Vector2(2, 8))
	c3.add_point(Vector2(23, -48), Vector2(-1, -4), Vector2(0, 0))
	
	var c4 := Curve2D.new()
	c4.add_point(Vector2(-19, -65), Vector2(0, 0), Vector2(-2, 8))
	c4.add_point(Vector2(-23, -48), Vector2(1, -4), Vector2(0, 0))
	
	return [c1.tessellate(4, 2.0), c2.tessellate(4, 2.0), c3.tessellate(4, 2.0), c4.tessellate(4, 2.0)]

static func get_hair_stray_tufts() -> Array[PackedVector2Array]:
	return []

## Side tresses draping over shoulders with soft wavy ribbon flow
static func get_hair_tress_curve(is_left: bool) -> Array[Curve2D]:
	var outer_c := Curve2D.new()
	# Luscious wavy front tress draping forward over the shoulder
	outer_c.add_point(Vector2(44, -38), Vector2(0, 0), Vector2(2, 12))
	outer_c.add_point(Vector2(46, 5), Vector2(-2, -14), Vector2(0, 16))
	outer_c.add_point(Vector2(40, 42), Vector2(2, -12), Vector2(-2, 12))
	outer_c.add_point(Vector2(30, 68), Vector2(2, -8), Vector2(0, 0))
	
	var inner_c := Curve2D.new()
	inner_c.add_point(Vector2(34, -28), Vector2(0, 0), Vector2(1, 10))
	inner_c.add_point(Vector2(36, 12), Vector2(-1, -12), Vector2(1, 12))
	inner_c.add_point(Vector2(33, 44), Vector2(1, -10), Vector2(-1, 8))
	inner_c.add_point(Vector2(26, 64), Vector2(1, -5), Vector2(0, 0))
	
	if is_left:
		var m_outer := Curve2D.new()
		for i in range(outer_c.point_count):
			var pos := outer_c.get_point_position(i)
			var in_p := outer_c.get_point_in(i)
			var out_p := outer_c.get_point_out(i)
			m_outer.add_point(Vector2(-pos.x, pos.y), Vector2(-in_p.x, in_p.y), Vector2(-out_p.x, out_p.y))
		
		var m_inner := Curve2D.new()
		for i in range(inner_c.point_count):
			var pos := inner_c.get_point_position(i)
			var in_p := inner_c.get_point_in(i)
			var out_p := inner_c.get_point_out(i)
			m_inner.add_point(Vector2(-pos.x, pos.y), Vector2(-in_p.x, in_p.y), Vector2(-out_p.x, out_p.y))
		return [m_outer, m_inner]
	
	return [outer_c, inner_c]

static func get_hair_tress_polygon(is_left: bool) -> PackedVector2Array:
	var curves := get_hair_tress_curve(is_left)
	var outer_pts := curves[0].tessellate(5, 1.5)
	var inner_pts := curves[1].tessellate(5, 1.5)
	
	var poly := PackedVector2Array()
	for pt in outer_pts:
		poly.append(pt)
	for i in range(inner_pts.size() - 1, -1, -1):
		poly.append(inner_pts[i])
	return poly

static func get_hair_tress_outer_stroke(is_left: bool) -> PackedVector2Array:
	var curves := get_hair_tress_curve(is_left)
	return curves[0].tessellate(5, 1.5)

static func get_hair_tress_inner_stroke(is_left: bool) -> PackedVector2Array:
	var curves := get_hair_tress_curve(is_left)
	return curves[1].tessellate(5, 1.5)

## Iconic crown cowlick ahoge: Bouncy, tapered S-curve flicking right
static func get_ahoge_curve() -> Curve2D:
	var c := Curve2D.new()
	c.add_point(Vector2(-1, -96), Vector2(0, 0), Vector2(4, -10))
	c.add_point(Vector2(9, -112), Vector2(-4, 6), Vector2(5, -6))
	c.add_point(Vector2(20, -125), Vector2(-4, 4), Vector2(0, 0))
	return c

static func get_ahoge_polygon() -> PackedVector2Array:
	var spine := get_ahoge_curve().tessellate(5, 1.5)
	if spine.size() < 2:
		return PackedVector2Array()
	var n := spine.size()
	var left_side := PackedVector2Array()
	var right_side := PackedVector2Array()
	left_side.resize(n)
	right_side.resize(n)
	for i in range(n):
		var t := float(i) / float(n - 1)
		var w := lerpf(4.0, 0.4, t)
		var normal := Vector2.ZERO
		if i == 0:
			var tangent := (spine[1] - spine[0]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		elif i == n - 1:
			var tangent := (spine[i] - spine[i - 1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		else:
			var tangent := (spine[i + 1] - spine[i - 1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		left_side[i] = spine[i] + normal * (w * 0.5)
		right_side[i] = spine[i] - normal * (w * 0.5)
	
	var poly := PackedVector2Array()
	for pt in left_side:
		poly.append(pt)
	for i in range(n - 1, -1, -1):
		poly.append(right_side[i])
	return poly

static func get_ahoge_spine() -> PackedVector2Array:
	return get_ahoge_curve().tessellate(5, 1.5)

# -------------------------------------------------------------------------
# HOODIE & TORSO (Local origin (0, 0) is Hip/Pelvis)
# -------------------------------------------------------------------------

## Oversized sage green hoodie body with relaxed slouch drape
static func get_hoodie_torso_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-46, -66), Vector2(0, 0), Vector2(8, -4))         # Left dropped shoulder
	c.add_point(Vector2(-15, -74), Vector2(-5, 0), Vector2(5, 0))         # Neck left
	c.add_point(Vector2(0, -70), Vector2(-4, -2), Vector2(4, -2))          # Neck center dip
	c.add_point(Vector2(15, -74), Vector2(-5, 0), Vector2(5, 0))          # Neck right
	c.add_point(Vector2(46, -66), Vector2(-8, -4), Vector2(0, 0))         # Right dropped shoulder
	c.add_point(Vector2(41, -34), Vector2(2, -12), Vector2(-2, 12))       # Right torso curve
	c.add_point(Vector2(37, 0), Vector2(1, -10), Vector2(-1, 0))          # Right waist hem
	c.add_point(Vector2(0, 3), Vector2(12, 0), Vector2(-12, 0))           # Center bottom hem curve
	c.add_point(Vector2(-37, 0), Vector2(1, 0), Vector2(-1, -10))         # Left waist hem
	c.add_point(Vector2(-41, -34), Vector2(-2, 12), Vector2(2, -12))      # Left torso curve
	return c.tessellate(5, 1.5)

static func get_hoodie_left_contour() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-46, -66), Vector2(0, 0), Vector2(2, 14))
	c.add_point(Vector2(-41, -34), Vector2(-2, -12), Vector2(1, 12))
	c.add_point(Vector2(-37, 0), Vector2(-1, -10), Vector2(0, 0))
	return c.tessellate(5, 1.5)

static func get_hoodie_right_contour() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(46, -66), Vector2(0, 0), Vector2(-2, 14))
	c.add_point(Vector2(41, -34), Vector2(2, -12), Vector2(-1, 12))
	c.add_point(Vector2(37, 0), Vector2(1, -10), Vector2(0, 0))
	return c.tessellate(5, 1.5)

## Cozy rounded cowl hood collar encircling the neck (covers base of neck)
static func get_hoodie_collar_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-24, -80), Vector2(0, 0), Vector2(8, -3))
	c.add_point(Vector2(0, -83), Vector2(-8, 0), Vector2(8, 0))
	c.add_point(Vector2(24, -80), Vector2(-8, -3), Vector2(0, 0))
	c.add_point(Vector2(20, -64), Vector2(3, -4), Vector2(-3, 4))
	c.add_point(Vector2(0, -60), Vector2(6, -1), Vector2(-6, -1))          # Front collar dip
	c.add_point(Vector2(-20, -64), Vector2(3, 4), Vector2(-3, -4))
	return c.tessellate(5, 1.5)

static func get_hoodie_collar_outer_stroke() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-24, -80), Vector2(0, 0), Vector2(8, -3))
	c.add_point(Vector2(0, -83), Vector2(-8, 0), Vector2(8, 0))
	c.add_point(Vector2(24, -80), Vector2(-8, -3), Vector2(0, 0))
	return c.tessellate(4, 2.0)

static func get_hoodie_collar_front_stroke() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-22, -70), Vector2(0, 0), Vector2(3, 4))
	c.add_point(Vector2(-20, -64), Vector2(-2, -3), Vector2(4, 3))
	c.add_point(Vector2(0, -60), Vector2(-6, -1), Vector2(6, -1))
	c.add_point(Vector2(20, -64), Vector2(-4, 3), Vector2(2, -3))
	c.add_point(Vector2(22, -70), Vector2(-3, 4), Vector2(0, 0))
	return c.tessellate(4, 2.0)

static func get_hoodie_pouch_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-22, -26), Vector2(0, 0), Vector2(8, 0))
	c.add_point(Vector2(22, -26), Vector2(-8, 0), Vector2(3, 4))
	c.add_point(Vector2(28, -3), Vector2(0, -5), Vector2(-8, 2))
	c.add_point(Vector2(-28, -3), Vector2(8, 2), Vector2(0, -5))
	return c.tessellate(4, 2.0)

static func get_hoodie_pouch_welts() -> Array[PackedVector2Array]:
	var w_left := Curve2D.new()
	w_left.add_point(Vector2(-22, -26), Vector2(0, 0), Vector2(-3, 7))
	w_left.add_point(Vector2(-28, -3), Vector2(2, -7), Vector2(0, 0))
	
	var w_right := Curve2D.new()
	w_right.add_point(Vector2(22, -26), Vector2(0, 0), Vector2(3, 7))
	w_right.add_point(Vector2(28, -3), Vector2(-2, -7), Vector2(0, 0))
	
	var w_top := Curve2D.new()
	w_top.add_point(Vector2(-22, -26), Vector2(0, 0), Vector2(8, 0))
	w_top.add_point(Vector2(22, -26), Vector2(-8, 0), Vector2(0, 0))
	
	return [w_left.tessellate(4, 2.0), w_right.tessellate(4, 2.0), w_top.tessellate(4, 2.0)]

static func get_hoodie_hem_line() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-37, 0), Vector2(0, 0), Vector2(10, 2))
	c.add_point(Vector2(0, 3), Vector2(-10, 0), Vector2(10, 0))
	c.add_point(Vector2(37, 0), Vector2(-10, 2), Vector2(0, 0))
	return c.tessellate(4, 2.0)

static func get_drawstrings() -> Array[PackedVector2Array]:
	var s1 := Curve2D.new()
	s1.add_point(Vector2(-7, -62), Vector2(0, 0), Vector2(0, 6))
	s1.add_point(Vector2(-6, -50), Vector2(0, -5), Vector2(-1, 5))
	s1.add_point(Vector2(-8, -36), Vector2(1, -4), Vector2(0, 0))
	
	var s2 := Curve2D.new()
	s2.add_point(Vector2(7, -62), Vector2(0, 0), Vector2(0, 6))
	s2.add_point(Vector2(6, -50), Vector2(0, -5), Vector2(1, 5))
	s2.add_point(Vector2(8, -36), Vector2(-1, -4), Vector2(0, 0))
	
	return [s1.tessellate(4, 2.0), s2.tessellate(4, 2.0)]

# -------------------------------------------------------------------------
# PLEATED SKIRT (Local origin (0, 0) is Waistband)
# -------------------------------------------------------------------------

static func get_skirt_bottom_hem() -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x_bots := [-34.0, -24.0, -14.0, -4.0, 5.0, 15.0, 25.0, 35.0]
	pts.append(Vector2(-43.0, 52.0))
	for i in range(x_bots.size()):
		var xb: float = x_bots[i]
		var y_base: float = 55.0 - 3.0 * ((xb / 43.0) * (xb / 43.0))
		# Outer pleat tip
		pts.append(Vector2(xb, y_base + 1.2))
		# Step up into fold
		pts.append(Vector2(xb + 0.6, y_base - 1.0))
	pts.append(Vector2(43.0, 52.0))
	return pts

static func get_skirt_polygon() -> PackedVector2Array:
	var pts := PackedVector2Array()
	# Top waistband (left to right)
	var top_c := Curve2D.new()
	top_c.add_point(Vector2(-31, 0), Vector2(0, 0), Vector2(10, 2))
	top_c.add_point(Vector2(0, 2.5), Vector2(-10, 0), Vector2(10, 0))
	top_c.add_point(Vector2(31, 0), Vector2(-10, 2), Vector2(0, 0))
	var top_pts := top_c.tessellate(4, 2.0)
	for p in top_pts:
		pts.append(p)
	
	# Right hip contour down to hem
	var right_c := Curve2D.new()
	right_c.add_point(Vector2(31, 0), Vector2(0, 0), Vector2(3, 18))
	right_c.add_point(Vector2(43, 52), Vector2(2, -12), Vector2(0, 0))
	var right_pts := right_c.tessellate(4, 2.0)
	for i in range(1, right_pts.size()):
		pts.append(right_pts[i])
	
	# Bottom stepped hem (traversed right to left)
	var hem := get_skirt_bottom_hem()
	for i in range(hem.size() - 2, -1, -1):
		pts.append(hem[i])
	
	# Left hip contour up to waistband
	var left_c := Curve2D.new()
	left_c.add_point(Vector2(-43, 52), Vector2(0, 0), Vector2(-2, -12))
	left_c.add_point(Vector2(-31, 0), Vector2(-3, 18), Vector2(0, 0))
	var left_pts := left_c.tessellate(4, 2.0)
	for i in range(1, left_pts.size() - 1):
		pts.append(left_pts[i])
	
	return pts

static func get_skirt_left_contour() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-31, 0), Vector2(0, 0), Vector2(-3, 18))
	c.add_point(Vector2(-43, 52), Vector2(-2, -12), Vector2(0, 0))
	return c.tessellate(4, 2.0)

static func get_skirt_right_contour() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(31, 0), Vector2(0, 0), Vector2(3, 18))
	c.add_point(Vector2(43, 52), Vector2(2, -12), Vector2(0, 0))
	return c.tessellate(4, 2.0)

## Radiating knife pleat crease lines
static func get_skirt_pleat_lines() -> Array[PackedVector2Array]:
	var lines: Array[PackedVector2Array] = []
	var x_tops := [-24.0, -17.0, -10.0, -3.0, 4.0, 11.0, 18.0, 25.0]
	var x_bots := [-34.0, -24.0, -14.0, -4.0, 5.0, 15.0, 25.0, 35.0]
	for i in range(x_tops.size()):
		var xb: float = x_bots[i]
		var y_base: float = 55.0 - 3.0 * ((xb / 43.0) * (xb / 43.0))
		var c := Curve2D.new()
		c.add_point(Vector2(x_tops[i], 2.0), Vector2(0, 0), Vector2((xb - x_tops[i]) * 0.3, 16.0))
		c.add_point(Vector2(xb, y_base + 1.2), Vector2((x_tops[i] - xb) * 0.3, -16.0), Vector2(0, 0))
		lines.append(c.tessellate(4, 2.0))
	return lines

## Alternating knife pleat shadow facets for authentic depth
static func get_skirt_shadow_facets() -> Array[PackedVector2Array]:
	var facets: Array[PackedVector2Array] = []
	var x_tops := [-24.0, -10.0, 4.0, 18.0]
	var x_bots := [-34.0, -14.0, 5.0, 25.0]
	var facet_w_top := 3.5
	var facet_w_bot := 5.0
	for i in range(x_tops.size()):
		var xb: float = x_bots[i]
		var y_base: float = 55.0 - 3.0 * ((xb / 43.0) * (xb / 43.0))
		var poly := PackedVector2Array([
			Vector2(x_tops[i], 2.0),
			Vector2(x_tops[i] + facet_w_top, 2.0),
			Vector2(xb + facet_w_bot, y_base),
			Vector2(xb + 0.6, y_base - 1.0),
			Vector2(xb, y_base + 1.2)
		])
		facets.append(poly)
	return facets

# -------------------------------------------------------------------------
# LIMBS, SOCKS & SNEAKERS
# -------------------------------------------------------------------------

## Upper arm sleeve with soft rounded shoulder cap and fabric drape
static func get_upper_arm_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-12, 0), Vector2(0, 0), Vector2(4, -5))
	c.add_point(Vector2(0, -7), Vector2(-5, 0), Vector2(5, 0))
	c.add_point(Vector2(12, 0), Vector2(-4, -5), Vector2(-1, 14))
	c.add_point(Vector2(11, 62), Vector2(1, -10), Vector2(-4, 2))
	c.add_point(Vector2(-11, 62), Vector2(4, 2), Vector2(0, 0))
	var base := c.tessellate(4, 2.0)
	return mirror_polygon(base) if is_left else base

static func get_upper_arm_contours(is_left: bool = true) -> Array[PackedVector2Array]:
	var sign_x := -1.0 if is_left else 1.0
	var outer_c := Curve2D.new()
	outer_c.add_point(Vector2(sign_x * -12, 0), Vector2(0, 0), Vector2(sign_x * -1, 18))
	outer_c.add_point(Vector2(sign_x * -11, 62), Vector2(sign_x * 0, -14), Vector2(0, 0))
	
	var inner_c := Curve2D.new()
	inner_c.add_point(Vector2(sign_x * 12, 0), Vector2(0, 0), Vector2(sign_x * -1, 18))
	inner_c.add_point(Vector2(sign_x * 11, 62), Vector2(sign_x * 0, -14), Vector2(0, 0))
	
	return [outer_c.tessellate(4, 2.0), inner_c.tessellate(4, 2.0)]

## Lower arm sleeve with gathered ribbed cuff
static func get_lower_arm_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-11, 0), Vector2(0, 0), Vector2(3, -4))
	c.add_point(Vector2(0, -5), Vector2(-4, 0), Vector2(4, 0))
	c.add_point(Vector2(11, 0), Vector2(-3, -4), Vector2(-1, 10))
	c.add_point(Vector2(9, 52), Vector2(1, -8), Vector2(-2, 0))
	c.add_point(Vector2(8, 58), Vector2(0, -2), Vector2(-3, 0))
	c.add_point(Vector2(-8, 58), Vector2(3, 0), Vector2(0, -2))
	c.add_point(Vector2(-9, 52), Vector2(-2, 0), Vector2(1, -8))
	var base := c.tessellate(4, 2.0)
	return mirror_polygon(base) if is_left else base

static func get_lower_arm_contours(is_left: bool = true) -> Array[PackedVector2Array]:
	var sign_x := -1.0 if is_left else 1.0
	var outer_c := Curve2D.new()
	outer_c.add_point(Vector2(sign_x * -11, 0), Vector2(0, 0), Vector2(sign_x * 1, 16))
	outer_c.add_point(Vector2(sign_x * -9, 52), Vector2(sign_x * 0, -10), Vector2(0, 0))
	
	var inner_c := Curve2D.new()
	inner_c.add_point(Vector2(sign_x * 11, 0), Vector2(0, 0), Vector2(sign_x * -1, 16))
	inner_c.add_point(Vector2(sign_x * 9, 52), Vector2(sign_x * 0, -10), Vector2(0, 0))
	
	return [outer_c.tessellate(4, 2.0), inner_c.tessellate(4, 2.0)]

## Illustrated expressive hand polygons
static func get_hand_polygon(hand_pose: int, is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	match hand_pose:
		1: # POINTING (Clear graceful index finger pointing forward, thumb curved)
			c.add_point(Vector2(-5, 0), Vector2(0, 0), Vector2(-2, 3))
			c.add_point(Vector2(-8, 7), Vector2(1, -2), Vector2(1, 2))  # Thumb knuckle
			c.add_point(Vector2(-5, 11), Vector2(-1, -1), Vector2(2, 0)) # Thumb tip
			c.add_point(Vector2(-2, 11), Vector2(-2, 0), Vector2(0, 3))  # Index base
			c.add_point(Vector2(2, 22), Vector2(-1, -3), Vector2(1, 0))  # Index fingertip
			c.add_point(Vector2(5, 20), Vector2(0, 2), Vector2(0, -3))
			c.add_point(Vector2(5, 10), Vector2(0, 2), Vector2(0, -2))   # Curled knuckles
			c.add_point(Vector2(4, 0), Vector2(1, 2), Vector2(0, 0))     # Outer wrist
		2: # FIST (Cute rounded clenched knuckles)
			c.add_point(Vector2(-4, 0), Vector2(0, 0), Vector2(-2, 3))
			c.add_point(Vector2(-7, 7), Vector2(1, -2), Vector2(1, 2))
			c.add_point(Vector2(-3, 14), Vector2(-2, -2), Vector2(2, 1))
			c.add_point(Vector2(3, 14), Vector2(-2, 1), Vector2(2, -2))
			c.add_point(Vector2(6, 8), Vector2(1, 2), Vector2(-1, -2))
			c.add_point(Vector2(4, 0), Vector2(1, 3), Vector2(0, 0))
		3: # OPEN (Conversational open palm gesture with fanned fingers)
			c.add_point(Vector2(-5, 0), Vector2(0, 0), Vector2(-2, 2))
			c.add_point(Vector2(-9, 6), Vector2(1, -2), Vector2(1, 2))   # Thumb knuckle
			c.add_point(Vector2(-8, 12), Vector2(-1, -1), Vector2(2, 2)) # Thumb tip
			c.add_point(Vector2(-3, 20), Vector2(-2, -2), Vector2(1, 1)) # Index tip
			c.add_point(Vector2(1, 21), Vector2(-1, 0), Vector2(1, -1))  # Middle tip
			c.add_point(Vector2(5, 18), Vector2(-1, 1), Vector2(1, -1))  # Ring tip
			c.add_point(Vector2(8, 14), Vector2(0, 2), Vector2(0, -2))   # Pinky tip
			c.add_point(Vector2(5, 0), Vector2(1, 3), Vector2(0, 0))     # Outer wrist
		_: # RELAXED (Gentle natural fingers with soft grouping)
			c.add_point(Vector2(-4, 0), Vector2(0, 0), Vector2(-2, 2))
			c.add_point(Vector2(-8, 6), Vector2(1, -2), Vector2(1, 2))  # Thumb knuckle
			c.add_point(Vector2(-6, 11), Vector2(-1, -1), Vector2(2, 1)) # Thumb tip
			c.add_point(Vector2(-2, 18), Vector2(-2, -2), Vector2(1, 1)) # Index tip
			c.add_point(Vector2(2, 19), Vector2(-1, 0), Vector2(1, -1))  # Middle tip
			c.add_point(Vector2(5, 15), Vector2(0, 2), Vector2(0, -2))   # Ring/pinky
			c.add_point(Vector2(4, 0), Vector2(1, 3), Vector2(0, 0))
	var base := c.tessellate(4, 1.8)
	return mirror_polygon(base) if is_left else base

## Thigh with rounded hip cap and slender anime taper (Length 82)
static func get_thigh_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-9, 0), Vector2(0, 0), Vector2(3, -5))
	c.add_point(Vector2(0, -5), Vector2(-5, 0), Vector2(5, 0))
	c.add_point(Vector2(9, 0), Vector2(-3, -5), Vector2(0, 18))
	c.add_point(Vector2(7.5, 82), Vector2(0, -12), Vector2(-4, 0))
	c.add_point(Vector2(-7.5, 82), Vector2(4, 0), Vector2(0, -12))
	var base := c.tessellate(4, 2.0)
	return mirror_polygon(base) if is_left else base

static func get_thigh_contours(is_left: bool = true) -> Array[PackedVector2Array]:
	var sign_x := -1.0 if is_left else 1.0
	var outer_c := Curve2D.new()
	outer_c.add_point(Vector2(sign_x * -9, 2), Vector2(0, 0), Vector2(sign_x * -1, 25))
	outer_c.add_point(Vector2(sign_x * -7.5, 82), Vector2(sign_x * 0, -20), Vector2(0, 0))
	
	var inner_c := Curve2D.new()
	inner_c.add_point(Vector2(sign_x * 9, 2), Vector2(0, 0), Vector2(sign_x * 0, 25))
	inner_c.add_point(Vector2(sign_x * 7.5, 82), Vector2(sign_x * 0, -20), Vector2(0, 0))
	
	return [outer_c.tessellate(4, 2.0), inner_c.tessellate(4, 2.0)]

## Shin with cute rounded knee and slender ankle (Length 86)
static func get_shin_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-7.5, 0), Vector2(0, 0), Vector2(2, -4))
	c.add_point(Vector2(0, -4), Vector2(-4, 0), Vector2(4, 0))
	c.add_point(Vector2(7.5, 0), Vector2(-2, -4), Vector2(0, 20))
	c.add_point(Vector2(6.5, 86), Vector2(0, -12), Vector2(-3, 0))
	c.add_point(Vector2(-6.5, 86), Vector2(3, 0), Vector2(0, -12))
	var base := c.tessellate(4, 2.0)
	return mirror_polygon(base) if is_left else base

static func get_shin_contours(is_left: bool = true) -> Array[PackedVector2Array]:
	var sign_x := -1.0 if is_left else 1.0
	var outer_c := Curve2D.new()
	outer_c.add_point(Vector2(sign_x * -7.5, 0), Vector2(0, 0), Vector2(sign_x * -1, 25))
	outer_c.add_point(Vector2(sign_x * -6.5, 86), Vector2(sign_x * 0, -20), Vector2(0, 0))
	
	var inner_c := Curve2D.new()
	inner_c.add_point(Vector2(sign_x * 7.5, 0), Vector2(0, 0), Vector2(sign_x * 0, 25))
	inner_c.add_point(Vector2(sign_x * 6.5, 86), Vector2(sign_x * 0, -20), Vector2(0, 0))
	
	return [outer_c.tessellate(4, 2.0), inner_c.tessellate(4, 2.0)]

## White sport crew sock (clean white)
static func get_sock_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-7.5, 54), Vector2(7.5, 54),
		Vector2(7.0, 86), Vector2(-7.0, 86)
	])

## Chunky white dad sneaker with thick curved sole and green accent
static func get_sneaker_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-9, 0), Vector2(0, 0), Vector2(5, 0))
	c.add_point(Vector2(9, 0), Vector2(-5, 0), Vector2(2, 5))
	c.add_point(Vector2(14, 10), Vector2(-2, -3), Vector2(3, 4))
	c.add_point(Vector2(19, 18), Vector2(-2, -2), Vector2(-4, 1))        # Sculpted toe lift
	c.add_point(Vector2(9, 19), Vector2(4, 0), Vector2(-8, 0))
	c.add_point(Vector2(-11, 19), Vector2(8, 0), Vector2(-3, -3))
	c.add_point(Vector2(-14, 10), Vector2(1, 4), Vector2(0, -5))        # Heel counter
	var base := c.tessellate(4, 1.8)
	return mirror_polygon(base) if is_left else base

static func get_sneaker_sole_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-14, 19), Vector2(0, 0), Vector2(11, 0))
	c.add_point(Vector2(19, 18), Vector2(-11, 0), Vector2(1, 3))
	c.add_point(Vector2(20, 26), Vector2(0, -2), Vector2(-11, 0))        # Thick chunky sole platform
	c.add_point(Vector2(0, 25.5), Vector2(5, 0), Vector2(-5, 0))         # Midfoot arch groove
	c.add_point(Vector2(-15, 26), Vector2(11, 0), Vector2(0, -2))        # Chunky heel
	var base := c.tessellate(4, 1.8)
	return mirror_polygon(base) if is_left else base

static func get_sneaker_trim_polygon(is_left: bool = true) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-5, 8))
	c.add_point(Vector2(13, 9))
	c.add_point(Vector2(11, 15))
	c.add_point(Vector2(-6, 13))
	var base := c.tessellate(3, 2.5)
	return mirror_polygon(base) if is_left else base

# -------------------------------------------------------------------------
# CROSSBODY BAG (Torso local coordinates)
# -------------------------------------------------------------------------

static func get_bag_strap_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-46, -66), Vector2(-40, -68),
		Vector2(36, 8), Vector2(30, 10)
	])

static func get_bag_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(18, -4))
	c.add_point(Vector2(48, -4))
	c.add_point(Vector2(47, 20))
	c.add_point(Vector2(19, 20))
	return c.tessellate(3, 2.5)

static func get_bag_flap_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(18, -4))
	c.add_point(Vector2(48, -4))
	c.add_point(Vector2(48, 6))
	c.add_point(Vector2(33, 13))
	c.add_point(Vector2(18, 6))
	return c.tessellate(3, 2.5)

static func get_bag_leaf_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(31, 6), Vector2(33, 2), Vector2(35, 6), Vector2(33, 10)
	])
