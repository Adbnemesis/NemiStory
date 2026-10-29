extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
const Hands=preload("res://common/storytime/production/HandPaths.gd")
var failures := 0
func _init() -> void: call_deferred("run")
func require(ok: bool, message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func snapshot(stage: Node) -> Array:
	var values: Array=[stage.current_shot,stage.world.position,stage.world.scale,stage.caption.text]
	for id in stage.actors:
		var actor=stage.actors[id].node
		values.append([true,actor.face.global_transform] if actor.visible else [false])
	for entry in stage.pictures: values.append([true,entry.node.global_transform,entry.node.progress] if entry.node.visible else [false])
	return values
func run() -> void:
	var stage=Stage.instantiate()
	stage.manual=true
	stage.spec_path="res://common/storytime/examples/refinement_10s/scene.json"
	root.add_child(stage)
	await process_frame
	require(stage.caption.z_index>10,"Captions can be obscured by production art or actors")
	var phone: Node2D
	for entry in stage.pictures:
		if entry.spec.kind=="phone": phone=entry.node
	for time in [0.2,2.5,3.8,4.799,4.8,5.7,6.19,7.6,7.799,7.8,9.4]:
		stage.sample(time)
		var expected=snapshot(stage)
		stage.sample(9.9)
		stage.sample(time)
		require(expected==snapshot(stage),"Refinement seek mismatch at "+str(time))
	stage.sample(4.79999)
	var before := phone.global_transform
	stage.sample(4.8)
	require(before.origin.distance_to(phone.global_position)<.01 and before.get_scale().distance_to(phone.global_scale)<.001,"Pickup teleported/resized phone")
	stage.sample(5.7)
	var actor=stage.actors.adb.node
	require(phone.to_global(Vector2(0,25)).distance_to(actor.right_hand_node.global_position)<.01,"Held phone lost palm contact")
	stage.sample(7.79999)
	before=phone.global_transform
	stage.sample(7.8)
	require(before.origin.distance_to(phone.global_position)<.01 and before.get_scale().distance_to(phone.global_scale)<.001,"Put-down teleported/resized phone")
	stage.sample(6.16)
	var head: float=actor.head_tilt
	stage.sample(6.19)
	require(is_equal_approx(head,actor.head_tilt),"Stepped thought changed between authored samples")
	stage.sample(7.6001)
	head=actor.head_tilt
	stage.sample(7.65)
	require(is_equal_approx(head,actor.head_tilt),"Snap reaction kept interpolating")
	var nemi=stage.actors.nemi.node
	# A reach must preserve anatomy, not merely put the prop on its target.
	for side in ["left","right"]:
		for target in [Vector2(75,30),Vector2(105,-10),Vector2(123,-58)]:
			stage.sample(5.7)
			if side=="left": target.x=-target.x
			Hands.sample(actor,"adb",{side:[{"at":0,"position":[target.x,target.y]}]},5.7)
			var shoulder: Vector2=actor.get_shoulder_pos(side=="right")
			var elbow: Vector2=actor.get(side+"_elbow")
			var hand: Vector2=actor.get(side+"_hand")
			require(absf(shoulder.distance_to(elbow)-58.0)<.01 and absf(elbow.distance_to(hand)-55.0)<.01,"ADB arm length changes during reach")
			require(is_equal_approx(actor.get(side+"_hand_node").rotation,(hand-elbow).angle()-PI*.5),"Unspecified wrist does not follow forearm")
	stage.sample(1)
	Hands.sample(nemi,"nemi",{"right":[{"at":0,"position":[85,-45],"angle":-5}]},1)
	require(nemi.to_local(nemi.right_hand_bone.global_position).distance_to(Vector2(85,-45))<.05,"Nemi external hand IK misses target")
	stage.free()
	if failures: quit(1)
	else:
		print("PASS: new camera paths, deterministic seeks, stepped/snap thoughts, Nemi hand IK, pickup/put-down continuity and palm contact")
		quit()
