extends SceneTree

func _init():
	print("--- Testing Godot 4 Built-In Geometry & Curve Tools ---")
	
	# 1. Test Curve2D tessellation
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0), Vector2(0, 0), Vector2(20, -10))
	c.add_point(Vector2(50, -30), Vector2(-15, 5), Vector2(15, -5))
	c.add_point(Vector2(100, 0), Vector2(-20, -10), Vector2(0, 0))
	var pts := c.tessellate(5, 4.0)
	print("Curve2D tessellated points count:", pts.size(), "first 3:", pts[0], pts[1], pts[2])
	
	# 2. Test Geometry2D offset_polygon
	var poly := PackedVector2Array([
		Vector2(0, 0), Vector2(40, 0), Vector2(40, 40), Vector2(0, 40)
	])
	var offset_polys := Geometry2D.offset_polygon(poly, 3.0, Geometry2D.JOIN_ROUND)
	print("Geometry2D offset_polygon count:", offset_polys.size(), "points in first:", offset_polys[0].size())
	
	# 3. Test Line2D width_curve capability
	var line := Line2D.new()
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	var wcurve := Curve.new()
	wcurve.add_point(Vector2(0.0, 0.2))
	wcurve.add_point(Vector2(0.5, 1.0))
	wcurve.add_point(Vector2(1.0, 0.1))
	line.width_curve = wcurve
	print("Line2D width_curve setup successful! Joints:", line.joint_mode)
	
	quit(0)
