extends SceneTree
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const Stage = preload("res://common/storytime/StorytimeStage.tscn")
const Acting = preload("res://common/storytime/PerformancePlayer.gd")
var failures := 0
func _init() -> void:
	call_deferred("run")
func require(ok: bool, message: String) -> void:
	if not ok:
		push_error(message)
		failures+=1
func snapshot(stage: Node) -> Array:
	var result: Array = []
	for entry in stage.actors:
		var actor = entry.node
		if entry.spec.author=="nemi":
			result.append([actor.root_bone.position,actor.head_bone.rotation,actor.right_upper_arm_bone.rotation,actor.face.gaze_direction,actor.hair_left_bone.rotation])
		else:
			result.append([actor.head_tilt,actor.right_hand,actor.face.position,actor.face.rotation,actor.get("_hair_sway")])
	return result
func run() -> void:
	var a = Assets.compose("nemi","a little plan...",42)
	var b = Assets.compose("adb","a little plan...",42)
	require(a.strokes!=b.strokes,"Character lettering must differ")
	require(a==Assets.compose("nemi","a little plan...",42),"Lettering must be reproducible")
	for author in ["nemi","adb"]:
		for kind in Assets.profile(author).marks:
			var mark=Assets.mark(author,kind)
			require(not mark.stroke_list.is_empty(),"Empty authored mark")
			mark.free()
	var stage=Stage.instantiate()
	stage.manual=true
	root.add_child(stage)
	await process_frame
	for author in ["nemi","adb"]:
		var actor=stage.actors[0 if author=="nemi" else 1].node
		for recipe in Acting.recipes()[author]:
			Acting.sample(actor,author,[{"at":0,"recipe":recipe}],0.0)
	for time in [0.0,1.75,4.35,6.7,9.2]:
		stage.sample(time)
		var expected=snapshot(stage)
		stage.sample(9.9)
		stage.sample(time)
		require(expected==snapshot(stage),"Acting must seek exactly to the same state")
	stage.sample(0.0)
	for cue in stage.track.cues:
		require(not cue.drawing.visible,"Future ink visible on backward seek")
	stage.sample(3.7)
	var expected=snapshot(stage)
	await process_frame
	require(expected==snapshot(stage),"Held pose changed outside production clock")
	stage.actors[0].spec.mouths=[{"start":1.0,"end":1.3,"shape":"ae"}]
	stage.actors[1].spec.mouths=[{"start":1.0,"end":1.3,"shape":"talk_open"}]
	stage.sample(1.15)
	require(stage.actors[0].node.face.mouth_shape=="ae","Nemi mouth cue failed")
	require(stage.actors[1].node.face.mouth_state=="talk_open","ADB mouth cue failed")
	stage.sample(0.5)
	require(stage.actors[0].node.face.mouth_shape!="ae","Nemi mouth did not restore on seek")
	require(stage.actors[1].node.face.mouth_state!="talk_open","ADB mouth did not restore on seek")
	stage.free()
	if failures>0:
		quit(1)
		return
	print("PASS: distinct lettering, reproducible paths, authored marks, all 16 recipes, backward seeks, stable holds, mouth intervals")
	quit()
