class_name NemiProportionOverlay
extends Node2D

const NemiProportions = preload("res://characters/nemi/NemiProportions.gd")

## Visual debug overlay that draws bounding boxes and proportion measurements
## directly aligned with Nemi's centralized constants in NemiProportions.gd.

@export var target_nemi: Node2D

func _draw() -> void:
	if not target_nemi or not visible:
		return
	
	# Match Nemi's current transform
	var origin: Vector2 = target_nemi.position
	var s: Vector2 = target_nemi.scale
	
	var col_box := Color(0.2, 0.6, 1.0, 0.7)
	var col_text := Color(0.1, 0.4, 0.9, 0.95)
	var col_hair := Color(0.9, 0.4, 0.1, 0.6)
	var col_head := Color(0.1, 0.8, 0.4, 0.7)
	
	# 1. Hair Silhouette Bounding Box (Max Width 118)
	var hair_rect := Rect2(
		origin + Vector2(-NemiProportions.HAIR_MAX_WIDTH * 0.5 * s.x, -218.0 * s.y),
		Vector2(NemiProportions.HAIR_MAX_WIDTH * s.x, (185.0 + 118.0) * s.y)
	)
	draw_rect(hair_rect, col_hair, false, 1.5)
	draw_string(ThemeDB.fallback_font, hair_rect.position + Vector2(4, 16), "HAIR WIDTH: 118 (Vertical Cascade)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col_hair)
	
	# 2. Head & Face Bounding Box (Origin at Chin y = -92 in character space)
	var head_y := -92.0 * s.y
	var head_rect := Rect2(
		origin + Vector2(-NemiProportions.HEAD_WIDTH * 0.5 * s.x, head_y - NemiProportions.HEAD_HEIGHT * s.y),
		Vector2(NemiProportions.HEAD_WIDTH * s.x, NemiProportions.HEAD_HEIGHT * s.y)
	)
	draw_rect(head_rect, col_head, false, 1.5)
	draw_string(ThemeDB.fallback_font, head_rect.position + Vector2(4, -6), "HEAD: 92 x 92 (Cute & Soft)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, col_head)
	
	# 3. Cheek Span Line (at y = -34 in head space)
	var cheek_y: float = origin.y + head_y - 34.0 * s.y
	var cheek_w: float = NemiProportions.FACE_WIDTH_AT_CHEEKS * s.x
	draw_line(Vector2(origin.x - cheek_w * 0.5, cheek_y), Vector2(origin.x + cheek_w * 0.5, cheek_y), Color(0.1, 0.8, 0.4, 0.9), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(origin.x + cheek_w * 0.5 + 4, cheek_y + 4), "Cheeks: 90", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, col_head)
	
	# 4. Eye Line & Interocular Gap (at y = -44 in head space)
	var eye_y: float = origin.y + head_y + NemiProportions.EYE_POS_Y * s.y
	var eye_l: float = origin.x - NemiProportions.EYE_OFFSET_X * s.x
	var eye_r: float = origin.x + NemiProportions.EYE_OFFSET_X * s.x
	draw_line(Vector2(eye_l - 11 * s.x, eye_y), Vector2(eye_l + 11 * s.x, eye_y), col_box, 2.0)
	draw_line(Vector2(eye_r - 11 * s.x, eye_y), Vector2(eye_r + 11 * s.x, eye_y), col_box, 2.0)
	# Interocular gap marker
	draw_line(Vector2(eye_l + 11 * s.x, eye_y - 3), Vector2(eye_r - 11 * s.x, eye_y - 3), Color(0.8, 0.2, 0.8, 0.9), 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(origin.x - 18, eye_y - 8), "Gap: 23", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.8, 0.2, 0.8, 0.9))
	
	# 5. Shoulder Span Line (at y = -68 in character space)
	var sh_y: float = origin.y - 68.0 * s.y
	var sh_w: float = NemiProportions.SHOULDER_WIDTH * s.x
	draw_line(Vector2(origin.x - sh_w * 0.5, sh_y), Vector2(origin.x + sh_w * 0.5, sh_y), col_box, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(origin.x + sh_w * 0.5 + 4, sh_y + 4), "Shoulders: 88", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, col_text)
	
	# 6. Floor Contact Line (Ground contact at y = +200 in character space)
	var floor_y: float = origin.y + 200.0 * s.y
	draw_line(Vector2(origin.x - 120, floor_y), Vector2(origin.x + 120, floor_y), Color(0.2, 0.8, 0.2, 0.8), 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(origin.x + 125, floor_y + 4), "Ground: y = 640", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.2, 0.8, 0.2, 0.9))
