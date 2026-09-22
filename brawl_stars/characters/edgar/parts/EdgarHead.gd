class_name EdgarHead
extends Node2D

## Pale Face Silhouette, Ear Piercings & Swooping Emo Hair for EDGAR (Brawl Stars)
## Implements the pale skin base, silver ear studs, and iconic heavy jet-black emo fringe
## sweeping across one eye with angular punk spikes.

const EdgarStyle = preload("res://brawl_stars/characters/edgar/EdgarStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: EdgarStyle

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Pale Neck & Head Base
	_draw_head_base()
	
	# 2. Left Ear & Piercings
	_draw_left_ear()
	
	# 3. Jet-Black Emo Hair Spikes & Swooping Fringe
	_draw_emo_hair()

func _draw_head_base() -> void:
	# Pale head oval from Y = -55 down to chin at Y = 20
	var head_pts := PackedVector2Array([
		Vector2(-32, -45),
		Vector2(-40, -20),
		Vector2(-36, 6),
		Vector2(-20, 20),
		Vector2(0, 25),
		Vector2(20, 20),
		Vector2(36, 6),
		Vector2(40, -20),
		Vector2(32, -45),
		Vector2(0, -56)
	])
	draw_colored_polygon(head_pts, style.skin_pale_color)
	
	# Jaw shadow
	var jaw_sh := PackedVector2Array([
		Vector2(-20, 16),
		Vector2(0, 25),
		Vector2(20, 16),
		Vector2(0, 21)
	])
	draw_colored_polygon(jaw_sh, style.skin_pale_shadow_color)
	
	draw_polyline(head_pts, style.ink_color, style.inner_line_width, true)

func _draw_left_ear() -> void:
	# Left ear at (-40, -14)
	var ear_pts := PackedVector2Array([
		Vector2(-38, -24),
		Vector2(-48, -18),
		Vector2(-48, -8),
		Vector2(-38, -2)
	])
	draw_colored_polygon(ear_pts, style.skin_pale_color)
	draw_polyline(ear_pts, style.ink_color, style.inner_line_width, true)
	
	# Double silver earring studs on lobe
	draw_circle(Vector2(-46, -14), 2.2, style.stud_silver_color)
	draw_circle(Vector2(-46, -14), 2.2, style.ink_color, false, 0.8)
	draw_circle(Vector2(-45, -8), 2.2, style.stud_silver_color)
	draw_circle(Vector2(-45, -8), 2.2, style.ink_color, false, 0.8)

func _draw_emo_hair() -> void:
	# Main voluminous spiky back hair & top crest
	var back_hair := PackedVector2Array([
		Vector2(-35, -45),
		Vector2(-48, -52),
		Vector2(-40, -68),
		Vector2(-22, -78),
		Vector2(0, -84),
		Vector2(24, -80),
		Vector2(44, -68),
		Vector2(50, -50),
		Vector2(42, -35),
		Vector2(35, -15),
		Vector2(28, 5),
		Vector2(18, -10),
		Vector2(28, -40),
		Vector2(0, -52),
		Vector2(-28, -40)
	])
	draw_colored_polygon(back_hair, style.hair_black_color)
	
	# Cel-shadow on inner crevices
	var hair_shadow := PackedVector2Array([
		Vector2(-48, -52),
		Vector2(-40, -68),
		Vector2(-22, -78),
		Vector2(-15, -60),
		Vector2(-35, -45)
	])
	draw_colored_polygon(hair_shadow, style.hair_black_shadow_color)
	
	# Top hair highlight crest
	var crest_hl := PackedVector2Array([
		Vector2(-18, -76),
		Vector2(0, -82),
		Vector2(20, -78),
		Vector2(14, -72),
		Vector2(0, -76),
		Vector2(-14, -72)
	])
	draw_colored_polygon(crest_hl, style.hair_black_highlight_color)
	
	# Iconic massive swooping emo bangs: sweeping from top-left across forehead down to bottom-right cheek!
	var emo_fringe := PackedVector2Array([
		Vector2(-32, -55),
		Vector2(-15, -62),
		Vector2(12, -58),
		Vector2(32, -45),
		Vector2(46, -20),
		Vector2(44, 12),  # sharp bottom tip covering right cheek
		Vector2(30, -5),
		Vector2(18, -25), # swooping jagged cutout
		Vector2(2, 2),    # middle lock tip
		Vector2(-6, -22),
		Vector2(-20, -8), # left lock tip
		Vector2(-32, -28),
		Vector2(-38, -45)
	])
	draw_colored_polygon(emo_fringe, style.hair_black_color)
	
	# Fringe shadow
	var fringe_sh := PackedVector2Array([
		Vector2(32, -45),
		Vector2(46, -20),
		Vector2(44, 12),
		Vector2(30, -5),
		Vector2(26, -20)
	])
	draw_colored_polygon(fringe_sh, style.hair_black_shadow_color)
	
	# Outlines
	draw_polyline(back_hair, style.ink_color, style.outer_contour_width, true)
	draw_polyline(emo_fringe, style.ink_color, style.outer_contour_width, true)
