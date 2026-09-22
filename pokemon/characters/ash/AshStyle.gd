class_name AshStyle
extends RefCounted

## Master Style & Palette Controller for ASH KETCHUM
## Enforces hand-drawn illustrated pen-and-ink aesthetics with canonical Indigo League colors.
## Supports instant switching between full COLOR and MONOCHROME ink-wash storytelling modes.

signal style_changed

enum ArtMode {
	COLOR,
	MONOCHROME
}

var current_mode: ArtMode = ArtMode.COLOR

# Line weight hierarchy
var outer_contour_width: float = 3.0
var inner_line_width: float = 1.8
var detail_line_width: float = 1.2
var lash_line_width: float = 3.2

# Palette accessors
var ink_color: Color:
	get:
		return Color("#262224")

var skin_color: Color:
	get:
		return Color("#f0be93") if current_mode == ArtMode.COLOR else Color("#fdfbf7")

var skin_shadow_color: Color:
	get:
		return Color("#d59663") if current_mode == ArtMode.COLOR else Color("#ede9e3")

var cap_red_color: Color:
	get:
		return Color("#d9383a") if current_mode == ArtMode.COLOR else Color("#4a4548")

var cap_white_color: Color:
	get:
		return Color("#fbf8f3") if current_mode == ArtMode.COLOR else Color("#ffffff")

var cap_logo_color: Color:
	get:
		return Color("#2a9d8f") if current_mode == ArtMode.COLOR else Color("#262224")

var cap_visor_color: Color:
	get:
		return Color("#d9383a") if current_mode == ArtMode.COLOR else Color("#4a4548")

var cap_visor_shadow_color: Color:
	get:
		return Color("#8f2325") if current_mode == ArtMode.COLOR else Color("#2b282a")

var bag_green_color: Color:
	get:
		return Color("#4c8b3e") if current_mode == ArtMode.COLOR else Color("#45434f")

var bag_strap_color: Color:
	get:
		return Color("#5ca24c") if current_mode == ArtMode.COLOR else Color("#56535f")

var bag_pocket_color: Color:
	get:
		return Color("#e67e22") if current_mode == ArtMode.COLOR else Color("#a8a3ab")

var hair_color: Color:
	get:
		return Color("#1e1d24")

var hair_highlight_color: Color:
	get:
		return Color("#3a3845") if current_mode == ArtMode.COLOR else Color("#45434f")

var eye_iris_color: Color:
	get:
		return Color("#3d281d") if current_mode == ArtMode.COLOR else Color("#302c2e")

var eye_sclera_color: Color:
	get:
		return Color("#ffffff")

var vest_blue_color: Color:
	get:
		return Color("#1d65a6") if current_mode == ArtMode.COLOR else Color("#4f4c54")

var vest_white_color: Color:
	get:
		return Color("#fbf8f3") if current_mode == ArtMode.COLOR else Color("#ffffff")

var vest_trim_color: Color:
	get:
		return Color("#f4a261") if current_mode == ArtMode.COLOR else Color("#d6d0d2")

var undershirt_color: Color:
	get:
		return Color("#212529")

var belt_color: Color:
	get:
		return Color("#723d1c") if current_mode == ArtMode.COLOR else Color("#302c2e")

var belt_buckle_color: Color:
	get:
		return Color("#ced4da")

var jeans_color: Color:
	get:
		return Color("#7fa6c7") if current_mode == ArtMode.COLOR else Color("#9c98a0")

var jeans_cuff_color: Color:
	get:
		return Color("#f5f5f5")

var glove_green_color: Color:
	get:
		return Color("#2d6a4f") if current_mode == ArtMode.COLOR else Color("#424045")

var glove_cuff_color: Color:
	get:
		return Color("#74c69d") if current_mode == ArtMode.COLOR else Color("#b8b4ba")

var shoe_white_color: Color:
	get:
		return Color("#f8f9fa")

var shoe_black_color: Color:
	get:
		return Color("#212529")

var shoe_red_color: Color:
	get:
		return Color("#d9383a") if current_mode == ArtMode.COLOR else Color("#555053")

var blush_color: Color:
	get:
		return Color(0.98, 0.55, 0.55, 0.45) if current_mode == ArtMode.COLOR else Color(0.2, 0.2, 0.2, 0.15)

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()
