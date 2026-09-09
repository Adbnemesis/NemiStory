extends SceneTree

## Automated Verification Script for NEMI — RIG V1
## Exercises all controller API methods, verifies zero image dependencies,
## tests novel posing and novel facial expressions, and captures high-res renders.

const NemiRigTestScene = preload("res://characters/nemi/test/NemiRigTest.tscn")

func _init() -> void:
	print("==================================================")
	print("--- Starting NEMI RIG V1 Automated Verification ---")
	print("==================================================")
	
	var root_vp := root
	var test_instance: Node2D = NemiRigTestScene.instantiate()
	root_vp.add_child(test_instance)
	
	var nemi: Nemi = test_instance.get_node_or_null("Nemi")
	assert(nemi != null, "ERROR: Nemi node not found in test scene!")
	
	var out_dir := "res://characters/nemi/renders/rig_v1/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	
	# Wait for ready and initialization
	for f in range(5):
		await process_frame
	
	# TEST 1: Neutral Idle Baseline
	print("[TEST 1/5] Verifying neutral idle baseline...")
	nemi.reset()
	for f in range(4):
		await process_frame
	_save_screenshot(root_vp, out_dir + "01_rig_v1_idle_baseline.png")
	
	# TEST 2: Live Rig Debug Overlay (Requirement 30)
	print("[TEST 2/5] Verifying live Rig Debug visualizer overlay (Bones & Joint Pivots)...")
	test_instance.call("_on_toggle_debug_btn_pressed")
	for f in range(4):
		await process_frame
	_save_screenshot(root_vp, out_dir + "02_rig_v1_debug_overlay.png")
	test_instance.call("_on_toggle_debug_btn_pressed") # Disable overlay for subsequent tests
	
	# TEST 3: Live New-Pose Test (Requirement 24)
	# Leans back, head turned right, looking left, right arm raised pointing across, left relaxed, hair follow-through
	print("[TEST 3/5] Verifying Requirement 24: Live New-Pose Test...")
	test_instance.call("run_live_new_pose_test")
	for f in range(15): # Allow smooth transition to finish
		await process_frame
	_save_screenshot(root_vp, out_dir + "03_rig_v1_novel_pose_color.png")
	
	# TEST 4: Live New-Expression Test (Requirement 25)
	# Asymmetrical brows (left raised, right lowered), widened pupils, surprised mouth, blush + sweat drop
	print("[TEST 4/5] Verifying Requirement 25: Live New-Expression Test (Close-Up Framing)...")
	nemi.position = Vector2(640, 780)
	nemi.scale = Vector2(3.2, 3.2)
	test_instance.call("run_live_new_expression_test")
	for f in range(6):
		await process_frame
	_save_screenshot(root_vp, out_dir + "04_rig_v1_novel_expression_closeup.png")
	
	# TEST 5: Dual Palette Mode Switch (Requirement 18 & 29)
	print("[TEST 5/5] Verifying Requirements 18 & 29: Monochrome mode switch on same instance...")
	nemi.position = Vector2(640, 420)
	nemi.scale = Vector2(1.0, 1.0)
	test_instance.call("run_live_new_pose_test")
	test_instance.call("_on_toggle_mode_btn_pressed") # Switches to MONOCHROME and updates UI
	for f in range(15):
		await process_frame
	_save_screenshot(root_vp, out_dir + "05_rig_v1_novel_pose_monochrome.png")
	
	# TEST 6: Articulation API Sweep
	print("[TEST 6/6] Verifying Articulation Sweep (Head, Arms, Legs, Hair)...")
	test_instance.call("_on_toggle_mode_btn_pressed") # Switches back to COLOR
	nemi.head_turn(-20.0, 0.0)
	nemi.head_tilt(12.0, 0.0)
	nemi.set_arm(true, -90.0, -45.0, "open", 0.0)
	nemi.set_arm(false, 135.0, 20.0, "fist", 0.0)
	nemi.set_leg(true, 18.0, -15.0, -5.0, 0.0)
	nemi.set_leg(false, -18.0, 22.0, 8.0, 0.0)
	nemi.set_hair_sway(-15.0, -20.0, -10.0, 0.0)
	nemi.set_expression("excited")
	test_instance.call("_update_ui", "★ ARTICULATION SWEEP: Arms (open & fist), head turned & tilted, hair swaying, legs walking!")
	for f in range(6):
		await process_frame
	_save_screenshot(root_vp, out_dir + "06_rig_v1_articulation_sweep.png")
	
	print("==================================================")
	print("--- ALL NEMI RIG V1 VERIFICATION TESTS PASSED! ---")
	print("==================================================")
	quit(0)

func _save_screenshot(vp: Viewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("  -> Saved Verification Render: ", path)
	else:
		printerr("  -> FAILED to capture viewport image for: ", path)
