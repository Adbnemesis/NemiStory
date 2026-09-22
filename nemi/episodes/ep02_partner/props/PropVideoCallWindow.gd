class_name PropVideoCallWindow
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Video Call Window Frame for Episode 02
## Hand-drawn generic split video window representing online college lockdown interaction.
## Features two participant frames, camera/mic icons, and Wi-Fi indicator.

var call_active: bool = true
var _blink_timer: float = 0.0

func _init() -> void:
	prop_name = "video_call_window"
	current_state = "active"

func _process(delta: float) -> void:
	_blink_timer += delta
	queue_redraw()

func _draw() -> void:
	var w := 160.0
	var h := 105.0
	
	# Main window frame
	var frame_poly := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.5), Vector2(w * 0.5, -h * 0.5),
		Vector2(w * 0.5, h * 0.5), Vector2(-w * 0.5, h * 0.5)
	])
	draw_colored_polygon(frame_poly, Color("#fdfbf7"))
	draw_polyline(frame_poly, Color("#2b2623"), 3.0)
	
	# Top title bar
	draw_line(Vector2(-w * 0.5, -h * 0.5 + 18), Vector2(w * 0.5, -h * 0.5 + 18), Color("#2b2623"), 2.0)
	# Window buttons (three little charcoal dots)
	draw_circle(Vector2(-w * 0.5 + 12, -h * 0.5 + 9), 3.0, Color("#2b2623"))
	draw_circle(Vector2(-w * 0.5 + 22, -h * 0.5 + 9), 3.0, Color("#2b2623"))
	draw_circle(Vector2(-w * 0.5 + 32, -h * 0.5 + 9), 3.0, Color("#2b2623"))
	
	# Split divider between participant frames
	draw_line(Vector2(0, -h * 0.5 + 18), Vector2(0, h * 0.5), Color("#2b2623"), 2.0)
	
	# Left Frame: Nemi silhouette avatar (Auburn bun hint)
	var left_center := Vector2(-w * 0.25, 12)
	draw_circle(left_center + Vector2(0, -8), 12.0, Color("#b84328")) # Ginger hair hint
	draw_circle(left_center + Vector2(0, -5), 9.0, Color("#fbeddb"))  # Face
	draw_circle(left_center + Vector2(0, 18), 16.0, Color("#536b5c")) # Olive hoodie
	draw_arc(left_center + Vector2(0, -8), 12.0, 0, TAU, 16, Color("#2b2623"), 1.8)
	
	# Right Frame: ADB stylish avatar (Spiky dark slate hair, cyan aviator goggles, dark techwear collar)
	var right_center := Vector2(w * 0.25, 12)
	# Techwear jacket body
	draw_circle(right_center + Vector2(0, 19), 17.0, Color("#1f242d")) # Dark slate techwear
	# Popped collar edges
	draw_line(right_center + Vector2(-12, 12), right_center + Vector2(-4, 22), Color("#2b2623"), 2.2)
	draw_line(right_center + Vector2(12, 12), right_center + Vector2(4, 22), Color("#2b2623"), 2.2)
	# Face base
	draw_circle(right_center + Vector2(0, -5), 9.5, Color("#fbeddb"))  # Face
	# Spiky dark layered hair
	var hair_pts := PackedVector2Array([
		right_center + Vector2(-12, -3),
		right_center + Vector2(-14, -12),
		right_center + Vector2(-7, -18),
		right_center + Vector2(0, -19),
		right_center + Vector2(8, -17),
		right_center + Vector2(14, -11),
		right_center + Vector2(12, -2),
		right_center + Vector2(5, -9),
		right_center + Vector2(-4, -9)
	])
	draw_colored_polygon(hair_pts, Color("#1e222a"))
	draw_polyline(hair_pts, Color("#2b2623"), 1.6)
	
	# Cool Goggles on forehead/eyes
	# Strap
	draw_line(right_center + Vector2(-11, -8), right_center + Vector2(11, -8), Color("#3e322a"), 2.2)
	# Left Goggle Rim & Tinted Lens
	draw_rect(Rect2(right_center.x - 9, right_center.y - 12, 8, 7), Color("#2d333b"))
	draw_rect(Rect2(right_center.x - 8, right_center.y - 11, 6, 5), Color("#38d9d4"))
	draw_line(right_center + Vector2(-8, -11), right_center + Vector2(-3, -7), Color(1, 1, 1, 0.8), 1.2)
	# Right Goggle Rim & Tinted Lens
	draw_rect(Rect2(right_center.x + 1, right_center.y - 12, 8, 7), Color("#2d333b"))
	draw_rect(Rect2(right_center.x + 2, right_center.y - 11, 6, 5), Color("#38d9d4"))
	draw_line(right_center + Vector2(2, -11), right_center + Vector2(7, -7), Color(1, 1, 1, 0.8), 1.2)
	# Bridge
	draw_line(right_center + Vector2(-1, -9), right_center + Vector2(1, -9), Color("#e2aa36"), 1.8)
	
	# Wi-Fi icon in top-right corner (blinking dot)
	var wifi_pos := Vector2(w * 0.5 - 18, -h * 0.5 + 9)
	draw_arc(wifi_pos, 6.0, -PI * 0.75, -PI * 0.25, 8, Color("#2b2623"), 1.6)
	draw_arc(wifi_pos, 3.5, -PI * 0.75, -PI * 0.25, 6, Color("#2b2623"), 1.6)
	var wifi_col := Color("#558268") if fmod(_blink_timer, 1.2) < 0.8 else Color("#2b2623")
	draw_circle(wifi_pos + Vector2(0, 2), 1.5, wifi_col)
