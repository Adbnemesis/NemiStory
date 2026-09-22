class_name PokemonInkStroke
extends RefCounted

## Calligraphic variable-width ink stroke renderer for the Pokémon character animation system.
## Produces organic hand-drawn linework with pen-pressure tapering, preventing sterile uniform lines.

enum Profile {
	UNIFORM,
	TAPER_BOTH,
	TAPER_START,
	TAPER_END,
	CALLIGRAPHIC_LASH,
	DELICATE_CREASE,
	SHARP_ACCENT
}

var points: PackedVector2Array = PackedVector2Array()
var base_width: float = 3.2
var profile: Profile = Profile.TAPER_BOTH
var min_taper_ratio: float = 0.12
var stroke_color: Color = Color("#262224")

func _init(p_points: PackedVector2Array = PackedVector2Array(), p_width: float = 3.2, p_profile: Profile = Profile.TAPER_BOTH, p_color: Color = Color("#262224")) -> void:
	points = p_points
	base_width = p_width
	profile = p_profile
	stroke_color = p_color

static func from_curve(curve: Curve2D, width: float = 3.2, prof: int = Profile.TAPER_BOTH, col: Color = Color("#262224"), max_stages: int = 5, tolerance_deg: float = 2.5) -> RefCounted:
	var dense_pts: PackedVector2Array = curve.tessellate(max_stages, tolerance_deg)
	var stroke_script = load("res://pokemon/scripts/PokemonInkStroke.gd")
	return stroke_script.new(dense_pts, width, prof, col)

static func from_points(pts: PackedVector2Array, width: float = 3.2, prof: int = Profile.TAPER_BOTH, col: Color = Color("#262224")) -> RefCounted:
	var stroke_script = load("res://pokemon/scripts/PokemonInkStroke.gd")
	return stroke_script.new(pts, width, prof, col)

func get_width_factor_at(t: float) -> float:
	match profile:
		Profile.UNIFORM:
			return 1.0
		Profile.TAPER_BOTH:
			return maxf(min_taper_ratio, sin(t * PI))
		Profile.TAPER_START:
			var factor := smoothstep(0.0, 0.45, t)
			return maxf(min_taper_ratio, factor)
		Profile.TAPER_END:
			var factor := 1.0 - smoothstep(0.4, 1.0, t)
			return maxf(min_taper_ratio, factor)
		Profile.CALLIGRAPHIC_LASH:
			if t < 0.5:
				return lerpf(0.3, 1.35, smoothstep(0.0, 0.5, t))
			else:
				return lerpf(1.35, 0.08, smoothstep(0.5, 1.0, t))
		Profile.DELICATE_CREASE:
			var s := sin(t * PI)
			return lerpf(min_taper_ratio, 0.85, sqrt(s))
		Profile.SHARP_ACCENT:
			return lerpf(1.3, 0.1, t * t)
		_:
			return 1.0

func generate_ribbon_polygon() -> PackedVector2Array:
	if points.size() < 2:
		return PackedVector2Array()
	
	var n: int = points.size()
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
	
	var ribbon := PackedVector2Array()
	ribbon.resize(n * 2)
	for i in range(n):
		ribbon[i] = left_side[i]
	for i in range(n):
		ribbon[n + i] = right_side[n - 1 - i]
	
	return ribbon

func draw_to(canvas_item: CanvasItem, color_override: Color = Color.TRANSPARENT) -> void:
	if points.size() < 2:
		return
	
	var col: Color = color_override if color_override.a > 0.0 else stroke_color
	
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
