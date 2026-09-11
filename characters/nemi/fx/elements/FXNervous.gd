class_name FXNervous
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn nervous reaction:
## Dripping teardrop sweat drops and subtle jitter/tension accents.

enum SweatStyle {
	SINGLE_DROP,
	DRIPPING_PAIR,
	NERVOUS_STREAM
}

@export var style_type: SweatStyle = SweatStyle.SINGLE_DROP

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_RIGHT
	anchor_offset = Vector2(46.0, -68.0)
	entrance_style = EntranceStyle.POP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 1.3

func _draw() -> void:
	var s: float = 0.85 + (float(intensity) * 0.16)
	
	match style_type:
		SweatStyle.SINGLE_DROP:
			_draw_droplet(Vector2.ZERO, s * 1.1)
			if intensity >= 3:
				_draw_vibration_ticks(Vector2.ZERO, s)
		
		SweatStyle.DRIPPING_PAIR:
			_draw_droplet(Vector2(-6, -4), s * 1.1)
			_draw_droplet(Vector2(10, 14), s * 0.75) # Secondary drip
			_draw_vibration_ticks(Vector2(-6, -4), s)
		
		SweatStyle.NERVOUS_STREAM:
			_draw_droplet(Vector2(0, -10), s * 1.2)
			_draw_droplet(Vector2(4, 12), s * 0.8)
			_draw_droplet(Vector2(2, 28), s * 0.55) # Small droplet trailing
			_draw_vibration_ticks(Vector2(0, -10), s * 1.2)

func _draw_droplet(pos: Vector2, s: float) -> void:
	var sz: float = 12.0 * s
	var pts := PackedVector2Array()
	var steps: int = 14
	pts.append(pos + Vector2(0.0, -sz * 0.85))
	var bulb_center := pos + Vector2(0.0, sz * 0.2)
	var radius := sz * 0.45
	for i in range(steps + 1):
		var ang: float = lerpf(0.12 * PI, 0.88 * PI, float(i) / float(steps))
		pts.append(bulb_center + Vector2(cos(ang) * radius, sin(ang) * radius))
	
	if pts.size() >= 3 and draw_progress >= 0.2:
		var fill := Color("#aee2f8", 0.92) if not is_monochrome else Color(0.92, 0.92, 0.92, 0.85)
		draw_colored_polygon(pts, fill)
		
		# Tiny white highlight crescent on upper left of droplet
		if not is_monochrome:
			draw_circle(bulb_center + Vector2(-radius * 0.4, -radius * 0.2), 1.6 * s, Color.WHITE)
		
		var outline := pts.duplicate()
		outline.append(pts[0])
		draw_ink_stroke(self, outline, 1.8 * s, InkStroke.Profile.UNIFORM, ink_color)

func _draw_vibration_ticks(pos: Vector2, s: float) -> void:
	var tick_len: float = 7.0 * s
	# Left tick
	var p1 := pos + Vector2(-16 * s, -4 * s)
	var p2 := p1 + Vector2(-tick_len, -tick_len * 0.4)
	draw_ink_stroke(self, PackedVector2Array([p1, p2]), 1.4 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
	
	# Right tick
	var p3 := pos + Vector2(16 * s, -4 * s)
	var p4 := p3 + Vector2(tick_len, -tick_len * 0.4)
	draw_ink_stroke(self, PackedVector2Array([p3, p4]), 1.4 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
