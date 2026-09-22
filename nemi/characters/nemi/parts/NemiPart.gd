class_name NemiPart
extends Node2D

## Base class for all Godot-native visual drawing parts of NEMI
## Connects to NemiStyle and handles drawing helpers.

var style: NemiStyle:
	set(val):
		if style != val:
			if style and style.style_changed.is_connected(_on_style_changed):
				style.style_changed.disconnect(_on_style_changed)
			style = val
			if style:
				style.style_changed.connect(_on_style_changed)
			queue_redraw()

func _ready() -> void:
	if not style:
		_find_style_in_ancestors()
	queue_redraw()

func _find_style_in_ancestors() -> void:
	var p: Node = get_parent()
	while p:
		if "style" in p and p.style is NemiStyle:
			style = p.style
			return
		p = p.get_parent()

func _on_style_changed() -> void:
	queue_redraw()

# Drawing helpers
func draw_part_polygon(poly: PackedVector2Array, fill_color: Color, outline_color: Color = Color.TRANSPARENT, outline_width: float = 0.0) -> void:
	if poly.size() < 3:
		return
	draw_colored_polygon(poly, fill_color)
	if outline_color.a > 0.0 and outline_width > 0.0:
		var closed_poly := poly.duplicate()
		closed_poly.append(poly[0])
		draw_polyline(closed_poly, outline_color, outline_width, true)

func draw_part_polyline(points: PackedVector2Array, stroke_color: Color, stroke_width: float) -> void:
	if points.size() < 2:
		return
	draw_polyline(points, stroke_color, stroke_width, true)
