extends SceneTree

## Dedicated SceneTree Runner for Headless Carousel Slide Generation
## Renders crisp 1080x1350 native PNG slides directly through Metal 4.0.

const StageScene = preload("res://carousel/scenes/CarouselSlideStage.tscn")
const CarouselSlideStage = preload("res://carousel/common/scripts/CarouselSlideStage.gd")

func _init() -> void:
	print("--- Starting Antigravity Carousel Headless Renderer ---")
	
	var manifest_path := _parse_manifest_arg()
	if manifest_path.is_empty():
		push_error("ERROR: No --manifest path provided to CarouselRenderRunner.gd!")
		quit(1)
		return
		
	print("Loading Manifest: ", manifest_path)
	if not FileAccess.file_exists(manifest_path):
		push_error("ERROR: Manifest file does not exist at: " + manifest_path)
		quit(1)
		return
		
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	var json_str := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var err := json.parse(json_str)
	if err != OK:
		push_error("ERROR: Failed to parse JSON manifest! Error: " + json.get_error_message())
		quit(1)
		return
		
	var manifest: Dictionary = json.data
	var brand: String = manifest.get("brand", "nemi")
	var slides: Array = manifest.get("slides", [])
	var out_dir := manifest_path.get_base_dir() + "/"
	
	var root_vp := root
	var sub_vp := SubViewport.new()
	sub_vp.size = Vector2i(1080, 1350)
	sub_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_vp.transparent_bg = false
	root_vp.add_child(sub_vp)
	
	var stage: CarouselSlideStage = StageScene.instantiate()
	sub_vp.add_child(stage)
	
	print("Found %d slides to render. Target directory: %s" % [slides.size(), out_dir])
	
	for idx in range(slides.size()):
		var s_data: Dictionary = slides[idx]
		var s_num: int = idx + 1
		stage.setup_slide(brand, s_data, s_num, slides.size())
		
		# Allow engine to process layout, font tessellations, and GPU draw calls
		for f in range(6):
			await process_frame
			
		var img: Image = sub_vp.get_texture().get_image()
		if img:
			var slide_filename := "%02d.png" % s_num
			var save_path := out_dir + slide_filename
			img.save_png(save_path)
			print("✓ Rendered slide %02d/%02d -> %s" % [s_num, slides.size(), slide_filename])
		else:
			push_error("ERROR: Failed to grab viewport texture for slide %d" % s_num)
			
	print("--- All Carousel Slides Successfully Rendered! ---")
	quit(0)

func _parse_manifest_arg() -> String:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()
		
	for i in range(args.size()):
		if args[i] == "--manifest" and i + 1 < args.size():
			return args[i + 1]
		elif args[i].begins_with("--manifest="):
			return args[i].substr("--manifest=".length())
	return ""
