class_name Ep06Backdrop
extends Node2D

## Ep06Backdrop - Master Hand-Illustrated Studio Environment for Episode 06
## "HOW I ACTUALLY MAKE STORYTIME ANIMATIONS"
##
## 100% Hand-Drawn Storybook Visual Language:
## - Base canvas: Warm cream sketchbook paper (#faf7f2 / #f5efe6)
## - ZERO pitch-black viewport flashes. All modes share warm paper continuity.
## - Specialized scenes (booth, timeline, Godot, forensic zoom) are illustrated
##   as hand-drawn diegetic setups (monitors, drafting boards, magnifying loupes).
## - Hand-inked linework (#2e1822 DNA) with warm watercolor washes.

const INK_MAIN: Color = Color("#2e1822")
const INK_SOFT: Color = Color("#6b5763")
const INK_RED: Color = Color("#d63031")
const INK_GOLD: Color = Color("#d35400")
const INK_BLUE: Color = Color("#0984e3")
const INK_MINT: Color = Color("#009470")
const INK_PURPLE: Color = Color("#6c5ce7")

const CANVAS_PAPER: Color = Color("#faf7f2")
const CANVAS_WARM_FLOOR: Color = Color("#f2ebe0")
const SHADOW_SOFT: Color = Color(0.18, 0.08, 0.12, 0.12)

enum Mode {
	NORMAL_STUDIO,      # 0: Warm studio room with desk, window, bookshelf, plants, corkboard
	MEMORY_EVENT,       # 1: Vignetted memory card pinned with washi tape
	DESK_FOCUS,         # 2: Wooden drafting desk with steaming mug, sketchbooks & pen jar
	RECORDING_BOOTH,    # 3: Illustrated studio acoustic corner with condenser mic
	TIMELINE_STAGE,     # 4: Blueprint drafting stage with colorful beat marker banners
	WHY_BEATS_MATTER,   # 5: Split comedy stage: warm chalkboard vs icy punchline speedlines
	GODOT_GRID,         # 6: Illustrated desktop workstation monitor with keyframe tracks
	DOODLE_GALLERY,     # 7: Artist workshop with pegboard, drafting tools, color swatches
	MICROSCOPIC_ZOOM,   # 8: Illustrated forensic magnifying loupe inspecting 1 hair pixel
	WARM_WRAPUP         # 9: Celebratory golden studio with wavy bunting flags & starbursts
}

var current_mode: Mode = Mode.NORMAL_STUDIO
var blend_progress: float = 1.0
var _active_tween: Tween

# Dynamic subtle animations
var steam_phase: float = 0.0
var wave_pulse: float = 0.0
var sparkle_phase: float = 0.0

func _ready() -> void:
	z_index = -5
	queue_redraw()

func _process(delta: float) -> void:
	steam_phase += delta * 2.2
	wave_pulse += delta * 3.2
	sparkle_phase += delta * 1.6
	if current_mode in [Mode.DESK_FOCUS, Mode.RECORDING_BOOTH, Mode.WARM_WRAPUP, Mode.GODOT_GRID] or (_active_tween and _active_tween.is_valid() and _active_tween.is_running()):
		queue_redraw()

func set_mode(m: int, dur: float = 0.35) -> void:
	var target_mode: Mode = Mode.values()[clampi(m, 0, Mode.size() - 1)]
	if dur <= 0.01:
		current_mode = target_mode
		blend_progress = 1.0
		queue_redraw()
		return

	if current_mode == target_mode:
		queue_redraw()
		return

	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()

	_active_tween = create_tween()
	_active_tween.tween_property(self, "blend_progress", 0.0, dur * 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_active_tween.tween_callback(func():
		current_mode = target_mode
		queue_redraw()
	)
	_active_tween.tween_property(self, "blend_progress", 1.0, dur * 0.65)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_tween.finished.connect(queue_redraw)

func _draw() -> void:
	var canvas_rect := Rect2(-300.0, -200.0, 1900.0, 1200.0)

	match current_mode:
		Mode.NORMAL_STUDIO:
			_draw_normal_studio(canvas_rect)
		Mode.MEMORY_EVENT:
			_draw_memory_event(canvas_rect)
		Mode.DESK_FOCUS:
			_draw_desk_focus(canvas_rect)
		Mode.RECORDING_BOOTH:
			_draw_recording_booth(canvas_rect)
		Mode.TIMELINE_STAGE:
			_draw_timeline_stage(canvas_rect)
		Mode.WHY_BEATS_MATTER:
			_draw_why_beats_matter(canvas_rect)
		Mode.GODOT_GRID:
			_draw_godot_grid(canvas_rect)
		Mode.DOODLE_GALLERY:
			_draw_doodle_gallery(canvas_rect)
		Mode.MICROSCOPIC_ZOOM:
			_draw_microscopic_zoom(canvas_rect)
		Mode.WARM_WRAPUP:
			_draw_warm_wrapup(canvas_rect)

# =============================================================================
# 0. NORMAL STUDIO ENVIRONMENT
# =============================================================================
func _draw_normal_studio(rect: Rect2) -> void:
	# 1. Warm cream paper canvas with soft warm wooden floor
	draw_rect(rect, CANVAS_PAPER)
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), CANVAS_WARM_FLOOR)

	# 2. Hand-inked baseboard & floorboard lines
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)
	draw_line(Vector2(-100.0, 528.0), Vector2(1400.0, 528.0), INK_SOFT, 1.4)
	for fx: float in [120.0, 360.0, 620.0, 900.0, 1180.0]:
		draw_line(Vector2(fx, 528.0), Vector2(fx - 45.0, 720.0), Color(0.4, 0.35, 0.35, 0.18), 1.2)

	# 3. Left Wall: Illustrated Studio Window with watercolor sky & clouds
	var win_rect := Rect2(70.0, 100.0, 180.0, 260.0)
	draw_rect(win_rect, Color("#ebf4fa"))
	# Soft fluffy hand-drawn clouds
	draw_circle(Vector2(130.0, 180.0), 16.0, Color("#ffffff"))
	draw_circle(Vector2(152.0, 172.0), 22.0, Color("#ffffff"))
	draw_circle(Vector2(174.0, 178.0), 16.0, Color("#ffffff"))
	draw_rect(win_rect, INK_MAIN, false, 3.0)
	draw_line(Vector2(160.0, 100.0), Vector2(160.0, 360.0), INK_MAIN, 2.2)
	draw_line(Vector2(70.0, 230.0), Vector2(250.0, 230.0), INK_MAIN, 2.2)
	draw_line(Vector2(60.0, 360.0), Vector2(260.0, 360.0), INK_MAIN, 4.5)

	# Potted succulent on windowsill
	draw_colored_polygon(PackedVector2Array([
		Vector2(90.0, 360.0), Vector2(114.0, 360.0),
		Vector2(110.0, 336.0), Vector2(94.0, 336.0)
	]), Color("#d98880"))
	draw_polyline(PackedVector2Array([
		Vector2(90.0, 360.0), Vector2(114.0, 360.0),
		Vector2(110.0, 336.0), Vector2(94.0, 336.0), Vector2(90.0, 360.0)
	]), INK_MAIN, 1.8)
	draw_arc(Vector2(102.0, 326.0), 9.0, -PI * 0.8, -PI * 0.2, 8, INK_MINT, 3.0)

	# 4. Center-Left: Hand-drawn Wooden Wall Bookshelf
	var shelf := Rect2(300.0, 190.0, 180.0, 10.0)
	draw_rect(shelf, Color("#8c6d58"))
	draw_rect(shelf, INK_MAIN, false, 2.2)
	# Books with slight tilt
	var book_cols = [INK_RED, INK_BLUE, INK_GOLD, INK_MINT, INK_PURPLE]
	var bx := 315.0
	for i in range(5):
		var bh: float = 34.0 + float(i % 3) * 8.0
		var bw: float = 13.0
		var tilt: float = -2.0 if i == 4 else 0.0
		draw_rect(Rect2(bx + tilt, 190.0 - bh, bw, bh), book_cols[i])
		draw_rect(Rect2(bx + tilt, 190.0 - bh, bw, bh), INK_MAIN, false, 1.5)
		bx += 16.0

	# 5. Right Wall: Pinned Corkboard with hand-drawn sticky notes
	var cork := Rect2(1000.0, 110.0, 210.0, 220.0)
	draw_rect(cork, Color("#dec39b"))
	draw_rect(cork, INK_MAIN, false, 3.2)
	# Yellow sticky note with slight organic tilt
	draw_colored_polygon(PackedVector2Array([
		Vector2(1025.0, 135.0), Vector2(1085.0, 138.0),
		Vector2(1082.0, 195.0), Vector2(1022.0, 192.0)
	]), Color("#fff475"))
	draw_polyline(PackedVector2Array([
		Vector2(1025.0, 135.0), Vector2(1085.0, 138.0),
		Vector2(1082.0, 195.0), Vector2(1022.0, 192.0), Vector2(1025.0, 135.0)
	]), INK_MAIN, 1.4)
	draw_circle(Vector2(1054.0, 138.0), 3.0, INK_RED)
	draw_line(Vector2(1032.0, 155.0), Vector2(1075.0, 156.0), INK_SOFT, 1.2)
	draw_line(Vector2(1032.0, 168.0), Vector2(1068.0, 169.0), INK_SOFT, 1.2)
	# Pink sketch note
	draw_colored_polygon(PackedVector2Array([
		Vector2(1110.0, 145.0), Vector2(1175.0, 142.0),
		Vector2(1178.0, 205.0), Vector2(1113.0, 208.0)
	]), Color("#ffb3ba"))
	draw_polyline(PackedVector2Array([
		Vector2(1110.0, 145.0), Vector2(1175.0, 142.0),
		Vector2(1178.0, 205.0), Vector2(1113.0, 208.0), Vector2(1110.0, 145.0)
	]), INK_MAIN, 1.4)
	draw_circle(Vector2(1144.0, 144.0), 3.0, INK_BLUE)
	# Little smiley sketch
	draw_arc(Vector2(1145.0, 175.0), 10.0, 0.0, TAU, 16, INK_MAIN, 1.4)
	draw_circle(Vector2(1141.0, 173.0), 1.5, INK_MAIN)
	draw_circle(Vector2(1149.0, 173.0), 1.5, INK_MAIN)
	draw_arc(Vector2(1145.0, 177.0), 5.0, 0.2, PI - 0.2, 8, INK_MAIN, 1.2)

# =============================================================================
# 1. MEMORY EVENT ENVIRONMENT (Beat 2)
# =============================================================================
func _draw_memory_event(rect: Rect2) -> void:
	# Warm sepia parchment
	draw_rect(rect, Color("#faf4eb"))
	# Floor line
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), Color("#f0e6d6"))
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.6)

	# Fluffy cloud border vignettes framing the story moment
	var cloud_col := Color(0.92, 0.86, 0.78, 0.55)
	for cx in range(80, 1240, 160):
		draw_circle(Vector2(float(cx), 50.0), 65.0, cloud_col)
	for cy in range(120, 540, 140):
		draw_circle(Vector2(40.0, float(cy)), 60.0, cloud_col)

	# Illustrated memory sketch card pinned on wall (X: 800, Y: 140)
	var card_rect := Rect2(800.0, 140.0, 270.0, 300.0)
	draw_rect(card_rect, Color("#ffffff"))
	draw_rect(card_rect, INK_MAIN, false, 2.8)

	# Washi tape on top
	draw_colored_polygon(PackedVector2Array([
		Vector2(890.0, 128.0), Vector2(980.0, 128.0),
		Vector2(976.0, 148.0), Vector2(886.0, 148.0)
	]), Color(0.85, 0.72, 0.60, 0.85))

	# Comic memory illustration inside card: Coffee spilling / trip
	var inner_rect := Rect2(820.0, 160.0, 230.0, 210.0)
	draw_rect(inner_rect, Color("#fffdf8"))
	draw_rect(inner_rect, INK_SOFT, false, 1.5)
	# Spilled coffee mug doodle
	draw_colored_polygon(PackedVector2Array([
		Vector2(890.0, 290.0), Vector2(930.0, 275.0),
		Vector2(940.0, 305.0), Vector2(900.0, 320.0)
	]), Color("#ffffff"))
	draw_line(Vector2(890.0, 290.0), Vector2(930.0, 275.0), INK_MAIN, 2.2)
	draw_line(Vector2(900.0, 320.0), Vector2(940.0, 305.0), INK_MAIN, 2.2)
	# Coffee liquid splash
	var splash := PackedVector2Array([
		Vector2(935.0, 295.0), Vector2(970.0, 285.0),
		Vector2(995.0, 300.0), Vector2(955.0, 315.0)
	])
	draw_colored_polygon(splash, Color("#6f4e37"))
	# Shock burst lines
	for ang: float in [-0.5, 0.0, 0.5, 1.0]:
		var p1 := Vector2(985.0, 295.0) + Vector2(cos(ang) * 10.0, sin(ang) * 10.0)
		var p2 := Vector2(985.0, 295.0) + Vector2(cos(ang) * 22.0, sin(ang) * 22.0)
		draw_line(p1, p2, INK_GOLD, 2.4)

	# Pinned caption under polaroid
	draw_line(Vector2(840.0, 395.0), Vector2(1030.0, 395.0), INK_SOFT, 1.4)
	draw_line(Vector2(860.0, 412.0), Vector2(1010.0, 412.0), INK_SOFT, 1.2)

# =============================================================================
# 2. DESK FOCUS & SCRIPTWRITING (Beat 3)
# =============================================================================
func _draw_desk_focus(rect: Rect2) -> void:
	# Warm amber studio room with floor line - physical desk prop sits in front
	draw_rect(rect, Color("#faf5eb"))
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), Color("#f0e6d6"))
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# Left wall: Studio window framing the desk scene
	var win_rect := Rect2(70.0, 100.0, 180.0, 260.0)
	draw_rect(win_rect, Color("#ebf4fa"))
	draw_circle(Vector2(140.0, 175.0), 18.0, Color("#ffffff"))
	draw_circle(Vector2(165.0, 168.0), 24.0, Color("#ffffff"))
	draw_rect(win_rect, INK_MAIN, false, 3.0)
	draw_line(Vector2(160.0, 100.0), Vector2(160.0, 360.0), INK_MAIN, 2.2)
	draw_line(Vector2(70.0, 230.0), Vector2(250.0, 230.0), INK_MAIN, 2.2)
	draw_line(Vector2(60.0, 360.0), Vector2(260.0, 360.0), INK_MAIN, 4.5)

	# Right wall: Corkboard with pinned story notes & index cards
	var board_rect := Rect2(880.0, 110.0, 250.0, 260.0)
	draw_rect(board_rect, Color("#d9b382"))
	draw_rect(board_rect, INK_MAIN, false, 3.2)
	# Yellow sticky note
	draw_rect(Rect2(910.0, 140.0, 70.0, 65.0), Color("#fff475"))
	draw_rect(Rect2(910.0, 140.0, 70.0, 65.0), INK_MAIN, false, 1.4)
	draw_circle(Vector2(945.0, 142.0), 3.0, INK_RED)
	# Pink sticky note
	draw_rect(Rect2(1010.0, 150.0, 65.0, 60.0), Color("#ffb3ba"))
	draw_rect(Rect2(1010.0, 150.0, 65.0, 60.0), INK_MAIN, false, 1.4)
	draw_circle(Vector2(1042.0, 152.0), 3.0, INK_BLUE)

# =============================================================================
# 3. RECORDING BOOTH & VOICE WAVEFORM (Beat 4)
# =============================================================================
# CRITICAL FIX: Grounded on warm paper canvas! ZERO pitch-black screen flash!
# =============================================================================
func _draw_recording_booth(rect: Rect2) -> void:
	# 1. Warm studio paper canvas base
	draw_rect(rect, CANVAS_PAPER)
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), CANVAS_WARM_FLOOR)
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# 2. Illustrated Acoustic Foam Wall Section (centered behind Nemi)
	var booth_w := 980.0
	var booth_h := 360.0
	var booth_rect := Rect2(150.0, 90.0, booth_w, booth_h)
	draw_rect(booth_rect, Color("#ede5d8"))
	draw_rect(booth_rect, INK_MAIN, false, 3.0)

	# Foam pyramid tiles with warm illustrated hatching
	var f_cols = [Color("#e4dacb"), Color("#dcd1c0")]
	for row in range(3):
		for col in range(8):
			var fx := 170.0 + float(col) * 118.0
			var fy := 110.0 + float(row) * 105.0
			var f_tile := Rect2(fx, fy, 108.0, 95.0)
			draw_rect(f_tile, f_cols[(row + col) % 2])
			draw_rect(f_tile, Color(0.45, 0.38, 0.32, 0.35), false, 1.2)
			# Hand-drawn center point of pyramid
			var f_center := Vector2(fx + 54.0, fy + 47.0)
			draw_line(Vector2(fx, fy), f_center, Color(0.45, 0.38, 0.32, 0.25), 1.0)
			draw_line(Vector2(fx + 108.0, fy), f_center, Color(0.45, 0.38, 0.32, 0.25), 1.0)
			draw_line(Vector2(fx, fy + 95.0), f_center, Color(0.45, 0.38, 0.32, 0.25), 1.0)
			draw_line(Vector2(fx + 108.0, fy + 95.0), f_center, Color(0.45, 0.38, 0.32, 0.25), 1.0)

	# 3. Hand-drawn pulsing audio waveform across lower section
	var wave_pts := PackedVector2Array()
	var center_y := 490.0
	for x_pos in range(120, 1160, 14):
		var norm_x: float = float(x_pos - 120) / 1040.0
		var envelope: float = sin(norm_x * PI)
		var wave_amp: float = (sin(float(x_pos) * 0.04 + wave_pulse) * cos(float(x_pos) * 0.02 - wave_pulse * 0.5)) * 36.0 * envelope
		wave_pts.append(Vector2(float(x_pos), center_y + wave_amp))
	draw_polyline(wave_pts, INK_GOLD, 3.0)

	# Secondary harmonic waveform
	var sub_wave := PackedVector2Array()
	for p in wave_pts:
		sub_wave.append(Vector2(p.x, center_y - (p.y - center_y) * 0.65))
	draw_polyline(sub_wave, Color(0.2, 0.6, 0.8, 0.5), 1.8)

# =============================================================================
# 4. TIMELINE BLUEPRINT & BEATS (Beat 5)
# =============================================================================
func _draw_timeline_stage(rect: Rect2) -> void:
	# Clean engineering blueprint on warm paper
	draw_rect(rect, Color("#f3f7fa"))
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), Color("#eaf0f5"))
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# Subtle blueprint grid lines
	var b_col := Color(0.1, 0.35, 0.65, 0.07)
	for x in range(0, 1280, 40):
		draw_line(Vector2(float(x), 0.0), Vector2(float(x), 720.0), b_col, 1.0)
	for y in range(0, 720, 40):
		draw_line(Vector2(0.0, float(y)), Vector2(1280.0, float(y)), b_col, 1.0)

	# Hand-drawn Master Audio Timeline Track raised cleanly across top (Y: 60 to 125)
	var trk_rect := Rect2(80.0, 60.0, 1120.0, 65.0)
	draw_rect(trk_rect, Color("#2c3442"))
	draw_rect(trk_rect, INK_MAIN, false, 2.6)

	# Frame ruler ticks
	for i in range(29):
		var rx: float = 95.0 + float(i) * 38.0
		var r_len: float = 12.0 if (i % 4 == 0) else 6.0
		draw_line(Vector2(rx, 62.0), Vector2(rx, 62.0 + r_len), Color("#a0b4c8"), 1.2)

	# Audio waveform green spikes inside track
	for i in range(65):
		var wx: float = 100.0 + float(i) * 16.5
		var w_height: float = 8.0 + sin(float(i) * 0.35) * 12.0 + float((i * 17) % 10)
		draw_line(Vector2(wx, 92.0 - w_height), Vector2(wx, 92.0 + w_height), Color("#4cd137"), 2.2)

	# 5 Colorful Hand-drawn Beat Marker Flags hanging cleanly below timeline (Y: 125 to 185)
	var beat_defs = [
		{"name": "EXPLAIN", "x": 160.0, "col": INK_MINT},
		{"name": "REACTION", "x": 380.0, "col": INK_GOLD},
		{"name": "JOKE", "x": 620.0, "col": INK_RED},
		{"name": "PAUSE", "x": 860.0, "col": INK_BLUE},
		{"name": "CUTAWAY", "x": 1070.0, "col": INK_PURPLE}
	]

	for b in beat_defs:
		var bx: float = b["x"]
		var b_col_tag: Color = b["col"]
		draw_line(Vector2(bx, 125.0), Vector2(bx, 150.0), b_col_tag, 2.4)
		draw_circle(Vector2(bx, 125.0), 4.0, b_col_tag)
		# Marker Card Banner
		var card := Rect2(bx - 50.0, 150.0, 100.0, 38.0)
		draw_rect(card, Color("#ffffff"))
		draw_rect(card, b_col_tag, false, 2.4)
		draw_rect(Rect2(bx - 50.0, 150.0, 100.0, 10.0), b_col_tag)

# =============================================================================
# 5. WHY BEATS MATTER SPLIT STAGE (Beat 6)
# =============================================================================
func _draw_why_beats_matter(rect: Rect2) -> void:
	# Split comedy stage on warm paper:
	# Left: Warm Explanatory Cream | Right: Icy Deadpan Pale Blue
	draw_rect(Rect2(-200.0, -100.0, 840.0, 1000.0), Color("#fffbf2"))
	draw_rect(Rect2(640.0, -100.0, 840.0, 1000.0), Color("#edf4fb"))
	draw_line(Vector2(640.0, 40.0), Vector2(640.0, 680.0), INK_MAIN, 3.5)

	# Left: Illustrated Chalkboard
	var board := Rect2(140.0, 160.0, 340.0, 220.0)
	draw_rect(board, Color("#30383b"))
	draw_rect(board, INK_MAIN, false, 3.2)
	# Hand-drawn lightbulb idea on board
	draw_arc(Vector2(310.0, 250.0), 22.0, -PI * 0.7, PI * 0.7, 16, Color("#ffeaa7"), 2.6)
	draw_line(Vector2(300.0, 275.0), Vector2(320.0, 275.0), Color("#ffeaa7"), 2.4)
	draw_line(Vector2(303.0, 282.0), Vector2(317.0, 282.0), Color("#ffeaa7"), 2.4)

	# Right: Radiating comic speed lines
	for i in range(16):
		var ang: float = float(i) * PI / 8.0
		var r1 := 170.0
		var r2 := 360.0
		var sp1 := Vector2(960.0, 360.0) + Vector2(cos(ang) * r1, sin(ang) * r1)
		var sp2 := Vector2(960.0, 360.0) + Vector2(cos(ang) * r2, sin(ang) * r2)
		draw_line(sp1, sp2, Color(0.2, 0.45, 0.75, 0.22), 2.2)

# =============================================================================
# 6. GODOT WORKSTATION MONITOR (Beat 7)
# =============================================================================
# CRITICAL FIX: Rendered as an illustrated desktop workstation monitor!
# ZERO pitch-black viewport wipe! Nemi stands at her desk looking at the screen!
# =============================================================================
func _draw_godot_grid(rect: Rect2) -> void:
	# 1. Warm studio paper canvas base
	draw_rect(rect, CANVAS_PAPER)
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), CANVAS_WARM_FLOOR)
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# 2. Large Illustrated Computer Monitor (X: 140, Y: 70, W: 1000, H: 430)
	var mon_x := 140.0
	var mon_y := 70.0
	var mon_w := 1000.0
	var mon_h := 430.0

	# Monitor stand
	draw_rect(Rect2(mon_x + mon_w * 0.45, mon_y + mon_h, mon_w * 0.1, 40.0), Color("#8a939e"))
	draw_rect(Rect2(mon_x + mon_w * 0.35, mon_y + mon_h + 35.0, mon_w * 0.3, 10.0), Color("#717a86"))
	draw_line(Vector2(mon_x + mon_w * 0.35, mon_y + mon_h + 45.0), Vector2(mon_x + mon_w * 0.65, mon_y + mon_h + 45.0), INK_MAIN, 2.4)

	# Monitor outer frame
	var outer_mon := Rect2(mon_x, mon_y, mon_w, mon_h)
	draw_rect(outer_mon, Color("#2b2f3a"))
	draw_rect(outer_mon, INK_MAIN, false, 3.5)

	# Monitor screen (Godot dark slate UI inside the frame)
	var screen := Rect2(mon_x + 12.0, mon_y + 12.0, mon_w - 24.0, mon_h - 24.0)
	draw_rect(screen, Color("#1f2128"))

	# Top UI Header Bar
	draw_rect(Rect2(screen.position.x, screen.position.y, screen.size.x, 32.0), Color("#282b35"))
	draw_line(Vector2(screen.position.x, screen.position.y + 32.0), Vector2(screen.position.x + screen.size.x, screen.position.y + 32.0), Color("#3d4251"), 1.5)
	# Godot Robot icon accent
	draw_circle(Vector2(screen.position.x + 24.0, screen.position.y + 16.0), 10.0, Color("#478cbf"))

	# 8 Horizontal Property Tracks filling the screen
	for i in range(8):
		var ty: float = screen.position.y + 40.0 + float(i) * 42.0
		var trk_bg: Color = Color("#23262f") if i % 2 == 0 else Color("#1c1e25")
		draw_rect(Rect2(screen.position.x + 10.0, ty, screen.size.x - 20.0, 38.0), trk_bg)
		draw_line(Vector2(screen.position.x + 10.0, ty + 38.0), Vector2(screen.position.x + screen.size.x - 10.0, ty + 38.0), Color("#2d323e"), 1.0)

		# Track header label strip
		draw_rect(Rect2(screen.position.x + 10.0, ty, 160.0, 38.0), Color("#2a2e3a"))
		draw_line(Vector2(screen.position.x + 170.0, ty), Vector2(screen.position.x + 170.0, ty + 38.0), Color("#3d4251"), 1.5)

		# Dense scattering of golden & cyan keyframe diamonds!
		for k in range(8):
			var kx: float = screen.position.x + 220.0 + float(k) * 90.0 + float((i * 37) % 55)
			var diamond := PackedVector2Array([
				Vector2(kx, ty + 12.0), Vector2(kx + 6.0, ty + 19.0),
				Vector2(kx, ty + 26.0), Vector2(kx - 6.0, ty + 19.0)
			])
			var k_col: Color = Color("#f1c40f") if (i + k) % 3 != 0 else Color("#00d2d3")
			draw_colored_polygon(diamond, k_col)

# =============================================================================
# 7. DOODLE & PROPS GALLERY (Beat 8)
# =============================================================================
func _draw_doodle_gallery(rect: Rect2) -> void:
	# Artist studio warm craft paper
	draw_rect(rect, Color("#faf5eb"))
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), Color("#f0e8dc"))
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# Pegboard with wooden frame on left wall
	var peg := Rect2(80.0, 100.0, 240.0, 400.0)
	draw_rect(peg, Color("#eedec9"))
	draw_rect(peg, INK_MAIN, false, 2.6)
	for px in range(110, 300, 32):
		for py in range(130, 480, 36):
			draw_circle(Vector2(float(px), float(py)), 2.2, Color("#c4ab8e"))

	# Hanging sketch paper pinned with washi tape
	var sketch_pts := PackedVector2Array([
		Vector2(118.0, 158.0), Vector2(278.0, 154.0),
		Vector2(282.0, 380.0), Vector2(114.0, 384.0)
	])
	draw_colored_polygon(sketch_pts, Color("#fffef8"))
	draw_polyline(PackedVector2Array([sketch_pts[0], sketch_pts[1], sketch_pts[2], sketch_pts[3], sketch_pts[0]]), INK_SOFT, 1.6)
	# Washi tape top
	draw_colored_polygon(PackedVector2Array([
		Vector2(175.0, 146.0), Vector2(225.0, 145.0),
		Vector2(223.0, 163.0), Vector2(173.0, 164.0)
	]), Color(0.85, 0.72, 0.60, 0.85))
	# Cute rough doodles on paper
	draw_arc(Vector2(195.0, 230.0), 22.0, 0.0, TAU, 16, INK_MAIN, 1.8)
	draw_line(Vector2(160.0, 300.0), Vector2(240.0, 300.0), INK_SOFT, 1.4)
	draw_line(Vector2(170.0, 320.0), Vector2(230.0, 320.0), INK_SOFT, 1.2)

	# Organic Watercolor Palette Sheet with Washi Tape on right wall
	var sheet_pts := PackedVector2Array([
		Vector2(982.0, 118.0), Vector2(1202.0, 115.0),
		Vector2(1205.0, 498.0), Vector2(980.0, 502.0)
	])
	draw_colored_polygon(sheet_pts, Color("#fffdf6"))
	draw_polyline(PackedVector2Array([sheet_pts[0], sheet_pts[1], sheet_pts[2], sheet_pts[3], sheet_pts[0]]), INK_MAIN, 2.2)

	# Diagonal washi tape strips at top corners
	draw_colored_polygon(PackedVector2Array([
		Vector2(965.0, 130.0), Vector2(1005.0, 105.0),
		Vector2(1015.0, 120.0), Vector2(975.0, 145.0)
	]), Color(0.92, 0.65, 0.65, 0.85))
	draw_colored_polygon(PackedVector2Array([
		Vector2(1175.0, 105.0), Vector2(1215.0, 130.0),
		Vector2(1205.0, 145.0), Vector2(1165.0, 120.0)
	]), Color(0.65, 0.82, 0.88, 0.85))

	# Organic watercolor pigment dab spots & hand notes
	var sw_cols = [INK_RED, INK_GOLD, INK_MINT, INK_BLUE, INK_PURPLE, Color("#e17055"), Color("#00cec9")]
	for i in range(sw_cols.size()):
		var sy: float = 160.0 + float(i) * 46.0
		var dab_center := Vector2(1020.0, sy)
		# Hand-dabbed watercolor spot (multi-ring soft pigment bleed)
		draw_circle(dab_center, 15.0, Color(sw_cols[i].r, sw_cols[i].g, sw_cols[i].b, 0.25))
		draw_circle(dab_center, 11.0, sw_cols[i])
		draw_arc(dab_center, 12.0, 0.0, TAU, 16, INK_MAIN, 1.4)
		# Hand-written label ink notes
		draw_line(Vector2(1048.0, sy - 2.0), Vector2(1165.0, sy - 2.0), INK_MAIN, 1.6)
		draw_line(Vector2(1048.0, sy + 7.0), Vector2(1125.0, sy + 7.0), INK_SOFT, 1.2)

# =============================================================================
# 8. MICROSCOPIC PRECISION ZOOM (Beat 9)
# =============================================================================
# Warm studio environment maintained! Zero full-screen dark wipes or sniper grids!
# =============================================================================
func _draw_microscopic_zoom(rect: Rect2) -> void:
	# 1. Warm studio paper canvas base
	draw_rect(rect, CANVAS_PAPER)
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), CANVAS_WARM_FLOOR)
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# 2. Cozy studio backdrop elements
	# Warm drafting sheet pinned to wall behind Nemi
	var model_sheet := Rect2(380.0, 120.0, 520.0, 360.0)
	draw_rect(model_sheet, Color("#fffdf6"))
	draw_rect(model_sheet, INK_SOFT, false, 1.8)
	# Soft cyan drafting blueprint grid on sheet
	var grid_col := Color(0.2, 0.6, 0.8, 0.12)
	for gx in range(400, 890, 30):
		draw_line(Vector2(float(gx), 130.0), Vector2(float(gx), 470.0), grid_col, 1.0)
	for gy in range(140, 470, 30):
		draw_line(Vector2(390.0, float(gy)), Vector2(890.0, float(gy)), grid_col, 1.0)

	# Washi tape strips holding the model sheet
	draw_colored_polygon(PackedVector2Array([
		Vector2(440.0, 110.0), Vector2(490.0, 110.0),
		Vector2(488.0, 128.0), Vector2(438.0, 128.0)
	]), Color(0.9, 0.75, 0.6, 0.8))
	draw_colored_polygon(PackedVector2Array([
		Vector2(780.0, 110.0), Vector2(830.0, 110.0),
		Vector2(828.0, 128.0), Vector2(778.0, 128.0)
	]), Color(0.9, 0.75, 0.6, 0.8))

	# Soft warm studio accent lighting on desk
	draw_colored_polygon(PackedVector2Array([
		Vector2(180.0, 60.0), Vector2(1100.0, 520.0),
		Vector2(180.0, 520.0)
	]), Color(1.0, 0.96, 0.88, 0.12))

# =============================================================================
# 9. WARM CELEBRATORY WRAPUP (Beat 10)
# =============================================================================
func _draw_warm_wrapup(rect: Rect2) -> void:
	# Festive warm golden studio atmosphere
	draw_rect(rect, Color("#fff8f0"))
	draw_rect(Rect2(-200.0, 520.0, 1700.0, 400.0), Color("#f2e9dc"))
	draw_line(Vector2(-100.0, 520.0), Vector2(1400.0, 520.0), INK_MAIN, 2.8)

	# Wavy hand-drawn bunting pennant string across top
	var pennant_cols = [INK_RED, INK_GOLD, INK_MINT, INK_BLUE, INK_PURPLE]
	var string_pts := PackedVector2Array()
	for i in range(16):
		var px: float = 40.0 + float(i) * 80.0
		var py: float = 60.0 + sin(float(i) * 0.4) * 16.0
		string_pts.append(Vector2(px, py))
	draw_polyline(string_pts, INK_SOFT, 1.8)

	for i in range(14):
		var p1 := string_pts[i]
		var p2 := string_pts[i + 1]
		var p_mid := (p1 + p2) * 0.5 + Vector2(0.0, 40.0 + sin(float(i)) * 4.0)
		draw_colored_polygon(PackedVector2Array([p1, p2, p_mid]), pennant_cols[i % pennant_cols.size()])
		draw_polyline(PackedVector2Array([p1, p2, p_mid, p1]), INK_MAIN, 1.4)

	# Golden starbursts floating gently in background
	for s_idx in range(6):
		var sx: float = 160.0 + float(s_idx) * 190.0 + sin(sparkle_phase + float(s_idx)) * 10.0
		var sy: float = 160.0 + float((s_idx * 53) % 220) + cos(sparkle_phase + float(s_idx)) * 8.0
		_draw_star(Vector2(sx, sy), 15.0, INK_GOLD)

	# Framed Master Film Reel on Right Wall
	var reel_rect := Rect2(980.0, 140.0, 220.0, 280.0)
	draw_rect(reel_rect, Color("#ffffff"))
	draw_rect(reel_rect, INK_MAIN, false, 3.2)
	draw_rect(Rect2(1000.0, 160.0, 180.0, 180.0), Color("#2d3436"))
	for sp in range(6):
		draw_rect(Rect2(1005.0, 170.0 + float(sp) * 28.0, 12.0, 16.0), Color("#ffffff"))
		draw_rect(Rect2(1163.0, 170.0 + float(sp) * 28.0, 12.0, 16.0), Color("#ffffff"))
	_draw_star(Vector2(1090.0, 250.0), 26.0, INK_GOLD)

func _draw_star(center: Vector2, rad: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var r_in := rad * 0.38
	for i in range(8):
		var ang: float = float(i) * PI * 0.25 - PI * 0.5
		var r: float = rad if (i % 2 == 0) else r_in
		pts.append(center + Vector2(cos(ang) * r, sin(ang) * r))
	pts.append(pts[0])
	draw_colored_polygon(pts, col)
	draw_polyline(pts, INK_MAIN, 1.4)
