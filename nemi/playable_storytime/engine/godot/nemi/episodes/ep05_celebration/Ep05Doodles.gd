class_name Ep05Doodles
extends RefCounted

## Hand-Drawn Doodle & Storytime Animation Engine for Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"
## 100% Authentic Hand-Drawn Storytime Aesthetic matching Pegi & Jaiden Animations:
## - True Hand-Drawn Typography via Patrick Hand & Caveat
## - Organic hand-drawn strokes with natural line wobble and double pencil sketch passes
## - Rich interactive celebration props & doodles:
##   * DoodleSubscriberCounter: Hand-drawn ticking counter (1 -> 17 -> 84 -> 247 -> 500 -> 999 -> 1000!!)
##   * DoodleGiant1000: Large hand-lettered 1000 with thick ink strokes, sparkles & celebration trophy
##   * DoodleCommentFlood: Generic hand-drawn comment bubbles falling, stacking, and pushable
##   * DoodleTinyCrowd: Cluster of 20+ cute little stick figure viewer doodles waving hands
##   * DoodlePhoneInstagram: Buzzing smartphone with 250 followers celebration card & linking arrow
##   * DoodleMagnifyingGlass: Hand-drawn magnifying glass to inspect the giant 1000 number
##   * DoodlePhysicalCards: "Goal: 1000 subs" (crossed out), "THANK YOU <3", "NEW VIDEO SOON"

const Ep05DoodlesClass = preload("res://nemi/episodes/ep05_celebration/Ep05Doodles.gd")

static var _patrick_font: FontFile = null
static var _caveat_font: FontFile = null

static func get_handwriting_font(cursive: bool = false) -> FontFile:
	if cursive:
		if _caveat_font == null:
			_caveat_font = FontFile.new()
			var err = _caveat_font.load_dynamic_font("res://assets/fonts/Caveat-Bold.ttf")
			if err != OK:
				_caveat_font = ThemeDB.fallback_font as FontFile
		return _caveat_font
	else:
		if _patrick_font == null:
			_patrick_font = FontFile.new()
			var err = _patrick_font.load_dynamic_font("res://assets/fonts/PatrickHand-Regular.ttf")
			if err != OK:
				_patrick_font = ThemeDB.fallback_font as FontFile
		return _patrick_font

# =============================================================================
# 1. PROCEDURAL HAND-DRAWN STROKE (Wobble + Double Pencil Sketch Lines)
# =============================================================================

class HandDrawnStroke extends Node2D:
	var raw_points: PackedVector2Array
	var ink_color: Color
	var line_width: float
	var wobble_amplitude: float
	var draw_progress: float = 1.0
	var double_sketch_pass: bool = true
	var _cached_wobbly_pts: PackedVector2Array
	var _cached_sketch_pts: PackedVector2Array

	func _init(pts: PackedVector2Array, col: Color = Color("#38101e"), width: float = 2.8, wobble: float = 2.0) -> void:
		raw_points = pts
		ink_color = col
		line_width = width
		wobble_amplitude = wobble
		_compute_wobble_geometry()

	func _compute_wobble_geometry() -> void:
		_cached_wobbly_pts.clear()
		_cached_sketch_pts.clear()
		if raw_points.size() < 2:
			return
		
		for i in range(raw_points.size() - 1):
			var p0 := raw_points[i]
			var p1 := raw_points[i + 1]
			var seg_len := p0.distance_to(p1)
			var sub_steps := maxi(2, int(ceil(seg_len / 12.0)))
			var dir := (p1 - p0).normalized()
			var norm := Vector2(-dir.y, dir.x)
			
			for s in range(sub_steps):
				var frac := float(s) / float(sub_steps)
				var base := p0.lerp(p1, frac)
				var seed_val := float(i * 7 + s)
				var displacement := (sin(seed_val * 1.73) * 0.65 + cos(seed_val * 3.41) * 0.35) * wobble_amplitude
				_cached_wobbly_pts.append(base + norm * displacement)
				
				var sketch_disp := (cos(seed_val * 2.11) * 0.5 + sin(seed_val * 4.17) * 0.5) * (wobble_amplitude * 1.3)
				_cached_sketch_pts.append(base + norm * sketch_disp + Vector2(0.8, 0.6))
				
		_cached_wobbly_pts.append(raw_points[raw_points.size() - 1])
		_cached_sketch_pts.append(raw_points[raw_points.size() - 1] + Vector2(0.8, 0.6))

	func animate_draw_on(duration: float = 0.35) -> Signal:
		draw_progress = 0.0
		queue_redraw()
		var tw := create_tween()
		tw.tween_property(self, "draw_progress", 1.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration)
		return tw.finished

	func _draw() -> void:
		if draw_progress <= 0.001 or _cached_wobbly_pts.size() < 2:
			return
			
		var total_pts := _cached_wobbly_pts.size()
		var visible_count := maxi(2, int(ceil(float(total_pts) * draw_progress)))
		visible_count = mini(visible_count, total_pts)
		
		var draw_pts := _cached_wobbly_pts.slice(0, visible_count)
		
		if double_sketch_pass and _cached_sketch_pts.size() >= visible_count:
			var sketch_slice := _cached_sketch_pts.slice(0, visible_count)
			var faint_col := Color(ink_color.r, ink_color.g, ink_color.b, ink_color.a * 0.32)
			draw_polyline(sketch_slice, faint_col, line_width * 0.65)
			
		draw_polyline(draw_pts, ink_color, line_width)

# =============================================================================
# 2. HAND-DRAWN SUBSCRIBER TICKING COUNTER (1 -> 17 -> 84 -> 247 -> 500 -> 999 -> 1000)
# =============================================================================

class DoodleSubscriberCounter extends Node2D:
	var current_number: int = 1
	var is_milestone: bool = false
	var label: Label
	var title_label: Label
	var _shake_timer: float = 0.0
	var _base_pos: Vector2 = Vector2.ZERO

	func _init(start_pos: Vector2) -> void:
		position = start_pos
		_base_pos = start_pos
		z_index = 20

		title_label = Label.new()
		title_label.text = "SUBSCRIBERS"
		title_label.position = Vector2(-90, -48)
		title_label.size = Vector2(180, 24)
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var font := Ep05DoodlesClass.get_handwriting_font(false)
		if font: title_label.add_theme_font_override("font", font)
		title_label.add_theme_font_size_override("font_size", 20)
		title_label.add_theme_color_override("font_color", Color("#555555"))
		add_child(title_label)

		label = Label.new()
		label.text = "1"
		label.position = Vector2(-90, -18)
		label.size = Vector2(180, 50)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if font: label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 42)
		label.add_theme_color_override("font_color", Color("#2b2623"))
		add_child(label)

	func _process(delta: float) -> void:
		if _shake_timer > 0.0:
			_shake_timer -= delta
			position = _base_pos + Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0))
			if _shake_timer <= 0.0:
				position = _base_pos

	func set_count(val: int, shake: bool = false) -> void:
		current_number = val
		if val >= 1000:
			label.text = "1,000!!"
			label.add_theme_color_override("font_color", Color("#d93b2b")) # Celebration red
			label.add_theme_font_size_override("font_size", 48)
			is_milestone = true
		else:
			label.text = str(val)
		if shake:
			_shake_timer = 0.25
		queue_redraw()

	func count_to(target_num: int, duration: float = 0.4) -> Signal:
		var start_num := current_number
		var tw := create_tween()
		tw.tween_method(func(v: int): set_count(v), start_num, target_num, duration)
		if target_num >= 999:
			tw.parallel().tween_property(self, "_shake_timer", 0.35, 0.0)
		return tw.finished

	func _draw() -> void:
		var rect := Rect2(-105, -55, 210, 95)
		# Cream paper card fill
		var bg_col := Color("#fffef7") if not is_milestone else Color("#fffdf0")
		draw_rect(rect, bg_col)

		# Organic hand-drawn perimeter
		var ink := Color("#2b2623")
		draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.position.x + rect.size.x, rect.position.y), ink, 2.4)
		draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y), Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), ink, 2.4)
		draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), Vector2(rect.position.x, rect.position.y + rect.size.y), ink, 2.4)
		draw_line(Vector2(rect.position.x, rect.position.y + rect.size.y), Vector2(rect.position.x, rect.position.y), ink, 2.4)

		# If hit 1000, draw hand-drawn celebratory red circle around counter
		if is_milestone:
			var pts := PackedVector2Array()
			var steps := 28
			for i in range(steps + 1):
				var ang := float(i) / float(steps) * TAU
				var r := 62.0 + sin(float(i) * 2.3) * 3.5
				pts.append(Vector2(cos(ang) * 1.4, sin(ang)) * r + Vector2(0, 5))
			draw_polyline(pts, Color("#d93b2b"), 3.2)

# =============================================================================
# 3. GIANT HAND-DRAWN 1,000 CELEBRATION DOODLE
# =============================================================================

class DoodleGiant1000 extends Node2D:
	var label: Label
	var sub_label: Label
	var draw_scale: float = 0.0

	func _init(center_pos: Vector2) -> void:
		position = center_pos
		z_index = 22
		scale = Vector2.ZERO

		label = Label.new()
		label.text = "1,000"
		label.position = Vector2(-200, -80)
		label.size = Vector2(400, 110)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var font := Ep05DoodlesClass.get_handwriting_font(false)
		if font: label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 96)
		label.add_theme_color_override("font_color", Color("#d93b2b"))
		label.add_theme_color_override("font_outline_color", Color("#2b2623"))
		label.add_theme_constant_override("outline_size", 8)
		add_child(label)

		sub_label = Label.new()
		sub_label.text = "SUBSCRIBERS!!"
		sub_label.position = Vector2(-200, 30)
		sub_label.size = Vector2(400, 45)
		sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		if font: sub_label.add_theme_font_override("font", font)
		sub_label.add_theme_font_size_override("font_size", 36)
		sub_label.add_theme_color_override("font_color", Color("#f39c12"))
		sub_label.add_theme_color_override("font_outline_color", Color("#2b2623"))
		sub_label.add_theme_constant_override("outline_size", 6)
		add_child(sub_label)

	func animate_pop_in(duration: float = 0.45) -> Signal:
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.15, 1.15), duration * 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", Vector2.ONE, duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		return tw.finished

	func _draw() -> void:
		# Draw radiating celebration starburst lines around the 1000
		var ink := Color("#f39c12")
		for i in range(12):
			var ang := float(i) / 12.0 * TAU
			var p0 := Vector2(cos(ang) * 180.0, sin(ang) * 95.0)
			var p1 := Vector2(cos(ang) * 230.0, sin(ang) * 125.0)
			draw_line(p0, p1, ink, 2.5)

# =============================================================================
# 4. GENERIC HAND-DRAWN COMMENT BUBBLES FLOOD
# =============================================================================

class DoodleCommentBubble extends Node2D:
	var width: float = 170.0
	var height: float = 65.0
	var bubble_color: Color = Color("#fffef7")
	var ink_color: Color = Color("#2b2623")
	var label: Label = null

	func _init(start_pos: Vector2, w: float = 170.0, h: float = 65.0, col: Color = Color("#fffef7")) -> void:
		position = start_pos
		width = w
		height = h
		bubble_color = col
		z_index = 18

	func set_text(txt: String, col: Color = Color("#2b2623")) -> void:
		if not label:
			label = Label.new()
			label.position = Vector2(-width * 0.5 + 44, -height * 0.5 + 4)
			label.size = Vector2(width - 50, height - 8)
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			var font := Ep05DoodlesClass.get_handwriting_font(false)
			if font: label.add_theme_font_override("font", font)
			label.add_theme_font_size_override("font_size", 18)
			add_child(label)
		label.text = txt
		label.add_theme_color_override("font_color", col)

	func _draw() -> void:
		var rect := Rect2(-width * 0.5, -height * 0.5, width, height)
		draw_rect(rect, bubble_color)

		# Hand-drawn perimeter
		draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.position.x + rect.size.x, rect.position.y), ink_color, 2.2)
		draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y), Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), ink_color, 2.2)
		draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y), Vector2(rect.position.x, rect.position.y + rect.size.y), ink_color, 2.2)
		draw_line(Vector2(rect.position.x, rect.position.y + rect.size.y), Vector2(rect.position.x, rect.position.y), ink_color, 2.2)

		# Little comment bubble tail
		draw_polygon(PackedVector2Array([
			Vector2(-width * 0.3, height * 0.5),
			Vector2(-width * 0.2, height * 0.5 + 12),
			Vector2(-width * 0.15, height * 0.5)
		]), [bubble_color])
		draw_line(Vector2(-width * 0.3, height * 0.5), Vector2(-width * 0.2, height * 0.5 + 12), ink_color, 2.0)
		draw_line(Vector2(-width * 0.2, height * 0.5 + 12), Vector2(-width * 0.15, height * 0.5), ink_color, 2.0)

		# Sketched avatar circle on left
		var av_pos := Vector2(-width * 0.5 + 24, 0)
		draw_circle(av_pos, 12.0, Color("#e2e8f0"))
		draw_arc(av_pos, 12.0, 0, TAU, 16, ink_color, 1.6)

		# Sketched text bars (represents generic friendly comment)
		var bar_x := -width * 0.5 + 46
		draw_line(Vector2(bar_x, -7), Vector2(width * 0.5 - 16, -7), Color("#718096"), 2.2)
		draw_line(Vector2(bar_x, 7), Vector2(width * 0.5 - 35, 7), Color("#a0aec0"), 2.0)

	func animate_fall(target_y: float, duration: float = 0.4) -> Signal:
		var tw := create_tween()
		tw.tween_property(self, "position:y", target_y, duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		return tw.finished

	func push_away(velocity: Vector2, duration: float = 0.35) -> Signal:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(self, "position", position + velocity, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "rotation", rotation + 0.35, duration)
		tw.tween_property(self, "modulate:a", 0.0, duration)
		return tw.finished

# =============================================================================
# 5. HAND-DRAWN TINY CROWD (Visual Metaphor for 1,000 Viewers)
# =============================================================================

class DoodleTinyCrowd extends Node2D:
	var crowd_members: Array = []
	var _is_waving: bool = false
	var _wave_time: float = 0.0

	func _init(base_y: float = 520.0) -> void:
		z_index = 12
		var rng := RandomNumberGenerator.new()
		rng.seed = 2026
		for i in range(24):
			var x := 120.0 + float(i) * 44.0 + rng.randf_range(-8.0, 8.0)
			var y := base_y + rng.randf_range(-15.0, 15.0)
			var arm_raised := (i % 2 == 0)
			crowd_members.append({"pos": Vector2(x, y), "arm": arm_raised, "scale": rng.randf_range(0.85, 1.15)})

	func start_waving() -> void:
		_is_waving = true

	func _process(delta: float) -> void:
		if _is_waving:
			_wave_time += delta
			for i in range(crowd_members.size()):
				crowd_members[i]["arm"] = int(_wave_time * 6.0 + i) % 2 == 0
			queue_redraw()

	func _draw() -> void:
		var ink := Color("#2b2623")
		for m in crowd_members:
			var p: Vector2 = m["pos"]
			var s: float = m["scale"]
			# Head
			draw_circle(p + Vector2(0, -32 * s), 8.0 * s, Color("#ffffff"))
			draw_arc(p + Vector2(0, -32 * s), 8.0 * s, 0, TAU, 14, ink, 1.8)
			# Smile in head
			draw_arc(p + Vector2(0, -30 * s), 4.0 * s, 0.2, PI - 0.2, 8, ink, 1.4)
			# Body line
			draw_line(p + Vector2(0, -24 * s), p + Vector2(0, -6 * s), ink, 2.0)
			# Waving arms
			if m["arm"]:
				draw_line(p + Vector2(0, -18 * s), p + Vector2(-12 * s, -28 * s), ink, 1.8)
				draw_line(p + Vector2(0, -18 * s), p + Vector2(12 * s, -28 * s), ink, 1.8)
			else:
				draw_line(p + Vector2(0, -18 * s), p + Vector2(-10 * s, -10 * s), ink, 1.8)
				draw_line(p + Vector2(0, -18 * s), p + Vector2(10 * s, -26 * s), ink, 1.8)

# =============================================================================
# 6. INSTAGRAM 250 SMARTPHONE DOODLE
# =============================================================================

class DoodlePhoneInstagram extends Node2D:
	var label: Label
	var _buzz_timer: float = 0.0
	var _base_pos: Vector2 = Vector2.ZERO

	func _init(start_pos: Vector2) -> void:
		position = start_pos
		_base_pos = start_pos
		z_index = 22

		label = Label.new()
		label.text = "250\nFOLLOWERS"
		label.position = Vector2(-55, -20)
		label.size = Vector2(110, 48)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var font := Ep05DoodlesClass.get_handwriting_font(false)
		if font: label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color("#2b2623"))
		add_child(label)

	func trigger_buzz(duration: float = 0.6) -> void:
		_buzz_timer = duration

	func vibrate(duration: float = 0.8) -> void:
		trigger_buzz(duration)

	func show_screen() -> void:
		pass

	func _process(delta: float) -> void:
		if _buzz_timer > 0.0:
			_buzz_timer -= delta
			position = _base_pos + Vector2(randf_range(-4.0, 4.0), randf_range(-1.5, 1.5))
			if _buzz_timer <= 0.0:
				position = _base_pos

	func _draw() -> void:
		# Smartphone body
		var rect := Rect2(-65, -95, 130, 190)
		draw_rect(rect, Color("#ffffff"))
		var ink := Color("#2b2623")
		draw_rect(rect, Color("#1a202c"), false, 2.6)

		# Screen inset
		var scr := Rect2(-58, -75, 116, 145)
		draw_rect(scr, Color("#fdf2f8"))
		draw_rect(scr, Color("#f472b6"), false, 1.8)

		# Generic hand-drawn camera icon (circle + flash lens)
		var cam_y := -45.0
		draw_rect(Rect2(-24, cam_y - 15, 48, 30), Color("#f43f5e"), false, 2.0)
		draw_circle(Vector2(0, cam_y), 8.0, Color("#f43f5e"))
		draw_circle(Vector2(14, cam_y - 8), 2.5, Color("#f43f5e"))

		# Vibration arcs if buzzing
		if _buzz_timer > 0.0:
			var vib_col := Color("#3b82f6")
			draw_arc(Vector2(-78, 0), 18.0, -PI * 0.4, PI * 0.4, 8, vib_col, 2.0)
			draw_arc(Vector2(78, 0), 18.0, PI * 0.6, PI * 1.4, 8, vib_col, 2.0)

# =============================================================================
# 7. PHYSICAL PAPER NOTEBOOK / GOAL CARD PROPS
# =============================================================================

class DoodlePhysicalCard extends Node2D:
	var label: Label
	var is_checked: bool = false
	var width: float = 200.0
	var height: float = 120.0
	var card_color: Color = Color("#fffdfa")

	func _init(pos: Vector2, text: String, checked: bool = false, col: Color = Color("#fffdfa")) -> void:
		position = pos
		is_checked = checked
		card_color = col
		z_index = 18

		label = Label.new()
		label.text = text
		label.position = Vector2(-width * 0.5 + 10, -height * 0.5 + 15)
		label.size = Vector2(width - 20, height - 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var font := Ep05DoodlesClass.get_handwriting_font(false)
		if font: label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 26)
		label.add_theme_color_override("font_color", Color("#2b2623"))
		add_child(label)

	func _draw() -> void:
		var rect := Rect2(-width * 0.5, -height * 0.5, width, height)
		draw_rect(rect, card_color)
		var ink := Color("#2b2623")
		draw_rect(rect, ink, false, 2.4)

		# Push-pin or tape on top
		draw_rect(Rect2(-18, -height * 0.5 - 6, 36, 12), Color(0.9, 0.88, 0.75, 0.85))

		# Big red celebration checkmark if checked
		if is_checked:
			var pts := PackedVector2Array([
				Vector2(-40, 10),
				Vector2(-10, 35),
				Vector2(45, -25)
			])
			draw_polyline(pts, Color("#d93b2b"), 4.0)

# =============================================================================
# CONVENIENCE FACTORY SPAWN METHODS
# =============================================================================

static func spawn_subscriber_counter(parent: Node, pos: Vector2) -> DoodleSubscriberCounter:
	var counter := DoodleSubscriberCounter.new(pos)
	parent.add_child(counter)
	return counter

static func spawn_giant_1000(parent: Node, pos: Vector2) -> DoodleGiant1000:
	var g1000 := DoodleGiant1000.new(pos)
	parent.add_child(g1000)
	g1000.animate_pop_in()
	return g1000

static func spawn_comment_bubble(parent: Node, pos: Vector2, w: float = 170.0, h: float = 65.0) -> DoodleCommentBubble:
	var bubble := DoodleCommentBubble.new(pos, w, h)
	parent.add_child(bubble)
	return bubble

static func spawn_tiny_crowd(parent: Node, base_y: float = 520.0) -> DoodleTinyCrowd:
	var crowd := DoodleTinyCrowd.new(base_y)
	parent.add_child(crowd)
	return crowd

static func spawn_phone_instagram(parent: Node, pos: Vector2) -> DoodlePhoneInstagram:
	var phone := DoodlePhoneInstagram.new(pos)
	parent.add_child(phone)
	return phone

static func spawn_physical_card(parent: Node, pos: Vector2, text: String, checked: bool = false, col: Color = Color("#fffdfa")) -> DoodlePhysicalCard:
	var card := DoodlePhysicalCard.new(pos, text, checked, col)
	parent.add_child(card)
	return card
