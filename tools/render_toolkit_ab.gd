extends SceneTree
## Toolkit A/B renderer — captures Line + Vector tests. Main-loop SceneTree script,
## so the GL Compatibility rasterizer is LIVE (unlike --headless/--script dummy).
## Run: open -a Godot --args --path . --script res://tools/render_toolkit_ab.gd
## (do NOT pass --headless; --quit-after N keeps the window open long enough).

const LineABScene = preload("res://ToolkitTests/LineQualityABTest.tscn")
const VectorScene = preload("res://ToolkitTests/VectorIllustrationTest.tscn")

func _init() -> void:
	print("--- Toolkit A/B renderer ---")
	print("Output dir: ", ProjectSettings.globalize_path("res://renders/toolkit_ab/"))
	DirAccess.make_dir_recursive_absolute("res://renders/toolkit_ab/")
	call_deferred("_run")

func _run() -> void:
	await create_timer(0.6).timeout
	var abs_dir := ProjectSettings.globalize_path("res://renders/toolkit_ab/")
	await _capture_scene(LineABScene, abs_dir, "line_ab", [1.0, 1.55, 2.5])
	await _capture_scene(VectorScene, abs_dir, "vector_ab", [1.0, 1.55, 2.5])
	print("--- A/B renders done ---")
	quit(0)

func _capture_scene(scene: PackedScene, abs_dir: String, prefix: String, zooms: Array) -> void:
	var stage: Node2D = scene.instantiate()
	root.add_child(stage)
	await create_timer(0.5).timeout
	for z in zooms:
		stage._apply_zoom(float(z))
		await create_timer(0.5).timeout
		var img: Image = root.get_texture().get_image()
		var suffix := "1x" if z <= 1.01 else ("mcu" if z <= 1.6 else "ecu")
		var path := abs_dir + "%s_%s.png" % [prefix, suffix]
		var err := img.save_png(path)
		print("Rendered: ", path, " (zoom ", z, ") err=", err, " size=", img.get_size())
	stage.queue_free()
	await create_timer(0.3).timeout
