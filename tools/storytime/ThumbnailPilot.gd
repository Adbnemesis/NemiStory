extends "res://tools/storytime/ThumbnailEpisodeSet.gd"
## Ordered static production-art layers for title/thumbnail experiments.
## Uses the existing compositor, rig controls and exporter; no animation player.
var actors: Dictionary = {}
var contacts: Array = []

func layout_paths() -> Array:
	var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://tools/storytime/thumbnail_pilots_2026-10-06.json"))
	var paths: Array=[]
	for item in manifest.variants: paths.append("res://"+item.layout)
	return paths

func character(parent: Node2D,item: Dictionary) -> void:
	super.character(parent,item)
	var node=parent.get_child(parent.get_child_count()-1)
	if item.author=="adb":
		if item.has("look"): node.look(item.look)
		if item.has("gaze"): node.face.look_at_direction(vec(item.gaze))
		if item.has("eyes"):
			node.face.eye_openness_left=float(item.eyes)
			node.face.eye_openness_right=float(item.eyes)
		if item.has("tilt"): node.head_tilt_to(float(item.tilt),0.0)
		if item.has("blush"): node.set_blush(float(item.blush),0.0)
		if item.has("mouth"): node.set_mouth(item.mouth)
		if item.has("hand_targets"):
			var paths: Dictionary={}
			for target in item.hand_targets:
				paths[target.side]=[{"at":0.0,"position":target.position,"angle":target.get("angle",0)}]
				if target.has("hand"): node.get(target.side+"_hand_node").set_hand_type(target.hand)
			Contacts.sample(node,"adb",paths,0.0)
		node.face.queue_redraw()
	elif item.author=="nemi" and item.has("mouth"):
		node.set_mouth_shape(item.mouth)
	actors[item.id]=node
	node.queue_redraw()

func attach_prop(parent: Node2D,node: Node2D,item: Dictionary) -> void:
	var binding: Dictionary=item.attachment
	var actor: Node2D=actors[binding.actor]
	var nemi: bool=actor.has_method("set_mouth_shape")
	var hand: Node2D=actor.get(binding.hand+"_hand_bone" if nemi else binding.hand+"_hand_node")
	var grip=vec(binding.grip_local)
	var target=parent.to_local(hand.global_position)
	node.position=target-(grip*node.scale).rotated(node.rotation)
	var error=hand.global_position.distance_to(node.to_global(grip))
	assert(error<0.05,"Grip lost wrist contact")
	contacts.append({"prop":item.get("id",item.get("source","prop")),"actor":binding.actor,"hand":binding.hand,"wrist":[target.x,target.y],"grip_local":binding.grip_local,"error_native_px":error})
	if item.get("grip_overlay",false):
		# Duplicate the existing hand drawing at exactly its original transform.
		# No new fingers, hand geometry or rig edits are introduced.
		var original: Node2D=actor.get(binding.hand+"_hand_visual" if nemi else binding.hand+"_hand_node")
		var overlay: Node2D=original.duplicate()
		if nemi: overlay.style=actor.style
		parent.add_child(overlay)
		overlay.global_transform=original.global_transform
		overlay.z_index=node.z_index+1
		overlay.process_mode=Node.PROCESS_MODE_DISABLED
		overlay.queue_redraw()

func add_layer(parent: Node2D,item: Dictionary,index: int) -> void:
	var before=parent.get_child_count()
	match item.type:
		"character": character(parent,item)
		"prop": prop(parent,item,parent.get_meta("author"))
		"scenery":
			var source=load(item.source)
			assert(source.has_method("make"),"Scenery needs the documented make factory")
			var node=source.make(parent.get_meta("author"),item.variant,item.part)
			parent.add_child(node)
			if item.has("position"): transform(node,item)
		"mark": decoration(parent,parent.get_meta("author"),item)
		_: assert(false,"Unknown static layer type")
	var node: Node2D=parent.get_child(before)
	# Existing rig parts have local z-indices. Spacing layer indices keeps their
	# hands/face intact while allowing a later counter/car to occlude the torso.
	node.z_index=index*30
	if item.has("attachment"): attach_prop(parent,node,item)

func draw_capture(vp: SubViewport) -> Image:
	for i in range(3): await process_frame
	RenderingServer.force_draw.call_deferred(false,1.0/30.0)
	await process_frame
	return vp.get_texture().get_image()

func render_one(path: String) -> void:
	var layout=JSON.parse_string(FileAccess.get_file_as_string(path))
	assert(layout.format in ["storytime-static-pilot-v1","storytime-static-promotional-v1"])
	assert(layout.author in ["adb","nemi"])
	actors.clear()
	contacts.clear()
	var vp=SubViewport.new()
	vp.size=Vector2i(3840,2160)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var world=Node2D.new()
	world.scale=Vector2(2,2)
	world.set_meta("author",layout.author)
	vp.add_child(world)
	Style.background(world,layout.background.top,layout.background.bottom)
	for index in range(layout.layers.size()): add_layer(world,layout.layers[index],index+1)
	var bare: Image=await draw_capture(vp)
	bare.resize(1920,1080,Image.INTERPOLATE_LANCZOS)
	assert(bare.save_png(path.get_base_dir()+"/scene_without_text.png")==OK)
	var labels=Node2D.new()
	labels.z_index=1000
	world.add_child(labels)
	for item in layout.headline: Editorial.headline(labels,item)
	var finished: Image=await draw_capture(vp)
	Style.save_exports(finished,path.get_base_dir()+"/thumbnail")
	var metadata=FileAccess.open(path.get_base_dir()+"/contact_geometry.json",FileAccess.WRITE)
	metadata.store_string(JSON.stringify({"variant":layout.variant,"contacts":contacts,"space":"logical 1920x1080; errors in native 4K capture pixels"},"\t")+"\n")
	print("THUMBNAIL_PILOT_OK ",layout.episode," ",layout.variant)
	vp.queue_free()
	await process_frame
