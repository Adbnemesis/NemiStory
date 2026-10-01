extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
const Media=preload("res://common/storytime/production/ProductionAudio.gd")
const Base=preload("res://common/storytime/PerformancePlayer.gd")
var failures := 0
func _init() -> void: call_deferred("run")
func require(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func state(stage: Node) -> Array:
	var result: Array=[stage.current_shot,stage.caption.text]
	for id in stage.actors:
		var node=stage.actors[id].node
		if not node.visible:
			result.append([false])
			continue
		if id=="nemi": result.append([node.visible,node.root_bone.position,node.head_bone.rotation,node.face.eye_openness,node.face.gaze_direction,node.right_lower_arm_bone.rotation,node.left_foot_bone.global_position,node.right_foot_bone.global_position])
		else: result.append([node.visible,node.pelvis_offset,node.head_tilt,node.face.eye_openness_left,node.face.eye_gaze,node.right_hand,node.left_foot_offset,node.right_foot_offset])
	for entry in stage.pictures: result.append([entry.node.visible,entry.node.global_position,entry.node.global_rotation,entry.node.progress] if entry.node.visible else [false])
	for entry in stage.effects: result.append([entry.node.visible,entry.node.global_position,entry.node.phase] if entry.node.visible else [false])
	return result
func check_feet(stage: Node,author: String) -> void:
	var node=stage.actors[author].node
	for side in ["left","right"]:
		var actual: Vector2
		if author=="nemi": actual=node.to_local(node.get(side+"_foot_bone").global_position)
		else: actual=node.pelvis_offset+Vector2(-22 if side=="left" else 22,178)+Vector2(node.get(side+"_leg_lean"),0)+node.get(side+"_foot_offset")
		var expected: Vector2=stage.acting.anchors[node.get_instance_id()][side]
		require(actual.distance_to(expected)<0.65,"Planted foot drift: %s %s %s -> %s" % [author,side,expected,actual])
func run() -> void:
	var stage=Stage.instantiate()
	stage.manual=true
	root.add_child(stage)
	await process_frame
	require(Media.read(stage.spec.audio)!=null,"Narration did not load directly")
	for sound in stage.spec.sfx:
		require(Media.read(sound.file)!=null,"Sound did not load directly")
	for author in ["nemi","adb"]:
		var node=stage.actors[author].node
		for recipe in Base.recipes()[author]:
			for time in [1.12,1.3,1.55,2.0]:
				stage.acting.sample(node,author,[{"at":0,"recipe":"listening"},{"at":1,"recipe":recipe}],time)
				check_feet(stage,author)
	for time in [0.0,.5,1.2,2.78,4.2,5.7,6.25,6.6,7.8,9.5]:
		stage.sample(time)
		var expected=state(stage)
		stage.sample(9.9)
		stage.sample(time)
		require(expected==state(stage),"Non-deterministic shot state at "+str(time))
	stage.sample(5.8)
	for entry in stage.pictures:
		if entry.spec.has("attach"):
			var actor=stage.actors[entry.spec.attach.actor].node
			var grip: Array=entry.spec.attach.grip
			require(entry.node.to_global(Vector2(grip[0],grip[1])).distance_to(actor.right_hand_node.to_global(actor.right_hand_node.get_prop_anchor()))<.01,"Prop grip lost contact")
	stage.sample(9.5)
	var held=state(stage)
	await process_frame
	require(held==state(stage),"Hold changed without clock advancing")
	stage.sample(6.4)
	var live_count := 0
	var held_count := 0
	for entry in stage.pictures:
		if entry.node.visible:
			if entry.spec.get("mode","hold")=="hold":
				held_count+=1
				require(entry.node.progress==1.0,"Held drawing is revealing")
			elif entry.node.progress>0 and entry.node.progress<1: live_count+=1
	require(held_count>0 and live_count>0,"Need mixed held/live art on correction beat")
	stage.free()
	if failures:
		quit(1)
		return
	print("PASS: 28 recipes, planted feet, seeking across cuts, prop grip, stable hold, mixed held/live artwork")
	quit()
