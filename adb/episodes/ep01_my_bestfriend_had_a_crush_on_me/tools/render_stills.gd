extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
func _init() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(1920,1080)
	var stage=Stage.instantiate()
	stage.manual=true
	stage.spec_path="res://adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/scene.json"
	root.add_child(stage)
	await process_frame
	var dir="res://renders/adb_school_crush/stills_r4"
	DirAccess.make_dir_recursive_absolute(dir)
	for shot in stage.spec.shots:
		var time: float=(shot.start+shot.end)*0.5
		stage.sample(time)
		RenderingServer.force_draw.call_deferred(false,1.0/30)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(dir+"/"+shot.id+".png")
		print("STILL ",shot.id," at ",time)
	print("PASS: sampled every shot through shared ProductionStage")
	quit()
