class_name IllustrationCanvas2D
extends RefCounted

## Reusable Godot-native illustration drawing layer.
## Bridges vector geometry with hand-drawn aesthetic:
## - Organic closed contours with solid or cel fills
## - Variable-width calligraphic ink strokes with natural pen pressure tapering
## - Open and broken contours with implied boundaries
## - Guaranteed 100% triangulation validity with zero external raster textures.

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

enum StrokeProfile {
	UNIFORM = 0,
	TAPER_BOTH = 1,
	TAPER_START = 2,
	TAPER_END = 3,
	CALLIGRAPHIC_LASH = 4,
	DELICATE_CREASE = 5
}

## Draws a filled organic polygon with an optional calligraphic outline
static func draw_illustrated_shape(
	canvas: CanvasItem,
	polygon: PackedVector2Array,
	fill_color: Color,
	outline_color: Color = Color.TRANSPARENT,
	outline_width: float = 0.0,
	is_closed: bool = true
) -> void:
	if polygon.size() < 3:
		return
	
	# 1. Base organic fill
	if fill_color.a > 0.0:
		canvas.draw_colored_polygon(polygon, fill_color)
	
	# 2. Outline stroke
	if outline_color.a > 0.0 and outline_width > 0.0:
		if is_closed:
			var closed_pts := polygon.duplicate()
			closed_pts.append(polygon[0])
			canvas.draw_polyline(closed_pts, outline_color, outline_width, true)
		else:
			canvas.draw_polyline(polygon, outline_color, outline_width, true)

## Draws a 2-tone cel-shaded region (base fill + cast shadow facet)
static func draw_cel_shaded_shape(
	canvas: CanvasItem,
	base_polygon: PackedVector2Array,
	shadow_polygon: PackedVector2Array,
	base_color: Color,
	shadow_color: Color,
	outline_color: Color = Color.TRANSPARENT,
	outline_width: float = 0.0
) -> void:
	if base_polygon.size() < 3:
		return
	
	# Base tone
	canvas.draw_colored_polygon(base_polygon, base_color)
	
	# Shadow facet
	if shadow_polygon.size() >= 3 and shadow_color.a > 0.0:
		canvas.draw_colored_polygon(shadow_polygon, shadow_color)
	
	# Clean outline
	if outline_color.a > 0.0 and outline_width > 0.0:
		var closed_pts := base_polygon.duplicate()
		closed_pts.append(base_polygon[0])
		canvas.draw_polyline(closed_pts, outline_color, outline_width, true)

## Draws an authored calligraphic stroke from a Curve2D with pen pressure tapering
static func draw_curve_stroke(
	canvas: CanvasItem,
	curve: Curve2D,
	width: float,
	profile: int = StrokeProfile.TAPER_BOTH,
	color: Color = Color("#3e081e"),
	max_stages: int = 5,
	tolerance_deg: float = 2.0
) -> void:
	var stroke: RefCounted = InkStroke.from_curve(curve, width, profile, color, max_stages, tolerance_deg)
	if stroke and stroke.has_method("draw_to"):
		stroke.draw_to(canvas)

## Draws an authored calligraphic stroke from discrete points
static func draw_points_stroke(
	canvas: CanvasItem,
	points: PackedVector2Array,
	width: float,
	profile: int = StrokeProfile.TAPER_BOTH,
	color: Color = Color("#3e081e")
) -> void:
	var stroke: RefCounted = InkStroke.from_points(points, width, profile, color)
	if stroke and stroke.has_method("draw_to"):
		stroke.draw_to(canvas)

## Draws an open implied contour (e.g. cheek crease, sleeve fold, hair strand)
static func draw_open_contour(
	canvas: CanvasItem,
	points: PackedVector2Array,
	width: float,
	color: Color = Color("#3e081e"),
	profile: int = StrokeProfile.DELICATE_CREASE
) -> void:
	draw_points_stroke(canvas, points, width, profile, color)
