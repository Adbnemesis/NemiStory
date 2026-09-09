extends SceneTree

## Dedicated Renderer for the User-Requested Pose:
## "Make Nemi lean backward, turn her head right, look left with her eyes,
## raise her right arm, bend her elbow, point, and look shocked."

const NemiScene = preload("res://characters/nemi/nemi.tscn")

func _init() -> void:
	print("--- Rendering Requested Shocked Pointing Pose ---")
	var root_vp := root
	
	# Background
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color("#faf7f5")
	root_vp.add_child(bg)
	
	# Floor line
	var floor_line := Line2D.new()
	floor_line.points = PackedVector2Array([Vector2(60, 640), Vector2(1220, 640)])
	floor_line.width = 2.0
	floor_line.default_color = Color(0.24, 0.03, 0.12, 0.35)
	root_vp.add_child(floor_line)
	
	# Nemi Instance
	var nemi: Nemi = NemiScene.instantiate()
	root_vp.add_child(nemi)
	
	# Wait for child nodes to initialize and run _ready()
	for f in range(5):
		await process_frame
	
	# Output directory
	var out_dir := "res://characters/nemi/renders/custom/"
	DirAccess.make_dir_recursive_absolute(out_dir)
	
	# 1. Full Body Color
	floor_line.visible = true
	nemi.position = Vector2(640, 420)
	nemi.scale = Vector2(1.15, 1.15)
	nemi.set_art_mode(NemiStyle.ArtMode.COLOR)
	nemi.set_pose("shocked_pointing", 0.0)
	nemi.set_micro_accent("sweat", true)
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "nemi_shocked_pointing_fullbody_color.png")
	
	# 2. Medium Bust Storytime Framing Color
	floor_line.visible = false
	nemi.position = Vector2(640, 560)
	nemi.scale = Vector2(1.9, 1.9)
	nemi.set_pose("shocked_pointing", 0.0)
	nemi.set_micro_accent("sweat", true)
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "nemi_shocked_pointing_bust_color.png")
	
	# 3. Facial Close-Up Color
	nemi.position = Vector2(640, 800)
	nemi.scale = Vector2(3.2, 3.2)
	nemi.set_pose("shocked_pointing", 0.0)
	nemi.set_micro_accent("sweat", true)
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "nemi_shocked_pointing_face_closeup.png")
	
	# 4. Full Body Finished Monochrome Mode
	floor_line.visible = true
	nemi.position = Vector2(640, 420)
	nemi.scale = Vector2(1.15, 1.15)
	nemi.set_art_mode(NemiStyle.ArtMode.MONOCHROME)
	nemi.set_pose("shocked_pointing", 0.0)
	for f in range(6):
		await process_frame
	_save(root_vp, out_dir + "nemi_shocked_pointing_fullbody_monochrome.png")
	
	print("--- All Renders Completed Successfully! ---")
	quit(0)

func _save(vp: Viewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("Saved render: ", path)
