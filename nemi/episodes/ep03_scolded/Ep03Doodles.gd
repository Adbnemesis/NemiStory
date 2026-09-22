class_name Ep03Doodles
extends RefCounted

## Episode 03 Hand-Drawn Doodle & Metaphor Storytelling Toolkit
## Renders hand-drawn black/dark charcoal ink (#2b2623) vector doodles
## Progressive draw-on, authentic pen modulation, and automatic cleanup.

const INK_COLOR: Color = Color("#2b2623")
const ACCENT_RED: Color = Color("#df5d48")
const ICE_BLUE: Color = Color("#9ec5db")
const PAPER_BG: Color = Color("#fbf8f3")

## 1. Gavel Stamp & Deserved Banner (Beat 1)
static func spawn_gavel_stamp(parent: Node2D, pos: Vector2, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		# Gavel hammer head
		if p > 0.1:
			var head_pts := PackedVector2Array([
				Vector2(-18, -12), Vector2(18, -12),
				Vector2(18, 2), Vector2(-18, 2), Vector2(-18, -12)
			])
			canvas.draw_colored_polygon(head_pts, Color("#d9b99b"))
			canvas.draw_polyline(head_pts, INK_COLOR, 2.8)
			# Handle
			canvas.draw_line(Vector2(0, -5), Vector2(25, -28), INK_COLOR, 3.5)
			
		# Sound impact burst
		if p > 0.4:
			canvas.draw_line(Vector2(-24, -5), Vector2(-36, -5), INK_COLOR, 2.0)
			canvas.draw_line(Vector2(-22, 10), Vector2(-32, 18), INK_COLOR, 2.0)
			canvas.draw_line(Vector2(22, 10), Vector2(32, 18), INK_COLOR, 2.0)
			
		# *DESERVED* rectangular stamp frame
		if p > 0.6:
			var stamp_rect := Rect2(-55, 12, 110, 26)
			canvas.draw_rect(stamp_rect, PAPER_BG)
			canvas.draw_rect(stamp_rect, INK_COLOR, false, 2.8)
			# Cross-hatch corner accents
			canvas.draw_line(Vector2(-50, 16), Vector2(-50, 34), INK_COLOR, 1.8)
			canvas.draw_line(Vector2(50, 16), Vector2(50, 34), INK_COLOR, 1.8)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 2. Sticky Note Reminder (Beat 2)
static func spawn_sticky_note(parent: Node2D, pos: Vector2, duration: float = 0.28) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var w := 115.0 * p
		var h := 85.0 * p
		
		# Yellow paper note with folded corner
		var note_pts := PackedVector2Array([
			Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5 - 12, -h * 0.5),
			Vector2(w * 0.5, -h * 0.5 + 12), Vector2(w * 0.5, h * 0.5),
			Vector2(-w * 0.5, h * 0.5), Vector2(-w * 0.5, -h * 0.5)
		])
		canvas.draw_colored_polygon(note_pts, Color("#f9eb9c"))
		canvas.draw_polyline(note_pts, INK_COLOR, 2.8)
		
		# Folded ear
		if p > 0.4:
			canvas.draw_line(Vector2(w * 0.5 - 12, -h * 0.5), Vector2(w * 0.5 - 12, -h * 0.5 + 12), INK_COLOR, 2.0)
			canvas.draw_line(Vector2(w * 0.5 - 12, -h * 0.5 + 12), Vector2(w * 0.5, -h * 0.5 + 12), INK_COLOR, 2.0)
			
		# Handwritten mock text lines
		if p > 0.7:
			canvas.draw_line(Vector2(-w * 0.4, -h * 0.2), Vector2(w * 0.35, -h * 0.2), INK_COLOR, 2.6) # "CHICKEN"
			canvas.draw_line(Vector2(-w * 0.4, 0), Vector2(w * 0.1, 0), INK_COLOR, 2.4)                # "FREEZER"
			canvas.draw_line(Vector2(-w * 0.4, h * 0.22), Vector2(w * 0.38, h * 0.22), ACCENT_RED, 3.2) # "2:00 PM!"
			# Big exclamation mark
			canvas.draw_line(Vector2(w * 0.25, h * 0.15), Vector2(w * 0.25, h * 0.32), ACCENT_RED, 3.5)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 3. Smug Crown & Sparkles (Beat 3)
static func spawn_crown_and_sparkles(parent: Node2D, pos: Vector2, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var s := 24.0 * p
		
		# Golden doodle crown
		var crown_pts := PackedVector2Array([
			Vector2(-s, 0), Vector2(-s * 0.8, -s),
			Vector2(0, -s * 0.4), Vector2(s * 0.8, -s),
			Vector2(s, 0), Vector2(-s, 0)
		])
		canvas.draw_colored_polygon(crown_pts, Color("#fce881"))
		canvas.draw_polyline(crown_pts, INK_COLOR, 2.6)
		
		# Sparkles
		if p > 0.5:
			_draw_sparkle(canvas, Vector2(-s * 1.5, -s * 0.8), 6.0)
			_draw_sparkle(canvas, Vector2(s * 1.5, -s * 0.6), 7.0)
			_draw_sparkle(canvas, Vector2(0, -s * 1.4), 5.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 4. Spinning Time-Skip Clock (Beat 4)
static func spawn_spinning_clock(parent: Node2D, pos: Vector2, duration: float = 0.35) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var r := 38.0
		
		# Clock face
		canvas.draw_circle(Vector2.ZERO, r, PAPER_BG)
		canvas.draw_arc(Vector2.ZERO, r, 0, TAU * p, 24, INK_COLOR, 3.2)
		
		# Clock ticks (12, 3, 6, 9)
		if p > 0.4:
			canvas.draw_line(Vector2(0, -r + 4), Vector2(0, -r + 10), INK_COLOR, 2.5)
			canvas.draw_line(Vector2(r - 4, 0), Vector2(r - 10, 0), INK_COLOR, 2.5)
			canvas.draw_line(Vector2(0, r - 4), Vector2(0, r - 10), INK_COLOR, 2.5)
			canvas.draw_line(Vector2(-r + 4, 0), Vector2(-r + 10, 0), INK_COLOR, 2.5)
			
		# Rapid spinning clock hands
		if p > 0.3:
			var ang_min = p * TAU * 3.5
			var ang_hr = p * TAU * 0.8 + 0.5
			canvas.draw_line(Vector2.ZERO, Vector2(cos(ang_min), sin(ang_min)) * (r * 0.72), INK_COLOR, 2.8)
			canvas.draw_line(Vector2.ZERO, Vector2(cos(ang_hr), sin(ang_hr)) * (r * 0.45), INK_COLOR, 3.8)
			canvas.draw_circle(Vector2.ZERO, 3.5, INK_COLOR)
			
		# Smoke trails / speed lines
		if p > 0.7:
			canvas.draw_arc(Vector2(-r * 0.8, -r * 0.6), 12.0, PI * 0.5, PI * 1.5, 8, INK_COLOR, 1.8)
			canvas.draw_arc(Vector2(r * 0.9, -r * 0.5), 14.0, -PI * 0.5, PI * 0.5, 8, INK_COLOR, 1.8)
			# Time label card "5:45 PM!"
			var label_box := Rect2(-38, r + 6, 76, 20)
			canvas.draw_rect(label_box, PAPER_BG)
			canvas.draw_rect(label_box, ACCENT_RED, false, 2.2)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 5. Car Arrival Shockwaves (Beat 5)
static func spawn_car_soundwaves(parent: Node2D, pos: Vector2, duration: float = 0.22) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		# Arcs radiating from right
		for i in range(3):
			if p > float(i) * 0.25:
				var r := 20.0 + i * 22.0
				canvas.draw_arc(Vector2.ZERO, r, -PI * 0.35, PI * 0.35, 12, ACCENT_RED if i == 0 else INK_COLOR, 3.2 - i * 0.5)
				
		# Sound label tag
		if p > 0.6:
			var tag_pts := PackedVector2Array([
				Vector2(45, -15), Vector2(105, -15), Vector2(100, 12), Vector2(40, 12), Vector2(45, -15)
			])
			canvas.draw_colored_polygon(tag_pts, PAPER_BG)
			canvas.draw_polyline(tag_pts, INK_COLOR, 2.5)
			# Impact vibration lines
			canvas.draw_line(Vector2(110, -8), Vector2(122, -12), INK_COLOR, 2.0)
			canvas.draw_line(Vector2(106, 6), Vector2(118, 10), INK_COLOR, 2.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 6. Arctic Permafrost Gauge & Ice Spikes (Beat 6)
static func spawn_permafrost_gauge(parent: Node2D, pos: Vector2, duration: float = 0.30) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		# Thermometer gauge
		var bulb_pos := Vector2(0, 30)
		canvas.draw_circle(bulb_pos, 14.0, ICE_BLUE)
		canvas.draw_arc(bulb_pos, 14.0, 0, TAU, 16, INK_COLOR, 2.6)
		
		# Stem
		var stem_h := 65.0 * p
		var stem_rect := Rect2(-6, bulb_pos.y - stem_h, 12, stem_h)
		canvas.draw_rect(stem_rect, PAPER_BG)
		canvas.draw_rect(stem_rect, INK_COLOR, false, 2.4)
		canvas.draw_rect(Rect2(-4, bulb_pos.y - stem_h + 2, 8, stem_h), ICE_BLUE)
		
		# Ice crystal spikes bursting from base
		if p > 0.5:
			canvas.draw_polyline([Vector2(-15, 20), Vector2(-28, 15), Vector2(-20, 30)], INK_COLOR, 2.2)
			canvas.draw_polyline([Vector2(15, 20), Vector2(28, 15), Vector2(20, 30)], INK_COLOR, 2.2)
			# Sub-zero text "-40°C" banner
			var txt_rect := Rect2(-30, -52, 60, 20)
			canvas.draw_rect(txt_rect, PAPER_BG)
			canvas.draw_rect(txt_rect, INK_COLOR, false, 2.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 7. Microwave Warning Sparks & Electric Zaps (Beat 7)
static func spawn_microwave_sparks(parent: Node2D, pos: Vector2, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		# Jagged lightning zaps
		for i in range(4):
			var ang := float(i) * (TAU / 4.0) + p * 0.5
			var start := Vector2(cos(ang), sin(ang)) * 10.0
			var mid := Vector2(cos(ang + 0.3), sin(ang + 0.3)) * 25.0
			var end := Vector2(cos(ang - 0.2), sin(ang - 0.2)) * (38.0 * p)
			canvas.draw_polyline([start, mid, end], ACCENT_RED if i % 2 == 0 else Color("#f5b041"), 2.8)
			
		# Warning triangle
		if p > 0.5:
			var tri_pts := PackedVector2Array([
				Vector2(0, -32), Vector2(24, 8), Vector2(-24, 8), Vector2(0, -32)
			])
			canvas.draw_colored_polygon(tri_pts, Color("#fcf3cf"))
			canvas.draw_polyline(tri_pts, INK_COLOR, 2.5)
			# Exclamation inside triangle
			canvas.draw_line(Vector2(0, -20), Vector2(0, -5), INK_COLOR, 3.2)
			canvas.draw_circle(Vector2(0, 1), 2.0, INK_COLOR)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 8. Target Lock Reticle (Beat 8)
static func spawn_target_reticle(parent: Node2D, pos: Vector2, duration: float = 0.25) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var r := 32.0 * p
		
		# Four crosshair brackets
		canvas.draw_arc(Vector2.ZERO, r, -PI * 0.4, -PI * 0.1, 8, ACCENT_RED, 2.8)
		canvas.draw_arc(Vector2.ZERO, r, PI * 0.1, PI * 0.4, 8, ACCENT_RED, 2.8)
		canvas.draw_arc(Vector2.ZERO, r, PI * 0.6, PI * 0.9, 8, ACCENT_RED, 2.8)
		canvas.draw_arc(Vector2.ZERO, r, -PI * 0.9, -PI * 0.6, 8, ACCENT_RED, 2.8)
		
		# Center point
		if p > 0.4:
			canvas.draw_circle(Vector2.ZERO, 3.0, ACCENT_RED)
			# Targeting label
			var box := Rect2(-65, r + 6, 130, 18)
			canvas.draw_rect(box, PAPER_BG)
			canvas.draw_rect(box, INK_COLOR, false, 2.0)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## 9. Cereal Bowl & Banned Stamp (Beat 9)
static func spawn_cereal_payoff(parent: Node2D, pos: Vector2, duration: float = 0.30) -> Node2D:
	var node := Node2D.new()
	node.position = pos
	var d := _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float):
		var p := progress
		var w := 50.0 * p
		var h := 22.0 * p
		
		# Ceramic cereal bowl
		var bowl_pts := PackedVector2Array([
			Vector2(-w * 0.5, 0), Vector2(w * 0.5, 0),
			Vector2(w * 0.35, h), Vector2(-w * 0.35, h),
			Vector2(-w * 0.5, 0)
		])
		canvas.draw_colored_polygon(bowl_pts, PAPER_BG)
		canvas.draw_polyline(bowl_pts, INK_COLOR, 2.8)
		
		# Spoon resting in bowl
		if p > 0.4:
			canvas.draw_line(Vector2(-w * 0.2, h * 0.4), Vector2(-w * 0.6, -14), INK_COLOR, 2.6)
			canvas.draw_arc(Vector2(-w * 0.6, -14), 5.0, 0, TAU, 8, INK_COLOR, 2.2)
			
		# "BANNED FROM FREEZER" circular stamp
		if p > 0.7:
			var stamp_pos := Vector2(40, -15)
			canvas.draw_circle(stamp_pos, 26.0, PAPER_BG)
			canvas.draw_arc(stamp_pos, 26.0, 0, TAU, 20, ACCENT_RED, 2.8)
			# Red diagonal strike-through
			canvas.draw_line(stamp_pos + Vector2(-18, -18), stamp_pos + Vector2(18, 18), ACCENT_RED, 3.2)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

static func _draw_sparkle(canvas: CanvasItem, p: Vector2, s: float) -> void:
	canvas.draw_line(p + Vector2(0, -s), p + Vector2(0, s), INK_COLOR, 2.0)
	canvas.draw_line(p + Vector2(-s, 0), p + Vector2(s, 0), INK_COLOR, 2.0)
	canvas.draw_circle(p, 1.8, INK_COLOR)

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
		draw_hand_stroke(canvas, Vector2(s * 1.35, -s * 0.15), Vector2(0, s * 0.25), INK_COLOR, 3.4, 1.0)
		draw_hand_stroke(canvas, Vector2(0, s * 0.25), Vector2(-s * 1.35, -s * 0.15), INK_COLOR, 3.4, 1.0)
		draw_hand_stroke(canvas, Vector2(-s * 1.35, -s * 0.15), Vector2(0, -s * 0.55), INK_COLOR, 3.4, 1.0)
		
		# Cap button & tassel hanging to right
		if p > 0.35:
			draw_hand_circle(canvas, Vector2(0, -s * 0.15), 4.5, Color("#f59e0b"), 2.0, Color("#fbbf24"))
			draw_hand_stroke(canvas, Vector2(0, -s * 0.15), Vector2(s * 1.1, s * 0.05), Color("#fbbf24"), 3.0, 0.8)
			draw_hand_circle(canvas, Vector2(s * 1.1, s * 0.05 + 8.0), 5.5, Color("#d97706"), 2.2, Color("#fbbf24"))
			
		# Rolled diploma scroll below cap
		if p > 0.55:
			var sc_p: float = (p - 0.55) / 0.45
			var w: float = 85.0 * sc_p
			var scroll_rect: Rect2 = Rect2(-w * 0.5, s * 0.35, w, 22.0)
			draw_hand_box(canvas, scroll_rect, INK_COLOR, 2.8, PAPER_BG, 3.5, 0.8)
			# Red ribbon tied in middle with hanging tails
			draw_hand_stroke(canvas, Vector2(0, s * 0.35), Vector2(0, s * 0.35 + 22.0), ACCENT_RED, 4.0, 0.5)
			draw_hand_stroke(canvas, Vector2(-4.0, s * 0.35 + 22.0), Vector2(-10.0, s * 0.35 + 32.0), ACCENT_RED, 2.8, 0.5)
			draw_hand_stroke(canvas, Vector2(4.0, s * 0.35 + 22.0), Vector2(10.0, s * 0.35 + 32.0), ACCENT_RED, 2.8, 0.5)
			
		# Golden sparkles celebrating the degree
		if p > 0.75:
			var sp_p: float = (p - 0.75) / 0.25
			_draw_sketch_sparkle(canvas, Vector2(-s * 1.2, -s * 0.6), 14.0 * sp_p)
			_draw_sketch_sparkle(canvas, Vector2(s * 1.2, -s * 0.6), 14.0 * sp_p)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

## Hand-drawn dark shame cloud with rain drops (for Beat 8 maternal devastation)
static func spawn_shame_cloud_doodle(parent: Node2D, pos: Vector2, duration: float = 0.28) -> Node2D:
	var node: Node2D = Node2D.new()
	node.position = pos
	node.z_index = 30
	var d: _AnimatedDoodle = _AnimatedDoodle.new()
	d.draw_func = func(canvas: CanvasItem, progress: float) -> void:
		var p: float = progress
		var s: float = 75.0 * p
		# Dark puffy cloud outline with stormy charcoal tint
		draw_hand_circle(canvas, Vector2(-s * 0.45, 0), s * 0.40, Color("#334155"), 3.2, Color(0.20, 0.25, 0.33, 0.85))
		draw_hand_circle(canvas, Vector2(0, -s * 0.25), s * 0.52, Color("#334155"), 3.5, Color(0.20, 0.25, 0.33, 0.90))
		draw_hand_circle(canvas, Vector2(s * 0.45, 0), s * 0.38, Color("#334155"), 3.2, Color(0.20, 0.25, 0.33, 0.85))
		# Flat stormy underside stroke
		draw_hand_stroke(canvas, Vector2(-s * 0.75, s * 0.25), Vector2(s * 0.75, s * 0.25), Color("#1e293b"), 3.8, 1.0)
		
		# Rain drops falling down onto Nemi's head
		if p > 0.45:
			var r_p: float = (p - 0.45) / 0.55
			for i in range(5):
				var rx: float = float(i) * 26.0 - 52.0
				var ry: float = s * 0.35 + float(i % 2) * 6.0
				var r_len: float = 20.0 * r_p
				draw_hand_stroke(canvas, Vector2(rx, ry), Vector2(rx - 2.0, ry + r_len), Color("#38bdf8"), 2.8, 0.5)
				
		# Comedic mini lightning zap or gloom squiggles
		if p > 0.7:
			var l_pts: PackedVector2Array = PackedVector2Array([
				Vector2(10.0, s * 0.3), Vector2(4.0, s * 0.48), Vector2(14.0, s * 0.50), Vector2(6.0, s * 0.75)
			])
			canvas.draw_polyline(l_pts, Color("#facc15"), 2.4)
			
	node.add_child(d)
	parent.add_child(node)
	d.play(duration)
	return node

# Internal helper for sketch sparkles
static func _draw_sketch_sparkle(canvas: CanvasItem, p: Vector2, s: float) -> void:
	if s < 0.5:
		return
	draw_hand_stroke(canvas, p + Vector2(0, -s), p + Vector2(0, s), INK_COLOR, 2.0, 0.5)
	draw_hand_stroke(canvas, p + Vector2(-s, 0), p + Vector2(s, 0), INK_COLOR, 2.0, 0.5)
	var d: float = s * 0.45
	canvas.draw_circle(p + Vector2(-d, -d), 1.2, INK_COLOR)
	canvas.draw_circle(p + Vector2(d, -d), 1.2, INK_COLOR)
	canvas.draw_circle(p + Vector2(-d, d), 1.2, INK_COLOR)
	canvas.draw_circle(p + Vector2(d, d), 1.2, INK_COLOR)

# Internal animated canvas item
class _AnimatedDoodle extends Node2D:
	var progress: float = 0.0
	var draw_func: Callable
	
	func play(duration: float) -> void:
		var tw: Tween = create_tween()
		tw.tween_property(self, "progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_callback(queue_redraw)
		
	func _process(_delta: float) -> void:
		if progress < 1.0:
			queue_redraw()
			
	func _draw() -> void:
		if draw_func.is_valid():
			draw_func.call(self, progress)
