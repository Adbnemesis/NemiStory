extends Node2D
## Paints one filled dot (meta "radius", meta "color").
func _draw() -> void:
	var radius: float = float(get_meta("radius", 5.0))
	var col: Color = get_meta("color", Color("#38101e"))
	draw_circle(Vector2.ZERO, radius, col)
