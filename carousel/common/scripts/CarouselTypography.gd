class_name CarouselTypography
extends RefCounted

## Master Typography Engine for Carousels
## Manages smart word-wrapping, hierarchical font sizing, and watercolor highlighter washes.

const FONT_PATRICK = preload("res://assets/fonts/PatrickHand-Regular.ttf")
const FONT_CAVEAT = preload("res://assets/fonts/Caveat-Bold.ttf")
const FONT_GOCHI = preload("res://assets/fonts/GochiHand-Regular.ttf")
const FONT_IMPACT = preload("res://assets/fonts/Impact.ttf")

static func draw_wrapped_text(
	canvas: CanvasItem,
	text: String,
	rect: Rect2,
	font: Font,
	font_size: int,
	color: Color,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT,
	line_spacing: float = 8.0,
	highlight_words: Array = [],
	highlight_color: Color = Color(0, 0, 0, 0)
) -> float:
	var words := text.split(" ")
	var lines: Array[String] = []
	var current_line := ""
	
	for w in words:
		var test_line = (current_line + " " + w).strip_edges()
		var line_width := font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		if line_width > rect.size.x and not current_line.is_empty():
			lines.append(current_line)
			current_line = w
		else:
			current_line = test_line
	if not current_line.is_empty():
		lines.append(current_line)
	
	var line_height := font.get_height(font_size) + line_spacing
	var total_h := lines.size() * line_height
	var cur_y := rect.position.y + font.get_ascent(font_size)
	
	# Optional Highlighter Washes behind specific words
	if highlight_color.a > 0.0 and not highlight_words.is_empty():
		for line_idx in range(lines.size()):
			var l_text: String = lines[line_idx]
			var l_y := rect.position.y + line_idx * line_height
			for hw in highlight_words:
				if l_text.containsn(str(hw)):
					var highlight_rect := Rect2(rect.position.x - 6, l_y - 4, rect.size.x * 0.85, line_height + 4)
					canvas.draw_rect(highlight_rect, highlight_color)
	
	# Draw each line
	for line in lines:
		var line_sz := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var cur_x := rect.position.x
		if align == HORIZONTAL_ALIGNMENT_CENTER:
			cur_x = rect.position.x + (rect.size.x - line_sz.x) * 0.5
		elif align == HORIZONTAL_ALIGNMENT_RIGHT:
			cur_x = rect.position.x + (rect.size.x - line_sz.x)
			
		canvas.draw_string(font, Vector2(cur_x, cur_y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
		cur_y += line_height
		
	return total_h
