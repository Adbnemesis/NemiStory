extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
var failed := false
func _init() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
	if not ok:
		failed=true
		push_error(message)
func run() -> void:
	var stage=Stage.instantiate()
	stage.manual=true
	stage.spec_path="res://common/storytime/examples/story_review_48s/scene.json"
	root.add_child(stage)
	await process_frame
	var mug: Node2D
	for entry in stage.pictures:
		if entry.spec.has("attach"): mug=entry.node
	var actor=stage.actors.adb.node
	for time in [24.7,24.9,25.4,26.3,27.49]:
		stage.sample(time)
		check(mug.to_global(Vector2(35,-18)).distance_to(actor.right_hand_node.to_global(Vector2(8,6)))<.01,"Mug handle lost palm contact")
		check(absf(actor.right_shoulder.distance_to(actor.right_elbow)-58)<.01,"Upper arm stretched")
		check(absf(actor.right_elbow.distance_to(actor.right_hand)-55)<.01,"Forearm stretched")
	for time in [24.7,27.5]:
		stage.sample(time-.00001)
		var before: Transform2D=mug.global_transform
		stage.sample(time)
		check(before.origin.distance_to(mug.global_position)<.02,"Mug jumps at pickup/release")
		check(before.x.distance_to(mug.global_transform.x)<.001,"Mug rotates or scales at contact")
	for time in [1.0,6.0,12.7,17.0,22.0,25.0,30.0,35.0,40.0,45.0]:
		stage.sample(time)
		for id in stage.actors:
			var node=stage.actors[id].node
			if not node.visible: continue
			check(node.scale.x<=2,"Review shot is too tight to inspect the body")
			for side in ["left","right"]:
				var foot: Vector2
				if id=="nemi": foot=node.get(side+"_foot_bone").global_position
				else: foot=node.to_global(node.pelvis_offset+Vector2(-22 if side=="left" else 22,178)+Vector2(node.get(side+"_leg_lean"),0)+node.get(side+"_foot_offset"))
				check(foot.y<960 and foot.y>700,"Feet outside review framing")
	stage.sample(12.8)
	var hand: Vector2=actor.right_hand
	stage.acting.sample(actor,"adb",stage.actors.adb.spec.performances,12.8)
	check(hand.distance_to(actor.right_hand)<.01,"Coffee hand path leaks into other shots")
	stage.free()
	if failed: quit(1)
	else:
		print("PASS: wider review framing, both feet visible, fixed arm lengths, mug grip/contact continuity and bounded choreography")
		quit()
