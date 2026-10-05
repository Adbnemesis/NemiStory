class_name CommonInkStroke
extends RefCounted

## CommonInkStroke — Independent Calligraphic Ink Stroke Engine
## Generates smooth variable-width ribbon polygons with natural pen pressure tapering,
## eliminating sterile uniform-width lines while guaranteeing 100% triangulation validity.
## Fully decoupled from character-specific code. Shared by Nemi, ADB, and future characters.

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
var stroke_color: Color = Color("#1c1822") # Common master dark ink

func _init(p_points: PackedVector2Array = PackedVector2Array(), p_width: float = 3.5, p_profile: Profile = Profile.TAPER_BOTH, p_color: Color = Color("#1c1822")) -> void:
	points = p_points
	base_width = p_width
	profile = p_profile
	stroke_color = p_color

## Factory: Creates a CommonInkStroke from a Curve2D with dense Bézier tessellation
static func from_curve(curve: Curve2D, width: float = 3.5, prof: Profile = Profile.TAPER_BOTH, col: Color = Color("#1c1822"), max_stages: int = 5, tolerance_deg: float = 2.5) -> RefCounted:
	var dense_pts: PackedVector2Array = curve.tessellate(max_stages, tolerance_deg)
	var stroke_script = load("res://common/engine/drawing/CommonInkStroke.gd")
	return stroke_script.new(dense_pts, width, prof, col)

## Factory: Creates a straight or multi-segment tapered stroke from points
static func from_points(pts: PackedVector2Array, width: float = 3.5, prof: Profile = Profile.TAPER_BOTH, col: Color = Color("#1c1822")) -> RefCounted:
	var stroke_script = load("res://common/engine/drawing/CommonInkStroke.gd")
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
			# Sweeping lash: thin start (0.2), lush heavy peak at t=0.6 (1.3x), sharp flick at end
			if t < 0.6:
				return lerpf(0.20, 1.35, ease(t / 0.6, 0.65))
			else:
				var exit_t := (t - 0.6) / 0.4
				return lerpf(1.35, 0.08, ease(exit_t, 1.8))

		Profile.DELICATE_CREASE:
			# Soft subtle crease: swells gently to 0.7 max width with soft feathered ends
			return 0.70 * sin(t * PI)

	return 1.0

## Generates polygon vertices for smooth ribbon rendering with rounded end caps
func build_polygon() -> PackedVector2Array:
	if points.size() < 2:
		return PackedVector2Array()

	# Pre-calculate cumulative arc lengths for accurate distance normalization
	var total_len := 0.0
	var seg_lens: Array[float] = []
	for i in range(points.size() - 1):
		var sl: float = points[i].distance_to(points[i + 1])
		seg_lens.append(sl)
		total_len += sl

	if total_len <= 0.001:
		return PackedVector2Array()

	var left_side := PackedVector2Array()
	var right_side := PackedVector2Array()
	var cur_dist := 0.0

	for i in range(points.size()):
		var t := cur_dist / total_len
		var w_factor := get_width_factor_at(t)
		var half_w := (base_width * 0.5) * w_factor

		# Compute tangent vector
		var tangent := Vector2.ZERO
		if i == 0:
			tangent = (points[1] - points[0]).normalized()
		elif i == points.size() - 1:
			tangent = (points[i] - points[i - 1]).normalized()
		else:
			var t1 := (points[i] - points[i - 1]).normalized()
			var t2 := (points[i + 1] - points[i]).normalized()
			tangent = (t1 + t2).normalized()
			if tangent.length_squared() < 0.001:
				tangent = t1

		var normal := Vector2(-tangent.y, tangent.x)

		left_side.append(points[i] + normal * half_w)
		right_side.append(points[i] - normal * half_w)

		if i < seg_lens.size():
			cur_dist += seg_lens[i]

	# Combine left edge + reversed right edge to form a single continuous polygon boundary
	var poly := PackedVector2Array()
	for pt in left_side:
		poly.append(pt)
	for idx in range(right_side.size() - 1, -1, -1):
		poly.append(right_side[idx])

	return poly

## Renders the ribbon directly to any Godot CanvasItem node
func draw_to(canvas: CanvasItem) -> void:
	if points.size() < 2:
		return

	var poly := build_polygon()
	if poly.size() >= 3:
		canvas.draw_colored_polygon(poly, stroke_color)

		# Round end caps for smooth organic pen terminal feel
		var start_r := (base_width * 0.5) * get_width_factor_at(0.0)
		var end_r := (base_width * 0.5) * get_width_factor_at(1.0)
		if start_r > 0.6:
			canvas.draw_circle(points[0], start_r, stroke_color)
		if end_r > 0.6:
			canvas.draw_circle(points[points.size() - 1], end_r, stroke_color)
	else:
		# Fallback to smooth polyline if polygon construction degenerate
		canvas.draw_polyline(points, stroke_color, base_width, true)
