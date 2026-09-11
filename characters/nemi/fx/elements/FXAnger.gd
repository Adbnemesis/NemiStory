class_name FXAnger
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn anger & irritation reaction:
## Anime stress vein mark (💢), sharp jagged emphasis lines, and compressed anger scribbles.

enum AngerStyle {
	STRESS_VEIN,
	JAGGED_BURST,
	SCRIBBLE_TENSION,
	FULL_ANGER
}

@export var style_type: AngerStyle = AngerStyle.FULL_ANGER

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_RIGHT
	anchor_offset = Vector2(44.0, -84.0)
	entrance_style = EntranceStyle.POP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.25

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.18)
	var anger_col := Color("#d63031") if (not is_monochrome) else ink_color
	
	match style_type:
		AngerStyle.STRESS_VEIN:
			_draw_stress_vein(Vector2.ZERO, s, anger_col)
		AngerStyle.JAGGED_BURST:
			_draw_jagged_spikes(Vector2.ZERO, s, anger_col)
		AngerStyle.SCRIBBLE_TENSION:
			_draw_anger_scribble(Vector2.ZERO, s, anger_col)
		AngerStyle.FULL_ANGER:
			if intensity <= 2:
				_draw_stress_vein(Vector2.ZERO, s, anger_col)
			elif intensity <= 4:
				_draw_stress_vein(Vector2.ZERO, s * 1.1, anger_col)
				_draw_jagged_spikes(Vector2(14 * s, -14 * s), s * 0.9, anger_col)
			else: # Intensity 5: massive furious stress burst
				_draw_stress_vein(Vector2.ZERO, s * 1.35, anger_col)
				_draw_jagged_spikes(Vector2(20 * s, -18 * s), s * 1.2, anger_col)
				_draw_anger_scribble(Vector2(-18 * s, 16 * s), s * 1.1, ink_color)

## Draws the classic 4-corner curved anime stress vein cross (💢)
func _draw_stress_vein(pos: Vector2, s: float, col: Color) -> void:
	var arm: float = 12.0 * s
	var c_rad: float = arm * 0.55
	
	# Top-Left arc
	var c_tl := Curve2D.new()
	c_tl.add_point(pos + Vector2(-arm, -arm * 0.25))
	c_tl.add_point(pos + Vector2(-c_rad, -c_rad), Vector2(0, 0), Vector2(c_rad * 0.3, c_rad * 0.3))
	c_tl.add_point(pos + Vector2(-arm * 0.25, -arm))
	draw_ink_curve(self, c_tl, 2.8 * s, InkStroke.Profile.TAPER_BOTH, col)
	
	# Top-Right arc
	var c_tr := Curve2D.new()
	c_tr.add_point(pos + Vector2(arm * 0.25, -arm))
	c_tr.add_point(pos + Vector2(c_rad, -c_rad), Vector2(0, 0), Vector2(-c_rad * 0.3, c_rad * 0.3))
	c_tr.add_point(pos + Vector2(arm, -arm * 0.25))
	draw_ink_curve(self, c_tr, 2.8 * s, InkStroke.Profile.TAPER_BOTH, col)
	
	# Bottom-Right arc
	var c_br := Curve2D.new()
	c_br.add_point(pos + Vector2(arm, arm * 0.25))
	c_br.add_point(pos + Vector2(c_rad, c_rad), Vector2(0, 0), Vector2(-c_rad * 0.3, -c_rad * 0.3))
	c_br.add_point(pos + Vector2(arm * 0.25, arm))
	draw_ink_curve(self, c_br, 2.8 * s, InkStroke.Profile.TAPER_BOTH, col)
	
	# Bottom-Left arc
	var c_bl := Curve2D.new()
	c_bl.add_point(pos + Vector2(-arm * 0.25, arm))
	c_bl.add_point(pos + Vector2(-c_rad, c_rad), Vector2(0, 0), Vector2(c_rad * 0.3, -c_rad * 0.3))
	c_bl.add_point(pos + Vector2(-arm, arm * 0.25))
	draw_ink_curve(self, c_bl, 2.8 * s, InkStroke.Profile.TAPER_BOTH, col)

func _draw_jagged_spikes(pos: Vector2, s: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var w: float = 16.0 * s
	pts.append(pos + Vector2(-w * 0.5, 0))
	pts.append(pos + Vector2(-w * 0.2, -8 * s))
	pts.append(pos + Vector2(0, 2 * s))
	pts.append(pos + Vector2(w * 0.25, -12 * s))
	pts.append(pos + Vector2(w * 0.5, -3 * s))
	draw_ink_stroke(self, pts, 2.2 * s, InkStroke.Profile.TAPER_BOTH, col)

func _draw_anger_scribble(pos: Vector2, s: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var r: float = 12.0 * s
	pts.append(pos + Vector2(-r, -r * 0.3))
	pts.append(pos + Vector2(-r * 0.2, r * 0.8))
	pts.append(pos + Vector2(r * 0.4, -r * 0.6))
	pts.append(pos + Vector2(r, r * 0.5))
	draw_ink_stroke(self, pts, 2.0 * s, InkStroke.Profile.TAPER_BOTH, col)
