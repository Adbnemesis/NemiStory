extends SceneTree

func _init() -> void:
	var adb_scene = load("res://adb/characters/adb/ADB.tscn")
	var adb = adb_scene.instantiate()
	root.add_child(adb)
	adb.position = Vector2(300, 300)
	adb.set_pose("stumble_pushed", 0.0)
	
	for i in range(5):
		await process_frame
		
	var img = root.get_texture().get_image()
	img.save_png("res://adb/renders/test_stumble.png")
	print("Saved test_stumble.png")
	quit(0)
