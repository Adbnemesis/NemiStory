class_name NemiPose
extends RefCounted

## Master Pose Data & Solver for NEMI
## Defines bone rotation angles (in radians), position offsets, and hand/face states.
## All poses are computed dynamically by the rig rather than using pre-rendered pictures.

# Standard Bone Map:
# - torso_rot
# - neck_rot
# - head_rot
# - left_upper_arm_rot, left_lower_arm_rot, left_hand_pose
# - right_upper_arm_rot, right_lower_arm_rot, right_hand_pose
# - skirt_rot
# - left_thigh_rot, left_shin_rot, left_foot_rot
# - right_thigh_rot, right_shin_rot, right_foot_rot

static func get_pose(pose_name: String) -> Dictionary:
	match pose_name.to_lower():
		"casual_standing":
			return {
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(3.0),
				"left_upper_arm_rot": deg_to_rad(12.0),
				"left_lower_arm_rot": deg_to_rad(18.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-18.0),
				"right_lower_arm_rot": deg_to_rad(-45.0), # Hand resting towards pocket
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(3.0),
				"left_shin_rot": deg_to_rad(-2.0),
				"left_foot_rot": deg_to_rad(-1.0),
				"right_thigh_rot": deg_to_rad(-4.0),
				"right_shin_rot": deg_to_rad(4.0),
				"right_foot_rot": deg_to_rad(0.0),
				"expression": "happy",
				"gaze": Vector2(0.0, 0.0)
			}
		
		"pointing":
			# Left arm raised forward pointing towards screen/content (as in Reference B!)
			return {
				"torso_rot": deg_to_rad(4.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(-3.0),
				"left_upper_arm_rot": deg_to_rad(-65.0), # Arm raised up & forward
				"left_lower_arm_rot": deg_to_rad(-40.0), # Forearm bent pointing
				"left_hand_pose": NemiLimbPart.HandPose.POINTING, # Extended index finger!
				"right_upper_arm_rot": deg_to_rad(15.0),
				"right_lower_arm_rot": deg_to_rad(10.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(2.0),
				"left_thigh_rot": deg_to_rad(-6.0),
				"left_shin_rot": deg_to_rad(5.0),
				"left_foot_rot": deg_to_rad(1.0),
				"right_thigh_rot": deg_to_rad(4.0),
				"right_shin_rot": deg_to_rad(-3.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"expression": "happy",
				"gaze": Vector2(-0.4, 0.0)
			}
		
		"thinking":
			# Hand raised to chin, head tilted, gaze up
			return {
				"torso_rot": deg_to_rad(-4.0),
				"neck_rot": deg_to_rad(5.0),
				"head_rot": deg_to_rad(8.0),
				"left_upper_arm_rot": deg_to_rad(10.0),
				"left_lower_arm_rot": deg_to_rad(15.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-85.0), # Arm up to chin
				"right_lower_arm_rot": deg_to_rad(-80.0), # Bent elbow
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(-2.0),
				"left_thigh_rot": deg_to_rad(2.0),
				"left_shin_rot": deg_to_rad(-1.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(-3.0),
				"right_shin_rot": deg_to_rad(2.0),
				"right_foot_rot": deg_to_rad(1.0),
				"expression": "confused",
				"gaze": Vector2(-0.5, -0.6)
			}
		
		"leaning":
			# Torso and head leaning forward in conversational interest
			return {
				"torso_rot": deg_to_rad(12.0),
				"neck_rot": deg_to_rad(-8.0),
				"head_rot": deg_to_rad(-4.0),
				"left_upper_arm_rot": deg_to_rad(25.0),
				"left_lower_arm_rot": deg_to_rad(35.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-20.0),
				"right_lower_arm_rot": deg_to_rad(30.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(8.0),
				"left_thigh_rot": deg_to_rad(-10.0),
				"left_shin_rot": deg_to_rad(12.0),
				"left_foot_rot": deg_to_rad(-2.0),
				"right_thigh_rot": deg_to_rad(-5.0),
				"right_shin_rot": deg_to_rad(6.0),
				"right_foot_rot": deg_to_rad(-1.0),
				"expression": "happy",
				"gaze": Vector2(0.3, 0.1)
			}
		
		"walking":
			# Dynamic contact step pose
			return {
				"torso_rot": deg_to_rad(3.0),
				"neck_rot": deg_to_rad(-2.0),
				"head_rot": deg_to_rad(1.0),
				"left_upper_arm_rot": deg_to_rad(-25.0), # Left arm swings forward
				"left_lower_arm_rot": deg_to_rad(-20.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(25.0),  # Right arm swings back
				"right_lower_arm_rot": deg_to_rad(15.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(4.0),
				"left_thigh_rot": deg_to_rad(22.0),      # Left leg forward
				"left_shin_rot": deg_to_rad(-15.0),
				"left_foot_rot": deg_to_rad(-8.0),
				"right_thigh_rot": deg_to_rad(-20.0),    # Right leg back
				"right_shin_rot": deg_to_rad(25.0),
				"right_foot_rot": deg_to_rad(12.0),
				"expression": "neutral",
				"gaze": Vector2(0.5, 0.0)
			}
		
		"excited":
			# Fist raised overhead outward, cheering expression clearing face!
			return {
				"torso_rot": deg_to_rad(-5.0),
				"neck_rot": deg_to_rad(3.0),
				"head_rot": deg_to_rad(-6.0),
				"left_upper_arm_rot": deg_to_rad(140.0), # Arm raised high & outward!
				"left_lower_arm_rot": deg_to_rad(15.0),
				"left_hand_pose": NemiLimbPart.HandPose.FIST, # Clenched fist!
				"right_upper_arm_rot": deg_to_rad(20.0),
				"right_lower_arm_rot": deg_to_rad(25.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(-3.0),
				"left_thigh_rot": deg_to_rad(8.0),
				"left_shin_rot": deg_to_rad(-6.0),
				"left_foot_rot": deg_to_rad(-2.0),
				"right_thigh_rot": deg_to_rad(-6.0),
				"right_shin_rot": deg_to_rad(5.0),
				"right_foot_rot": deg_to_rad(1.0),
				"expression": "excited",
				"gaze": Vector2(0.0, -0.4)
			}
		
		"recoiling":
			# Comedic shock recoil back with balanced defensive hands framing chest
			return {
				"torso_rot": deg_to_rad(-16.0), # Strong backward lean
				"neck_rot": deg_to_rad(8.0),
				"head_rot": deg_to_rad(10.0),
				"left_upper_arm_rot": deg_to_rad(32.0), # Hands up defensively framing upper torso
				"left_lower_arm_rot": deg_to_rad(-105.0), # Forearm bent up
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-32.0), # Symmetrical defensive raise
				"right_lower_arm_rot": deg_to_rad(105.0), # Forearm bent up
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(-10.0),
				"left_thigh_rot": deg_to_rad(14.0),
				"left_shin_rot": deg_to_rad(-16.0),
				"left_foot_rot": deg_to_rad(4.0),
				"right_thigh_rot": deg_to_rad(10.0),
				"right_shin_rot": deg_to_rad(-12.0),
				"right_foot_rot": deg_to_rad(2.0),
				"expression": "shocked",
				"gaze": Vector2(0.0, 0.0)
			}
		
		"novel_pose", "shocked_pointing":
			# Nemi leans backward, turns head right, looks left with eyes, raises right arm, bends elbow, points, shocked expression
			return {
				"torso_rot": deg_to_rad(-15.0),
				"neck_rot": deg_to_rad(6.0),
				"head_rot": deg_to_rad(16.0),
				"left_upper_arm_rot": deg_to_rad(26.0),
				"left_lower_arm_rot": deg_to_rad(34.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-75.0),
				"right_lower_arm_rot": deg_to_rad(-55.0),
				"right_hand_pose": NemiLimbPart.HandPose.POINTING, # Right hand pointing across
				"skirt_rot": deg_to_rad(-8.0),
				"left_thigh_rot": deg_to_rad(12.0),
				"left_shin_rot": deg_to_rad(-10.0),
				"left_foot_rot": deg_to_rad(-2.0),
				"right_thigh_rot": deg_to_rad(-10.0),
				"right_shin_rot": deg_to_rad(12.0),
				"right_foot_rot": deg_to_rad(0.0),
				"hair_back_rot": deg_to_rad(8.0),
				"hair_left_rot": deg_to_rad(10.0),
				"hair_right_rot": deg_to_rad(16.0),
				"expression": "shocked",
				"gaze": Vector2(-1.0, -0.1) # Looking left with her eyes!
			}
		
		"hand_on_heart":
			return {
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(2.0),
				"head_rot": deg_to_rad(-4.0),
				"left_upper_arm_rot": deg_to_rad(-35.0),
				"left_lower_arm_rot": deg_to_rad(-65.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(12.0),
				"right_lower_arm_rot": deg_to_rad(15.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(0.0),
				"left_shin_rot": deg_to_rad(0.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(0.0),
				"right_shin_rot": deg_to_rad(0.0),
				"right_foot_rot": deg_to_rad(0.0),
				"expression": "warm_smile",
				"gaze": Vector2.ZERO
			}
		
		"gesturing":
			return {
				"torso_rot": deg_to_rad(0.0),
				"neck_rot": deg_to_rad(0.0),
				"head_rot": deg_to_rad(2.0),
				"left_upper_arm_rot": deg_to_rad(-25.0),
				"left_lower_arm_rot": deg_to_rad(-20.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(25.0),
				"right_lower_arm_rot": deg_to_rad(20.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(0.0),
				"left_thigh_rot": deg_to_rad(0.0),
				"left_shin_rot": deg_to_rad(0.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(0.0),
				"right_shin_rot": deg_to_rad(0.0),
				"right_foot_rot": deg_to_rad(0.0),
				"expression": "smile",
				"gaze": Vector2.ZERO
			}
		
		"casual_wave", "wave":
			return {
				"torso_rot": deg_to_rad(-2.0),
				"neck_rot": deg_to_rad(1.0),
				"head_rot": deg_to_rad(-4.0),
				"left_upper_arm_rot": deg_to_rad(10.0),
				"left_lower_arm_rot": deg_to_rad(15.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-85.0),
				"right_lower_arm_rot": deg_to_rad(-25.0),
				"right_hand_pose": NemiLimbPart.HandPose.OPEN,
				"skirt_rot": deg_to_rad(-1.0),
				"left_thigh_rot": deg_to_rad(0.0),
				"left_shin_rot": deg_to_rad(0.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(0.0),
				"right_shin_rot": deg_to_rad(0.0),
				"right_foot_rot": deg_to_rad(0.0),
				"expression": "cheerful_smile",
				"gaze": Vector2.ZERO
			}
		
		_: # "idle" / default
			return {
				"torso_rot": deg_to_rad(0.0),
				"neck_rot": deg_to_rad(0.0),
				"head_rot": deg_to_rad(0.0),
				"left_upper_arm_rot": deg_to_rad(8.0),
				"left_lower_arm_rot": deg_to_rad(12.0),
				"left_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"right_upper_arm_rot": deg_to_rad(-8.0),
				"right_lower_arm_rot": deg_to_rad(-12.0),
				"right_hand_pose": NemiLimbPart.HandPose.RELAXED,
				"skirt_rot": deg_to_rad(0.0),
				"left_thigh_rot": deg_to_rad(0.0),
				"left_shin_rot": deg_to_rad(0.0),
				"left_foot_rot": deg_to_rad(0.0),
				"right_thigh_rot": deg_to_rad(0.0),
				"right_shin_rot": deg_to_rad(0.0),
				"right_foot_rot": deg_to_rad(0.0),
				"expression": "neutral",
				"gaze": Vector2.ZERO
			}
