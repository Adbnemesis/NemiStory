class_name ADBIntroProps
extends Node2D

## ADBIntroProps — Hand-drawn props and mystery silhouette for ADB Episode 00
## 100% vector drawn in the common storytime inking style (#2b2623 contour)

const INK_CONTOUR: Color = Color("#2b2623")
const PAPER_BG: Color = Color("#faf6ee")

# =========================================================================
# 1. Mystery Girlfriend Silhouette
# Deliberately heavily obscured / solid dark silhouette
# ZERO Nemi face, rig details, body construction, or character exposure
# =========================================================================
class MysterySilhouette extends Node2D:
	var arm_extension: float = 0.0 # 0.0 (tucked) to 1.0 (fully pushing)
	var push_hand_offset: Vector2 = Vector2.ZERO
	var alpha_fade: float = 1.0
	var is_thumbs_up: bool = false
	var _arm_tween: Tween

	func _init() -> void:
		z_index = 2

	func _process(_delta: float) -> void:
		queue_redraw()

	func push_forward(dist_px: float = 90.0, dur: float = 0.22) -> Signal:
		if _arm_tween and _arm_tween.is_valid():
			_arm_tween.kill()
		_arm_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_arm_tween.tween_property(self, "arm_extension", 1.0, dur)
		_arm_tween.parallel().tween_property(self, "push_hand_offset", Vector2(-dist_px, -10), dur)
		return _arm_tween.finished

	func retract(dur: float = 0.25) -> Signal:
		if _arm_tween and _arm_tween.is_valid():
			_arm_tween.kill()
		_arm_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		_arm_tween.tween_property(self, "arm_extension", 0.0, dur)
		_arm_tween.parallel().tween_property(self, "push_hand_offset", Vector2.ZERO, dur)
		return _arm_tween.finished

	func fade_out(dur: float = 0.3) -> Signal:
		var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "alpha_fade", 0.0, dur)
		tw.finished.connect(func(): visible = false)
		return tw.finished

	func fade_in(dur: float = 0.25) -> Signal:
		visible = true
		var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "alpha_fade", 1.0, dur)
		return tw.finished

	func _draw() -> void:
		var sil_col := Color(0.11, 0.09, 0.12, 0.92 * alpha_fade)
		var sil_soft := Color(0.18, 0.14, 0.19, 0.40 * alpha_fade)

		# 1. Soft blurred aura / shadow behind
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.08, 1.06))
		draw_circle(Vector2(0, -110), 48.0, sil_soft)
		_draw_soft_ellipse(Vector2(-10, -20), 45.0, 75.0, sil_soft)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		# 2. Main solid dark silhouette body (cropped off-screen right)
		# Torso / hoodie / jacket mass
		var body_pts := PackedVector2Array([
			Vector2(120, 160),
			Vector2(20, 160),
			Vector2(-25, 70),
			Vector2(-35, -20),
			Vector2(-20, -75),
			Vector2(5, -95),
			Vector2(30, -95),
			Vector2(70, -60),
			Vector2(120, -20)
		])
		draw_colored_polygon(body_pts, sil_col)

		# 3. Soft organic head silhouette (no detailed features, clean round bun/hair mass)
		draw_circle(Vector2(5, -118), 34.0, sil_col)
		# Stylized hair top knot silhouette
		draw_circle(Vector2(22, -145), 18.0, sil_col)

		# 4. Pushing Arm and Hand
		var shoulder := Vector2(-25, -55)
		var elbow := shoulder + Vector2(-45.0 * arm_extension, 20.0 * (1.0 - arm_extension))
		var hand_pos := elbow + Vector2(-55.0 * arm_extension, -10.0 * arm_extension) + push_hand_offset

		# Thick sleeve
		draw_line(shoulder, elbow, sil_col, 24.0, true)
		draw_line(elbow, hand_pos, sil_col, 20.0, true)

		# Palm / push contact or thumbs up
		if is_thumbs_up:
			draw_circle(hand_pos, 14.0, sil_col)
			draw_line(hand_pos, hand_pos + Vector2(0, -18), sil_col, 8.0, true)
		else:
			# Flat push palm with curled fingers
			draw_set_transform(hand_pos, -0.25 * arm_extension, Vector2.ONE)
			draw_rect(Rect2(-16, -18, 22, 28), sil_col, true)
			draw_circle(Vector2(-10, -4), 10.0, sil_col)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _draw_soft_ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
		var pts := PackedVector2Array()
		var segs := 24
		for i in range(segs):
			var a := (float(i) / float(segs)) * TAU
			pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
		draw_colored_polygon(pts, col)

# =========================================================================
# 2. Table Tennis Paddle & Ball
# =========================================================================
class TableTennisPaddle extends Node2D:
	var rubber_color: Color = Color("#c0392b") # Red rubber side
	var wood_color: Color = Color("#d3a26a")
	var face_angle: float = 0.0

	func _draw() -> void:
		# Handle
		var handle_pts := PackedVector2Array([
			Vector2(-7, 20), Vector2(7, 20),
			Vector2(5, 75), Vector2(-5, 75)
		])
		draw_colored_polygon(handle_pts, wood_color)
		draw_polyline(handle_pts, INK_CONTOUR, 2.8, true)
		draw_line(Vector2(0, 30), Vector2(0, 70), INK_CONTOUR, 1.5)

		# Paddle Face (Oval)
		draw_set_transform(Vector2.ZERO, face_angle, Vector2.ONE)
		var rx := 32.0
		var ry := 38.0
		var oval_pts := PackedVector2Array()
		for i in range(32):
			var a := (float(i) / 32.0) * TAU
			oval_pts.append(Vector2(cos(a) * rx, sin(a) * ry))
		draw_colored_polygon(oval_pts, rubber_color)
		draw_polyline(oval_pts, INK_CONTOUR, 3.2, true)

		# Edge tape
		draw_polyline(oval_pts, Color("#1a1a1a"), 1.8, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

class TableTennisBall extends Node2D:
	var trail_progress: float = 0.0
	func _draw() -> void:
		# Motion speedlines if active
		if trail_progress > 0.1:
			var alpha := clampf(trail_progress, 0.0, 0.6)
			draw_line(Vector2(12, -4), Vector2(48, -12), Color(0.95, 0.6, 0.2, alpha), 3.0)
			draw_line(Vector2(8, 6), Vector2(40, 16), Color(0.95, 0.6, 0.2, alpha), 2.5)

		# White celluloid ball
		draw_circle(Vector2(1.5, 1.5), 11.0, Color(0.85, 0.82, 0.78, 0.4))
		draw_circle(Vector2.ZERO, 10.5, Color("#ffffff"))
		# Subtle warm crescent shadow
		draw_arc(Vector2.ZERO, 10.5, 0.3, PI * 0.9, 16, INK_CONTOUR, 2.5)
		# Specular catchlight
		draw_circle(Vector2(-3.5, -3.5), 2.5, Color(1, 1, 1, 0.95))

# =========================================================================
# 3. Game Controller
# =========================================================================
class GameController extends Node2D:
	var body_color: Color = Color("#22252e")
	var accent_color: Color = Color("#00cec9")

	func _draw() -> void:
		# Main ergonomic gamepad shape
		var body_pts := PackedVector2Array([
			Vector2(-42, -12), Vector2(-15, -20), Vector2(15, -20), Vector2(42, -12),
			Vector2(48, 15), Vector2(38, 38), Vector2(24, 34), Vector2(12, 10),
			Vector2(-12, 10), Vector2(-24, 34), Vector2(-38, 38), Vector2(-48, 15)
		])
		draw_colored_polygon(body_pts, body_color)
		draw_polyline(body_pts, INK_CONTOUR, 3.0, true)

		# D-Pad (Left)
		var dpad_pts := PackedVector2Array([
			Vector2(-28, -8), Vector2(-24, -8), Vector2(-24, -14), Vector2(-20, -14),
			Vector2(-20, -8), Vector2(-16, -8), Vector2(-16, -4), Vector2(-20, -4),
			Vector2(-20, 2), Vector2(-24, 2), Vector2(-24, -4), Vector2(-28, -4)
		])
		draw_colored_polygon(dpad_pts, Color("#3d4251"))
		draw_polyline(dpad_pts, INK_CONTOUR, 1.8, true)

		# Action Buttons (Right XYAB)
		var btn_col := Color("#dfe6e9")
		draw_circle(Vector2(24, -14), 3.0, btn_col)
		draw_circle(Vector2(18, -8), 3.0, btn_col)
		draw_circle(Vector2(30, -8), 3.0, btn_col)
		draw_circle(Vector2(24, -2), 3.0, btn_col)

		# Dual Analog Sticks
		draw_circle(Vector2(-14, 8), 7.0, Color("#15171d"))
		draw_circle(Vector2(-14, 8), 7.0, INK_CONTOUR, false, 1.5)
		draw_circle(Vector2(14, 8), 7.0, Color("#15171d"))
		draw_circle(Vector2(14, 8), 7.0, INK_CONTOUR, false, 1.5)

		# Central LED glow strip
		draw_line(Vector2(-6, -14), Vector2(6, -14), accent_color, 2.5)

# =========================================================================
# 4. Gym Dumbbell
# =========================================================================
class GymDumbbell extends Node2D:
	var plate_color: Color = Color("#262933")
	var bar_color: Color = Color("#b2bec3")

	func _draw() -> void:
		# Central knurled steel bar
		draw_line(Vector2(-35, 0), Vector2(35, 0), bar_color, 8.0, true)
		draw_line(Vector2(-35, 0), Vector2(35, 0), INK_CONTOUR, 8.0, false)
		draw_line(Vector2(-18, 0), Vector2(18, 0), Color("#7f8c8d"), 6.0)

		# Left weight plates
		draw_rect(Rect2(-42, -24, 10, 48), plate_color, true)
		draw_rect(Rect2(-42, -24, 10, 48), INK_CONTOUR, false, 2.5)
		draw_rect(Rect2(-50, -20, 8, 40), plate_color, true)
		draw_rect(Rect2(-50, -20, 8, 40), INK_CONTOUR, false, 2.0)

		# Right weight plates
		draw_rect(Rect2(32, -24, 10, 48), plate_color, true)
		draw_rect(Rect2(32, -24, 10, 48), INK_CONTOUR, false, 2.5)
		draw_rect(Rect2(42, -20, 8, 40), plate_color, true)
		draw_rect(Rect2(42, -20, 8, 40), INK_CONTOUR, false, 2.0)

		# Hexagonal plate bolts
		draw_circle(Vector2(-52, 0), 3.0, Color("#636e72"))
		draw_circle(Vector2(52, 0), 3.0, Color("#636e72"))

# =========================================================================
# 5. Engineering Laptop & Desk Items
# =========================================================================
class EngineeringLaptop extends Node2D:
	var open_angle: float = 1.0 # 1.0 is full open

	func _draw() -> void:
		# Laptop base on desk
		var base_pts := PackedVector2Array([
			Vector2(-75, 15), Vector2(75, 15),
			Vector2(95, 38), Vector2(-95, 38)
		])
		draw_colored_polygon(base_pts, Color("#dfe6e9"))
		draw_polyline(base_pts, INK_CONTOUR, 2.8, true)

		# Trackpad & keyboard indications
		draw_rect(Rect2(-24, 25, 48, 10), Color("#b2bec3"), true)
		draw_rect(Rect2(-24, 25, 48, 10), INK_CONTOUR, false, 1.2)
		draw_rect(Rect2(-60, 18, 120, 6), Color("#636e72"), true)

		# Screen (angled upward)
		var screen_top := Vector2(0, -90 * open_angle)
		var screen_pts := PackedVector2Array([
			Vector2(-75, 15), Vector2(75, 15),
			Vector2(70, -78 * open_angle), Vector2(-70, -78 * open_angle)
		])
		draw_colored_polygon(screen_pts, Color("#1e272e"))
		draw_polyline(screen_pts, INK_CONTOUR, 3.0, true)

		# Screen display lines (code / blueprints)
		var display_pts := PackedVector2Array([
			Vector2(-64, 10), Vector2(64, 10),
			Vector2(60, -70 * open_angle), Vector2(-60, -70 * open_angle)
		])
		draw_colored_polygon(display_pts, Color("#0984e3", 0.85))
		# Glowing code / diagram lines
		draw_line(Vector2(-50, -50), Vector2(-10, -50), Color("#ffffff", 0.9), 2.0)
		draw_line(Vector2(-50, -40), Vector2(30, -40), Color("#00cec9", 0.9), 2.0)
		draw_line(Vector2(-50, -30), Vector2(10, -30), Color("#ffeaa7", 0.9), 2.0)
		draw_line(Vector2(-50, -20), Vector2(-20, -20), Color("#ff7675", 0.9), 2.0)
		draw_line(Vector2(-50, -10), Vector2(40, -10), Color("#ffffff", 0.9), 2.0)

# =========================================================================
# 6. Animation Timeline Prop
# =========================================================================
class AnimationTimelineProp extends Node2D:
	var reveal_scale: float = 1.0

	func _draw() -> void:
		# Long horizontal video editing timeline box
		var w := 720.0 * reveal_scale
		var h := 120.0
		var rect := Rect2(-w * 0.5, -h * 0.5, w, h)
		draw_rect(rect, Color("#2d3436"), true)
		draw_rect(rect, INK_CONTOUR, false, 3.2)

		# Time ruler track (top)
		draw_line(Vector2(-w * 0.5, -h * 0.5 + 24), Vector2(w * 0.5, -h * 0.5 + 24), Color("#636e72"), 1.8)
		for t_idx in range(12):
			var x_pos := -w * 0.5 + float(t_idx) * (w / 12.0)
			draw_line(Vector2(x_pos, -h * 0.5), Vector2(x_pos, -h * 0.5 + 16), Color("#b2bec3"), 1.5)

		# Audio Waveform track
		var audio_y := -h * 0.5 + 44
		draw_rect(Rect2(-w * 0.5 + 8, audio_y - 12, w - 16, 24), Color("#1e272e"), true)
		# Spiky green waveform
		var wave_pts := PackedVector2Array()
		for step in range(24):
			var wx := -w * 0.5 + 12.0 + float(step) * ((w - 24.0) / 24.0)
			var wy := audio_y + (-8.0 if step % 2 == 1 else 8.0) * (0.4 + 0.6 * sin(float(step)))
			wave_pts.append(Vector2(wx, wy))
		if wave_pts.size() >= 2:
			draw_polyline(wave_pts, Color("#00b894"), 2.0)

		# Video Layer Tracks with colored blocks
		var track_y := audio_y + 36
		draw_rect(Rect2(-w * 0.5 + 20, track_y - 8, w * 0.35, 18), Color("#0984e3"), true)
		draw_rect(Rect2(-w * 0.5 + w * 0.40, track_y - 8, w * 0.45, 18), Color("#6c5ce7"), true)

		# Red scrubbing playhead line
		var playhead_x := -w * 0.5 + w * 0.55
		draw_line(Vector2(playhead_x, -h * 0.5), Vector2(playhead_x, h * 0.5), Color("#d63031"), 3.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(playhead_x - 6, -h * 0.5),
			Vector2(playhead_x + 6, -h * 0.5),
			Vector2(playhead_x, -h * 0.5 + 10)
		]), Color("#d63031"))
