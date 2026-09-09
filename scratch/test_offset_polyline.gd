extends SceneTree

func _init():
	print("--- Testing Geometry2D.offset_polyline ---")
	var path := PackedVector2Array([
		Vector2(0, 0), Vector2(20, -30), Vector2(35, -50)
	])
	var polys := Geometry2D.offset_polyline(path, 6.0, Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	print("Generated polys count:", polys.size())
	if polys.size() > 0:
		var indices := Geometry2D.triangulate_polygon(polys[0])
		print("Polys[0] points:", polys[0].size(), "triangulation indices:", indices.size())
	quit(0)
