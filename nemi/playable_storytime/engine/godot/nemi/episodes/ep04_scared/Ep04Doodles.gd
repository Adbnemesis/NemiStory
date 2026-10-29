class_name Ep04Doodles
extends RefCounted

## Hand-Drawn Doodle & Storytime Animation Engine for Episode 04: "Guys, I'm Scared."
## 100% Authentic Hand-Drawn Storytime Aesthetic matching Pegi & Jaiden Animations:
## - True Hand-Drawn Typography via Patrick Hand & Caveat (zero mechanical stick fonts)
## - Live animated pen write-on reveal (stroke/letter progressive draw-in)
## - Rich interactive props & doodles:
##   * DoodleDropdownMenu: Funny status picker ("Status: Panicking") inspired by Pegi's dropdown
##   * DoodleCatMascot: Cute chibi cat sitting on desk watching Nemi
##   * DoodleGhost: Cute wobbly sheet ghost + "HORROR MOVIE?" + red marker crossout
##   * DoodleYouTube: YouTube play button + "<- The real monster"
##   * DoodleShrimpPosture: Hunched shrimp on office chair ("<- My posture")
##   * DoodleViewsRefresh: "7 views" + refresh circle + smartphone + pie chart ("half from my phone")
##   * DoodleBrainSpiral: Overthinking swirl + question mark cloud
##   * DoodleTimelineChaos: Tangled timeline ribbons + error card ("layer 84") + bug
##   * DoodleHeartCare: Sketched pink watercolor heart + "i care a lot ♡"
##   * DoodleNextVideo: Video player card + "NEXT VIDEO ->" + star stickers
##   * DoodleSignoff: Cheerful wave lettering ("wish me luck! ♡" + "BYE!! :D")

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
	var draw_progress: float = 1.0 # 0.0 to 1.0
	var double_pencil_pass: bool = true
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
				
				# Offset faint second pencil line for hand-sketched look
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
		
		# 1. Subtle secondary sketch line underneath
		if double_pencil_pass and _cached_sketch_pts.size() >= visible_count:
			var sketch_slice := _cached_sketch_pts.slice(0, visible_count)
			var faint_col := Color(ink_color.r, ink_color.g, ink_color.b, ink_color.a * 0.32)
			draw_polyline(sketch_slice, faint_col, line_width * 0.65)
			
		# 2. Main hand-drawn ink line
		draw_polyline(draw_pts, ink_color, line_width)

# =============================================================================
# 2. AUTHENTIC HANDWRITTEN TEXT (Patrick Hand & Caveat TrueType Rendering)
# =============================================================================

class HandwrittenText extends Node2D:
	var full_text: String = ""
	var font_size: int = 28
	var ink_color: Color = Color("#38101e")
	var is_cursive: bool = false
	var align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	var draw_progress: float = 1.0 # 0.0 to 1.0 (progressive letter reveal)
	var wobble_rot: float = 0.0

	var _font: FontFile

	func _init(p_text: String, p_size: float = 28.0, p_col: Color = Color("#38101e"), p_cursive: bool = false, p_align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void:
		full_text = p_text
		font_size = int(p_size)
		ink_color = p_col
		is_cursive = p_cursive
		align = p_align
		_font = Ep04Doodles.get_handwriting_font(p_cursive)
		wobble_rot = deg_to_rad(randf_range(-1.5, 1.5))
		rotation = wobble_rot

	func animate_draw_on(duration: float = 0.4) -> Signal:
		draw_progress = 0.0
		queue_redraw()
		var tw := create_tween()
		tw.tween_property(self, "draw_progress", 1.0, duration).set_trans(Tween.TRANS_LINEAR)
		tw.parallel().tween_method(func(_v): queue_redraw(), 0.0, 1.0, duration)
		return tw.finished

	func _draw() -> void:
		if full_text.is_empty() or draw_progress <= 0.001 or _font == null:
			return
			
		var visible_chars := int(ceil(float(full_text.length()) * draw_progress))
		visible_chars = clamp(visible_chars, 0, full_text.length())
		var sub := full_text.substr(0, visible_chars)
		
		var full_sz := _font.get_string_size(full_text, align, -1, font_size)
		var text_offset := Vector2.ZERO
		if align == HORIZONTAL_ALIGNMENT_CENTER:
			text_offset.x = -full_sz.x * 0.5
		elif align == HORIZONTAL_ALIGNMENT_RIGHT:
			text_offset.x = -full_sz.x
			
		# Render with anti-aliasing and soft warm outline
		draw_string_outline(_font, text_offset + Vector2(0, full_sz.y * 0.3), sub, align, -1, font_size, 1, Color(ink_color.r, ink_color.g, ink_color.b, 0.4))
		draw_string(_font, text_offset + Vector2(0, full_sz.y * 0.3), sub, align, -1, font_size, ink_color)

# =============================================================================
# 3. HAND-DRAWN CALLOUT ARROW (<- My posture, <- from my phone)
# =============================================================================

class HandDrawnArrow extends Node2D:
	var from_pos: Vector2
	var to_pos: Vector2
	var label_text: String
	var ink_color: Color
	var is_cursive: bool
	
	var _stroke: HandDrawnStroke
	var _head_stroke: HandDrawnStroke
	var _label: HandwrittenText

	func _init(p_from: Vector2, p_to: Vector2, p_label: String = "", p_col: Color = Color("#38101e"), p_cursive: bool = false) -> void:
		from_pos = p_from
		to_pos = p_to
		label_text = p_label
		ink_color = p_col
		is_cursive = p_cursive
		
		# Curved arrow shaft
		var dir := (to_pos - from_pos).normalized()
		var dist := from_pos.distance_to(to_pos)
		var perp := Vector2(-dir.y, dir.x)
		var mid := from_pos.lerp(to_pos, 0.5) + perp * (dist * 0.18)
		
		var shaft_pts := PackedVector2Array([from_pos, mid, to_pos])
		_stroke = HandDrawnStroke.new(shaft_pts, ink_color, 2.6, 1.8)
		add_child(_stroke)
		
		# Arrowhead barb
		var barb1 := to_pos - dir * 16.0 + perp * 9.0
		var barb2 := to_pos - dir * 16.0 - perp * 9.0
		var head_pts := PackedVector2Array([barb1, to_pos, barb2])
		_head_stroke = HandDrawnStroke.new(head_pts, ink_color, 2.6, 1.4)
		add_child(_head_stroke)
		
		# Label at arrow tail
		if not label_text.is_empty():
			_label = HandwrittenText.new(label_text, 26.0, ink_color, is_cursive)
			var offset_dir := -dir
			_label.position = from_pos + offset_dir * 12.0 + Vector2(-10, -10)
			add_child(_label)

	func animate_draw_on(duration: float = 0.35) -> Signal:
		_stroke.animate_draw_on(duration * 0.6)
		_head_stroke.animate_draw_on(duration * 0.4)
		if _label:
			_label.animate_draw_on(duration * 0.5)
		var tw := create_tween()
		tw.tween_interval(duration)
		return tw.finished

# =============================================================================
# 4. RICH STORYTIME DOODLES (MATCHING PEGI / JAIDEN REFERENCES)
# =============================================================================

# --- BEAT 1: DROPDOWN MENU STATUS PICKER ("Status: Panicking") ---
class DoodleDropdownMenu extends Node2D:
	var frame_rect: Rect2 = Rect2(0, 0, 200, 160)
	var ink_col: Color = Color("#38101e")
	var highlight_col: Color = Color("#ffb3c1") # Pastel rose
	var label_nodes: Array[Node2D] = []

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		
		# Hand-sketched box
		var box_pts := PackedVector2Array([
			Vector2(0, 0), Vector2(200, 0), Vector2(200, 160), Vector2(0, 160), Vector2(0, 0)
		])
		var box := HandDrawnStroke.new(box_pts, ink_col, 2.8, 1.8)
		add_child(box)
		
		# Horizontal dividers
		var d1 := HandDrawnStroke.new(PackedVector2Array([Vector2(0, 40), Vector2(200, 40)]), ink_col, 2.0, 1.4)
		var d2 := HandDrawnStroke.new(PackedVector2Array([Vector2(0, 80), Vector2(200, 80)]), ink_col, 2.0, 1.4)
		var d3 := HandDrawnStroke.new(PackedVector2Array([Vector2(0, 120), Vector2(200, 120)]), ink_col, 2.0, 1.4)
		add_child(d1); add_child(d2); add_child(d3)
		
		# Down arrow icon on header
		var v_pts := PackedVector2Array([Vector2(170, 15), Vector2(182, 28), Vector2(194, 15)])
		add_child(HandDrawnStroke.new(v_pts, ink_col, 2.4, 1.2))
		
		# Text items: "Status", "Confident", "Chilling", "PANICKING"
		var t_title := HandwrittenText.new("Status:", 24.0, ink_col)
		t_title.position = Vector2(15, 8); add_child(t_title); label_nodes.append(t_title)
		
		var t_opt1 := HandwrittenText.new("Confident", 22.0, Color(ink_col.r, ink_col.g, ink_col.b, 0.45))
		t_opt1.position = Vector2(15, 48); add_child(t_opt1); label_nodes.append(t_opt1)
		
		var t_opt2 := HandwrittenText.new("Chilling", 22.0, Color(ink_col.r, ink_col.g, ink_col.b, 0.45))
		t_opt2.position = Vector2(15, 88); add_child(t_opt2); label_nodes.append(t_opt2)
		
		var t_opt3 := HandwrittenText.new("Panicking!!", 24.0, Color("#d90429")) # Bold red
		t_opt3.position = Vector2(15, 126); add_child(t_opt3); label_nodes.append(t_opt3)
		
		# Arrow pointing to panicking ("<- ME RN")
		var callout := HandDrawnArrow.new(Vector2(250, 140), Vector2(205, 140), "<- Me rn", Color("#d90429"), true)
		add_child(callout)

	func _draw() -> void:
		# Card paper fill
		draw_rect(Rect2(0, 0, 200, 160), Color("#ffffff", 0.95))
		# Highlight on "Panicking" row
		draw_rect(Rect2(2, 122, 196, 36), highlight_col)

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.3, 0.3)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

# --- CHIBI CAT MASCOT ON DESK (Inspired by Pegi's cat in First Video) ---
class DoodleCatMascot extends Node2D:
	var ink_col: Color = Color("#38101e")

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		z_index = 16
		
		# Head contour
		var head_pts := PackedVector2Array()
		for i in range(16):
			var a := float(i) * TAU / 15.0
			head_pts.append(Vector2(cos(a) * 22, sin(a) * 18))
		add_child(HandDrawnStroke.new(head_pts, ink_col, 2.4, 1.2))
		
		# Ears
		var l_ear := PackedVector2Array([Vector2(-16, -12), Vector2(-22, -32), Vector2(-4, -18)])
		var r_ear := PackedVector2Array([Vector2(4, -18), Vector2(22, -32), Vector2(16, -12)])
		add_child(HandDrawnStroke.new(l_ear, ink_col, 2.4, 1.2))
		add_child(HandDrawnStroke.new(r_ear, ink_col, 2.4, 1.2))
		
		# Body
		var body_pts := PackedVector2Array([
			Vector2(-14, 14), Vector2(-24, 45), Vector2(24, 45), Vector2(14, 14)
		])
		add_child(HandDrawnStroke.new(body_pts, ink_col, 2.4, 1.5))
		
		# Curled tail on right side
		var tail_pts := PackedVector2Array([
			Vector2(20, 42), Vector2(36, 32), Vector2(40, 10), Vector2(34, -4)
		])
		add_child(HandDrawnStroke.new(tail_pts, ink_col, 2.4, 1.4))
		
		# Whiskers
		var w_left := HandDrawnStroke.new(PackedVector2Array([Vector2(-16, 2), Vector2(-30, 0)]), ink_col, 1.6, 0.8)
		var w_right := HandDrawnStroke.new(PackedVector2Array([Vector2(16, 2), Vector2(30, 0)]), ink_col, 1.6, 0.8)
		add_child(w_left); add_child(w_right)
		
		# Cute smile mouth
		var mouth := HandwrittenText.new("ω", 20.0, ink_col)
		mouth.position = Vector2(-7, -4)
		add_child(mouth)

	func _draw() -> void:
		# Soft white cat body fill
		draw_circle(Vector2(0, 0), 21.0, Color("#ffffff"))
		draw_rect(Rect2(-20, 14, 40, 31), Color("#ffffff"))
		# Pink ear interiors
		var l_ear_inner := PackedVector2Array([Vector2(-14, -14), Vector2(-19, -27), Vector2(-6, -18)])
		var r_ear_inner := PackedVector2Array([Vector2(6, -18), Vector2(19, -27), Vector2(14, -14)])
		draw_colored_polygon(l_ear_inner, Color("#ffccd5"))
		draw_colored_polygon(r_ear_inner, Color("#ffccd5"))
		# Big dark curious eyes with cute white pupil highlights (Pegi style)
		draw_circle(Vector2(-9, -4), 4.5, ink_col)
		draw_circle(Vector2(9, -4), 4.5, ink_col)
		draw_circle(Vector2(-8, -6), 1.6, Color("#ffffff"))
		draw_circle(Vector2(10, -6), 1.6, Color("#ffffff"))
		# Cheek blushes
		draw_circle(Vector2(-15, 4), 4.0, Color(1.0, 0.65, 0.72, 0.5))
		draw_circle(Vector2(15, 4), 4.0, Color(1.0, 0.65, 0.72, 0.5))

# --- BEAT 2: GHOST DOODLE + RED MARKER CROSSOUT + YOUTUBE LOGO ---
class DoodleGhost extends Node2D:
	var label: HandwrittenText
	var ghost_stroke: HandDrawnStroke
	var cross_stroke1: HandDrawnStroke
	var cross_stroke2: HandDrawnStroke
	var red_ink: Color = Color("#e63946")

	func _init(col: Color = Color("#38101e")) -> void:
		# Ghost outline with bottom wavy ruffle
		var pts := PackedVector2Array([
			Vector2(-35, 40), Vector2(-35, -20), Vector2(-20, -50),
			Vector2(0, -56), Vector2(20, -50), Vector2(35, -20),
			Vector2(35, 40), Vector2(25, 32), Vector2(12, 40),
			Vector2(0, 32), Vector2(-12, 40), Vector2(-25, 32), Vector2(-35, 40)
		])
		ghost_stroke = HandDrawnStroke.new(pts, col, 3.2, 2.0)
		add_child(ghost_stroke)
		
		# Ghost cute eyes
		var e1 := HandDrawnStroke.new(PackedVector2Array([Vector2(-14, -16), Vector2(-14, -10)]), col, 3.5, 0.8)
		var e2 := HandDrawnStroke.new(PackedVector2Array([Vector2(14, -16), Vector2(14, -10)]), col, 3.5, 0.8)
		var mouth := HandDrawnStroke.new(PackedVector2Array([Vector2(0, -4), Vector2(0, 2)]), col, 3.0, 0.8)
		add_child(e1); add_child(e2); add_child(mouth)
		
		# Handwritten label: "HORROR MOVIE?" in Patrick Hand
		label = HandwrittenText.new("HORROR MOVIE?", 28.0, col)
		label.align = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(0, 65)
		add_child(label)
		
		# Red marker energetic X crossout strokes
		cross_stroke1 = HandDrawnStroke.new(PackedVector2Array([Vector2(-60, -70), Vector2(60, 60)]), red_ink, 5.0, 2.5)
		cross_stroke2 = HandDrawnStroke.new(PackedVector2Array([Vector2(60, -70), Vector2(-60, 60)]), red_ink, 5.0, 2.5)
		cross_stroke1.visible = false
		cross_stroke2.visible = false
		add_child(cross_stroke1); add_child(cross_stroke2)

	func _draw() -> void:
		# White sheet fill for ghost body
		var body_fill := PackedVector2Array([
			Vector2(-33, 38), Vector2(-33, -19), Vector2(-19, -48),
			Vector2(0, -54), Vector2(19, -48), Vector2(33, -19),
			Vector2(33, 38), Vector2(24, 30), Vector2(12, 38),
			Vector2(0, 30), Vector2(-12, 38), Vector2(-24, 30)
		])
		draw_colored_polygon(body_fill, Color("#ffffff", 0.95))

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		ghost_stroke.animate_draw_on(duration * 0.7)
		label.animate_draw_on(duration * 0.6)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

	func trigger_crossout(duration: float = 0.3) -> Signal:
		cross_stroke1.visible = true
		cross_stroke2.visible = true
		cross_stroke1.animate_draw_on(duration * 0.5)
		var tw := create_tween()
		tw.tween_interval(duration * 0.4)
		tw.tween_callback(func(): cross_stroke2.animate_draw_on(duration * 0.5))
		tw.tween_interval(duration * 0.5)
		return tw.finished

# --- BEAT 2 / 8: HAND-DRAWN YOUTUBE LOGO ---
class DoodleYouTube extends Node2D:
	var label: HandwrittenText
	var red_col: Color = Color("#ff0033")
	var ink_col: Color = Color("#38101e")

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		# Rounded TV rectangle
		var pts := PackedVector2Array([
			Vector2(-65, -38), Vector2(65, -38), Vector2(75, -28), Vector2(75, 28),
			Vector2(65, 38), Vector2(-65, 38), Vector2(-75, 28), Vector2(-75, -28), Vector2(-65, -38)
		])
		add_child(HandDrawnStroke.new(pts, red_col, 4.0, 2.2))
		
		# Play triangle
		var tri := PackedVector2Array([
			Vector2(-14, -20), Vector2(24, 0), Vector2(-14, 20), Vector2(-14, -20)
		])
		add_child(HandDrawnStroke.new(tri, red_col, 3.2, 1.4))
		
		# Label underneath: "<- The real monster"
		var arrow := HandDrawnArrow.new(Vector2(110, 40), Vector2(80, 20), "<- The real monster", ink_col, true)
		add_child(arrow)

	func _draw() -> void:
		# Red play button fill
		draw_rect(Rect2(-68, -35, 136, 70), Color("#ff0033", 0.15))
		# White triangle fill
		draw_colored_polygon(PackedVector2Array([Vector2(-12, -18), Vector2(22, 0), Vector2(-12, 18)]), Color("#ffffff"))

# --- BEAT 3: SHRIMP POSTURE GAG (Directly from Pegi yt_003.png) ---
class DoodleShrimpPosture extends Node2D:
	var arrow: HandDrawnArrow
	var shrimp_col: Color = Color("#e76f51") # Cooked shrimp coral
	var ink_col: Color = Color("#38101e")

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		
		# Curled shrimp body segments on an office chair
		var shrimp_spine := PackedVector2Array([
			Vector2(-35, 20), Vector2(-45, -5), Vector2(-38, -35),
			Vector2(-15, -50), Vector2(15, -45), Vector2(32, -25),
			Vector2(38, -5), Vector2(30, 15)
		])
		add_child(HandDrawnStroke.new(shrimp_spine, shrimp_col, 5.5, 2.5))
		
		# Shrimp ribs / segments
		for i in range(4):
			var a := float(i) * 0.4 - 0.6
			var p1 := Vector2(sin(a) * 32, -cos(a) * 32 - 15)
			var p2 := p1 + Vector2(cos(a) * 16, sin(a) * 16)
			add_child(HandDrawnStroke.new(PackedVector2Array([p1, p2]), shrimp_col, 3.0, 1.4))
			
		# Tail fin
		var tail := PackedVector2Array([Vector2(30, 15), Vector2(48, 12), Vector2(40, 26), Vector2(48, 38), Vector2(28, 22)])
		add_child(HandDrawnStroke.new(tail, shrimp_col, 2.8, 1.6))
		
		# Office chair base underneath
		var chair_pts := PackedVector2Array([
			Vector2(10, 30), Vector2(10, 58), Vector2(-22, 58), Vector2(42, 58)
		])
		add_child(HandDrawnStroke.new(chair_pts, ink_col, 3.0, 1.5))
		
		# Mini drawing desk in front of shrimp
		var desk_pts := PackedVector2Array([
			Vector2(-65, -10), Vector2(-30, -10), Vector2(-48, -10), Vector2(-48, 58)
		])
		add_child(HandDrawnStroke.new(desk_pts, ink_col, 2.8, 1.5))
		
		# Hand-drawn arrow pointing to shrimp with Patrick Hand text: "<- My posture"
		arrow = HandDrawnArrow.new(Vector2(95, -45), Vector2(35, -45), "My posture", ink_col, true)
		add_child(arrow)

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

# --- BEAT 4: 2:00 AM REFRESH & "7 VIEWS" + PHONE ---
class DoodleViewsRefresh extends Node2D:
	var label_views: HandwrittenText
	var label_phone: HandwrittenText
	var refresh_stroke: HandDrawnStroke
	var phone_stroke: HandDrawnStroke
	var pie_stroke: HandDrawnStroke
	var chalk_col: Color = Color("#f8f9fa")
	var coral_col: Color = Color("#ff6b6b")

	func _init(col: Color = Color("#f8f9fa")) -> void:
		chalk_col = col
		
		# Big handwritten "7 views" in Patrick Hand
		label_views = HandwrittenText.new("7 views", 52.0, chalk_col)
		label_views.position = Vector2(-90, -70)
		add_child(label_views)
		
		# Circular refresh arrow icon
		var refresh_pts := PackedVector2Array()
		for i in range(14):
			var a := float(i) * (PI * 1.5) / 13.0 - PI * 0.2
			refresh_pts.append(Vector2(75 + cos(a) * 26, -55 + sin(a) * 26))
		refresh_stroke = HandDrawnStroke.new(refresh_pts, chalk_col, 3.2, 1.8)
		add_child(refresh_stroke)
		# Arrow barb on refresh circle
		var arrow_barb := HandDrawnStroke.new(PackedVector2Array([Vector2(95, -75), Vector2(105, -60), Vector2(90, -50)]), chalk_col, 3.2, 1.4)
		add_child(arrow_barb)
		
		# Pie Chart: 50% / 50%
		var pie_center := Vector2(-45, 45)
		var pie_pts := PackedVector2Array()
		for i in range(17):
			var a := float(i) * TAU / 16.0
			pie_pts.append(pie_center + Vector2(cos(a) * 32, sin(a) * 32))
		pie_stroke = HandDrawnStroke.new(pie_pts, chalk_col, 2.8, 1.8)
		add_child(pie_stroke)
		# Pie slice divider
		var divider := HandDrawnStroke.new(PackedVector2Array([pie_center + Vector2(0, -32), pie_center + Vector2(0, 32)]), chalk_col, 2.6, 1.2)
		add_child(divider)
		
		# Smartphone outline vibrating
		var phone_pos := Vector2(65, 45)
		var phone_pts := PackedVector2Array([
			Vector2(-22, -38), Vector2(22, -38), Vector2(22, 38), Vector2(-22, 38), Vector2(-22, -38)
		])
		for i in range(phone_pts.size()):
			phone_pts[i] += phone_pos
		phone_stroke = HandDrawnStroke.new(phone_pts, chalk_col, 2.8, 1.8)
		add_child(phone_stroke)
		
		# Vibrating buzz marks around phone
		var b1 := HandDrawnStroke.new(PackedVector2Array([phone_pos + Vector2(-30, -15), phone_pos + Vector2(-36, -5)]), coral_col, 2.6, 1.2)
		var b2 := HandDrawnStroke.new(PackedVector2Array([phone_pos + Vector2(30, -15), phone_pos + Vector2(36, -5)]), coral_col, 2.6, 1.2)
		var b3 := HandDrawnStroke.new(PackedVector2Array([phone_pos + Vector2(0, 48), phone_pos + Vector2(10, 56), phone_pos + Vector2(-6, 62)]), coral_col, 2.6, 1.4)
		add_child(b1); add_child(b2); add_child(b3)
		
		# Label: "half from my phone" in Caveat cursive
		label_phone = HandwrittenText.new("half from my phone", 28.0, coral_col, true)
		label_phone.position = Vector2(-75, 110)
		add_child(label_phone)

	func _draw() -> void:
		# Red hatching on half of pie chart
		var pie_center := Vector2(-45, 45)
		for h in range(-3, 4):
			var hy := float(h) * 8.0
			var hx := sqrt(maxf(0.0, 30.0 * 30.0 - hy * hy))
			draw_line(pie_center + Vector2(-hx, hy), pie_center + Vector2(0, hy), Color(coral_col.r, coral_col.g, coral_col.b, 0.75), 2.2)

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

# --- BEAT 6: TIMELINE CHAOS & SOFTWARE BUG ---
class DoodleTimelineChaos extends Node2D:
	var label_chaos: HandwrittenText
	var ink_col: Color = Color("#38101e")
	var red_col: Color = Color("#d90429")

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		
		# Tangled keyframe tracks
		var t1 := HandDrawnStroke.new(PackedVector2Array([
			Vector2(-90, 0), Vector2(-50, 15), Vector2(-20, -25), Vector2(10, 10),
			Vector2(40, -15), Vector2(70, 20), Vector2(100, -5)
		]), ink_col, 3.2, 2.5)
		
		var t2 := HandDrawnStroke.new(PackedVector2Array([
			Vector2(-85, 20), Vector2(-40, -10), Vector2(0, 35), Vector2(30, -25),
			Vector2(65, 15), Vector2(95, 0)
		]), red_col, 2.8, 2.5)
		add_child(t1); add_child(t2)
		
		# Bug / glitch square highlight on timeline
		var box := HandDrawnStroke.new(PackedVector2Array([
			Vector2(-15, -28), Vector2(5, -28), Vector2(5, -8), Vector2(-15, -8), Vector2(-15, -28)
		]), red_col, 2.5, 1.4)
		add_child(box)
		
		# Arrow pointing to the tangled glitch: "layer 84"
		var arrow := HandDrawnArrow.new(Vector2(40, -45), Vector2(0, -28), "layer 84", ink_col)
		add_child(arrow)
		
		# Label: "pure chaos" in Patrick Hand
		label_chaos = HandwrittenText.new("pure chaos", 38.0, red_col, true)
		label_chaos.align = HORIZONTAL_ALIGNMENT_CENTER
		label_chaos.position = Vector2(0, 50)
		add_child(label_chaos)

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

# --- BEAT 7: WARM SKETCHED HEART ("i care a lot ♡") ---
class DoodleHeartCare extends Node2D:
	var label: HandwrittenText
	var heart_stroke: HandDrawnStroke
	var heart_col: Color = Color("#ff6584") # Watercolor rose
	var ink_col: Color = Color("#38101e")
	var _rays: Array[HandDrawnStroke] = []

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		
		# Expressive hand-drawn heart geometry
		var heart_pts := PackedVector2Array([
			Vector2(0, -15), Vector2(-18, -42), Vector2(-42, -36), Vector2(-50, -15),
			Vector2(-42, 10), Vector2(-22, 30), Vector2(0, 52),
			Vector2(22, 30), Vector2(42, 10), Vector2(50, -15), Vector2(42, -36),
			Vector2(18, -42), Vector2(0, -15)
		])
		heart_stroke = HandDrawnStroke.new(heart_pts, heart_col, 4.0, 2.5)
		add_child(heart_stroke)
		
		# Radiating shine ticks
		var r1 := HandDrawnStroke.new(PackedVector2Array([Vector2(-45, -45), Vector2(-58, -58)]), heart_col, 2.8, 1.5)
		var r2 := HandDrawnStroke.new(PackedVector2Array([Vector2(0, -55), Vector2(0, -70)]), heart_col, 2.8, 1.5)
		var r3 := HandDrawnStroke.new(PackedVector2Array([Vector2(45, -45), Vector2(58, -58)]), heart_col, 2.8, 1.5)
		add_child(r1); add_child(r2); add_child(r3)
		_rays.append_array([r1, r2, r3])
		
		# Handwritten cursive in Caveat-Bold: "i care a lot ♡"
		label = HandwrittenText.new("i care a lot ♡", 32.0, ink_col, true)
		label.align = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(0, 80)
		add_child(label)

	func _draw() -> void:
		# Soft watercolor pink fill for the heart
		var fill_pts := PackedVector2Array([
			Vector2(0, -12), Vector2(-16, -38), Vector2(-38, -32), Vector2(-45, -14),
			Vector2(-38, 8), Vector2(-20, 26), Vector2(0, 46),
			Vector2(20, 26), Vector2(38, 8), Vector2(45, -14), Vector2(38, -32),
			Vector2(16, -38)
		])
		draw_colored_polygon(fill_pts, Color(heart_col.r, heart_col.g, heart_col.b, 0.35))

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		heart_stroke.animate_draw_on(duration * 0.7)
		label.animate_draw_on(duration * 0.6)
		for r in _rays:
			r.animate_draw_on(duration * 0.5)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

	func fade_out(duration: float = 0.25) -> Signal:
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, duration)
		tw.tween_callback(queue_free)
		return tw.finished

# --- BEAT 8: NEXT VIDEO PREVIEW CARD ---
class DoodleNextVideo extends Node2D:
	var label: HandwrittenText
	var ink_col: Color = Color("#38101e")

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		# Thumbnail card
		var card_pts := PackedVector2Array([
			Vector2(-70, -42), Vector2(70, -42), Vector2(70, 42), Vector2(-70, 42), Vector2(-70, -42)
		])
		add_child(HandDrawnStroke.new(card_pts, ink_col, 3.2, 2.0))
		
		# Play button triangle inside card
		var tri := PackedVector2Array([Vector2(-12, -16), Vector2(16, 0), Vector2(-12, 16), Vector2(-12, -16)])
		add_child(HandDrawnStroke.new(tri, Color("#e63946"), 3.0, 1.2))
		
		# Little red plus badge on top corner
		var p1 := HandDrawnStroke.new(PackedVector2Array([Vector2(70, -42), Vector2(82, -42)]), Color("#e63946"), 3.0, 1.0)
		var p2 := HandDrawnStroke.new(PackedVector2Array([Vector2(76, -48), Vector2(76, -36)]), Color("#e63946"), 3.0, 1.0)
		add_child(p1); add_child(p2)
		
		# Label: "NEXT VIDEO ->" in Patrick Hand
		label = HandwrittenText.new("NEXT VIDEO ->", 28.0, ink_col)
		label.align = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(0, 68)
		add_child(label)

	func _draw() -> void:
		draw_rect(Rect2(-68, -40, 136, 80), Color("#ffffff", 0.95))

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

# --- BEAT 9: CASUAL SIGNOFF LETTERING ("wish me luck! ♡", "BYE!! :D") ---
class DoodleSignoff extends Node2D:
	var label1: HandwrittenText
	var label2: HandwrittenText
	var ink_col: Color = Color("#38101e")

	func _init(col: Color = Color("#38101e")) -> void:
		ink_col = col
		
		# Handwritten: "wish me luck! ♡" in Patrick Hand
		label1 = HandwrittenText.new("wish me luck! ♡", 32.0, ink_col)
		label1.align = HORIZONTAL_ALIGNMENT_CENTER
		label1.position = Vector2(0, -22)
		add_child(label1)
		
		# Handwritten: "BYE!! :D" in bold coral pink
		label2 = HandwrittenText.new("BYE!! :D", 42.0, Color("#ff6584"))
		label2.align = HORIZONTAL_ALIGNMENT_CENTER
		label2.position = Vector2(0, 30)
		add_child(label2)

	func pop_in(duration: float = 0.35) -> Signal:
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		label1.animate_draw_on(duration * 0.5)
		label2.animate_draw_on(duration * 0.5)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, duration * 0.5)
		return tw.finished

# =============================================================================
# FACTORY SPAWN METHODS
# =============================================================================

static func spawn_dropdown_menu(parent: Node2D, pos: Vector2) -> DoodleDropdownMenu:
	var menu := DoodleDropdownMenu.new()
	menu.position = pos
	parent.add_child(menu)
	menu.pop_in(0.35)
	return menu

static func spawn_cat_mascot(parent: Node2D, pos: Vector2) -> DoodleCatMascot:
	var cat := DoodleCatMascot.new()
	cat.position = pos
	parent.add_child(cat)
	return cat

static func spawn_ghost_card(parent: Node2D, pos: Vector2) -> DoodleGhost:
	var ghost := DoodleGhost.new()
	ghost.position = pos
	parent.add_child(ghost)
	ghost.pop_in(0.35)
	return ghost

static func spawn_youtube_card(parent: Node2D, pos: Vector2) -> DoodleYouTube:
	var yt := DoodleYouTube.new()
	yt.position = pos
	parent.add_child(yt)
	return yt

static func spawn_shrimp_posture(parent: Node2D, pos: Vector2) -> DoodleShrimpPosture:
	var s := DoodleShrimpPosture.new()
	s.position = pos
	parent.add_child(s)
	s.pop_in(0.35)
	return s

static func spawn_views_refresh(parent: Node2D, pos: Vector2) -> DoodleViewsRefresh:
	var v := DoodleViewsRefresh.new()
	v.position = pos
	parent.add_child(v)
	v.pop_in(0.35)
	return v

static func spawn_timeline_chaos(parent: Node2D, pos: Vector2) -> DoodleTimelineChaos:
	var c := DoodleTimelineChaos.new()
	c.position = pos
	parent.add_child(c)
	c.pop_in(0.35)
	return c

static func spawn_heart_card(parent: Node2D, pos: Vector2) -> DoodleHeartCare:
	var heart := DoodleHeartCare.new()
	heart.position = pos
	parent.add_child(heart)
	heart.pop_in(0.35)
	return heart

static func spawn_next_video(parent: Node2D, pos: Vector2) -> DoodleNextVideo:
	var nv := DoodleNextVideo.new()
	nv.position = pos
	parent.add_child(nv)
	nv.pop_in(0.35)
	return nv

static func spawn_signoff(parent: Node2D, pos: Vector2) -> DoodleSignoff:
	var so := DoodleSignoff.new()
	so.position = pos
	parent.add_child(so)
	so.pop_in(0.35)
	return so

# =============================================================================
# 5. COMIC ACCENTS & MICRO-EXPRESSION FX
# =============================================================================

class ComicSweatDrop extends Node2D:
	func _init(dur: float = 1.4) -> void:
		z_index = 10
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, 0.1)
		tw.tween_property(self, "position:y", position.y + 16.0, dur * 0.7).set_delay(0.2)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.3).set_delay(dur - 0.3)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		var pts := PackedVector2Array([
			Vector2(0, -12), Vector2(6, -2), Vector2(7, 4), Vector2(4, 9),
			Vector2(0, 11), Vector2(-4, 9), Vector2(-7, 4), Vector2(-6, -2)
		])
		draw_colored_polygon(pts, Color("#70d6ff"))
		draw_polyline(pts, Color("#38101e"), 1.8)
		draw_circle(Vector2(2, 2), 2.0, Color("#ffffff"))

class ComicQuestionMark extends Node2D:
	func _init(dur: float = 1.1) -> void:
		z_index = 10
		var t := HandwrittenText.new("?", 36.0, Color("#ffb703"))
		add_child(t)
		scale = Vector2(0.2, 0.2)
		modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.1, 1.1), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 1.0, 0.1)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		tw.tween_property(self, "position:y", position.y - 12.0, dur * 0.6)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.3).set_delay(dur - 0.3)
		tw.tween_callback(queue_free)

class ComicStressLines extends Node2D:
	func _init(dur: float = 1.4) -> void:
		z_index = 10
		for i in range(4):
			var x := float(i - 2) * 8.0
			var line := HandDrawnStroke.new(PackedVector2Array([Vector2(x, 0), Vector2(x, 26)]), Color("#4361ee"), 2.0, 1.2)
			add_child(line)
			line.animate_draw_on(0.25)
		var tw := create_tween()
		tw.tween_interval(dur - 0.3)
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)

class ComicBrainSpiral extends Node2D:
	func _init(dur: float = 2.2) -> void:
		z_index = 10
		var spiral_pts := PackedVector2Array()
		for i in range(24):
			var a := float(i) * 0.65
			var r := float(i) * 1.8 + 4.0
			spiral_pts.append(Vector2(cos(a) * r, sin(a) * r * 0.7))
		var stroke := HandDrawnStroke.new(spiral_pts, Color("#38101e"), 2.4, 1.5)
		add_child(stroke)
		stroke.animate_draw_on(0.4)
		var tw := create_tween()
		tw.tween_property(self, "rotation", deg_to_rad(360), dur)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.4).set_delay(dur - 0.4)
		tw.tween_callback(queue_free)

class ComicVeinMark extends Node2D:
	func _init(dur: float = 1.3) -> void:
		z_index = 10
		scale = Vector2(0.2, 0.2)
		var col := Color("#e63946")
		var s1 := HandDrawnStroke.new(PackedVector2Array([Vector2(-12, -8), Vector2(0, -4), Vector2(12, -8)]), col, 3.0, 1.0)
		var s2 := HandDrawnStroke.new(PackedVector2Array([Vector2(-12, 8), Vector2(0, 4), Vector2(12, 8)]), col, 3.0, 1.0)
		var s3 := HandDrawnStroke.new(PackedVector2Array([Vector2(-8, -12), Vector2(-4, 0), Vector2(-8, 12)]), col, 3.0, 1.0)
		var s4 := HandDrawnStroke.new(PackedVector2Array([Vector2(8, -12), Vector2(4, 0), Vector2(8, 12)]), col, 3.0, 1.0)
		add_child(s1); add_child(s2); add_child(s3); add_child(s4)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK)
		tw.tween_property(self, "scale", Vector2(0.9, 0.9), 0.15)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
		tw.tween_interval(dur - 0.6)
		tw.tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(queue_free)

class ComicExclamation extends Node2D:
	func _init(has_q: bool = false, is_double: bool = false, dur: float = 1.0) -> void:
		z_index = 10
		var txt := "?!" if has_q else ("!!" if is_double else "!")
		var t := HandwrittenText.new(txt, 38.0, Color("#e63946"))
		add_child(t)
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		tw.tween_interval(dur - 0.4)
		tw.tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(queue_free)

class ComicSparkles extends Node2D:
	func _init(dur: float = 1.4) -> void:
		z_index = 10
		for i in range(3):
			var sp := Node2D.new()
			var off := Vector2(randf_range(-35, 35), randf_range(-35, 35))
			sp.position = off
			add_child(sp)
			# 4-point diamond star
			var star := PackedVector2Array([
				Vector2(0, -10), Vector2(3, -3), Vector2(10, 0), Vector2(3, 3),
				Vector2(0, 10), Vector2(-3, 3), Vector2(-10, 0), Vector2(-3, -3)
			])
			var col := Color("#ffd166")
			var poly := Polygon2D.new()
			poly.polygon = star
			poly.color = col
			sp.add_child(poly)
			sp.scale = Vector2.ZERO
			var tw := create_tween()
			tw.tween_interval(float(i) * 0.1)
			tw.tween_property(sp, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
			tw.tween_property(sp, "rotation", deg_to_rad(45), dur * 0.6)
			tw.parallel().tween_property(sp, "scale", Vector2.ZERO, 0.2).set_delay(dur - 0.4)
		var main_tw := create_tween()
		main_tw.tween_interval(dur)
		main_tw.tween_callback(queue_free)

class ComicBurstRays extends Node2D:
	func _init(dur: float = 0.8) -> void:
		z_index = 8
		var count := 8
		for i in range(count):
			var a := float(i) * TAU / float(count)
			var r1 := 50.0
			var r2 := 80.0
			var p1 := Vector2(cos(a) * r1, sin(a) * r1)
			var p2 := Vector2(cos(a) * r2, sin(a) * r2)
			var ray := HandDrawnStroke.new(PackedVector2Array([p1, p2]), Color("#ffbe0b"), 2.8, 1.0)
			add_child(ray)
			ray.animate_draw_on(0.2)
		var tw := create_tween()
		tw.tween_interval(dur - 0.25)
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)

class ComicSoulFloat extends Node2D:
	func _init(dur: float = 2.0) -> void:
		z_index = 10
		scale = Vector2(0.3, 0.3)
		modulate.a = 0.0
		var soul_pts := PackedVector2Array([
			Vector2(-12, -18), Vector2(0, -26), Vector2(12, -18),
			Vector2(14, 0), Vector2(8, 16), Vector2(0, 24), Vector2(-8, 16), Vector2(-14, 0)
		])
		var stroke := HandDrawnStroke.new(soul_pts, Color(0.6, 0.7, 0.9, 0.8), 2.2, 1.5)
		add_child(stroke)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.8, 0.3)
		tw.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)
		tw.tween_property(self, "position:y", position.y - 45.0, dur * 0.8)
		tw.parallel().tween_property(self, "position:x", position.x + sin(dur) * 15.0, dur * 0.8)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.4).set_delay(dur - 0.4)
		tw.tween_callback(queue_free)

class ComicEmoticonBubble extends Node2D:
	func _init(face: String = ">_<", dur: float = 1.3) -> void:
		z_index = 10
		var bubble_pts := PackedVector2Array([
			Vector2(-35, -22), Vector2(35, -22), Vector2(35, 22), Vector2(8, 22),
			Vector2(0, 32), Vector2(-4, 22), Vector2(-35, 22), Vector2(-35, -22)
		])
		add_child(HandDrawnStroke.new(bubble_pts, Color("#38101e"), 2.4, 1.5))
		var txt := HandwrittenText.new(face, 26.0, Color("#38101e"))
		txt.align = HORIZONTAL_ALIGNMENT_CENTER
		txt.position = Vector2(0, -10)
		add_child(txt)
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK)
		tw.tween_interval(dur - 0.4)
		tw.tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		draw_rect(Rect2(-33, -20, 66, 40), Color("#ffffff", 0.95))

class ComicLightbulb extends Node2D:
	func _init(dur: float = 1.3) -> void:
		z_index = 10
		var bulb_pts := PackedVector2Array([
			Vector2(-16, -10), Vector2(-18, -25), Vector2(0, -38), Vector2(18, -25),
			Vector2(16, -10), Vector2(10, 5), Vector2(-10, 5), Vector2(-16, -10)
		])
		add_child(HandDrawnStroke.new(bulb_pts, Color("#ffb703"), 2.8, 1.4))
		# Base
		add_child(HandDrawnStroke.new(PackedVector2Array([Vector2(-8, 9), Vector2(8, 9)]), Color("#38101e"), 2.2, 1.0))
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_BACK)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		tw.tween_interval(dur - 0.4)
		tw.tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		draw_circle(Vector2(0, -22), 16.0, Color("#ffe494", 0.9))


class DoodlePanicMeter extends Node2D:
	var needle: Node2D
	var _time: float = 0.0

	func _init(dur: float = 2.0) -> void:
		z_index = 8
		var arc_pts := PackedVector2Array()
		for i in range(17):
			var a: float = PI + float(i) / 16.0 * PI
			arc_pts.append(Vector2(cos(a) * 65.0, sin(a) * 65.0))
		add_child(HandDrawnStroke.new(arc_pts, Color("#38101e"), 3.5, 1.8))
		needle = Node2D.new()
		var n_pts := PackedVector2Array([Vector2.ZERO, Vector2(55, 0)])
		needle.add_child(HandDrawnStroke.new(n_pts, Color("#d93b2b"), 3.2, 1.0))
		needle.rotation = deg_to_rad(-25.0)
		add_child(needle)
		var peg := HandDrawnStroke.new(PackedVector2Array([Vector2(-4, 0), Vector2(4, 0)]), Color("#38101e"), 4.0, 0.5)
		add_child(peg)
		var label := HandwrittenText.new("PANIC LEVEL: 100%", 20.0, Color("#d93b2b"), false, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(0, 15)
		add_child(label)
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
		tw.tween_interval(maxf(0.1, dur - 0.5))
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)

	func _process(delta: float) -> void:
		_time += delta
		if is_instance_valid(needle):
			needle.rotation = deg_to_rad(-25.0) + sin(_time * 45.0) * deg_to_rad(6.5)

	func _draw() -> void:
		draw_arc(Vector2.ZERO, 60.0, PI, PI + PI * 0.4, 8, Color("#52b788", 0.7), 6.0)
		draw_arc(Vector2.ZERO, 60.0, PI + PI * 0.4, PI + PI * 0.75, 8, Color("#f4a261", 0.7), 6.0)
		draw_arc(Vector2.ZERO, 60.0, PI + PI * 0.75, TAU, 8, Color("#e63946", 0.8), 8.0)

class DoodleStickyNote extends Node2D:
	func _init(note_text: String, bg_col: Color = Color("#fff3b0"), dur: float = 2.5) -> void:
		z_index = 9
		rotation = deg_to_rad(randf_range(-4.0, 4.0))
		var w: float = 140.0
		var h: float = 90.0
		var outline_pts := PackedVector2Array([
			Vector2(-w*0.5, -h*0.5), Vector2(w*0.5, -h*0.5),
			Vector2(w*0.5, h*0.5 - 12), Vector2(w*0.5 - 12, h*0.5),
			Vector2(-w*0.5, h*0.5), Vector2(-w*0.5, -h*0.5)
		])
		add_child(HandDrawnStroke.new(outline_pts, Color("#38101e"), 2.6, 1.4))
		var curl_pts := PackedVector2Array([
			Vector2(w*0.5 - 12, h*0.5), Vector2(w*0.5 - 12, h*0.5 - 12), Vector2(w*0.5, h*0.5 - 12)
		])
		add_child(HandDrawnStroke.new(curl_pts, Color("#38101e"), 2.0, 0.8))
		var tape_pts := PackedVector2Array([Vector2(-20, -h*0.5 - 6), Vector2(20, -h*0.5 - 6)])
		add_child(HandDrawnStroke.new(tape_pts, Color("#d4a373", 0.85), 7.0, 1.0))
		var txt := HandwrittenText.new(note_text, 19.0, Color("#2b111e"), false, HORIZONTAL_ALIGNMENT_CENTER)
		txt.position = Vector2(0, -6)
		add_child(txt)
		scale = Vector2(0.3, 0.3)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.05, 1.05), 0.18).set_trans(Tween.TRANS_BACK)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		tw.tween_interval(maxf(0.1, dur - 0.5))
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		draw_rect(Rect2(-70, -45, 140, 90), Color("#fff3b0", 0.95))
		draw_rect(Rect2(-67, -42, 140, 90), Color(0, 0, 0, 0.08))

class DoodleActionBubble extends Node2D:
	func _init(action_str: String = "*GASP*", col: Color = Color("#d93b2b"), dur: float = 1.0) -> void:
		z_index = 12
		rotation = deg_to_rad(randf_range(-6.0, 6.0))
		var pts := PackedVector2Array()
		var n: int = 12
		var rad_out: float = 52.0
		var rad_in: float = 34.0
		for i in range(n * 2 + 1):
			var a: float = float(i) / float(n * 2) * TAU
			var r: float = rad_out if (i % 2 == 0) else rad_in
			pts.append(Vector2(cos(a) * r, sin(a) * r))
		add_child(HandDrawnStroke.new(pts, Color("#38101e"), 3.2, 1.5))
		var txt := HandwrittenText.new(action_str, 24.0, col, false, HORIZONTAL_ALIGNMENT_CENTER)
		txt.position = Vector2(0, -2)
		add_child(txt)
		scale = Vector2(0.1, 0.1)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
		tw.tween_interval(maxf(0.1, dur - 0.4))
		tw.tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		draw_circle(Vector2.ZERO, 38.0, Color("#ffffff", 0.95))

class DoodleHeartBurst extends Node2D:
	var _hearts: Array[Node2D] = []
	
	func _init(dur: float = 2.0) -> void:
		z_index = 8
		for i in range(5):
			var h_node := Node2D.new()
			var heart_pts := PackedVector2Array([
				Vector2(0, -5), Vector2(-7, -15), Vector2(-15, -12), Vector2(-15, 0),
				Vector2(0, 15), Vector2(15, 0), Vector2(15, -12), Vector2(7, -15), Vector2(0, -5)
			])
			var sc: float = randf_range(0.6, 1.1)
			var scaled_pts := PackedVector2Array()
			for p in heart_pts:
				scaled_pts.append(p * sc)
			h_node.add_child(HandDrawnStroke.new(scaled_pts, Color("#e63946"), 2.2, 1.0))
			h_node.position = Vector2(randf_range(-30, 30), randf_range(-10, 10))
			add_child(h_node)
			_hearts.append(h_node)
			
			var tw := create_tween()
			var dest := h_node.position + Vector2(randf_range(-40, 40), randf_range(-80, -140))
			tw.tween_property(h_node, "position", dest, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(h_node, "modulate:a", 0.0, dur * 0.4).set_delay(dur * 0.6)
		
		var clean_tw := create_tween()
		clean_tw.tween_interval(dur)
		clean_tw.tween_callback(queue_free)

class DoodleFacepalmChibi extends Node2D:
	func _init(dur: float = 2.2) -> void:
		z_index = 8
		var card_pts := PackedVector2Array([
			Vector2(-90, -70), Vector2(90, -70), Vector2(90, 70), Vector2(-90, 70), Vector2(-90, -70)
		])
		add_child(HandDrawnStroke.new(card_pts, Color("#38101e"), 2.8, 1.5))
		var head_pts := PackedVector2Array()
		for i in range(17):
			var a: float = float(i) / 16.0 * TAU
			head_pts.append(Vector2(-20, -15) + Vector2(cos(a) * 22, sin(a) * 22))
		add_child(HandDrawnStroke.new(head_pts, Color("#38101e"), 2.6, 1.2))
		var arm_pts := PackedVector2Array([Vector2(-35, 10), Vector2(-40, -10), Vector2(-25, -20)])
		add_child(HandDrawnStroke.new(arm_pts, Color("#38101e"), 2.8, 1.0))
		var body_pts := PackedVector2Array([Vector2(-20, 7), Vector2(-20, 45)])
		add_child(HandDrawnStroke.new(body_pts, Color("#38101e"), 3.0, 1.2))
		var cap := HandwrittenText.new("(why am i like this)", 18.0, Color("#d93b2b"), true, HORIZONTAL_ALIGNMENT_CENTER)
		cap.position = Vector2(0, 48)
		add_child(cap)
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK)
		tw.tween_interval(maxf(0.1, dur - 0.5))
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		draw_rect(Rect2(-90, -70, 180, 140), Color("#fffbf5", 0.96))

class DoodleCoffeeMug extends Node2D:
	var _steam1: Node2D
	var _steam2: Node2D
	var _time: float = 0.0

	func _init(dur: float = 3.5) -> void:
		z_index = 8
		var mug_pts := PackedVector2Array([
			Vector2(-22, -18), Vector2(22, -18), Vector2(18, 22), Vector2(-18, 22), Vector2(-22, -18)
		])
		add_child(HandDrawnStroke.new(mug_pts, Color("#38101e"), 2.8, 1.2))
		var handle_pts := PackedVector2Array([
			Vector2(22, -10), Vector2(34, -5), Vector2(34, 12), Vector2(18, 15)
		])
		add_child(HandDrawnStroke.new(handle_pts, Color("#38101e"), 2.4, 1.0))
		var heart_pts := PackedVector2Array([
			Vector2(0, 0), Vector2(-5, -6), Vector2(-10, -3), Vector2(-7, 4), Vector2(0, 10),
			Vector2(7, 4), Vector2(10, -3), Vector2(5, -6), Vector2(0, 0)
		])
		add_child(HandDrawnStroke.new(heart_pts, Color("#e63946"), 2.0, 0.8))
		_steam1 = Node2D.new()
		var s1_pts := PackedVector2Array([Vector2(-8, -22), Vector2(-12, -35), Vector2(-6, -48), Vector2(-10, -60)])
		_steam1.add_child(HandDrawnStroke.new(s1_pts, Color("#a8dadc", 0.8), 2.0, 1.2))
		add_child(_steam1)
		_steam2 = Node2D.new()
		var s2_pts := PackedVector2Array([Vector2(8, -22), Vector2(12, -35), Vector2(6, -48), Vector2(10, -60)])
		_steam2.add_child(HandDrawnStroke.new(s2_pts, Color("#a8dadc", 0.8), 2.0, 1.2))
		add_child(_steam2)
		var label := HandwrittenText.new("caffeine = sanity ♡", 16.0, Color("#457b9d"), true, HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(0, 32)
		add_child(label)
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK)
		tw.tween_interval(maxf(0.1, dur - 0.5))
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)

	func _process(delta: float) -> void:
		_time += delta
		if is_instance_valid(_steam1):
			_steam1.position.x = sin(_time * 4.0) * 3.0
		if is_instance_valid(_steam2):
			_steam2.position.x = cos(_time * 4.0) * 3.0

	func _draw() -> void:
		draw_rect(Rect2(-20, -16, 40, 36), Color("#faf0ca", 0.95))

class DoodleNotificationBuzz extends Node2D:
	func _init(dur: float = 2.0) -> void:
		z_index = 9
		var phone_pts := PackedVector2Array([
			Vector2(-25, -45), Vector2(25, -45), Vector2(25, 45), Vector2(-25, 45), Vector2(-25, -45)
		])
		add_child(HandDrawnStroke.new(phone_pts, Color("#38101e"), 3.0, 1.4))
		var screen_pts := PackedVector2Array([
			Vector2(-20, -35), Vector2(20, -35), Vector2(20, 35), Vector2(-20, 35), Vector2(-20, -35)
		])
		add_child(HandDrawnStroke.new(screen_pts, Color("#457b9d"), 2.0, 0.8))
		var wave_l := PackedVector2Array([Vector2(-35, -20), Vector2(-42, 0), Vector2(-35, 20)])
		add_child(HandDrawnStroke.new(wave_l, Color("#e63946"), 2.4, 1.2))
		var wave_r := PackedVector2Array([Vector2(35, -20), Vector2(42, 0), Vector2(35, 20)])
		add_child(HandDrawnStroke.new(wave_r, Color("#e63946"), 2.4, 1.2))
		var bzzz := HandwrittenText.new("*BZZT!*", 20.0, Color("#e63946"), false, HORIZONTAL_ALIGNMENT_CENTER)
		bzzz.position = Vector2(0, -60)
		add_child(bzzz)
		scale = Vector2(0.2, 0.2)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)
		tw.tween_interval(maxf(0.1, dur - 0.4))
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)

	func _draw() -> void:
		draw_rect(Rect2(-24, -44, 48, 88), Color("#ffffff", 0.95))

# =============================================================================
# COMIC ACCENT SPAWN HELPERS
# =============================================================================

static func spawn_sweat_drop(parent: Node2D, offset: Vector2, dur: float = 1.4) -> ComicSweatDrop:
	var s := ComicSweatDrop.new(dur)
	s.position = offset
	parent.add_child(s)
	return s

static func spawn_question_mark(parent: Node2D, offset: Vector2, dur: float = 1.1) -> ComicQuestionMark:
	var q := ComicQuestionMark.new(dur)
	q.position = offset
	parent.add_child(q)
	return q

static func spawn_stress_lines(parent: Node2D, offset: Vector2, dur: float = 1.4) -> ComicStressLines:
	var sl := ComicStressLines.new(dur)
	sl.position = offset
	parent.add_child(sl)
	return sl

static func spawn_brain_spiral(parent: Node2D, offset: Vector2, dur: float = 2.2) -> ComicBrainSpiral:
	var bs := ComicBrainSpiral.new(dur)
	bs.position = offset
	parent.add_child(bs)
	return bs

static func spawn_vein_mark(parent: Node2D, offset: Vector2, dur: float = 1.3) -> ComicVeinMark:
	var v := ComicVeinMark.new(dur)
	v.position = offset
	parent.add_child(v)
	return v

static func spawn_exclamation(parent: Node2D, offset: Vector2, has_q: bool = false, is_double: bool = false, dur: float = 1.0) -> ComicExclamation:
	var e := ComicExclamation.new(has_q, is_double, dur)
	e.position = offset
	parent.add_child(e)
	return e

static func spawn_sparkles(parent: Node2D, pos: Vector2, dur: float = 1.4) -> ComicSparkles:
	var sp := ComicSparkles.new(dur)
	sp.position = pos
	parent.add_child(sp)
	return sp

static func spawn_burst_rays(parent: Node2D, pos: Vector2, dur: float = 0.8) -> ComicBurstRays:
	var br := ComicBurstRays.new(dur)
	br.position = pos
	parent.add_child(br)
	return br

static func spawn_soul_float(parent: Node2D, offset: Vector2, dur: float = 2.0) -> ComicSoulFloat:
	var sf := ComicSoulFloat.new(dur)
	sf.position = offset
	parent.add_child(sf)
	return sf

static func spawn_emoticon(parent: Node2D, pos: Vector2, face: String = ">_<", dur: float = 1.3) -> ComicEmoticonBubble:
	var eb := ComicEmoticonBubble.new(face, dur)
	eb.position = pos
	parent.add_child(eb)
	return eb

static func spawn_lightbulb(parent: Node2D, offset: Vector2, dur: float = 1.3) -> ComicLightbulb:
	var lb := ComicLightbulb.new(dur)
	lb.position = offset
	parent.add_child(lb)
	return lb



static func spawn_panic_meter(parent: Node2D, pos: Vector2, dur: float = 2.0) -> DoodlePanicMeter:
	var pm := DoodlePanicMeter.new(dur)
	pm.position = pos
	parent.add_child(pm)
	return pm

static func spawn_sticky_note(parent: Node2D, pos: Vector2, note_text: String, bg_col: Color = Color("#fff3b0"), dur: float = 2.5) -> DoodleStickyNote:
	var sn := DoodleStickyNote.new(note_text, bg_col, dur)
	sn.position = pos
	parent.add_child(sn)
	return sn

static func spawn_action_bubble(parent: Node2D, pos: Vector2, action_str: String = "*GASP*", col: Color = Color("#d93b2b"), dur: float = 1.0) -> DoodleActionBubble:
	var ab := DoodleActionBubble.new(action_str, col, dur)
	ab.position = pos
	parent.add_child(ab)
	return ab

static func spawn_heart_burst(parent: Node2D, pos: Vector2, dur: float = 2.0) -> DoodleHeartBurst:
	var hb := DoodleHeartBurst.new(dur)
	hb.position = pos
	parent.add_child(hb)
	return hb

static func spawn_facepalm_chibi(parent: Node2D, pos: Vector2, dur: float = 2.2) -> DoodleFacepalmChibi:
	var fc := DoodleFacepalmChibi.new(dur)
	fc.position = pos
	parent.add_child(fc)
	return fc

static func spawn_coffee_mug(parent: Node2D, pos: Vector2, dur: float = 3.5) -> DoodleCoffeeMug:
	var cm := DoodleCoffeeMug.new(dur)
	cm.position = pos
	parent.add_child(cm)
	return cm

static func spawn_notification_buzz(parent: Node2D, pos: Vector2, dur: float = 2.0) -> DoodleNotificationBuzz:
	var nb := DoodleNotificationBuzz.new(dur)
	nb.position = pos
	parent.add_child(nb)
	return nb
