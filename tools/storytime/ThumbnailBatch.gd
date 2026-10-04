extends SceneTree
## Static production-art compositions only; no episode or rig mutation.
const Style = preload("res://tools/storytime/ThumbnailStyle.gd")
const Acting = preload("res://common/storytime/PerformancePlayer.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const IntroProps = preload("res://adb/episodes/ep00_intro/props/ADBIntroProps.gd")
const FearArt = preload("res://nemi/episodes/ep04_scared/Ep04Doodles.gd")
const CelebrationArt = preload("res://nemi/episodes/ep05_celebration/Ep05Doodles.gd")
const SchoolArt = preload("res://common/storytime/production/SchoolGags.gd")

func layout_paths() -> Array:
	var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://tools/storytime/thumbnail_collection.json"))
	var paths: Array = []
	for item in manifest.episodes:
		if item.get("render_in_batch",false): paths.append("res://"+item.folder+"/thumbnail/layout.json")
	return paths

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var paths = layout_paths()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--layout="): paths = [arg.trim_prefix("--layout=")]
	for path in paths: await render_one(path)
	print("THUMBNAIL_BATCH_OK ",paths.size())
	quit(0)

func vec(values: Array) -> Vector2: return Vector2(values[0],values[1])

func transform(node: Node2D, item: Dictionary) -> void:
	node.position = vec(item.position)
	var size_value = item.get("scale",1.0)
	node.scale = vec(size_value) if size_value is Array else Vector2.ONE*float(size_value)
	node.rotation_degrees = float(item.get("angle",0.0))

func character(parent: Node2D, item: Dictionary) -> void:
	var node = load(item.rig).instantiate()
	parent.add_child(node)
	node.process_mode = Node.PROCESS_MODE_DISABLED
	var author: String = item.author
	if author == "nemi":
		node.set_style("color")
		node.set_pose(item.get("pose","idle"),0.0)
		node.set_expression(item.expression)
		node.set_eye_openness(float(item.get("eyes",1.0)))
		node.set_pupil_scale(float(item.get("pupils",1.0)))
		node.look_at_direction(vec(item.get("gaze",[0.0,0.0])))
		node.head_tilt(float(item.get("tilt",0.0)),0.0)
		for arm in item.get("arms",[]):
			node.set_arm(arm.left,float(arm.upper),float(arm.lower),arm.hand,0.0)
	elif author == "adb":
		Acting.sample(node,"adb",[{"at":0.0,"recipe":item.recipe}],1.0)
		if item.has("expression"): node.set_expression(item.expression,0.0)
	elif author == "legacy_adb":
		# EP02 uses this historical character in its film; no new episode use.
		node.set_expression(item.expression,0.0)
		node.look("left")
	else: assert(false,"Unknown character source")
	transform(node,item)
	node.queue_redraw()

func prop(parent: Node2D, item: Dictionary, author: String) -> void:
	var node: Node2D
	match item.kind:
		"script": node = load(item.source).new()
		"cat":
			node = load("res://nemi/characters/neeko/Neeko.tscn").instantiate()
		"paddle": node = IntroProps.TableTennisPaddle.new()
		"controller": node = IntroProps.GameController.new()
		"youtube":
			node = FearArt.DoodleYouTube.new()
			# Omit the optional annotation while retaining the film's play-button art.
			var annotation = node.get_child(node.get_child_count()-1)
			node.remove_child(annotation)
			annotation.free()
		"crowd":
			node = CelebrationArt.DoodleTinyCrowd.new(0.0)
			var members: Array = node.crowd_members.slice(0,12)
			for i in range(members.size()):
				members[i].pos = Vector2((i%6)*65,floor(float(i)/6.0)*60.0)
			node.crowd_members = members
		"heart", "paper":
			node = SchoolArt.make(author,"crush_heart" if item.kind=="heart" else "blank_classwork")
			node.progress = 1.0
		_: assert(false,"Unknown production prop kind: "+item.kind)
	parent.add_child(node)
	if item.kind == "cat":
		node.set_state(item.get("state","scared"),0.0)
		node.get("_active_tween").custom_step(1.0)
		node.get("_active_tween").kill()
	for key in item.get("controls",{}): node.set(key,item.controls[key])
	node.process_mode = Node.PROCESS_MODE_DISABLED
	transform(node,item)
	node.queue_redraw()

func decoration(parent: Node2D, author: String, item: Dictionary) -> void:
	var node = Assets.mark(author,item.kind)
	for stroke in node.stroke_list:
		stroke.col = Color(item.get("color","#ffffff"))
		stroke.w *= float(item.get("weight",1.5))
	node.prepare()
	node.progress = 1.0
	transform(node,item)
	parent.add_child(node)

func render_one(path: String) -> void:
	var layout = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert(layout.author in ["nemi","adb"])
	var art_vp = SubViewport.new()
	art_vp.size = Vector2i(3840,2160)
	art_vp.transparent_bg = true
	art_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(art_vp)
	var art = Node2D.new()
	art.scale = Vector2(2,2)
	art_vp.add_child(art)
	for item in layout.props: prop(art,item,layout.author)
	for item in layout.characters: character(art,item)
	for item in layout.get("art_marks",[]): decoration(art,layout.author,item)
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	var img = art_vp.get_texture().get_image()
	var vp = SubViewport.new()
	vp.size = Vector2i(3840,2160)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var world = Node2D.new()
	world.scale = Vector2(2,2)
	vp.add_child(world)
	Style.background(world,layout.background.top,layout.background.bottom)
	Style.art_with_aura(world,img)
	var font = load("res://assets/fonts/Impact.ttf")
	for line in layout.headline:
		var size_px: int = line["size"]
		while font.get_string_size(line.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x > float(line.max_width): size_px -= 1
		assert(size_px>=150,"Headline needs a shorter hook")
		Style.headline(world,line.text,vec(line.position),size_px,Color(line.color))
	for item in layout.marks: decoration(world,layout.author,item)
	for i in range(3): await process_frame
	await RenderingServer.frame_post_draw
	Style.save_exports(vp.get_texture().get_image(),path.get_base_dir()+"/thumbnail")
	print("THUMBNAIL_OK ",layout.episode)
	vp.queue_free()
	art_vp.queue_free()
	await process_frame
