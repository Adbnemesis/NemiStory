extends RefCounted
## New-production acting only. Evaluates from time, never accumulates motion.
const Base = preload("res://common/storytime/PerformancePlayer.gd")
const NP = preload("res://nemi/characters/nemi/NemiPose.gd")
const AP = preload("res://adb/poses/ADBPoseLibrary.gd")
const FACE_NEMI = ["eye_openness","pupil_scale","left_brow_offset","right_brow_offset","left_brow_tilt","right_brow_tilt","gaze_direction"]
const FACE_ADB = ["eye_openness_left","eye_openness_right","brow_left_height","brow_right_height","brow_left_angle","brow_right_angle","blush_intensity","tear_intensity","sweat_intensity","eye_gaze"]
var anchors: Dictionary = {}

func bind(actor: Node2D, author: String) -> void:
	if author=="nemi":
		var left: Vector2=actor.to_local(actor.left_foot_bone.global_position)
		var right: Vector2=actor.to_local(actor.right_foot_bone.global_position)
		var floor_y := maxf(left.y,right.y)
		anchors[actor.get_instance_id()]={"left":Vector2(left.x,floor_y),"right":Vector2(right.x,floor_y)}
	else:
		anchors[actor.get_instance_id()]={"left":Vector2(-22,178),"right":Vector2(22,178)}

func face_recipe(actor: Node2D, author: String, recipe: Dictionary) -> Dictionary:
	if author=="nemi":
		actor.set_expression(recipe.expression)
		actor.face.pupil_scale=1.0
		actor.face.exaggeration_mouth_scale=0.85
		actor.face.eye_openness=recipe.eyes
	else:
		actor.set_expression(recipe.expression,0.0)
		actor.face.eye_openness_left=recipe.eyes
		actor.face.eye_openness_right=recipe.eyes
	actor.face.set("gaze_direction" if author=="nemi" else "eye_gaze",Vector2(recipe.gaze[0],recipe.gaze[1]))
	for key in recipe.face:
		var value: Variant=recipe.face[key]
		actor.face.set(key,Vector2(value[0],value[1]) if value is Array else value)
	var values: Dictionary={}
	for key in (FACE_NEMI if author=="nemi" else FACE_ADB):
		values[key]=actor.face.get(key)
	return values

func sample(actor: Node2D, author: String, cues: Array, time: float) -> void:
	var index := 0
	for i in range(cues.size()):
		if float(cues[i].at)<=time: index=i
	var cue: Dictionary=cues[index]
	# Caption boundaries do not drive motion. Each thought selects its cadence.
	var motion: String=cue.get("motion","smooth")
	if motion=="stepped":
		var fps: float=cue.get("step_fps",12)
		time=float(cue.at)+floorf((time-float(cue.at))*fps)/fps
	if motion=="snap":
		cues=cues.duplicate(true)
		cues[index]["duration"]=0.0
		cue=cues[index]
	var old_cue: Dictionary=cues[maxi(0,index-1)]
	var catalog: Dictionary=Base.recipes()[author]
	var current: Dictionary=catalog[cue.recipe].duplicate(true)
	var previous: Dictionary=catalog[old_cue.recipe].duplicate(true)
	current.face.merge(cue.get("face",{}),true)
	previous.face.merge(old_cue.get("face",{}),true)
	Base.sample(actor,author,cues,time)
	if author=="nemi":
		# Bounded hand paths rotate the wrist globally. Restore its canonical
		# local rest before each sample so that rotation cannot leak into later
		# recipe-owned gestures after path ownership ends.
		actor.left_hand_bone.rotation=actor.left_hand_bone.get_rest().get_rotation()
		actor.right_hand_bone.rotation=actor.right_hand_bone.get_rest().get_rotation()
	var duration: float=cue.get("duration",current.duration) if index>0 else 0.0
	var elapsed: float=time-float(cue.at)
	var body_t := Base.amount(elapsed,duration,0.15)
	var arm_t := Base.amount(elapsed,duration,0.38)
	# Upper arm initiates, forearm/wrist arrive later. Avoid moving every joint
	# with one interpolation value as if the arm were a rigid lever.
	var pose_a: Dictionary=NP.get_pose(previous.pose) if author=="nemi" else AP.get_pose(previous.pose)
	var pose_b: Dictionary=NP.get_pose(current.pose) if author=="nemi" else AP.get_pose(current.pose)
	if author=="nemi":
		for key in Base.NEMI_BONES:
			if "arm" in key:
				var delay := 0.28 if "upper" in key else 0.48
				actor.get(Base.NEMI_BONES[key]).rotation=lerpf(pose_a.get(key,0.0),pose_b.get(key,0.0),Base.amount(elapsed,duration,delay))
	else:
		for key in ["left_elbow","right_elbow","left_hand","right_hand"]:
			actor.set(key,Base.blend(pose_a.get(key,Vector2.ZERO),pose_b.get(key,Vector2.ZERO),Base.amount(elapsed,duration,0.28 if "elbow" in key else 0.48)))
	# Eyes orient first; expression softens over 120ms before the hands commit.
	var a := face_recipe(actor,author,previous)
	var b := face_recipe(actor,author,current)
	var face_t := Base.amount(elapsed,minf(duration,0.12),0.0)
	for key in b:
		actor.face.set(key,Base.blend(a[key],b[key],face_t))
	var gaze_a: Array=old_cue.get("gaze",previous.gaze)
	var gaze_b: Array=cue.get("gaze",current.gaze)
	actor.face.set("gaze_direction" if author=="nemi" else "eye_gaze",Vector2(gaze_a[0],gaze_a[1]).lerp(Vector2(gaze_b[0],gaze_b[1]),Base.amount(elapsed,minf(duration,0.09),0)))
	# Optional externally authored refinements; no library/rig edits.
	var tweaks_a: Dictionary=previous.get("controls",{})
	var tweaks_b: Dictionary=current.get("controls",{})
	var keys: Dictionary={}
	for key in tweaks_a: keys[key]=true
	for key in tweaks_b: keys[key]=true
	for key in keys:
		var va: Variant=tweaks_a.get(key,[0,0] if tweaks_b.get(key) is Array else 0)
		var vb: Variant=tweaks_b.get(key,[0,0] if va is Array else 0)
		if va is Array: va=Vector2(va[0],va[1])
		if vb is Array: vb=Vector2(vb[0],vb[1])
		var t := arm_t if "arm" in key or "hand" in key or "elbow" in key else body_t
		var value: Variant=Base.blend(va,vb,t)
		if author=="nemi":
			if key=="root_offset": actor.root_bone.position+=value
			else: actor.get(Base.NEMI_BONES[key]).rotation+=deg_to_rad(float(value))
		else: actor.set(key,actor.get(key)+value)
	# One bounded gesture arc, followed by a settle. No endless oscillation.
	var u := clampf(elapsed/maxf(duration,0.001),0.0,1.0)
	var arc := sin(PI*u)*sin(PI*u) if duration>0 and index>0 else 0.0
	var strength: float=current.get("gesture_arc",0.0)
	if author=="nemi": actor.right_lower_arm_bone.rotation+=deg_to_rad(strength*arc)
	else: actor.right_hand+=Vector2(0,-strength*arc)
	# Hand shape changes during travel, not before the arm begins to move.
	var hand_cue: Dictionary=cue if arm_t>=0.55 else old_cue
	var pose: Dictionary=(NP.get_pose(current.pose) if author=="nemi" else AP.get_pose(current.pose)) if arm_t>=0.55 else (NP.get_pose(previous.pose) if author=="nemi" else AP.get_pose(previous.pose))
	for side in ["left","right"]:
		if author=="nemi":
			actor.get(side+"_hand_visual").hand_pose=pose.get(side+"_hand_pose",0)
			if hand_cue.get("hands",{}).has(side): actor.set_hand_pose(side=="left",hand_cue.hands[side])
		else:
			actor.get(side+"_hand_node").set_hand_type(hand_cue.get("hands",{}).get(side,pose.get(side+"_hand_type","relaxed")))
	if cue.get("grounded",true): plant_feet(actor,author)
	for at in cue.get("blinks",[]):
		var phase := (time-float(at))/0.14
		if phase>=0 and phase<=1:
			var openness: float=current.eyes*absf(phase*2-1)
			if author=="nemi": actor.set_eye_openness(openness)
			else:
				actor.face.eye_openness_left=openness
				actor.face.eye_openness_right=openness
	if author=="adb": sync_adb(actor)
	actor.face.queue_redraw()
	actor.queue_redraw()

func plant_feet(actor: Node2D, author: String) -> void:
	var feet: Dictionary=anchors[actor.get_instance_id()]
	if author=="nemi":
		# Lower the pelvis only as needed to keep both targets within reach.
		# A straight interpolated leg otherwise pulls its shoe off the floor.
		for side in ["left","right"]:
			var thigh: Bone2D=actor.get(side+"_thigh_bone")
			var shin: Bone2D=actor.get(side+"_shin_bone")
			var foot: Bone2D=actor.get(side+"_foot_bone")
			var reach := shin.position.length()+foot.position.length()-0.02
			var dx: float=feet[side].x-actor.root_bone.position.x-thigh.position.x
			var vertical := sqrt(maxf(0.01,reach*reach-dx*dx))
			actor.root_bone.position.y=maxf(actor.root_bone.position.y,feet[side].y-thigh.position.y-vertical)
	for side in ["left","right"]:
		if author=="nemi":
			var thigh: Bone2D=actor.get(side+"_thigh_bone")
			var shin: Bone2D=actor.get(side+"_shin_bone")
			var foot: Bone2D=actor.get(side+"_foot_bone")
			var target: Vector2=actor.root_bone.to_local(actor.to_global(feet[side]))-thigh.position
			var l1 := shin.position.length()
			var l2 := foot.position.length()
			var distance := clampf(target.length(),absf(l1-l2)+0.01,l1+l2-0.01)
			var hip_angle := acos(clampf((l1*l1+distance*distance-l2*l2)/(2*l1*distance),-1,1))
			var knee_angle := PI-acos(clampf((l1*l1+l2*l2-distance*distance)/(2*l1*l2),-1,1))
			var bend := 1.0 # consistent knee direction keeps the silhouette relaxed
			thigh.rotation=target.angle()-PI*0.5-bend*hip_angle
			shin.rotation=bend*knee_angle
			foot.rotation=actor.global_rotation-shin.global_rotation
		else:
			var base_x := -22.0 if side=="left" else 22.0
			var lean: float=actor.get(side+"_leg_lean")
			actor.set(side+"_foot_offset",feet[side]-actor.pelvis_offset-Vector2(base_x+lean,178))
			actor.set(side+"_knee_bend",float(actor.get(side+"_knee_bend"))-actor.pelvis_offset.x*0.3)

static func sync_adb(actor: Node2D) -> void:
	actor.face.position=actor.head_offset
	actor.face.rotation_degrees=actor.head_tilt
	actor.left_shoulder=actor.get_shoulder_pos(false)
	actor.right_shoulder=actor.get_shoulder_pos(true)
	for side in ["left","right"]:
		var node: Node2D=actor.get(side+"_hand_node")
		var hand: Vector2=actor.get(side+"_hand")
		var elbow: Vector2=actor.get(side+"_elbow")
		node.position=hand
		node.rotation=(hand-elbow).angle()-PI*0.5
