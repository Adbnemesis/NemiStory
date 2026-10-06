extends "res://shorts/godot/BatchEdit.gd"
## Version 3: authored body/face motion, finite camera follow and drawn event paths.
const DynamicArt = preload("res://shorts/godot/DynamicPoseArt.gd")
const DynamicAccents = preload("res://shorts/godot/DynamicAccentArt.gd")
var dynamic_ready := false
var motion_tracks: Dictionary = {}
var outgoing_canvas: Node2D
var outgoing_art: Dictionary = {}
var wipe_shader: Shader

func _ready() -> void:
	super._ready()
	for item in config.actors:
		motion_tracks[item.id] = item.motion
	for id in actors:
		var entry: Dictionary = actors[id]
		entry.drawing.queue_free()
		var art = DynamicArt.new()
		art.author = entry.author
		canvas.add_child(art)
		entry.drawing = art
	marks.queue_free()
	frontmarks.queue_free()
	marks = DynamicAccents.new()
	marks.events = config.events
	marks.theme = config.theme.signature
	add_child(marks)
	move_child(marks,1)
	frontmarks = DynamicAccents.new()
	frontmarks.events = config.events
	frontmarks.foreground = true
	frontmarks.z_index = 50
	add_child(frontmarks)
	# A departing pose is another editable vector drawing, never a captured sprite.
	outgoing_canvas = Node2D.new()
	add_child(outgoing_canvas)
	move_child(outgoing_canvas,canvas.get_index())
	for id in actors:
		var art = DynamicArt.new()
		art.author = actors[id].author
		outgoing_canvas.add_child(art)
		outgoing_art[id] = art
	wipe_shader = Shader.new()
	wipe_shader.code = "shader_type canvas_item; uniform float boundary = -200.; uniform float direction = 1.; uniform float incoming = 1.; uniform float focus_y = 850.; void fragment(){float edge=boundary+(FRAGCOORD.y-focus_y)*.06*direction; float side=(FRAGCOORD.x-edge)*direction; if((incoming>0.5 && side>0.) || (incoming<0.5 && side<0.)){discard;}}"
	for id in actors:
		for art in [actors[id].drawing,outgoing_art[id]]:
			var material = ShaderMaterial.new()
			material.shader = wipe_shader
			art.set_meta("wipe_material",material)
	dynamic_ready = true
	sample(0)

func motion_at(track: Array, frame: int) -> Dictionary:
	var a: Dictionary = track[0]
	var b: Dictionary = a
	for key in track:
		if int(key.frame) <= frame: a = key
		else:
			b = key
			break
	if int(b.frame) <= int(a.frame): return a
	var u := clampf(float(frame-int(a.frame))/float(int(b.frame)-int(a.frame)),0,1)
	# Smooth finite path; a matching pair of keys creates a true held pose.
	var e := u*u*(3-2*u)
	var result: Dictionary = {}
	for field in ["head","look","eyes","lean","gesture"]:
		result[field] = lerpf(float(a[field]),float(b[field]),e)
	return result

func sample(frame: int) -> void:
	super.sample(frame)
	if not dynamic_ready: return
	if shot.has("travel"):
		var t: Dictionary = shot.travel
		var u := clampf(float(frame-int(shot.frame))/float(int(t.end)-int(shot.frame)),0,1)
		var e := u*u*(3-2*u)
		var factor := lerpf(1,float(t.zoom),e)
		canvas.scale *= factor
		canvas.position = Vector2(540,960)-Vector2(shot.center[0],shot.center[1])*canvas.scale.x
		canvas.position += Vector2(t.pan[0],t.pan[1])*e
		if shot.move == "whip":
			var settle := clampf(float(frame-int(shot.frame))/float(shot.get("settle",5)),0,1)
			canvas.position.x += pow(1-settle,3)*420*int(shot.get("direction",1))
	for id in actors:
		var drawing = actors[id].drawing
		if not drawing.visible: continue
		var m := motion_at(motion_tracks[id],frame)
		var cue := cue_at(actors[id].art_cues,frame)
		drawing.body_pose = cue.get("bodyPose","neutral")
		drawing.page_art = cue.get("pageArt","cat")
		drawing.rotation = 0
		drawing.head_angle = m.head
		drawing.look_x = m.look
		drawing.eye_open = m.eyes
		drawing.torso_lean = m.lean
		drawing.pose_progress = m.gesture
		drawing.queue_redraw()
	apply_transition(frame)
	var camera_delta := camera_delta_at(shot,frame)
	canvas.transform = camera_delta*canvas.transform
	marks.stage_transform = camera_delta if marks.stage in ["door","runway","columns"] else Transform2D.IDENTITY
	marks.queue_redraw()

func camera_delta_at(target_shot: Dictionary, frame: int) -> Transform2D:
	if not target_shot.has("camera"): return Transform2D.IDENTITY
	var camera: Dictionary = target_shot.camera
	var track: Array = camera["keys"]
	var a: Dictionary = track[0]
	var b: Dictionary = a
	for key in track:
		if int(key.frame) <= frame: a = key
		else:
			b = key
			break
	var factor := float(a.factor)
	var pan := Vector2(a.pan[0],a.pan[1])
	var roll := float(a.roll)
	if int(b.frame)>int(a.frame):
		var u := clampf(float(frame-int(a.frame))/float(int(b.frame)-int(a.frame)),0,1)
		# The destination key owns the arriving segment's easing.
		match b.ease:
			"smooth":u = u*u*(3-2*u)
			"out":u = 1-pow(1-u,3)
			"in":u = u*u*u
		factor = lerpf(float(a.factor),float(b.factor),u)
		pan = pan.lerp(Vector2(b.pan[0],b.pan[1]),u)
		roll = lerpf(float(a.roll),float(b.roll),u)
	var focus := Vector2(camera.focus[0],camera.focus[1])
	var delta := Transform2D(deg_to_rad(roll),Vector2.ZERO)
	delta.x *= factor
	delta.y *= factor
	delta.origin = focus+pan-delta.basis_xform(focus)
	return delta

func previous_of(target_shot: Dictionary) -> Dictionary:
	var previous: Dictionary = config.shots[0]
	for candidate in config.shots:
		if int(candidate.frame)>=int(target_shot.frame):break
		previous = candidate
	return previous

func base_transform_at(target_shot: Dictionary, frame: int) -> Transform2D:
	# Recompute the director's real picture state at an arbitrary frame. Outgoing
	# transition art must not jump back to an unzoomed/unpanned saved shot root.
	var age := frame-int(target_shot.frame)
	var settle := clampf(float(age)/float(target_shot.get("settle",5)),0,1)
	var ease := 1-pow(1-settle,3)
	var zoom := float(target_shot.zoom)
	if target_shot.move=="punch":zoom *= 1+.13*(1-ease)
	elif target_shot.move=="pull":zoom *= 1+.23*(1-ease)
	var roll := deg_to_rad(float(target_shot.get("angle",0))*(1-ease))
	var position := Vector2(540,960)-Vector2(target_shot.center[0],target_shot.center[1])*zoom
	if target_shot.move=="whip":position.x += pow(1-settle,3)*420*int(target_shot.get("direction",1))
	var transition: Dictionary = target_shot.get("transition",{})
	var active_transition := not transition.is_empty() and age>=0 and age<int(transition.duration)
	if active_transition:
		zoom = float(target_shot.zoom)
		roll = 0
		position = Vector2(540,960)-Vector2(target_shot.center[0],target_shot.center[1])*zoom
	if target_shot.has("travel"):
		var travel: Dictionary = target_shot.travel
		var u := clampf(float(age)/float(int(travel.end)-int(target_shot.frame)),0,1)
		var smooth := u*u*(3-2*u)
		zoom *= lerpf(1,float(travel.zoom),smooth)
		position = Vector2(540,960)-Vector2(target_shot.center[0],target_shot.center[1])*zoom+Vector2(travel.pan[0],travel.pan[1])*smooth
		if target_shot.move=="whip" and not active_transition:position.x += pow(1-settle,3)*420*int(target_shot.get("direction",1))
	var result := Transform2D(roll,position)
	result.x *= zoom
	result.y *= zoom
	if active_transition:
		var u := clampf(float(age)/float(transition.duration),0,1)
		var e := 1-pow(1-u,3)
		var direction := int(transition.get("direction",1))
		var focus_data: Array = transition.get("focus",[540,850])
		var focus := Vector2(focus_data[0],focus_data[1])
		if transition.kind in ["whip","smear"]:result.origin.x += 1320.0*(1-e)*direction
		if transition.kind=="smear":
			var stretch := Vector2(1+.12*(1-e),1-.035*(1-e))
			result.x *= stretch.x
			result.y *= stretch.y
			result.origin = focus+(result.origin-focus)*stretch
		elif transition.kind=="match":
			var previous := previous_of(target_shot)
			var factor := lerpf(clampf(float(previous.zoom)/float(target_shot.zoom),.78,1.22),1,e)
			result.x *= factor
			result.y *= factor
			result.origin = focus+(result.origin-focus)*factor
	return result

func cue_at(track: Array, frame: int) -> Dictionary:
	var result: Dictionary = track[0]
	for key in track:
		if int(key.frame) <= frame: result = key
		else: break
	return result

func previous_shot() -> Dictionary:
	var previous: Dictionary = config.shots[0]
	for candidate in config.shots:
		if int(candidate.frame) >= int(shot.frame): break
		previous = candidate
	return previous

func prepare_outgoing(previous: Dictionary, frame: int) -> void:
	var departure_frame := maxi(0,int(shot.frame)-1)
	outgoing_canvas.transform = camera_delta_at(previous,departure_frame)*base_transform_at(previous,departure_frame)
	for id in outgoing_art:
		var art = outgoing_art[id]
		art.visible = previous.actors.has(id)
		if not art.visible: continue
		var cue := cue_at(actors[id].art_cues,maxi(0,int(shot.frame)-1))
		var m := motion_at(motion_tracks[id],maxi(0,int(shot.frame)-1))
		var block: Dictionary = previous.actors[id]
		art.position = Vector2(block.position[0],block.position[1])
		art.scale = Vector2(float(block.scale)*int(block.get("flip",1)),float(block.scale))
		art.view = cue.get("view","front")
		art.body_pose = cue.get("bodyPose","neutral")
		art.page_art = cue.get("pageArt","cat")
		art.action = cue.get("action","rest")
		art.emotion = cue.get("emotion","shy")
		art.accessory = actors[id].drawing.accessory
		for field in ["ink","paper","shade","accent","shading"]: art.set(field,actors[id].drawing.get(field))
		art.head_angle = m.head
		art.look_x = m.look
		art.eye_open = m.eyes
		art.torso_lean = m.lean
		art.pose_progress = m.gesture
		art.smear = false
		art.queue_redraw()

func set_wipe(art: Node2D, boundary: float, direction: int, incoming: bool, focus_y: float) -> void:
	var material: ShaderMaterial = art.get_meta("wipe_material")
	material.set_shader_parameter("boundary",boundary)
	material.set_shader_parameter("direction",float(direction))
	material.set_shader_parameter("incoming",1.0 if incoming else 0.0)
	material.set_shader_parameter("focus_y",focus_y)
	art.material = material

func apply_transition(frame: int) -> void:
	outgoing_canvas.visible = false
	frontmarks.transition = {}
	for id in actors:
		actors[id].drawing.material = null
		outgoing_art[id].material = null
	if not shot.has("transition"): return
	var transition: Dictionary = shot.transition
	var age := frame-int(shot.frame)
	var span := int(transition.duration)
	if age < 0 or age >= span: return
	# Endpoint belongs to a real held drawing, with no oscillation after this window.
	var u := clampf(float(age)/float(span),0,1)
	var ease := 1-pow(1-u,3)
	var direction := int(transition.get("direction",1))
	var focus := Vector2(transition.get("focus",[540,850])[0],transition.get("focus",[540,850])[1])
	var kind: String = transition.kind
	var previous := previous_shot()
	# A pre-beat transition can explicitly preview its target drawing. The cue still
	# lands on the named accent; no automatic interpolation of two body drawings.
	var pose_frame := int(transition.get("poseFrame",shot.frame))
	for id in actors:
		var drawing = actors[id].drawing
		if not drawing.visible: continue
		var cue := cue_at(actors[id].art_cues,pose_frame)
		var motion := motion_at(motion_tracks[id],pose_frame)
		drawing.view = cue.get("view","front")
		drawing.emotion = cue.get("emotion","shy")
		drawing.action = cue.get("action","rest")
		drawing.body_pose = cue.get("bodyPose","neutral")
		drawing.page_art = cue.get("pageArt","cat")
		drawing.head_angle = motion.head
		drawing.look_x = motion.look
		drawing.eye_open = motion.eyes
		drawing.torso_lean = motion.lean
		drawing.pose_progress = motion.gesture
		drawing.queue_redraw()
	# Explicit transitions replace the older generic shot arrival to avoid double whips.
	var zoom := float(shot.zoom)
	canvas.scale = Vector2.ONE*zoom
	canvas.rotation = 0
	canvas.position = Vector2(540,960)-Vector2(shot.center[0],shot.center[1])*zoom
	if shot.has("travel"):
		var travel: Dictionary = shot.travel
		var travel_u := clampf(float(frame-int(shot.frame))/float(int(travel.end)-int(shot.frame)),0,1)
		var travel_e := travel_u*travel_u*(3-2*travel_u)
		canvas.scale *= lerpf(1,float(travel.zoom),travel_e)
		canvas.position = Vector2(540,960)-Vector2(shot.center[0],shot.center[1])*canvas.scale.x
		canvas.position += Vector2(travel.pan[0],travel.pan[1])*travel_e
	prepare_outgoing(previous,frame)
	if int(shot.frame) > 0 and kind in ["whip","smear","focus_wipe"]: outgoing_canvas.visible = true
	match kind:
		"whip":
			canvas.position.x += 1320.0*(1-ease)*direction
			outgoing_canvas.position.x -= 1320.0*ease*direction
			for id in actors: actors[id].drawing.smear = age < 3
		"smear":
			# Keep the incoming face outside the frame at the start. A speed smear
			# must not look like two complete characters standing beside each other.
			canvas.position.x += 1320.0*(1-ease)*direction
			outgoing_canvas.position.x -= 1380.0*ease*direction
			var stretch := Vector2(1+.12*(1-ease),1-.035*(1-ease))
			canvas.scale *= stretch
			canvas.position = focus+(canvas.position-focus)*stretch
			for id in actors: actors[id].drawing.smear = age < 3
		"match":
			var start := clampf(float(previous.zoom)/zoom,.78,1.22)
			var factor := lerpf(start,1,ease)
			canvas.scale *= factor
			canvas.position = focus+(canvas.position-focus)*factor
		"focus_wipe":
			# The strip crosses the authored focus at half-time; its diagonal edge
			# and complementary art masks use exactly the same path.
			var first := -170.0 if direction == 1 else 1250.0
			var last := 1250.0 if direction == 1 else -170.0
			var boundary := lerpf(first,focus.x,u*2) if u<.5 else lerpf(focus.x,last,(u-.5)*2)
			for id in actors:
				set_wipe(actors[id].drawing,boundary,direction,true,focus.y)
				set_wipe(outgoing_art[id],boundary,direction,false,focus.y)
			frontmarks.transition = transition
			frontmarks.transition_boundary = boundary
			frontmarks.paper = actors.values()[0].drawing.paper
	frontmarks.queue_redraw()
