class_name EdgarStyle
extends RefCounted

## Master Style & Palette Controller for EDGAR (Brawl Stars)
## Enforces hand-drawn illustrated pen-and-ink aesthetics with canonical emo punk colors.
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
var detail_line_width: float = 1.3
var lash_line_width: float = 3.2

# -------------------------------------------------------------------------
# PALETTE ACCESSORS
# -------------------------------------------------------------------------

var ink_color: Color:
	get: return Color("#1c1624")

# Skin & Emo Hair (Natural Warm Light Skin Tone)
var skin_pale_color: Color:
	get: return Color("#f6d8be") if current_mode == ArtMode.COLOR else Color("#eae2da")

var skin_light_color: Color:
	get: return Color("#f6d8be") if current_mode == ArtMode.COLOR else Color("#eae2da")

var skin_pale_shadow_color: Color:
	get: return Color("#d89e72") if current_mode == ArtMode.COLOR else Color("#bcae9e")

var skin_light_shadow_color: Color:
	get: return Color("#d89e72") if current_mode == ArtMode.COLOR else Color("#bcae9e")

var hair_black_color: Color:
	get: return Color("#181a28") if current_mode == ArtMode.COLOR else Color("#222228")

var hair_black_shadow_color: Color:
	get: return Color("#10121c") if current_mode == ArtMode.COLOR else Color("#141418")

var hair_black_highlight_color: Color:
	get: return Color("#2c3044") if current_mode == ArtMode.COLOR else Color("#383840")

# Signature Sentient Striped Scarf
var scarf_purple_color: Color:
	get: return Color("#2e1644") if current_mode == ArtMode.COLOR else Color("#2c2c34")

var scarf_purple_shadow_color: Color:
	get: return Color("#1a0c28") if current_mode == ArtMode.COLOR else Color("#1c1c22")

var scarf_white_color: Color:
	get: return Color("#eee8f6") if current_mode == ArtMode.COLOR else Color("#f2f2f4")

var scarf_white_shadow_color: Color:
	get: return Color("#c8c0d6") if current_mode == ArtMode.COLOR else Color("#d0d0d4")

# Red Punk Vest & Shirt
var vest_red_color: Color:
	get: return Color("#d62432") if current_mode == ArtMode.COLOR else Color("#4c4c54")

var vest_red_shadow_color: Color:
	get: return Color("#94141e") if current_mode == ArtMode.COLOR else Color("#34343a")

var shirt_dark_color: Color:
	get: return Color("#1e1a28") if current_mode == ArtMode.COLOR else Color("#202026")

var skull_white_color: Color:
	get: return Color("#f8f6fa")

var pin_yellow_color: Color:
	get: return Color("#f6c820") if current_mode == ArtMode.COLOR else Color("#e8e8ea")

# Punk Belt & Buckle
var belt_dark_color: Color:
	get: return Color("#241634") if current_mode == ArtMode.COLOR else Color("#26262e")

var stud_silver_color: Color:
	get: return Color("#d4d8e4") if current_mode == ArtMode.COLOR else Color("#e0e0e4")

var buckle_skull_color: Color:
	get: return Color("#72b0ee") if current_mode == ArtMode.COLOR else Color("#a4a8b4")

# Pants & Gloves
var pants_indigo_color: Color:
	get: return Color("#1c1828") if current_mode == ArtMode.COLOR else Color("#1e1e24")

var pants_stripe_color: Color:
	get: return Color("#e82848") if current_mode == ArtMode.COLOR else Color("#646470")

var glove_purple_color: Color:
	get: return Color("#361c52") if current_mode == ArtMode.COLOR else Color("#30303a")

var glove_shadow_color: Color:
	get: return Color("#221034") if current_mode == ArtMode.COLOR else Color("#1c1c24")

# Emo Fatigue & Eyeshadow
var eye_shadow_purple_color: Color:
	get:
		if current_mode == ArtMode.COLOR:
			return Color(0.24, 0.16, 0.32, 0.40)
		return Color(0.18, 0.18, 0.22, 0.40)

# FX Colors
var sweat_color: Color:
	get: return Color("#48b8f8") if current_mode == ArtMode.COLOR else Color("#c0c0c8")

var anger_color: Color:
	get: return Color("#e62838") if current_mode == ArtMode.COLOR else Color("#222228")

# -------------------------------------------------------------------------
# MODE SWITCHING
# -------------------------------------------------------------------------

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()

func toggle_mode() -> void:
	if current_mode == ArtMode.COLOR:
		set_mode(ArtMode.MONOCHROME)
	else:
		set_mode(ArtMode.COLOR)
