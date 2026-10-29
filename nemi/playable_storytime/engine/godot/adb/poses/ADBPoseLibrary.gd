class_name ADBPoseLibrary
extends RefCounted

## Master Pose Catalog for ADB Character
## Provides canonical spatial configurations for 25+ storytime acting poses.

static func get_pose(pose_name: String) -> Dictionary:
	var raw := _get_raw_pose(pose_name)
	return _calibrate_pose(raw)

static func _calibrate_pose(p: Dictionary) -> Dictionary:
	if p.is_empty():
		return p
	var res := p.duplicate()
	# Only offset legacy poses where torso_offset was defined near -60
	if res.has("torso_offset") and res["torso_offset"].y < -30:
		res["torso_offset"] = res["torso_offset"] + Vector2(0, 60)
		if res.has("head_offset"):
			res["head_offset"] = res["head_offset"] + Vector2(0, 36)
		if res.has("left_shoulder"):
			res["left_shoulder"] = res["left_shoulder"] + Vector2(-6, 40)
		if res.has("right_shoulder"):
			res["right_shoulder"] = res["right_shoulder"] + Vector2(6, 40)
		if res.has("left_elbow"):
			res["left_elbow"] = res["left_elbow"] + Vector2(-4, 40)
		if res.has("right_elbow"):
			res["right_elbow"] = res["right_elbow"] + Vector2(4, 40)
		if res.has("left_hand"):
			res["left_hand"] = res["left_hand"] + Vector2(-4, 45)
		if res.has("right_hand"):
			res["right_hand"] = res["right_hand"] + Vector2(4, 45)
	
	# Calibrate canonical head_offset: shift down to natural storytime neck level (-106)
	if res.has("head_offset") and res["head_offset"].y < -120:
		res["head_offset"] = res["head_offset"] + Vector2(0, 36)
		
	return res

static func _get_raw_pose(pose_name: String) -> Dictionary:
	var name_clean := pose_name.to_lower().strip_edges()
	
	match name_clean:
		# --- RELAXED BASELINE POSES (Athletic Broad-Shoulder Proportions) ---
		"relaxed_standing", "neutral", "idle":
			return {
				"torso_offset": Vector2(0, 0),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -142),
				"head_tilt": 0.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-60, -20),
				"left_hand": Vector2(-58, 36),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(60, -20),
				"right_hand": Vector2(58, 36),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"weight_left":
			return {
				"torso_offset": Vector2(-4, 0),
				"torso_tilt": 2.5,
				"head_offset": Vector2(-4, -142),
				"head_tilt": -3.0,
				"left_shoulder": Vector2(-52, -78),
				"left_elbow": Vector2(-60, -18),
				"left_hand": Vector2(-54, 35),
				"right_shoulder": Vector2(52, -78),
				"right_elbow": Vector2(74, -56),
				"right_hand": Vector2(64, -100),
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-6, 0),
				"left_leg_lean": -3.0,
				"right_leg_lean": 2.0,
				"is_seated": false
			}
			
		"weight_right":
			return {
				"torso_offset": Vector2(6, -60),
				"torso_tilt": -3.0,
				"head_offset": Vector2(4, -140),
				"head_tilt": 4.0,
				"left_shoulder": Vector2(-42, -121),
				"left_elbow": Vector2(-48, -62),
				"left_hand": Vector2(-38, -15),
				"right_shoulder": Vector2(50, -115),
				"right_elbow": Vector2(56, -58),
				"right_hand": Vector2(48, -12),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(8, 0),
				"left_leg_lean": -2.0,
				"right_leg_lean": 4.0,
				"is_seated": false
			}
			
		"casual_slouch":
			return {
				"torso_offset": Vector2(0, -54),
				"torso_tilt": -4.0,
				"head_offset": Vector2(-2, -132),
				"head_tilt": 6.0,
				"left_shoulder": Vector2(-44, -110),
				"left_elbow": Vector2(-50, -55),
				"left_hand": Vector2(-36, -2),
				"right_shoulder": Vector2(44, -110),
				"right_elbow": Vector2(50, -55),
				"right_hand": Vector2(36, -2),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 6),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"seated_chair":
			return {
				"torso_offset": Vector2(0, -52),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -134),
				"head_tilt": 0.0,
				"left_shoulder": Vector2(-44, -112),
				"left_elbow": Vector2(-58, -62),
				"left_hand": Vector2(-36, -58),
				"right_shoulder": Vector2(44, -112),
				"right_elbow": Vector2(58, -62),
				"right_hand": Vector2(36, -58),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 48),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": true
			}
			
		"seated_slump":
			return {
				"torso_offset": Vector2(0, -42),
				"torso_tilt": -8.0,
				"head_offset": Vector2(-4, -118),
				"head_tilt": 12.0,
				"left_shoulder": Vector2(-42, -100),
				"left_elbow": Vector2(-52, -45),
				"left_hand": Vector2(-40, 10),
				"right_shoulder": Vector2(42, -100),
				"right_elbow": Vector2(52, -45),
				"right_hand": Vector2(40, 10),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 60),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": true
			}

		# --- CONVERSATIONAL POSES ---
		"explaining":
			return {
				"torso_offset": Vector2(-3, -60),
				"torso_tilt": 2.0,
				"head_offset": Vector2(-2, -140),
				"head_tilt": 5.0,
				"left_shoulder": Vector2(-46, -118),
				"left_elbow": Vector2(-52, -60),
				"left_hand": Vector2(-42, -10),
				"right_shoulder": Vector2(46, -118),
				"right_elbow": Vector2(62, -75),
				"right_hand": Vector2(48, -105), # Hand raised gesturing
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"pointing":
			return {
				"torso_offset": Vector2(-3, 0),
				"torso_tilt": 2.5,
				"head_offset": Vector2(-2, -142),
				"head_tilt": 3.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-60, -20),
				"left_hand": Vector2(-58, 36),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(88, -72),
				"right_hand": Vector2(128, -78),
				"left_hand_type": "relaxed",
				"right_hand_type": "pointing",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"shrug_open":
			return {
				"torso_offset": Vector2(0, -60),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -138),
				"head_tilt": 6.0,
				"left_shoulder": Vector2(-48, -125), # Elevated shoulders
				"left_elbow": Vector2(-65, -80),
				"left_hand": Vector2(-68, -65),
				"right_shoulder": Vector2(48, -125),
				"right_elbow": Vector2(65, -80),
				"right_hand": Vector2(68, -65),
				"left_hand_type": "shrug_open",
				"right_hand_type": "shrug_open",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"open_palms":
			return {
				"torso_offset": Vector2(0, -60),
				"torso_tilt": 3.0,
				"head_offset": Vector2(0, -140),
				"head_tilt": 0.0,
				"left_shoulder": Vector2(-46, -118),
				"left_elbow": Vector2(-58, -75),
				"left_hand": Vector2(-35, -88),
				"right_shoulder": Vector2(46, -118),
				"right_elbow": Vector2(58, -75),
				"right_hand": Vector2(35, -88),
				"left_hand_type": "open_palm",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"hand_near_face":
			return {
				"torso_offset": Vector2(2, -60),
				"torso_tilt": -2.0,
				"head_offset": Vector2(2, -140),
				"head_tilt": 7.0,
				"left_shoulder": Vector2(-46, -118),
				"left_elbow": Vector2(-52, -60),
				"left_hand": Vector2(-42, -10),
				"right_shoulder": Vector2(46, -118),
				"right_elbow": Vector2(52, -88),
				"right_hand": Vector2(18, -135), # Near chin
				"left_hand_type": "relaxed",
				"right_hand_type": "hand_to_chin",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"hand_to_chest":
			return {
				"torso_offset": Vector2(-2, -60),
				"torso_tilt": 2.0,
				"head_offset": Vector2(-2, -140),
				"head_tilt": -3.0,
				"left_shoulder": Vector2(-46, -118),
				"left_elbow": Vector2(-52, -60),
				"left_hand": Vector2(-42, -10),
				"right_shoulder": Vector2(46, -118),
				"right_elbow": Vector2(45, -80),
				"right_hand": Vector2(6, -95), # Hand on heart
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}

		# --- EMOTIONAL POSES ---
		"happy":
			return {
				"torso_offset": Vector2(0, -62),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -142),
				"head_tilt": 4.0,
				"left_shoulder": Vector2(-46, -120),
				"left_elbow": Vector2(-54, -65),
				"left_hand": Vector2(-44, -15),
				"right_shoulder": Vector2(46, -120),
				"right_elbow": Vector2(56, -72),
				"right_hand": Vector2(45, -88),
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"excited":
			return {
				"torso_offset": Vector2(0, -64),
				"torso_tilt": 4.0,
				"head_offset": Vector2(0, -144),
				"head_tilt": 0.0,
				"left_shoulder": Vector2(-48, -124),
				"left_elbow": Vector2(-62, -88),
				"left_hand": Vector2(-48, -120),
				"right_shoulder": Vector2(48, -124),
				"right_elbow": Vector2(62, -88),
				"right_hand": Vector2(48, -120),
				"left_hand_type": "fist",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"embarrassed":
			return {
				"torso_offset": Vector2(3, 0),
				"torso_tilt": -2.5,
				"head_offset": Vector2(5, -140),
				"head_tilt": 8.0, # Head tilted away
				"left_shoulder": Vector2(-52, -78),
				"left_elbow": Vector2(-58, -20),
				"left_hand": Vector2(-52, 35),
				"right_shoulder": Vector2(52, -78),
				"right_elbow": Vector2(68, -76),
				"right_hand": Vector2(36, -118), # Hand near back of neck / cheek
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(3, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 2.0,
				"is_seated": false
			}
			
		"smug":
			return {
				"torso_offset": Vector2(6, -60),
				"torso_tilt": -4.0,
				"head_offset": Vector2(6, -140),
				"head_tilt": 5.0,
				"left_shoulder": Vector2(-42, -118),
				"left_elbow": Vector2(-48, -60),
				"left_hand": Vector2(-38, -10),
				"right_shoulder": Vector2(48, -120),
				"right_elbow": Vector2(60, -78),
				"right_hand": Vector2(52, -102),
				"left_hand_type": "relaxed",
				"right_hand_type": "thumb_up",
				"pelvis_offset": Vector2(6, 0),
				"left_leg_lean": -2.0,
				"right_leg_lean": 4.0,
				"is_seated": false
			}
			
		"annoyed":
			return {
				"torso_offset": Vector2(0, -58),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -138),
				"head_tilt": -5.0,
				"left_shoulder": Vector2(-46, -118),
				"left_elbow": Vector2(-42, -72),
				"left_hand": Vector2(8, -70), # Folded arm
				"right_shoulder": Vector2(46, -118),
				"right_elbow": Vector2(42, -72),
				"right_hand": Vector2(-8, -70), # Crossed arm
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}

		# --- COMEDIC POSES ---
		"deadpan_freeze", "deadpan":
			return {
				"torso_offset": Vector2(0, 0),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -142),
				"head_tilt": 0.0,
				"left_shoulder": Vector2(-52, -78),
				"left_elbow": Vector2(-56, -20),
				"left_hand": Vector2(-50, 35),
				"right_shoulder": Vector2(52, -78),
				"right_elbow": Vector2(56, -20),
				"right_hand": Vector2(50, 35),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"awkward_freeze":
			return {
				"torso_offset": Vector2(-4, -60),
				"torso_tilt": 4.0,
				"head_offset": Vector2(-4, -140),
				"head_tilt": -8.0,
				"left_shoulder": Vector2(-46, -120),
				"left_elbow": Vector2(-58, -75),
				"left_hand": Vector2(-48, -85),
				"right_shoulder": Vector2(46, -116),
				"right_elbow": Vector2(55, -70),
				"right_hand": Vector2(35, -75),
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-4, 0),
				"left_leg_lean": -2.0,
				"right_leg_lean": 2.0,
				"is_seated": false
			}
			
		"facepalm":
			return {
				"torso_offset": Vector2(0, -56),
				"torso_tilt": 5.0,
				"head_offset": Vector2(2, -134),
				"head_tilt": 8.0,
				"left_shoulder": Vector2(-44, -115),
				"left_elbow": Vector2(-50, -58),
				"left_hand": Vector2(-40, -10),
				"right_shoulder": Vector2(46, -118),
				"right_elbow": Vector2(42, -92),
				"right_hand": Vector2(2, -142), # Palm over face
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"recoil":
			return {
				"torso_offset": Vector2(-12, -58),
				"torso_tilt": -10.0,
				"head_offset": Vector2(-16, -136),
				"head_tilt": -6.0,
				"left_shoulder": Vector2(-54, -122),
				"left_elbow": Vector2(-68, -85),
				"left_hand": Vector2(-55, -105), # Defensive hands
				"right_shoulder": Vector2(36, -114),
				"right_elbow": Vector2(48, -80),
				"right_hand": Vector2(35, -100),
				"left_hand_type": "open_palm",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-8, 0),
				"left_leg_lean": -6.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}
			
		"what_shrug":
			return {
				"torso_offset": Vector2(0, -58),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -136),
				"head_tilt": 8.0,
				"left_shoulder": Vector2(-50, -128),
				"left_elbow": Vector2(-70, -85),
				"left_hand": Vector2(-75, -70),
				"right_shoulder": Vector2(50, -128),
				"right_elbow": Vector2(70, -85),
				"right_hand": Vector2(75, -70),
				"left_hand_type": "shrug_open",
				"right_hand_type": "shrug_open",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": 0.0,
				"right_leg_lean": 0.0,
				"is_seated": false
			}

		# --- DYNAMIC ACTION & LOWER BODY ACTING POSES ---
		"stumble_pushed":
			# Dramatic stumble when shoved from screen-right: body pitched back, feet bracing
			return {
				"torso_offset": Vector2(-12, 10),
				"torso_tilt": -12.0,
				"head_offset": Vector2(-14, -135),
				"head_tilt": -8.0,
				"left_shoulder": Vector2(-54, -70),
				"left_elbow": Vector2(-75, -55),
				"left_hand": Vector2(-70, -85),
				"right_shoulder": Vector2(45, -70),
				"right_elbow": Vector2(65, -50),
				"right_hand": Vector2(55, -80),
				"left_hand_type": "open_palm",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-12, 6),
				"left_leg_lean": -14.0,
				"right_leg_lean": 4.0,
				"left_foot_offset": Vector2(-18, 6),
				"right_foot_offset": Vector2(16, -6),
				"left_knee_bend": -12.0,
				"right_knee_bend": 8.0,
				"is_seated": false
			}

		"athletic_ready", "table_tennis_ready":
			# Wide athletic ready stance: knees bent outward, poised forward
			return {
				"torso_offset": Vector2(0, 12),
				"torso_tilt": 6.0,
				"head_offset": Vector2(0, -132),
				"head_tilt": -4.0,
				"left_shoulder": Vector2(-49, -65),
				"left_elbow": Vector2(-65, -20),
				"left_hand": Vector2(-50, -45),
				"right_shoulder": Vector2(49, -65),
				"right_elbow": Vector2(65, -20),
				"right_hand": Vector2(50, -45),
				"left_hand_type": "open_palm",
				"right_hand_type": "fist",
				"pelvis_offset": Vector2(0, 14),
				"left_leg_lean": -6.0,
				"right_leg_lean": 6.0,
				"left_foot_offset": Vector2(-22, 0),
				"right_foot_offset": Vector2(22, 0),
				"left_knee_bend": -12.0,
				"right_knee_bend": 12.0,
				"is_seated": false
			}

		"smash_lunge", "table_tennis_serve":
			# High-power athletic smash lunge forward
			return {
				"torso_offset": Vector2(10, 8),
				"torso_tilt": -8.0,
				"head_offset": Vector2(12, -135),
				"head_tilt": 6.0,
				"left_shoulder": Vector2(-45, -70),
				"left_elbow": Vector2(-60, -45),
				"left_hand": Vector2(-40, -75),
				"right_shoulder": Vector2(52, -70),
				"right_elbow": Vector2(78, -95),
				"right_hand": Vector2(60, -135),
				"left_hand_type": "open_palm",
				"right_hand_type": "fist",
				"pelvis_offset": Vector2(8, 8),
				"left_leg_lean": -4.0,
				"right_leg_lean": 8.0,
				"left_foot_offset": Vector2(-14, 2),
				"right_foot_offset": Vector2(26, -6),
				"left_knee_bend": -14.0,
				"right_knee_bend": 6.0,
				"is_seated": false
			}

		"gym_squat_stance":
			# Solid lifting posture with shoulder-width stance and bent knees
			return {
				"torso_offset": Vector2(0, 6),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -138),
				"head_tilt": 0.0,
				"left_shoulder": Vector2(-50, -74),
				"left_elbow": Vector2(-58, -25),
				"left_hand": Vector2(-52, 25),
				"right_shoulder": Vector2(50, -74),
				"right_elbow": Vector2(62, -55),
				"right_hand": Vector2(42, -90),
				"left_hand_type": "fist",
				"right_hand_type": "fist",
				"pelvis_offset": Vector2(0, 8),
				"left_leg_lean": -5.0,
				"right_leg_lean": 5.0,
				"left_foot_offset": Vector2(-18, 0),
				"right_foot_offset": Vector2(18, 0),
				"left_knee_bend": -8.0,
				"right_knee_bend": 8.0,
				"is_seated": false
			}

		"casual_contrapposto":
			# Stylish anime creator weight shift: resting weight on one hip
			return {
				"torso_offset": Vector2(-2, 0),
				"torso_tilt": 2.5,
				"head_offset": Vector2(-2, -140),
				"head_tilt": -3.0,
				"left_shoulder": Vector2(-50, -76),
				"left_elbow": Vector2(-58, -22),
				"left_hand": Vector2(-52, 34),
				"right_shoulder": Vector2(48, -76),
				"right_elbow": Vector2(58, -35),
				"right_hand": Vector2(46, -60),
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-6, 0),
				"left_leg_lean": -10.0,
				"right_leg_lean": 6.0,
				"left_foot_offset": Vector2(-6, 0),
				"right_foot_offset": Vector2(12, -4),
				"left_knee_bend": 0.0,
				"right_knee_bend": 6.0,
				"is_seated": false
			}

		"pacing_step_left":
			# Walking step: left leg forward
			return {
				"torso_offset": Vector2(-4, 0),
				"torso_tilt": 1.5,
				"head_offset": Vector2(-4, -142),
				"head_tilt": 2.0,
				"left_shoulder": Vector2(-50, -76),
				"left_elbow": Vector2(-56, -20),
				"left_hand": Vector2(-48, 30),
				"right_shoulder": Vector2(48, -76),
				"right_elbow": Vector2(62, -45),
				"right_hand": Vector2(50, -85),
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-4, 2),
				"left_leg_lean": -8.0,
				"right_leg_lean": 2.0,
				"left_foot_offset": Vector2(-14, -6),
				"right_foot_offset": Vector2(10, 0),
				"left_knee_bend": -8.0,
				"right_knee_bend": 2.0,
				"is_seated": false
			}

		"pacing_step_right":
			# Walking step: right leg forward
			return {
				"torso_offset": Vector2(4, 0),
				"torso_tilt": -1.5,
				"head_offset": Vector2(4, -142),
				"head_tilt": -2.0,
				"left_shoulder": Vector2(-48, -76),
				"left_elbow": Vector2(-62, -45),
				"left_hand": Vector2(-50, -85),
				"right_shoulder": Vector2(50, -76),
				"right_elbow": Vector2(56, -20),
				"right_hand": Vector2(48, 30),
				"left_hand_type": "open_palm",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(4, 2),
				"left_leg_lean": -2.0,
				"right_leg_lean": 8.0,
				"left_foot_offset": Vector2(-10, 0),
				"right_foot_offset": Vector2(14, -6),
				"left_knee_bend": 2.0,
				"right_knee_bend": 8.0,
				"is_seated": false
			}

		"hands_clasped":
			# Conversational hands resting together in front
			return {
				"torso_offset": Vector2(0, 0),
				"torso_tilt": 0.0,
				"head_offset": Vector2(0, -142),
				"head_tilt": 2.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-42, -28),
				"left_hand": Vector2(-8, 5),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(42, -28),
				"right_hand": Vector2(8, 5),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(0, 0),
				"left_leg_lean": -4.0,
				"right_leg_lean": 2.0,
				"left_foot_offset": Vector2(-4, 0),
				"right_foot_offset": Vector2(4, 0),
				"left_knee_bend": 0.0,
				"right_knee_bend": 0.0,
				"is_seated": false
			}

		"chin_rub", "thinking_chin":
			# Thoughtful pose with hand at chin
			return {
				"torso_offset": Vector2(2, 0),
				"torso_tilt": -2.0,
				"head_offset": Vector2(2, -140),
				"head_tilt": 6.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-54, -28),
				"left_hand": Vector2(-44, 15),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(46, -60),
				"right_hand": Vector2(14, -102),
				"left_hand_type": "relaxed",
				"right_hand_type": "hand_to_chin",
				"pelvis_offset": Vector2(4, 0),
				"left_leg_lean": -2.0,
				"right_leg_lean": 6.0,
				"left_foot_offset": Vector2(-6, 0),
				"right_foot_offset": Vector2(8, -4),
				"left_knee_bend": 0.0,
				"right_knee_bend": 4.0,
				"is_seated": false
			}

		"confused_scratch":
			# Awkward hand scratching back of head
			return {
				"torso_offset": Vector2(-2, 0),
				"torso_tilt": 3.0,
				"head_offset": Vector2(-2, -140),
				"head_tilt": -7.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-56, -20),
				"left_hand": Vector2(-50, 30),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(72, -88),
				"right_hand": Vector2(36, -138),
				"left_hand_type": "relaxed",
				"right_hand_type": "relaxed",
				"pelvis_offset": Vector2(-2, 0),
				"left_leg_lean": 2.0,
				"right_leg_lean": -2.0,
				"left_foot_offset": Vector2(-8, 0),
				"right_foot_offset": Vector2(8, -3),
				"left_knee_bend": 3.0,
				"right_knee_bend": -3.0,
				"is_seated": false
			}

		"one_hand_gesture":
			# Casual open hand explanation gesture
			return {
				"torso_offset": Vector2(-2, 0),
				"torso_tilt": 2.0,
				"head_offset": Vector2(-2, -142),
				"head_tilt": 3.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-58, -22),
				"left_hand": Vector2(-52, 34),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(66, -50),
				"right_hand": Vector2(54, -88),
				"left_hand_type": "relaxed",
				"right_hand_type": "open_palm",
				"pelvis_offset": Vector2(-2, 0),
				"left_leg_lean": -5.0,
				"right_leg_lean": 3.0,
				"left_foot_offset": Vector2(-6, 0),
				"right_foot_offset": Vector2(6, 0),
				"left_knee_bend": 0.0,
				"right_knee_bend": 0.0,
				"is_seated": false
			}

		"pointing_up", "smug_point":
			# Confident point upwards
			return {
				"torso_offset": Vector2(2, 0),
				"torso_tilt": -3.0,
				"head_offset": Vector2(2, -142),
				"head_tilt": 4.0,
				"left_shoulder": Vector2(-49, -76),
				"left_elbow": Vector2(-56, -22),
				"left_hand": Vector2(-50, 34),
				"right_shoulder": Vector2(49, -76),
				"right_elbow": Vector2(60, -90),
				"right_hand": Vector2(52, -145),
				"left_hand_type": "relaxed",
				"right_hand_type": "pointing",
				"pelvis_offset": Vector2(2, 0),
				"left_leg_lean": -6.0,
				"right_leg_lean": 6.0,
				"left_foot_offset": Vector2(-12, 0),
				"right_foot_offset": Vector2(12, 0),
				"left_knee_bend": -4.0,
				"right_knee_bend": 4.0,
				"is_seated": false
			}

		_:
			return _get_raw_pose("relaxed_standing")
