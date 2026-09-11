extends RefCounted
## BezierUtil — shared organic helpers for ToolkitTests (pure GDScript).
## scribble_points() returns a wobbly horizontal scribble polyline.

static func scribble_points(length: float = 90.0, amp: float = 26.0, lobes: int = 3) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var steps := 40
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		pts.append(Vector2(lerpf(-length * 0.5, length * 0.5, t), sin(t * TAU * float(lobes)) * amp * 0.5))
	return pts
