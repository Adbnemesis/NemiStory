class_name NemiFXAnchor
extends RefCounted

## Manages dynamic spatial attachment anchors for Nemi's Expression FX system.
## Resolves character landmarks taking Bone2D skeletal movement into account.

enum AnchorType {
	HEAD_TOP,
	HEAD_LEFT,
	HEAD_RIGHT,
	FACE_CENTER,
	CHEEKS,
	CHEEK_LEFT,
	CHEEK_RIGHT,
	TEMPLE_LEFT,
	TEMPLE_RIGHT,
	SHOULDER_LEFT,
	SHOULDER_RIGHT,
	HAND_LEFT,
	HAND_RIGHT,
	TORSO_CENTER,
	PROP_ANCHOR,
	CUSTOM
}

## Returns the target bone or node corresponding to an anchor type
static func get_anchor_node(character: Node2D, anchor_type: AnchorType) -> Node2D:
	if not character:
		return null
	
	# If character has head_bone directly or via skeleton
	var head: Node2D = character.get("head_bone")
	var torso: Node2D = character.get("torso_bone")
	var l_arm: Node2D = character.get("left_upper_arm_bone")
	var r_arm: Node2D = character.get("right_upper_arm_bone")
	var l_hand: Node2D = character.get("left_hand_bone")
	var r_hand: Node2D = character.get("right_hand_bone")
	
	match anchor_type:
		AnchorType.HEAD_TOP, AnchorType.HEAD_LEFT, AnchorType.HEAD_RIGHT, \
		AnchorType.FACE_CENTER, AnchorType.CHEEKS, AnchorType.CHEEK_LEFT, AnchorType.CHEEK_RIGHT, \
		AnchorType.TEMPLE_LEFT, AnchorType.TEMPLE_RIGHT:
			return head if head else character
		
		AnchorType.SHOULDER_LEFT:
			return l_arm if l_arm else torso if torso else character
		AnchorType.SHOULDER_RIGHT:
			return r_arm if r_arm else torso if torso else character
		
		AnchorType.HAND_LEFT:
			return l_hand if l_hand else character
		AnchorType.HAND_RIGHT:
			return r_hand if r_hand else character
		
		AnchorType.TORSO_CENTER:
			return torso if torso else character
		
		_:
			return character

## Returns local offset from the anchor node
static func get_local_offset(anchor_type: AnchorType) -> Vector2:
	match anchor_type:
		AnchorType.HEAD_TOP:
			return Vector2(0.0, -125.0) # Above hair crown and ahoge
		AnchorType.HEAD_LEFT:
			return Vector2(-55.0, -78.0) # Upper left of hair/head
		AnchorType.HEAD_RIGHT:
			return Vector2(55.0, -78.0) # Upper right of hair/head
		AnchorType.FACE_CENTER:
			return Vector2(0.0, -35.0) # Mid face between eyes and nose
		AnchorType.CHEEKS:
			return Vector2(0.0, -32.0)
		AnchorType.CHEEK_LEFT:
			return Vector2(-35.0, -32.0)
		AnchorType.CHEEK_RIGHT:
			return Vector2(35.0, -32.0)
		AnchorType.TEMPLE_LEFT:
			return Vector2(-46.0, -62.0)
		AnchorType.TEMPLE_RIGHT:
			return Vector2(46.0, -62.0)
		AnchorType.SHOULDER_LEFT:
			return Vector2(-10.0, 0.0)
		AnchorType.SHOULDER_RIGHT:
			return Vector2(10.0, 0.0)
		AnchorType.HAND_LEFT:
			return Vector2(0.0, 15.0)
		AnchorType.HAND_RIGHT:
			return Vector2(0.0, 15.0)
		AnchorType.TORSO_CENTER:
			return Vector2(0.0, -30.0)
		_:
			return Vector2.ZERO

## Resolves global position of the anchor in world space
static func get_anchor_global_pos(character: Node2D, anchor_type: AnchorType, custom_offset: Vector2 = Vector2.ZERO) -> Vector2:
	var node := get_anchor_node(character, anchor_type)
	var offset := get_local_offset(anchor_type) + custom_offset
	if node and node.is_inside_tree():
		return node.global_transform * offset
	elif character and character.is_inside_tree():
		return character.global_position + offset
	return offset

## Converts string name to AnchorType enum
static func from_string(name_str: String) -> AnchorType:
	match name_str.to_lower().strip_edges():
		"head_top", "top", "above_head":
			return AnchorType.HEAD_TOP
		"head_left", "top_left":
			return AnchorType.HEAD_LEFT
		"head_right", "top_right":
			return AnchorType.HEAD_RIGHT
		"face_center", "face":
			return AnchorType.FACE_CENTER
		"cheeks", "blush":
			return AnchorType.CHEEKS
		"cheek_left":
			return AnchorType.CHEEK_LEFT
		"cheek_right":
			return AnchorType.CHEEK_RIGHT
		"temple_left":
			return AnchorType.TEMPLE_LEFT
		"temple_right":
			return AnchorType.TEMPLE_RIGHT
		"shoulder_left":
			return AnchorType.SHOULDER_LEFT
		"shoulder_right":
			return AnchorType.SHOULDER_RIGHT
		"hand_left":
			return AnchorType.HAND_LEFT
		"hand_right":
			return AnchorType.HAND_RIGHT
		"torso_center", "torso", "chest":
			return AnchorType.TORSO_CENTER
		"prop", "prop_anchor":
			return AnchorType.PROP_ANCHOR
		_:
			return AnchorType.HEAD_TOP
