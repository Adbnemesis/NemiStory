class_name PikachuStyle
extends RefCounted

## Master Style & Palette Controller for PIKACHU
## Enforces hand-drawn illustrated pen-and-ink aesthetics with intentional line hierarchy.
## Supports instant switching between full COLOR and MONOCHROME ink-wash storytelling modes.

signal style_changed

enum ArtMode {
	COLOR,
	MONOCHROME
}

var current_mode: ArtMode = ArtMode.COLOR

# Line weight hierarchy
var outer_contour_width: float = 3.2
var inner_line_width: float = 2.0
var detail_line_width: float = 1.4
var eye_contour_width: float = 2.8

# Palette accessors
var ink_color: Color:
	get:
		return Color("#262224") # Warm organic charcoal ink

var fur_base_color: Color:
	get:
		return Color("#ffd13b") if current_mode == ArtMode.COLOR else Color("#fdfbf7")

var fur_shadow_color: Color:
	get:
		return Color("#f0b823") if current_mode == ArtMode.COLOR else Color("#ede9e3")

var fur_highlight_color: Color:
	get:
		return Color("#ffe885") if current_mode == ArtMode.COLOR else Color("#ffffff")

var cheek_color: Color:
	get:
		return Color("#e63946") if current_mode == ArtMode.COLOR else Color(0.2, 0.2, 0.2, 0.15)

var ear_tip_color: Color:
	get:
		return Color("#262224")

var brown_marking_color: Color:
	get:
		return Color("#854d0e") if current_mode == ArtMode.COLOR else Color("#3d3639")

var eye_pupil_color: Color:
	get:
		return Color("#242022")

var eye_highlight_color: Color:
	get:
		return Color("#ffffff")

var mouth_interior_color: Color:
	get:
		return Color("#9e2a2b") if current_mode == ArtMode.COLOR else Color("#453b40")

var tongue_color: Color:
	get:
		return Color("#f28482") if current_mode == ArtMode.COLOR else Color("#d4ccd0")

var spark_color: Color:
	get:
		return Color("#ffea00") if current_mode == ArtMode.COLOR else Color("#262224")

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()
