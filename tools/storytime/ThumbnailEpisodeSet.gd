extends "res://tools/storytime/ThumbnailBatch.gd"
## Independent story compositions; no mandatory channel colour/template.
const Editorial=preload("res://tools/storytime/ThumbnailStoryArt.gd")
const SceneProps=preload("res://common/storytime/production/SceneArt.gd")
const Contacts=preload("res://common/storytime/production/HandPaths.gd")

func character(parent: Node2D,item: Dictionary) -> void:
	super.character(parent,item)
	var node=parent.get_child(parent.get_child_count()-1)
	if item.author=="nemi":
		for target in item.get("hand_targets",[]):
			var at: Vector2
			if target.has("head_offset"):
				at=node.to_local(node.head_bone.to_global(vec(target.head_offset)))
			else:at=vec(target.position)
			node.set_hand_pose(target.side=="left",target.hand)
			var paths={target.side:[{"at":0.0,"position":[at.x,at.y],"angle":target.get("angle",0.0)}]}
			Contacts.sample(node,"nemi",paths,0.0)
			if target.has("elbow_side"):
				# Static editorial direction through set_arm; preserve both segment
				# lengths and choose the other elbow branch to keep sleeves off eyes.
				var upper: Bone2D=node.get(target.side+"_upper_arm_bone")
				var lower: Bone2D=node.get(target.side+"_lower_arm_bone")
				var hand: Bone2D=node.get(target.side+"_hand_bone")
				var delta: Vector2=upper.get_parent().to_local(node.to_global(at))-upper.position
				var l1=lower.position.length()
				var l2=hand.position.length()
				var distance=clampf(delta.length(),absf(l1-l2)+.01,l1+l2-.01)
				var shoulder=acos(clampf((l1*l1+distance*distance-l2*l2)/(2*l1*distance),-1,1))
				var elbow=PI-acos(clampf((l1*l1+l2*l2-distance*distance)/(2*l1*l2),-1,1))
				var direction=float(target.elbow_side)
				node.set_arm(target.side=="left",rad_to_deg(delta.angle()-PI*.5-direction*shoulder),rad_to_deg(direction*elbow),target.hand,0.0)
				hand.global_rotation=node.global_rotation+deg_to_rad(float(target.get("angle",0.0)))

func prop(parent: Node2D,item: Dictionary,author: String) -> void:
	if item.kind=="scene":
		var node=SceneProps.make(author,item.asset)
		node.progress=1.0
		transform(node,item)
		parent.add_child(node)
	else: super.prop(parent,item,author)

func render_one(path: String) -> void:
	var layout=JSON.parse_string(FileAccess.get_file_as_string(path))
	assert(layout.author in ["nemi","adb"])
	var art_vp=SubViewport.new()
	art_vp.size=Vector2i(3840,2160)
	art_vp.transparent_bg=true
	art_vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(art_vp)
	var art=Node2D.new()
	art.scale=Vector2(2,2)
	art_vp.add_child(art)
	for item in layout.props:prop(art,item,layout.author)
	for item in layout.characters:character(art,item)
	for item in layout.get("art_marks",[]):decoration(art,layout.author,item)
	for i in range(3):await process_frame
	# A held composition may not trigger another redraw. Force a real GPU draw
	# instead of waiting indefinitely on frame_post_draw (same as render_stage).
	RenderingServer.force_draw.call_deferred(false,1.0/30.0)
	await process_frame
	var img=art_vp.get_texture().get_image()
	var vp=SubViewport.new()
	vp.size=Vector2i(3840,2160)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var world=Node2D.new()
	world.scale=Vector2(2,2)
	vp.add_child(world)
	Style.background(world,layout.background.top,layout.background.bottom)
	Editorial.background(world,layout.author,layout.background)
	if layout.get("aura",true):Style.art_with_aura(world,img)
	else:
		var sprite=Sprite2D.new()
		sprite.texture=ImageTexture.create_from_image(img)
		sprite.centered=false
		sprite.scale=Vector2(.5,.5)
		world.add_child(sprite)
	for item in layout.headline:Editorial.headline(world,item)
	for item in layout.marks:decoration(world,layout.author,item)
	for i in range(3):await process_frame
	RenderingServer.force_draw.call_deferred(false,1.0/30.0)
	await process_frame
	Style.save_exports(vp.get_texture().get_image(),path.get_base_dir()+"/thumbnail")
	print("THUMBNAIL_STORY_OK ",layout.episode)
	vp.queue_free()
	art_vp.queue_free()
	await process_frame
