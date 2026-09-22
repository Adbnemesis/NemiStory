class_name RuffsTorso
extends Node2D

## Torso & Military Uniform Construction for RUFFS (Colonel Ruffs - Brawl Stars)
## Faithfully captures:
## - Double-breasted magenta military officer coat with flared cut
## - Gleaming gold shoulder epaulettes with military hanging fringe
## - High navy stand collar with gold piping lapels
## - Diagonal gold button flap with large circular gold officer buttons
## - Military Dog-Bone Medal with paw print & sky-blue ribbon
## - Dark navy belt with silver winged shield buckle

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: RuffsStyle

var torso_lean: float = 0.0:
	set(val):
		torso_lean = val
		rotation = torso_lean
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# 1. Main Military Coat Body (Magenta)
	_draw_coat_body()
	
	# 2. Diagonal Flap, Collar & Gold Buttons
	_draw_collar_and_button_flap()
	
	# 3. Gold Epaulettes with Shoulder Fringe
	_draw_shoulder_epaulettes()
	
	# 4. Dog-Bone Military Medal (Left Chest)
	_draw_bone_medal()
	
	# 5. Navy Belt & Winged Shield Buckle
	_draw_officer_belt()

func _draw_coat_body() -> void:
	# Coat torso from shoulders (Y ~ -34) to waist belt (Y ~ 42)
	var coat_pts := PackedVector2Array([
		Vector2(-42, -32),
		Vector2(-48, -4),
		Vector2(-44, 38),
		Vector2(-24, 42),
		Vector2(0, 44),
		Vector2(24, 42),
		Vector2(44, 38),
		Vector2(48, -4),
		Vector2(42, -32),
		Vector2(20, -36),
		Vector2(0, -34),
		Vector2(-20, -36)
	])
	draw_colored_polygon(coat_pts, style.coat_magenta_color)
	
	# Shadow on right side
	var shadow_pts := PackedVector2Array([
		Vector2(0, -34),
		Vector2(20, -36),
		Vector2(42, -32),
		Vector2(48, -4),
		Vector2(44, 38),
		Vector2(24, 42),
		Vector2(16, 12),
		Vector2(12, -20)
	])
	draw_colored_polygon(shadow_pts, style.coat_shadow_color)
	
	var loop := PackedVector2Array()
	for p in coat_pts: loop.append(p)
	loop.append(coat_pts[0])
	CosmoInkStroke.from_points(loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)

func _draw_collar_and_button_flap() -> void:
	# High Navy Collar at neck
	var collar_pts := PackedVector2Array([
		Vector2(-22, -36),
		Vector2(-12, -22),
		Vector2(0, -20),
		Vector2(12, -22),
		Vector2(22, -36),
		Vector2(14, -40),
		Vector2(0, -38),
		Vector2(-14, -40)
	])
	draw_colored_polygon(collar_pts, style.navy_trim_color)
	var c_loop := PackedVector2Array()
	for p in collar_pts: c_loop.append(p)
	c_loop.append(collar_pts[0])
	CosmoInkStroke.from_points(c_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Gold collar piping trim
	draw_line(Vector2(-18, -36), Vector2(-8, -24), style.gold_accent_color, 2.5)
	draw_line(Vector2(18, -36), Vector2(8, -24), style.gold_accent_color, 2.5)
	
	# Diagonal Gold Double-Breasted Flap running from right shoulder to belt
	var flap_pts := PackedVector2Array([
		Vector2(-10, -22),
		Vector2(-24, -20),
		Vector2(-32, 22),
		Vector2(-24, 36),
		Vector2(-18, 36),
		Vector2(-24, 20),
		Vector2(-8, -16)
	])
	draw_colored_polygon(flap_pts, style.gold_accent_color)
	var f_loop := PackedVector2Array()
	for p in flap_pts: f_loop.append(p)
	f_loop.append(flap_pts[0])
	CosmoInkStroke.from_points(f_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Circular Gold Officer Buttons
	var btn_positions := [
		Vector2(-18, -6),
		Vector2(-20, 10),
		Vector2(-20, 26)
	]
	for b_pos in btn_positions:
		draw_circle(b_pos, 5.5, style.gold_accent_color)
		draw_arc(b_pos, 5.5, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
		draw_circle(b_pos + Vector2(-1.5, -1.5), 1.6, style.gold_highlight_color)

func _draw_shoulder_epaulettes() -> void:
	# Gold Shoulder Epaulettes with hanging fringe
	_draw_single_epaulette(Vector2(-42, -32), true)
	_draw_single_epaulette(Vector2(42, -32), false)

func _draw_single_epaulette(pos: Vector2, is_left: bool) -> void:
	var flip: float = -1.0 if is_left else 1.0
	
	# Gold Epaulette Base Pad
	var pad_pts := PackedVector2Array([
		pos + Vector2(10 * flip, -6),
		pos + Vector2(-16 * flip, -8),
		pos + Vector2(-22 * flip, 6),
		pos + Vector2(4 * flip, 8)
	])
	draw_colored_polygon(pad_pts, style.gold_accent_color)
	var p_loop := PackedVector2Array()
	for p in pad_pts: p_loop.append(p)
	p_loop.append(pad_pts[0])
	CosmoInkStroke.from_points(p_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Gold Fringe Tassels hanging beneath pad
	for i in range(4):
		var t_pos := pos + Vector2((-18 + float(i) * 6.0) * flip, 8)
		draw_line(t_pos, t_pos + Vector2(0, 10), style.gold_accent_color, 2.8)
		draw_line(t_pos, t_pos + Vector2(0, 10), style.ink_color, 1.2)

func _draw_bone_medal() -> void:
	# Pinned to left chest (screen right) at Vector2(24, 0)
	var medal_pos := Vector2(24, -2)
	
	# Sky Blue Hanging Ribbon
	var ribbon_pts := PackedVector2Array([
		medal_pos + Vector2(-8, 6),
		medal_pos + Vector2(8, 6),
		medal_pos + Vector2(6, 18),
		medal_pos + Vector2(0, 14), # Inverted V notch
		medal_pos + Vector2(-6, 18)
	])
	draw_colored_polygon(ribbon_pts, style.medal_ribbon_color)
	var r_loop := PackedVector2Array()
	for p in ribbon_pts: r_loop.append(p)
	r_loop.append(ribbon_pts[0])
	CosmoInkStroke.from_points(r_loop, 1.2, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Golden Dog-Bone Plaque
	var b_w: float = 12.0
	var b_h: float = 5.0
	draw_rect(Rect2(medal_pos.x - b_w, medal_pos.y - b_h, b_w * 2, b_h * 2), style.gold_accent_color, true)
	draw_circle(medal_pos + Vector2(-b_w, -b_h), 3.5, style.gold_accent_color)
	draw_circle(medal_pos + Vector2(-b_w, b_h), 3.5, style.gold_accent_color)
	draw_circle(medal_pos + Vector2(b_w, -b_h), 3.5, style.gold_accent_color)
	draw_circle(medal_pos + Vector2(b_w, b_h), 3.5, style.gold_accent_color)
	
	# Center paw print mark (crimson)
	draw_circle(medal_pos, 2.2, Color("#c03848"))
	draw_circle(medal_pos + Vector2(-2.5, -2.5), 1.0, Color("#c03848"))
	draw_circle(medal_pos + Vector2(0, -3.2), 1.0, Color("#c03848"))
	draw_circle(medal_pos + Vector2(2.5, -2.5), 1.0, Color("#c03848"))

func _draw_officer_belt() -> void:
	# Dark Navy Belt across waist at Y ~ 34
	var belt_y := 34.0
	var belt_rect := Rect2(-44, belt_y - 6, 88, 12)
	draw_rect(belt_rect, style.navy_trim_color, true)
	draw_rect(belt_rect, style.ink_color, false, style.inner_line_width)
	
	# Silver Winged Shield Buckle in center
	var buckle_pts := PackedVector2Array([
		Vector2(-16, belt_y - 8),
		Vector2(16, belt_y - 8),
		Vector2(14, belt_y + 8),
		Vector2(0, belt_y + 14), # Pointed shield bottom
		Vector2(-14, belt_y + 8)
	])
	draw_colored_polygon(buckle_pts, style.silver_badge_color)
	var b_loop := PackedVector2Array()
	for p in buckle_pts: b_loop.append(p)
	b_loop.append(buckle_pts[0])
	CosmoInkStroke.from_points(b_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# Center purple inverted anchor / T-symbol
	draw_line(Vector2(-6, belt_y - 2), Vector2(6, belt_y - 2), style.coat_shadow_color, 2.5)
	draw_line(Vector2(0, belt_y - 2), Vector2(0, belt_y + 8), style.coat_shadow_color, 2.5)
