extends SceneTree

func _init() -> void:
	print("--- Verifying Leon Character Rig ---")
	var scene_res := load("res://brawl_stars/characters/leon/Leon.tscn")
	if not scene_res:
		printerr("FAILED to load Leon.tscn")
		quit(1)
		return
	
	var leon: Node2D = scene_res.instantiate()
	root.add_child(leon)
	
	# Test all 14 expressions
	var expressions: Array[String] = [
		"neutral", "curious", "analytical", "happy", "excited",
		"confused", "surprised", "shocked", "annoyed", "worried",
		"smug", "deadpan", "screaming_panic", "con_artist_persuasive"
	]
	for expr in expressions:
		leon.call("set_expression", expr)
		print("  Tested expression: ", expr)
	
	# Test all body poses
	var poses: Array[String] = [
		"idle", "con_artist_pitch", "stealth_crouch", "panic_flail",
		"holding_shurikens", "proud_smug", "deadpan_freeze"
	]
	for p in poses:
		leon.call("set_pose", p, 0.0)
		print("  Tested pose: ", p)
	
	# Test eye tracking & visemes
	leon.call("set_gaze", Vector2(0.5, -0.3))
	leon.call("set_viseme", "talk_open")
	leon.call("toggle_art_mode")
	
	print("--- Leon Verification Completed Successfully! ---")
	quit(0)
