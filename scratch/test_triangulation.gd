extends SceneTree

func _init():
	var c := Curve2D.new()
	c.add_point(Vector2(0, 0))
	c.add_point(Vector2(50, -50))
	c.add_point(Vector2(100, 0))
	c.add_point(Vector2(50, 50))
	# Note: Do not duplicate the first point in a closed polygon for draw_colored_polygon
	var pts := c.tessellate(4, 4.0)
	print("Tessellated pts:", pts.size())
	var indices := Geometry2D.triangulate_polygon(pts)
	print("Triangulation indices count:", indices.size())
	if indices.size() > 0:
		print("Triangulation succeeded!")
	else:
		print("Triangulation failed, let us inspect points.")
	quit(0)
