class_name Ep04StudioBackdrop
extends Node2D

## Illustrated Cozy Studio Backdrop for Episode 04: "Guys, I'm Scared."
## Hand-drawn animator bedroom / studio in the authentic aesthetic of Pegi:
## - Soft pastel wash (#eaf3fc sky tint / #faf7f4 paper base)
## - Sketched room structures: window with daylight & curtains, bookshelf with colorful books,
##   corkboard with taped sketches & fairy lights, potted succulent, wall art.
## - Front drawing desk: wooden surface, digital drawing tablet, stylus, coffee mug with steam.
## - Dynamic 2:00 AM Night Mode: smooth transition to deep midnight blue (#141528)
##   with glowing desk lamp and monitor glare illuminating Nemi.

@export var night_mode_intensity: float = 0.0 # 0.0 = day studio, 1.0 = 2:00 AM dark room
@export var show_desk: bool = true

var day_bg_color: Color = Color("#eaf3fc") # Soft pastel sky blue from Pegi reference
var night_bg_color: Color = Color("#141528") # Deep midnight blue for late night

var day_ink_color: Color = Color("#38101e") # Deep blackberry ink
var night_ink_color: Color = Color("#6b6e94") # Soft slate night ink

var day_wood_color: Color = Color("#e6d8c8") # Warm wood surface
var day_wood_shadow: Color = Color("#c7b5a0") # Wood edge/shadow

var day_wall_wood: Color = Color("#dfd2c0") # Shelves
var night_wood_color: Color = Color("#222338")

var screen_glare_color: Color = Color(0.40, 0.70, 1.0, 0.28)
var lamp_glow_color: Color = Color(1.0, 0.88, 0.60, 0.35)

var _active_tween: Tween
var foreground_desk: Node2D

func _init() -> void:
	foreground_desk = StudioForegroundDesk.new(self)
	foreground_desk.name = "ForegroundDesk"

func _ready() -> void:
	z_index = -10
	request_redraw_all()

func request_redraw_all() -> void:
	queue_redraw()
	if is_instance_valid(foreground_desk):
		foreground_desk.queue_redraw()

func set_night_mode(enabled: bool, duration: float = 0.5) -> Signal:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	var target: float = 1.0 if enabled else 0.0
	_active_tween = create_tween()
	_active_tween.tween_property(self, "night_mode_intensity", target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_active_tween.parallel().tween_method(func(_v): request_redraw_all(), 0.0, 1.0, duration)
	return _active_tween.finished

func set_desk_visible(visible_state: bool) -> void:
	show_desk = visible_state
	request_redraw_all()

func _draw() -> void:
	var t: float = night_mode_intensity
	var bg_col: Color = day_bg_color.lerp(night_bg_color, t)
	var ink_col: Color = day_ink_color.lerp(night_ink_color, t)
	
	# 1. Full Canvas Background Fill
	draw_rect(Rect2(-2000, -2000, 6000, 6000), bg_col)
	
	# 2. Floor Horizon Line (warm ground plane at y = 560)
	var floor_y := 560.0
	var floor_col := Color("#dfebf5").lerp(Color("#101120"), t)
	draw_rect(Rect2(-2000, floor_y, 6000, 2000), floor_col)
	_draw_hand_line_on(self, Vector2(-1000, floor_y), Vector2(3000, floor_y), ink_col, 2.2, 1.5)
	
	# 3. Room Wall Structures (Bookshelf, Window, Pinboard, Fairy Lights)
	_draw_window(Vector2(1010, 150), t, ink_col)
	_draw_bookshelf(Vector2(120, 180), t, ink_col)
	_draw_pinboard(Vector2(450, 150), t, ink_col)
	_draw_fairy_lights(Vector2(430, 130), Vector2(850, 140), t)

# -----------------------------------------------------------------------------
# ROOM ELEMENTS (100% Procedural Hand-Drawn Vector Vectors)
# -----------------------------------------------------------------------------

func _draw_window(pos: Vector2, t: float, ink: Color) -> void:
	var w := 200.0
	var h := 220.0
	var win_rect := Rect2(pos.x, pos.y, w, h)
	
	# Window sky pane fill (bright daytime sky or dark starry night)
	var sky_col := Color("#ffffff").lerp(Color("#0c0d1a"), t)
	draw_rect(win_rect, sky_col)
	
	# Outer frame
	_draw_hand_rect(win_rect, ink, 2.4, 2.0)
	
	# Window panes (+ divider)
	var mid_x := pos.x + w * 0.5
	var mid_y := pos.y + h * 0.45
	_draw_hand_line(Vector2(mid_x, pos.y), Vector2(mid_x, pos.y + h), ink, 1.8, 1.2)
	_draw_hand_line(Vector2(pos.x, mid_y), Vector2(pos.x + w, mid_y), ink, 1.8, 1.2)
	
	# Soft pastel curtain drapes on left and right
	var curtain_col := Color("#fcdbe2", 0.65).lerp(Color("#2c283d", 0.7), t)
	var left_curtain := PackedVector2Array([
		Vector2(pos.x - 15, pos.y - 10), Vector2(pos.x + 35, pos.y - 10),
		Vector2(pos.x + 20, pos.y + h + 15), Vector2(pos.x - 20, pos.y + h + 15)
	])
	draw_colored_polygon(left_curtain, curtain_col)
	_draw_hand_line(Vector2(pos.x + 35, pos.y - 10), Vector2(pos.x + 20, pos.y + h + 15), ink, 1.5, 1.2)
	
	var right_curtain := PackedVector2Array([
		Vector2(pos.x + w - 35, pos.y - 10), Vector2(pos.x + w + 15, pos.y - 10),
		Vector2(pos.x + w + 20, pos.y + h + 15), Vector2(pos.x + w - 20, pos.y + h + 15)
	])
	draw_colored_polygon(right_curtain, curtain_col)
	_draw_hand_line(Vector2(pos.x + w - 35, pos.y - 10), Vector2(pos.x + w - 20, pos.y + h + 15), ink, 1.5, 1.2)

func _draw_bookshelf(pos: Vector2, t: float, ink: Color) -> void:
	var shelf_w := 240.0
	var shelf_h := 12.0
	var wood := day_wall_wood.lerp(night_wood_color, t)
	
	# 2-tier shelves
	for tier in range(2):
		var sy := pos.y + float(tier) * 90.0
		# Shelf plank
		draw_rect(Rect2(pos.x, sy, shelf_w, shelf_h), wood)
		_draw_hand_line(Vector2(pos.x, sy), Vector2(pos.x + shelf_w, sy), ink, 2.0, 1.5)
		_draw_hand_line(Vector2(pos.x, sy + shelf_h), Vector2(pos.x + shelf_w, sy + shelf_h), ink, 2.0, 1.5)
		
		# Books on shelf
		var book_colors: Array[Color] = [
			Color("#ff8a9e"), Color("#7bc5ae"), Color("#ffd275"), Color("#9db4c0"), Color("#c3aed6")
		]
		var bx := pos.x + 15.0
		for b in range(5):
			var bw := 14.0 + float((b * 7) % 8)
			var bh := 45.0 + float((b * 13) % 25)
			var b_col: Color = book_colors[b % book_colors.size()].lerp(Color("#262942"), t)
			var b_rect := Rect2(bx, sy - bh, bw, bh)
			draw_rect(b_rect, b_col)
			_draw_hand_rect(b_rect, ink, 1.4, 1.0)
			bx += bw + 3.0
			
		# Small potted succulent on top shelf
		if tier == 0:
			var pot_x := pos.x + shelf_w - 45.0
			var pot_rect := Rect2(pot_x, sy - 24.0, 28.0, 24.0)
			draw_rect(pot_rect, Color("#df8a6c").lerp(Color("#36252a"), t))
			_draw_hand_rect(pot_rect, ink, 1.5, 1.0)
			# Green leaves
			var plant_col := Color("#69b578").lerp(Color("#1d3b25"), t)
			draw_circle(Vector2(pot_x + 8, sy - 28), 7.0, plant_col)
			draw_circle(Vector2(pot_x + 14, sy - 34), 9.0, plant_col)
			draw_circle(Vector2(pot_x + 20, sy - 28), 7.0, plant_col)

func _draw_pinboard(pos: Vector2, t: float, ink: Color) -> void:
	var pw := 220.0
	var ph := 140.0
	var cork_col := Color("#ecd9be").lerp(Color("#23243b"), t)
	var board_rect := Rect2(pos.x, pos.y, pw, ph)
	draw_rect(board_rect, cork_col)
	_draw_hand_rect(board_rect, ink, 2.2, 1.8)
	
	# Sticky notes & taped sketches
	var notes := [
		{"pos": Vector2(pos.x + 20, pos.y + 20), "size": Vector2(50, 45), "col": Color("#fff475")},
		{"pos": Vector2(pos.x + 85, pos.y + 15), "size": Vector2(65, 55), "col": Color("#ffd1dc")},
		{"pos": Vector2(pos.x + 140, pos.y + 55), "size": Vector2(60, 60), "col": Color("#d4f0f0")},
		{"pos": Vector2(pos.x + 35, pos.y + 75), "size": Vector2(55, 45), "col": Color("#e2d4f0")}
	]
	for n in notes:
		var n_col: Color = (n["col"] as Color).lerp(Color("#2c2e48"), t)
		var n_rect := Rect2(n["pos"] as Vector2, n["size"] as Vector2)
		draw_rect(n_rect, n_col)
		_draw_hand_rect(n_rect, ink, 1.2, 0.8)
		# Little red/yellow pin dot
		draw_circle((n["pos"] as Vector2) + Vector2(n_rect.size.x * 0.5, 4), 2.5, Color("#e63946"))

func _draw_fairy_lights(p0: Vector2, p1: Vector2, t: float) -> void:
	var wire_pts := PackedVector2Array()
	var steps := 20
	for i in range(steps + 1):
		var frac := float(i) / float(steps)
		var base := p0.lerp(p1, frac)
		var sag := sin(frac * PI) * 22.0 # Drooping string
		wire_pts.append(base + Vector2(0, sag))
	draw_polyline(wire_pts, Color(0.3, 0.25, 0.35, 0.6), 1.2)
	
	# Glowing bulbs along the string
	var light_colors := [Color("#ffd166"), Color("#ef476f"), Color("#06d6a0"), Color("#118ab2")]
	for i in range(1, steps, 2):
		var pt := wire_pts[i]
		var col: Color = light_colors[(i / 2) % light_colors.size()]
		# Halo
		draw_circle(pt, 6.0, Color(col.r, col.g, col.b, lerpf(0.3, 0.75, t)))
		# Core
		draw_circle(pt, 2.5, Color("#ffffff"))

# -----------------------------------------------------------------------------
# HAND-DRAWN PRIMITIVE DRAWING UTILITIES
# -----------------------------------------------------------------------------

func _draw_hand_line(p0: Vector2, p1: Vector2, col: Color, w: float = 2.4, wobble: float = 2.0) -> void:
	_draw_hand_line_on(self, p0, p1, col, w, wobble)

func _draw_hand_rect(r: Rect2, col: Color, w: float = 2.2, wobble: float = 1.8) -> void:
	_draw_hand_rect_on(self, r, col, w, wobble)

static func _draw_hand_line_on(canvas: CanvasItem, p0: Vector2, p1: Vector2, col: Color, w: float = 2.4, wobble: float = 2.0) -> void:
	var dist := p0.distance_to(p1)
	if dist < 1.0:
		return
	var steps := maxi(2, int(ceil(dist / 18.0)))
	var dir := (p1 - p0).normalized()
	var norm := Vector2(-dir.y, dir.x)
	var pts := PackedVector2Array()
	
	for s in range(steps + 1):
		var frac := float(s) / float(steps)
		var base := p0.lerp(p1, frac)
		var j := (sin(frac * 11.3) * 0.65 + cos(frac * 19.7) * 0.35) * wobble
		pts.append(base + norm * j)
	canvas.draw_polyline(pts, col, w)

static func _draw_hand_rect_on(canvas: CanvasItem, r: Rect2, col: Color, w: float = 2.2, wobble: float = 1.8) -> void:
	var tl := r.position
	var tr := r.position + Vector2(r.size.x, 0)
	var br := r.position + r.size
	var bl := r.position + Vector2(0, r.size.y)
	_draw_hand_line_on(canvas, tl, tr, col, w, wobble)
	_draw_hand_line_on(canvas, tr, br, col, w, wobble)
	_draw_hand_line_on(canvas, br, bl, col, w, wobble)
	_draw_hand_line_on(canvas, bl, tl, col, w, wobble)

# =============================================================================
# FOREGROUND DESK LAYER (z_index = 5, in front of skirt/legs, behind hands)
# =============================================================================

class StudioForegroundDesk extends Node2D:
	var backdrop: Ep04StudioBackdrop

	func _init(p_backdrop: Ep04StudioBackdrop) -> void:
		backdrop = p_backdrop
		z_index = 15
		z_as_relative = false

	func _draw() -> void:
		if not is_instance_valid(backdrop) or not backdrop.show_desk:
			return
			
		var t: float = backdrop.night_mode_intensity
		var ink: Color = backdrop.day_ink_color.lerp(backdrop.night_ink_color, t)
		var wood: Color = backdrop.day_wood_color.lerp(backdrop.night_wood_color, t)
		var wood_shd: Color = backdrop.day_wood_shadow.lerp(backdrop.night_wood_color * 0.8, t)
		
		var desk_y := 540.0
		var desk_w := 1800.0
		var desk_h := 300.0
		var desk_rect := Rect2(-300, desk_y, desk_w, desk_h)
		
		# Desk Top Surface (Warm wooden tabletop covering legs)
		draw_rect(desk_rect, wood)
		
		# Tabletop top bevel edge
		draw_rect(Rect2(-300, desk_y, desk_w, 14.0), wood_shd)
		Ep04StudioBackdrop._draw_hand_line_on(self, Vector2(-300, desk_y), Vector2(1500, desk_y), ink, 3.2, 2.0)
		Ep04StudioBackdrop._draw_hand_line_on(self, Vector2(-300, desk_y + 14.0), Vector2(1500, desk_y + 14.0), ink, 2.0, 1.5)
		
		# 1. Digital Drawing Tablet (Cintiq display) directly in front of Nemi
		var tab_pos := Vector2(510, desk_y - 45)
		var tab_w := 260.0
		var tab_h := 80.0
		var tab_rect := Rect2(tab_pos.x, tab_pos.y, tab_w, tab_h)
		draw_rect(tab_rect, Color("#2b2c3d").lerp(Color("#141524"), t))
		Ep04StudioBackdrop._draw_hand_rect_on(self, tab_rect, ink, 2.5, 1.8)
		var scr_rect := Rect2(tab_pos.x + 22, tab_pos.y + 8, tab_w - 44, tab_h - 16)
		var scr_col := Color("#f5f2eb").lerp(Color("#3a7bd5"), t * 0.8)
		draw_rect(scr_rect, scr_col)
		Ep04StudioBackdrop._draw_hand_rect_on(self, scr_rect, ink, 1.4, 1.0)
		for k in range(4):
			var ky := tab_pos.y + 14.0 + float(k) * 13.0
			draw_rect(Rect2(tab_pos.x + 6, ky, 10, 8), Color("#414257"))
		Ep04StudioBackdrop._draw_hand_line_on(self, Vector2(tab_pos.x + 190, tab_pos.y + 20), Vector2(tab_pos.x + 225, tab_pos.y + 65), Color("#1b1c2b"), 3.2, 1.0)
		
		# 2. Coffee Mug on left side of desk
		var mug_pos := Vector2(290, desk_y - 38)
		var mug_w := 42.0
		var mug_h := 46.0
		var mug_col := Color("#ffcad4").lerp(Color("#432e3a"), t)
		draw_rect(Rect2(mug_pos.x, mug_pos.y, mug_w, mug_h), mug_col)
		Ep04StudioBackdrop._draw_hand_rect_on(self, Rect2(mug_pos.x, mug_pos.y, mug_w, mug_h), ink, 2.2, 1.4)
		var handle_pts := PackedVector2Array([
			Vector2(mug_pos.x - 2, mug_pos.y + 10), Vector2(mug_pos.x - 14, mug_pos.y + 16),
			Vector2(mug_pos.x - 14, mug_pos.y + 32), Vector2(mug_pos.x - 2, mug_pos.y + 36)
		])
		draw_polyline(handle_pts, ink, 2.2)
		if t < 0.95:
			var steam_col := Color(ink.r, ink.g, ink.b, 0.35)
			Ep04StudioBackdrop._draw_hand_line_on(self, Vector2(mug_pos.x + 14, mug_pos.y - 5), Vector2(mug_pos.x + 10, mug_pos.y - 25), steam_col, 1.5, 2.0)
			Ep04StudioBackdrop._draw_hand_line_on(self, Vector2(mug_pos.x + 26, mug_pos.y - 8), Vector2(mug_pos.x + 30, mug_pos.y - 32), steam_col, 1.5, 2.0)

		# 3. Desk Lamp on far left
		var lamp_base := Vector2(200, desk_y - 10)
		draw_rect(Rect2(lamp_base.x - 18, lamp_base.y - 6, 36, 10), Color("#ffd166").lerp(Color("#4a3f28"), t))
		Ep04StudioBackdrop._draw_hand_rect_on(self, Rect2(lamp_base.x - 18, lamp_base.y - 6, 36, 10), ink, 2.0, 1.2)
		var arm1 := lamp_base + Vector2(0, -60)
		var arm2 := arm1 + Vector2(40, -45)
		Ep04StudioBackdrop._draw_hand_line_on(self, lamp_base, arm1, ink, 3.0, 1.5)
		Ep04StudioBackdrop._draw_hand_line_on(self, arm1, arm2, ink, 3.0, 1.5)
		var shade_pts := PackedVector2Array([
			arm2 + Vector2(-15, -10), arm2 + Vector2(25, 5),
			arm2 + Vector2(32, 25), arm2 + Vector2(-8, 12)
		])
		draw_colored_polygon(shade_pts, Color("#ffd166").lerp(Color("#ffe28a"), t))
		draw_polyline(shade_pts, ink, 2.2)

		# 4. Night Mode Screen Glare and Lamp Glow in Foreground
		if t > 0.02:
			var lamp_pos := Vector2(220, desk_y - 50)
			draw_circle(lamp_pos, 160.0, Color(backdrop.lamp_glow_color.r, backdrop.lamp_glow_color.g, backdrop.lamp_glow_color.b, backdrop.lamp_glow_color.a * t))
			var glare_pts := PackedVector2Array([
				Vector2(640, desk_y), Vector2(380, 260), Vector2(900, 260)
			])
			var glare_col := backdrop.screen_glare_color
			glare_col.a *= t * 0.5
			draw_colored_polygon(glare_pts, glare_col)
