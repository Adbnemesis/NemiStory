extends SceneTree
## Inspect the validated shared production stage; no alternate clock/player.
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
func _init() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(1920,1080)
	var stage=Stage.instantiate()
	stage.manual=true
	root.add_child(stage)
	await process_frame
	var ep="res://nemi/episodes/ep10_my_teacher_used_to_stalk_me/"
	var rows: Array=[]
	var times: Array=[]
	for shot in stage.spec.shots:times.append((shot.start+shot.end)*.5)
	for boundary in stage.spec.actors[0].hand_path_window:
		times.append(boundary-.04)
		times.append(boundary+.04)
	for t in times:
		stage.sample(t)
		await process_frame
		RenderingServer.force_draw.call_deferred(false,1.0/30)
		await process_frame
		var image=root.get_texture().get_image()
		image.save_png(ep+"review/short_frame_%06.2f.png" % t)
		var actor=stage.actors.nemi.node
		rows.append({"time":t,"shot":stage.current_shot,"feet_world":[[actor.left_foot_bone.global_position.x,actor.left_foot_bone.global_position.y],[actor.right_foot_bone.global_position.x,actor.right_foot_bone.global_position.y]],"head_screen":[actor.face.global_position.x,actor.face.global_position.y],"foot_local_y":actor.to_local(actor.left_foot_bone.global_position).y})
	var f=FileAccess.open(ep+"review/capture_geometry.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(rows,"\t")+"\n")
	print("EP10 REVIEW CAPTURE COMPLETE")
	quit()
