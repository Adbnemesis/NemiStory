class_name Ep02Doodles
extends RefCounted

## Episode 02 Hand-Drawn Doodle & Metaphor Storytelling Toolkit
## Renders hand-drawn black/dark charcoal ink (#2b2623) vector doodles
## Progressive draw-on, authentic pen modulation, and automatic cleanup.

const INK_COLOR: Color = Color("#2b2623")

## 1. Secret Lock & Key (Beat 1)
static func spawn_lock(parent: Node2D, pos: Vector2, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var w := 28.0
		var h := 22.0
		
		# Shackle (U-shape arch)
		if p > 0.1:
			var shackle_pts := PackedVector2Array([
				Vector2(-10, -8), Vector2(-10, -22), Vector2(0, -28), Vector2(10, -22), Vector2(10, -8)
			])
			canvas.draw_polyline(shackle_pts, INK_COLOR, 2.6)
			
		# Lock body (rectangular box)
		if p > 0.4:
			var body_pts := PackedVector2Array([
				Vector2(-w * 0.5, -h * 0.4), Vector2(w * 0.5, -h * 0.4),
				Vector2(w * 0.5, h * 0.6), Vector2(-w * 0.5, h * 0.6),
				Vector2(-w * 0.5, -h * 0.4)
			])
			canvas.draw_colored_polygon(body_pts, Color("#faf7f2"))
			canvas.draw_polyline(body_pts, INK_COLOR, 3.0)
			
		# Keyhole
		if p > 0.7:
			canvas.draw_circle(Vector2(0, 0), 3.0, INK_COLOR)
			canvas.draw_line(Vector2(0, 2), Vector2(0, 7), INK_COLOR, 2.2)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 2. Texting Chat Bubble (Beat 4)
static func spawn_chat_bubble(parent: Node2D, pos: Vector2, text: String, is_left: bool = true, duration: float = 0.22) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		if progress < 0.05: return
		var w := 80.0 * progress
		var h := 32.0 * progress
		var sign_x := -1.0 if is_left else 1.0
		
		# Bubble body
		var rect := Rect2(-w * 0.5, -h * 0.5, w, h)
		canvas.draw_rect(rect, Color("#fdfbf7"))
		canvas.draw_rect(rect, INK_COLOR, false, 2.6)
		
		# Speech tail
		var tail := PackedVector2Array([
			Vector2(-w * 0.25 * sign_x, h * 0.5),
			Vector2(-w * 0.40 * sign_x, h * 0.5 + 8.0 * progress),
			Vector2(-w * 0.10 * sign_x, h * 0.5)
		])
		canvas.draw_colored_polygon(tail, Color("#fdfbf7"))
		canvas.draw_polyline(tail, INK_COLOR, 2.6)
		
		# Inner text simulation (organic little ink dashes)
		if progress > 0.6:
			canvas.draw_line(Vector2(-w * 0.35, -3), Vector2(w * 0.3, -3), INK_COLOR, 2.2)
			canvas.draw_line(Vector2(-w * 0.35, 5), Vector2(0, 5), INK_COLOR, 2.2)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 3. Flipping Calendar Pages (Beat 4)
static func spawn_calendar(parent: Node2D, pos: Vector2, month_label: String, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var w := 44.0
		var h := 52.0
		
		# Calendar back sheet
		var back_pts := PackedVector2Array([
			Vector2(-w * 0.5 + 3, -h * 0.5 + 3), Vector2(w * 0.5 + 3, -h * 0.5 + 3),
			Vector2(w * 0.5 + 3, h * 0.5 + 3), Vector2(-w * 0.5 + 3, h * 0.5 + 3),
			Vector2(-w * 0.5 + 3, -h * 0.5 + 3)
		])
		canvas.draw_polyline(back_pts, INK_COLOR, 1.8)
		
		# Main calendar body
		var body_pts := PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5),
			Vector2(w * 0.5, h * 0.5), Vector2(-w * 0.5, h * 0.5),
			Vector2(-w * 0.5, -h * 0.5)
		])
		canvas.draw_colored_polygon(body_pts, Color("#faf7f2"))
		canvas.draw_polyline(body_pts, INK_COLOR, 2.8)
		
		# Header binder bar
		canvas.draw_line(Vector2(-w * 0.5, -h * 0.5 + 12), Vector2(w * 0.5, -h * 0.5 + 12), INK_COLOR, 2.2)
		# Binder rings
		canvas.draw_line(Vector2(-12, -h * 0.5 - 3), Vector2(-12, -h * 0.5 + 3), INK_COLOR, 2.4)
		canvas.draw_line(Vector2(12, -h * 0.5 - 3), Vector2(12, -h * 0.5 + 3), INK_COLOR, 2.4)
		
		# Month indicator (simulated ink numeral or checkmark)
		if progress > 0.5:
			canvas.draw_line(Vector2(-10, 8), Vector2(0, 18), INK_COLOR, 3.0)
			canvas.draw_line(Vector2(0, 18), Vector2(14, -2), INK_COLOR, 3.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 4. Matching Puzzle Pieces (Beat 5)
static func spawn_puzzle_pieces(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var gap := lerpf(40.0, 0.0, progress)
		
		# Left Piece
		var lp := Vector2(-gap, 0)
		var left_pts := PackedVector2Array([
			lp + Vector2(-25, -20), lp + Vector2(0, -20),
			lp + Vector2(6, -8), lp + Vector2(6, 8), lp + Vector2(0, 20),
			lp + Vector2(-25, 20), lp + Vector2(-25, -20)
		])
		canvas.draw_colored_polygon(left_pts, Color("#fdfbf7"))
		canvas.draw_polyline(left_pts, INK_COLOR, 2.8)
		
		# Right Piece (interlocking notch)
		var rp := Vector2(gap, 0)
		var right_pts := PackedVector2Array([
			rp + Vector2(0, -20), rp + Vector2(25, -20),
			rp + Vector2(25, 20), rp + Vector2(0, 20),
			rp + Vector2(6, 8), lp + Vector2(6, -8), rp + Vector2(0, -20)
		])
		canvas.draw_colored_polygon(right_pts, Color("#fdfbf7"))
		canvas.draw_polyline(right_pts, INK_COLOR, 2.8)
		
		if progress >= 0.95:
			# Click highlight star
			canvas.draw_line(Vector2(0, -26), Vector2(0, -32), INK_COLOR, 2.0)
			canvas.draw_line(Vector2(-3, -29), Vector2(3, -29), INK_COLOR, 2.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 5. Anime Manga Speed Lines & Sparkles (Beat 7)
static func spawn_manga_burst(parent: Node2D, pos: Vector2, duration: float = 0.28) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var radius := 55.0 * progress
		for i in range(8):
			var ang := (float(i) / 8.0) * TAU
			var p1 := Vector2(cos(ang), sin(ang)) * (radius * 0.5)
			var p2 := Vector2(cos(ang), sin(ang)) * radius
			canvas.draw_line(p1, p2, INK_COLOR, 2.6)
			
		# Four-point anime glints
		if progress > 0.4:
			_draw_glint(canvas, Vector2(-45, -35), 14.0 * progress)
			_draw_glint(canvas, Vector2(45, -35), 14.0 * progress)
			_draw_glint(canvas, Vector2(0, -50), 18.0 * progress)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 6. Mutual Irritation & Balance Scales (Beat 8)
static func spawn_balance_scale(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var w := 70.0
		# Center pivot
		canvas.draw_line(Vector2(0, 25), Vector2(0, -15), INK_COLOR, 3.0)
		canvas.draw_line(Vector2(-12, 25), Vector2(12, 25), INK_COLOR, 3.2)
		
		# Horizontal beam
		canvas.draw_line(Vector2(-w * 0.5, -15), Vector2(w * 0.5, -15), INK_COLOR, 2.8)
		
		# Left & Right scale pans
		if p > 0.4:
			canvas.draw_line(Vector2(-w * 0.5, -15), Vector2(-w * 0.5, 5), INK_COLOR, 1.8)
			canvas.draw_arc(Vector2(-w * 0.5, 5), 14.0, 0, PI, 10, INK_COLOR, 2.4)
			
			canvas.draw_line(Vector2(w * 0.5, -15), Vector2(w * 0.5, 5), INK_COLOR, 1.8)
			canvas.draw_arc(Vector2(w * 0.5, 5), 14.0, 0, PI, 10, INK_COLOR, 2.4)
			
		# "= 100% BALANCE" underline
		if p > 0.8:
			canvas.draw_line(Vector2(-20, 32), Vector2(20, 32), INK_COLOR, 2.4)
			canvas.draw_line(Vector2(-20, 36), Vector2(20, 36), INK_COLOR, 2.4)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 7. Two-Way Help Arrows (Beat 9)
static func spawn_help_arrows(parent: Node2D, pos: Vector2, duration: float = 0.30) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var span := 60.0 * progress
		# Top arrow pointing right ->
		canvas.draw_line(Vector2(-span * 0.5, -8), Vector2(span * 0.5, -8), INK_COLOR, 2.6)
		if progress > 0.7:
			canvas.draw_line(Vector2(span * 0.5 - 6, -14), Vector2(span * 0.5, -8), INK_COLOR, 2.6)
			canvas.draw_line(Vector2(span * 0.5 - 6, -2), Vector2(span * 0.5, -8), INK_COLOR, 2.6)
			
		# Bottom arrow pointing left <-
		canvas.draw_line(Vector2(span * 0.5, 8), Vector2(-span * 0.5, 8), INK_COLOR, 2.6)
		if progress > 0.7:
			canvas.draw_line(Vector2(-span * 0.5 + 6, 2), Vector2(-span * 0.5, 8), INK_COLOR, 2.6)
			canvas.draw_line(Vector2(-span * 0.5 + 6, 14), Vector2(-span * 0.5, 8), INK_COLOR, 2.6)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 8. Connected Pair of Best Friends (Beat 10)
static func spawn_connected_pair(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		# Left figure (Nemi stick figure)
		canvas.draw_circle(Vector2(-25, -16), 7.0, INK_COLOR)
		canvas.draw_line(Vector2(-25, -9), Vector2(-25, 12), INK_COLOR, 2.4)
		canvas.draw_line(Vector2(-25, 12), Vector2(-32, 26), INK_COLOR, 2.4)
		canvas.draw_line(Vector2(-25, 12), Vector2(-18, 26), INK_COLOR, 2.4)
		
		# Right figure (ADB stick figure)
		canvas.draw_circle(Vector2(25, -18), 7.5, INK_COLOR)
		canvas.draw_line(Vector2(25, -10.5), Vector2(25, 14), INK_COLOR, 2.4)
		canvas.draw_line(Vector2(25, 14), Vector2(18, 28), INK_COLOR, 2.4)
		canvas.draw_line(Vector2(25, 14), Vector2(32, 28), INK_COLOR, 2.4)
		
		# Connecting joined hands line
		if progress > 0.4:
			canvas.draw_line(Vector2(-25, -2), Vector2(0, 0), INK_COLOR, 2.6)
			canvas.draw_line(Vector2(25, -3), Vector2(0, 0), INK_COLOR, 2.6)
			
		# Small shared star above
		if progress > 0.8:
			_draw_glint(canvas, Vector2(0, -22), 9.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 9. 3:00 AM Analog Clock with Spinning Hands (Beat 4)
static func spawn_3am_clock(parent: Node2D, pos: Vector2, duration: float = 0.30) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var r := 26.0
		# Clock face circle
		canvas.draw_circle(Vector2.ZERO, r, Color("#faf7f2"))
		canvas.draw_arc(Vector2.ZERO, r, 0, TAU, 24, INK_COLOR, 2.8)
		
		# Hour tick marks
		for i in range(12):
			var ang := (float(i) / 12.0) * TAU
			var p1 := Vector2(cos(ang), sin(ang)) * (r - 4.0)
			var p2 := Vector2(cos(ang), sin(ang)) * (r - 1.0)
			canvas.draw_line(p1, p2, INK_COLOR, 1.6)
			
		# Center pivot
		canvas.draw_circle(Vector2.ZERO, 2.5, INK_COLOR)
		
		# Hour Hand pointing to 3 o'clock (right)
		var hr_ang := lerpf(-PI * 0.5, 0.0, clampf(progress * 1.5, 0.0, 1.0))
		canvas.draw_line(Vector2.ZERO, Vector2(cos(hr_ang), sin(hr_ang)) * 14.0, INK_COLOR, 3.0)
		
		# Minute Hand spinning rapidly to 12 o'clock
		var min_ang := -PI * 0.5 + progress * TAU * 2.0
		canvas.draw_line(Vector2.ZERO, Vector2(cos(min_ang), sin(min_ang)) * 20.0, INK_COLOR, 2.2)
		
		# Little ringing bell ears on top
		if progress > 0.6:
			canvas.draw_arc(Vector2(-16, -20), 7.0, -PI * 0.8, -0.1, 8, INK_COLOR, 2.0)
			canvas.draw_arc(Vector2(16, -20), 7.0, -PI + 0.1, -PI * 0.2, 8, INK_COLOR, 2.0)
			
		# "3:00 AM" doodle label below
		if progress > 0.8:
			canvas.draw_line(Vector2(-20, 36), Vector2(-16, 36), INK_COLOR, 2.2) # 3
			canvas.draw_circle(Vector2(-10, 34), 1.2, INK_COLOR) # :
			canvas.draw_circle(Vector2(-10, 38), 1.2, INK_COLOR)
			canvas.draw_circle(Vector2(-2, 36), 3.0, INK_COLOR) # 0
			canvas.draw_circle(Vector2(7, 36), 3.0, INK_COLOR) # 0
			canvas.draw_line(Vector2(14, 40), Vector2(17, 32), INK_COLOR, 1.8) # A
			canvas.draw_line(Vector2(17, 32), Vector2(20, 40), INK_COLOR, 1.8)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 10. Drunken Loopy Swirls (Beat 6)
static func spawn_drunken_swirls(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		if progress < 0.1: return
		var pts := PackedVector2Array()
		var steps := int(progress * 40.0)
		for i in range(steps):
			var t := float(i) * 0.15
			var r := 2.0 + t * 4.0
			var x := cos(t) * r
			var y := sin(t) * (r * 0.6) - (t * 2.0)
			pts.append(Vector2(x, y))
		if pts.size() > 1:
			canvas.draw_polyline(pts, INK_COLOR, 2.2)
			
		# Little floating bubbles of tipsiness
		if progress > 0.7:
			canvas.draw_circle(Vector2(-18, -25), 3.0, Color("#faf7f2"))
			canvas.draw_arc(Vector2(-18, -25), 3.0, 0, TAU, 8, INK_COLOR, 1.6)
			canvas.draw_circle(Vector2(20, -32), 4.0, Color("#faf7f2"))
			canvas.draw_arc(Vector2(20, -32), 4.0, 0, TAU, 8, INK_COLOR, 1.6)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 11. Protective Rain Umbrella & Storm Sheltering (Beat 9)
static func spawn_umbrella(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var w := 80.0 * progress
		var h := 32.0 * progress
		
		# Rain drops falling from above outside umbrella canopy
		if progress > 0.3:
			for x_off in [-55, -42, 42, 55]:
				canvas.draw_line(Vector2(x_off, -45), Vector2(x_off - 6, -20), INK_COLOR, 1.6)
				
		# Umbrella Canopy Dome
		var canopy_pts := PackedVector2Array([
			Vector2(-w * 0.5, 0),
			Vector2(-w * 0.35, -h * 0.7),
			Vector2(0, -h),
			Vector2(w * 0.35, -h * 0.7),
			Vector2(w * 0.5, 0),
			Vector2(w * 0.25, -4),
			Vector2(0, 0),
			Vector2(-w * 0.25, -4),
			Vector2(-w * 0.5, 0)
		])
		canvas.draw_colored_polygon(canopy_pts, Color("#fdfbf7"))
		canvas.draw_polyline(canopy_pts, INK_COLOR, 2.8)
		
		# Top tip spike
		canvas.draw_line(Vector2(0, -h), Vector2(0, -h - 8 * progress), INK_COLOR, 2.4)
		
		# Central shaft
		canvas.draw_line(Vector2(0, -h * 0.4), Vector2(0, 35 * progress), INK_COLOR, 2.6)
		# J-Hook Handle
		if progress > 0.8:
			canvas.draw_arc(Vector2(6, 35), 6.0, 0, PI, 8, INK_COLOR, 2.6)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 12. Anime Hero Speedline Katana Slash & Aura (Beat 7)
static func spawn_anime_katana_aura(parent: Node2D, pos: Vector2, duration: float = 0.30) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		# Dynamic diagonal slash streak across ADB
		var slash_len := 160.0 * progress
		var p1 := Vector2(-slash_len * 0.5, slash_len * 0.4)
		var p2 := Vector2(slash_len * 0.5, -slash_len * 0.4)
		canvas.draw_line(p1, p2, Color("#38d9d4"), 4.0)
		canvas.draw_line(p1, p2, INK_COLOR, 1.8)
		
		# Radiating speedlines
		for i in range(12):
			var ang := (float(i) / 12.0) * TAU
			var dist1 := 60.0 + 20.0 * sin(float(i) * 3.0)
			var dist2 := dist1 + 50.0 * progress
			var pt1 := Vector2(cos(ang), sin(ang)) * dist1
			var pt2 := Vector2(cos(ang), sin(ang)) * dist2
			canvas.draw_line(pt1, pt2, INK_COLOR, 2.2)
			
		# Heroic action spark stars
		if progress > 0.6:
			_draw_glint(canvas, Vector2(-60, -40), 16.0)
			_draw_glint(canvas, Vector2(65, -30), 14.0)
			_draw_glint(canvas, Vector2(0, -75), 18.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 13. Teasing Finger Poker & Comic Anger Veins (Beat 8)
static func spawn_tease_poker(parent: Node2D, pos: Vector2, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		# Pointing finger darting left towards Nemi
		var travel := lerpf(40.0, 0.0, progress)
		var p := Vector2(travel, 0)
		# Arm / index finger
		var finger_pts := PackedVector2Array([
			p + Vector2(40, -4), p + Vector2(10, -4),
			p + Vector2(0, 0), p + Vector2(10, 4),
			p + Vector2(40, 4)
		])
		canvas.draw_polyline(finger_pts, INK_COLOR, 2.8)
		
		# Comic impact marks at tip ("poke poke")
		if progress > 0.8:
			canvas.draw_line(p + Vector2(-6, -8), p + Vector2(-14, -14), INK_COLOR, 2.2)
			canvas.draw_line(p + Vector2(-8, 0), p + Vector2(-16, 0), INK_COLOR, 2.2)
			canvas.draw_line(p + Vector2(-6, 8), p + Vector2(-14, 14), INK_COLOR, 2.2)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 14. Brain Electricity & Synapse Flash (Beat 5)
static func spawn_brain_electricity(parent: Node2D, pos: Vector2, duration: float = 0.30) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var span := 80.0 * progress
		# Zig-zag electric bolt between brains
		var bolt_pts := PackedVector2Array([
			Vector2(-span * 0.5, 0),
			Vector2(-span * 0.25, -14),
			Vector2(-span * 0.05, 10),
			Vector2(span * 0.15, -12),
			Vector2(span * 0.35, 12),
			Vector2(span * 0.5, 0)
		])
		canvas.draw_polyline(bolt_pts, Color("#e2aa36"), 4.0)
		canvas.draw_polyline(bolt_pts, INK_COLOR, 2.0)
		
		if progress > 0.6:
			_draw_glint(canvas, Vector2(0, 0), 15.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 15. Cozy Desk with Laptop and Steaming Coffee (Beat 3)
static func spawn_desk_setup(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var desk_w := 170.0 * progress
		# Desktop horizontal board
		var desk_top := PackedVector2Array([
			Vector2(-desk_w * 0.5, 0), Vector2(desk_w * 0.5, 0),
			Vector2(desk_w * 0.48, 14), Vector2(-desk_w * 0.48, 14),
			Vector2(-desk_w * 0.5, 0)
		])
		canvas.draw_colored_polygon(desk_top, Color("#f5f0e6"))
		canvas.draw_polyline(desk_top, INK_COLOR, 2.8)
		
		# Desk legs extending down to horizon floor (height 140)
		if progress > 0.4:
			canvas.draw_line(Vector2(-desk_w * 0.42, 14), Vector2(-desk_w * 0.42, 140), INK_COLOR, 2.8)
			canvas.draw_line(Vector2(desk_w * 0.42, 14), Vector2(desk_w * 0.42, 140), INK_COLOR, 2.8)
			
		# Open Laptop on desk
		if progress > 0.6:
			var lap_x := 15.0
			# Keyboard base
			var kb_pts := PackedVector2Array([
				Vector2(lap_x - 30, 0), Vector2(lap_x + 30, 0),
				Vector2(lap_x + 24, -6), Vector2(lap_x - 24, -6)
			])
			canvas.draw_colored_polygon(kb_pts, Color("#e6ded1"))
			canvas.draw_polyline(kb_pts, INK_COLOR, 2.2)
			# Screen tilted back
			var scr_pts := PackedVector2Array([
				Vector2(lap_x - 24, -6), Vector2(lap_x + 24, -6),
				Vector2(lap_x + 22, -45), Vector2(lap_x - 22, -45)
			])
			canvas.draw_colored_polygon(scr_pts, Color("#fdfbf7"))
			canvas.draw_polyline(scr_pts, INK_COLOR, 2.4)
			# Screen glowing window hint
			canvas.draw_line(Vector2(lap_x - 18, -38), Vector2(lap_x + 18, -38), Color("#38d9d4"), 2.0)
			canvas.draw_line(Vector2(lap_x - 18, -30), Vector2(lap_x + 10, -30), Color("#38d9d4"), 2.0)
			
		# Coffee mug on desk
		if progress > 0.7:
			var mug_pos := Vector2(-desk_w * 0.30, -5)
			var mug_rect := Rect2(mug_pos.x - 7, mug_pos.y - 12, 14, 14)
			canvas.draw_rect(mug_rect, Color("#fdfbf7"))
			canvas.draw_rect(mug_rect, INK_COLOR, false, 2.2)
			# Handle
			canvas.draw_arc(mug_pos + Vector2(-9, -5), 5.0, PI * 0.5, PI * 1.5, 6, INK_COLOR, 2.0)
			# Steam curls
			canvas.draw_line(mug_pos + Vector2(-2, -15), mug_pos + Vector2(-4, -23), INK_COLOR, 1.6)
			canvas.draw_line(mug_pos + Vector2(3, -17), mug_pos + Vector2(1, -26), INK_COLOR, 1.6)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

static func _draw_glint(canvas: CanvasItem, p: Vector2, s: float) -> void:
	canvas.draw_line(p + Vector2(0, -s), p + Vector2(0, s), INK_COLOR, 2.0)
	canvas.draw_line(p + Vector2(-s, 0), p + Vector2(s, 0), INK_COLOR, 2.0)
	canvas.draw_circle(p, 2.0, INK_COLOR)

# Internal helper class for animating stroke progress
class _AnimatedDoodle extends Node2D:
	var progress: float = 0.0
	var draw_func: Callable
	
	func play(duration: float) -> void:
		var tw := create_tween()
		tw.tween_property(self, "progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_callback(queue_redraw)
		
	func _process(_delta: float) -> void:
		if progress < 1.0:
			queue_redraw()
			
	func _draw() -> void:
		if draw_func.is_valid():
			draw_func.call(self, progress)
