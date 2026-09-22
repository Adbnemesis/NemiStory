@tool
extends Node2D
class_name PropTypingHands

## Animated frantic doodle typing hands with key clatter effects
## Attached in front of Nemi's chest during "six entire hours researching..."

var time_elapsed: float = 0.0
var ink_color: Color = Color(0.18, 0.15, 0.14, 0.95)
var skin_color: Color = Color(1.0, 0.94, 0.88, 1.0)
var clack_labels: Array[String] = ["CLACK!", "TAP TAP", "CLICK", "SEARCH", "WIKIPEDIA", "PDF 1884"]

func _ready() -> void:
	scale = Vector2(0.85, 0.85)

func _process(delta: float) -> void:
	time_elapsed += delta
	queue_redraw()

func _draw() -> void:
	# Subtle mini laptop / keyboard silhouette
	var kb_rect = Rect2(-90, 20, 180, 45)
	draw_rect(kb_rect, Color(0.2, 0.22, 0.25, 0.8), true)
	draw_rect(kb_rect, ink_color, false, 2.5)
	
	# Key rows
	for row in range(3):
		for col in range(8):
			var kx = -75 + col * 20
			var ky = 26 + row * 10
			draw_rect(Rect2(kx, ky, 14, 7), Color(0.85, 0.87, 0.9, 0.8), true)
	
	# Animated frantic hands (left & right hands oscillating rapidly)
	var left_offset = sin(time_elapsed * 32.0) * 12.0
	var right_offset = cos(time_elapsed * 28.0) * 12.0
	
	# Left arm / hand blur
	var left_wrist = Vector2(-60, -10 + left_offset)
	draw_line(Vector2(-100, -35), left_wrist, ink_color, 12.0)
	draw_circle(left_wrist, 14.0, skin_color)
	draw_circle(left_wrist, 14.0, ink_color, false, 2.5)
	# Fingers tapping keys
	for f in range(3):
		var fx = left_wrist.x + 8 + f * 5
		var fy = left_wrist.y + 14 + sin(time_elapsed * 40.0 + f) * 5.0
		draw_line(left_wrist, Vector2(fx, fy), ink_color, 4.0)
		
	# Right arm / hand blur
	var right_wrist = Vector2(60, -10 + right_offset)
	draw_line(Vector2(100, -35), right_wrist, ink_color, 12.0)
	draw_circle(right_wrist, 14.0, skin_color)
	draw_circle(right_wrist, 14.0, ink_color, false, 2.5)
	# Fingers tapping keys
	for f in range(3):
		var fx = right_wrist.x - 8 - f * 5
		var fy = right_wrist.y + 14 + cos(time_elapsed * 36.0 + f) * 5.0
		draw_line(right_wrist, Vector2(fx, fy), ink_color, 4.0)
		
	# Sound effects floating up
	var font = ThemeDB.fallback_font
	if font:
		var sfx_idx = int(time_elapsed * 6.0) % clack_labels.size()
		var sfx_text = clack_labels[sfx_idx]
		var sfx_pos = Vector2(-40 + sin(time_elapsed * 10.0) * 30.0, -30 - fmod(time_elapsed * 40.0, 30.0))
		draw_string(font, sfx_pos, sfx_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(0.85, 0.2, 0.2, 0.9))
