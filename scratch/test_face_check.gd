extends SceneTree

func _init():
	var nemi_scene = load("res://characters/nemi/nemi.tscn")
	var nemi = nemi_scene.instantiate()
	root.add_child(nemi)
	
	var face_node = nemi.get_node_or_null("Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/FaceVisual")
	print("Direct path face_node: ", face_node)
	print("nemi.face: ", nemi.face)
	if face_node:
		print("face_node script: ", face_node.get_script())
		print("has set_expression_by_name? ", face_node.has_method("set_expression_by_name"))
		face_node.set_expression_by_name("happy")
		print("face expression changed successfully!")
	quit(0)
