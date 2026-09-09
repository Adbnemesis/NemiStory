extends SceneTree

func _init():
	print("--- Testing InkStroke Ribbon Generation in Godot 4 ---")
	
	var curve := Curve2D.new()
	curve.add_point(Vector2(0, 0), Vector2(0, 0), Vector2(30, -50))
	curve.add_point(Vector2(100, -80), Vector2(-30, 20), Vector2(30, -20))
	curve.add_point(Vector2(200, 0), Vector2(-30, -40), Vector2(0, 0))
	
	var dense_pts := curve.tessellate(5, 2.0)
	print("Dense points along spline: ", dense_pts.size())
	
	# Test profile evaluation
	var ribbon := PackedVector2Array()
	var left_side := PackedVector2Array()
	var right_side := PackedVector2Array()
	
	var total_len := 0.0
	var dists := [0.0]
	for i in range(dense_pts.size() - 1):
		total_len += dense_pts[i].distance_to(dense_pts[i+1])
		dists.append(total_len)
	
	var base_width := 6.0
	for i in range(dense_pts.size()):
		var t: float = (dists[i] / total_len) if total_len > 0.0 else 0.0
		# Taper both ends (sin curve)
		var factor := sin(t * PI)
		var w := base_width * maxf(0.15, factor)
		
		var normal := Vector2.ZERO
		if i == 0:
			var tangent := (dense_pts[1] - dense_pts[0]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		elif i == dense_pts.size() - 1:
			var tangent := (dense_pts[i] - dense_pts[i-1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		else:
			var tangent := (dense_pts[i+1] - dense_pts[i-1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)
		
		left_side.append(dense_pts[i] + normal * (w * 0.5))
		right_side.append(dense_pts[i] - normal * (w * 0.5))
	
	for pt in left_side:
		ribbon.append(pt)
	for i in range(right_side.size() - 1, -1, -1):
		ribbon.append(right_side[i])
	
	print("Ribbon polygon vertices: ", ribbon.size())
	var tris := Geometry2D.triangulate_polygon(ribbon)
	print("Triangles in ribbon: ", tris.size() / 3)
	if tris.is_empty():
		print("FAILED triangulation!")
	else:
		print("SUCCESSFUL smooth ribbon stroke triangulation!")
	quit(0)
