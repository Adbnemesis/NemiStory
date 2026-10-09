extends SceneTree
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
func _init() -> void:call_deferred("run")
func run() -> void:
	root.size=Vector2i(1920,1080)
	var stage=Stage.instantiate();stage.manual=true;root.add_child(stage)
	await process_frame
	var folder="res://nemi/episodes/ep10_my_teacher_used_to_stalk_me/review/r4/"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--review-folder="):folder=arg.trim_prefix("--review-folder=")
	DirAccess.make_dir_recursive_absolute(folder)
	var times: Array=[.9,2.7,4.6,6.7,9.7,13.6,17.4,20.9,25.9,28.5,30.4,32.5,35.2,37.7,40.5,42.5,43.51,43.59,46.7,49.8,54.95,58.9,63.7,67.9,70.6,74.3,76.7,78.5,82.4,85.5,88.9,90.5,92.7,97.8,101.9,105.5,107.0,108.8,114.3,119.3,122.9,125.1,129.0,133.0,136.6]
	for t in times:
		stage.sample(t)
		await process_frame
		RenderingServer.force_draw.call_deferred(false,1.0/30)
		await process_frame
		root.get_texture().get_image().save_png(folder+"frame_%06.2f.png" % t)
	print("R4 CAPTURE COMPLETE: ",times.size()," actual 1080p review frames")
	quit()
