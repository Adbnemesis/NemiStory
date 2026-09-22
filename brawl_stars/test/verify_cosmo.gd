extends SceneTree

func _init() -> void:
	print("--- Verifying Cosmo Character Rig & Showcase ---")
	var root_viewport := root
	var scene_res := load("res://brawl_stars/scenes/CosmoShowcase.tscn")
	if not scene_res:
		printerr("FAILED to load CosmoShowcase.tscn")
		quit(1)
		return
	
	var showcase: Node2D = scene_res.instantiate()
	showcase.set("auto_play", false)
	root_viewport.add_child(showcase)
	
	DirAccess.make_dir_recursive_absolute("res://scratch/cosmo_verification")
	
	var capture_steps: Array[Dictionary] = [
		{"step": 0, "name": "cosmo_01_neutral"},
		{"step": 1, "name": "cosmo_02_curious"},
		{"step": 2, "name": "cosmo_03_analytical"},
		{"step": 3, "name": "cosmo_04_happy"},
		{"step": 7, "name": "cosmo_08_shocked"},
		{"step": 11, "name": "cosmo_12_deadpan"},
		{"step": 13, "name": "cosmo_14_realization"},
		{"step": 18, "name": "cosmo_test_a_telescope"},
		{"step": 20, "name": "cosmo_test_c_orbit_doodle"},
		{"step": 21, "name": "cosmo_test_d_gravity_pull"},
		{"step": 23, "name": "cosmo_test_f_deadpan_hold"},
		{"step": 24, "name": "cosmo_art_monochrome"}
	]
	
	for item in capture_steps:
		showcase.call("execute_step", item["step"])
		for f in range(25):
			await process_frame
		
		var img: Image = root_viewport.get_texture().get_image()
		var out_path: String = "scratch/cosmo_verification/" + item["name"] + ".png"
		img.save_png(out_path)
		print("Successfully captured: ", out_path)
	
	print("--- Cosmo Verification Completed Successfully! ---")
	quit(0)
