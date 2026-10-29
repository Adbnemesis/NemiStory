extends RefCounted
## External, seekable acting recipes. Never edits character definitions.
const NemiPoses = preload("res://nemi/characters/nemi/NemiPose.gd")
const AdbPoses = preload("res://adb/poses/ADBPoseLibrary.gd")
static var _recipes: Dictionary = {}
const NEMI_BONES := {
	"torso_rot":"torso_bone", "neck_rot":"neck_bone", "head_rot":"head_bone", "skirt_rot":"skirt_bone",
	"left_upper_arm_rot":"left_upper_arm_bone", "left_lower_arm_rot":"left_lower_arm_bone",
	"right_upper_arm_rot":"right_upper_arm_bone", "right_lower_arm_rot":"right_lower_arm_bone",
	"left_thigh_rot":"left_thigh_bone", "left_shin_rot":"left_shin_bone", "left_foot_rot":"left_foot_bone",
	"right_thigh_rot":"right_thigh_bone", "right_shin_rot":"right_shin_bone", "right_foot_rot":"right_foot_bone"}
const ADB_CONTROLS := ["torso_offset","torso_tilt","head_offset","head_tilt","pelvis_offset",
	"left_elbow","left_hand","right_elbow","right_hand","left_leg_lean","right_leg_lean",
	"left_foot_offset","right_foot_offset","left_knee_bend","right_knee_bend"]

static func recipes() -> Dictionary:
	if _recipes.is_empty():
		_recipes = JSON.parse_string(FileAccess.get_file_as_string("res://common/storytime/performances/recipes.json"))
	return _recipes

static func amount(elapsed: float, duration: float, delay: float) -> float:
	if duration <= 0.0:
		return 1.0
	var u := clampf((elapsed-duration*delay)/maxf(0.001,duration*(1.0-delay)),0.0,1.0)
	return u*u*(3.0-2.0*u)

static func blend(a: Variant, b: Variant, t: float) -> Variant:
	if a is Vector2 and b is Vector2:
		return a.lerp(b,t)
	return lerpf(float(a),float(b),t)

static func sample(actor: Node2D, author: String, cues: Array, time: float) -> void:
	assert(not cues.is_empty(), "Each actor needs an initial performance cue at time 0")
	var catalog: Dictionary = recipes()[author]
	var index := 0
	for i in range(cues.size()):
		if time >= float(cues[i].at):
			index=i
	var cue: Dictionary = cues[index]
	var current: Dictionary = catalog[cue.recipe]
	var previous: Dictionary = catalog[cues[maxi(0,index-1)].recipe]
	var elapsed := time-float(cue.at)
	var duration: float = cue.get("duration",current.duration) if index>0 else 0.0
	var body_t := amount(elapsed,duration,0.15)
	var head_t := amount(elapsed,duration,0.25)
	var arm_t := amount(elapsed,duration,0.38)
	# Feet stay on their authored stance; translation of the actor's root is
	# deliberately excluded. Use a separate blocked action for walking.
	actor.set_pose(current.pose,0.0)
	if author=="nemi":
		var a: Dictionary = NemiPoses.get_pose(previous.pose)
		var b: Dictionary = NemiPoses.get_pose(current.pose)
		for key in NEMI_BONES:
			var bone = actor.get(NEMI_BONES[key])
			if is_instance_valid(bone):
				var t := arm_t if "arm" in key else (head_t if "head" in key or "neck" in key else body_t)
				bone.rotation = lerpf(float(a.get(key,0.0)),float(b.get(key,0.0)),t)
		actor.root_bone.position = Vector2(a.get("root_offset",Vector2.ZERO)).lerp(b.get("root_offset",Vector2.ZERO),body_t)
		actor.head_bone.rotation += deg_to_rad(lerpf(previous.head_degrees,current.head_degrees,head_t))
		actor.set_expression(current.expression)
		actor.set_eye_openness(current.eyes)
		actor.look_at_direction(Vector2(current.gaze[0],current.gaze[1]))
	else:
		var a: Dictionary = AdbPoses.get_pose(previous.pose)
		var b: Dictionary = AdbPoses.get_pose(current.pose)
		for key in ADB_CONTROLS:
			var default_value: Variant = Vector2.ZERO if "offset" in key or "elbow" in key or "hand" in key else 0.0
			var t := arm_t if "hand" in key or "elbow" in key else (head_t if "head" in key else body_t)
			actor.set(key,blend(a.get(key,default_value),b.get(key,default_value),t))
		actor.head_tilt += lerpf(previous.head_degrees,current.head_degrees,head_t)
		actor.set_expression(current.expression,0.0)
		actor.face.eye_openness_left=current.eyes
		actor.face.eye_openness_right=current.eyes
		actor.face.look_at_direction(Vector2(current.gaze[0],current.gaze[1]))
	for key in current.face:
		var value: Variant = current.face[key]
		if value is Array:
			value = Vector2(value[0],value[1])
		actor.face.set(key,value)
	# Explicit blinks avoid timer/randomness, respect holds, and support seeking.
	for at in cue.get("blinks",[]):
		var phase := (time-float(at))/0.14
		if phase>=0.0 and phase<=1.0:
			var openness: float = current.eyes*absf(phase*2.0-1.0)
			if author=="nemi": actor.set_eye_openness(openness)
			else:
				actor.face.eye_openness_left=openness
				actor.face.eye_openness_right=openness
	# Deterministic follow-through from the authored head transition, not FPS.
	var lag_t := amount(elapsed-0.055,duration,0.25) if index>0 else head_t
	var head_delta := float(current.head_degrees)-float(previous.head_degrees)
	if author=="nemi":
		var sway := deg_to_rad(head_delta*(lag_t-head_t)*0.6)
		actor.hair_left_bone.rotation += sway
		actor.hair_right_bone.rotation += sway
		actor.hair_back_bone.rotation += sway*0.65
	else:
		actor.set("_hair_sway",head_delta*(lag_t-head_t)*0.6)
		actor.face.scale=Vector2.ONE*actor.HEAD_SCALE
		actor.face.position=actor.head_offset
		actor.face.rotation_degrees=actor.head_tilt
		actor.left_shoulder=actor.get_shoulder_pos(false)
		actor.right_shoulder=actor.get_shoulder_pos(true)
		for side in ["left","right"]:
			var hand_node = actor.get(side+"_hand_node")
			var hand: Vector2 = actor.get(side+"_hand")
			var elbow: Vector2 = actor.get(side+"_elbow")
			hand_node.position=hand
			hand_node.rotation=(hand-elbow).angle()-PI*0.5
	actor.face.queue_redraw()
	actor.queue_redraw()
