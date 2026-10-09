extends SceneTree
## Actual wrist and arm geometry after bounded phone ownership, including late poses.
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
func _init() -> void:call_deferred("run")
func run() -> void:
	var stage=Stage.instantiate();stage.manual=true;root.add_child(stage)
	await process_frame
	var actor=stage.actors.nemi.node
	var owned=stage.spec.actors[0].hand_path_window
	var times: Array=[owned[0]-.04,owned[0]+.04,owned[1]-.04,owned[1]+.04,65.5,78.5,85.5,90.5,105.5,113.5,130.5,136.5]
	for t in times:
		stage.sample(t)
		for side in ["left","right"]:
			var upper: Bone2D=actor.get(side+"_upper_arm_bone")
			var lower: Bone2D=actor.get(side+"_lower_arm_bone")
			var wrist: Bone2D=actor.get(side+"_hand_bone")
			var scale: float=actor.global_scale.x
			assert(absf(upper.global_position.distance_to(lower.global_position)/scale-lower.position.length())<.02,"Upper arm length changed")
			assert(absf(lower.global_position.distance_to(wrist.global_position)/scale-wrist.position.length())<.02,"Forearm length changed")
			if t<owned[0] or t>=owned[1]:assert(absf(wrist.rotation-wrist.get_rest().get_rotation())<.0001,"Leaked global wrist rotation after phone path")
	print("PASS: R4 wrists restore, both arm lengths preserved, ownership boundaries and second-half poses")
	stage.queue_free()
	await process_frame
	await process_frame
	quit()
