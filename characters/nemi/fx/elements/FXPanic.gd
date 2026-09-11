class_name FXPanic
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn panic & frantic distress reaction:
## Multiple flying sweat droplets, head vibration lines, and comic scribble cloud.

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_TOP
	anchor_offset = Vector2(0.0, -110.0)
	entrance_style = EntranceStyle.BOUNCE
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.35

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.18)
	
	# 1. Dark Scribble Cloud directly over head
	_draw_scribble_cloud(Vector2(0, -12 * s), s)
	
	# 2. Flying sweat droplets on left and right
	_draw_flying_sweat(Vector2(-38 * s, 10 * s), -1.0, s)
	_draw_flying_sweat(Vector2(38 * s, 8 * s), 1.0, s)
	
	if intensity >= 4:
		_draw_flying_sweat(Vector2(-48 * s, 26 * s), -1.2, s * 0.8)
		_draw_flying_sweat(Vector2(46 * s, 24 * s), 1.2, s * 0.8)
	
	# 3. Vibration jitter ticks
	_draw_panic_vibrations(Vector2(0, 15 * s), s)

func _draw_scribble_cloud(pos: Vector2, s: float) -> void:
	var loops: int = 5 + intensity * 2
	var w: float = (30.0 + float(intensity) * 8.0) * s
	var h: float = (16.0 + float(intensity) * 4.0) * s
	
	var pts := PackedVector2Array()
	pts.append(pos + Vector2(-w * 0.5, 0))
	for i in range(loops):
		var t := float(i) / float(loops)
		var x := lerpf(-w * 0.5, w * 0.5, t)
		var sign_y := -1.0 if (i % 2 == 0) else 1.0
		var y := sign_y * (h * 0.4 + sin(float(i) * 2.1) * h * 0.3)
		pts.append(pos + Vector2(x, y))
	pts.append(pos + Vector2(w * 0.5, 0))
	
	draw_ink_stroke(self, pts, 2.2 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
	
	# Secondary intertwining scribble loop
	if intensity >= 3:
		var pts2 := PackedVector2Array()
		pts2.append(pos + Vector2(-w * 0.4, 2 * s))
		for i in range(loops - 1):
			var t := float(i) / float(loops - 1)
			var x := lerpf(-w * 0.4, w * 0.4, t)
			var sign_y := 1.0 if (i % 2 == 0) else -1.0
			var y := sign_y * (h * 0.35 + cos(float(i) * 1.8) * h * 0.25)
			pts2.append(pos + Vector2(x, y))
		pts2.append(pos + Vector2(w * 0.4, -2 * s))
		draw_ink_stroke(self, pts2, 1.8 * s, InkStroke.Profile.TAPER_BOTH, ink_color)

func _draw_flying_sweat(pos: Vector2, dir_x: float, s: float) -> void:
	var sz: float = 10.0 * s
	var steps: int = 10
	var rot: float = 0.55 if dir_x > 0 else -0.55
	
	var base_pts := PackedVector2Array()
	base_pts.append(Vector2(0.0, -sz * 0.85))
	var bulb_center := Vector2(0.0, sz * 0.2)
	var radius := sz * 0.45
	for i in range(steps + 1):
		var ang: float = lerpf(0.12 * PI, 0.88 * PI, float(i) / float(steps))
		base_pts.append(bulb_center + Vector2(cos(ang) * radius, sin(ang) * radius))
	
	var pts := PackedVector2Array()
	for pt in base_pts:
		pts.append(pos + pt.rotated(rot))
	
	if pts.size() >= 3 and draw_progress >= 0.2:
		var fill := Color("#aee2f8", 0.9) if not is_monochrome else Color(0.9, 0.9, 0.9, 0.85)
		draw_colored_polygon(pts, fill)
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_ink_stroke(self, closed, 1.4 * s, InkStroke.Profile.UNIFORM, ink_color)

func _draw_panic_vibrations(pos: Vector2, s: float) -> void:
	var count: int = 4 + intensity
	var span: float = 50.0 * s
	for i in range(count):
		var x := lerpf(-span * 0.5, span * 0.5, float(i) / float(count - 1))
		var p1 := pos + Vector2(x, -6 * s)
		var p2 := pos + Vector2(x, 6 * s)
		draw_ink_stroke(self, PackedVector2Array([p1, p2]), 1.3 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
