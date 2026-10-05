class_name ADBGeometry
extends RefCounted

## Master Organic Vector Geometry Definitions for ADB
## 100% Godot 4-native drawing geometry powered by Curve2D cubic Bézier splines
## and CommonInkStroke ribbon offset contours.
## Faithfully reproduces the cool, relaxed aesthetic of ADB Model Sheet.

const ADBStyle = preload("res://adb/characters/adb/ADBStyle.gd")
const CommonInkStroke = preload("res://common/engine/drawing/CommonInkStroke.gd")

# -------------------------------------------------------------------------
# HEAD & JAW (Local origin (0, 0) is Chin apex)
# -------------------------------------------------------------------------

static func get_head_base_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(-12, 0), Vector2(12, 0))            # Chin apex
	c.add_point(Vector2(26, -14), Vector2(-8, 5), Vector2(8, -6))          # Jawline
	c.add_point(Vector2(46, -42), Vector2(-6, 12), Vector2(-1, -10))       # Cheek
	c.add_point(Vector2(44, -68), Vector2(3, 12), Vector2(-2, -12))        # Temple
	c.add_point(Vector2(28, -102), Vector2(8, 10), Vector2(-8, -8))        # Skull upper dome
	c.add_point(Vector2(0, -114), Vector2(16, 0), Vector2(-16, 0))         # Skull apex
	var right_pts := c.tessellate(5, 1.5)

	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

static func get_jaw_outline() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(-12, 0), Vector2(12, 0))            # Chin apex
	c.add_point(Vector2(26, -14), Vector2(-8, 5), Vector2(8, -6))          # Jawline
	c.add_point(Vector2(46, -42), Vector2(-6, 12), Vector2(-1, -10))       # Cheek
	c.add_point(Vector2(44, -66), Vector2(3, 12), Vector2(0, 0))           # Temple
	var right_pts := c.tessellate(5, 1.5)

	var jaw := PackedVector2Array()
	for i in range(right_pts.size() - 1, 0, -1):
		jaw.append(Vector2(-right_pts[i].x, right_pts[i].y))
	for pt in right_pts:
		jaw.append(pt)
	return jaw

static func get_ear_polygon(is_left: bool = false) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(42, -62), Vector2(0, 0), Vector2(4, -3))
	c.add_point(Vector2(53, -52), Vector2(-2, -5), Vector2(2, 6))
	c.add_point(Vector2(49, -36), Vector2(3, -4), Vector2(-3, 4))
	c.add_point(Vector2(42, -30), Vector2(4, 2), Vector2(0, 0))
	var base := c.tessellate(4, 2.0)
	if is_left:
		var mir := PackedVector2Array()
		for pt in base:
			mir.append(Vector2(-pt.x, pt.y))
		return mir
	return base

static func get_ear_crease(is_left: bool = false) -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(45, -56), Vector2(0, 0), Vector2(2, -1))
	c.add_point(Vector2(47, -46), Vector2(-1, -3), Vector2(1, 3))
	c.add_point(Vector2(44, -38), Vector2(1, -2), Vector2(0, 0))
	var base := c.tessellate(4, 2.0)
	if is_left:
		var mir := PackedVector2Array()
		for pt in base:
			mir.append(Vector2(-pt.x, pt.y))
		return mir
	return base

# -------------------------------------------------------------------------
# HAIR: SIGNATURE TOUSLED CURTAIN BANGS & CROWN VOLUME
# -------------------------------------------------------------------------

static func get_hair_crown_curve() -> Curve2D:
	var c := Curve2D.new()
	c.add_point(Vector2(-52, -42), Vector2(0, 0), Vector2(-4, -18))
	c.add_point(Vector2(-56, -72), Vector2(2, 14), Vector2(-3, -16))
	c.add_point(Vector2(-42, -108), Vector2(-8, 14), Vector2(12, -12))
	c.add_point(Vector2(-12, -128), Vector2(-16, 2), Vector2(10, -2))
	c.add_point(Vector2(8, -126), Vector2(-8, -2), Vector2(16, 4))
	c.add_point(Vector2(42, -108), Vector2(-12, -12), Vector2(8, 14))
	c.add_point(Vector2(56, -72), Vector2(3, -16), Vector2(-2, 14))
	c.add_point(Vector2(52, -42), Vector2(4, -18), Vector2(0, 0))
	return c

static func get_curtain_fringe_curve() -> Curve2D:
	var c := Curve2D.new()
	c.add_point(Vector2(52, -42), Vector2(0, 0), Vector2(-4, 10))
	c.add_point(Vector2(44, -28), Vector2(3, -6), Vector2(-3, 6))  # Right cheek flick tip
	c.add_point(Vector2(36, -44), Vector2(2, 6), Vector2(-2, -8))
	c.add_point(Vector2(26, -58), Vector2(3, 8), Vector2(-4, -6))
	c.add_point(Vector2(14, -72), Vector2(4, 6), Vector2(-3, -8))
	c.add_point(Vector2(4, -88), Vector2(3, 8), Vector2(-1, 0))    # Right part apex
	c.add_point(Vector2(0, -82), Vector2(2, -4), Vector2(-2, -4))  # Forehead opening
	c.add_point(Vector2(-4, -88), Vector2(1, 0), Vector2(-3, 8))   # Left part apex
	c.add_point(Vector2(-14, -72), Vector2(3, -8), Vector2(-4, 6))
	c.add_point(Vector2(-26, -58), Vector2(4, -6), Vector2(-3, 8))
	c.add_point(Vector2(-36, -44), Vector2(2, -8), Vector2(-2, 6))
	c.add_point(Vector2(-44, -28), Vector2(3, 6), Vector2(-3, -6)) # Left cheek flick tip
	c.add_point(Vector2(-52, -42), Vector2(4, 10), Vector2(0, 0))
	return c

static func get_curtain_bangs_polygon() -> PackedVector2Array:
	var crown_pts := get_hair_crown_curve().tessellate(5, 1.5)
	var fringe_pts := get_curtain_fringe_curve().tessellate(5, 1.5)

	var poly := PackedVector2Array()
	for pt in crown_pts:
		poly.append(pt)
	for i in range(1, fringe_pts.size() - 1):
		poly.append(fringe_pts[i])
	return poly

static func get_hair_flicks() -> Array[PackedVector2Array]:
	var flicks: Array[PackedVector2Array] = []
	var f1 := Curve2D.new()
	f1.add_point(Vector2(-24, -122), Vector2(0, 0), Vector2(-6, -10))
	f1.add_point(Vector2(-36, -136), Vector2(4, 6), Vector2(6, 2))
	f1.add_point(Vector2(-20, -126), Vector2(-4, -4), Vector2(0, 0))
	flicks.append(f1.tessellate(4, 1.5))

	var f2 := Curve2D.new()
	f2.add_point(Vector2(16, -124), Vector2(0, 0), Vector2(8, -10))
	f2.add_point(Vector2(32, -138), Vector2(-4, 6), Vector2(-6, 2))
	f2.add_point(Vector2(12, -126), Vector2(4, -4), Vector2(0, 0))
	flicks.append(f2.tessellate(4, 1.5))

	var f3 := Curve2D.new()
	f3.add_point(Vector2(50, -82), Vector2(0, 0), Vector2(8, -4))
	f3.add_point(Vector2(62, -92), Vector2(-4, 4), Vector2(-4, 6))
	f3.add_point(Vector2(54, -68), Vector2(3, -4), Vector2(0, 0))
	flicks.append(f3.tessellate(4, 1.5))
	return flicks

static func get_curtain_creases() -> Array[PackedVector2Array]:
	var creases: Array[PackedVector2Array] = []
	var c1 := Curve2D.new()
	c1.add_point(Vector2(-3, -88), Vector2(0, 0), Vector2(-8, 14))
	c1.add_point(Vector2(-22, -54), Vector2(4, -10), Vector2(-3, 10))
	c1.add_point(Vector2(-32, -32), Vector2(2, -6), Vector2(0, 0))
	creases.append(c1.tessellate(4, 1.5))

	var c2 := Curve2D.new()
	c2.add_point(Vector2(3, -88), Vector2(0, 0), Vector2(8, 14))
	c2.add_point(Vector2(22, -54), Vector2(-4, -10), Vector2(3, 10))
	c2.add_point(Vector2(32, -32), Vector2(-2, -6), Vector2(0, 0))
	creases.append(c2.tessellate(4, 1.5))
	return creases

static func get_hair_back_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, -128), Vector2(-24, 0), Vector2(24, 0))
	c.add_point(Vector2(46, -118), Vector2(-12, -6), Vector2(12, 6))
	c.add_point(Vector2(64, -86), Vector2(-6, -14), Vector2(8, 16))
	c.add_point(Vector2(60, -46), Vector2(4, -12), Vector2(-4, 14))
	c.add_point(Vector2(46, -14), Vector2(6, -8), Vector2(-8, 6))
	c.add_point(Vector2(24, 6), Vector2(8, -4), Vector2(-8, 2))
	c.add_point(Vector2(0, 10), Vector2(12, 0), Vector2(-12, 0))
	var right_pts := c.tessellate(5, 1.5)

	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

# -------------------------------------------------------------------------
# TORSO & SHIRT: RELAXED SAGE GREEN BUTTON-DOWN SHIRT
# Oversized across upper chest & drop-shoulders (width 102-108),
# but fitted/touching the body below chest through waist (width 80) and hips (width 80)
# (Curved hem at Y = 7..10, drop-shoulders at Y = -76, collar base at Y = -84, back collar dip at Y = -82)
# -------------------------------------------------------------------------

static func get_sweater_body_polygon() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(0, 25), Vector2(-15, 0), Vector2(15, 0))                # Clean longer curved hem center (Y = 25)
	c.add_point(Vector2(38.5, 21), Vector2(-8, 1), Vector2(0, -6))               # Touching hip line
	c.add_point(Vector2(38.0, -10), Vector2(0, 8), Vector2(0, -8))               # Touching waist below chest
	c.add_point(Vector2(38.5, -45), Vector2(0, 8), Vector2(0, -8))               # Smooth clean chest (no pointy bulge in middle)
	c.add_point(Vector2(49, -76), Vector2(-4, 6), Vector2(-4, -4))               # Relaxed drop-shoulder socket
	c.add_point(Vector2(20, -84), Vector2(6, 1), Vector2(-5, -1))                # Right collar base
	c.add_point(Vector2(0, -82), Vector2(6, 0), Vector2(-6, 0))                  # Back collar dip
	var right_pts := c.tessellate(5, 1.5)

	var poly := PackedVector2Array()
	for pt in right_pts:
		poly.append(pt)
	for i in range(right_pts.size() - 2, 0, -1):
		poly.append(Vector2(-right_pts[i].x, right_pts[i].y))
	return poly

## Left open collar lapel (relaxed open top button)
static func get_collar_lapel_left() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-20, -84), # Collar base
		Vector2(-16, -96), # Left collar peak
		Vector2(-6, -90),  # Inner collar fold
		Vector2(0, -42),   # Open V apex (unbuttoned opening)
		Vector2(-10, -58)  # Outer neckline
	])

## Right open collar lapel (relaxed open top button)
static func get_collar_lapel_right() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(20, -84),  # Collar base
		Vector2(16, -96),  # Right collar peak
		Vector2(6, -90),   # Inner collar fold
		Vector2(0, -42),   # Open V apex
		Vector2(10, -58)   # Outer neckline
	])

## Bare chest & throat visible inside the open unbuttoned collar (NO inner shirt)
static func get_bare_chest_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-8, -84),
		Vector2(8, -84),
		Vector2(4, -58),
		Vector2(0, -42),
		Vector2(-4, -58)
	])

## Backward compatibility alias
static func get_inner_tee_polygon() -> PackedVector2Array:
	return get_bare_chest_polygon()

## Relaxed curved bottom hem points (longer cut touching the body/hips)
static func get_relaxed_shirt_hem() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-38.5, 21),
		Vector2(-19.0, 24),
		Vector2(0, 25),
		Vector2(19.0, 24),
		Vector2(38.5, 21)
	])

static func get_sweater_rib_waistband() -> PackedVector2Array:
	return get_relaxed_shirt_hem()

# -------------------------------------------------------------------------
# ARMS & SLEEVES (Oversized relaxed fit, rolled sleeves with bare forearms)
# -------------------------------------------------------------------------

static func get_upper_sleeve_polygon(p1: Vector2, p2: Vector2, w1: float = 26.0, w2: float = 21.0) -> PackedVector2Array:
	var dir := (p2 - p1).normalized()
	var norm := Vector2(-dir.y, dir.x)
	var h1 := w1 * 0.5
	var h2 := w2 * 0.5
	return PackedVector2Array([
		p1 - norm * h1,
		p1 + norm * h1,
		p2 + norm * h2,
		p2 - norm * h2
	])

static func get_forearm_sleeve_polygon(p1: Vector2, p2: Vector2, w1: float = 18.0, w2: float = 15.0) -> PackedVector2Array:
	var dir := (p2 - p1).normalized()
	var norm := Vector2(-dir.y, dir.x)
	var h1 := w1 * 0.5
	var h2 := w2 * 0.5
	return PackedVector2Array([
		p1 - norm * h1,
		p1 + norm * h1,
		p2 + norm * h2,
		p2 - norm * h2
	])

# -------------------------------------------------------------------------
# TROUSERS & SNEAKERS: RELAXED WIDE-LEG SILHOUETTE
# -------------------------------------------------------------------------

static func get_trouser_pelvis_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-38, 4),
		Vector2(38, 4),
		Vector2(38, 24),
		Vector2(0, 48),
		Vector2(-38, 24)
	])

## Wide-leg trouser silhouette: broad straight cut falling over sneakers
static func get_trouser_leg_polygon(hip_x: float, ankle_x: float, is_left: bool = false) -> PackedVector2Array:
	var top_y := 24.0
	var knee_y := 105.0
	var hem_y := 178.0
	var leg_w_top := 28.0
	var leg_w_knee := 28.0
	var leg_w_hem := 32.0 # Wide leg hem draping over sneaker
	var mid_x := lerpf(hip_x, ankle_x, 0.5)

	return PackedVector2Array([
		Vector2(hip_x - leg_w_top * 0.5, top_y),
		Vector2(hip_x + leg_w_top * 0.5, top_y),
		Vector2(mid_x + leg_w_knee * 0.5, knee_y),
		Vector2(ankle_x + leg_w_hem * 0.5, hem_y),
		Vector2(ankle_x - leg_w_hem * 0.5, hem_y),
		Vector2(mid_x - leg_w_knee * 0.5, knee_y)
	])

static func get_sneaker_polygon(pos: Vector2, is_left: bool = false) -> PackedVector2Array:
	var flip := -1.0 if is_left else 1.0
	return PackedVector2Array([
		pos + Vector2(-16 * flip, -4),
		pos + Vector2(14 * flip, -4),
		pos + Vector2(22 * flip, 2),
		pos + Vector2(24 * flip, 10),
		pos + Vector2(-18 * flip, 10)
	])

static func get_sneaker_toe_cap(pos: Vector2, is_left: bool = false) -> PackedVector2Array:
	var flip := -1.0 if is_left else 1.0
	return PackedVector2Array([
		pos + Vector2(10 * flip, -4),
		pos + Vector2(18 * flip, -2),
		pos + Vector2(24 * flip, 10),
		pos + Vector2(8 * flip, 10)
	])

static func get_sneaker_sole(pos: Vector2, is_left: bool = false) -> PackedVector2Array:
	var flip := -1.0 if is_left else 1.0
	return PackedVector2Array([
		pos + Vector2(-18 * flip, 10),
		pos + Vector2(24 * flip, 10),
		pos + Vector2(24 * flip, 14),
		pos + Vector2(-18 * flip, 14)
	])
