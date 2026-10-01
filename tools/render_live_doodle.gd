extends SceneTree
const Scene = preload("res://tools/LiveDoodleShowcase.tscn")
func _init() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1920,1080)
	var stage = Scene.instantiate()
	stage.manual=true
	root.add_child(stage)
	await process_frame
	DirAccess.make_dir_recursive_absolute("res://renders/live_doodle")
	if "--movie" in OS.get_cmdline_user_args():
		# Drive authored time from frame number, never wall time or accumulated
		# delta. Export stays identical even when a frame takes longer to draw.
		for frame in range(871):
			stage.sample(float(frame)/30.0)
			await RenderingServer.frame_post_draw
		print("LIVE DOODLE MOVIE: all 871 authored frames completed")
	else:
		var times := [0.9,2.7,4.3,6.9,8.9,14.5,19.5,24.8,28.6]
		for i in range(times.size()):
			stage.sample(times[i])
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://renders/live_doodle/proof_%02d.png" % i)
		print("LIVE DOODLE FRAMES SAVED")
	quit()
