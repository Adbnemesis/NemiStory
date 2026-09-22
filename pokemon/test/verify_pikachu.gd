extends SceneTree

const PikachuScript = preload("res://pokemon/characters/pikachu/Pikachu.gd")

func _init() -> void:
	print("--- Verifying Pikachu Rig & Expressions ---")
	var root_viewport := root
	var scene_res := load("res://pokemon/characters/pikachu/Pikachu.tscn")
	if not scene_res:
		printerr("FAILED to load Pikachu.tscn")
		quit(1)
		return
	
	var pika: Node2D = scene_res.instantiate()
	root_viewport.add_child(pika)
	pika.position = Vector2(640, 450)
	pika.scale = Vector2(3.0, 3.0) # Scaled up for crystal clear QA
	
	DirAccess.make_dir_recursive_absolute("res://scratch/pokemon_verification")
	
	var expressions := [
		"neutral", "happy", "curious", "confused", "surprised",
		"shocked", "annoyed", "excited", "sad", "deadpan",
		"angry", "frustrated", "scared", "suspicious", "smug",
		"exhausted", "relieved", "nervous", "determined", "embarrassed"
	]
	
	for expr in expressions:
		pika.call("set_expression", expr)
		if expr == "curious":
			pika.call("set_pose", "curious_tilt", 0.0)
		elif expr == "excited":
			pika.call("set_pose", "cheering", 0.0)
		elif expr == "shocked":
			pika.call("set_pose", "shock_recoil", 0.0)
		else:
			pika.call("set_pose", "idle", 0.0)
		
		# Flush frames
		for f in range(3):
			await process_frame
		
		var img: Image = root_viewport.get_texture().get_image()
		var out_path: String = "scratch/pokemon_verification/pikachu_" + expr + ".png"
		img.save_png(out_path)
		print("Successfully captured: ", out_path)
	
	print("--- Pikachu Verification Suite Completed! ---")
	quit(0)
