extends Node2D

func _draw():
	_draw_complete_head(Vector2(640, 420))

func _draw_complete_head(center: Vector2):
	# 1. Back hair
	var hair_back := Curve2D.new()
	hair_back.add_point(center + Vector2(0, -118), Vector2(-25, 0), Vector2(25, 0))
	hair_back.add_point(center + Vector2(58, -80), Vector2(-10, -20), Vector2(6, 30))
	hair_back.add_point(center + Vector2(60, 20), Vector2(0, -40), Vector2(-4, 50))
	hair_back.add_point(center + Vector2(48, 120), Vector2(8, -40), Vector2(-6, 30))
	hair_back.add_point(center + Vector2(30, 175), Vector2(4, -20), Vector2(-4, 0)) # Clump 1
	hair_back.add_point(center + Vector2(16, 155), Vector2(0, 0), Vector2(0, 0))
	hair_back.add_point(center + Vector2(0, 185), Vector2(6, -15), Vector2(-6, -15)) # Center clump
	hair_back.add_point(center + Vector2(-16, 155), Vector2(0, 0), Vector2(0, 0))
	hair_back.add_point(center + Vector2(-30, 175), Vector2(4, 0), Vector2(-4, -20)) # Clump 2
	hair_back.add_point(center + Vector2(-48, 120), Vector2(6, 30), Vector2(-8, -40))
	hair_back.add_point(center + Vector2(-60, 20), Vector2(4, 50), Vector2(0, -40))
	hair_back.add_point(center + Vector2(-58, -80), Vector2(-6, 30), Vector2(10, -20))
	
	var hair_back_pts := hair_back.tessellate(5, 3.0)
	draw_colored_polygon(hair_back_pts, Color("#c54d42"))
	draw_polyline(hair_back_pts + PackedVector2Array([hair_back_pts[0]]), Color("#3e081e"), 2.8, true)
	
	# 2. Neck
	var neck := PackedVector2Array([
		center + Vector2(-12, -8), center + Vector2(12, -8),
		center + Vector2(15, 35), center + Vector2(-15, 35)
	])
	draw_colored_polygon(neck, Color("#fadcc2"))
	draw_polyline(neck, Color("#3e081e"), 2.2, true)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-12, -8), center + Vector2(12, -8),
		center + Vector2(13, 8), center + Vector2(0, 14), center + Vector2(-13, 8)
	]), Color("#f1be9d"))
	
	# 3. Soft, Youthful Curved Face (Chin at 0, Cheeks at -42, Temples at -72)
	var c := Curve2D.new()
	c.add_point(center + Vector2(0, 0), Vector2(-14, 0), Vector2(14, 0)) # Rounded chin
	c.add_point(center + Vector2(26, -14), Vector2(-8, 6), Vector2(8, -6)) # Lower right jaw
	c.add_point(center + Vector2(46, -42), Vector2(-4, 12), Vector2(2, -14)) # Soft full right cheek
	c.add_point(center + Vector2(45, -72), Vector2(0, 12), Vector2(-2, -12)) # Right temple
	c.add_point(center + Vector2(32, -98), Vector2(8, 10), Vector2(-10, -10)) # Skull upper right
	c.add_point(center + Vector2(0, -112), Vector2(18, 0), Vector2(-18, 0)) # Skull apex
	c.add_point(center + Vector2(-32, -98), Vector2(10, -10), Vector2(-8, 10)) # Skull upper left
	c.add_point(center + Vector2(-45, -72), Vector2(2, -12), Vector2(0, 12)) # Left temple
	c.add_point(center + Vector2(-46, -42), Vector2(-2, -14), Vector2(4, 12)) # Soft full left cheek
	c.add_point(center + Vector2(-26, -14), Vector2(-8, -6), Vector2(8, 6)) # Lower left jaw
	
	var smooth_face := c.tessellate(5, 3.0)
	draw_colored_polygon(smooth_face, Color("#fadcc2"))
	draw_polyline(smooth_face + PackedVector2Array([smooth_face[0]]), Color("#3e081e"), 2.6, true)
	
	# 4. Eyes (at y = -48)
	_draw_cute_eye(center + Vector2(-23, -48), true)
	_draw_cute_eye(center + Vector2(23, -48), false)
	
	# Nose
	draw_circle(center + Vector2(0, -26), 1.3, Color("#3e081e"))
	
	# Mouth
	var mouth := PackedVector2Array([
		center + Vector2(-9, -14), center + Vector2(-3, -11),
		center + Vector2(0, -12), center + Vector2(3, -11), center + Vector2(9, -14)
	])
	draw_polyline(mouth, Color("#c54d42"), 2.0, true)
	
	# Blush
	for dx in [-3, 0, 3]:
		draw_line(center + Vector2(-30 + dx, -32), center + Vector2(-26 + dx, -24), Color("#e88b7d", 0.6), 1.5, true)
		draw_line(center + Vector2(26 + dx, -32), center + Vector2(30 + dx, -24), Color("#e88b7d", 0.6), 1.5, true)
	
	# 5. Front Bangs & Crown (Fringe tips hover neatly above eyes at y = -58 to -55!)
	var bangs := Curve2D.new()
	bangs.add_point(center + Vector2(-48, -75), Vector2(-4, -10), Vector2(4, 10))
	bangs.add_point(center + Vector2(-40, -56), Vector2(-4, -8), Vector2(2, 6))
	bangs.add_point(center + Vector2(-32, -48), Vector2(-4, 4), Vector2(4, -8)) # Side fringe
	bangs.add_point(center + Vector2(-22, -66), Vector2(-2, 8), Vector2(2, 6))
	bangs.add_point(center + Vector2(-12, -56), Vector2(-3, -6), Vector2(3, 6)) # Center-left fringe
	bangs.add_point(center + Vector2(0, -70), Vector2(-3, 8), Vector2(3, 8)) # Center part
	bangs.add_point(center + Vector2(12, -56), Vector2(-3, 6), Vector2(3, -6)) # Center-right fringe
	bangs.add_point(center + Vector2(22, -66), Vector2(-2, 6), Vector2(2, 8))
	bangs.add_point(center + Vector2(32, -48), Vector2(-4, -8), Vector2(4, 4)) # Side fringe
	bangs.add_point(center + Vector2(40, -56), Vector2(-2, 6), Vector2(4, -8))
	bangs.add_point(center + Vector2(48, -75), Vector2(-4, 10), Vector2(4, -10))
	bangs.add_point(center + Vector2(32, -106), Vector2(8, 8), Vector2(-8, -8))
	bangs.add_point(center + Vector2(0, -116), Vector2(15, 0), Vector2(-15, 0))
	bangs.add_point(center + Vector2(-32, -106), Vector2(8, -8), Vector2(-8, 8))
	
	var bangs_pts := bangs.tessellate(5, 3.0)
	draw_colored_polygon(bangs_pts, Color("#c54d42"))
	draw_polyline(bangs_pts + PackedVector2Array([bangs_pts[0]]), Color("#3e081e"), 2.8, true)
	
	# 6. Side Tresses (framing cheeks)
	var lt_path := PackedVector2Array([
		center + Vector2(-40, -50),
		center + Vector2(-42, 0),
		center + Vector2(-36, 45),
		center + Vector2(-32, 80)
	])
	var lt_polys := Geometry2D.offset_polyline(lt_path, 6.0, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	if lt_polys.size() > 0:
		draw_colored_polygon(lt_polys[0], Color("#c54d42"))
		draw_polyline(lt_polys[0] + PackedVector2Array([lt_polys[0][0]]), Color("#3e081e"), 2.4, true)
	
	var rt_path := PackedVector2Array([
		center + Vector2(40, -50),
		center + Vector2(42, 0),
		center + Vector2(36, 45),
		center + Vector2(32, 80)
	])
	var rt_polys := Geometry2D.offset_polyline(rt_path, 6.0, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	if rt_polys.size() > 0:
		draw_colored_polygon(rt_polys[0], Color("#c54d42"))
		draw_polyline(rt_polys[0] + PackedVector2Array([rt_polys[0][0]]), Color("#3e081e"), 2.4, true)
	
	# 7. Ahoge (flicking up and to the right)
	var ahoge_c := Curve2D.new()
	ahoge_c.add_point(center + Vector2(4, -114), Vector2(0, 0), Vector2(4, -15))
	ahoge_c.add_point(center + Vector2(16, -138), Vector2(-4, 10), Vector2(6, -10))
	ahoge_c.add_point(center + Vector2(26, -152), Vector2(-3, 6), Vector2(0, 0))
	var ahoge_path := ahoge_c.tessellate(4, 3.0)
	var ahoge_polys := Geometry2D.offset_polyline(ahoge_path, 5.0, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	if ahoge_polys.size() > 0:
		draw_colored_polygon(ahoge_polys[0], Color("#c54d42"))
		draw_polyline(ahoge_polys[0] + PackedVector2Array([ahoge_polys[0][0]]), Color("#3e081e"), 2.4, true)
	
	# 8. Eyebrows over bangs (classic anime layering)
	var lb := Curve2D.new()
	lb.add_point(center + Vector2(-33, -64), Vector2(0, 0), Vector2(6, -5))
	lb.add_point(center + Vector2(-14, -66), Vector2(-6, -4), Vector2(0, 0))
	draw_polyline(lb.tessellate(4, 3.0), Color("#7b261e"), 2.6, true)
	
	var rb := Curve2D.new()
	rb.add_point(center + Vector2(14, -66), Vector2(0, 0), Vector2(6, -4))
	rb.add_point(center + Vector2(33, -64), Vector2(-6, -5), Vector2(0, 0))
	draw_polyline(rb.tessellate(4, 3.0), Color("#7b261e"), 2.6, true)

func _draw_cute_eye(center: Vector2, is_left: bool):
	var sign_x := -1.0 if is_left else 1.0
	var eye_c := Curve2D.new()
	eye_c.add_point(center + Vector2(-11 * sign_x, 0), Vector2(0, 0), Vector2(3 * sign_x, -9))
	eye_c.add_point(center + Vector2(0, -9), Vector2(-5 * sign_x, 0), Vector2(5 * sign_x, 0))
	eye_c.add_point(center + Vector2(11 * sign_x, 1), Vector2(-3 * sign_x, -8), Vector2(0, 4))
	eye_c.add_point(center + Vector2(0, 7), Vector2(5 * sign_x, 0), Vector2(-5 * sign_x, 0))
	
	var sclera_pts := eye_c.tessellate(4, 4.0)
	draw_colored_polygon(sclera_pts, Color.WHITE)
	
	# Emerald Iris
	draw_circle(center + Vector2(0, -1), 6.5, Color("#368d5f"))
	draw_circle(center + Vector2(0, -2), 5.5, Color("#245e43"))
	# Dark Pupil
	draw_circle(center + Vector2(0, -1), 3.2, Color("#132c20"))
	# Highlights
	draw_circle(center + Vector2(-2 * sign_x, -3.5), 2.2, Color.WHITE)
	draw_circle(center + Vector2(2.5 * sign_x, 1.5), 1.2, Color.WHITE)
	
	# Upper lash line
	var lash_c := Curve2D.new()
	lash_c.add_point(center + Vector2(-12 * sign_x, 2), Vector2(0, 0), Vector2(3 * sign_x, -9))
	lash_c.add_point(center + Vector2(0, -10), Vector2(-5 * sign_x, 0), Vector2(6 * sign_x, 0))
	lash_c.add_point(center + Vector2(13 * sign_x, -1), Vector2(-4 * sign_x, -5), Vector2(2 * sign_x, -2))
	lash_c.add_point(center + Vector2(16 * sign_x, -3), Vector2(0, 0), Vector2(0, 0))
	draw_polyline(lash_c.tessellate(5, 2.0), Color("#3e081e"), 3.2, true)
	
	# Crease
	draw_polyline(PackedVector2Array([center + Vector2(-6 * sign_x, -14), center + Vector2(4 * sign_x, -14)]), Color("#3e081e", 0.5), 1.2, true)
