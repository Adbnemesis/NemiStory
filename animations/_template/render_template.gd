extends SceneTree

## Standalone CLI Render Runner for Template Animation
## Runs the animation scene and renders output for video generation.

const SceneResource = preload("res://animations/_template/template_scene.tscn")

var scene_instance: Node2D

func _init() -> void:
	print("=== Starting Animation Render ===")
	call_deferred("_launch_render")

func _launch_render() -> void:
	scene_instance = SceneResource.instantiate()
	root.add_child(scene_instance)
	print("Scene loaded. Animation running...")
