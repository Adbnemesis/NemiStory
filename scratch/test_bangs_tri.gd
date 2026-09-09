extends SceneTree

func _init():
	var c := Curve2D.new()
	c.add_point(Vector2(0, -122), Vector2(-18, 0), Vector2(18, 0)) # Crown
	c.add_point(Vector2(36, -114), Vector2(-8, -8), Vector2(8, 8))
	c.add_point(Vector2(52, -85), Vector2(-4, -12), Vector2(4, 12))
	c.add_point(Vector2(48, -60), Vector2(2, -10), Vector2(-2, 10))
	c.add_point(Vector2(40, -56), Vector2(4, -4), Vector2(-4, 4))
	c.add_point(Vector2(28, -54), Vector2(4, 4), Vector2(-4, -4))
	c.add_point(Vector2(18, -68), Vector2(3, 8), Vector2(-3, 8))
	c.add_point(Vector2(9, -58), Vector2(2, -6), Vector2(-2, 6))
	c.add_point(Vector2(0, -72), Vector2(3, 8), Vector2(-3, 8))
	c.add_point(Vector2(-9, -58), Vector2(2, 6), Vector2(-2, -6))
	c.add_point(Vector2(-18, -68), Vector2(3, 8), Vector2(-3, 8))
	c.add_point(Vector2(-28, -54), Vector2(4, -4), Vector2(-4, 4))
	c.add_point(Vector2(-40, -56), Vector2(4, 4), Vector2(-4, -4))
	c.add_point(Vector2(-48, -60), Vector2(-2, 10), Vector2(2, -10))
	c.add_point(Vector2(-52, -85), Vector2(-4, 12), Vector2(4, -12))
	c.add_point(Vector2(-36, -114), Vector2(-8, 8), Vector2(8, -8))
	
	var pts := c.tessellate(5, 3.0)
	print("Tessellated points count: ", pts.size())
	var tris := Geometry2D.triangulate_polygon(pts)
	print("Triangles count: ", tris.size() / 3)
	if tris.is_empty():
		print("TRIANGULATION FAILED!")
	else:
		print("TRIANGULATION SUCCESSFUL! Clean non-self-intersecting polygon.")
	quit(0)
