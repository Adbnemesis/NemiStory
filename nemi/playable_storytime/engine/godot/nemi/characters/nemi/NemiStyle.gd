class_name NemiStyle
extends RefCounted

## Master Style & Palette Controller for NEMI
## Supports instant, 100% geometry-preserving switching between:
## - COLOR (faithful to canonical design sheet)
## - MONOCHROME (faithful to finished YouTube storytelling ink illustration)

signal style_changed

enum ArtMode {
	COLOR,
	MONOCHROME
}

var current_mode: ArtMode = ArtMode.COLOR

# Line weight hierarchy (ensures clear visual depth and refined calligraphic presence)
var outer_contour_width: float = 2.4     # Clean outer silhouette ink
var silhouette_detail_width: float = 2.0 # Secondary structural contours
var inner_line_width: float = 1.5        # Fabric folds, inner seams
var detail_line_width: float = 1.1       # Delicate creases, hatching, nose/ear details
var lash_line_width: float = 3.4         # Bold calligraphic upper lash band

# Dynamic palette accessors
var ink_line_color: Color:
	get:
		return Color("#38101e") # Deep warm blackberry inking

var hair_color: Color:
	get:
		return Color("#d64937") if current_mode == ArtMode.COLOR else Color("#ffffff")

var hair_shadow_color: Color:
	get:
		return Color("#a83023") if current_mode == ArtMode.COLOR else Color("#ede9e3")

var hair_highlight_color: Color:
	get:
		return Color("#e86b59") if current_mode == ArtMode.COLOR else Color("#ffffff")

var skin_color: Color:
	get:
		return Color("#fcf0e6") if current_mode == ArtMode.COLOR else Color("#ffffff")

var skin_shadow_color: Color:
	get:
		return Color("#edd2c0") if current_mode == ArtMode.COLOR else Color("#f5f3ef")

var blush_color: Color:
	get:
		# Soft warm peach-pink blush in both modes
		return Color(0.98, 0.60, 0.58, 0.40) if current_mode == ArtMode.COLOR else Color(0.95, 0.55, 0.65, 0.35)

var blush_hatch_color: Color:
	get:
		return Color("#b83a2d") if current_mode == ArtMode.COLOR else Color("#7a2b3f")

var eye_sclera_color: Color:
	get:
		return Color("#ffffff")

var eye_iris_color: Color:
	get:
		return Color("#2da866") if current_mode == ArtMode.COLOR else Color("#2b2826")

var eye_pupil_color: Color:
	get:
		return Color("#0e2e1a") if current_mode == ArtMode.COLOR else Color("#141213")

var eye_highlight_color: Color:
	get:
		return Color("#ffffff")

var mouth_lip_color: Color:
	get:
		return Color("#d64937") if current_mode == ArtMode.COLOR else Color("#38101e")

var mouth_interior_color: Color:
	get:
		return Color("#a83023") if current_mode == ArtMode.COLOR else Color("#2e0817")

var mouth_teeth_color: Color:
	get:
		return Color("#ffffff")

var mouth_tongue_color: Color:
	get:
		return Color("#f07d7d") if current_mode == ArtMode.COLOR else Color("#732537")

var hoodie_color: Color:
	get:
		return Color("#739879") if current_mode == ArtMode.COLOR else Color("#ffffff")

var hoodie_shadow_color: Color:
	get:
		return Color("#55775b") if current_mode == ArtMode.COLOR else Color("#edeae4")

var hoodie_drawstring_color: Color:
	get:
		return Color("#f4f2ea") if current_mode == ArtMode.COLOR else Color("#ffffff")

var skirt_color: Color:
	get:
		return Color("#234537") if current_mode == ArtMode.COLOR else Color("#222021")

var skirt_shadow_color: Color:
	get:
		return Color("#173026") if current_mode == ArtMode.COLOR else Color("#151415")

var skirt_pleat_color: Color:
	get:
		return Color("#1c382c") if current_mode == ArtMode.COLOR else Color("#121112")

var sock_color: Color:
	get:
		return Color("#ffffff")

var sock_shadow_color: Color:
	get:
		return Color("#ded9d0") if current_mode == ArtMode.COLOR else Color("#dedad4")

var shoe_base_color: Color:
	get:
		return Color("#ffffff") if current_mode == ArtMode.COLOR else Color("#ffffff")

var shoe_trim_color: Color:
	get:
		return Color("#2da866") if current_mode == ArtMode.COLOR else Color("#c8c4be")

var shoe_sole_color: Color:
	get:
		return Color("#ede9e1") if current_mode == ArtMode.COLOR else Color("#edeae4")

var shoe_tread_color: Color:
	get:
		return Color("#234537") if current_mode == ArtMode.COLOR else Color("#222021")

var bag_body_color: Color:
	get:
		return Color("#2e2b32") if current_mode == ArtMode.COLOR else Color("#252324")

var bag_strap_color: Color:
	get:
		return Color("#1e1b21") if current_mode == ArtMode.COLOR else Color("#181717")

var bag_badge_color: Color:
	get:
		return Color("#faf3df") if current_mode == ArtMode.COLOR else Color("#ffffff")

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()

func toggle_mode() -> void:
	if current_mode == ArtMode.COLOR:
		set_mode(ArtMode.MONOCHROME)
	else:
		set_mode(ArtMode.COLOR)
