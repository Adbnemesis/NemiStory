class_name RuffsRightArm
extends Node2D

## Master Right Arm & Directorial Gestures for RUFFS (Colonel Ruffs - Brawl Stars)
## Implements Ruffs's signature military officer gestures:
## - "salute": Crisp military salute to the hat visor
## - "parade_rest": Hands strictly tucked behind back at military ease
## - "aim_blaster": Arm raised forward aiming the Double-Barrel Laser Blaster
## - "command_point": Authoritative officer point ("Orders are orders!")
## - "on_hip": Casual military resting pose
## - "recoil": Sudden defensive recoil

const RuffsStyle = preload("res://brawl_stars/characters/ruffs/RuffsStyle.gd")
const CosmoInkStroke = preload("res://brawl_stars/scripts/CosmoInkStroke.gd")

var style: RuffsStyle

var arm_pose: String = "parade_rest": # "parade_rest", "salute", "aim_blaster", "command_point", "on_hip", "recoil"
	set(val):
		arm_pose = val
		queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	# Attached at Right Shoulder Vector2(-42, -34) matching Torso epaulettes
	var shoulder := Vector2(-42, -34)
	
	var elbow: Vector2
	var wrist: Vector2
	
	match arm_pose:
		"salute":
			# Crisp military salute snapped up to right hat visor brim
			elbow = shoulder + Vector2(-28, -6)
			wrist = shoulder + Vector2(-2, -26)
		"aim_blaster":
			# Arm raised aiming blaster forward-left
			elbow = shoulder + Vector2(-32, 14)
			wrist = elbow + Vector2(-36, -6)
		"command_point":
			# Pointing straight forward authoritatively
			elbow = shoulder + Vector2(-28, 16)
			wrist = elbow + Vector2(-42, -10)
		"on_hip":
			# Resting paw on hip
			elbow = shoulder + Vector2(-22, 28)
			wrist = elbow + Vector2(18, 16)
		"recoil":
			# Pulled close to chest in surprise
			elbow = shoulder + Vector2(-14, 20)
			wrist = elbow + Vector2(8, -12)
		_: # "parade_rest" (Default military ease: tucked behind back)
			elbow = shoulder + Vector2(-16, 30)
			wrist = elbow + Vector2(24, 14)
	
	# 1. Upper Arm Sleeve (Magenta)
	var up_dir := (elbow - shoulder).normalized()
	var up_n := Vector2(-up_dir.y, up_dir.x)
	var up_sleeve := PackedVector2Array([
		shoulder + up_n * 13,
		elbow + up_n * 11,
		elbow - up_n * 11,
		shoulder - up_n * 13
	])
	draw_colored_polygon(up_sleeve, style.coat_magenta_color)
	var u_loop := PackedVector2Array()
	for p in up_sleeve: u_loop.append(p)
	u_loop.append(up_sleeve[0])
	CosmoInkStroke.from_points(u_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 2. Forearm Sleeve
	var fore_dir := (wrist - elbow).normalized()
	var fore_n := Vector2(-fore_dir.y, fore_dir.x)
	var fore_sleeve := PackedVector2Array([
		elbow + fore_n * 11,
		wrist + fore_n * 12,
		wrist - fore_n * 12,
		elbow - fore_n * 11
	])
	draw_colored_polygon(fore_sleeve, style.coat_magenta_color)
	var f_loop := PackedVector2Array()
	for p in fore_sleeve: f_loop.append(p)
	f_loop.append(fore_sleeve[0])
	CosmoInkStroke.from_points(f_loop, style.outer_contour_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 3. Officer Sleeve Cuff (Pink/Highlight)
	var cuff_w: float = 13.0
	var cuff_pts := PackedVector2Array([
		wrist + fore_n * cuff_w - fore_dir * 2,
		wrist + fore_n * cuff_w + fore_dir * 6,
		wrist - fore_n * cuff_w + fore_dir * 6,
		wrist - fore_n * cuff_w - fore_dir * 2
	])
	draw_colored_polygon(cuff_pts, style.coat_highlight_color)
	var c_loop := PackedVector2Array()
	for p in cuff_pts: c_loop.append(p)
	c_loop.append(cuff_pts[0])
	CosmoInkStroke.from_points(c_loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
	
	# 4. Orange Canine Paw
	var paw_pos := wrist + fore_dir * 6
	_draw_right_paw(paw_pos, fore_dir, fore_n)

func _draw_right_paw(pos: Vector2, dir: Vector2, norm: Vector2) -> void:
	match arm_pose:
		"salute":
			# Crisp flat military saluting paw touching hat brim
			var s_paw := PackedVector2Array([
				pos - norm * 6,
				pos + norm * 6,
				pos + dir * 14 + norm * 4,
				pos + dir * 16 - norm * 2
			])
			draw_colored_polygon(s_paw, style.fur_orange_color)
			var loop := PackedVector2Array()
			for p in s_paw: loop.append(p)
			loop.append(s_paw[0])
			CosmoInkStroke.from_points(loop, style.inner_line_width, CosmoInkStroke.Profile.UNIFORM, style.ink_color).draw_to(self)
		
		"command_point":
			# Extended pointing paw
			draw_circle(pos, 6.0, style.fur_orange_color)
			draw_line(pos, pos + dir * 18, style.fur_orange_color, 4.0)
			draw_line(pos, pos + dir * 18, style.ink_color, 1.4)
		
		_: # Open palm / gripping paw
			draw_circle(pos, 6.5, style.fur_orange_color)
			draw_arc(pos, 6.5, 0, TAU, 16, style.ink_color, style.inner_line_width, true)
			
			var p1 := pos + dir * 8 - norm * 3
			var p2 := pos + dir * 10
			var p3 := pos + dir * 8 + norm * 3
			draw_circle(p1, 2.8, style.fur_orange_color)
			draw_circle(p2, 2.8, style.fur_orange_color)
			draw_circle(p3, 2.8, style.fur_orange_color)
			draw_arc(p1, 2.8, 0, TAU, 10, style.ink_color, 1.2, true)
			draw_arc(p2, 2.8, 0, TAU, 10, style.ink_color, 1.2, true)
			draw_arc(p3, 2.8, 0, TAU, 10, style.ink_color, 1.2, true)
