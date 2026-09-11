class_name FXRealization
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn realization & "idea" reaction:
## Hand-drawn lightbulb doodle with glowing filament, sudden spark rays, and exclamation pop.

enum RealizationStyle {
	LIGHTBULB,
	SPARK_BURST,
	LIGHTBULB_AND_SPARKS
}

@export var style_type: RealizationStyle = RealizationStyle.LIGHTBULB_AND_SPARKS

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_TOP
	anchor_offset = Vector2(0.0, -125.0)
	entrance_style = EntranceStyle.POP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.35

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.16)
	
	match style_type:
		RealizationStyle.LIGHTBULB:
			_draw_lightbulb(Vector2.ZERO, s)
		RealizationStyle.SPARK_BURST:
			_draw_spark_rays(Vector2.ZERO, s)
		RealizationStyle.LIGHTBULB_AND_SPARKS:
			if intensity <= 2:
				_draw_spark_rays(Vector2.ZERO, s * 0.8)
			elif intensity <= 4:
				_draw_lightbulb(Vector2.ZERO, s)
				_draw_spark_rays(Vector2(0, -6 * s), s)
			else: # Intensity 5: lightbulb + wide spark burst + exclamation
				_draw_lightbulb(Vector2.ZERO, s * 1.15)
				_draw_spark_rays(Vector2(0, -6 * s), s * 1.3)
				_draw_realization_exclamation(Vector2(26 * s, -16 * s), s)

func _draw_lightbulb(pos: Vector2, s: float) -> void:
	var bulb_r: float = 14.0 * s
	var c_bulb := pos + Vector2(0, -bulb_r * 0.6)
	
	# Glass bulb contour
	var bulb_pts := PackedVector2Array()
	var steps: int = 18
	for i in range(steps + 1):
		var ang: float = lerpf(-PI * 0.82, PI * 0.82, float(i) / float(steps))
		bulb_pts.append(c_bulb + Vector2(cos(ang) * bulb_r, sin(ang) * bulb_r))
	
	# Neck down to screw base
	bulb_pts.append(pos + Vector2(bulb_r * 0.38, bulb_r * 0.6))
	bulb_pts.append(pos + Vector2(-bulb_r * 0.38, bulb_r * 0.6))
	
	if bulb_pts.size() >= 3 and draw_progress >= 0.2:
		var fill := Color("#fff8cc", 0.95) if not is_monochrome else Color(0.95, 0.95, 0.95, 0.9)
		draw_colored_polygon(bulb_pts, fill)
		
		# Glowing yellow filament (M-shape / loop)
		var fil_col := Color("#e67e22") if not is_monochrome else ink_color
		var fil_pts := PackedVector2Array([
			c_bulb + Vector2(-bulb_r * 0.25, bulb_r * 0.3),
			c_bulb + Vector2(-bulb_r * 0.15, -bulb_r * 0.2),
			c_bulb + Vector2(0.0, -bulb_r * 0.05),
			c_bulb + Vector2(bulb_r * 0.15, -bulb_r * 0.2),
			c_bulb + Vector2(bulb_r * 0.25, bulb_r * 0.3)
		])
		draw_ink_stroke(self, fil_pts, 1.8 * s, InkStroke.Profile.UNIFORM, fil_col)
		
		# Outer ink stroke for bulb
		var closed_bulb := bulb_pts.duplicate()
		closed_bulb.append(bulb_pts[0])
		draw_ink_stroke(self, closed_bulb, 2.0 * s, InkStroke.Profile.UNIFORM, ink_color)
		
		# Metal screw base ridges
		var base_top := pos + Vector2(-bulb_r * 0.35, bulb_r * 0.6)
		var base_bot := pos + Vector2(bulb_r * 0.35, bulb_r * 0.6)
		draw_ink_stroke(self, PackedVector2Array([base_top, base_bot]), 2.2 * s, InkStroke.Profile.UNIFORM, ink_color)
		
		var base_top2 := pos + Vector2(-bulb_r * 0.28, bulb_r * 0.8)
		var base_bot2 := pos + Vector2(bulb_r * 0.28, bulb_r * 0.8)
		draw_ink_stroke(self, PackedVector2Array([base_top2, base_bot2]), 2.2 * s, InkStroke.Profile.UNIFORM, ink_color)

func _draw_spark_rays(pos: Vector2, s: float) -> void:
	var ray_count: int = 5 + intensity
	var r_inner: float = 22.0 * s
	var r_outer: float = (32.0 + float(intensity) * 5.0) * s
	
	var ray_col := Color("#f39c12") if not is_monochrome else ink_color
	for i in range(ray_count):
		var ang: float = lerpf(-PI * 0.9, -PI * 0.1, float(i) / float(ray_count - 1))
		var dir := Vector2(cos(ang), sin(ang))
		var p1 := pos + dir * r_inner
		var p2 := pos + dir * r_outer
		draw_ink_stroke(self, PackedVector2Array([p1, p2]), 2.0 * s, InkStroke.Profile.TAPER_START, ray_col)

func _draw_realization_exclamation(pos: Vector2, s: float) -> void:
	var p1 := pos + Vector2(0, -18 * s)
	var p2 := pos + Vector2(0, -4 * s)
	var col := Color("#e74c3c") if not is_monochrome else ink_color
	draw_ink_stroke(self, PackedVector2Array([p1, p2]), 2.6 * s, InkStroke.Profile.TAPER_END, col)
	if draw_progress >= 0.75:
		draw_circle(pos + Vector2(0, 2 * s), 2.0 * s, col)
