extends SceneTree

func _init():
	print("--- Rendering Comparison: Old Sharp Face vs New Smooth Organic Curve Face ---")
	var root_vp := root
	
	var stage := Node2D.new()
	root_vp.add_child(stage)
	
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color("#faf7f5")
	stage.add_child(bg)
	
	var drawer := Node2D.new()
	drawer.set_script(load("res://scratch/test_drawer.gd"))
	stage.add_child(drawer)
	
	# Render 4 frames to flush
	for i in range(4):
		await process_frame
	
	var img := root_vp.get_texture().get_image()
	img.save_png("scratch/face_comparison.png")
	print("Saved scratch/face_comparison.png successfully!")
	quit(0)
