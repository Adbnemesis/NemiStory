extends SceneTree

## Dedicated Renderer for the ADB Live Rig
## Renders the actual procedural Godot rig of ADB in various poses and closeups
## Output saved to res://adb/renders/rig/

const ADBCatalog = preload("res://adb/characters/adb/ADB.gd")
const ADBScene = preload("res://adb/characters/adb/ADB.tscn")

func _init() -> void:
	print("--- Starting ADB Rig Showcase Renderer ---")
	var root_vp := root
	
	# Background: Warm storytime paper canvas
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.965, 0.955, 0.935, 1.0)
	root_vp.add_child(bg)
	
	# Floor line
	var floor_line := Line2D.new()
	floor_line.points = PackedVector2Array([Vector2(60, 620), Vector2(1220, 620)])
	floor_line.width = 3.0
	floor_line.default_color = Color(0.72, 0.68, 0.65, 0.6)
	root_vp.add_child(floor_line)
	
	# ADB Instance
	var adb: ADB = ADBScene.instantiate()
	root_vp.add_child(adb)
	
	# Wait for child nodes to initialize
	for f in range(5):
		await process_frame
	
	var out_dir := "res://adb/renders/rig/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	
	# 1. Full Body Neutral Standing (1280x720 grounded on floor line)
	adb.position = Vector2(640, 375)
	adb.scale = Vector2(1.3, 1.3)
	adb.set_pose("relaxed_standing", 0.0)
	adb.set_expression("neutral", 0.0)
	adb.look("camera")
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "01_adb_rig_fullbody_neutral.png")
	
	# 2. Explaining Pose with Left Weight Shift
	adb.set_pose("weight_left", 0.0)
	adb.set_expression("happy", 0.0)
	adb.look("camera")
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "02_adb_rig_explaining_happy.png")
	
	# 3. Pointing Gesture with Smug Smirk & Side-Eye
	adb.set_pose("pointing", 0.0)
	adb.set_expression("smug", 0.0)
	adb.look("side_eye")
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "03_adb_rig_pointing_smug.png")
	
	# 4. Cute Fluster with Hand Near Neck & Cheek Blush
	adb.set_pose("embarrassed", 0.0)
	adb.set_expression("cute", 0.0)
	adb.look("camera")
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "04_adb_rig_cute_blush.png")
	
	# 5. Comedic Deadpan Freeze
	adb.set_pose("deadpan_freeze", 0.0)
	adb.set_expression("deadpan", 0.0)
	adb.look("camera")
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "05_adb_rig_deadpan_freeze.png")
	
	# 6. Upper Bust Storytime Close-up Framing
	floor_line.visible = false
	adb.position = Vector2(640, 520)
	adb.scale = Vector2(2.4, 2.4)
	adb.set_pose("pointing", 0.0)
	adb.set_expression("smug", 0.0)
	adb.look("side_eye")
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "06_adb_rig_bust_closeup.png")
	
	print("--- All ADB Rig Showcase Renders Complete! ---")
	quit(0)

func _save(vp: Viewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("Saved render: ", path)
