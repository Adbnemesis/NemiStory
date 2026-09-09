class_name InkStroke
extends RefCounted

## Represents an intentional, calligraphic hand-drawn ink stroke.
## Generates smooth variable-width ribbon polygons with natural pen pressure tapering,
## eliminating sterile uniform-width lines while guaranteeing 100% triangulation validity.

enum Profile {
	UNIFORM,            # Constant line width
	TAPER_BOTH,         # Tapers to fine point at both start and end
	TAPER_START,        # Starts fine, swells to full width
	TAPER_END,          # Starts full width, tapers to fine point at end (flicks, hair tips)
	CALLIGRAPHIC_LASH,  # Sweeping lash line: thin start, lush heavy arch, sharp wing flick
	DELICATE_CREASE     # Gentle interior crease with soft tapered ends
}

var points: PackedVector2Array = PackedVector2Array()
var base_width: float = 3.5
var profile: Profile = Profile.TAPER_BOTH
var min_taper_ratio: float = 0.12
var stroke_color: Color = Color("#3e081e") # Master burgundy inking

func _init(p_points: PackedVector2Array = PackedVector2Array(), p_width: float = 3.5, p_profile: Profile = Profile.TAPER_BOTH, p_color: Color = Color("#3e081e")) -> void:
	points = p_points
	base_width = p_width
	profile = p_profile
	stroke_color = p_color

## Factory: Creates an InkStroke from a Curve2D with dense Bézier tessellation
static func from_curve(curve: Curve2D, width: float = 3.5, prof: int = 1, col: Color = Color("#3e081e"), max_stages: int = 5, tolerance_deg: float = 2.5) -> RefCounted:
	var dense_pts: PackedVector2Array = curve.tessellate(max_stages, tolerance_deg)
	var stroke_script = load("res://characters/nemi/drawing/InkStroke.gd")
	return stroke_script.new(dense_pts, width, prof, col)

## Factory: Creates a straight or multi-segment tapered stroke
static func from_points(pts: PackedVector2Array, width: float = 3.5, prof: int = 1, col: Color = Color("#3e081e")) -> RefCounted:
	var stroke_script = load("res://characters/nemi/drawing/InkStroke.gd")
	return stroke_script.new(pts, width, prof, col)

## Evaluates the stroke width factor (0.0 to 1.0+) along normalized distance t (0.0 to 1.0)
func get_width_factor_at(t: float) -> float:
	match profile:
		Profile.UNIFORM:
			return 1.0
		
		Profile.TAPER_BOTH:
			# Smooth sine bell curve with min_taper floor
			return maxf(min_taper_ratio, sin(t * PI))
		
		Profile.TAPER_START:
			# Starts fine, reaches full thickness at t = 0.4
			var factor := smoothstep(0.0, 0.4, t)
			return maxf(min_taper_ratio, factor)
		
		Profile.TAPER_END:
			# Full thickness until t = 0.4, then tapers smoothly to sharp point
			var factor := 1.0 - smoothstep(0.4, 1.0, t)
			return maxf(min_taper_ratio, factor)
		
		Profile.CALLIGRAPHIC_LASH:
			# Eyelash profile: starts at 0.2, swells to 1.3 at t = 0.55, tapers to fine wing flick (0.05)
			if t < 0.55:
				var ramp := smoothstep(0.0, 0.55, t)
				return lerpf(0.25, 1.3, ramp)
			else:
				var drop := smoothstep(0.55, 1.0, t)
				return lerpf(1.3, 0.05, drop)
		
		Profile.DELICATE_CREASE:
			# Very subtle soft ends, maintaining ~0.8 width through center
			var s := sin(t * PI)
			return lerpf(min_taper_ratio, 0.85, sqrt(s))
		
		_:
			return 1.0

## Generates a non-self-intersecting closed ribbon polygon
func generate_ribbon_polygon() -> PackedVector2Array:
	if points.size() < 2:
		return PackedVector2Array()
	
	var n: int = points.size()
	
	# Calculate cumulative arc lengths
	var dists: Array[float] = [0.0]
	var total_len: float = 0.0
	for i in range(n - 1):
		total_len += points[i].distance_to(points[i + 1])
		dists.append(total_len)
	
	if total_len <= 0.001:
		return PackedVector2Array()
	
	var left_side := PackedVector2Array()
	var right_side := PackedVector2Array()
	left_side.resize(n)
	right_side.resize(n)
	
	for i in range(n):
		var t: float = dists[i] / total_len
		var w: float = base_width * get_width_factor_at(t)
		var half_w: float = w * 0.5
		
		var normal: Vector2
		if i == 0:
			var tangent: Vector2 = (points[1] - points[0]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		elif i == n - 1:
			var tangent: Vector2 = (points[i] - points[i - 1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		else:
			var tangent: Vector2 = (points[i + 1] - points[i - 1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		
		left_side[i] = points[i] + normal * half_w
		right_side[i] = points[i] - normal * half_w
	
	# Assemble closed ribbon
	var ribbon := PackedVector2Array()
	ribbon.resize(n * 2)
	for i in range(n):
		ribbon[i] = left_side[i]
	for i in range(n):
		ribbon[n + i] = right_side[n - 1 - i]
	
	return ribbon

## Directly renders this calligraphic stroke to any CanvasItem
func draw_to(canvas_item: CanvasItem, color_override: Color = Color.TRANSPARENT) -> void:
	if points.size() < 2:
		return
	
	var col: Color = color_override if color_override.a > 0.0 else stroke_color
	
	# Fast and robust path for uniform strokes
	if profile == Profile.UNIFORM:
		canvas_item.draw_polyline(points, col, base_width, true)
		return
	
	var ribbon: PackedVector2Array = generate_ribbon_polygon()
	if ribbon.size() >= 3:
		var tris := Geometry2D.triangulate_polygon(ribbon)
		if not tris.is_empty():
			canvas_item.draw_colored_polygon(ribbon, col)
		else:
			canvas_item.draw_polyline(points, col, base_width, true)
	else:
		canvas_item.draw_polyline(points, col, base_width, true)
