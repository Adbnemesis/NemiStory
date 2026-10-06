extends SceneTree
## Read-only headless director test. No production spec or movie is changed.
const Edit = preload("res://shorts/godot/DynamicEdit.gd")
const Art = preload("res://shorts/godot/DynamicPoseArt.gd")
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
	var art = Art.new()
	assert(art.page_art == "cat")
	art.free()
	var original: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://shorts/nemi/my-song/short.json"))
	for kind in ["smear","whip","match","focus_wipe"]:
		var config := original.duplicate(true)
		config.shots = config.shots.slice(0,2)
		for shot in config.shots: shot.erase("transition")
		var shot: Dictionary = config.shots[1]
		shot.erase("travel")
		shot.move = "cut"
		var start := int(shot.frame)
		shot.transition = {"kind":kind,"duration":8,"event":"test-page","direction":1,"focus":[540,800],"poseFrame":start+8}
		var performer: Dictionary = config.actors[0]
		var before: Dictionary = performer.cues[0].duplicate(true)
		before.frame=0;before.bodyPose="neutral";before.action="sketch";before.view="front";before.pageArt="moon"
		var after := before.duplicate(true)
		after.frame=start+8;after.pageArt="cat"
		var blank := after.duplicate(true)
		blank.frame=start+10;blank.pageArt="blank"
		var default := after.duplicate(true)
		default.frame=start+12;default.erase("pageArt")
		performer.cues=[before,after,blank,default]
		var edit = Edit.new();edit.config=config;edit.manual=true;root.add_child(edit)
		edit.sample(0)
		assert(edit.actors[performer.id].drawing.page_art == "moon")
		edit.sample(start)
		assert(edit.actors[performer.id].drawing.page_art == "cat")
		assert(edit.outgoing_art[performer.id].page_art == "moon")
		edit.sample(start+8)
		assert(edit.actors[performer.id].drawing.page_art == "cat")
		edit.sample(start+10)
		assert(edit.actors[performer.id].drawing.page_art == "blank")
		edit.sample(start+12)
		assert(edit.actors[performer.id].drawing.page_art == "cat")
		edit.queue_free();await process_frame
	print("PAGE ART TEST PASS: default cat, three selections and incoming/outgoing ownership for four devices")
	quit()
