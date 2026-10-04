extends SceneTree
const Stage=preload("res://common/storytime/StorytimeStage.tscn")
const Production=preload("res://common/storytime/production/ProductionStage.tscn")
func _init() -> void:
	call_deferred("run")
func run() -> void:
	var target_res := Vector2i(1920, 1080)
	for arg in OS.get_cmdline_user_args():
		if arg == "--4k": target_res = Vector2i(3840, 2160)
		elif arg.begins_with("--resolution="):
			var parts := arg.trim_prefix("--resolution=").split("x")
			if parts.size() == 2: target_res = Vector2i(int(parts[0]), int(parts[1]))
	root.size = target_res
	var path := "res://common/storytime/examples/two_authors_10s.json"

	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="): path=arg.trim_prefix("--spec=")
	var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
	var stage=(Production if int(data.version)==2 else Stage).instantiate()
	stage.manual=true
	root.add_child(stage)
	await process_frame
	var start := 0.0
	var duration: float=stage.spec.duration
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--start="): start=float(arg.trim_prefix("--start="))
		if arg.begins_with("--duration="): duration=float(arg.trim_prefix("--duration="))
	var fps: int = stage.spec.fps
	var frames := int(round(duration*fps))
	if "--stills" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://renders/storytime_identity")
		for time in [1.2,3.7,5.8,7.8,9.8]:
			stage.sample(time)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://renders/storytime_identity/frame_%02d.png" % int(time*10))
	else:
		for frame in range(frames):
			stage.sample(start+float(frame)/fps)
			# Native occlusion can suppress automatic drawing while MovieWriter
			# still captures. Explicit drawing keeps held and background frames fresh.
			RenderingServer.force_draw.call_deferred(false,1.0/fps)
			# MovieWriter records each process frame even when a held viewport
			# does not redraw. Awaiting frame_post_draw here can freeze the clock
			# while the writer silently records thousands of duplicate frames.
			await process_frame
	print("STORYTIME COMPLETE: ", frames," authored frames")
	quit()
