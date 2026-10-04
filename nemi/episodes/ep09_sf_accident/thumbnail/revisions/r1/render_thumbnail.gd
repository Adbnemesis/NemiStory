extends SceneTree
## Static editorial composition. Reuses the episode's rigs, art and pen; no AI image service.
const NemiScene = preload("res://nemi/characters/nemi/nemi.tscn")
const Travel = preload("res://common/storytime/production/TravelArt.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const Backdrop = preload("res://common/storytime/production/Backdrop.gd")
const Impact = preload("res://assets/fonts/Impact.ttf")
const Hand = preload("res://assets/fonts/PatrickHand-Regular.ttf")
const OUT = "res://nemi/episodes/ep09_sf_accident/thumbnail/"
var layout: Dictionary

func _initialize() -> void:
	call_deferred("render_all")

func render_all() -> void:
	var file = FileAccess.open(OUT + "layout.json", FileAccess.READ)
	if file == null:
		push_error("Missing thumbnail layout")
		quit(1)
		return
	layout = JSON.parse_string(file.get_as_text())
	assert(layout.author == "nemi", "This episode's thumbnail uses Nemi art")
	for variant in layout.variants:
		await render_one(variant)
	quit(0)

func text_layer(parent: Node, value: String, at: Vector2, size_px: int, color: Color, font: Font = Impact) -> Label:
	var label = Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size_px)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func mark(parent: Node, kind: String, at: Vector2, size_xy: Vector2, tilt: float = 0.0) -> void:
	var node = Assets.mark(layout.author, kind, true)
	node.position = at
	node.scale = size_xy
	node.rotation_degrees = tilt
	node.progress = 1.0
	parent.add_child(node)

func render_one(variant: Dictionary) -> void:
	var vp = SubViewport.new()
	vp.size = Vector2i(3840, 2160)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var world = Node2D.new()
	world.scale = Vector2(2, 2)
	vp.add_child(world)
	var ink = Color(layout.palette.ink)
	var rose = Color(layout.palette.accent)
	var paper = Color(layout.palette.paper)
	var bg = Node2D.new()
	bg.draw.connect(func():
		bg.draw_rect(Rect2(0, 0, 1920, 1080), paper)
		# A quiet flat-colour field; the face and collision keep priority.
		bg.draw_colored_polygon(PackedVector2Array([Vector2(0,0),Vector2(705,0),Vector2(775,1080),Vector2(0,1080)]), Color("#dce7e2"))
	)
	world.add_child(bg)
	# The actual Golden Gate set, cropped as a contextual postcard behind the portrait.
	var clip = Control.new()
	clip.position = Vector2(0, 115)
	clip.size = Vector2(705, 470)
	clip.clip_contents = true
	world.add_child(clip)
	var bridge = Backdrop.new()
	bridge.kind = "sf_bridge"
	bridge.position = Vector2(-445, -43)
	bridge.scale = Vector2(0.64, 0.64)
	bridge.modulate = Color(1, 1, 1, 0.48)
	clip.add_child(bridge)
	# Location tag is editorial typography, not a replacement for scenery.
	text_layer(world, "SAN FRANCISCO", Vector2(66, 44), 52, ink, Hand)
	mark(world, "underline", Vector2(265, 116), Vector2(2.9, 0.75))
	# Right-hand headline; short enough to read in a feed.
	text_layer(world, variant.top, Vector2(795, 76), int(variant.top_size), ink)
	text_layer(world, variant.bottom, Vector2(790, 275), int(variant.bottom_size), rose)
	mark(world, "underline", Vector2(1278, 510), Vector2(6.9, 1.3), -1.0)
	# Road is a separate vignette, not a scene with a giant person standing beside tiny cars.
	var road = Node2D.new()
	road.draw.connect(func():
		road.draw_colored_polygon(PackedVector2Array([Vector2(746,807),Vector2(1920,776),Vector2(1920,1080),Vector2(759,1080)]), Color("#b9bcbb"))
		road.draw_line(Vector2(752,823),Vector2(1920,794),Color("#efe4c9"),4,true)
		for x in [840, 1150, 1480]:
			road.draw_line(Vector2(x, 1020),Vector2(x+176, 1017),Color("#f8f1d9"),8,true)
	)
	world.add_child(road)
	# Both vehicles face left: the following car's front meets the taxi's rear.
	for item in layout.cars:
		var car = Travel.make(layout.author, item.kind)
		car.position = Vector2(item.position[0], item.position[1])
		car.scale = Vector2(-float(item.scale), float(item.scale))
		car.progress = 1.0
		world.add_child(car)
	# Taxi identifier is a small flat editorial tab; it adds no new crash or injury.
	var tab = Node2D.new()
	tab.draw.connect(func():
		tab.draw_colored_polygon(PackedVector2Array([Vector2(925,648),Vector2(1059,650),Vector2(1063,686),Vector2(921,686)]),paper)
		tab.draw_polyline(PackedVector2Array([Vector2(925,648),Vector2(1059,650),Vector2(1063,686),Vector2(921,686),Vector2(925,648)]),ink,3,true)
	)
	world.add_child(tab)
	text_layer(world, "TAXI", Vector2(952, 645), 33, ink, Hand)
	# One editorial impact accent using the author's existing spark mark, rotated around contact.
	mark(world, "spark", Vector2(1306, 779), Vector2(2.4, 2.4), 19)
	mark(world, "spark", Vector2(1306, 874), Vector2(2.1, 2.1), 166)
	text_layer(world, "!!", Vector2(1275, 591), 112, rose, Hand).rotation_degrees = 9
	# Foreground portrait from the unchanged production rig.
	var nemi = NemiScene.instantiate()
	world.add_child(nemi)
	nemi.process_mode = Node.PROCESS_MODE_DISABLED
	nemi.set_style("color")
	nemi.set_pose("idle", 0.0)
	nemi.set_expression("shocked")
	nemi.set_eye_openness(1.27)
	nemi.set_pupil_scale(0.68)
	nemi.look_at_direction(Vector2(0.2, 0.12))
	nemi.set_arm(true, -15, 30, "relaxed", 0.0)
	nemi.set_arm(false, 15, -170, "open_palm_up", 0.0)
	nemi.position = Vector2(layout.character.position[0], layout.character.position[1])
	nemi.scale = Vector2.ONE * float(layout.character.scale)
	nemi.head_tilt(-3, 0.0)
	# Short hand-written aside carries Nemi's voice without supplying new dialogue.
	var aside = text_layer(world, "I WAS IN THE BACK.", Vector2(799, 546), 53, ink, Hand)
	aside.rotation_degrees = -1.5
	for frame in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	var img = vp.get_texture().get_image()
	assert(img.get_size() == Vector2i(3840, 2160))
	var prefix = OUT + str(variant.file)
	assert(img.save_png(prefix + "_master_4k.png") == OK)
	img.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	assert(img.save_png(prefix + ".png") == OK)
	assert(img.save_jpg(prefix + ".jpg", 0.93) == OK)
	img.resize(320, 180, Image.INTERPOLATE_LANCZOS)
	assert(img.save_png(prefix + "_phone.png") == OK)
	print("THUMBNAIL_OK ", variant.file)
	root.remove_child(vp)
	vp.queue_free()
