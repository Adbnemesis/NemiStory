class_name CosmoStyle
extends RefCounted

## Master Style & Palette Controller for COSMO (Brawl Stars)
## Enforces hand-drawn illustrated pen-and-ink aesthetics with canonical astronomer colors.
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
	get:
		return Color("#201c24")

# Head & Observatory Dome
var head_dome_color: Color:
	get:
		return Color("#dde2ed") if current_mode == ArtMode.COLOR else Color("#f4f4f7")

var head_dome_shadow_color: Color:
	get:
		return Color("#b0b8cb") if current_mode == ArtMode.COLOR else Color("#d2d2d8")

var ear_bracket_color: Color:
	get:
		return Color("#c0c8d8") if current_mode == ArtMode.COLOR else Color("#d8d8de")

var ear_screw_color: Color:
	get:
		return Color("#505568") if current_mode == ArtMode.COLOR else Color("#55555c")

# Eye / Telescope Lens
var lens_barrel_color: Color:
	get:
		return Color("#2a2b36") if current_mode == ArtMode.COLOR else Color("#303036")

var lens_interior_color: Color:
	get:
		return Color("#3d1a58") if current_mode == ArtMode.COLOR else Color("#222228")

var pupil_glow_color: Color:
	get:
		return Color("#d870f0") if current_mode == ArtMode.COLOR else Color("#aaaaaa")

var pupil_white_color: Color:
	get:
		return Color("#ffffff")

# Mouth Grill
var mouth_grill_color: Color:
	get:
		return Color("#f6d678") if current_mode == ArtMode.COLOR else Color("#fdfdfd")

var mouth_grill_shadow_color: Color:
	get:
		return Color("#cfaf50") if current_mode == ArtMode.COLOR else Color("#d0d0d0")

# Torso & Clothing
var coat_blue_color: Color:
	get:
		return Color("#2464c8") if current_mode == ArtMode.COLOR else Color("#454854")

var coat_shadow_color: Color:
	get:
		return Color("#1a4896") if current_mode == ArtMode.COLOR else Color("#33353e")

var coat_cuff_color: Color:
	get:
		return Color("#58b4d8") if current_mode == ArtMode.COLOR else Color("#888a94")

var vest_magenta_color: Color:
	get:
		return Color("#c4285e") if current_mode == ArtMode.COLOR else Color("#605862")

var vest_shadow_color: Color:
	get:
		return Color("#88163e") if current_mode == ArtMode.COLOR else Color("#443e46")

var shirt_white_color: Color:
	get:
		return Color("#f4f6fa") if current_mode == ArtMode.COLOR else Color("#ffffff")

var shirt_shadow_color: Color:
	get:
		return Color("#d0d6e4") if current_mode == ArtMode.COLOR else Color("#e0e0e4")

var tie_orange_color: Color:
	get:
		return Color("#f07820") if current_mode == ArtMode.COLOR else Color("#78757a")

# Attractor Gauntlet & Robotic Limbs
var attractor_cuff_color: Color:
	get:
		return Color("#dce2ee") if current_mode == ArtMode.COLOR else Color("#eeeeee")

var attractor_bracket_color: Color:
	get:
		return Color("#dc3232") if current_mode == ArtMode.COLOR else Color("#555555")

var attractor_badge_color: Color:
	get:
		return Color("#f8be28") if current_mode == ArtMode.COLOR else Color("#bbbbbb")

var robot_metal_color: Color:
	get:
		return Color("#363846") if current_mode == ArtMode.COLOR else Color("#38383e")

var robot_metal_highlight_color: Color:
	get:
		return Color("#525568") if current_mode == ArtMode.COLOR else Color("#585860")

var robot_metal_shadow_color: Color:
	get:
		return Color("#22232c") if current_mode == ArtMode.COLOR else Color("#222226")

# Energy / Levitation Rings
var energy_ring_color: Color:
	get:
		return Color(0.38, 0.82, 1.0, 0.45) if current_mode == ArtMode.COLOR else Color(0.9, 0.9, 0.9, 0.35)

var energy_core_color: Color:
	get:
		return Color(0.85, 0.96, 1.0, 0.85) if current_mode == ArtMode.COLOR else Color(1.0, 1.0, 1.0, 0.75)

# Celestial Orbs & Doodles
var celestial_planet_color: Color:
	get:
		return Color("#3ca4f0") if current_mode == ArtMode.COLOR else Color("#66666e")

var celestial_ring_color: Color:
	get:
		return Color("#8ae0ff") if current_mode == ArtMode.COLOR else Color("#cccccc")

var doodle_ink_color: Color:
	get:
		return Color("#201c24")

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()
