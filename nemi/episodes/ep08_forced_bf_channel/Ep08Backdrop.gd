class_name Ep08Backdrop
extends Node2D

## Ep08Backdrop — Master Hand-Illustrated Dynamic Environments for Episode 08
## "I FORCED MY BF TO CREATE A CHANNEL"
##
## 100% Hand-Drawn Storybook Visual Language:
## - Base canvas: Warm cream sketchbook paper (#faf7f2 / #f5efe6)
## - ZERO pitch-black viewport flashes. All modes share warm paper continuity.
## - Diegetic hand-inked linework (#2b2623) with custom watercolor washes for each scene.
## - Ground plane: Floor level at Y = 840.0.

const INK_MAIN: Color = Color("#2b2623")
const INK_SOFT: Color = Color("#594f4b")
const INK_MUTED: Color = Color("#8a7c76")
const INK_RED: Color = Color("#b84328")
const INK_GOLD: Color = Color("#d35400")
const INK_BLUE: Color = Color("#2980b9")
const INK_GREEN: Color = Color("#27ae60")
const INK_WARM_SHADOW: Color = Color(0.18, 0.12, 0.10, 0.12)

const CANVAS_PAPER: Color = Color("#faf7f2")
const CANVAS_WALL: Color = Color("#f5efe6")
const CANVAS_FLOOR: Color = Color("#ede4d6")
const CANVAS_WOOD_TRIM: Color = Color("#dfd3c0")

enum EnvironmentMode {
	NORMAL_STUDIO,       # 0: Beat 1 Hook - Cozy animator studio with desk, tablet, window, plant
	ARCHIVAL_MEMORY,     # 1: Beat 2 Old ADB - Nostalgic museum exhibition / retro slide projector
	CRITIQUE_BOARD,      # 2: Beat 3 Hated Design - Critique corkboard, red critiques, crumpled drafts
	REDESIGN_WORKSHOP,   # 3: Beat 4 Redesign Studio - Blueprint cutting mat, palettes, artist easel
	CONSPIRACY_SCHEME,   # 4: Beat 5 Terrible Idea - Scheming whiteboard with red string yarn & coffee
	LIVING_ROOM,         # 5: Beat 6 Asking ADB - Apartment living room with couch, rug, ticking clock
	DUAL_STUDIO_SPLIT,   # 6: Beat 7 Two Channels - Dynamic split-screen (Nemi green vs ADB slate)
	ADB_STAGE,           # 7: Beat 8 ADB Intro - ADB's acoustic foam hex studio & warm floor lamp
	CELEBRATION_WRAPUP   # 8: Beat 9 Outro - Festive celebration studio with bunting & YouTube trophy
}

var current_mode: EnvironmentMode = EnvironmentMode.NORMAL_STUDIO
var target_mode: EnvironmentMode = EnvironmentMode.NORMAL_STUDIO
var mode_blend: float = 1.0
var _mode_tween: Tween

var _ambient_time: float = 0.0

func _ready() -> void:
	z_index = -10
	queue_redraw()

func _process(delta: float) -> void:
	_ambient_time += delta
	if mode_blend < 1.0:
		queue_redraw()

func set_mode(new_mode: int, _transition_duration: float = 0.0) -> void:
	target_mode = clampi(new_mode, 0, EnvironmentMode.size() - 1) as EnvironmentMode
	current_mode = target_mode
	mode_blend = 1.0
	if _mode_tween and _mode_tween.is_valid():
		_mode_tween.kill()
	queue_redraw()

func _draw() -> void:
	# 1. Base paper canvas
	draw_rect(Rect2(0, 0, 1920, 1080), CANVAS_PAPER)

	# 2. Draw specific background mode
	match current_mode:
		EnvironmentMode.NORMAL_STUDIO:
			_draw_mode_normal_studio()
		EnvironmentMode.ARCHIVAL_MEMORY:
			_draw_mode_archival_memory()
		EnvironmentMode.CRITIQUE_BOARD:
			_draw_mode_critique_board()
		EnvironmentMode.REDESIGN_WORKSHOP:
			_draw_mode_redesign_workshop()
		EnvironmentMode.CONSPIRACY_SCHEME:
			_draw_mode_conspiracy_scheme()
		EnvironmentMode.LIVING_ROOM:
			_draw_mode_living_room()
		EnvironmentMode.DUAL_STUDIO_SPLIT:
			_draw_mode_dual_studio_split()
		EnvironmentMode.ADB_STAGE:
			_draw_mode_adb_stage()
		EnvironmentMode.CELEBRATION_WRAPUP:
			_draw_mode_celebration_wrapup()

# =============================================================================
# HELPER: STANDARD BASEBOARD & FLOOR (Grounded at Y = 840)
# =============================================================================
func _draw_standard_floor(wall_color: Color = CANVAS_WALL, floor_color: Color = CANVAS_FLOOR) -> void:
	# Wall
	draw_rect(Rect2(0, 0, 1920, 840), wall_color)
	# Baseboard trim
	draw_rect(Rect2(0, 825, 1920, 15), CANVAS_WOOD_TRIM)
	draw_line(Vector2(0, 825), Vector2(1920, 825), INK_MUTED, 1.8)
	draw_line(Vector2(0, 840), Vector2(1920, 840), INK_MAIN, 2.5)
	# Floor
	draw_rect(Rect2(0, 840, 1920, 240), floor_color)
	# Perspective floor plank lines
	for x in [120, 480, 840, 1200, 1560]:
		draw_line(Vector2(x, 840), Vector2(x - 90, 1080), Color(0.18, 0.12, 0.10, 0.05), 1.5)

# =============================================================================
# MODE 0: NORMAL STUDIO (Beat 1 Hook)
# =============================================================================
func _draw_mode_normal_studio() -> void:
	_draw_standard_floor(CANVAS_WALL, CANVAS_FLOOR)

	# Studio Window (left) with morning light
	var win_rect := Rect2(140, 160, 240, 360)
	draw_rect(win_rect, Color("#ffffff", 0.9))
	draw_rect(win_rect, Color("#e8f4f8", 0.45))
	draw_rect(win_rect, INK_MAIN, false, 2.5)
	draw_line(Vector2(260, 160), Vector2(260, 520), INK_MAIN, 2.0)
	draw_line(Vector2(140, 340), Vector2(380, 340), INK_MAIN, 2.0)
	draw_rect(Rect2(120, 520, 280, 14), Color("#dcd2c2"))
	draw_rect(Rect2(120, 520, 280, 14), INK_MAIN, false, 2.0)

	# Potted succulent
	var pot_pts := PackedVector2Array([Vector2(165, 520), Vector2(195, 520), Vector2(190, 490), Vector2(170, 490)])
	draw_colored_polygon(pot_pts, Color("#d9886a"))
	draw_polyline(pot_pts, INK_MAIN, 2.0, true)
	draw_circle(Vector2(180, 480), 12.0, Color("#7ba685"))
	draw_arc(Vector2(180, 480), 12.0, 0, TAU, 14, INK_MAIN, 1.8)

	# Animator's Computer Desk & Drawing Tablet (left-center)
	draw_rect(Rect2(430, 580, 320, 245), Color("#d5c4a1")) # Desk surface
	draw_rect(Rect2(430, 580, 320, 245), INK_MAIN, false, 2.2)
	# Monitor on desk
	draw_rect(Rect2(470, 400, 180, 140), Color("#2b2b2b"))
	draw_rect(Rect2(478, 408, 164, 124), Color("#eaf2f8"))
	draw_rect(Rect2(470, 400, 180, 140), INK_MAIN, false, 2.0)
	# Monitor stand
	draw_line(Vector2(560, 540), Vector2(560, 580), INK_MAIN, 4.0)
	draw_line(Vector2(530, 580), Vector2(590, 580), INK_MAIN, 4.0)
	# Drawing tablet angled on desk
	var tab_pts := PackedVector2Array([Vector2(670, 550), Vector2(740, 530), Vector2(760, 570), Vector2(690, 590)])
	draw_colored_polygon(tab_pts, Color("#3d3d3d"))
	draw_polyline(tab_pts, INK_MAIN, 2.0, true)
	# Stylus pen
	draw_line(Vector2(705, 540), Vector2(735, 525), INK_GOLD, 2.5)

	# Corkboard with notes (right of monitor)
	var cb_rect := Rect2(820, 180, 340, 220)
	draw_rect(cb_rect, Color("#e6cca9"))
	draw_rect(cb_rect, INK_MAIN, false, 2.2)
	draw_rect(Rect2(850, 210, 75, 90), Color("#fffef5"))
	draw_rect(Rect2(850, 210, 75, 90), INK_SOFT, false, 1.5)
	draw_circle(Vector2(885, 215), 3.5, INK_RED)
	draw_rect(Rect2(950, 225, 80, 95), Color("#fffef5"))
	draw_rect(Rect2(950, 225, 80, 95), INK_SOFT, false, 1.5)
	draw_circle(Vector2(990, 230), 3.5, INK_BLUE)

	# Bookshelf (far right)
	var bs_rect := Rect2(1620, 140, 240, 685)
	draw_rect(bs_rect, Color("#dfd2c0"))
	draw_rect(bs_rect, INK_MAIN, false, 2.5)
	for y in [310, 480, 650]:
		draw_line(Vector2(1620, y), Vector2(1860, y), INK_MAIN, 2.2)
	# Books
	var book_cols := [Color("#b84328"), Color("#2980b9"), Color("#e67e22"), Color("#27ae60"), Color("#8e44ad")]
	for i in range(5):
		draw_rect(Rect2(1640 + i * 22, 210, 18, 100), book_cols[i])
		draw_rect(Rect2(1640 + i * 22, 210, 18, 100), INK_MAIN, false, 1.5)

# =============================================================================
# MODE 1: ARCHIVAL MEMORY (Beat 2 Old ADB Callback)
# =============================================================================
func _draw_mode_archival_memory() -> void:
	# Nostalgic sepia parchment wash
	_draw_standard_floor(Color("#ede3d2"), Color("#dfd3bf"))

	# Retro cinema / slide projector screen in center
	var screen_rect := Rect2(920, 110, 680, 715)
	draw_rect(screen_rect, Color("#f9f5ec"))
	draw_rect(screen_rect, Color("#dcd2be"), false, 8.0)
	draw_rect(screen_rect, INK_MAIN, false, 3.0)

	# Hanging projector screen cords
	draw_line(Vector2(1000, 0), Vector2(1000, 110), INK_MAIN, 2.0)
	draw_line(Vector2(1520, 0), Vector2(1520, 110), INK_MAIN, 2.0)

	# Archival film strip on far left
	draw_rect(Rect2(40, 60, 90, 760), Color("#2b2623"))
	for y in range(80, 800, 36):
		draw_rect(Rect2(50, y, 16, 22), Color("#faf7f2"))
		draw_rect(Rect2(104, y, 16, 22), Color("#faf7f2"))

	# Vintage stamp in corner: "ARCHIVED: 2024"
	var tag_rect := Rect2(940, 130, 220, 42)
	draw_rect(tag_rect, Color("#e74c3c", 0.15))
	draw_rect(tag_rect, INK_RED, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(955, 158), "ARCHIVE: 2024", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, INK_RED)

	# Subtle memory vignette rays
	draw_line(Vector2(920, 110), Vector2(1260, 460), Color(0.18, 0.12, 0.10, 0.04), 2.0)
	draw_line(Vector2(1600, 110), Vector2(1260, 460), Color(0.18, 0.12, 0.10, 0.04), 2.0)

# =============================================================================
# MODE 2: CRITIQUE BOARD (Beat 3 Hated Design)
# =============================================================================
func _draw_mode_critique_board() -> void:
	_draw_standard_floor(Color("#f0e8dc"), Color("#e5dcce"))

	# Giant Wall-Sized Critique Corkboard
	var cb_rect := Rect2(180, 90, 1560, 735)
	draw_rect(cb_rect, Color("#e8d1b0"))
	draw_rect(cb_rect, Color("#c7a77e"), false, 10.0)
	draw_rect(cb_rect, INK_MAIN, false, 3.0)

	# Pinned critique sticky notes
	var notes := [
		{"pos": Vector2(240, 140), "col": Color("#fffa65"), "txt": "TOO CHUNKY!"},
		{"pos": Vector2(380, 260), "col": Color("#ffaf40"), "txt": "WHY GOGGLES??"},
		{"pos": Vector2(260, 420), "col": Color("#ff7675"), "txt": "DISAPPROVED"},
		{"pos": Vector2(1420, 160), "col": Color("#70a1ff"), "txt": "HE HATED IT"},
		{"pos": Vector2(1440, 340), "col": Color("#fffa65"), "txt": "START OVER!"}
	]
	for n in notes:
		var p: Vector2 = n["pos"]
		draw_rect(Rect2(p.x, p.y, 140, 90), n["col"])
		draw_rect(Rect2(p.x, p.y, 140, 90), INK_SOFT, false, 1.5)
		draw_circle(Vector2(p.x + 70, p.y + 10), 3.5, INK_RED)
		draw_string(ThemeDB.fallback_font, Vector2(p.x + 12, p.y + 55), n["txt"], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, INK_MAIN)

	# Wire mesh trash bin on floor overflowing with crumpled drafts
	draw_rect(Rect2(150, 740, 75, 95), Color("#8a7c76", 0.35))
	draw_rect(Rect2(150, 740, 75, 95), INK_MAIN, false, 2.0)
	for i in range(4):
		draw_circle(Vector2(170 + i * 8, 735 - (i % 2) * 12), 10.0, Color("#ffffff"))
		draw_arc(Vector2(170 + i * 8, 735 - (i % 2) * 12), 10.0, 0, TAU, 10, INK_MAIN, 1.5)

# =============================================================================
# MODE 3: REDESIGN WORKSHOP (Beat 4 Redesign Studio & Reveal)
# =============================================================================
func _draw_mode_redesign_workshop() -> void:
	# Blueprint drafting studio aesthetic
	_draw_standard_floor(Color("#eaf0f4"), Color("#dce5eb"))

	# Large cutting mat / drafting grid in center wall
	var mat_rect := Rect2(440, 110, 1040, 715)
	draw_rect(mat_rect, Color("#f3f7fa"))
	draw_rect(mat_rect, Color("#34495e", 0.15), false, 4.0)
	draw_rect(mat_rect, INK_MAIN, false, 2.5)

	# Fine drafting grid lines
	for x in range(480, 1460, 60):
		draw_line(Vector2(x, 110), Vector2(x, 825), Color("#2980b9", 0.12), 1.0)
	for y in range(140, 825, 60):
		draw_line(Vector2(440, y), Vector2(1480, y), Color("#2980b9", 0.12), 1.0)

	# Color Palette Swatches on left
	var swatches := [
		{"col": Color("#34495e"), "name": "ONYX HAIR"},
		{"col": Color("#4a7056"), "name": "EMERALD SHIRT"},
		{"col": Color("#ede8df"), "name": "CREAM CHINOS"},
		{"col": Color("#ffd8cc"), "name": "SKIN TONE"}
	]
	for i in range(swatches.size()):
		var sy := 180 + i * 75
		draw_circle(Vector2(500, sy), 20.0, swatches[i]["col"])
		draw_arc(Vector2(500, sy), 20.0, 0, TAU, 18, INK_MAIN, 1.8)
		draw_string(ThemeDB.fallback_font, Vector2(535, sy + 6), swatches[i]["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, INK_MAIN)

	# Artist Wooden Easel (right side)
	var easel_pts := PackedVector2Array([
		Vector2(1650, 240), Vector2(1580, 835),
		Vector2(1650, 240), Vector2(1720, 835)
	])
	draw_polyline(easel_pts, Color("#8e6a47"), 5.0)
	draw_polyline(easel_pts, INK_MAIN, 1.5)
	# Easel shelf holding palette
	draw_line(Vector2(1550, 560), Vector2(1750, 560), Color("#8e6a47"), 7.0)
	draw_line(Vector2(1550, 560), Vector2(1750, 560), INK_MAIN, 2.0)

# =============================================================================
# MODE 4: CONSPIRACY SCHEME (Beat 5 Terrible Idea)
# =============================================================================
func _draw_mode_conspiracy_scheme() -> void:
	# Warm scheming amber atmosphere
	_draw_standard_floor(Color("#f7eedb"), Color("#ecdcb8"))

	# Detective / Scheming Board across upper wall
	var board := Rect2(200, 100, 1520, 540)
	draw_rect(board, Color("#e6cca9"))
	draw_rect(board, Color("#c4a57b"), false, 8.0)
	draw_rect(board, INK_MAIN, false, 2.8)

	# Pinned Scheme Cards
	var card_nemi := Rect2(300, 180, 220, 140)
	draw_rect(card_nemi, Color("#ffffff"))
	draw_rect(card_nemi, INK_MAIN, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(320, 250), "NEMI CHANNEL", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#27ae60"))
	draw_string(ThemeDB.fallback_font, Vector2(340, 285), "Storytime Animations", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK_SOFT)

	var card_adb := Rect2(1400, 180, 220, 140)
	draw_rect(card_adb, Color("#ffffff"))
	draw_rect(card_adb, INK_MAIN, false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(1430, 250), "ADB CHANNEL?", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#2980b9"))
	draw_string(ThemeDB.fallback_font, Vector2(1440, 285), "Storytime Animations!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK_SOFT)

	var card_chaos := Rect2(850, 360, 240, 150)
	draw_rect(card_chaos, Color("#fff9e6"))
	draw_rect(card_chaos, INK_RED, false, 2.5)
	draw_string(ThemeDB.fallback_font, Vector2(880, 420), "DOUBLE THE", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, INK_RED)
	draw_string(ThemeDB.fallback_font, Vector2(895, 455), "CONTENT!", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, INK_RED)

	# Red yarn string connecting cards
	draw_line(Vector2(520, 250), Vector2(850, 420), INK_RED, 3.0)
	draw_line(Vector2(1400, 250), Vector2(1090, 420), INK_RED, 3.0)
	draw_circle(Vector2(520, 250), 5.0, Color("#d63031"))
	draw_circle(Vector2(1400, 250), 5.0, Color("#d63031"))
	draw_circle(Vector2(970, 420), 5.0, Color("#d63031"))

# =============================================================================
# MODE 5: LIVING ROOM STANDOFF (Beat 6 Asking ADB)
# =============================================================================
func _draw_mode_living_room() -> void:
	_draw_standard_floor(Color("#f5ece1"), Color("#e6dac9"))

	# Cozy living room couch silhouette in background
	var couch_back := PackedVector2Array([
		Vector2(1050, 460), Vector2(1650, 460), Vector2(1670, 680), Vector2(1030, 680)
	])
	draw_colored_polygon(couch_back, Color("#637381"))
	draw_polyline(couch_back, INK_MAIN, 2.5, true)
	# Couch cushions
	draw_rect(Rect2(1040, 640, 300, 160), Color("#4b5966"))
	draw_rect(Rect2(1040, 640, 300, 160), INK_MAIN, false, 2.0)
	draw_rect(Rect2(1340, 640, 310, 160), Color("#4b5966"))
	draw_rect(Rect2(1340, 640, 310, 160), INK_MAIN, false, 2.0)

	# Wall Clock above ticking away time
	draw_circle(Vector2(960, 220), 45.0, Color("#ffffff"))
	draw_arc(Vector2(960, 220), 45.0, 0, TAU, 32, INK_MAIN, 2.5)
	# Clock hands (advancing)
	draw_line(Vector2(960, 220), Vector2(960, 190), INK_MAIN, 3.0)
	draw_line(Vector2(960, 220), Vector2(985, 230), INK_RED, 2.0)

	# Potted Fiddle Leaf Fig tree in left corner
	var stem := PackedVector2Array([Vector2(180, 840), Vector2(190, 680), Vector2(170, 520), Vector2(185, 380)])
	draw_polyline(stem, Color("#594433"), 5.0)
	draw_polyline(stem, INK_MAIN, 1.8)
	# Big green leaves
	for lp in [Vector2(160, 420), Vector2(210, 480), Vector2(150, 580), Vector2(215, 640)]:
		draw_circle(lp, 28.0, Color("#437355"))
		draw_arc(lp, 28.0, 0, TAU, 16, INK_MAIN, 1.8)

# =============================================================================
# MODE 6: DUAL STUDIO SPLIT (Beat 7 Two Channels)
# =============================================================================
func _draw_mode_dual_studio_split() -> void:
	# LEFT HALF (NEMI): Warm green wash
	draw_rect(Rect2(0, 0, 960, 840), Color("#edf5ee"))
	draw_rect(Rect2(0, 840, 960, 240), Color("#e4eee5"))
	# RIGHT HALF (ADB): Cool slate wash
	draw_rect(Rect2(960, 0, 960, 840), Color("#eaedf2"))
	draw_rect(Rect2(960, 840, 960, 240), Color("#dde2ea"))

	# Baseboards
	draw_rect(Rect2(0, 825, 1920, 15), CANVAS_WOOD_TRIM)
	draw_line(Vector2(0, 825), Vector2(1920, 825), INK_MUTED, 1.8)
	draw_line(Vector2(0, 840), Vector2(1920, 840), INK_MAIN, 2.5)

	# Hand-drawn torn paper seam down center (X = 960)
	var seam_pts := PackedVector2Array([
		Vector2(960, 0), Vector2(952, 140), Vector2(968, 280),
		Vector2(954, 440), Vector2(965, 590), Vector2(950, 720),
		Vector2(966, 840), Vector2(955, 960), Vector2(960, 1080)
	])
	draw_polyline(seam_pts, INK_MAIN, 3.5)

	# Left side banner: "NEMI STUDIO"
	var nemi_sign := Rect2(240, 80, 280, 55)
	draw_rect(nemi_sign, Color("#27ae60", 0.15))
	draw_rect(nemi_sign, Color("#27ae60"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(290, 117), "NEMI ANIMATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#27ae60"))

	# Right side banner: "ADB STUDIO"
	var adb_sign := Rect2(1400, 80, 280, 55)
	draw_rect(adb_sign, Color("#2980b9", 0.15))
	draw_rect(adb_sign, Color("#2980b9"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(1450, 117), "ADB ANIMATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#2980b9"))

# =============================================================================
# MODE 7: ADB STAGE (Beat 8 ADB Intro)
# =============================================================================
func _draw_mode_adb_stage() -> void:
	# Cool, sleek minimalist creator space
	_draw_standard_floor(Color("#e8edf2"), Color("#dde4ec"))

	# Acoustic Foam Hexagonal Wall Panels behind ADB (X: 1100 -> 1600, Y: 120 -> 500)
	var hex_centers := [
		Vector2(1180, 200), Vector2(1300, 200), Vector2(1420, 200),
		Vector2(1240, 280), Vector2(1360, 280), Vector2(1480, 280),
		Vector2(1180, 360), Vector2(1300, 360), Vector2(1420, 360)
	]
	for c in hex_centers:
		var pts := PackedVector2Array()
		for i in range(6):
			var th := (float(i) / 6.0) * TAU
			pts.append(c + Vector2(cos(th) * 45.0, sin(th) * 45.0))
		draw_colored_polygon(pts, Color("#34495e", 0.12))
		draw_polyline(pts, INK_MAIN, 1.8, true)

	# Minimalist Floor Lamp (far right)
	draw_line(Vector2(1740, 840), Vector2(1740, 340), INK_MAIN, 4.0)
	var shade := PackedVector2Array([
		Vector2(1710, 340), Vector2(1770, 340), Vector2(1790, 420), Vector2(1690, 420)
	])
	draw_colored_polygon(shade, Color("#f39c12", 0.75))
	draw_polyline(shade, INK_MAIN, 2.0, true)
	# Warm lamp light cone
	var cone := PackedVector2Array([
		Vector2(1740, 420), Vector2(1500, 840), Vector2(1900, 840)
	])
	draw_colored_polygon(cone, Color("#f39c12", 0.08))

# =============================================================================
# MODE 8: CELEBRATION WRAPUP (Beat 9 Outro)
# =============================================================================
func _draw_mode_celebration_wrapup() -> void:
	# Festive warm celebration atmosphere
	_draw_standard_floor(Color("#fdf7ee"), Color("#f4eada"))

	# Hand-Drawn Triangular Party Bunting across top ceiling
	var bunting_pts: Array[Vector2] = [
		Vector2(100, 60), Vector2(300, 110), Vector2(500, 70),
		Vector2(700, 110), Vector2(900, 75), Vector2(1100, 110),
		Vector2(1300, 70), Vector2(1500, 115), Vector2(1700, 75), Vector2(1850, 90)
	]
	var flag_cols: Array[Color] = [Color("#e74c3c"), Color("#f1c40f"), Color("#2ecc71"), Color("#3498db"), Color("#9b59b6")]
	for i in range(bunting_pts.size() - 1):
		draw_line(bunting_pts[i], bunting_pts[i + 1], INK_MAIN, 2.0)
		var mid: Vector2 = (bunting_pts[i] + bunting_pts[i + 1]) * 0.5
		var bunting_tri := PackedVector2Array([bunting_pts[i], bunting_pts[i + 1], mid + Vector2(0, 50)])
		draw_colored_polygon(bunting_tri, flag_cols[i % flag_cols.size()])
		draw_polyline(bunting_tri, INK_MAIN, 1.8, true)

	# Framed YouTube Play Button Trophy on wall (X = 960)
	var plaque := Rect2(870, 200, 180, 140)
	draw_rect(plaque, Color("#f1c40f", 0.25))
	draw_rect(plaque, INK_GOLD, false, 3.0)
	# Play triangle
	var play_tri := PackedVector2Array([Vector2(945, 250), Vector2(985, 270), Vector2(945, 290)])
	draw_colored_polygon(play_tri, INK_RED)
	draw_polyline(play_tri, INK_MAIN, 2.0, true)
	draw_string(ThemeDB.fallback_font, Vector2(915, 325), "WELCOME ADB!", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK_MAIN)
