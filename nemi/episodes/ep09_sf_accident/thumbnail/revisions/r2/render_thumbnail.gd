extends SceneTree
## EP09 static revision 2: one headline, EP00-inspired colour field and shared white aura.
const NemiScene = preload("res://nemi/characters/nemi/nemi.tscn")
const Travel = preload("res://common/storytime/production/TravelArt.gd")
const Style = preload("res://tools/storytime/ThumbnailStyle.gd")
const OUT = "res://nemi/episodes/ep09_sf_accident/thumbnail/"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var layout = JSON.parse_string(FileAccess.get_file_as_string(OUT+"layout.json"))
	assert(layout.author=="nemi")
	var art_vp = SubViewport.new()
	art_vp.size = Vector2i(3840,2160)
	art_vp.transparent_bg = true
	art_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(art_vp)
	var art_world = Node2D.new()
	art_world.scale = Vector2(2,2)
	art_vp.add_child(art_world)
	for item in layout.cars:
		var car = Travel.make(layout.author,item.kind)
		car.position = Vector2(item.position[0],item.position[1])
		car.scale = Vector2(-float(item.scale),float(item.scale))
		car.progress = 1.0
		art_world.add_child(car)
	var nemi = NemiScene.instantiate()
	art_world.add_child(nemi)
	nemi.process_mode = Node.PROCESS_MODE_DISABLED
	nemi.set_style("color")
	nemi.set_pose("idle",0.0)
	nemi.set_expression("shocked")
	nemi.set_eye_openness(1.27)
	nemi.set_pupil_scale(0.68)
	nemi.look_at_direction(Vector2(.2,.12))
	nemi.set_arm(true,-15,30,"relaxed",0.0)
	nemi.set_arm(false,15,-170,"open_palm_up",0.0)
	nemi.position = Vector2(layout.character.position[0],layout.character.position[1])
	nemi.scale = Vector2.ONE*float(layout.character.scale)
	nemi.head_tilt(-3,0.0)
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var art_img = art_vp.get_texture().get_image()
	var vp = SubViewport.new()
	vp.size = Vector2i(3840,2160)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var world = Node2D.new()
	world.scale = Vector2(2,2)
	vp.add_child(world)
	Style.background(world,layout.background.top,layout.background.bottom)
	# Profile-authored decorations stay completed and use Nemi's own geometry.
	Style.mark(world,"nemi","spark",Vector2(93,248),Vector2(2.1,2.1),-24)
	Style.mark(world,"nemi","circle",Vector2(1738,654),Vector2(.65,.65),-12)
	Style.mark(world,"nemi","spark",Vector2(1846,95),Vector2(1.65,1.65),10)
	Style.art_with_aura(world,art_img)
	Style.headline(world,layout.variants[0].top,Vector2(783,72),int(layout.variants[0].top_size))
	Style.headline(world,layout.variants[0].bottom,Vector2(778,291),int(layout.variants[0].bottom_size),Color("#ffe1b2"))
	Style.mark(world,"nemi","underline",Vector2(1275,571),Vector2(6.7,1.4),-2)
	Style.mark(world,"nemi","spark",Vector2(1300,741),Vector2(2.3,2.3),18)
	Style.mark(world,"nemi","spark",Vector2(1300,912),Vector2(1.7,1.7),174)
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	Style.save_exports(vp.get_texture().get_image(),OUT+"thumbnail")
	print("THUMBNAIL_OK nemi_ep09_revision2")
	quit(0)
