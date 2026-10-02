class_name Ep08Doodles
extends Node2D

## Ep08Doodles — Master Hand-Authored Storytime Doodles, Props & Lettering
## Episode 08: "I FORCED MY BF TO CREATE A CHANNEL"
##
## Shared live-ink playback and actual drawn-lettering paths.
## Episode-specific illustrations remain independent assets.
## Default doodle color: Dark sepia ink (#2b2623 DNA).
## Doodles are animated stroke-by-stroke into the scene.

const Profiles = preload("res://common/storytime/ProfileAssets.gd")

const INK_MAIN: Color = Color("#2b2623")
const INK_SOFT: Color = Color("#594f4b")
const INK_RED: Color = Color("#b84328")
const INK_GOLD: Color = Color("#d35400")
const INK_BLUE: Color = Color("#2980b9")
const INK_GREEN: Color = Color("#27ae60")

# =============================================================================
# ANIMATED DOODLE CONTAINER
# =============================================================================
class AnimatedDoodle extends "res://common/engine/illustration/LiveDrawing.gd":
	var author: String = "nemi"
	var held: bool = true
	func prepare() -> void:
		# Same shared ink player; select the character alphabet before its preparation.
		for label in texts:
			var letters: Dictionary = Profiles.compose(author, str(label.txt), float(label.get("size", 24)))
			for stroke in letters.strokes:
				var moved := PackedVector2Array()
				for point in stroke.pts:
					moved.append(point + Vector2(label.pos) - Vector2(0, float(label.get("size", 24))))
				stroke.pts = moved
				stroke.col = label.get("col", Color("#423035"))
				stroke_list.append(stroke)
		texts.clear()
		super.prepare()
	func play_draw(duration: float = 0.7):
		if held:
			prepare()
			progress = 1.0
			return self
		return super.play_draw(duration)

func author_mark(kind: String, author: String = "nemi") -> Array[Dictionary]:
	var strokes: Array[Dictionary] = []
	var style := Profiles.profile(author)
	for path in style.marks[kind]:
		var points := PackedVector2Array()
		for point in path.points: points.append(Vector2(point[0], point[1]))
		strokes.append({"pts":points,"smooth":path.get("smooth",true),"w":path.get("width",3.0),"col":Color(style.ink),"pause":path.get("pause",style.pen_lift),"pressure":PackedFloat32Array(style.pressure)})
	return strokes

func _ready() -> void:
	z_index = 25

# =============================================================================
# AUTHORED DOODLE & PROP GENERATORS
# =============================================================================

## 1. Hand-drawn organic arrow pointing toward old ADB
func spawn_hand_drawn_arrow(pos: Vector2, pointing_direction: Vector2 = Vector2(1, 0), col: Color = INK_MAIN, dur: float = 0.55) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.held = false
	d.position = pos
	d.rotation = pointing_direction.angle()
	d.stroke_list = author_mark("arrow")
	add_child(d)
	d.play_draw(dur)
	return d

func spawn_rough_circle(pos: Vector2, radius: float = 85.0, col: Color = INK_MAIN, dur: float = 0.65) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.held = false
	d.position = pos
	d.scale = Vector2.ONE * radius / 45.0
	d.stroke_list = author_mark("circle")
	add_child(d)
	d.play_draw(dur)
	return d

func spawn_redesign_sketch_card(pos: Vector2, col: Color = INK_MAIN, dur: float = 0.40) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.held = false
	d.position = pos

	var paper_rect := PackedVector2Array([
		Vector2(-90, -120), Vector2(90, -115),
		Vector2(95, 120), Vector2(-88, 125), Vector2(-90, -120)
	])
	d.fills.append({"poly": paper_rect, "col": Color("#ffffff", 0.95)})
	d.stroke_list.append({"pts": paper_rect, "w": 3.0, "col": INK_SOFT})

	var head_oval := PackedVector2Array()
	for i in range(16):
		var th := (float(i) / 16.0) * TAU
		head_oval.append(Vector2(0, -40) + Vector2(cos(th) * 32.0, sin(th) * 38.0))
	head_oval.append(head_oval[0])
	d.stroke_list.append({"pts": head_oval, "w": 2.5, "col": col})

	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-28, -60), Vector2(-15, -75), Vector2(5, -68)]), "w": 3.0, "col": col})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-10, -75), Vector2(18, -80), Vector2(30, -62)]), "w": 3.0, "col": col})

	var cross1 := PackedVector2Array([Vector2(-75, -95), Vector2(75, 95)])
	var cross2 := PackedVector2Array([Vector2(75, -95), Vector2(-75, 95)])
	d.stroke_list.append({"pts": cross1, "w": 4.5, "col": INK_RED})
	d.stroke_list.append({"pts": cross2, "w": 4.5, "col": INK_RED})

	add_child(d)
	d.play_draw(dur)
	return d

## 4. Creative Idea lightbulb / spark swirl
func spawn_idea_lightbulb(pos: Vector2, col: Color = INK_MAIN, dur: float = 0.32) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos

	var bulb := PackedVector2Array([
		Vector2(-15, 30), Vector2(-18, 10), Vector2(-36, -10),
		Vector2(-32, -45), Vector2(0, -62), Vector2(32, -45),
		Vector2(36, -10), Vector2(18, 10), Vector2(15, 30)
	])
	d.fills.append({"poly": bulb, "col": Color("#fff9db", 0.85)})
	d.stroke_list.append({"pts": bulb, "w": 3.5, "col": col})

	var filament := PackedVector2Array([
		Vector2(-10, 10), Vector2(-8, -15), Vector2(0, -25), Vector2(8, -15), Vector2(10, 10)
	])
	d.stroke_list.append({"pts": filament, "w": 2.8, "col": INK_GOLD})

	var base := PackedVector2Array([Vector2(-15, 30), Vector2(15, 30), Vector2(12, 42), Vector2(-12, 42), Vector2(-15, 30)])
	d.stroke_list.append({"pts": base, "w": 2.5, "col": INK_SOFT})

	d.stroke_list.append({"pts": PackedVector2Array([Vector2(0, -74), Vector2(0, -96)]), "w": 3.2, "col": col})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-42, -56), Vector2(-60, -74)]), "w": 3.2, "col": col})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(42, -56), Vector2(60, -74)]), "w": 3.2, "col": col})

	add_child(d)
	d.play_draw(dur)
	return d

## 5. Handwritten "NO" scribbled sticker
func spawn_handwritten_no(pos: Vector2, scale_factor: float = 1.0, col: Color = INK_MAIN, dur: float = 0.5) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.author = "adb"
	d.position = pos - Vector2(35, 30) * scale_factor
	d.scale = Vector2.ONE * scale_factor
	var lettering = Profiles.compose("adb", "no.", 62)
	d.stroke_list.assign(lettering.strokes)
	add_child(d)
	d.play_draw(dur)
	return d

func spawn_asked_again_note(pos: Vector2, col: Color = INK_MAIN, dur: float = 0.28) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.held = false
	d.position = pos

	var q_curl := PackedVector2Array([
		Vector2(-20, -30), Vector2(-5, -45), Vector2(20, -35),
		Vector2(20, -15), Vector2(0, 5), Vector2(0, 20)
	])
	d.stroke_list.append({"pts": q_curl, "w": 4.5, "col": col})
	var q_dot := PackedVector2Array([Vector2(0, 35), Vector2(0, 38)])
	d.stroke_list.append({"pts": q_dot, "w": 5.5, "col": col})

	var loop_arrow := PackedVector2Array([
		Vector2(-50, 0), Vector2(-40, -40), Vector2(-10, -50), Vector2(30, -50), Vector2(50, -20)
	])
	d.stroke_list.append({"pts": loop_arrow, "w": 3.0, "col": INK_SOFT})

	d.texts.append({"pos": Vector2(-75, 65), "txt": "ASKED AGAIN!", "size": 18, "col": INK_MAIN})

	add_child(d)
	d.play_draw(dur)
	return d

## 7. Hand-drawn YouTube channel badges for Nemi and ADB
func spawn_dual_channel_badges(pos: Vector2, dur: float = 0.38) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos

	var b1_poly := PackedVector2Array([
		Vector2(-220, -45), Vector2(-40, -45), Vector2(-30, 45), Vector2(-230, 45), Vector2(-220, -45)
	])
	d.fills.append({"poly": b1_poly, "col": Color("#536b5c", 0.18)})
	d.stroke_list.append({"pts": b1_poly, "w": 3.5, "col": INK_MAIN})
	var tri1 := PackedVector2Array([Vector2(-190, -20), Vector2(-160, 0), Vector2(-190, 20), Vector2(-190, -20)])
	d.fills.append({"poly": tri1, "col": Color("#b84328")})
	d.stroke_list.append({"pts": tri1, "w": 2.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-140, 10), "txt": "NEMI", "size": 22, "col": Color("#27ae60")})

	var b2_poly := PackedVector2Array([
		Vector2(40, -45), Vector2(220, -45), Vector2(230, 45), Vector2(30, 45), Vector2(40, -45)
	])
	d.fills.append({"poly": b2_poly, "col": Color("#232836", 0.18)})
	d.stroke_list.append({"pts": b2_poly, "w": 3.5, "col": INK_MAIN})
	var tri2 := PackedVector2Array([Vector2(70, -20), Vector2(100, 0), Vector2(70, 20), Vector2(70, -20)])
	d.fills.append({"poly": tri2, "col": Color("#232836")})
	d.stroke_list.append({"pts": tri2, "w": 2.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(120, 10), "txt": "ADB", "size": 22, "col": Color("#2980b9")})

	add_child(d)
	d.play_draw(dur)
	return d

## 8. Playful animation rivalry doodle (crossed stylus pens / sparks)
func spawn_rivalry_sparks(pos: Vector2, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos

	var pen1 := PackedVector2Array([Vector2(-50, -50), Vector2(40, 40)])
	d.stroke_list.append({"pts": pen1, "w": 5.0, "col": Color("#536b5c")})

	var pen2 := PackedVector2Array([Vector2(50, -50), Vector2(-40, 40)])
	d.stroke_list.append({"pts": pen2, "w": 5.0, "col": Color("#232836")})

	var star := PackedVector2Array([
		Vector2(0, -25), Vector2(6, -8), Vector2(25, 0), Vector2(8, 6),
		Vector2(0, 25), Vector2(-8, 6), Vector2(-25, 0), Vector2(-6, -8), Vector2(0, -25)
	])
	d.fills.append({"poly": star, "col": Color("#ffd32a", 0.9)})
	d.stroke_list.append({"pts": star, "w": 2.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-70, 75), "txt": "ANIMATION WAR!", "size": 18, "col": INK_RED})

	add_child(d)
	d.play_draw(dur)
	return d

## 9. Hand-drawn downward arrow + handwritten "link ↓" cue for ADB
func spawn_link_description_cue(pos: Vector2, col: Color = INK_MAIN, dur: float = 0.32) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos

	var stem := PackedVector2Array([Vector2(0, -45), Vector2(0, 30)])
	d.stroke_list.append({"pts": stem, "w": 4.5, "col": col})
	var barb_l := PackedVector2Array([Vector2(-18, 12), Vector2(0, 32)])
	var barb_r := PackedVector2Array([Vector2(18, 12), Vector2(0, 32)])
	d.stroke_list.append({"pts": barb_l, "w": 4.5, "col": col})
	d.stroke_list.append({"pts": barb_r, "w": 4.5, "col": col})

	var box := PackedVector2Array([
		Vector2(30, -35), Vector2(190, -35), Vector2(190, 40), Vector2(30, 40), Vector2(30, -35)
	])
	d.fills.append({"poly": box, "col": Color("#fff9e6")})
	d.stroke_list.append({"pts": box, "w": 2.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(45, -5), "txt": "CHANNEL LINK", "size": 16, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(45, 25), "txt": "IN DESCRIPTION", "size": 14, "col": INK_RED})

	add_child(d)
	d.play_draw(dur)
	return d

## 10. Comic sweat drop
func spawn_sweat_drop(pos: Vector2, dur: float = 0.22) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var drop := PackedVector2Array([
		Vector2(0, -22), Vector2(12, 4), Vector2(6, 18), Vector2(0, 20), Vector2(-6, 18), Vector2(-12, 4), Vector2(0, -22)
	])
	d.fills.append({"poly": drop, "col": Color("#74b9ff", 0.75)})
	d.stroke_list.append({"pts": drop, "w": 2.5, "col": INK_MAIN})
	add_child(d)
	d.play_draw(dur)
	return d

# =============================================================================
# NEW ADVANCED PROPS & DOODLES
# =============================================================================

## 11. Hand-drawn stress spiral (Beat 1 Hook)
func spawn_stress_spiral(pos: Vector2, col: Color = INK_MAIN, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var pts := PackedVector2Array()
	var steps := 36
	for i in range(steps):
		var th := float(i) * 0.4
		var r := 4.0 + float(i) * 1.5
		pts.append(Vector2(cos(th) * r, sin(th) * r))
	d.stroke_list.append({"pts": pts, "w": 3.0, "col": col})
	d.texts.append({"pos": Vector2(-70, -45), "txt": "NEW PROBLEM!!", "size": 20, "col": INK_RED})
	add_child(d)
	d.play_draw(dur)
	return d

## 12. Pinned critique notes (Beat 3)
func spawn_critique_notes(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var poly := PackedVector2Array([Vector2(-60, -40), Vector2(60, -40), Vector2(60, 40), Vector2(-60, 40), Vector2(-60, -40)])
	d.fills.append({"poly": poly, "col": Color("#fffa65")})
	d.stroke_list.append({"pts": poly, "w": 2.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-45, 5), "txt": "HATED IT!", "size": 18, "col": INK_RED})
	add_child(d)
	d.play_draw(dur)
	return d

## 13. Crumpled paper ball on floor (Beat 3)
func spawn_crumpled_paper_ball(pos: Vector2, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var pts := PackedVector2Array([
		Vector2(-15, -8), Vector2(-6, -18), Vector2(10, -12),
		Vector2(18, 4), Vector2(8, 16), Vector2(-12, 14), Vector2(-15, -8)
	])
	d.fills.append({"poly": pts, "col": Color("#ffffff")})
	d.stroke_list.append({"pts": pts, "w": 2.2, "col": INK_MAIN})
	# Wrinkle lines
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(-8, -6), Vector2(4, 2)]), "w": 1.8, "col": INK_SOFT})
	d.stroke_list.append({"pts": PackedVector2Array([Vector2(2, -10), Vector2(-4, 10)]), "w": 1.8, "col": INK_SOFT})
	add_child(d)
	d.play_draw(dur)
	return d

## 14. Brick wall doodle on "STILL NO" (Beat 6)
func spawn_brick_wall_no(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var wall := PackedVector2Array([Vector2(-90, -60), Vector2(90, -60), Vector2(90, 60), Vector2(-90, 60), Vector2(-90, -60)])
	d.fills.append({"poly": wall, "col": Color("#d35400", 0.25)})
	d.stroke_list.append({"pts": wall, "w": 3.0, "col": INK_MAIN})
	for y in [-20, 20]:
		d.stroke_list.append({"pts": PackedVector2Array([Vector2(-90, y), Vector2(90, y)]), "w": 2.0, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-75, 10), "txt": "ABSOLUTELY NOT", "size": 17, "col": INK_RED})
	add_child(d)
	d.play_draw(dur)
	return d

## 15. Confetti burst on channel created (Beat 6)
func spawn_confetti_burst(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var cols := [Color("#e74c3c"), Color("#f1c40f"), Color("#2ecc71"), Color("#3498db")]
	for i in range(12):
		var ang := (float(i) / 12.0) * TAU
		var dist := 70.0 + (i % 3) * 25.0
		var cp := Vector2(cos(ang) * dist, sin(ang) * dist)
		var c_poly := PackedVector2Array([cp, cp + Vector2(10, 0), cp + Vector2(8, 12), cp + Vector2(-2, 10), cp])
		d.fills.append({"poly": c_poly, "col": cols[i % cols.size()]})
		d.stroke_list.append({"pts": c_poly, "w": 1.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-80, 5), "txt": "CHANNEL CREATED! ", "size": 18, "col": Color("#27ae60")})
	add_child(d)
	d.play_draw(dur)
	return d

## 16. Vintage Microphone held by Nemi pointing toward ADB (Beat 8)
func spawn_vintage_microphone(nemi_hand_pos: Vector2, adb_mouth_pos: Vector2, dur: float = 0.40) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = Vector2.ZERO

	# Microphone cable curling from Nemi to bottom
	var cable := PackedVector2Array([
		nemi_hand_pos,
		nemi_hand_pos + Vector2(30, 80),
		nemi_hand_pos + Vector2(70, 140),
		nemi_hand_pos + Vector2(40, 200)
	])
	d.stroke_list.append({"pts": cable, "w": 3.0, "col": INK_MAIN})

	# Microphone handle extending toward ADB
	var dir := (adb_mouth_pos - nemi_hand_pos).normalized()
	var mic_head := nemi_hand_pos + dir * 160.0
	var handle := PackedVector2Array([nemi_hand_pos, mic_head - dir * 25.0])
	d.stroke_list.append({"pts": handle, "w": 7.0, "col": Color("#34495e")})
	d.stroke_list.append({"pts": handle, "w": 2.0, "col": INK_MAIN})

	# Silver microphone grill
	var grill := PackedVector2Array()
	for i in range(16):
		var th := (float(i) / 16.0) * TAU
		grill.append(mic_head + Vector2(cos(th) * 20.0, sin(th) * 20.0))
	grill.append(grill[0])
	d.fills.append({"poly": grill, "col": Color("#bdc3c7")})
	d.stroke_list.append({"pts": grill, "w": 2.5, "col": INK_MAIN})

	add_child(d)
	d.play_draw(dur)
	return d

## 17. Hand-drawn cue card held up: "SAY HI!" (Beat 8)
func spawn_cue_card(pos: Vector2, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var card := PackedVector2Array([Vector2(-70, -45), Vector2(70, -45), Vector2(70, 45), Vector2(-70, 45), Vector2(-70, -45)])
	d.fills.append({"poly": card, "col": Color("#ffffff")})
	d.stroke_list.append({"pts": card, "w": 2.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-55, 10), "txt": "INTRODUCE!", "size": 18, "col": INK_RED})
	add_child(d)
	d.play_draw(dur)
	return d

## 18. Radiating sound waves from ADB speaking (Beat 8)
func spawn_audio_waves(pos: Vector2, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	for i in range(3):
		var r := 25.0 + float(i) * 20.0
		var pts := PackedVector2Array()
		for a in range(-5, 6):
			var th := (float(a) / 10.0) * 0.8
			pts.append(Vector2(cos(th) * r, sin(th) * r))
		d.stroke_list.append({"pts": pts, "w": 3.0, "col": INK_BLUE})
	add_child(d)
	d.play_draw(dur)
	return d

## 19. Comic bouncy question marks
func spawn_question_marks(pos: Vector2, count: int = 3, dur: float = 0.25) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	for i in range(count):
		var offset_x: float = float(i - 1) * 32.0
		var offset_y: float = -absf(float(i - 1)) * 10.0
		var q_pts := PackedVector2Array([
			Vector2(offset_x - 10, offset_y - 20),
			Vector2(offset_x, offset_y - 30),
			Vector2(offset_x + 12, offset_y - 22),
			Vector2(offset_x + 6, offset_y - 8),
			Vector2(offset_x, offset_y + 2)
		])
		d.stroke_list.append({"pts": q_pts, "w": 3.5, "col": INK_GOLD})
		var dot_pts := PackedVector2Array([
			Vector2(offset_x, offset_y + 12),
			Vector2(offset_x + 1, offset_y + 14)
		])
		d.stroke_list.append({"pts": dot_pts, "w": 4.5, "col": INK_GOLD})
	add_child(d)
	d.play_draw(dur)
	return d

## 20. Comic REJECTED rubber stamp with double border
func spawn_rubber_stamp_rejected(pos: Vector2, dur: float = 0.20) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	d.rotation_degrees = -9.0
	# Outer border
	var b_out := PackedVector2Array([Vector2(-110, -38), Vector2(110, -38), Vector2(110, 38), Vector2(-110, 38), Vector2(-110, -38)])
	d.stroke_list.append({"pts": b_out, "w": 4.5, "col": INK_RED})
	# Inner border
	var b_in := PackedVector2Array([Vector2(-104, -32), Vector2(104, -32), Vector2(104, 32), Vector2(-104, 32), Vector2(-104, -32)])
	d.stroke_list.append({"pts": b_in, "w": 2.0, "col": INK_RED})
	d.texts.append({"pos": Vector2(-88, 12), "txt": "DISAPPROVED", "size": 22, "col": INK_RED})
	add_child(d)
	d.play_draw(dur)
	return d

## 21. Anime sparkles / glints around New ADB
func spawn_sparkles(pos: Vector2, dur: float = 0.30) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var offsets: Array[Vector2] = [Vector2(-50, -40), Vector2(60, -50), Vector2(40, 40), Vector2(-60, 30)]
	var colors: Array[Color] = [INK_GOLD, INK_BLUE, INK_GOLD, INK_RED]
	for idx in range(offsets.size()):
		var o := offsets[idx]
		var c := colors[idx]
		# 4-pointed diamond star
		var pts_h := PackedVector2Array([Vector2(o.x - 18, o.y), Vector2(o.x + 18, o.y)])
		var pts_v := PackedVector2Array([Vector2(o.x, o.y - 18), Vector2(o.x, o.y + 18)])
		d.stroke_list.append({"pts": pts_h, "w": 3.0, "col": c})
		d.stroke_list.append({"pts": pts_v, "w": 3.0, "col": c})
	add_child(d)
	d.play_draw(dur)
	return d

## 22. Bold comic exclamation mark pop
func spawn_comic_exclamation(pos: Vector2, dur: float = 0.20) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var excl1 := PackedVector2Array([Vector2(-8, -35), Vector2(-6, 0)])
	var excl2 := PackedVector2Array([Vector2(8, -35), Vector2(6, 0)])
	d.stroke_list.append({"pts": excl1, "w": 5.0, "col": INK_RED})
	d.stroke_list.append({"pts": excl2, "w": 5.0, "col": INK_RED})
	var dot1 := PackedVector2Array([Vector2(-7, 12), Vector2(-6, 14)])
	var dot2 := PackedVector2Array([Vector2(7, 12), Vector2(8, 14)])
	d.stroke_list.append({"pts": dot1, "w": 6.0, "col": INK_RED})
	d.stroke_list.append({"pts": dot2, "w": 6.0, "col": INK_RED})
	add_child(d)
	d.play_draw(dur)
	return d

## 23. Hand-drawn YouTube SUBSCRIBE button with bell
func spawn_subscribe_bell_button(pos: Vector2, dur: float = 0.35) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.position = pos
	var btn := PackedVector2Array([Vector2(-120, -32), Vector2(120, -32), Vector2(120, 32), Vector2(-120, 32), Vector2(-120, -32)])
	d.fills.append({"poly": btn, "col": Color("#e74c3c")})
	d.stroke_list.append({"pts": btn, "w": 3.5, "col": INK_MAIN})
	d.texts.append({"pos": Vector2(-75, 10), "txt": "SUBSCRIBE", "size": 22, "col": Color("#ffffff")})
	add_child(d)
	d.play_draw(dur)
	return d


## ADB's imagined story notebook: held artwork, no false hand contact.
func spawn_story_notebook(pos: Vector2) -> AnimatedDoodle:
	var d := AnimatedDoodle.new()
	d.author = "adb"
	d.position = pos
	var page := PackedVector2Array([Vector2(-90,-75),Vector2(91,-72),Vector2(94,80),Vector2(-89,83),Vector2(-90,-75)])
	d.fills.append({"poly":page,"col":Color("#fffdf5")})
	d.stroke_list.append({"pts":page,"w":3.0,"col":INK_MAIN})
	for y in [-36, -8, 20]:
		d.stroke_list.append({"pts":PackedVector2Array([Vector2(-65,y),Vector2(66,y+2)]),"w":2.0,"col":INK_SOFT})
	d.texts.append({"pos":Vector2(-65,66),"txt":"my stories","size":24,"col":INK_MAIN})
	add_child(d)
	d.play_draw()
	return d
