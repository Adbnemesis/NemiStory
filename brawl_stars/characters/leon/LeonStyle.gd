class_name LeonStyle
extends RefCounted

## Master Style & Palette Controller for LEON (Brawl Stars)
## Enforces hand-drawn illustrated pen-and-ink aesthetics with canonical chameleon hoodie colors.
## Supports instant switching between full COLOR and MONOCHROME ink-wash storytelling modes.

signal style_changed

enum ArtMode {
	COLOR,
	MONOCHROME
}

var current_mode: ArtMode = ArtMode.COLOR

# Line weight hierarchy (organic hand-drawn linework)
var outer_contour_width: float = 3.2
var inner_line_width: float = 2.0
var detail_line_width: float = 1.3
var lash_line_width: float = 3.0

# -------------------------------------------------------------------------
# PALETTE ACCESSORS
# -------------------------------------------------------------------------

var ink_color: Color:
	get: return Color("#1e1a24")

# Chameleon Hoodie & Cowl
var hood_green_color: Color:
	get: return Color("#1ea838") if current_mode == ArtMode.COLOR else Color("#4c544e")

var hood_green_shadow_color: Color:
	get: return Color("#127024") if current_mode == ArtMode.COLOR else Color("#323834")

var hood_green_highlight_color: Color:
	get: return Color("#36ce54") if current_mode == ArtMode.COLOR else Color("#68726a")

var hood_orange_color: Color:
	get: return Color("#f47818") if current_mode == ArtMode.COLOR else Color("#dedede")

var hood_orange_shadow_color: Color:
	get: return Color("#b8520e") if current_mode == ArtMode.COLOR else Color("#b0b0b0")

# Chameleon Hoodie Eyes (Dual Blue Turrets)
var cham_turret_blue_color: Color:
	get: return Color("#1d8cf8") if current_mode == ArtMode.COLOR else Color("#4c5460")

var cham_turret_shadow_color: Color:
	get: return Color("#0a5ec2") if current_mode == ArtMode.COLOR else Color("#2e3238")

var cham_turret_recess_color: Color:
	get: return Color("#063e80") if current_mode == ArtMode.COLOR else Color("#1a1c20")

var cham_turret_highlight_color: Color:
	get: return Color("#60a5fa") if current_mode == ArtMode.COLOR else Color("#808892")

var cham_eye_white_color: Color:
	get: return Color("#ffffff")

var cham_pupil_blue_color: Color:
	get: return Color("#1d8cf8") if current_mode == ArtMode.COLOR else Color("#2a2a2a")

# Red Hood Brim Accent (Chameleon Tongue/Eyelid Flap)
var hood_red_accent_color: Color:
	get: return Color("#e11d48") if current_mode == ArtMode.COLOR else Color("#383840")

var hood_red_shadow_color: Color:
	get: return Color("#9f1239") if current_mode == ArtMode.COLOR else Color("#202024")

# Face & Skin Under Cowl
var skin_tan_color: Color:
	get: return Color("#c86a38") if current_mode == ArtMode.COLOR else Color("#d6d0c8")

var skin_tan_shadow_color: Color:
	get: return Color("#96421a") if current_mode == ArtMode.COLOR else Color("#98928a")

var cowl_deep_shadow_color: Color:
	get:
		if current_mode == ArtMode.COLOR:
			return Color(0.08, 0.14, 0.08, 0.72)
		return Color(0.12, 0.12, 0.14, 0.82)

var mouth_tooth_color: Color:
	get: return Color("#ffffff")

var mouth_interior_color: Color:
	get: return Color("#500724") if current_mode == ArtMode.COLOR else Color("#28282c")

# Signature Lollipop (Magenta/Pink Candy Ball with White Stick)
var lollipop_candy_color: Color:
	get: return Color("#f43f5e") if current_mode == ArtMode.COLOR else Color("#dedede")

var lollipop_candy_shadow_color: Color:
	get: return Color("#be123c") if current_mode == ArtMode.COLOR else Color("#909090")

var lollipop_blue_color: Color:
	get: return Color("#24a4f4") if current_mode == ArtMode.COLOR else Color("#e0e0e0")

var lollipop_shadow_color: Color:
	get: return Color("#1668b4") if current_mode == ArtMode.COLOR else Color("#909090")

var lollipop_stick_color: Color:
	get: return Color("#f8f8fa")

# Kangaroo Pouch & Pocket
var pouch_blue_color: Color:
	get: return Color("#0ea5e9") if current_mode == ArtMode.COLOR else Color("#444c58")

var pouch_blue_shadow_color: Color:
	get: return Color("#0284c7") if current_mode == ArtMode.COLOR else Color("#2c323c")

# Industrial Zipper & Pouch
var zipper_metal_color: Color:
	get: return Color("#a4b4c8") if current_mode == ArtMode.COLOR else Color("#dcdfe4")

var zipper_shadow_color: Color:
	get: return Color("#5e6c7e") if current_mode == ArtMode.COLOR else Color("#787c84")

# Gloves / Mittens
var mitten_blue_color: Color:
	get: return Color("#2074e0") if current_mode == ArtMode.COLOR else Color("#383844")

var mitten_shadow_color: Color:
	get: return Color("#144ca8") if current_mode == ArtMode.COLOR else Color("#24242c")

# Shorts, Legs & Tail
var shorts_indigo_color: Color:
	get: return Color("#242840") if current_mode == ArtMode.COLOR else Color("#2c2c34")

var shorts_shadow_color: Color:
	get: return Color("#161828") if current_mode == ArtMode.COLOR else Color("#1a1a20")

var shuriken_metal_color: Color:
	get: return Color("#406894") if current_mode == ArtMode.COLOR else Color("#505460")

var shuriken_glow_color: Color:
	get: return Color("#48c8f8") if current_mode == ArtMode.COLOR else Color("#c8c8d0")

# FX Colors
var sweat_color: Color:
	get: return Color("#48b8f8") if current_mode == ArtMode.COLOR else Color("#c0c0c8")

var anger_color: Color:
	get: return Color("#e62838") if current_mode == ArtMode.COLOR else Color("#222228")

var sparkle_color: Color:
	get: return Color("#ffe240") if current_mode == ArtMode.COLOR else Color("#ffffff")

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
