extends RefCounted
## Authored actor-local hand contacts through existing controls; no rig changes.
const Motion=preload("res://common/storytime/production/Motion.gd")
const Acting=preload("res://common/storytime/production/ActingTimeline.gd")
static func sample(actor: Node2D, author: String, paths: Dictionary, time: float) -> void:
	for side in paths:
		var path: Array=paths[side]
		var target := Motion.point(path,time)
		if author=="nemi":
			var upper: Bone2D=actor.get(side+"_upper_arm_bone")
			var lower: Bone2D=actor.get(side+"_lower_arm_bone")
			var hand: Bone2D=actor.get(side+"_hand_bone")
			var delta: Vector2=upper.get_parent().to_local(actor.to_global(target))-upper.position
			var l1 := lower.position.length()
			var l2 := hand.position.length()
			var distance := clampf(delta.length(),absf(l1-l2)+0.01,l1+l2-0.01)
			var shoulder := acos(clampf((l1*l1+distance*distance-l2*l2)/(2*l1*distance),-1,1))
			var elbow := PI-acos(clampf((l1*l1+l2*l2-distance*distance)/(2*l1*l2),-1,1))
			var direction := -1.0 if side=="right" else 1.0
			upper.rotation=delta.angle()-PI*.5-direction*shoulder
			lower.rotation=direction*elbow
			hand.global_rotation=actor.global_rotation+deg_to_rad(Motion.scalar(path,time,"angle",0))
		else:
			var shoulder: Vector2=actor.get_shoulder_pos(side=="right")
			var delta := target-shoulder
			var middle := shoulder+delta*.5
			var normal := Vector2(-delta.y,delta.x).normalized()
			actor.set(side+"_hand",target)
			actor.set(side+"_elbow",middle+normal*(24.0 if side=="right" else -24.0))
	if author=="adb":
		Acting.sync_adb(actor)
		for side in paths:
			actor.get(side+"_hand_node").rotation_degrees=Motion.scalar(paths[side],time,"angle",0)
	actor.queue_redraw()
