extends "res://tools/storytime/ThumbnailPilot.gd"
## Original editorial illustrations using the same native static exporter.
func layout_paths() -> Array:
	var manifest_path="res://tools/storytime/thumbnail_promotional_collection.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--manifest="): manifest_path=arg.trim_prefix("--manifest=")
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var paths: Array=[]
	for item in manifest.variants: paths.append("res://"+item.layout)
	return paths
