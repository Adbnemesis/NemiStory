extends SceneTree
const Stage=preload("res://common/storytime/StorytimeStage.tscn")
const Production=preload("res://common/storytime/production/ProductionStage.tscn")
func _init() -> void:
	call_deferred("run")
func run() -> void:
	root.size=Vector2i(1920,1080)
	var path := "res://common/storytime/examples/two_authors_10s.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="): path=arg.trim_prefix("--spec=")
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
	var stage=(Production if int(data.version)==2 else Stage).instantiate()
	stage.manual=true
	root.add_child(stage)
	await process_frame
	var fps: int = stage.spec.fps
	var frames := int(round(float(stage.spec.duration)*fps))
	if "--stills" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://renders/storytime_identity")
		for time in [1.2,3.7,5.8,7.8,9.8]:
			stage.sample(time)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://renders/storytime_identity/frame_%02d.png" % int(time*10))
	else:
		for frame in range(frames):
			stage.sample(float(frame)/fps)
			await RenderingServer.frame_post_draw
	print("STORYTIME COMPLETE: ", frames," authored frames")
	quit()
