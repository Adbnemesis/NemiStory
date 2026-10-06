extends SceneTree
const Edit = preload("res://shorts/godot/DynamicEdit.gd")
func _init() -> void: call_deferred("run")
func run() -> void:
	var path = ""
	var review = ""
	var stills = false
	var selected_frames: Array = []
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="): path = arg.trim_prefix("--spec=")
		if arg.begins_with("--review="): review = arg.trim_prefix("--review=")
		if arg == "--stills": stills = true
		if arg.begins_with("--proof-frames="):
			for value in arg.trim_prefix("--proof-frames=").split(","): selected_frames.append(int(value))
	root.size = Vector2i(1080,1920)
	root.content_scale_size = Vector2i(1080,1920)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var edit = Edit.new()
	edit.manual = true
	edit.config = JSON.parse_string(FileAccess.get_file_as_string(path))
	root.add_child(edit)
	await process_frame
	if stills:
		var frames: Array = [0,edit.config.frames-1]
		if selected_frames.is_empty():
			for shot in edit.config.shots: frames.append(mini(int(shot.frame)+7,int(edit.config.frames)-1))
		else: frames = selected_frames
		for f in frames:
			edit.sample(f)
			RenderingServer.force_draw.call_deferred(false,1.0/edit.config.fps)
			await process_frame
			root.get_texture().get_image().save_png(review+"/frame_%03d.png" % f)
	else:
		for f in range(int(edit.config.frames)):
			edit.sample(f)
			RenderingServer.force_draw.call_deferred(false,1.0/edit.config.fps)
			await process_frame
	print("INK EDIT COMPLETE: ",edit.config.frames," authored frames")
	quit()
