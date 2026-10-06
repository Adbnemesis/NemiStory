extends "res://tools/storytime/ThumbnailPilot.gd"
## Original editorial illustrations using the same native static exporter.
func layout_paths() -> Array:
	var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://tools/storytime/thumbnail_promotional_2026-10-06.json"))
	var paths: Array=[]
	for item in manifest.variants: paths.append("res://"+item.layout)
	return paths
