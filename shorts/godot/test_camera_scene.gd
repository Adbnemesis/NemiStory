extends SceneTree
## Real controller checks: destination easing, held endpoints and outgoing continuity.
const Edit = preload("res://shorts/godot/DynamicEdit.gd")

func _initialize() -> void:call_deferred("verify")

func clean_config() -> Dictionary:
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://shorts/nemi/my-song/short.json"))
	config = config.duplicate(true)
	config.shots = config.shots.slice(0,2)
	for shot in config.shots:
		shot.erase("camera")
		shot.erase("travel")
		shot.erase("transition")
		shot.move = "cut"
	return config

func spawn(config: Dictionary) -> Node2D:
	var edit = Edit.new()
	edit.manual = true
	edit.config = config
	root.add_child(edit)
	return edit

func verify() -> void:
	# Existing move/travel paths have exactly the same matrix without camera keys.
	for move in ["cut","punch","pull","whip"]:
		var config := clean_config()
		config.shots[0].move = move
		config.shots[0].angle = 2
		config.shots[0].direction = -1
		config.shots[0].travel = {"pan":[12,-5],"zoom":1.02,"end":16}
		var edit = spawn(config)
		for frame in [0,1,4,12,20]:
			edit.sample(frame)
			assert(edit.canvas.transform.is_equal_approx(edit.base_transform_at(config.shots[0],frame)))
			assert(edit.marks.stage_transform.is_equal_approx(Transform2D.IDENTITY))
		edit.queue_free()
		await process_frame
	var config := clean_config()
	config.shots[0].stage = "door"
	config.shots[0].camera = {"focus":[540,650],"keys":[
		{"frame":0,"factor":1.0,"pan":[0,0],"roll":0,"ease":"linear"},
		{"frame":8,"factor":1.08,"pan":[40,-10],"roll":2,"ease":"out"},
		{"frame":14,"factor":1.04,"pan":[20,-5],"roll":1,"ease":"smooth"}]}
	config.shots[1].transition = {"kind":"whip","duration":8,"event":"test-departure","direction":1}
	var edit = spawn(config)
	edit.sample(4)
	var delta: Transform2D = edit.camera_delta_at(config.shots[0],4)
	assert(absf(delta.x.length()-1.07)<.0001)
	assert((delta*Vector2(540,650)).distance_to(Vector2(575,641.25))<.001)
	assert(edit.marks.stage_transform.is_equal_approx(delta))
	assert(edit.label.position == Vector2(110,1490))
	var caption_position: Vector2 = edit.label.global_position
	edit.sample(14)
	var held: Transform2D = edit.canvas.transform
	edit.sample(20)
	assert(edit.canvas.transform.is_equal_approx(held))
	assert(edit.label.global_position == caption_position)
	config.shots[0].stage = "viewfinder"
	edit.sample(4)
	assert(edit.marks.stage_transform.is_equal_approx(Transform2D.IDENTITY))
	var cut := int(config.shots[1].frame)
	edit.sample(cut-1)
	var departure: Transform2D = edit.canvas.transform
	edit.sample(cut)
	assert(edit.outgoing_canvas.transform.is_equal_approx(departure))
	assert(edit.marks.stage_transform.is_equal_approx(Transform2D.IDENTITY))
	edit.queue_free()
	await process_frame
	print("CAMERA TEST PASS: old defaults, destination easing, held endpoints, stage scope, fixed caption and actual outgoing camera continuity")
	quit()
