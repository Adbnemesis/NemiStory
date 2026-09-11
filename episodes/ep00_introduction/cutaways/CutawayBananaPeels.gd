class_name CutawayBananaPeels
extends Node2D

## Illustrated Cutaway for Beat 3: "Three Invisible Banana Peels"
## A hand-drawn animated comic cutaway showing a failed walk-cycle attempt:
## - Doodle character steps forward confidently
## - Slips on Banana Peel 1 (feet shoot forward)
## - Flails onto Banana Peel 2 (horizontal air spin)
## - Drifts across Banana Peel 3 in dramatic slow motion

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

var doodle_pos: Vector2 = Vector2(-120, 40)
var doodle_rot: float = 0.0
var doodle_leg_l: float = 0.0
var doodle_leg_r: float = 0.0
var doodle_alpha: float = 1.0

var banana1_pos: Vector2 = Vector2(-40, 60)
var banana2_pos: Vector2 = Vector2(40, 60)
var banana3_pos: Vector2 = Vector2(130, 60)

var slow_mo_text: String = ""
var motion_lines_alpha: float = 0.0

func _ready() -> void:
	z_index = 30
	modulate.a = 0.0

func play_sequence(total_duration: float = 4.2) -> void:
	modulate.a = 0.0
	scale = Vector2(0.9, 0.9)
	
	# Pop in cutaway card
	var tw_in := create_tween().set_parallel(true)
	tw_in.tween_property(self, "modulate:a", 1.0, 0.25)
	tw_in.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw_in.finished
	
	# STEP 1: Confident forward step toward peel 1
	var tw1 := create_tween().set_parallel(true)
	tw1.tween_property(self, "doodle_pos:x", -50.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw1.tween_property(self, "doodle_leg_l", 25.0, 0.35)
	await tw1.finished
	
	# SLIP 1: Foot hits peel 1! Legs shoot up, body tilts back, motion lines burst
	var tw_slip1 := create_tween().set_parallel(true)
	tw_slip1.tween_property(self, "doodle_pos:x", 10.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_slip1.tween_property(self, "doodle_pos:y", 15.0, 0.22)
	tw_slip1.tween_property(self, "doodle_rot", deg_to_rad(-42.0), 0.35)
	tw_slip1.tween_property(self, "doodle_leg_l", 65.0, 0.35)
	tw_slip1.tween_property(self, "doodle_leg_r", 45.0, 0.35)
	tw_slip1.tween_property(self, "motion_lines_alpha", 1.0, 0.1)
	tw_slip1.chain().tween_property(self, "motion_lines_alpha", 0.0, 0.35)
	await tw_slip1.finished
	
	# SLIP 2: Momentum launches onto peel 2! Full horizontal spin + motion lines
	var tw_slip2 := create_tween().set_parallel(true)
	tw_slip2.tween_property(self, "doodle_pos:x", 80.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_slip2.tween_property(self, "doodle_pos:y", -10.0, 0.25)
	tw_slip2.tween_property(self, "doodle_rot", deg_to_rad(-95.0), 0.50)
	tw_slip2.tween_property(self, "motion_lines_alpha", 1.0, 0.1)
	tw_slip2.chain().tween_property(self, "motion_lines_alpha", 0.0, 0.45)
	await tw_slip2.finished
	
	# SLIP 3: Ultra slow-motion float across peel 3
	slow_mo_text = "*SLOW MOTION*"
	queue_redraw()
	var tw_slip3 := create_tween().set_parallel(true)
	tw_slip3.tween_property(self, "doodle_pos:x", 160.0, 1.8).set_trans(Tween.TRANS_LINEAR)
	tw_slip3.tween_property(self, "doodle_pos:y", 30.0, 1.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw_slip3.tween_property(self, "doodle_rot", deg_to_rad(-160.0), 1.8)
	tw_slip3.tween_property(self, "motion_lines_alpha", 0.65, 0.4)
	await tw_slip3.finished

func fade_out(duration: float = 0.3) -> Signal:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, duration)
	return tw.finished

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var ink_col := Color("#2b111e")
	var paper_col := Color(0.98, 0.97, 0.94, 0.95)
	var peel_col := Color("#dfc08f")
	
	# 1. Floating Storyboard Card Background
	var card_rect := Rect2(Vector2(-240, -140), Vector2(480, 260))
	draw_rect(card_rect, paper_col)
	draw_rect(card_rect, ink_col, false, 2.5)
	
	# Header Callout
	var title_text := "WALK CYCLE ATTEMPT #1"
	draw_string(ThemeDB.fallback_font, Vector2(-220, -110), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, ink_col)
	
	if slow_mo_text != "":
		draw_string(ThemeDB.fallback_font, Vector2(60, -110), slow_mo_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, 16, Color("#a83232"))
	
	# Ground line
	draw_line(Vector2(-210, 60), Vector2(210, 60), ink_col, 2.0)
	
	# 2. Draw the 3 Banana Peels
	_draw_banana_peel(banana1_pos, peel_col, ink_col)
	_draw_banana_peel(banana2_pos, peel_col, ink_col)
	_draw_banana_peel(banana3_pos, peel_col, ink_col)
	
	# Comic slip motion lines & impact marks
	if motion_lines_alpha > 0.05:
		var line_col := Color(ink_col.r, ink_col.g, ink_col.b, motion_lines_alpha * 0.9)
		draw_line(doodle_pos + Vector2(-30, 15), doodle_pos + Vector2(-65, 25), line_col, 2.2)
		draw_line(doodle_pos + Vector2(-25, -5), doodle_pos + Vector2(-55, -12), line_col, 2.0)
		draw_line(doodle_pos + Vector2(-20, -25), doodle_pos + Vector2(-45, -35), line_col, 1.8)
		# Impact pop tick near floor
		draw_line(Vector2(doodle_pos.x - 15, 55), Vector2(doodle_pos.x - 30, 48), line_col, 2.0)
		draw_line(Vector2(doodle_pos.x + 10, 52), Vector2(doodle_pos.x + 22, 42), line_col, 2.0)
	
	# 3. Draw Doodle Character
	draw_set_transform(doodle_pos, doodle_rot, Vector2.ONE)
	
	# Head (circle)
	draw_circle(Vector2(0, -45), 14.0, Color.WHITE)
	draw_arc(Vector2(0, -45), 14.0, 0, TAU, 24, ink_col, 2.2)
	# Confused doodle face (x x eyes, wavy mouth)
	draw_line(Vector2(-7, -48), Vector2(-3, -44), ink_col, 1.8)
	draw_line(Vector2(-3, -48), Vector2(-7, -44), ink_col, 1.8)
	draw_line(Vector2(3, -48), Vector2(7, -44), ink_col, 1.8)
	draw_line(Vector2(7, -48), Vector2(3, -44), ink_col, 1.8)
	draw_arc(Vector2(0, -38), 5.0, 0.2, PI - 0.2, 8, ink_col, 1.8)
	
	# Spine
	draw_line(Vector2(0, -31), Vector2(0, 5), ink_col, 2.5)
	
	# Arms flailing out
	draw_line(Vector2(0, -22), Vector2(-22, -35), ink_col, 2.0)
	draw_line(Vector2(0, -22), Vector2(24, -30), ink_col, 2.0)
	
	# Legs
	var l_end := Vector2(-15, 25).rotated(deg_to_rad(doodle_leg_l))
	var r_end := Vector2(15, 25).rotated(deg_to_rad(-doodle_leg_r))
	draw_line(Vector2(0, 5), l_end, ink_col, 2.2)
	draw_line(Vector2(0, 5), r_end, ink_col, 2.2)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_banana_peel(pos: Vector2, col: Color, ink: Color) -> void:
	var pts := PackedVector2Array([
		pos + Vector2(-12, 0), pos + Vector2(-6, -8),
		pos + Vector2(0, -2), pos + Vector2(6, -9),
		pos + Vector2(12, 0), pos + Vector2(0, 2)
	])
	draw_colored_polygon(pts, col)
	draw_polyline(pts + PackedVector2Array([pts[0]]), ink, 1.8)
