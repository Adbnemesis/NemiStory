extends SceneTree

const NemiStyleScript = preload("res://characters/nemi/NemiStyle.gd")
const NemiScript = preload("res://characters/nemi/nemi.gd")

func _init() -> void:
	print("--- Starting Nemi Rig Verification Runner ---")
	var root_viewport := root
	var scene_res := load("res://characters/nemi/test/NemiRigTest.tscn")
	var scene_inst: Node2D = scene_res.instantiate()
	root_viewport.add_child(scene_inst)
	
	# Disable auto loop so we can control frames deterministically
	scene_inst.auto_test_active = false
	var nemi: Node2D = scene_inst.get_node("Nemi")
	var status_label: Label = scene_inst.get_node("CanvasLayer/UI/StatusLabel")
	var mode_label: Label = scene_inst.get_node("CanvasLayer/UI/ModeLabel")
	
	DirAccess.make_dir_recursive_absolute("res://scratch/rig_verification")
	
	var steps: Array[Dictionary] = [
		{
			"name": "01_idle_color",
			"label": "1. Master Idle (Color)",
			"pose": "idle",
			"expr": "neutral",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO
		},
		{
			"name": "02_gaze_right_happy",
			"label": "2. Gaze Tracking Right + Happy Smile",
			"pose": "idle",
			"expr": "happy",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(0.8, -0.1)
		},
		{
			"name": "03_casual_standing_color",
			"label": "3. Casual Standing Pose (Hand towards pocket)",
			"pose": "casual_standing",
			"expr": "happy",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO
		},
		{
			"name": "04_pointing_color",
			"label": "4. Pointing Pose (Index finger, confident smile)",
			"pose": "pointing",
			"expr": "happy",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(-0.4, 0.0)
		},
		{
			"name": "05_excited_color",
			"label": "5. Excited Cheering Pose (Fist overhead, cheering)",
			"pose": "excited",
			"expr": "excited",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(0.0, -0.4)
		},
		{
			"name": "06_thinking_color",
			"label": "6. Thinking Pose (Hand at chin, ? doodle)",
			"pose": "thinking",
			"expr": "confused",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(-0.5, -0.6)
		},
		{
			"name": "07_recoiling_color",
			"label": "7. Comedic Recoil (Shocked face, action lines)",
			"pose": "recoiling",
			"expr": "shocked",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2.ZERO
		},
		{
			"name": "08_novel_pose_color",
			"label": "8. DEFINITIVE TEST: Novel Rig-Generated Pose (Color)",
			"pose": "novel_pose",
			"expr": "shocked",
			"mode": NemiStyleScript.ArtMode.COLOR,
			"gaze": Vector2(0.7, -0.2)
		},
		{
			"name": "09_novel_pose_monochrome",
			"label": "9. DEFINITIVE TEST: Novel Rig-Generated Pose (Monochrome)",
			"pose": "novel_pose",
			"expr": "shocked",
			"mode": NemiStyleScript.ArtMode.MONOCHROME,
			"gaze": Vector2(0.7, -0.2)
		},
		{
			"name": "10_casual_monochrome",
			"label": "10. Casual Standing (Finished Monochrome Ink)",
			"pose": "casual_standing",
			"expr": "happy",
			"mode": NemiStyleScript.ArtMode.MONOCHROME,
			"gaze": Vector2.ZERO
		},
	]
	
	for i in range(steps.size()):
		var step: Dictionary = steps[i]
		nemi.call("set_art_mode", step["mode"])
		nemi.call("set_pose", step["pose"], 0.0)
		nemi.call("set_expression", step["expr"])
		if "gaze" in step:
			nemi.call("look_at_direction", step["gaze"])
		
		status_label.text = step["label"]
		mode_label.text = "Art Mode: " + str(nemi.call("get_art_mode_name"))
		
		# Render frames to flush canvas drawing
		for f in range(3):
			await process_frame
		
		var img: Image = root_viewport.get_texture().get_image()
		var out_path: String = "scratch/rig_verification/" + str(step["name"]) + ".png"
		img.save_png(out_path)
		print("Saved verification capture: ", out_path)
	
	print("--- All Nemi Rig Verifications Successfully Captured! ---")
	quit(0)
