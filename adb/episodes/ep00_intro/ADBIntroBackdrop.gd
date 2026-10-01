class_name ADBIntroBackdrop
extends Node2D

## ADBIntroBackdrop — Master Hand-Illustrated Environment for ADB Episode 00
## "HI, I'M ADB."
##
## 100% Hand-Drawn Storytime Visual Language:
## - Base canvas: Warm cream sketchbook paper (#faf6ee / #f4ede2)
## - Diegetic hand-inked linework (#2b2623) with subtle watercolor tonal washes.
## - Rich environmental detailing: studio furniture, window with daylight, bookshelves,
##   table tennis arena, gaming station, manga walls, gym mirror & racks, engineering blueprints.

const PAPER_COLOR: Color = Color("#faf6ee")
const PAPER_WARM: Color = Color("#f4ede2")
const PAPER_FLOOR: Color = Color("#ede4d3")
const INK_CONTOUR: Color = Color("#2b2623")
const INK_FAINT: Color = Color(0.17, 0.15, 0.14, 0.18)
const INK_SOFT: Color = Color(0.17, 0.15, 0.14, 0.35)
const INK_ACCENT: Color = Color(0.85, 0.47, 0.15, 0.28)
const INK_BLUE: Color = Color(0.12, 0.45, 0.85, 0.25)
const INK_RED: Color = Color(0.85, 0.22, 0.22, 0.30)

enum EnvironmentMode {
	STUDIO_NEUTRAL,     # Beat 1 & 2: Cozy modern creator space with desk, window, shelves
	TABLE_TENNIS_ARENA, # Beat 3: Tournament table tennis court, scoreboard, arena bleachers
	GAMING_CORNER,      # Beat 4: RGB gaming lounge, ultrawide screen, console shelves
	ANIME_REALM,        # Beat 5: Dynamic multi-panel manga spread, endless book stacks
	GYM_FLOOR,          # Beat 6: Fitness studio with mirror, dumbbell racks, squat cage
	ENGINEERING_OFFICE, # Beat 7: Blueprint drafting desk, schematics, circuit traces, math formulas
	TIMELINE_VOID,      # Beat 8: Overwhelming multi-tier digital editing timeline dimension
	GIRLFRIEND_CORNER,  # Beat 9: Cozy studio with warm lamp glow & mystery shadow corner
	OUTRO_STAGE         # Beat 10: Warm festive creator space with banner & stage lighting
}

@export var mode: EnvironmentMode = EnvironmentMode.STUDIO_NEUTRAL
var speedline_intensity: float = 0.0
var bg_color: Color = PAPER_COLOR
var _color_tween: Tween

func _process(_delta: float) -> void:
	queue_redraw()

func set_mode(new_mode: EnvironmentMode, transition_dur: float = 0.25) -> void:
	mode = new_mode
	var target_col := PAPER_COLOR
	match mode:
		EnvironmentMode.ANIME_REALM:
			target_col = Color("#fcf9f2")
		EnvironmentMode.ENGINEERING_OFFICE:
			target_col = Color("#f2f6fa")
		EnvironmentMode.GYM_FLOOR:
			target_col = Color("#f5f2eb")
		EnvironmentMode.GAMING_CORNER:
			target_col = Color("#f4f0f7")
		EnvironmentMode.TABLE_TENNIS_ARENA:
			target_col = Color("#f0f7f3")
		_:
			target_col = PAPER_COLOR

	if _color_tween and _color_tween.is_valid():
		_color_tween.kill()
	_color_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_color_tween.tween_property(self, "bg_color", target_col, transition_dur)

func _draw() -> void:
	# 1. Base Canvas with generous bleed margin (-600 to 2520, -400 to 1480)
	draw_rect(Rect2(-600, -400, 3120, 1880), bg_color, true)

	# 2. Floor Grounding Baseline (Floor line at Y = 840 with full bleed)
	var floor_y := 840.0
	draw_rect(Rect2(-600, floor_y, 3120, 640), PAPER_FLOOR, true)
	draw_line(Vector2(-600, floor_y), Vector2(2520, floor_y), INK_CONTOUR, 3.2)

	# Floor perspective wooden planks (warm storybook room grounding)
	var plank_xs := [-160.0, 140.0, 380.0, 680.0, 1020.0, 1340.0, 1660.0, 1940.0, 2220.0]
	for px in plank_xs:
		draw_line(Vector2(px, floor_y), Vector2(px - 90.0, 1180), INK_FAINT, 1.8)
		# Occasional wood grain knot
		draw_arc(Vector2(px - 45.0, floor_y + 110), 12.0, 0.2, PI * 0.9, 12, INK_FAINT, 1.2)

	# 3. Mode-specific rich environmental illustrations
	match mode:
		EnvironmentMode.STUDIO_NEUTRAL, EnvironmentMode.OUTRO_STAGE:
			_draw_studio_environment(floor_y)
		EnvironmentMode.TABLE_TENNIS_ARENA:
			_draw_table_tennis_environment(floor_y)
		EnvironmentMode.GAMING_CORNER:
			_draw_gaming_environment(floor_y)
		EnvironmentMode.ANIME_REALM:
			_draw_anime_environment(floor_y)
		EnvironmentMode.GYM_FLOOR:
			_draw_gym_environment(floor_y)
		EnvironmentMode.ENGINEERING_OFFICE:
			_draw_engineering_environment(floor_y)
		EnvironmentMode.TIMELINE_VOID:
			_draw_timeline_environment(floor_y)
		EnvironmentMode.GIRLFRIEND_CORNER:
			_draw_girlfriend_corner_environment(floor_y)

# =========================================================================
# 1. STUDIO / CREATOR ROOM (Beats 1, 2, 10)
# =========================================================================
func _draw_studio_environment(floor_y: float) -> void:
	# Room corner perspective
	draw_line(Vector2(1440, 60), Vector2(1440, floor_y), INK_FAINT, 2.0)
	draw_line(Vector2(1440, floor_y), Vector2(1920, floor_y + 90), INK_FAINT, 2.0)

	# Large Sunlit Window (Left wall: X=100..420, Y=160..600)
	var win_rect := Rect2(100, 160, 320, 440)
	draw_rect(win_rect, Color(0.92, 0.96, 1.0, 0.45), true)
	draw_rect(win_rect, INK_CONTOUR, false, 3.2)
	# Window crossbars
	draw_line(Vector2(260, 160), Vector2(260, 600), INK_CONTOUR, 2.2)
	draw_line(Vector2(100, 380), Vector2(420, 380), INK_CONTOUR, 2.2)
	# Curtains on both sides
	draw_polyline(PackedVector2Array([
		Vector2(85, 140), Vector2(120, 170), Vector2(95, 360), Vector2(115, 620), Vector2(85, 620)
	]), INK_FAINT, 2.0)
	draw_polyline(PackedVector2Array([
		Vector2(435, 140), Vector2(400, 170), Vector2(425, 360), Vector2(405, 620), Vector2(435, 620)
	]), INK_FAINT, 2.0)

	# Hanging wall shelves (Left center: X=480..820)
	_draw_shelf(Vector2(500, 260), 320, [
		{"type": "plant", "offset": 30},
		{"type": "books", "offset": 120, "count": 6},
		{"type": "mug", "offset": 260}
	])
	_draw_shelf(Vector2(540, 420), 260, [
		{"type": "books", "offset": 40, "count": 8},
		{"type": "figure", "offset": 190}
	])

	# Studio Desk Setup (Right side: X=1200..1840)
	var desk_top_y := floor_y - 200.0
	# Desk surface
	draw_line(Vector2(1200, desk_top_y), Vector2(1880, desk_top_y), INK_CONTOUR, 3.5)
	draw_line(Vector2(1260, desk_top_y), Vector2(1260, floor_y), INK_CONTOUR, 3.0)
	draw_line(Vector2(1820, desk_top_y), Vector2(1820, floor_y), INK_CONTOUR, 3.0)

	# Dual Monitors on desk
	# Primary wide monitor (X=1340..1660, Y=desk_top_y-240..desk_top_y-30)
	var mon_rect := Rect2(1340, desk_top_y - 230, 320, 190)
	draw_rect(mon_rect, Color(0.12, 0.15, 0.20, 0.20), true)
	draw_rect(mon_rect, INK_CONTOUR, false, 2.8)
	draw_line(Vector2(1500, desk_top_y - 40), Vector2(1500, desk_top_y), INK_CONTOUR, 4.0)
	draw_line(Vector2(1460, desk_top_y), Vector2(1540, desk_top_y), INK_CONTOUR, 3.0)
	# Screen window layout lines (video timeline preview on monitor)
	draw_line(Vector2(1360, desk_top_y - 80), Vector2(1640, desk_top_y - 80), Color("#0984e3", 0.5), 2.0)
	draw_rect(Rect2(1360, desk_top_y - 210, 180, 110), Color(0.9, 0.6, 0.2, 0.3), true)

	# Secondary portrait monitor (X=1680..1820)
	var p_mon := Rect2(1680, desk_top_y - 250, 130, 210)
	draw_rect(p_mon, Color(0.12, 0.15, 0.20, 0.15), true)
	draw_rect(p_mon, INK_CONTOUR, false, 2.2)

	# Pen Tablet on desk surface
	draw_rect(Rect2(1360, desk_top_y + 20, 140, 80), Color(0.2, 0.2, 0.25, 0.2), true)
	draw_rect(Rect2(1360, desk_top_y + 20, 140, 80), INK_CONTOUR, false, 1.8)
	# Pen holder with stylus
	draw_rect(Rect2(1520, desk_top_y + 35, 24, 45), INK_FAINT, false, 1.8)
	draw_line(Vector2(1532, desk_top_y + 35), Vector2(1540, desk_top_y - 15), INK_CONTOUR, 2.2)

	# Steaming coffee mug
	draw_rect(Rect2(1280, desk_top_y + 40, 32, 38), Color(0.85, 0.5, 0.2, 0.3), true)
	draw_rect(Rect2(1280, desk_top_y + 40, 32, 38), INK_CONTOUR, false, 2.0)
	# Steam curls
	draw_arc(Vector2(1292, desk_top_y + 22), 8.0, 0.0, PI * 0.8, 8, INK_FAINT, 1.5)
	draw_arc(Vector2(1302, desk_top_y + 10), 8.0, PI * 0.2, PI, 8, INK_FAINT, 1.5)

	# Framed anime poster on wall (X=900..1160, Y=140..360)
	var post_rect := Rect2(920, 140, 220, 210)
	draw_rect(post_rect, Color(0.96, 0.92, 0.85, 0.5), true)
	draw_rect(post_rect, INK_CONTOUR, false, 2.5)
	# Poster silhouette artwork (stylized anime sword fighter)
	draw_line(Vector2(950, 280), Vector2(1090, 280), INK_FAINT, 1.5)
	draw_circle(Vector2(1020, 200), 22.0, Color(0.9, 0.3, 0.2, 0.3))
	draw_line(Vector2(1020, 220), Vector2(1020, 280), INK_CONTOUR, 2.2)

# =========================================================================
# 2. TABLE TENNIS ARENA (Beat 3)
# =========================================================================
func _draw_table_tennis_environment(floor_y: float) -> void:
	# Arena Bleachers & Wall Banner (Background)
	draw_rect(Rect2(80, 80, 1760, 140), Color(0.15, 0.35, 0.25, 0.12), true)
	draw_rect(Rect2(80, 80, 1760, 140), INK_CONTOUR, false, 2.8)
	# Banner title
	draw_line(Vector2(100, 150), Vector2(1820, 150), INK_FAINT, 1.5)

	# Electronic Scoreboard (Center background: X=820..1100, Y=100..200)
	var sc_rect := Rect2(800, 95, 320, 110)
	draw_rect(sc_rect, Color(0.10, 0.12, 0.15, 0.85), true)
	draw_rect(sc_rect, INK_CONTOUR, false, 3.0)
	# Digital LED scores
	# "ADB 11" (Green)
	draw_rect(Rect2(840, 130, 40, 50), Color("#00b894"), true)
	draw_rect(Rect2(890, 130, 40, 50), Color("#00b894"), true)
	# "OPP 00" (Red)
	draw_rect(Rect2(990, 130, 40, 50), Color("#d63031"), true)
	draw_rect(Rect2(1040, 130, 40, 50), Color("#d63031"), true)

	# Regulation Table Tennis Table (Left center: X=180..680)
	var table_top_y := floor_y - 140.0
	var table_pts := PackedVector2Array([
		Vector2(160, table_top_y + 40),
		Vector2(560, table_top_y - 40),
		Vector2(740, table_top_y + 30),
		Vector2(320, table_top_y + 110)
	])
	# Dark tournament green surface
	draw_colored_polygon(table_pts, Color(0.08, 0.42, 0.30, 0.70))
	draw_polyline(table_pts, INK_CONTOUR, 3.2, true)
	# White regulation perimeter lines
	draw_polyline(table_pts, Color("#ffffff"), 1.8, true)
	# Table Net
	var net_pts := PackedVector2Array([
		Vector2(440, table_top_y - 20), Vector2(440, table_top_y - 70),
		Vector2(540, table_top_y + 20), Vector2(540, table_top_y + 70)
	])
	draw_colored_polygon(net_pts, Color(0.9, 0.9, 0.9, 0.5))
	draw_polyline(net_pts, INK_CONTOUR, 2.5, true)
	# Table steel legs
	draw_line(Vector2(220, table_top_y + 70), Vector2(220, floor_y), INK_CONTOUR, 4.0)
	draw_line(Vector2(680, table_top_y + 50), Vector2(680, floor_y), INK_CONTOUR, 4.0)
	draw_line(Vector2(420, table_top_y + 30), Vector2(420, floor_y), INK_CONTOUR, 3.5)

	# Arena Floor court boundary lines
	draw_line(Vector2(120, floor_y + 50), Vector2(1800, floor_y + 50), Color(0.85, 0.25, 0.2, 0.4), 3.0)

	# Dynamic anime speedlines if active
	if speedline_intensity > 0.05:
		var alpha := speedline_intensity * 0.5
		for r_idx in range(24):
			var angle := float(r_idx) * (TAU / 24.0)
			var start_p := Vector2(960, 520) + Vector2(cos(angle), sin(angle)) * 340.0
			var end_p := Vector2(960, 520) + Vector2(cos(angle), sin(angle)) * 1200.0
			draw_line(start_p, end_p, Color(0.85, 0.22, 0.2, alpha), 3.0)

# =========================================================================
# 3. GAMING CORNER (Beat 4)
# =========================================================================
func _draw_gaming_environment(floor_y: float) -> void:
	# Ambient RGB ambient wall wash (purple / cyan glow)
	var glow_col := Color(0.42, 0.22, 0.85, 0.12)
	draw_circle(Vector2(1440, 480), 380.0, glow_col)
	draw_circle(Vector2(1440, 480), 220.0, Color(0.0, 0.8, 0.8, 0.10))

	# Gaming Desk & Ultrawide Curved Display (X=1180..1860)
	var desk_y := floor_y - 210.0
	draw_line(Vector2(1180, desk_y), Vector2(1860, desk_y), INK_CONTOUR, 3.5)
	draw_line(Vector2(1220, desk_y), Vector2(1220, floor_y), INK_CONTOUR, 3.0)
	draw_line(Vector2(1820, desk_y), Vector2(1820, floor_y), INK_CONTOUR, 3.0)

	# Huge curved monitor (X=1260..1760, Y=desk_y-260..desk_y-40)
	var mon_pts := PackedVector2Array([
		Vector2(1260, desk_y - 250), Vector2(1510, desk_y - 265), Vector2(1760, desk_y - 250),
		Vector2(1760, desk_y - 45), Vector2(1510, desk_y - 30), Vector2(1260, desk_y - 45)
	])
	draw_colored_polygon(mon_pts, Color(0.08, 0.10, 0.15, 0.90))
	draw_polyline(mon_pts, INK_CONTOUR, 3.2, true)
	# In-game HUD lines on screen (mini-map, health bars)
	draw_rect(Rect2(1280, desk_y - 230, 60, 60), Color(0.0, 0.8, 0.8, 0.6), true)
	draw_rect(Rect2(1440, desk_y - 70, 140, 14), Color(0.1, 0.9, 0.3, 0.8), true)

	# RGB Gaming PC Tower on desk (Right side)
	var pc_rect := Rect2(1780, desk_y - 220, 80, 200)
	draw_rect(pc_rect, Color(0.15, 0.16, 0.20, 0.8), true)
	draw_rect(pc_rect, INK_CONTOUR, false, 2.5)
	# Glowing fan circles
	draw_circle(Vector2(1820, desk_y - 160), 24.0, Color(0.9, 0.2, 0.6, 0.7))
	draw_circle(Vector2(1820, desk_y - 80), 24.0, Color(0.2, 0.6, 0.9, 0.7))

	# Console game cases stacked on shelf (Left side)
	_draw_shelf(Vector2(200, 340), 380, [
		{"type": "games", "offset": 40, "count": 12},
		{"type": "headset", "offset": 260}
	])

# =========================================================================
# 4. ANIME REALM (Beat 5)
# =========================================================================
func _draw_anime_environment(floor_y: float) -> void:
	# Multi-panel dynamic manga layout borders
	draw_rect(Rect2(60, 50, 1800, 980), INK_CONTOUR, false, 4.0)
	draw_line(Vector2(60, 360), Vector2(620, 360), INK_CONTOUR, 3.0)
	draw_line(Vector2(620, 50), Vector2(620, floor_y), INK_CONTOUR, 3.0)
	draw_line(Vector2(1320, 50), Vector2(1320, floor_y), INK_CONTOUR, 3.0)

	# Left Panel: Packed Manga Bookshelf (Floor to ceiling)
	var shelf_ys := [160.0, 320.0, 480.0, 640.0, 800.0]
	for sy in shelf_ys:
		draw_line(Vector2(80, sy), Vector2(600, sy), INK_CONTOUR, 2.5)
		# Tightly packed colored manga volumes
		var cols := [Color("#e17055"), Color("#0984e3"), Color("#6c5ce7"), Color("#00b894"), Color("#fdcb6e"), Color("#d63031")]
		for b_idx in range(16):
			var bx := 90.0 + float(b_idx) * 31.0
			var c: Color = cols[b_idx % cols.size()]
			draw_rect(Rect2(bx, sy - 110, 27, 108), c, true)
			draw_rect(Rect2(bx, sy - 110, 27, 108), INK_CONTOUR, false, 1.8)

	# Right Panel: Action Manga Screentone & Speedlines
	for i in range(18):
		var y_pos := 80.0 + float(i) * 42.0
		draw_line(Vector2(1340, y_pos), Vector2(1840, y_pos - 30), INK_FAINT, 1.5)

	# Radiating dramatic speedlines behind center character
	for i in range(28):
		var ang := float(i) * (TAU / 28.0)
		var p1 := Vector2(960, 480) + Vector2(cos(ang) * 420, sin(ang) * 320)
		var p2 := Vector2(960, 480) + Vector2(cos(ang) * 1200, sin(ang) * 900)
		draw_line(p1, p2, Color(0.17, 0.15, 0.14, 0.25), 2.2)

# =========================================================================
# 5. GYM FLOOR (Beat 6)
# =========================================================================
func _draw_gym_environment(floor_y: float) -> void:
	# Large Full-Length Studio Mirror (Center wall: X=640..1280, Y=140..800)
	var mirror_rect := Rect2(640, 140, 640, 660)
	draw_rect(mirror_rect, Color(0.92, 0.95, 0.98, 0.55), true)
	draw_rect(mirror_rect, INK_CONTOUR, false, 3.5)
	# Diagonal mirror reflection sheen lines
	draw_line(Vector2(700, 160), Vector2(1200, 780), Color(1, 1, 1, 0.6), 2.5)
	draw_line(Vector2(760, 160), Vector2(1260, 780), Color(1, 1, 1, 0.4), 2.0)

	# Multi-tier Dumbbell Rack (Left wall: X=100..560)
	var rack_ys := [floor_y - 240.0, floor_y - 120.0]
	for ry in rack_ys:
		draw_line(Vector2(120, ry), Vector2(540, ry), INK_CONTOUR, 3.2)
		draw_line(Vector2(120, ry + 25), Vector2(540, ry + 25), INK_CONTOUR, 2.5)
		# Dumbbell rows on rack
		for d in range(5):
			var dx := 160.0 + float(d) * 80.0
			draw_rect(Rect2(dx - 12, ry - 30, 24, 60), Color("#2d3436"), true)
			draw_line(Vector2(dx - 25, ry), Vector2(dx + 25, ry), Color("#b2bec3"), 5.0)

	# Olympic Squat Cage / Barbell Silhouette (Right wall: X=1360..1820)
	draw_line(Vector2(1420, 140), Vector2(1420, floor_y), INK_CONTOUR, 4.0)
	draw_line(Vector2(1760, 140), Vector2(1760, floor_y), INK_CONTOUR, 4.0)
	draw_line(Vector2(1420, 200), Vector2(1760, 200), INK_CONTOUR, 4.0)
	# Barbell loaded with plates
	var bar_y := floor_y - 260.0
	draw_line(Vector2(1380, bar_y), Vector2(1800, bar_y), Color("#7f8c8d"), 6.0)
	draw_rect(Rect2(1400, bar_y - 45, 16, 90), Color("#2d3436"), true)
	draw_rect(Rect2(1764, bar_y - 45, 16, 90), Color("#2d3436"), true)

	# Heavy floor rubber mat boundary
	draw_line(Vector2(0, floor_y + 40), Vector2(1920, floor_y + 40), Color("#d63031", 0.4), 3.0)

# =========================================================================
# 6. ENGINEERING OFFICE (Beat 7)
# =========================================================================
func _draw_engineering_environment(floor_y: float) -> void:
	# Technical Blueprint Grid across entire canvas
	var grid_color := Color(0.1, 0.4, 0.85, 0.10)
	for x in range(18):
		var gx := 80.0 + float(x) * 105.0
		draw_line(Vector2(gx, 40), Vector2(gx, floor_y), grid_color, 1.2)
	for y in range(8):
		var gy := 60.0 + float(y) * 100.0
		draw_line(Vector2(60, gy), Vector2(1860, gy), grid_color, 1.2)

	# Left Wall Whiteboard with Flowcharts & Circuit Diagrams
	var wb_rect := Rect2(120, 120, 480, 420)
	draw_rect(wb_rect, Color(1, 1, 1, 0.85), true)
	draw_rect(wb_rect, INK_CONTOUR, false, 3.2)
	# Mathematical formulas
	draw_line(Vector2(160, 180), Vector2(340, 180), INK_CONTOUR, 2.0)
	draw_circle(Vector2(200, 260), 25.0, INK_CONTOUR, false, 2.0)
	draw_rect(Rect2(280, 235, 70, 50), INK_CONTOUR, false, 2.0)
	draw_line(Vector2(225, 260), Vector2(280, 260), INK_CONTOUR, 2.0)
	draw_line(Vector2(350, 260), Vector2(420, 260), INK_CONTOUR, 2.0)
	draw_rect(Rect2(420, 235, 70, 50), Color(0.1, 0.5, 0.9, 0.2), true)
	draw_rect(Rect2(420, 235, 70, 50), INK_CONTOUR, false, 2.0)

	# Right Wall: Isometric Mechanical CAD Diagram
	var cad_center := Vector2(1540, 320)
	draw_rect(Rect2(cad_center.x - 140, cad_center.y - 140, 280, 280), Color(0.1, 0.4, 0.8, 0.08), true)
	draw_rect(Rect2(cad_center.x - 140, cad_center.y - 140, 280, 280), INK_CONTOUR, false, 2.2)
	# Isometric cube & gear lines
	draw_line(cad_center - Vector2(100, 100), cad_center + Vector2(100, 100), INK_FAINT, 1.5)
	draw_line(cad_center - Vector2(-100, 100), cad_center + Vector2(-100, 100), INK_FAINT, 1.5)
	draw_circle(cad_center, 65.0, INK_CONTOUR, false, 2.0)
	for g in range(12):
		var a := float(g) * (TAU / 12.0)
		draw_line(cad_center + Vector2(cos(a) * 65, sin(a) * 65), cad_center + Vector2(cos(a) * 82, sin(a) * 82), INK_CONTOUR, 3.5)

# =========================================================================
# 7. TIMELINE VOID (Beat 8)
# =========================================================================
func _draw_timeline_environment(floor_y: float) -> void:
	# Cascading Multi-Track Timeline Grid covering top half (Y=80..680)
	var t_col := Color(0.35, 0.20, 0.60, 0.16)
	var tracks := ["V6", "V5", "V4", "V3", "V2", "V1", "A1", "A2", "A3", "A4"]
	for i in range(tracks.size()):
		var ty := 100.0 + float(i) * 58.0
		draw_line(Vector2(60, ty), Vector2(1860, ty), t_col, 1.8)
		# Track header box (left)
		draw_rect(Rect2(60, ty - 26, 80, 52), Color(0.15, 0.16, 0.22, 0.35), true)
		draw_rect(Rect2(60, ty - 26, 80, 52), INK_CONTOUR, false, 1.5)

		# Random multi-colored video clips along track
		var clip_x1 := 160.0 + (float(i * 97) + 50.0)
		var clip_w1 := 240.0 + float((i * 43) % 200)
		draw_rect(Rect2(clip_x1, ty - 22, clip_w1, 44), Color(0.1, 0.5, 0.85, 0.35), true)
		draw_rect(Rect2(clip_x1, ty - 22, clip_w1, 44), INK_CONTOUR, false, 1.8)

		var clip_x2 := clip_x1 + clip_w1 + 40.0
		var clip_w2 := 320.0 + float((i * 67) % 250)
		if clip_x2 + clip_w2 < 1840.0:
			draw_rect(Rect2(clip_x2, ty - 22, clip_w2, 44), Color(0.85, 0.3, 0.6, 0.35), true)
			draw_rect(Rect2(clip_x2, ty - 22, clip_w2, 44), INK_CONTOUR, false, 1.8)

	# Vertical red scrubbing playhead cutting through all tracks
	draw_line(Vector2(960, 60), Vector2(960, floor_y), Color("#d63031"), 3.5)

# =========================================================================
# 8. GIRLFRIEND CORNER (Beat 9)
# =========================================================================
func _draw_girlfriend_corner_environment(floor_y: float) -> void:
	_draw_studio_environment(floor_y)
	# Warm golden light pool on ADB's side (Left)
	var warm_glow := Color(0.98, 0.85, 0.55, 0.15)
	draw_circle(Vector2(880, 540), 450.0, warm_glow)

	# Mystery Shadow Corner on the right edge
	var shadow_col := Color(0.08, 0.06, 0.12, 0.12)
	draw_rect(Rect2(1360, 0, 560, 1080), shadow_col, true)
	draw_line(Vector2(1360, 0), Vector2(1360, floor_y), Color(0.11, 0.09, 0.14, 0.25), 2.5)

# =========================================================================
# HELPER: Hand-drawn shelf
# =========================================================================
func _draw_shelf(pos: Vector2, width: float, items: Array[Dictionary]) -> void:
	# Shelf wooden plank
	draw_line(pos, pos + Vector2(width, 0), INK_CONTOUR, 3.5)
	draw_line(pos + Vector2(20, 0), pos + Vector2(10, 30), INK_CONTOUR, 2.0)
	draw_line(pos + Vector2(width - 20, 0), pos + Vector2(width - 10, 30), INK_CONTOUR, 2.0)

	for it in items:
		var ox: float = it.get("offset", 0.0)
		var item_pos := pos + Vector2(ox, 0)
		match it.get("type", ""):
			"plant":
				draw_rect(Rect2(item_pos.x - 14, item_pos.y - 32, 28, 32), Color(0.8, 0.45, 0.2, 0.4), true)
				draw_rect(Rect2(item_pos.x - 14, item_pos.y - 32, 28, 32), INK_CONTOUR, false, 1.8)
				# Trailing leaves
				draw_arc(Vector2(item_pos.x - 8, item_pos.y - 42), 12.0, 0.0, PI * 0.8, 8, Color("#00b894"), 2.5)
				draw_arc(Vector2(item_pos.x + 8, item_pos.y - 48), 14.0, 0.2, PI, 8, Color("#00b894"), 2.5)
			"books":
				var count: int = it.get("count", 4)
				var b_cols := [Color("#e17055"), Color("#0984e3"), Color("#6c5ce7"), Color("#00b894")]
				for bi in range(count):
					var bx := item_pos.x + float(bi) * 16.0
					var bh := 45.0 + float((bi * 7) % 20)
					draw_rect(Rect2(bx, item_pos.y - bh, 14, bh), b_cols[bi % b_cols.size()], true)
					draw_rect(Rect2(bx, item_pos.y - bh, 14, bh), INK_CONTOUR, false, 1.5)
			"mug":
				draw_rect(Rect2(item_pos.x, item_pos.y - 30, 24, 30), Color(0.9, 0.3, 0.2, 0.4), true)
				draw_rect(Rect2(item_pos.x, item_pos.y - 30, 24, 30), INK_CONTOUR, false, 1.8)
			"figure":
				draw_rect(Rect2(item_pos.x, item_pos.y - 55, 20, 55), Color(0.2, 0.2, 0.25, 0.3), true)
				draw_rect(Rect2(item_pos.x, item_pos.y - 55, 20, 55), INK_CONTOUR, false, 1.5)
				draw_circle(Vector2(item_pos.x + 10, item_pos.y - 65), 10.0, Color(0.2, 0.2, 0.25, 0.3))
