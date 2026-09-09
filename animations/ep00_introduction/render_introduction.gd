extends SceneTree

## Standalone CLI Render Runner for Nemi Debut Introduction Video
## Runs res://animations/ep00_introduction/introduction_scene.tscn and orchestrates movie capture.

const SceneResource = preload("res://animations/ep00_introduction/introduction_scene.tscn")

var scene_instance: Node2D

func _init() -> void:
	print("=== Starting Nemi Introduction Video Render ===")
	call_deferred("_launch_render")

func _launch_render() -> void:
	scene_instance = SceneResource.instantiate()
	root.add_child(scene_instance)
	print("Introduction scene instantiated. Execution started...")
