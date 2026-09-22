extends SceneTree

func _init() -> void:
	print("--- Verifying Edgar Character Rig ---")
	var scene_res := load("res://brawl_stars/characters/edgar/Edgar.tscn")
	if not scene_res:
		printerr("FAILED to load Edgar.tscn")
		quit(1)
		return
	
	var edgar: Node2D = scene_res.instantiate()
	root.add_child(edgar)
	
	# Test all 14 expressions
	var expressions: Array[String] = [
		"neutral", "curious", "analytical", "happy", "excited",
		"confused", "surprised", "shocked", "annoyed", "worried",
		"smug", "deadpan", "explosive_shout", "emo_despair"
	]
	for expr in expressions:
		edgar.call("set_expression", expr)
		print("  Tested expression: ", expr)
	
	# Test all body poses & scarf actions
	var poses: Array[String] = [
		"idle_slouch", "arms_crossed", "phone_scroll", "toxic_thumbs_down",
		"punch_ready", "shrug", "deadpan_freeze"
	]
	for p in poses:
		edgar.call("set_pose", p, 0.0)
		print("  Tested pose: ", p)
	
	# Test eye tracking & visemes
	edgar.call("set_gaze", Vector2(-0.4, 0.2))
	edgar.call("set_viseme", "talk_open")
	edgar.call("toggle_art_mode")
	
	print("--- Edgar Verification Completed Successfully! ---")
	quit(0)
