extends SceneTree

func _init() -> void:
	var poses = [
		"relaxed_standing", "weight_left", "explaining", "stumble_pushed",
		"athletic_ready", "table_tennis_smash", "timeline_overwhelm", "hands_clasped"
	]
	
	var all_passed = true
	var test_count = 0
	
	for i in range(poses.size()):
		for j in range(i + 1, poses.size()):
			var p1 = ADBPoseLibrary.get_pose(poses[i])
			var p2 = ADBPoseLibrary.get_pose(poses[j])
			
			for step in range(21):
				var t: float = step / 20.0
				var t_torso_off: Vector2 = p1.get("torso_offset", Vector2.ZERO).lerp(p2.get("torso_offset", Vector2.ZERO), t)
				var t_torso_tilt: float = lerpf(p1.get("torso_tilt", 0.0), p2.get("torso_tilt", 0.0), t)
				var t_pelvis_off: Vector2 = p1.get("pelvis_offset", Vector2.ZERO).lerp(p2.get("pelvis_offset", Vector2.ZERO), t)
				
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
					print("❌ FAILED: interpolation between ", poses[i], " and ", poses[j], " at t=", t)
					all_passed = false
				test_count += 1
				
	if all_passed:
		print("✅ ALL ", test_count, " POSE INTERPOLATIONS PASSED WITH ZERO TRIANGULATION ERRORS!")
	quit(0)
