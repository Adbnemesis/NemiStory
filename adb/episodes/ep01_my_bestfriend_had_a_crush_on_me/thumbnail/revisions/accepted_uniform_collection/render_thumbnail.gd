extends SceneTree
## EP01 static thumbnail: unchanged ADB rig, existing crush-heart and shared aura.
const AdbScene = preload("res://adb/characters/adb/ADB.tscn")
const Gags = preload("res://common/storytime/production/SchoolGags.gd")
const Acting = preload("res://common/storytime/PerformancePlayer.gd")
const Style = preload("res://tools/storytime/ThumbnailStyle.gd")
const OUT = "res://adb/episodes/ep01_my_bestfriend_had_a_crush_on_me/thumbnail/"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var layout = JSON.parse_string(FileAccess.get_file_as_string(OUT+"layout.json"))
	assert(layout.author=="adb")
	var art_vp = SubViewport.new()
	art_vp.size = Vector2i(3840,2160)
	art_vp.transparent_bg = true
	art_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(art_vp)
	var art_world = Node2D.new()
	art_world.scale = Vector2(2,2)
	art_vp.add_child(art_world)
	var heart = Gags.make("adb","crush_heart")
	heart.position = Vector2(layout.heart.position[0],layout.heart.position[1])
	heart.scale = Vector2.ONE*float(layout.heart.scale)
	heart.rotation_degrees = -13
	heart.progress = 1.0
	art_world.add_child(heart)
	var adb = AdbScene.instantiate()
	art_world.add_child(adb)
	adb.process_mode = Node.PROCESS_MODE_DISABLED
	Acting.sample(adb,"adb",[{"at":0.0,"recipe":layout.character.recipe}],1.0)
	adb.face.blush_intensity = .75
	adb.face.eye_openness_left = 1.02
	adb.face.eye_openness_right = .92
	adb.face.eye_gaze = Vector2(-.55,.14)
	adb.head_tilt = -5
	adb.face.rotation_degrees = adb.head_tilt
	adb.face.queue_redraw()
	adb.position = Vector2(layout.character.position[0],layout.character.position[1])
	adb.scale = Vector2.ONE*float(layout.character.scale)
	adb.queue_redraw()
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
	Style.mark(world,"adb","spark",Vector2(101,97),Vector2(1.8,1.8),-15)
	Style.mark(world,"adb","question",Vector2(1813,183),Vector2(2.6,2.6),9)
	Style.mark(world,"adb","spark",Vector2(859,929),Vector2(1.6,1.6),28)
	Style.art_with_aura(world,art_img)
	Style.headline(world,layout.headline[0],Vector2(75,139),204)
	Style.headline(world,layout.headline[1],Vector2(84,353),304,Color("#44263b"))
	Style.mark(world,"adb","underline",Vector2(420,725),Vector2(5.1,1.2),-4)
	Style.mark(world,"adb","arrow",Vector2(704,853),Vector2(3.0,3.0),-40)
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	Style.save_exports(vp.get_texture().get_image(),OUT+"thumbnail")
	print("THUMBNAIL_OK adb_ep01_revision1")
	quit(0)
