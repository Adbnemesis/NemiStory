extends SceneTree
const Edit = preload("res://shorts/godot/InkEdit.gd")
func _init() -> void: call_deferred("run")
func run() -> void:
	var path = "res://shorts/godot/ink-proof/short.json"
	var stills = false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="): path = arg.trim_prefix("--spec=")
		if arg == "--stills": stills = true
	root.size = Vector2i(1080,1920)
	root.content_scale_size = Vector2i(1080,1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var edit = Edit.new()
	edit.manual = true
	edit.config = JSON.parse_string(FileAccess.get_file_as_string(path))
	root.add_child(edit)
	await process_frame
	if stills:
		for f in [0,45,60,90,140,190,215,260,310,350]:
			edit.sample(f)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://shorts/godot/ink-proof/review/frame_%03d.png" % f)
	else:
		for f in range(int(edit.config.frames)):
			edit.sample(f)
			RenderingServer.force_draw.call_deferred(false,1.0/edit.config.fps)
			await process_frame
	print("INK EDIT COMPLETE: ",edit.config.frames," authored frames")
	quit()
