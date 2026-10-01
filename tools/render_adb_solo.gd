extends SceneTree

## Dedicated Solo Renderer for ADB
## Produces crisp, presentation-ready solo renders of ADB in storytime poses.

const ADBScene = preload("res://adb/characters/adb/ADB.tscn")

func _init() -> void:
	print("--- Starting Dedicated ADB Solo Renderer ---")
	var root_vp := root
	
	# Clean warm storytelling paper canvas
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.97, 0.96, 0.94, 1.0)
	root_vp.add_child(bg)
	
	# Floor grounding line
	var floor_line := Line2D.new()
	floor_line.points = PackedVector2Array([Vector2(60, 630), Vector2(1220, 630)])
	floor_line.width = 2.8
	floor_line.default_color = Color(0.72, 0.68, 0.65, 0.6)
	root_vp.add_child(floor_line)
	
	# ADB Instance
	var adb: ADB = ADBScene.instantiate()
	adb.name = "ADB"
	root_vp.add_child(adb)
	
	for f in range(6):
		await process_frame
		
	var out_dir := "res://adb/renders/solo/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	
	# -----------------------------------------------------------------
	# 1. FULL BODY SIGNATURE HERO SHOT (1280x720)
	# Relaxed standing, signature charming smirk, grounded floor
	# -----------------------------------------------------------------
	floor_line.visible = true
	adb.position = Vector2(640, 385)
	adb.scale = Vector2(1.3, 1.3)
	adb.set_pose("relaxed_standing", 0.0)
	adb.set_expression("smug", 0.0)
	adb.look("side_eye")
	
	for f in range(8):
		await process_frame
	_save(root_vp, out_dir + "adb_solo_fullbody_hero.png")
	
	# -----------------------------------------------------------------
	# 2. STORYTIME EXPLAINING / GESTURE SHOT (1280x720)
	# Confident weight shift with expressive hand gesture
	# -----------------------------------------------------------------
	floor_line.visible = true
	adb.position = Vector2(640, 385)
	adb.scale = Vector2(1.3, 1.3)
	adb.set_pose("weight_left", 0.0)
	adb.set_expression("happy", 0.0)
	adb.look("camera")
	
	for f in range(8):
		await process_frame
	_save(root_vp, out_dir + "adb_solo_explaining.png")
	
	# -----------------------------------------------------------------
	# 3. MEDIUM BUST CLOSEUP (1280x720)
	# Cinematic framing showing facial features, open collar, rolled cuffs
	# -----------------------------------------------------------------
	floor_line.visible = false
	adb.position = Vector2(640, 545)
	adb.scale = Vector2(2.1, 2.1)
	adb.set_pose("relaxed_standing", 0.0)
	adb.set_expression("smug", 0.0)
	adb.look("camera")
	
	for f in range(8):
		await process_frame
	_save(root_vp, out_dir + "adb_solo_bust_portrait.png")
	
	print("--- Completed All Dedicated ADB Solo Renders! ---")
	quit(0)

func _save(vp: Viewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("Successfully saved: ", path)
