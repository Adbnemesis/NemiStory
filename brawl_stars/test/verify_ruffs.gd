extends SceneTree

func _init() -> void:
	print("--- Verifying Colonel Ruffs Character Rig & Showcase ---")
	var root_viewport := root
	var scene_res := load("res://brawl_stars/scenes/RuffsShowcase.tscn")
	if not scene_res:
		printerr("FAILED to load RuffsShowcase.tscn")
		quit(1)
		return
	
	var showcase: Node2D = scene_res.instantiate()
	showcase.set("auto_play", false)
	root_viewport.add_child(showcase)
	
	DirAccess.make_dir_recursive_absolute("res://scratch/ruffs_verification")
	
	var capture_steps: Array[Dictionary] = [
		{"step": 0, "name": "ruffs_01_neutral"},
		{"step": 1, "name": "ruffs_02_curious"},
		{"step": 2, "name": "ruffs_03_analytical"},
		{"step": 3, "name": "ruffs_04_happy"},
		{"step": 4, "name": "ruffs_05_excited_panting"},
		{"step": 7, "name": "ruffs_08_shocked"},
		{"step": 8, "name": "ruffs_09_annoyed_growl"},
		{"step": 11, "name": "ruffs_12_deadpan"},
		{"step": 12, "name": "ruffs_13_disciplined"},
		{"step": 13, "name": "ruffs_14_mission_accomplished"},
		{"step": 18, "name": "ruffs_test_a_salute"},
		{"step": 19, "name": "ruffs_test_b_ricochet"},
		{"step": 20, "name": "ruffs_test_c_supply_drop"},
		{"step": 21, "name": "ruffs_test_d_briefing"},
		{"step": 22, "name": "ruffs_test_e_canine_instinct"},
		{"step": 23, "name": "ruffs_test_f_deadpan_hold"},
		{"step": 24, "name": "ruffs_art_monochrome"}
	]
	
	for item in capture_steps:
		showcase.call("execute_step", item["step"])
		for f in range(25):
			await process_frame
		
		var img: Image = root_viewport.get_texture().get_image()
		var out_path: String = "scratch/ruffs_verification/" + item["name"] + ".png"
		img.save_png(out_path)
		print("Successfully captured: ", out_path)
	
	print("--- Ruffs Verification Completed Successfully! ---")
	quit(0)
