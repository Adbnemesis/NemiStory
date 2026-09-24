class_name NemiPose
extends RefCounted

## Master Storytelling Performance Pose Library for NEMI
## Implements 35+ distinct storytelling poses across 5 categories:
## A. Relaxed / Casual
## B. Conversational
## C. Emotional
## D. Comedic
## E. Storytelling & Staging
##
## Every pose authoritatively defines:
## - root_offset: Vector2 (Center of mass displacement & hip balance)
## - torso_rot, neck_rot, head_rot (Spine line of action)
## - skirt_rot (Pelvic counter-rotation)
## - left_thigh_rot, left_shin_rot, left_foot_rot (Leg kinematics & weight distribution)
## - right_thigh_rot, right_shin_rot, right_foot_rot
## - arm kinematics & expressive hand poses
## - hair rest angles, expression, and gaze

static func get_pose(pose_name: String) -> Dictionary:
	var key: String = pose_name.to_lower().strip_edges()
	match key:
		# =========================================================================
		# CATEGORY A: RELAXED / CASUAL
		# =========================================================================
		"relaxed_standing", "casual_standing", "default":
			# Weight naturally resting on left leg, right knee softly relaxed
			return {
				"root_offset": Vector2(-6.0, 0.0),
				"torso_rot": deg_to_rad(-3.0),
				"neck_rot": deg_to_rad(1.5),
				"head_rot": deg_to_rad(3.5),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-8.0),
				"right_shin_rot": deg_to_rad(10.0),
				"right_foot_rot": deg_to_rad(4.0),
				"left_upper_arm_rot": deg_to_rad(12.0),
				"left_lower_arm_rot": deg_to_rad(16.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-14.0),
				"right_lower_arm_rot": deg_to_rad(-24.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(1.0),
				"hair_left_rot": deg_to_rad(-1.0),
				"hair_right_rot": deg_to_rad(2.0),
				"expression": "happy",
				"gaze": Vector2(0.0, 0.0)
			}

		"relaxed_standing_left_weight", "weight_left":
			# Strong contrapposto: weight anchored on left leg, hip pushed out left
			return {
				"root_offset": Vector2(-10.0, 0.0),
				"torso_rot": deg_to_rad(-5.0),
				"neck_rot": deg_to_rad(2.5),
				"head_rot": deg_to_rad(5.0),
				"skirt_rot": deg_to_rad(-4.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-3.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-12.0),
				"right_shin_rot": deg_to_rad(14.0),
				"right_foot_rot": deg_to_rad(6.0),
				"left_upper_arm_rot": deg_to_rad(10.0),
				"left_lower_arm_rot": deg_to_rad(14.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-16.0),
				"right_lower_arm_rot": deg_to_rad(-32.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(2.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(4.0),
				"expression": "warm_smile",
				"gaze": Vector2(0.1, 0.0)
			}

		"relaxed_standing_right_weight", "weight_right":
			# Contrapposto on right leg: right hip kicked out, left knee softly bent
			return {
				"root_offset": Vector2(10.0, 0.0),
				"torso_rot": deg_to_rad(5.0),
				"neck_rot": deg_to_rad(-2.5),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(4.0),
				"left_thigh_rot": deg_to_rad(12.0),
				"left_shin_rot": deg_to_rad(-14.0),
				"left_foot_rot": deg_to_rad(-5.0),
				"right_thigh_rot": deg_to_rad(-3.0),
				"right_shin_rot": deg_to_rad(3.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(14.0),
				"left_lower_arm_rot": deg_to_rad(28.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-10.0),
				"right_lower_arm_rot": deg_to_rad(-14.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-2.0),
				"hair_left_rot": deg_to_rad(-4.0),
				"hair_right_rot": deg_to_rad(2.0),
				"expression": "happy",
				"gaze": Vector2(-0.1, 0.0)
			}

		"casual_hand_on_hip", "hand_on_hip":
			# Right hand on hip, elbow akimbo, hip pushed right, relaxed left arm
			return {
				"root_offset": Vector2(8.0, 0.0),
				"torso_rot": deg_to_rad(4.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(-3.0),
				"skirt_rot": deg_to_rad(3.0),
				"left_thigh_rot": deg_to_rad(10.0),
				"left_shin_rot": deg_to_rad(-12.0),
				"left_foot_rot": deg_to_rad(-4.0),
				"right_thigh_rot": deg_to_rad(-2.0),
				"right_shin_rot": deg_to_rad(2.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(10.0),
				"left_lower_arm_rot": deg_to_rad(14.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-45.0), # Hand on waist
				"right_lower_arm_rot": deg_to_rad(-75.0),
				"right_hand_pose": NemiLimbPart.HandPose.FIST,
				"hair_back_rot": deg_to_rad(-1.5),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(2.5),
				"expression": "smug",
				"gaze": Vector2(0.0, 0.0)
			}

		"casual_hand_on_bag_strap", "bag_strap_touch":
			# Left hand casually holding bag strap at chest level, weight on left
			return {
				"root_offset": Vector2(-6.0, 0.0),
				"torso_rot": deg_to_rad(-3.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(3.0),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-6.0),
				"right_shin_rot": deg_to_rad(8.0),
				"right_foot_rot": deg_to_rad(3.0),
				"left_upper_arm_rot": deg_to_rad(-35.0),
				"left_lower_arm_rot": deg_to_rad(-75.0),
				"left_hand_pose": NemiLimbPart.HandPose.GRIP_STRAP,
				"right_upper_arm_rot": deg_to_rad(-12.0),
				"right_lower_arm_rot": deg_to_rad(-16.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(1.0),
				"hair_left_rot": deg_to_rad(-1.0),
				"hair_right_rot": deg_to_rad(2.0),
				"expression": "gentle_smile",
				"gaze": Vector2(0.0, 0.0)
			}

		"casual_lean_left", "lean_left":
			return {
				"root_offset": Vector2(-14.0, 2.0),
				"torso_rot": deg_to_rad(-8.0),
				"neck_rot": deg_to_rad(4.0),
				"head_rot": deg_to_rad(6.0),
				"skirt_rot": deg_to_rad(-6.0),
				"left_thigh_rot": deg_to_rad(4.0),
				"left_shin_rot": deg_to_rad(-4.0),
				"left_foot_rot": deg_to_rad(-2.0),
				"right_thigh_rot": deg_to_rad(-14.0),
				"right_shin_rot": deg_to_rad(16.0),
				"right_foot_rot": deg_to_rad(8.0),
				"left_upper_arm_rot": deg_to_rad(18.0),
				"left_lower_arm_rot": deg_to_rad(25.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-18.0),
				"right_lower_arm_rot": deg_to_rad(-35.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(4.0),
				"hair_left_rot": deg_to_rad(2.0),
				"hair_right_rot": deg_to_rad(6.0),
				"expression": "casual",
				"gaze": Vector2(0.2, 0.0)
			}

		"arms_loosely_folded", "arms_folded":
			# Arms crossed casually over waist, head tilted
			return {
				"root_offset": Vector2(4.0, 0.0),
				"torso_rot": deg_to_rad(2.0),
				"neck_rot": deg_to_rad(-1.0),
				"head_rot": deg_to_rad(4.0),
				"skirt_rot": deg_to_rad(1.0),
				"left_thigh_rot": deg_to_rad(6.0),
				"left_shin_rot": deg_to_rad(-8.0),
				"left_foot_rot": deg_to_rad(-2.0),
				"right_thigh_rot": deg_to_rad(-3.0),
				"right_shin_rot": deg_to_rad(4.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(-35.0),
				"left_lower_arm_rot": deg_to_rad(-65.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(35.0),
				"right_lower_arm_rot": deg_to_rad(65.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(1.0),
				"hair_left_rot": deg_to_rad(0.0),
				"hair_right_rot": deg_to_rad(3.0),
				"expression": "amused",
				"gaze": Vector2(0.0, 0.0)
			}

		# =========================================================================
		# CATEGORY B: CONVERSATIONAL
		# =========================================================================
		"one_hand_explaining", "explaining", "conversational_open_one":
			# Right hand raised open in conversational explanation, body leaned forward
			return {
				"root_offset": Vector2(4.0, 1.0),
				"torso_rot": deg_to_rad(5.0),
				"neck_rot": deg_to_rad(-2.5),
				"head_rot": deg_to_rad(-1.5),
				"skirt_rot": deg_to_rad(3.0),
				"left_thigh_rot": deg_to_rad(-4.0),
				"left_shin_rot": deg_to_rad(5.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(5.0),
				"right_shin_rot": deg_to_rad(-4.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(14.0),
				"left_lower_arm_rot": deg_to_rad(18.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-40.0),
				"right_lower_arm_rot": deg_to_rad(-60.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "talking",
				"gaze": Vector2(0.1, 0.0)
			}

		"both_hands_explaining_asym", "explaining_both":
			# Both hands explaining with distinct height and depth asymmetry
			return {
				"root_offset": Vector2(0.0, 1.0),
				"torso_rot": deg_to_rad(4.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(2.0),
				"skirt_rot": deg_to_rad(2.0),
				"left_thigh_rot": deg_to_rad(-3.0),
				"left_shin_rot": deg_to_rad(4.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-3.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-48.0), # Higher left hand
				"left_lower_arm_rot": deg_to_rad(-70.0),
				"left_hand_pose": NemiLimbPart.HandPose.OPEN,
				"right_upper_arm_rot": deg_to_rad(25.0), # Lower right hand
				"right_lower_arm_rot": deg_to_rad(45.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"hair_back_rot": deg_to_rad(0.5),
				"hair_left_rot": deg_to_rad(-1.0),
				"hair_right_rot": deg_to_rad(2.0),
				"expression": "talking_open",
				"gaze": Vector2(0.0, 0.0)
			}

		"pointing", "point", "conversational_point_low", "point_down_subtle":
			# Decisive index point, body slightly turned toward target
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-4.0),
				"neck_rot": deg_to_rad(2.0),
				"head_rot": deg_to_rad(-3.0),
				"skirt_rot": deg_to_rad(-3.0),
				"left_thigh_rot": deg_to_rad(4.0),
				"left_shin_rot": deg_to_rad(-4.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-6.0),
				"right_shin_rot": deg_to_rad(8.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-70.0), # Left arm pointing forward
				"left_lower_arm_rot": deg_to_rad(-45.0),
				"left_hand_pose": NemiLimbPart.HandPose.POINTING,
				"right_upper_arm_rot": deg_to_rad(-12.0),
				"right_lower_arm_rot": deg_to_rad(-18.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(2.0),
				"hair_left_rot": deg_to_rad(3.0),
				"hair_right_rot": deg_to_rad(-1.0),
				"expression": "confident",
				"gaze": Vector2(-0.4, 0.0)
			}

		"counting_one", "finger_count_one":
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(4.0),
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(5.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(-55.0),
				"left_lower_arm_rot": deg_to_rad(-85.0),
				"left_hand_pose": NemiLimbPart.HandPose.FINGER_COUNT_ONE,
				"right_upper_arm_rot": deg_to_rad(-12.0),
				"right_lower_arm_rot": deg_to_rad(-18.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(1.5),
				"hair_left_rot": deg_to_rad(-1.0),
				"hair_right_rot": deg_to_rad(2.5),
				"expression": "talking",
				"gaze": Vector2(0.0, 0.0)
			}

		"counting_two", "finger_count_two":
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(4.0),
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(5.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(-55.0),
				"left_lower_arm_rot": deg_to_rad(-85.0),
				"left_hand_pose": NemiLimbPart.HandPose.FINGER_COUNT_TWO,
				"right_upper_arm_rot": deg_to_rad(-12.0),
				"right_lower_arm_rot": deg_to_rad(-18.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(1.5),
				"hair_left_rot": deg_to_rad(-1.0),
				"hair_right_rot": deg_to_rad(2.5),
				"expression": "talking",
				"gaze": Vector2(0.0, 0.0)
			}

		"counting_three", "finger_count_three":
			return {
				"root_offset": Vector2(4.0, 1.0),
				"torso_rot": deg_to_rad(5.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(-2.0),
				"skirt_rot": deg_to_rad(3.0),
				"left_thigh_rot": deg_to_rad(-4.0),
				"left_shin_rot": deg_to_rad(5.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(5.0),
				"right_shin_rot": deg_to_rad(-4.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(12.0),
				"left_lower_arm_rot": deg_to_rad(16.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(65.0), # Hand held high & clear to camera
				"right_lower_arm_rot": deg_to_rad(85.0),
				"right_hand_pose": NemiLimbPart.HandPose.FINGER_COUNT_THREE,
				"hair_back_rot": deg_to_rad(-1.5),
				"hair_left_rot": deg_to_rad(-2.5),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "talking",
				"gaze": Vector2(0.1, 0.0)
			}

		"palms_up_what", "what_shrug":
			# Both palms raised upward, shoulders elevated, head cocked
			return {
				"root_offset": Vector2(0.0, -2.0), # Lifted torso
				"torso_rot": deg_to_rad(1.0),
				"neck_rot": deg_to_rad(-1.0),
				"head_rot": deg_to_rad(-6.0),
				"skirt_rot": deg_to_rad(0.0),
				"left_thigh_rot": deg_to_rad(4.0),
				"left_shin_rot": deg_to_rad(-4.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(4.0),
				"right_foot_rot": deg_to_rad(0.0),
				"left_upper_arm_rot": deg_to_rad(-38.0),
				"left_lower_arm_rot": deg_to_rad(-65.0),
				"left_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"right_upper_arm_rot": deg_to_rad(32.0),
				"right_lower_arm_rot": deg_to_rad(58.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"hair_back_rot": deg_to_rad(-2.0),
				"hair_left_rot": deg_to_rad(-4.0),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "confused",
				"gaze": Vector2(0.0, 0.0)
			}

		"thinking", "hand_near_chin", "thinking_chin_tap":
			# Right hand near chin, head tilted, eyes averted
			return {
				"root_offset": Vector2(-5.0, 0.0),
				"torso_rot": deg_to_rad(-4.0),
				"neck_rot": deg_to_rad(3.0),
				"head_rot": deg_to_rad(8.0),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-3.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-5.0),
				"right_shin_rot": deg_to_rad(6.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(12.0),
				"left_lower_arm_rot": deg_to_rad(18.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-70.0),
				"right_lower_arm_rot": deg_to_rad(-95.0),
				"right_hand_pose": NemiLimbPart.HandPose.HAND_TO_CHEEK,
				"hair_back_rot": deg_to_rad(3.0),
				"hair_left_rot": deg_to_rad(1.0),
				"hair_right_rot": deg_to_rad(5.0),
				"expression": "confused",
				"gaze": Vector2(-0.4, -0.5)
			}

		"hand_near_cheek", "sheepish_cheek":
			# Left hand touching cheek softly, bashful head angle
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-3.0),
				"neck_rot": deg_to_rad(2.0),
				"head_rot": deg_to_rad(-5.0),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-3.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-5.0),
				"right_shin_rot": deg_to_rad(6.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-65.0),
				"left_lower_arm_rot": deg_to_rad(-90.0),
				"left_hand_pose": NemiLimbPart.HandPose.HAND_TO_CHEEK,
				"right_upper_arm_rot": deg_to_rad(-12.0),
				"right_lower_arm_rot": deg_to_rad(-18.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-2.0),
				"hair_left_rot": deg_to_rad(-3.5),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "blush",
				"gaze": Vector2(0.2, 0.1)
			}

		"finger_to_lips", "pondering_lips":
			# Index finger resting at mouth
			return {
				"root_offset": Vector2(-2.0, 0.0),
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(4.0),
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-3.0),
				"right_shin_rot": deg_to_rad(4.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(10.0),
				"left_lower_arm_rot": deg_to_rad(14.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-72.0),
				"right_lower_arm_rot": deg_to_rad(-105.0),
				"right_hand_pose": NemiLimbPart.HandPose.POINTING,
				"hair_back_rot": deg_to_rad(1.5),
				"hair_left_rot": deg_to_rad(0.0),
				"hair_right_rot": deg_to_rad(3.0),
				"expression": "thinking",
				"gaze": Vector2(-0.2, -0.4)
			}

		"small_shrug", "shrug":
			return {
				"root_offset": Vector2(0.0, -2.0),
				"torso_rot": deg_to_rad(0.0),
				"neck_rot": deg_to_rad(0.0),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(0.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-2.0),
				"right_shin_rot": deg_to_rad(2.0),
				"right_foot_rot": deg_to_rad(0.0),
				"left_upper_arm_rot": deg_to_rad(-30.0),
				"left_lower_arm_rot": deg_to_rad(-50.0),
				"left_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"right_upper_arm_rot": deg_to_rad(30.0),
				"right_lower_arm_rot": deg_to_rad(50.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.5),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "deadpan",
				"gaze": Vector2(0.0, 0.0)
			}

		"presenting_prop", "presenting":
			# Body angled right, right arm sweeping outward presenting a prop
			return {
				"root_offset": Vector2(6.0, 1.0),
				"torso_rot": deg_to_rad(6.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(-3.0),
				"skirt_rot": deg_to_rad(4.0),
				"left_thigh_rot": deg_to_rad(-6.0),
				"left_shin_rot": deg_to_rad(8.0),
				"left_foot_rot": deg_to_rad(2.0),
				"right_thigh_rot": deg_to_rad(6.0),
				"right_shin_rot": deg_to_rad(-5.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(15.0),
				"left_lower_arm_rot": deg_to_rad(20.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(65.0),
				"right_lower_arm_rot": deg_to_rad(35.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN_PALM_UP,
				"hair_back_rot": deg_to_rad(-1.5),
				"hair_left_rot": deg_to_rad(-3.0),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "cheerful_smile",
				"gaze": Vector2(0.4, 0.0)
			}

		# =========================================================================
		# CATEGORY C: EMOTIONAL
		# =========================================================================
		"excited", "excited_burst":
			# High-energy celebration: chest puffed, fist in air, head thrown back
			return {
				"root_offset": Vector2(0.0, -6.0), # Lifted up
				"torso_rot": deg_to_rad(-6.0),
				"neck_rot": deg_to_rad(3.0),
				"head_rot": deg_to_rad(-6.0),
				"skirt_rot": deg_to_rad(-4.0),
				"left_thigh_rot": deg_to_rad(8.0),
				"left_shin_rot": deg_to_rad(-6.0),
				"left_foot_rot": deg_to_rad(-3.0),
				"right_thigh_rot": deg_to_rad(-8.0),
				"right_shin_rot": deg_to_rad(6.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-140.0), # Fist raised high!
				"left_lower_arm_rot": deg_to_rad(-25.0),
				"left_hand_pose": NemiLimbPart.HandPose.FIST,
				"right_upper_arm_rot": deg_to_rad(20.0),
				"right_lower_arm_rot": deg_to_rad(25.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-4.0),
				"hair_left_rot": deg_to_rad(-6.0),
				"hair_right_rot": deg_to_rad(-3.0),
				"expression": "excited",
				"gaze": Vector2(0.0, -0.4)
			}

		"excited_anticipation", "pre_jump":
			# Compressed body pre-jump: knees bent, hands balled near chest
			return {
				"root_offset": Vector2(0.0, 8.0), # Dropped down
				"torso_rot": deg_to_rad(6.0),
				"neck_rot": deg_to_rad(-3.0),
				"head_rot": deg_to_rad(-2.0),
				"skirt_rot": deg_to_rad(4.0),
				"left_thigh_rot": deg_to_rad(14.0),
				"left_shin_rot": deg_to_rad(-16.0),
				"left_foot_rot": deg_to_rad(2.0),
				"right_thigh_rot": deg_to_rad(14.0),
				"right_shin_rot": deg_to_rad(-16.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(25.0),
				"left_lower_arm_rot": deg_to_rad(-70.0),
				"left_hand_pose": NemiLimbPart.HandPose.FIST,
				"right_upper_arm_rot": deg_to_rad(-25.0),
				"right_lower_arm_rot": deg_to_rad(70.0),
				"right_hand_pose": NemiLimbPart.HandPose.FIST,
				"hair_back_rot": deg_to_rad(2.0),
				"hair_left_rot": deg_to_rad(3.0),
				"hair_right_rot": deg_to_rad(2.0),
				"expression": "sparkle",
				"gaze": Vector2(0.0, 0.0)
			}

		"nervous", "nervous_hands_together":
			# Hands clasped together, knock-kneed stance, head tilted nervously
			return {
				"root_offset": Vector2(0.0, 2.0),
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(5.0),
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(-6.0),  # Knees turned inward
				"left_shin_rot": deg_to_rad(8.0),
				"left_foot_rot": deg_to_rad(4.0),
				"right_thigh_rot": deg_to_rad(6.0),
				"right_shin_rot": deg_to_rad(-8.0),
				"right_foot_rot": deg_to_rad(-4.0),
				"left_upper_arm_rot": deg_to_rad(-32.0),
				"left_lower_arm_rot": deg_to_rad(-60.0),
				"left_hand_pose": NemiLimbPart.HandPose.HANDS_TOGETHER,
				"right_upper_arm_rot": deg_to_rad(32.0),
				"right_lower_arm_rot": deg_to_rad(60.0),
				"right_hand_pose": NemiLimbPart.HandPose.HANDS_TOGETHER,
				"hair_back_rot": deg_to_rad(2.0),
				"hair_left_rot": deg_to_rad(1.0),
				"hair_right_rot": deg_to_rad(3.5),
				"expression": "nervous",
				"gaze": Vector2(-0.2, 0.2)
			}

		"embarrassed_shrink", "embarrassed", "shy_confession":
			# Contracted silhouette, shoulders hunched, head lowered, hand near mouth
			return {
				"root_offset": Vector2(-3.0, 4.0),
				"torso_rot": deg_to_rad(4.0),
				"neck_rot": deg_to_rad(-6.0),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(2.0),
				"left_thigh_rot": deg_to_rad(-5.0),
				"left_shin_rot": deg_to_rad(7.0),
				"left_foot_rot": deg_to_rad(2.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-5.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-50.0),
				"left_lower_arm_rot": deg_to_rad(-85.0),
				"left_hand_pose": NemiLimbPart.HandPose.HAND_TO_MOUTH,
				"right_upper_arm_rot": deg_to_rad(-10.0),
				"right_lower_arm_rot": deg_to_rad(-15.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(0.5),
				"expression": "blush",
				"gaze": Vector2(0.3, 0.3)
			}

		"annoyed_crossed_arms", "annoyed":
			# Hip kicked out left, tight arms folded, head tilted away with side-eye
			return {
				"root_offset": Vector2(-8.0, 0.0),
				"torso_rot": deg_to_rad(-6.0),
				"neck_rot": deg_to_rad(3.0),
				"head_rot": deg_to_rad(8.0),
				"skirt_rot": deg_to_rad(-5.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-3.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-10.0),
				"right_shin_rot": deg_to_rad(12.0),
				"right_foot_rot": deg_to_rad(5.0),
				"left_upper_arm_rot": deg_to_rad(-40.0),
				"left_lower_arm_rot": deg_to_rad(-70.0),
				"left_hand_pose": NemiLimbPart.HandPose.FIST,
				"right_upper_arm_rot": deg_to_rad(40.0),
				"right_lower_arm_rot": deg_to_rad(70.0),
				"right_hand_pose": NemiLimbPart.HandPose.FIST,
				"hair_back_rot": deg_to_rad(3.0),
				"hair_left_rot": deg_to_rad(1.0),
				"hair_right_rot": deg_to_rad(5.0),
				"expression": "annoyed",
				"gaze": Vector2(-0.8, -0.1) # Strong side-eye
			}

		"recoiling", "shock_recoil", "scared_recoil":
			# Comedic shock recoil: torso thrown back, defensive hands framing chest
			return {
				"root_offset": Vector2(4.0, 2.0),
				"torso_rot": deg_to_rad(-18.0), # Strong backward lean
				"neck_rot": deg_to_rad(9.0),
				"head_rot": deg_to_rad(12.0),
				"skirt_rot": deg_to_rad(-12.0),
				"left_thigh_rot": deg_to_rad(16.0),
				"left_shin_rot": deg_to_rad(-18.0),
				"left_foot_rot": deg_to_rad(5.0),
				"right_thigh_rot": deg_to_rad(12.0),
				"right_shin_rot": deg_to_rad(-14.0),
				"right_foot_rot": deg_to_rad(3.0),
				"left_upper_arm_rot": deg_to_rad(35.0),
				"left_lower_arm_rot": deg_to_rad(-110.0), # Forearms up defensively
				"left_hand_pose": NemiLimbPart.HandPose.SPLAYED_FINGERS,
				"right_upper_arm_rot": deg_to_rad(-35.0),
				"right_lower_arm_rot": deg_to_rad(110.0),
				"right_hand_pose": NemiLimbPart.HandPose.SPLAYED_FINGERS,
				"hair_back_rot": deg_to_rad(10.0), # Hair flares back!
				"hair_left_rot": deg_to_rad(12.0),
				"hair_right_rot": deg_to_rad(14.0),
				"expression": "shocked",
				"gaze": Vector2(0.0, 0.0)
			}

		"disbelief_forehead_touch", "disbelief":
			# Hand touching temple in utter cognitive overload
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-4.0),
				"neck_rot": deg_to_rad(2.0),
				"head_rot": deg_to_rad(6.0),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-3.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-5.0),
				"right_shin_rot": deg_to_rad(6.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(12.0),
				"left_lower_arm_rot": deg_to_rad(16.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-85.0),
				"right_lower_arm_rot": deg_to_rad(-105.0),
				"right_hand_pose": NemiLimbPart.HandPose.HAND_TO_CHEEK,
				"hair_back_rot": deg_to_rad(2.0),
				"hair_left_rot": deg_to_rad(0.5),
				"hair_right_rot": deg_to_rad(4.0),
				"expression": "shocked",
				"gaze": Vector2(0.0, 0.0)
			}

		"overwhelmed_chest_touch", "hand_on_heart":
			# Hand resting softly over heart, heartfelt realization
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(2.0),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(5.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(-35.0),
				"left_lower_arm_rot": deg_to_rad(-65.0),
				"left_hand_pose": NemiLimbPart.HandPose.HAND_TO_CHEST,
				"right_upper_arm_rot": deg_to_rad(12.0),
				"right_lower_arm_rot": deg_to_rad(15.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-1.5),
				"hair_left_rot": deg_to_rad(-2.5),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "warm_smile",
				"gaze": Vector2(0.0, 0.0)
			}

		"laughing_hand_mouth", "laughing":
			# Torso bowed forward in laughter, hand shielding mouth
			return {
				"root_offset": Vector2(2.0, 2.0),
				"torso_rot": deg_to_rad(8.0),
				"neck_rot": deg_to_rad(-5.0),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(5.0),
				"left_thigh_rot": deg_to_rad(-6.0),
				"left_shin_rot": deg_to_rad(7.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(5.0),
				"right_shin_rot": deg_to_rad(-4.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-55.0),
				"left_lower_arm_rot": deg_to_rad(-95.0),
				"left_hand_pose": NemiLimbPart.HandPose.HAND_TO_MOUTH,
				"right_upper_arm_rot": deg_to_rad(18.0),
				"right_lower_arm_rot": deg_to_rad(24.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-2.0),
				"hair_left_rot": deg_to_rad(-3.0),
				"hair_right_rot": deg_to_rad(-1.0),
				"expression": "laugh",
				"gaze": Vector2(0.0, 0.0)
			}

		# =========================================================================
		# CATEGORY D: COMEDIC
		# =========================================================================
		"deadpan_freeze", "deadpan":
			# Completely rigid, flat, zero micro-gesture silhouette
			return {
				"root_offset": Vector2(0.0, 0.0),
				"torso_rot": 0.0,
				"neck_rot": 0.0,
				"head_rot": 0.0,
				"skirt_rot": 0.0,
				"left_thigh_rot": 0.0,
				"left_shin_rot": 0.0,
				"left_foot_rot": 0.0,
				"right_thigh_rot": 0.0,
				"right_shin_rot": 0.0,
				"right_foot_rot": 0.0,
				"left_upper_arm_rot": deg_to_rad(8.0),
				"left_lower_arm_rot": deg_to_rad(12.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-8.0),
				"right_lower_arm_rot": deg_to_rad(-12.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": 0.0,
				"hair_left_rot": 0.0,
				"hair_right_rot": 0.0,
				"expression": "deadpan",
				"gaze": Vector2(0.0, 0.0)
			}

		"facepalm":
			# Hand pressed to face, elbow supported, body slumped
			return {
				"root_offset": Vector2(4.0, 3.0),
				"torso_rot": deg_to_rad(6.0),
				"neck_rot": deg_to_rad(-4.0),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(3.0),
				"left_thigh_rot": deg_to_rad(-4.0),
				"left_shin_rot": deg_to_rad(5.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-4.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(14.0),
				"left_lower_arm_rot": deg_to_rad(18.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-85.0),
				"right_lower_arm_rot": deg_to_rad(-115.0),
				"right_hand_pose": NemiLimbPart.HandPose.FACEPALM,
				"hair_back_rot": deg_to_rad(-1.5),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(-1.0),
				"expression": "deadpan",
				"gaze": Vector2(0.0, 0.0)
			}

		"hands_over_face":
			# Both hands covering face in comedic shame/overwhelm
			return {
				"root_offset": Vector2(0.0, 4.0),
				"torso_rot": deg_to_rad(5.0),
				"neck_rot": deg_to_rad(-3.0),
				"head_rot": deg_to_rad(-2.0),
				"skirt_rot": deg_to_rad(3.0),
				"left_thigh_rot": deg_to_rad(-3.0),
				"left_shin_rot": deg_to_rad(4.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(3.0),
				"right_shin_rot": deg_to_rad(-3.0),
				"right_foot_rot": deg_to_rad(0.0),
				"left_upper_arm_rot": deg_to_rad(-80.0),
				"left_lower_arm_rot": deg_to_rad(-110.0),
				"left_hand_pose": NemiLimbPart.HandPose.FACEPALM,
				"right_upper_arm_rot": deg_to_rad(80.0),
				"right_lower_arm_rot": deg_to_rad(110.0),
				"right_hand_pose": NemiLimbPart.HandPose.FACEPALM,
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(-2.0),
				"expression": "blush",
				"gaze": Vector2(0.0, 0.0)
			}

		"suspicious_side_eye":
			# Body angled 3/4 away, head turned back, sharp suspicious eye dart
			return {
				"root_offset": Vector2(-8.0, 0.0),
				"torso_rot": deg_to_rad(-8.0),
				"neck_rot": deg_to_rad(4.0),
				"head_rot": deg_to_rad(12.0),
				"skirt_rot": deg_to_rad(-6.0),
				"left_thigh_rot": deg_to_rad(4.0),
				"left_shin_rot": deg_to_rad(-4.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-12.0),
				"right_shin_rot": deg_to_rad(14.0),
				"right_foot_rot": deg_to_rad(6.0),
				"left_upper_arm_rot": deg_to_rad(16.0),
				"left_lower_arm_rot": deg_to_rad(24.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-16.0),
				"right_lower_arm_rot": deg_to_rad(-28.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(4.0),
				"hair_left_rot": deg_to_rad(2.0),
				"hair_right_rot": deg_to_rad(6.0),
				"expression": "suspicious",
				"gaze": Vector2(-0.9, -0.1) # Extreme side-eye
			}

		"exaggerated_pointing":
			# Full body lean forward into a dramatic pointing gesture
			return {
				"root_offset": Vector2(10.0, 2.0),
				"torso_rot": deg_to_rad(14.0),
				"neck_rot": deg_to_rad(-8.0),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(9.0),
				"left_thigh_rot": deg_to_rad(-14.0),
				"left_shin_rot": deg_to_rad(16.0),
				"left_foot_rot": deg_to_rad(4.0),
				"right_thigh_rot": deg_to_rad(12.0),
				"right_shin_rot": deg_to_rad(-10.0),
				"right_foot_rot": deg_to_rad(-3.0),
				"left_upper_arm_rot": deg_to_rad(20.0),
				"left_lower_arm_rot": deg_to_rad(30.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(75.0), # Strong point forward
				"right_lower_arm_rot": deg_to_rad(20.0),
				"right_hand_pose": NemiLimbPart.HandPose.POINTING,
				"hair_back_rot": deg_to_rad(-4.0),
				"hair_left_rot": deg_to_rad(-5.0),
				"hair_right_rot": deg_to_rad(-2.0),
				"expression": "shocked",
				"gaze": Vector2(0.6, 0.0)
			}

		"defeated_slump", "exhausted":
			# Shoulders rounded, chest collapsed, arms dangling limp, knees soft
			return {
				"root_offset": Vector2(0.0, 6.0), # Sunk down
				"torso_rot": deg_to_rad(8.0),
				"neck_rot": deg_to_rad(-10.0),
				"head_rot": deg_to_rad(-8.0),
				"skirt_rot": deg_to_rad(5.0),
				"left_thigh_rot": deg_to_rad(6.0),
				"left_shin_rot": deg_to_rad(-8.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(6.0),
				"right_shin_rot": deg_to_rad(-8.0),
				"right_foot_rot": deg_to_rad(0.0),
				"left_upper_arm_rot": deg_to_rad(25.0), # Dangling limp
				"left_lower_arm_rot": deg_to_rad(15.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-25.0),
				"right_lower_arm_rot": deg_to_rad(-15.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-3.0),
				"hair_left_rot": deg_to_rad(-4.0),
				"hair_right_rot": deg_to_rad(-2.0),
				"expression": "exhausted",
				"gaze": Vector2(0.0, 0.5)
			}

		"dramatic_despair":
			# Both hands clutching head, torso arched back in comedic agony
			return {
				"root_offset": Vector2(0.0, 2.0),
				"torso_rot": deg_to_rad(-14.0),
				"neck_rot": deg_to_rad(7.0),
				"head_rot": deg_to_rad(10.0),
				"skirt_rot": deg_to_rad(-8.0),
				"left_thigh_rot": deg_to_rad(10.0),
				"left_shin_rot": deg_to_rad(-12.0),
				"left_foot_rot": deg_to_rad(3.0),
				"right_thigh_rot": deg_to_rad(8.0),
				"right_shin_rot": deg_to_rad(-10.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-75.0),
				"left_lower_arm_rot": deg_to_rad(-115.0),
				"left_hand_pose": NemiLimbPart.HandPose.SPLAYED_FINGERS,
				"right_upper_arm_rot": deg_to_rad(75.0),
				"right_lower_arm_rot": deg_to_rad(115.0),
				"right_hand_pose": NemiLimbPart.HandPose.SPLAYED_FINGERS,
				"hair_back_rot": deg_to_rad(8.0),
				"hair_left_rot": deg_to_rad(10.0),
				"hair_right_rot": deg_to_rad(11.0),
				"expression": "shocked",
				"gaze": Vector2(0.0, -0.3)
			}

		# =========================================================================
		# CATEGORY E: STORYTELLING & STAGING
		# =========================================================================
		"hold_phone_low", "phone_glance":
			# Holding phone in left hand below chest, head tilted down glancing at it
			return {
				"root_offset": Vector2(-4.0, 1.0),
				"torso_rot": deg_to_rad(4.0),
				"neck_rot": deg_to_rad(-4.0),
				"head_rot": deg_to_rad(-6.0), # Head looking down
				"skirt_rot": deg_to_rad(2.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-3.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-6.0),
				"right_shin_rot": deg_to_rad(8.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-35.0), # Arm angled holding phone
				"left_lower_arm_rot": deg_to_rad(-70.0),
				"left_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"right_upper_arm_rot": deg_to_rad(-12.0),
				"right_lower_arm_rot": deg_to_rad(-16.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(-2.0),
				"hair_left_rot": deg_to_rad(-3.0),
				"hair_right_rot": deg_to_rad(-1.0),
				"expression": "concentrated",
				"gaze": Vector2(-0.2, 0.6) # Eyes down at phone screen
			}

		"hold_phone_high", "phone_present":
			# Holding phone up to show viewer or inspect closely
			return {
				"root_offset": Vector2(-4.0, 0.0),
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(3.0),
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-5.0),
				"right_shin_rot": deg_to_rad(6.0),
				"right_foot_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-60.0), # Arm up presenting phone
				"left_lower_arm_rot": deg_to_rad(-85.0),
				"left_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"right_upper_arm_rot": deg_to_rad(15.0),
				"right_lower_arm_rot": deg_to_rad(20.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(1.0),
				"hair_left_rot": deg_to_rad(-1.0),
				"hair_right_rot": deg_to_rad(2.0),
				"expression": "talking",
				"gaze": Vector2(-0.1, 0.0)
			}

		"turning_toward_prop", "look_at_prop":
			# Whole body angled toward right side object/prop
			return {
				"root_offset": Vector2(8.0, 1.0),
				"torso_rot": deg_to_rad(10.0),
				"neck_rot": deg_to_rad(-4.0),
				"head_rot": deg_to_rad(-3.0),
				"skirt_rot": deg_to_rad(7.0),
				"left_thigh_rot": deg_to_rad(-8.0),
				"left_shin_rot": deg_to_rad(10.0),
				"left_foot_rot": deg_to_rad(3.0),
				"right_thigh_rot": deg_to_rad(8.0),
				"right_shin_rot": deg_to_rad(-6.0),
				"right_foot_rot": deg_to_rad(-2.0),
				"left_upper_arm_rot": deg_to_rad(16.0),
				"left_lower_arm_rot": deg_to_rad(24.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(45.0),
				"right_lower_arm_rot": deg_to_rad(35.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN,
				"hair_back_rot": deg_to_rad(-3.0),
				"hair_left_rot": deg_to_rad(-4.5),
				"hair_right_rot": deg_to_rad(0.5),
				"expression": "curious",
				"gaze": Vector2(0.5, 0.1)
			}

		"casual_wave", "wave":
			return {
				"root_offset": Vector2(-3.0, 0.0),
				"torso_rot": deg_to_rad(-3.0),
				"neck_rot": deg_to_rad(1.5),
				"head_rot": deg_to_rad(-4.0),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(5.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(10.0),
				"left_lower_arm_rot": deg_to_rad(15.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-85.0),
				"right_lower_arm_rot": deg_to_rad(-25.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN,
				"hair_back_rot": deg_to_rad(-1.5),
				"hair_left_rot": deg_to_rad(-3.0),
				"hair_right_rot": deg_to_rad(1.5),
				"expression": "cheerful_smile",
				"gaze": Vector2(0.0, 0.0)
			}

		"seated_at_desk_relaxed", "seated_at_desk", "desk_sit":
			# Seated casual posture: pelvis lowered, thighs angled forward to right (desk), shins down to floor
			return {
				"root_offset": Vector2(0.0, 16.0), # Pelvis lowered to chair height
				"torso_rot": deg_to_rad(3.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(-1.0),
				"skirt_rot": deg_to_rad(-4.0), # Skirt rests flat on chair
				"left_thigh_rot": deg_to_rad(-72.0), # Thighs forward to right toward desk
				"left_shin_rot": deg_to_rad(70.0), # Shins down to floor
				"left_foot_rot": deg_to_rad(-4.0),
				"right_thigh_rot": deg_to_rad(-70.0),
				"right_shin_rot": deg_to_rad(68.0),
				"right_foot_rot": deg_to_rad(-2.0),
				"left_upper_arm_rot": deg_to_rad(28.0), # Arms resting forward on desk
				"left_lower_arm_rot": deg_to_rad(54.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(24.0),
				"right_lower_arm_rot": deg_to_rad(52.0),
				"right_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "casual",
				"gaze": Vector2(0.0, 0.0)
			}

		"seated_desk_lean":
			# Leaning slightly forward over desk, examining something closely
			return {
				"root_offset": Vector2(4.0, 14.0),
				"torso_rot": deg_to_rad(8.0), # Leaned forward
				"neck_rot": deg_to_rad(-5.0),
				"head_rot": deg_to_rad(-6.0), # Gaze down at surface
				"skirt_rot": deg_to_rad(-3.0),
				"left_thigh_rot": deg_to_rad(-75.0),
				"left_shin_rot": deg_to_rad(72.0),
				"left_foot_rot": deg_to_rad(-4.0),
				"right_thigh_rot": deg_to_rad(-72.0),
				"right_shin_rot": deg_to_rad(70.0),
				"right_foot_rot": deg_to_rad(-2.0),
				"left_upper_arm_rot": deg_to_rad(38.0),
				"left_lower_arm_rot": deg_to_rad(58.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-25.0), # Holding phone up to eyes
				"right_lower_arm_rot": deg_to_rad(-65.0),
				"right_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"hair_back_rot": deg_to_rad(-3.0),
				"hair_left_rot": deg_to_rad(-4.0),
				"hair_right_rot": deg_to_rad(-1.0),
				"expression": "concentrated",
				"gaze": Vector2(0.2, 0.4)
			}

		"shocked_analytics_freeze", "freeze_shock", "analytics_freeze":
			# Comedic shock freeze: rigid upright spine, phone held frozen mid-air, wide unblinking eyes
			return {
				"root_offset": Vector2(0.0, 12.0),
				"torso_rot": deg_to_rad(-4.0), # Slight stiff recoil
				"neck_rot": deg_to_rad(2.0),
				"head_rot": deg_to_rad(5.0),
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(-70.0),
				"left_shin_rot": deg_to_rad(68.0),
				"left_foot_rot": deg_to_rad(-2.0),
				"right_thigh_rot": deg_to_rad(-68.0),
				"right_shin_rot": deg_to_rad(66.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-20.0),
				"left_lower_arm_rot": deg_to_rad(-35.0),
				"left_hand_pose": NemiLimbPart.HandPose.SPLAYED_FINGERS, # Tense panic splay
				"right_upper_arm_rot": deg_to_rad(-45.0), # Phone frozen in air
				"right_lower_arm_rot": deg_to_rad(-75.0),
				"right_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"hair_back_rot": deg_to_rad(4.0),
				"hair_left_rot": deg_to_rad(5.0),
				"hair_right_rot": deg_to_rad(6.0),
				"expression": "shocked",
				"gaze": Vector2(0.0, 0.0) # Locked dead-center on viewer
			}

		"deadpan_camera_stare":
			# Completely still comedy hold: standing or seated, staring deadpan at lens
			return {
				"root_offset": Vector2(-2.0, 0.0),
				"torso_rot": 0.0,
				"neck_rot": 0.0,
				"head_rot": 0.0,
				"skirt_rot": 0.0,
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(5.0),
				"right_foot_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(8.0),
				"left_lower_arm_rot": deg_to_rad(12.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-20.0), # Phone held low by hip
				"right_lower_arm_rot": deg_to_rad(-30.0),
				"right_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"hair_back_rot": 0.0,
				"hair_left_rot": 0.0,
				"hair_right_rot": 0.0,
				"expression": "deadpan",
				"gaze": Vector2(0.0, 0.0)
			}

		"shy_phone_confession", "phone_confession":
			# Sheepish confession: Left hand shielding mouth in shy chuckle, right hand holding phone UP to camera
			return {
				"root_offset": Vector2(-3.0, 2.0),
				"torso_rot": deg_to_rad(3.5),
				"neck_rot": deg_to_rad(-5.0),
				"head_rot": deg_to_rad(-3.0),
				"skirt_rot": deg_to_rad(2.0),
				"left_thigh_rot": deg_to_rad(-4.0),
				"left_shin_rot": deg_to_rad(6.0),
				"left_foot_rot": deg_to_rad(2.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-4.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-52.0),
				"left_lower_arm_rot": deg_to_rad(-88.0),
				"left_hand_pose": NemiLimbPart.HandPose.HAND_TO_MOUTH, # Cupping mouth in bashful chuckle
				"right_upper_arm_rot": deg_to_rad(-60.0), # Holding phone up clearly to camera
				"right_lower_arm_rot": deg_to_rad(-85.0),
				"right_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "blush",
				"gaze": Vector2(0.2, 0.1) # Looking sheepishly slightly to the side
			}

		"coffee_sip", "sipping_coffee":
			# Taking a warm comforting sip of coffee from ceramic mug (left hand)
			return {
				"root_offset": Vector2(-2.0, 1.0),
				"torso_rot": deg_to_rad(2.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(5.0), # Gentle tilt toward mug
				"skirt_rot": deg_to_rad(1.0),
				"left_thigh_rot": deg_to_rad(-4.0),
				"left_shin_rot": deg_to_rad(5.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-3.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-64.0), # Left hand bringing mug to mouth
				"left_lower_arm_rot": deg_to_rad(-94.0),
				"left_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"right_upper_arm_rot": deg_to_rad(16.0),
				"right_lower_arm_rot": deg_to_rad(24.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"hair_back_rot": deg_to_rad(2.0),
				"hair_left_rot": deg_to_rad(1.0),
				"hair_right_rot": deg_to_rad(3.0),
				"expression": "casual",
				"gaze": Vector2(0.1, 0.4)
			}

		"holding_warm_mug":
			# Holding warm coffee mug at chest level, cozy animator energy
			return {
				"root_offset": Vector2(0.0, 1.0),
				"torso_rot": deg_to_rad(3.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(-3.0),
				"skirt_rot": deg_to_rad(1.0),
				"left_thigh_rot": deg_to_rad(-3.0),
				"left_shin_rot": deg_to_rad(4.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-3.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"left_upper_arm_rot": deg_to_rad(-38.0), # Holding mug at waist/chest
				"left_lower_arm_rot": deg_to_rad(-62.0),
				"left_hand_pose": NemiLimbPart.HandPose.HOLD_PROP,
				"right_upper_arm_rot": deg_to_rad(22.0),
				"right_lower_arm_rot": deg_to_rad(42.0),
				"right_hand_pose": NemiLimbPart.HandPose.HOLD_PROP, # Supporting mug
				"hair_back_rot": deg_to_rad(-1.0),
				"hair_left_rot": deg_to_rad(-2.0),
				"hair_right_rot": deg_to_rad(1.0),
				"expression": "warm",
				"gaze": Vector2(0.0, 0.0)
			}

		"seated_typing_laptop":
			# Seated leaning forward over desk, fingers tapping laptop trackpad/keyboard
			return {
				"root_offset": Vector2(4.0, 14.0),
				"torso_rot": deg_to_rad(9.0), # Leaned forward over laptop
				"neck_rot": deg_to_rad(-5.0),
				"head_rot": deg_to_rad(6.0), # Looking down at laptop screen
				"skirt_rot": deg_to_rad(-3.0),
				"left_thigh_rot": deg_to_rad(-74.0),
				"left_shin_rot": deg_to_rad(70.0),
				"left_foot_rot": deg_to_rad(-4.0),
				"right_thigh_rot": deg_to_rad(-72.0),
				"right_shin_rot": deg_to_rad(68.0),
				"right_foot_rot": deg_to_rad(-2.0),
				"left_upper_arm_rot": deg_to_rad(30.0), # Left hand resting on desk near coffee
				"left_lower_arm_rot": deg_to_rad(55.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-24.0), # Right hand reaching over trackpad/keys
				"right_lower_arm_rot": deg_to_rad(-48.0),
				"right_hand_pose": NemiLimbPart.HandPose.POINTING, # Tapping key
				"hair_back_rot": deg_to_rad(-2.0),
				"hair_left_rot": deg_to_rad(-3.0),
				"hair_right_rot": deg_to_rad(0.0),
				"expression": "concentrated",
				"gaze": Vector2(0.4, 0.4) # Looking directly at laptop screen
			}

		_: # Fallback to relaxed standing
			return get_pose("relaxed_standing")
