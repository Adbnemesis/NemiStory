extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
var failures := 0
func _init() -> void:call_deferred("run")
func verify(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func run() -> void:
	var stage=Stage.instantiate()
	stage.manual=true
	stage.spec_path="res://adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/scene.json"
	root.add_child(stage)
	await process_frame
	var actor=stage.actors.adb.node
	var window: Array=stage.spec.actors[0].hand_path_window
	for t in [window[0]-.001,window[0],window[0]+.1,window[0]+.35,window[0]+.7,window[1]-.001,window[1],window[1]+.001]:
		stage.sample(t)
		for side in ["left","right"]:
			var actual: Vector2=actor.pelvis_offset+Vector2(-22 if side=="left" else 22,178)+Vector2(actor.get(side+"_leg_lean"),0)+actor.get(side+"_foot_offset")
			verify(actual.distance_to(stage.acting.anchors[actor.get_instance_id()][side])<.65,"Foot drift at "+str(t))
		if t>=window[0] and t<window[1]:
			verify(absf(actor.get_shoulder_pos(true).distance_to(actor.right_elbow)-58)<.02,"Upper arm length")
			verify(absf(actor.right_elbow.distance_to(actor.right_hand)-55)<.02,"Forearm length")
			for p in stage.pictures:
				if p.spec.has("attach"):
					verify(p.node.visible,"Held page not visible")
					var grip: Array=p.spec.attach.grip
					verify(p.node.to_global(Vector2(grip[0],grip[1])).distance_to(actor.right_hand_node.to_global(actor.right_hand_node.get_prop_anchor()))<.01,"Homework grip slipped")
	for shot in stage.spec.shots:
		var t: float=(shot.start+shot.end)*.5
		stage.sample(t)
		for p in stage.pictures:
			if p.node.visible and p.spec.get("mode","hold")=="hold":verify(p.node.progress==1,"Held art revealed instead of held")
		var old: Vector2=actor.right_hand
		await process_frame
		verify(old==actor.right_hand,"Autonomous acting changed a hold")
		stage.sample(stage.spec.duration-.01)
		stage.sample(t)
		if actor.visible:verify(old==actor.right_hand,"Seeking changed the visible pose")
	stage.free()
	if failures:quit(1);return
	print("PASS: new school art, every shot seeking, still holds, planted feet, both hand-path boundaries, 58/55 arm lengths and continuous page grip")
	quit()
