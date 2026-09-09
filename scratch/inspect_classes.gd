extends SceneTree

func _init():
	print("--- Inspecting Godot 4 2D Tools & Classes ---")
	var class_list = ClassDB.get_class_list()
	var keywords = ["2D", "Polygon", "Line", "Curve", "Bone", "Skeleton", "Path", "Mesh", "Geometry"]
	var matched = []
	for c in class_list:
		for k in keywords:
			if k in c and not c in matched:
				matched.append(c)
				break
	matched.sort()
	for m in matched:
		var parent = ClassDB.get_parent_class(m)
		print(m, " (extends ", parent, ")")
	quit(0)
