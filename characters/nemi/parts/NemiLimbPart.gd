class_name NemiLimbPart
extends NemiPart

const InkStroke = preload("res://characters/nemi/drawing/InkStroke.gd")

## Renders Nemi's arm components (Upper Arm, Lower Arm, Hand) with hidden overlapping joint caps.
## All parts are pivoted at their joint:
## - Upper Arm pivot = Shoulder (0, 0)
## - Lower Arm pivot = Elbow (0, 0)
## - Hand pivot = Wrist (0, 0)

enum LimbType {
	UPPER_ARM,
	LOWER_ARM,
	HAND
}

enum HandPose {
	RELAXED,
	POINTING,
	FIST,
	OPEN
}

@export var limb_type: LimbType = LimbType.UPPER_ARM
@export var is_left: bool = true
@export var hand_pose: HandPose = HandPose.RELAXED:
	set(val):
		if hand_pose != val:
			hand_pose = val
			queue_redraw()

func _draw() -> void:
	if not style:
		return
	
	match limb_type:
		LimbType.UPPER_ARM:
			_draw_upper_arm()
		LimbType.LOWER_ARM:
			_draw_lower_arm()
		LimbType.HAND:
			_draw_hand()

func _draw_upper_arm() -> void:
	var poly := NemiGeometry.get_upper_arm_polygon(is_left)
	if poly.size() < 3:
		return
	
	draw_colored_polygon(poly, style.hoodie_color)
	
	# Sleeve drape folds
	var sign_x := -1.0 if is_left else 1.0
	var fold1 := PackedVector2Array([Vector2(sign_x * 12, 35), Vector2(0, 42)])
	var fold2 := PackedVector2Array([Vector2(-sign_x * 8, 55), Vector2(0, 60)])
	var f1_stroke := InkStroke.from_points(fold1, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	var f2_stroke := InkStroke.from_points(fold2, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	f1_stroke.draw_to(self)
	f2_stroke.draw_to(self)
	
	# Side contours only (no cross-cut lines at shoulder or elbow!)
	var contours := NemiGeometry.get_upper_arm_contours(is_left)
	for c in contours:
		var c_stroke := InkStroke.from_points(c, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		c_stroke.draw_to(self)

func _draw_lower_arm() -> void:
	var poly := NemiGeometry.get_lower_arm_polygon(is_left)
	if poly.size() < 3:
		return
	
	draw_colored_polygon(poly, style.hoodie_color)
	
	# Gathered wrist cuff band
	var sign_x := -1.0 if is_left else 1.0
	var cuff_line := PackedVector2Array([
		Vector2(sign_x * 10, 58), Vector2(0, 60), Vector2(-sign_x * 10, 58)
	])
	var cuff_stroke := InkStroke.from_points(cuff_line, style.inner_line_width, InkStroke.Profile.DELICATE_CREASE, style.ink_line_color)
	cuff_stroke.draw_to(self)
	
	# Forearm crease
	var crease := PackedVector2Array([Vector2(sign_x * 4, 25), Vector2(sign_x * 1, 45)])
	var cr_stroke := InkStroke.from_points(crease, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	cr_stroke.draw_to(self)
	
	# Side contours only (no joint cross lines!)
	var contours := NemiGeometry.get_lower_arm_contours(is_left)
	for c in contours:
		var c_stroke := InkStroke.from_points(c, style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		c_stroke.draw_to(self)

func _draw_hand() -> void:
	var poly := NemiGeometry.get_hand_polygon(hand_pose, is_left)
	if poly.size() < 3:
		return
	
	draw_colored_polygon(poly, style.skin_color)
	
	# Interior finger creases
	var sign_x := -1.0 if is_left else 1.0
	if hand_pose == HandPose.RELAXED:
		var f1 := PackedVector2Array([Vector2(-sign_x * 4, 12), Vector2(-sign_x * 1, 20)])
		var f2 := PackedVector2Array([Vector2(0, 14), Vector2(sign_x * 2, 22)])
		var s1 := InkStroke.from_points(f1, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		var s2 := InkStroke.from_points(f2, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		s1.draw_to(self)
		s2.draw_to(self)
	elif hand_pose == HandPose.POINTING:
		var k := PackedVector2Array([Vector2(-sign_x * 3, 14), Vector2(sign_x * 2, 14)])
		var ks := InkStroke.from_points(k, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		ks.draw_to(self)
	elif hand_pose == HandPose.FIST:
		var k1 := PackedVector2Array([Vector2(-sign_x * 4, 8), Vector2(-sign_x * 2, 14)])
		var k2 := PackedVector2Array([Vector2(0, 8), Vector2(0, 15)])
		var k3 := PackedVector2Array([Vector2(sign_x * 4, 8), Vector2(sign_x * 3, 14)])
		var s1 := InkStroke.from_points(k1, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		var s2 := InkStroke.from_points(k2, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		var s3 := InkStroke.from_points(k3, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		s1.draw_to(self)
		s2.draw_to(self)
		s3.draw_to(self)
	elif hand_pose == HandPose.OPEN:
		var o1 := PackedVector2Array([Vector2(-sign_x * 5, 6), Vector2(-sign_x * 3, 11)])
		var o2 := PackedVector2Array([Vector2(-sign_x * 1, 10), Vector2(-sign_x * 0.5, 17)])
		var o3 := PackedVector2Array([Vector2(sign_x * 2.5, 10), Vector2(sign_x * 3, 16)])
		var s1 := InkStroke.from_points(o1, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		var s2 := InkStroke.from_points(o2, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		var s3 := InkStroke.from_points(o3, style.detail_line_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
		s1.draw_to(self)
		s2.draw_to(self)
		s3.draw_to(self)
	
	# Hand calligraphic outer contour
	var outline := InkStroke.from_points(poly + PackedVector2Array([poly[0]]), style.outer_contour_width, InkStroke.Profile.TAPER_BOTH, style.ink_line_color)
	outline.draw_to(self)
