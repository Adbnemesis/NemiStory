extends SceneTree

func _init() -> void:
	print("--- Verifying Episode 01: 'Ruffs' Revenge' QA Shots ---")
	var root_viewport := root
	var scene_res := load("res://brawl_stars/episodes/ep01_ruffs_revenge/Ep01RuffsRevenge.tscn")
	if not scene_res:
		printerr("FAILED to load Ep01RuffsRevenge.tscn")
		quit(1)
		return
	
	var episode: Node2D = scene_res.instantiate()
	episode.set("auto_start", false)
	root_viewport.add_child(episode)
	for f in range(5):
		await process_frame
	
	DirAccess.make_dir_recursive_absolute("res://scratch/episode_verification")
	
	var capture_shots: Array[String] = [
		"shot_01_puppy_playing",
		"shot_04_cosmo_attractor",
		"shot_09_capsule_launch",
		"shot_11_space_drift",
		"shot_14_cosmic_anomaly",
		"shot_17_adult_emergence",
		"shot_20_present_lab",
		"shot_22_ruffs_enters",
		"shot_24_desk_slam_toy",
		"shot_26_blaster_ricochet",
		"shot_29_cosmo_realizes",
		"shot_31_machine_destroyed",
		"shot_34_title_card"
	]
	
	for shot in capture_shots:
		episode.call("setup_qa_shot", shot)
		for f in range(25):
			await process_frame
		
		var img: Image = root_viewport.get_texture().get_image()
		var out_path: String = "scratch/episode_verification/" + shot + ".png"
		img.save_png(out_path)
		print("Successfully captured QA frame: ", out_path)
	
	print("--- Episode 01 Verification Completed Successfully! ---")
	quit(0)
