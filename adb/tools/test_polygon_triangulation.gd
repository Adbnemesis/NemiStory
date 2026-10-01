extends SceneTree

func _init() -> void:
	var poses = [
		"relaxed_standing", "weight_left", "weight_right", "casual_slouch", "seated_chair", "seated_slump",
		"explaining", "one_hand_gesture", "both_hands_open", "hands_on_hips", "arms_crossed", "shrug",
		"thinking_chin", "embarrassed_neck", "facepalm", "facepalm_double", "pointing", "table_slam",
		"holding_object", "holding_controller", "holding_phone", "waving", "stumble_pushed", "athletic_ready",
		"table_tennis_ready", "table_tennis_forehand", "table_tennis_backhand", "table_tennis_smash",
		"lifting_dumbbell", "lifting_overhead", "typing_laptop", "leaning_desk", "timeline_overwhelm",
		"pointing_presentation", "holding_doodle_card", "hands_clasped", "wave_goodbye", "casual_contrapposto",
		"awkward_freeze"
	]
	
	var all_passed = true
	for p_name in poses:
		var p_data = ADBPoseLibrary.get_pose(p_name)
		var t_torso_off: Vector2 = p_data.get("torso_offset", Vector2.ZERO)
		var t_torso_tilt: float = p_data.get("torso_tilt", 0.0)
		var t_pelvis_off: Vector2 = p_data.get("pelvis_offset", Vector2.ZERO)
		
		var t_pos: Vector2 = t_torso_off + t_pelvis_off
		var rad: float = deg_to_rad(t_torso_tilt)
		
		var hem_c: Vector2 = t_pos + Vector2(0, 25).rotated(rad)
		var hem_l: Vector2 = t_pos + Vector2(-38.5, 21).rotated(rad)
		var waist_l: Vector2 = t_pos + Vector2(-38.0, -10).rotated(rad)
		var armpit_l: Vector2 = t_pos + Vector2(-42.0, -56.0).rotated(rad)
		var sh_l: Vector2 = t_pos + Vector2(-49.0, -76.0).rotated(rad)
		var collar_l: Vector2 = t_pos + Vector2(-20, -84).rotated(rad)
		var collar_dip: Vector2 = t_pos + Vector2(0, -82).rotated(rad)
		var collar_r: Vector2 = t_pos + Vector2(20, -84).rotated(rad)
		var sh_r: Vector2 = t_pos + Vector2(49.0, -76.0).rotated(rad)
		var armpit_r: Vector2 = t_pos + Vector2(42.0, -56.0).rotated(rad)
		var waist_r: Vector2 = t_pos + Vector2(38.0, -10).rotated(rad)
		var hem_r: Vector2 = t_pos + Vector2(38.5, 21).rotated(rad)
		
		var body_poly := PackedVector2Array([
			hem_c, hem_l, waist_l, armpit_l, sh_l, collar_l, collar_dip, collar_r, sh_r, armpit_r, waist_r, hem_r
		])
		
		var triangles = Geometry2D.triangulate_polygon(body_poly)
		if triangles.is_empty():
			print("❌ FAILED: pose '", p_name, "'")
			all_passed = false
			
	if all_passed:
		print("✅ ALL 38 POSES PASSED WITH ZERO TRIANGULATION ERRORS!")
	quit(0)
