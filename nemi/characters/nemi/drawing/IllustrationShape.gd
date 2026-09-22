class_name IllustrationShape
extends RefCounted

## Encapsulates an illustrated 2D component with fill, calligraphic outlines, and interior crease strokes.
## This structure enforces the YouTube storytime illustration style:
## solid color fill -> selective interior crease lines -> weighted outer calligraphic contour.

var fill_polygon: PackedVector2Array = PackedVector2Array()
var fill_color: Color = Color.WHITE
var outline_strokes: Array[InkStroke] = []
var interior_strokes: Array[InkStroke] = []

func _init(p_fill: PackedVector2Array = PackedVector2Array(), p_fill_col: Color = Color.WHITE) -> void:
	fill_polygon = p_fill
	fill_color = p_fill_col
	outline_strokes = []
	interior_strokes = []

## Adds an interior crease or fold stroke
func add_interior_stroke(stroke: InkStroke) -> void:
	interior_strokes.append(stroke)

## Adds an exterior outline stroke
func add_outline_stroke(stroke: InkStroke) -> void:
	outline_strokes.append(stroke)

## Draws the complete illustrated shape to the canvas item
func draw_to(canvas_item: CanvasItem, fill_override: Color = Color.TRANSPARENT, ink_override: Color = Color.TRANSPARENT) -> void:
	var f_col: Color = fill_override if fill_override.a > 0.0 else fill_color
	
	# 1. Fill polygon
	if fill_polygon.size() >= 3 and f_col.a > 0.0:
		canvas_item.draw_colored_polygon(fill_polygon, f_col)
	
	# 2. Interior strokes (subtle, drawn under outlines)
	for s in interior_strokes:
		if s:
			s.draw_to(canvas_item, ink_override)
	
	# 3. Outline strokes (weighted perimeter)
	for s in outline_strokes:
		if s:
			s.draw_to(canvas_item, ink_override)
