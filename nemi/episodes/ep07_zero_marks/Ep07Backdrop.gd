class_name Ep07Backdrop
extends Node2D

## Ep07Backdrop - Master Hand-Illustrated Environment for Episode 07
## "I GOT 0 MARKS IN MY EXAM"
##
## 100% Hand-Drawn Storybook Visual Language:
## - Base canvas: Warm cream sketchbook paper (#faf7f2 / #f5efe6)
## - ZERO pitch-black viewport flashes. All modes share warm paper continuity.
## - Diegetic hand-inked linework (#2e1822 DNA) with warm watercolor washes.

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
	COVID_ONLINE,       # 1: Online college desk, floating class window shorthand, digital schedule
	COLLEGE_HALLWAY,    # 2: Physical college building with brick arch, sunlit corridor
	PROCRASTINATION,    # 3: Study corner with textbook, casual relaxed space
	EMAIL_PANIC,        # 4: Dramatic amber wash with stylized student panic silhouettes
	MIDNIGHT_STUDY,     # 5: Midnight paper tone with warm incandescent desk lamp light cone
	EXAM_HALL,          # 6: Institutional exam hall with rows of desks, wide floor perspective
	WRITING_FRENZY,     # 7: Dynamic high-focus exam desk with diagonal energy lines
	ZERO_REVEAL,        # 8: Dramatic crimson/charcoal impact wash spotlighting the exam paper
	WARM_WRAPUP         # 9: Warm studio with callback elements: 2 AM clock, crumpled notes, 0/30 paper
}

var current_mode: Mode = Mode.NORMAL_STUDIO
var blend_progress: float = 1.0
var _active_tween: Tween

var lamp_pulse: float = 0.0
var wave_phase: float = 0.0

func _ready() -> void:
	z_index = -5
	queue_redraw()

func _process(delta: float) -> void:
	lamp_pulse += delta * 2.0
	wave_phase += delta * 1.5
	if current_mode in [Mode.MIDNIGHT_STUDY, Mode.ZERO_REVEAL, Mode.EMAIL_PANIC] or (_active_tween and _active_tween.is_valid() and _active_tween.is_running()):
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
		Mode.COVID_ONLINE:
			_draw_covid_online(canvas_rect)
		Mode.COLLEGE_HALLWAY:
			_draw_college_hallway(canvas_rect)
		Mode.PROCRASTINATION:
			_draw_procrastination(canvas_rect)
		Mode.EMAIL_PANIC:
			_draw_email_panic(canvas_rect)
		Mode.MIDNIGHT_STUDY:
			_draw_midnight_study(canvas_rect)
		Mode.EXAM_HALL:
			_draw_exam_hall(canvas_rect)
		Mode.WRITING_FRENZY:
			_draw_writing_frenzy(canvas_rect)
		Mode.ZERO_REVEAL:
			_draw_zero_reveal(canvas_rect)
		Mode.WARM_WRAPUP:
			_draw_warm_wrapup(canvas_rect)

# -----------------------------------------------------------------------------
# MODE 0: NORMAL STUDIO
# -----------------------------------------------------------------------------
func _draw_normal_studio(r: Rect2) -> void:
	# Base paper
	draw_rect(r, CANVAS_PAPER)
	# Floor line at Y = 580
	var floor_rect := Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0)
	draw_rect(floor_rect, CANVAS_WARM_FLOOR)
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_SOFT, 2.0)

	# Room corner line at X = 320
	draw_line(Vector2(320.0, r.position.y), Vector2(320.0, 580.0), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)

	# Studio Window (left wall)
	var win_rect := Rect2(120.0, 140.0, 140.0, 220.0)
	draw_rect(win_rect, Color("#edf5f8"))
	draw_rect(win_rect, INK_MAIN, false, 2.5)
	draw_line(Vector2(190.0, 140.0), Vector2(190.0, 360.0), INK_MAIN, 1.8)
	draw_line(Vector2(120.0, 250.0), Vector2(260.0, 250.0), INK_MAIN, 1.8)

	# Wall Corkboard / Sketch pins (right wall)
	var board_rect := Rect2(820.0, 120.0, 360.0, 200.0)
	draw_rect(board_rect, Color("#ede4d3"))
	draw_rect(board_rect, INK_SOFT, false, 2.0)
	# Pinned paper sketches
	draw_rect(Rect2(850.0, 145.0, 70.0, 90.0), Color("#fffdf8"))
	draw_rect(Rect2(850.0, 145.0, 70.0, 90.0), INK_SOFT, false, 1.2)
	draw_circle(Vector2(885.0, 148.0), 3.0, INK_RED)

	draw_rect(Rect2(950.0, 160.0, 80.0, 100.0), Color("#fffdf8"))
	draw_rect(Rect2(950.0, 160.0, 80.0, 100.0), INK_SOFT, false, 1.2)
	draw_circle(Vector2(990.0, 163.0), 3.0, INK_GOLD)

# -----------------------------------------------------------------------------
# MODE 1: COVID ONLINE
# -----------------------------------------------------------------------------
func _draw_covid_online(r: Rect2) -> void:
	draw_rect(r, Color("#f7f4ed"))
	# Floor line
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#eee7db"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_SOFT, 2.0)

	# Stylized floating online class shorthand boxes (background)
	var screen_base_x := 780.0
	var screen_base_y := 120.0
	var scr_w := 380.0
	var scr_h := 240.0
	# Illustrated laptop screen outline
	draw_rect(Rect2(screen_base_x, screen_base_y, scr_w, scr_h), Color("#edf2f7"))
	draw_rect(Rect2(screen_base_x, screen_base_y, scr_w, scr_h), INK_MAIN, false, 2.8)

	# Video call 4-grid squares
	var pad := 12.0
	var gw := (scr_w - pad * 3.0) / 2.0
	var gh := (scr_h - pad * 3.0) / 2.0
	for row in range(2):
		for col in range(2):
			var gx: float = screen_base_x + pad + col * (gw + pad)
			var gy: float = screen_base_y + pad + row * (gh + pad)
			draw_rect(Rect2(gx, gy, gw, gh), Color("#e2e8f0"))
			draw_rect(Rect2(gx, gy, gw, gh), INK_SOFT, false, 1.4)
			# Tiny illustrated avatar silhouettes
			draw_circle(Vector2(gx + gw * 0.5, gy + gh * 0.4), 14.0, Color(0.4, 0.45, 0.55, 0.4))
			draw_circle(Vector2(gx + gw * 0.5, gy + gh * 0.85), 24.0, Color(0.4, 0.45, 0.55, 0.3))

	# Wifi signal icon top right
	var wx := screen_base_x + scr_w - 30.0
	var wy := screen_base_y + 20.0
	draw_arc(Vector2(wx, wy), 16.0, -PI * 0.8, -PI * 0.2, 8, INK_BLUE, 2.0)
	draw_arc(Vector2(wx, wy), 10.0, -PI * 0.8, -PI * 0.2, 6, INK_BLUE, 2.0)
	draw_circle(Vector2(wx, wy + 2.0), 2.5, INK_BLUE)

# -----------------------------------------------------------------------------
# MODE 2: COLLEGE HALLWAY
# -----------------------------------------------------------------------------
func _draw_college_hallway(r: Rect2) -> void:
	draw_rect(r, Color("#faf4ea"))
	# Polished university tile floor line
	draw_rect(Rect2(r.position.x, 560.0, r.size.x, r.size.y - 560.0), Color("#eadecb"))
	draw_line(Vector2(r.position.x, 560.0), Vector2(r.end.x, 560.0), INK_MAIN, 2.4)

	# Diagonal tile perspective lines
	for i in range(-2, 10):
		var x1: float = i * 220.0
		var x2: float = x1 - 120.0
		draw_line(Vector2(x1, 560.0), Vector2(x2, r.end.y), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.2), 1.5)

	# Brick archway architecture (screen right)
	var arch_x := 820.0
	var arch_w := 340.0
	var arch_h := 460.0
	# Arch opening
	draw_rect(Rect2(arch_x, 100.0, arch_w, arch_h), Color("#f3e7d5"))
	draw_rect(Rect2(arch_x, 100.0, arch_w, arch_h), INK_MAIN, false, 2.8)
	# Arch semicircular curve top
	draw_arc(Vector2(arch_x + arch_w * 0.5, 100.0), arch_w * 0.5, -PI, 0.0, 24, INK_MAIN, 2.8)

	# College banner
	var banner_rect := Rect2(arch_x + 60.0, 160.0, 220.0, 60.0)
	draw_rect(banner_rect, Color("#3d5a80"))
	draw_rect(banner_rect, INK_MAIN, false, 2.0)
	# White banner bar
	draw_line(Vector2(arch_x + 80.0, 190.0), Vector2(arch_x + 260.0, 190.0), Color("#ffffff"), 3.0)

# -----------------------------------------------------------------------------
# MODE 3: PROCRASTINATION
# -----------------------------------------------------------------------------
func _draw_procrastination(r: Rect2) -> void:
	draw_rect(r, Color("#faf6f0"))
	# Floor line
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#f0e6d6"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_SOFT, 2.0)

	# Study desk sketch on right
	var desk_rect := Rect2(720.0, 440.0, 480.0, 140.0)
	draw_rect(desk_rect, Color("#f3ede3"))
	draw_rect(desk_rect, INK_MAIN, false, 2.5)

	# Big thick unopened textbook on desk
	var book_rect := Rect2(820.0, 400.0, 130.0, 40.0)
	draw_rect(book_rect, Color("#d9534f")) # Dusty reddish cover
	draw_rect(book_rect, INK_MAIN, false, 2.2)
	# Spine and pages
	draw_rect(Rect2(820.0, 432.0, 126.0, 8.0), Color("#ffffff"))
	draw_line(Vector2(820.0, 440.0), Vector2(946.0, 440.0), INK_MAIN, 1.8)

	# Cobweb or dust doodle on the textbook
	draw_line(Vector2(835.0, 405.0), Vector2(855.0, 415.0), INK_SOFT, 1.2)
	draw_line(Vector2(845.0, 405.0), Vector2(845.0, 422.0), INK_SOFT, 1.2)

# -----------------------------------------------------------------------------
# MODE 4: EMAIL PANIC
# -----------------------------------------------------------------------------
func _draw_email_panic(r: Rect2) -> void:
	# Urgent anxious amber wash
	var amber_bg := Color("#fcf0de")
	draw_rect(r, amber_bg)
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#f4dfc4"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_RED, 2.5)

	# Background panic shock rays
	var cx := 960.0
	var cy := 280.0
	var ray_col := Color(0.85, 0.25, 0.2, 0.12)
	for i in range(16):
		var ang := float(i) * PI / 8.0 + sin(wave_phase * 2.0) * 0.05
		var p1 := Vector2(cx, cy) + Vector2(cos(ang), sin(ang)) * 120.0
		var p2 := Vector2(cx, cy) + Vector2(cos(ang), sin(ang)) * 800.0
		draw_line(p1, p2, ray_col, 8.0)

	# Stylized crowd silhouettes panicking in background
	var crowd_x := [720.0, 840.0, 980.0, 1100.0]
	for k in crowd_x:
		var col_silhouette := Color(0.4, 0.2, 0.25, 0.25)
		draw_circle(Vector2(k, 420.0), 18.0, col_silhouette)
		draw_polygon(PackedVector2Array([
			Vector2(k - 18.0, 560.0), Vector2(k - 14.0, 440.0),
			Vector2(k + 14.0, 440.0), Vector2(k + 18.0, 560.0)
		]), [col_silhouette, col_silhouette, col_silhouette, col_silhouette])
		# Little panicked waving arm strokes
		draw_line(Vector2(k - 14.0, 450.0), Vector2(k - 35.0, 410.0), INK_RED, 2.0)
		draw_line(Vector2(k + 14.0, 450.0), Vector2(k + 35.0, 410.0), INK_RED, 2.0)

# -----------------------------------------------------------------------------
# MODE 5: MIDNIGHT STUDY
# -----------------------------------------------------------------------------
func _draw_midnight_study(r: Rect2) -> void:
	# Deep midnight paper tone
	var dark_paper := Color("#1c202a")
	draw_rect(r, dark_paper)
	# Floor line
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#151820"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), Color("#323846"), 2.0)

	# Warm cone of light from desk lamp onto desk (screen center-right)
	var lamp_tip := Vector2(880.0, 240.0)
	var cone_pts := PackedVector2Array([
		lamp_tip,
		Vector2(640.0, 580.0),
		Vector2(1180.0, 580.0)
	])
	var light_col := Color(1.0, 0.95, 0.72, 0.22 + sin(lamp_pulse) * 0.02)
	draw_colored_polygon(cone_pts, light_col)

	# Desk surface illuminated
	draw_rect(Rect2(680.0, 440.0, 460.0, 140.0), Color(0.25, 0.22, 0.20, 0.8))
	draw_rect(Rect2(680.0, 440.0, 460.0, 140.0), Color("#f4ede2"), false, 2.0)

	# Mountain of books and papers in background
	for b in range(5):
		var by: float = 440.0 - float(b) * 18.0
		var bx: float = 1000.0 + (b % 2) * 8.0
		draw_rect(Rect2(bx, by, 110.0, 16.0), Color("#2a354b"))
		draw_rect(Rect2(bx, by, 110.0, 16.0), Color("#8a9bb8"), false, 1.2)

# -----------------------------------------------------------------------------
# MODE 6: EXAM HALL
# -----------------------------------------------------------------------------
func _draw_exam_hall(r: Rect2) -> void:
	# Pale institutional examination room canvas
	draw_rect(r, Color("#f5f6f8"))
	# Floor line with grid
	draw_rect(Rect2(r.position.x, 540.0, r.size.x, r.size.y - 540.0), Color("#eaecee"))
	draw_line(Vector2(r.position.x, 540.0), Vector2(r.end.x, 540.0), INK_MAIN, 2.5)

	# Strict rows of exam desks in background perspective
	for row in range(3):
		var ry: float = 380.0 + float(row) * 60.0
		var rw: float = 180.0 - float(row) * 20.0
		for col in range(4):
			var rx: float = 620.0 + float(col) * 160.0
			draw_rect(Rect2(rx, ry, rw * 0.6, 25.0), Color("#d8dde4"))
			draw_rect(Rect2(rx, ry, rw * 0.6, 25.0), INK_SOFT, false, 1.4)
			# Desk legs
			draw_line(Vector2(rx + 8.0, ry + 25.0), Vector2(rx + 8.0, ry + 55.0), INK_SOFT, 1.4)
			draw_line(Vector2(rx + rw * 0.6 - 8.0, ry + 25.0), Vector2(rx + rw * 0.6 - 8.0, ry + 55.0), INK_SOFT, 1.4)

	# Institutional wall clock high up center
	var clock_pos := Vector2(960.0, 150.0)
	draw_circle(clock_pos, 32.0, Color("#ffffff"))
	draw_circle(clock_pos, 32.0, INK_MAIN) # Border
	draw_circle(clock_pos, 30.0, Color("#ffffff"))
	draw_line(clock_pos, clock_pos + Vector2(0, -18), INK_MAIN, 2.4)
	draw_line(clock_pos, clock_pos + Vector2(12, 0), INK_MAIN, 2.0)

# -----------------------------------------------------------------------------
# MODE 7: WRITING FRENZY
# -----------------------------------------------------------------------------
func _draw_writing_frenzy(r: Rect2) -> void:
	# Energetic dynamic paper with subtle action diagonal speed lines
	draw_rect(r, Color("#faf6f0"))
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#f0e6d6"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_MAIN, 2.5)

	# Dynamic motion speed lines across frame
	var speed_col := Color(0.8, 0.4, 0.1, 0.15)
	for i in range(12):
		var y_pos: float = 100.0 + float(i) * 38.0
		var x_start: float = 600.0 + (i % 3) * 60.0
		draw_line(Vector2(x_start, y_pos), Vector2(x_start + 450.0, y_pos - 15.0), speed_col, 3.0)

# -----------------------------------------------------------------------------
# MODE 8: ZERO REVEAL
# -----------------------------------------------------------------------------
func _draw_zero_reveal(r: Rect2) -> void:
	# Dramatic dark crimson/sepia paper wash
	var dark_wash := Color("#23151b")
	draw_rect(r, dark_wash)
	# Floor line
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#1a0e13"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_RED, 2.5)

	# Spotlight on exam paper at right side
	var spot_center := Vector2(980.0, 360.0)
	var spot_col := Color(1.0, 0.92, 0.85, 0.18 + sin(lamp_pulse * 1.5) * 0.03)
	draw_circle(spot_center, 220.0, spot_col)
	draw_circle(spot_center, 140.0, Color(1.0, 0.95, 0.9, 0.12))

	# Shock impact lines radiating from paper
	for i in range(12):
		var a: float = float(i) * PI / 6.0
		var p1 := spot_center + Vector2(cos(a), sin(a)) * 160.0
		var p2 := spot_center + Vector2(cos(a), sin(a)) * 260.0
		draw_line(p1, p2, Color(0.85, 0.2, 0.2, 0.25), 4.0)

# -----------------------------------------------------------------------------
# MODE 9: WARM WRAPUP / AFTERMATH
# -----------------------------------------------------------------------------
func _draw_warm_wrapup(r: Rect2) -> void:
	# Warm, comforting sketchbook paper
	draw_rect(r, Color("#faf7f2"))
	draw_rect(Rect2(r.position.x, 580.0, r.size.x, r.size.y - 580.0), Color("#f2ebe0"))
	draw_line(Vector2(r.position.x, 580.0), Vector2(r.end.x, 580.0), INK_SOFT, 2.0)

	# Desk with peaceful post-battle callback props (right side)
	var desk_rect := Rect2(700.0, 440.0, 480.0, 140.0)
	draw_rect(desk_rect, Color("#f5ede3"))
	draw_rect(desk_rect, INK_MAIN, false, 2.4)

	# Small 2 AM clock resting quietly on desk
	var c_pos := Vector2(1080.0, 410.0)
	draw_circle(c_pos, 22.0, Color("#fffdf8"))
	draw_arc(c_pos, 22.0, 0.0, TAU, 24, INK_MAIN, 2.4)
	draw_line(c_pos, c_pos + Vector2(0, -12), INK_MAIN, 2.0)
	draw_line(c_pos, c_pos + Vector2(8, -6), INK_MAIN, 2.0)

	# A few crumpled paper balls on desk
	draw_circle(Vector2(760.0, 432.0), 10.0, Color("#fffdf8"))
	draw_arc(Vector2(760.0, 432.0), 10.0, 0.0, TAU, 16, INK_SOFT, 1.8)
	draw_line(Vector2(756.0, 429.0), Vector2(764.0, 435.0), INK_SOFT, 1.4)
	draw_circle(Vector2(782.0, 434.0), 8.0, Color("#fffdf8"))
	draw_arc(Vector2(782.0, 434.0), 8.0, 0.0, TAU, 16, INK_SOFT, 1.8)
