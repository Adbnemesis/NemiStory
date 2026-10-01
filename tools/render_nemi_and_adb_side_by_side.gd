extends SceneTree

## Dedicated Renderer: Nemi and ADB Side-by-Side Lineup
## Compares the two characters' scale, athletic builds, silhouettes, and shared storytime animation style.

const NemiScene = preload("res://nemi/characters/nemi/nemi.tscn")
const ADBScene = preload("res://adb/characters/adb/ADB.tscn")

func _init() -> void:
	print("--- Starting Nemi and ADB Side-by-Side Renderer ---")
	var root_vp := root
	
	# Clean warm storytelling paper canvas
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.97, 0.96, 0.94, 1.0)
	root_vp.add_child(bg)
	
	# Shared grounded floor line at y = 640
	var floor_line := Line2D.new()
	floor_line.points = PackedVector2Array([Vector2(40, 640), Vector2(1240, 640)])
	floor_line.width = 2.5
	floor_line.default_color = Color(0.72, 0.68, 0.65, 0.6)
	root_vp.add_child(floor_line)
	
	# 1. Instantiate Nemi (left)
	var nemi = NemiScene.instantiate()
	nemi.name = "Nemi"
	root_vp.add_child(nemi)
	
	# 2. Instantiate ADB (right)
	var adb = ADBScene.instantiate()
	adb.name = "ADB"
	root_vp.add_child(adb)
	
	# Wait for rigs and children to initialize
	for f in range(6):
		await process_frame
		
	var out_dir := "res://adb/renders/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	
	# -------------------------------------------------------------
	# SHOT 1: FULL BODY MASTER LINEUP (1280x720)
	# Both characters grounded at floor level y = 640 with scale 1.22
	# -------------------------------------------------------------
	floor_line.visible = true
	
	# Nemi: friendly storytime idle stance
	nemi.position = Vector2(470, 400)
	nemi.scale = Vector2(1.22, 1.22)
	nemi.set_pose("idle", 0.0)
	nemi.set_expression("happy")
	if nemi.has_method("look_at_direction"):
		nemi.look_at_direction(Vector2(0.2, 0.0))
		
	# ADB: athletic relaxed stance with off-white wide-leg pants & open green shirt
	adb.position = Vector2(810, 406)
	adb.scale = Vector2(1.22, 1.22)
	adb.set_pose("relaxed_standing", 0.0)
	adb.set_expression("smug", 0.0)
	adb.look("side_eye")
	
	for f in range(8):
		await process_frame
	_save(root_vp, out_dir + "nemi_and_adb_side_by_side.png")
	
	# -------------------------------------------------------------
	# SHOT 2: MEDIUM BUST TWO-SHOT (1280x720)
	# Close-up conversation framing showcasing facial and shirt details
	# -------------------------------------------------------------
	floor_line.visible = false
	
	nemi.position = Vector2(460, 560)
	nemi.scale = Vector2(1.9, 1.9)
	nemi.set_pose("idle", 0.0)
	nemi.set_expression("happy")
	if nemi.has_method("look_at_direction"):
		nemi.look_at_direction(Vector2(0.4, -0.1))
		
	adb.position = Vector2(820, 570)
	adb.scale = Vector2(1.9, 1.9)
	adb.set_pose("pointing", 0.0)
	adb.set_expression("smug", 0.0)
	adb.look("camera")
	
	for f in range(8):
		await process_frame
	_save(root_vp, out_dir + "nemi_and_adb_two_shot_bust.png")
	
	print("--- Completed Nemi and ADB Side-by-Side Renders! ---")
	quit(0)

func _save(vp: Viewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("Successfully saved: ", path)
