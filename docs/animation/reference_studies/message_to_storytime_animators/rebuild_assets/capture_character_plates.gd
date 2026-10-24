extends SceneTree

## Character-only asset capture for the externally composited edit rebuild.
## Uses existing canonical rigs and their supported controls. No final edit here.
const NEMI_SCENE = preload("res://nemi/characters/nemi/nemi.tscn")
const ADB_SCENE = preload("res://adb/characters/adb/ADB.tscn")
const ACTING = preload("res://common/storytime/production/ActingTimeline.gd")
const PERFORMANCE = preload("res://common/storytime/PerformancePlayer.gd")
const NP = preload("res://nemi/characters/nemi/NemiPose.gd")
const AP = preload("res://adb/poses/ADBPoseLibrary.gd")
const OUT = "res://renders/message_to_storytime_rebuild/character_plates/"
var vp: SubViewport
var anchor_data: Dictionary = {"canvas":[2000,2200],"rig_scale":4.5,"rig_origin":[1000,1100],"authors":{}}

func _init() -> void:
	call_deferred("capture")

func capture() -> void:
	vp = SubViewport.new()
	vp.size = Vector2i(2000, 2200)
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var all_recipes = {}
	var motions_only = "--motions-only" in OS.get_cmdline_user_args()
	for author in ["nemi", "adb"]:
		DirAccess.make_dir_recursive_absolute(OUT + author)
		anchor_data.authors[author]={}
		var recipes = {}
		for pose_id in range(1, 11):
			var actor = (NEMI_SCENE if author == "nemi" else ADB_SCENE).instantiate()
			vp.add_child(actor)
			actor.set_process(false)
			actor.position = Vector2(1000, 1100)
			actor.scale = Vector2(4.5, 4.5)
			await process_frame
			if author == "nemi":
				pose_nemi(actor, pose_id)
			else:
				pose_adb(actor, pose_id)
				reapply_adb_nodes(actor)
			recipes[pose_id] = recipe_from_actor(actor, author, pose_id)
			anchor_data.authors[author]["%02d_%s"%[pose_id,pose_name(pose_id)]]=get_anchors(actor,author)
			if motions_only:
				actor.queue_free()
				await process_frame
				continue
			for mouth in ["closed", "open", "wide"]:
				if author == "nemi":
					actor.set_mouth_shape(("neutral" if pose_id == 6 else "smirk") if mouth == "closed" else ("small_open" if mouth == "open" else "open_excited"))
				else:
					actor.set_mouth(("deadpan" if pose_id == 6 else "smirk") if mouth == "closed" else ("talk_open" if mouth == "open" else "talk_wide"))
				for f in range(2):
					await process_frame
				RenderingServer.force_draw.call_deferred(false,1.0/30.0)
				await process_frame
				var path = OUT + author + "/%02d_%s_%s.png" % [pose_id, pose_name(pose_id), mouth]
				var err = vp.get_texture().get_image().save_png(path)
				print("PLATE ", path, " ", err)
			if pose_id in [7,8,9]:
				hide_except_hands(actor,author)
				for f in range(2): await process_frame
				RenderingServer.force_draw.call_deferred(false,1.0/30.0)
				await process_frame
				vp.get_texture().get_image().save_png(OUT+author+"/%02d_%s_hands.png"%[pose_id,pose_name(pose_id)])
			actor.queue_free()
			await process_frame
		all_recipes[author]=recipes
		FileAccess.open(OUT+"anchors.json",FileAccess.WRITE).store_string(JSON.stringify(anchor_data,"\t"))
	for author in ["nemi","adb"]:
		await capture_motions(author, all_recipes[author])
	print("CHARACTER_PLATES_COMPLETE")
	quit(0)

func pose_name(id: int) -> String:
	return ["", "direct_confident", "lean_smug", "wide_bravado", "challenge_point", "self_presentation", "dry_payoff", "clutch_sketchbook", "hoist_trophy", "chin_thought", "proud_behind_back"][id]

func pose_nemi(actor: Nemi, id: int) -> void:
	var poses = ["", "deadpan_freeze", "arms_folded", "palms_up_what", "exaggerated_pointing", "excited", "deadpan_freeze", "deadpan_freeze", "deadpan_freeze", "deadpan_freeze", "deadpan_freeze"]
	actor.set_pose(poses[id], 0.0)
	actor.set_expression("deadpan" if id == 6 else "smug")
	actor.face.gaze_direction = Vector2.ZERO
	actor.face.show_sparkles = false
	actor.face.show_blush = false
	actor.face.eye_openness = 0.68 if id in [1, 2, 3] else 0.95
	if id in [1,2,3,7,10]:
		actor.face.right_brow_offset.y = -8
	if id == 1:
		actor.head_bone.rotation_degrees = -3
		actor.torso_bone.rotation_degrees = 2
	elif id == 2:
		actor.torso_bone.rotation_degrees = 6
		actor.neck_bone.rotation_degrees = -4
		actor.head_bone.rotation_degrees = -2
		actor.face.left_brow_offset.y = -1
		actor.face.right_brow_offset.y = -7
	elif id == 3:
		actor.set_arm(true, 62, 33, "open_palm_up")
		actor.set_arm(false, -58, -37, "open_palm_up")
		actor.head_bone.rotation_degrees = 0
	elif id == 4:
		actor.set_arm(true, 8, 12, "relaxed")
		actor.set_arm(false, -70, -12, "pointing")
		actor.face.left_brow_offset.y = 2
		actor.face.right_brow_offset.y = 2
		actor.face.left_brow_tilt = -0.2
		actor.face.right_brow_tilt = 0.2
	elif id == 5:
		actor.set_arm(true, 142, 20, "fist")
		actor.set_arm(false, -26, -42, "open_palm_up")
		actor.face.eye_openness = 1.05
		actor.face.left_brow_offset.y = -5
		actor.face.right_brow_offset.y = -5
	elif id == 6:
		actor.face.eye_openness = 0.55
		actor.face.show_blush = false
	elif id == 7:
		set_nemi_hand(actor, true, Vector2(-36,-34), "hold_prop")
		set_nemi_hand(actor, false, Vector2(36,-34), "hold_prop")
		actor.face.eye_openness = 0.88
	elif id == 8:
		set_nemi_hand(actor, true, Vector2(-85,-180), "open_palm_up")
		set_nemi_hand(actor, false, Vector2(85,-180), "open_palm_up")
		actor.face.eye_openness = 1.05
	elif id == 9:
		set_nemi_hand(actor, false, Vector2(24,-82), "hand_to_cheek")
		actor.face.gaze_direction = Vector2(-0.6,-0.1)
		actor.face.right_brow_offset.y = -7
		actor.face.eye_openness = 0.8
	elif id == 10:
		actor.set_arm(true, -15, -100, "relaxed")
		actor.set_arm(false, 15, 100, "relaxed")
		actor.left_upper_arm_bone.z_index = -1
		actor.right_upper_arm_bone.z_index = -1
		actor.head_bone.rotation_degrees = -3
		actor.face.eye_openness = 0.88

func pose_adb(actor: ADB, id: int) -> void:
	var poses = ["", "relaxed_standing", "annoyed", "open_palms", "pointing", "pointing_up", "deadpan_freeze", "relaxed_standing", "relaxed_standing", "relaxed_standing", "relaxed_standing"]
	actor.set_pose(poses[id], 0.0)
	actor.set_expression("deadpan" if id == 6 else ("determined" if id == 4 else "smug"), 0.0)
	actor.look("camera")
	actor.set_blush(0.0, 0.0)
	if id in [1,2,3,7,10]:
		actor.face.eye_openness_left = 0.67
		actor.face.eye_openness_right = 0.73
	if id == 1:
		actor.head_tilt = -3
		actor.torso_tilt = 2
	elif id == 2:
		actor.torso_tilt = 5
		actor.head_offset.x = 7
		actor.head_tilt = -3
	elif id == 3:
		actor.torso_tilt = 0
		actor.head_tilt = 0
		set_adb_hand(actor, true, Vector2(-159, -76), "open_palm")
		set_adb_hand(actor, false, Vector2(159, -76), "open_palm")
	elif id == 4:
		actor.torso_tilt = 5
		actor.head_tilt = -2
		actor.head_offset.x = 6
	elif id == 5:
		actor.head_tilt = -4
		actor.face.eye_openness_left = 1.04
		actor.face.eye_openness_right = 1.04
		actor.face.brow_left_height = 4
		actor.face.brow_right_height = 4
	elif id == 7:
		set_adb_hand(actor, true, Vector2(-37,-34), "open_palm")
		set_adb_hand(actor, false, Vector2(37,-34), "open_palm")
	elif id == 8:
		set_adb_hand(actor, true, Vector2(-87,-177), "open_palm")
		set_adb_hand(actor, false, Vector2(87,-177), "open_palm")
		actor.face.eye_openness_left = 1.04
		actor.face.eye_openness_right = 1.04
	elif id == 9:
		set_adb_hand(actor, false, Vector2(20,-88), "hand_to_chin")
		actor.head_tilt = -4
		actor.face.eye_gaze = Vector2(-0.6,-0.2)
	elif id == 10:
		set_adb_hand(actor, true, Vector2(-30,15), "relaxed")
		set_adb_hand(actor, false, Vector2(30,15), "relaxed")
		actor.head_tilt = -3
	actor.queue_redraw()

func set_adb_hand(actor: ADB, left: bool, target: Vector2, hand: String) -> void:
	# Fixed canonical 58/55 local-unit arm lengths; elbow placed by two-bone IK.
	var shoulder = actor.get_shoulder_pos(not left)
	var delta = target - shoulder
	var distance = minf(delta.length(), 112.9)
	var direction = delta.normalized()
	var along = (58.0 * 58.0 - 55.0 * 55.0 + distance * distance) / (2.0 * distance)
	var height = sqrt(maxf(0.0, 58.0 * 58.0 - along * along))
	var normal = Vector2(-direction.y, direction.x) * (-1 if left else 1)
	var elbow = shoulder + direction * along + normal * height
	if left:
		actor.left_elbow = elbow
		actor.left_hand = shoulder + direction * distance
		actor.left_hand_node.set_hand_type(hand)
	else:
		actor.right_elbow = elbow
		actor.right_hand = shoulder + direction * distance
		actor.right_hand_node.set_hand_type(hand)

func set_nemi_hand(actor: Nemi, left: bool, target: Vector2, hand: String) -> void:
	var upper: Bone2D = actor.left_upper_arm_bone if left else actor.right_upper_arm_bone
	var lower: Bone2D = actor.left_lower_arm_bone if left else actor.right_lower_arm_bone
	var wrist: Bone2D = actor.left_hand_bone if left else actor.right_hand_bone
	var shoulder = actor.to_local(upper.global_position)
	var l1 = lower.position.length()
	var l2 = wrist.position.length()
	var delta = target - shoulder
	var d = clampf(delta.length(), absf(l1-l2)+0.01,l1+l2-0.01)
	var along = (l1*l1-l2*l2+d*d)/(2*d)
	var normal = Vector2(-delta.normalized().y,delta.normalized().x)*(1 if left else -1)
	var elbow = shoulder+delta.normalized()*along+normal*sqrt(maxf(0,l1*l1-along*along))
	var global_upper = (elbow-shoulder).angle()-PI/2
	var parent_rot = upper.get_parent().global_rotation-actor.global_rotation
	var global_lower = (target-elbow).angle()-PI/2
	actor.set_arm(left,wrapf(rad_to_deg(global_upper-parent_rot),-180,180),wrapf(rad_to_deg(global_lower-global_upper),-180,180),hand)

func reapply_adb_nodes(actor: ADB) -> void:
	actor.face.scale = Vector2.ONE * actor.HEAD_SCALE
	ACTING.sync_adb(actor)
	actor.face.queue_redraw()
	actor.queue_redraw()

func recipe_from_actor(actor: Node2D, author: String, id: int) -> Dictionary:
	var recipe = {"pose":"deadpan_freeze", "expression":"deadpan" if id==6 else "smug", "eyes":0.85,"gaze":[0.0,0.0],"face":{},"controls":{},"head_degrees":0.0,"duration":0.38,"gesture_arc":0.0}
	if author=="nemi":
		var baseline = NP.get_pose("deadpan_freeze")
		for key in PERFORMANCE.NEMI_BONES:
			recipe.controls[key]=rad_to_deg(actor.get(PERFORMANCE.NEMI_BONES[key]).rotation-float(baseline.get(key,0.0)))
		recipe.controls.root_offset=[actor.root_bone.position.x,actor.root_bone.position.y]
		recipe.eyes=actor.face.eye_openness
		recipe.gaze=[actor.face.gaze_direction.x,actor.face.gaze_direction.y]
		for key in ACTING.FACE_NEMI:
			var value = actor.face.get(key)
			recipe.face[key]=[value.x,value.y] if value is Vector2 else value
		recipe.hands={"left":actor.left_hand_visual.hand_pose,"right":actor.right_hand_visual.hand_pose}
	else:
		var baseline = AP.get_pose("deadpan_freeze")
		for key in PERFORMANCE.ADB_CONTROLS:
			var baseline_value = baseline.get(key,Vector2.ZERO if "offset" in key or "elbow" in key or "hand" in key else 0.0)
			var value = actor.get(key)-baseline_value
			recipe.controls[key]=[value.x,value.y] if value is Vector2 else value
		recipe.eyes=actor.face.eye_openness_left
		recipe.gaze=[actor.face.eye_gaze.x,actor.face.eye_gaze.y]
		for key in ACTING.FACE_ADB:
			var value = actor.face.get(key)
			recipe.face[key]=[value.x,value.y] if value is Vector2 else value
		recipe.hands={"left":actor.left_hand_node.current_hand_type,"right":actor.right_hand_node.current_hand_type}
	PERFORMANCE.recipes()[author]["edit_plate_%02d"%id]=recipe
	return recipe

func capture_motions(author: String, recipes: Dictionary) -> void:
	var actor = (NEMI_SCENE if author=="nemi" else ADB_SCENE).instantiate()
	vp.add_child(actor)
	actor.set_process(false)
	actor.position=Vector2(1000,1100)
	actor.scale=Vector2.ONE*4.5
	await process_frame
	var timeline=ACTING.new()
	timeline.bind(actor,author)
	var pairs=[[1,3],[3,4],[4,7],[7,8],[8,6],[1,9]]
	for pair in pairs:
		var name="motion_%02d_to_%02d"%[pair[0],pair[1]]
		DirAccess.make_dir_recursive_absolute(OUT+author+"/"+name)
		var cues=[{"at":0.0,"recipe":"edit_plate_%02d"%pair[0],"hands":recipes[pair[0]].hands},{"at":0.001,"recipe":"edit_plate_%02d"%pair[1],"duration":0.4,"hands":recipes[pair[1]].hands}]
		var frame_anchors=[]
		for i in range(12):
			timeline.sample(actor,author,cues,0.001+0.4*float(i)/11.0)
			if author=="nemi":
				actor.face.show_sparkles=false
				actor.face.show_blush=false
				actor.set_mouth_shape("neutral" if pair[1]==6 else "smirk")
			else:
				actor.set_mouth("deadpan" if pair[1]==6 else "smirk")
				reapply_adb_nodes(actor)
			for f in range(2):
				await process_frame
			RenderingServer.force_draw.call_deferred(false,1.0/30.0)
			await process_frame
			var path=OUT+author+"/"+name+"/%03d.png"%i
			vp.get_texture().get_image().save_png(path)
			frame_anchors.append({"frame":i,"time":0.4*float(i)/11.0,"anchors":get_anchors(actor,author)})
		FileAccess.open(OUT+author+"/"+name+"/anchors.json",FileAccess.WRITE).store_string(JSON.stringify(frame_anchors,"\t"))
		print("MOTION ",author," ",name)
	actor.queue_free()
	await process_frame

func get_anchors(actor: Node2D, author: String) -> Dictionary:
	var l: Node2D=actor.left_hand_visual if author=="nemi" else actor.left_hand_node
	var r: Node2D=actor.right_hand_visual if author=="nemi" else actor.right_hand_node
	var a=l.global_position
	var b=r.global_position
	var ap=l.to_global(Vector2(0,10))
	var bp=r.to_global(Vector2(0,10))
	var chin=actor.face.global_position
	var top=actor.face.to_global(Vector2(0,-138))
	return {"left_wrist":[a.x,a.y],"right_wrist":[b.x,b.y],"left_palm":[ap.x,ap.y],"right_palm":[bp.x,bp.y],"left_hand_rotation_degrees":l.global_rotation_degrees,"right_hand_rotation_degrees":r.global_rotation_degrees,"chin":[chin.x,chin.y],"head_top_approx":[top.x,top.y]}

func hide_except_hands(actor: Node2D, author: String) -> void:
	if author=="adb":
		actor.self_modulate=Color(1,1,1,0)
		actor.face.visible=false
	else:
		hide_nemi_parts(actor,actor.left_hand_visual,actor.right_hand_visual)

func hide_nemi_parts(node: Node, left: Node, right: Node) -> void:
	if node is NemiPart and node!=left and node!=right: node.visible=false
	for child in node.get_children(): hide_nemi_parts(child,left,right)
