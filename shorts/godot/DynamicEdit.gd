extends "res://shorts/godot/BatchEdit.gd"
## Version 3: authored body/face motion, finite camera follow and drawn event paths.
const DynamicArt = preload("res://shorts/godot/DynamicPoseArt.gd")
const DynamicAccents = preload("res://shorts/godot/DynamicAccentArt.gd")
var dynamic_ready := false
var motion_tracks: Dictionary = {}

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
		drawing.rotation = 0
		drawing.head_angle = m.head
		drawing.look_x = m.look
		drawing.eye_open = m.eyes
		drawing.torso_lean = m.lean
		drawing.pose_progress = m.gesture
		drawing.queue_redraw()
