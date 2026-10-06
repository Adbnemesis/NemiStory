extends SceneTree
## Engine-level check: vector departure, exact wipe clock and settled endpoint.
const Edit = preload("res://shorts/godot/DynamicEdit.gd")

func _initialize() -> void:
	call_deferred("verify")

func verify() -> void:
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://shorts/nemi/my-song/short.json"))
	for kind in ["smear","whip","match","focus_wipe"]:
		var config := original.duplicate(true)
		config.shots = config.shots.slice(0,2)
		for shot in config.shots:
			shot.erase("transition")
			shot.erase("camera")
		var shot: Dictionary = config.shots[1]
		shot.erase("travel")
		shot.move = "cut"
		shot.transition = {"kind":kind,"duration":8,"event":"test-cut","direction":1,"focus":[540,800],"poseFrame":int(shot.frame)+8}
		var performer: Dictionary = config.actors[0]
		for cue in performer.cues:
			cue.bodyPose = "neutral"
			cue.action = "rest"
			cue.view = "front"
		var target: Dictionary = performer.cues[0].duplicate(true)
		target.frame = int(shot.frame)+8
		target.bodyPose = "recoil"
		var next_cues: Array = []
		for cue in performer.cues:
			if int(cue.frame) != int(target.frame):next_cues.append(cue)
		next_cues.append(target)
		next_cues.sort_custom(func(a,b):return a.frame<b.frame)
		performer.cues = next_cues
		var edit = Edit.new()
		edit.config = config
		edit.manual = true
		root.add_child(edit)
		var start := int(shot.frame)
		edit.sample(start)
		assert(edit.actors[performer.id].drawing.body_pose == "recoil")
		assert(edit.outgoing_art[performer.id].body_pose == "neutral")
		assert(edit.outgoing_canvas.visible == (kind != "match"))
		if kind == "focus_wipe":
			assert(edit.frontmarks.transition_boundary == -170)
			assert(edit.actors.values()[0].drawing.material != null)
		if kind == "whip":
			var resting_x := 540-float(shot.center[0])*float(shot.zoom)
			assert(absf(edit.canvas.position.x-resting_x-1320)<.01)
		edit.sample(start+8)
		var expected := Vector2(540,960)-Vector2(shot.center[0],shot.center[1])*float(shot.zoom)
		assert(edit.canvas.position.distance_to(expected)<.01)
		var settled: Transform2D = edit.canvas.transform
		edit.sample(start+9)
		assert(not edit.outgoing_canvas.visible)
		assert(edit.frontmarks.transition.is_empty())
		assert(edit.canvas.transform.is_equal_approx(settled))
		for id in edit.actors: assert(edit.actors[id].drawing.material == null)
		edit.queue_free()
		await process_frame
	print("TRANSITION TEST PASS: four finite devices, departing vector poses, wipe masks and held endpoints")
	quit()
