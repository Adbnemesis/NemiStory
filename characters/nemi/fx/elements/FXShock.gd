class_name FXShock
extends "res://characters/nemi/fx/NemiFXElement.gd"

## Hand-drawn shock & impact reaction:
## Radial calligraphic spike bursts, exclamation mark(s), and vertical tension shock lines.

enum ShockStyle {
	RADIAL_BURST,
	EXCLAMATION,
	VERTICAL_LINES,
	FULL_SHOCK
}

@export var style_type: ShockStyle = ShockStyle.FULL_SHOCK

func _init() -> void:
	anchor_type = NemiFXAnchor.AnchorType.HEAD_TOP
	anchor_offset = Vector2(0.0, -118.0)
	entrance_style = EntranceStyle.SNAP
	exit_style = ExitStyle.FADE
	auto_dismiss_time = 0.95

func _draw() -> void:
	var s: float = 0.8 + (float(intensity) * 0.18)
	
	match style_type:
		ShockStyle.RADIAL_BURST:
			_draw_radial_burst(Vector2.ZERO, s)
		ShockStyle.EXCLAMATION:
			_draw_exclamation_marks(Vector2(0, -10), s)
		ShockStyle.VERTICAL_LINES:
			_draw_vertical_shock_lines(Vector2.ZERO, s)
		ShockStyle.FULL_SHOCK:
			if intensity <= 2:
				_draw_exclamation_marks(Vector2(18, -10), s)
				_draw_vertical_shock_lines(Vector2(0, -15), s * 0.7)
			elif intensity <= 4:
				_draw_radial_burst(Vector2(0, 15), s)
				_draw_exclamation_marks(Vector2(24, -18), s * 1.1)
			else: # Intensity 5: massive comic recoil
				_draw_radial_burst(Vector2(0, 20), s * 1.3)
				_draw_double_exclamation(Vector2(28, -22), s * 1.3)
				_draw_vertical_shock_lines(Vector2(0, -25), s * 1.1)

func _draw_radial_burst(pos: Vector2, s: float) -> void:
	var rays: int = 6 + (intensity * 2)
	var min_r: float = 28.0 * s
	var max_r: float = (50.0 + float(intensity) * 8.0) * s
	
	for i in range(rays):
		# Spread outward in an upward 220-degree arc around the head
		var angle: float = lerpf(-PI * 0.85, -PI * 0.15, float(i) / float(rays - 1))
		# Add natural organic irregularity
		var jitter_len := sin(float(i) * 3.7) * 8.0 * s
		var r_start := min_r + jitter_len * 0.3
		var r_end := max_r + jitter_len
		
		var dir := Vector2(cos(angle), sin(angle))
		var p1 := pos + dir * r_start
		var p2 := pos + dir * r_end
		
		draw_ink_stroke(self, PackedVector2Array([p1, p2]), 2.8 * s, InkStroke.Profile.TAPER_START, ink_color)

func _draw_exclamation_marks(pos: Vector2, s: float) -> void:
	var h: float = 26.0 * s
	var top := pos + Vector2(0, -h)
	var bot := pos + Vector2(0, -h * 0.25)
	
	var col := accent_color if (not is_monochrome and intensity >= 3) else ink_color
	# Main tapered exclamation bar
	draw_ink_stroke(self, PackedVector2Array([top, bot]), 3.2 * s, InkStroke.Profile.TAPER_END, col)
	
	# Exclamation dot
	if draw_progress >= 0.75 and erase_progress < 0.95:
		draw_circle(pos + Vector2(0, 2.0 * s), 2.2 * s, col)

func _draw_double_exclamation(pos: Vector2, s: float) -> void:
	_draw_exclamation_marks(pos + Vector2(-9 * s, 0), s * 0.9)
	_draw_exclamation_marks(pos + Vector2(9 * s, -4 * s), s * 1.15)

func _draw_vertical_shock_lines(pos: Vector2, s: float) -> void:
	var count: int = 4 + intensity
	var spacing: float = 9.0 * s
	var line_len: float = (22.0 + float(intensity) * 5.0) * s
	
	for i in range(count):
		var ox := float(i - count / 2) * spacing
		var p1 := pos + Vector2(ox, -line_len * 0.5)
		var p2 := pos + Vector2(ox, line_len * 0.5)
		draw_ink_stroke(self, PackedVector2Array([p1, p2]), 1.8 * s, InkStroke.Profile.TAPER_BOTH, ink_color)
