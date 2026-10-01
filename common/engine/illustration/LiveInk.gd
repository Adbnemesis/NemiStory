extends RefCounted
## Cached, seekable ink. Pressure is evaluated against the FULL stroke, so ink
## already on the page does not change width when the pen advances.
var strokes: Array[Dictionary] = []
var total_time: float = 0.0

static func curve(points: PackedVector2Array, smooth: bool = true) -> PackedVector2Array:
	if points.size() < 3 or not smooth:
		return points
	var result := PackedVector2Array()
	for i in range(points.size() - 1):
		var a := points[maxi(0, i - 1)]
		var b := points[i]
		var c := points[i + 1]
		var d := points[mini(points.size() - 1, i + 2)]
		var steps := maxi(3, int(ceil(b.distance_to(c) / 3.0)))
		for j in range(steps):
			var t := float(j) / steps
			result.append(0.5 * ((2.0 * b) + (-a + c) * t + (2.0 * a - 5.0 * b + 4.0 * c - d) * t * t + (-a + 3.0 * b - 3.0 * c + d) * t * t * t))
	result.append(points[-1])
	return result

func prepare(source: Array) -> void:
	strokes.clear()
	total_time = 0.0
	for item in source:
		var raw: PackedVector2Array = item.get("pts", PackedVector2Array())
		if raw.size() < 2:
			continue
		var pts := curve(raw, item.get("smooth", false))
		var lengths := PackedFloat32Array([0.0])
		for i in range(1, pts.size()):
			lengths.append(lengths[-1] + pts[i - 1].distance_to(pts[i]))
		var length: float = lengths[-1]
		if length < 0.001:
			continue
		# Real pen lifts consume time; long marks take longer than dots.
		total_time += maxf(0.0, float(item.get("pause", 0.025)))
		var duration: float = maxf(0.015, float(item.get("duration", length / 460.0)))
		strokes.append({"pts": pts, "lengths": lengths, "length": length,
			"start": total_time, "duration": duration, "w": item.get("w", 3.0),
			"col": item.get("col", Color("#423035")),
			"pressure": item.get("pressure", PackedFloat32Array([0.32, 0.9, 1.0, 0.76, 0.18]))})
		total_time += duration

static func pressure_at(values: PackedFloat32Array, t: float) -> float:
	if values.is_empty():
		return 1.0
	var f := clampf(t, 0.0, 1.0) * (values.size() - 1)
	var i := int(f)
	return lerpf(values[i], values[mini(i + 1, values.size() - 1)], f - i)

func visible_distance(stroke: Dictionary, progress: float) -> float:
	var elapsed := clampf(progress, 0.0, 1.0) * total_time
	var u := clampf((elapsed - float(stroke.start)) / float(stroke.duration), 0.0, 1.0)
	# Soft arrival/departure, with a faster middle. No global ease-out that
	# makes the last letters crawl while the first ones flash past.
	var spacing := u * u * (3.0 - 2.0 * u)
	return float(stroke.length) * spacing

func draw_to(canvas: CanvasItem, progress: float) -> void:
	for stroke in strokes:
		var distance := visible_distance(stroke, progress)
		if distance <= 0.001:
			continue
		var pts: PackedVector2Array = stroke.pts
		var lengths: PackedFloat32Array = stroke.lengths
		var pressure: PackedFloat32Array = stroke.pressure
		var color: Color = stroke.col
		var visible_pts := PackedVector2Array([pts[0]])
		var widths := PackedFloat32Array([float(stroke.w) * pressure_at(pressure, 0.0)])
		for i in range(1, pts.size()):
			var start_d: float = lengths[i - 1]
			if start_d >= distance:
				break
			var end_d: float = minf(distance, lengths[i])
			var seg_len: float = lengths[i] - start_d
			if seg_len < 0.001:
				continue
			var end := pts[i - 1].lerp(pts[i], (end_d - start_d) / seg_len)
			var subdivisions := maxi(1, int(ceil((end_d - start_d) / 3.0)))
			for j in range(1, subdivisions + 1):
				var fraction := float(j) / subdivisions
				visible_pts.append(pts[i - 1].lerp(end, fraction))
				widths.append(float(stroke.w) * pressure_at(pressure, lerpf(start_d,end_d,fraction)/float(stroke.length)))
		var left := PackedVector2Array()
		var right := PackedVector2Array()
		for i in range(visible_pts.size()):
			var tangent: Vector2
			if i == 0:
				tangent = visible_pts[1] - visible_pts[0]
			elif i == visible_pts.size() - 1:
				tangent = visible_pts[i] - visible_pts[i-1]
			else:
				tangent = (visible_pts[i] - visible_pts[i-1]).normalized() + (visible_pts[i+1] - visible_pts[i]).normalized()
			var normal := Vector2(-tangent.y,tangent.x).normalized() * maxf(0.3,widths[i]) * 0.5
			left.append(visible_pts[i] + normal)
			right.append(visible_pts[i] - normal)
		var polygon := left.duplicate()
		right.reverse()
		polygon.append_array(right)
		if Geometry2D.triangulate_polygon(polygon).size() > 0:
			canvas.draw_colored_polygon(polygon,color)
			# One continuous AA boundary avoids the bead-like edges produced
			# by layering hundreds of antialiased circles along a line.
			polygon.append(polygon[0])
			canvas.draw_polyline(polygon,color,0.5,true)
		else:
			# Fill intersecting ribbons segment by segment, with AA only on
			# the continuous boundaries (not on each internal segment).
			right.reverse()
			for i in range(1,left.size()):
				var quad := PackedVector2Array([left[i-1],left[i],right[i],right[i-1]])
				if Geometry2D.triangulate_polygon(quad).size()>0:
					canvas.draw_colored_polygon(quad,color)
			canvas.draw_polyline(left,color,0.5,true)
			canvas.draw_polyline(right,color,0.5,true)
