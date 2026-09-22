extends SceneTree

var _frames: int = 0
var _vp: SubViewport
var _leon: Node2D
var _edgar: Node2D

func _init() -> void:
	print("Setting up snapshot render...")
	_vp = SubViewport.new()
	_vp.size = Vector2i(1280, 720)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_vp)
	
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.98, 0.965, 0.94)
	_vp.add_child(bg)
	
	var leon_scene = load("res://brawl_stars/characters/leon/Leon.tscn")
	_leon = leon_scene.instantiate()
	_leon.position = Vector2(420, 520)
	_vp.add_child(_leon)
	_leon.set_expression("mischievous")
	_leon.set_pose("holding_shurikens")
	_leon.trigger_shuriken_spin(true)
	
	var edgar_scene = load("res://brawl_stars/characters/edgar/Edgar.tscn")
	_edgar = edgar_scene.instantiate()
	_edgar.position = Vector2(860, 520)
	_vp.add_child(_edgar)
	_edgar.set_expression("toxic_smug")
	_edgar.set_pose("toxic_pin")
	
	process_frame.connect(_on_process_frame)

func _on_process_frame() -> void:
	_frames += 1
	if _frames == 15:
		var img: Image = _vp.get_texture().get_image()
		if img != null:
			var err = img.save_png("/Users/talus/.gemini/antigravity-ide/brain/9beb4d8d-ab4c-4a5f-8dfc-740942ef139f/brawlers_showcase.png")
			print("Saved snapshot: ", err, " size: ", img.get_width(), "x", img.get_height())
		else:
			print("Viewport image is null")
		quit()
