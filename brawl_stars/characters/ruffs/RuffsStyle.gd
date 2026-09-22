class_name RuffsStyle
extends RefCounted

## Master Style & Palette Controller for RUFFS (Colonel Ruffs - Brawl Stars)
## Enforces hand-drawn illustrated pen-and-ink aesthetics with canonical military space dog colors.
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
var lash_line_width: float = 3.0

# -------------------------------------------------------------------------
# PALETTE ACCESSORS
# -------------------------------------------------------------------------

var ink_color: Color:
	get: return Color("#201c24")

# Officer Uniform & Peaked Cap
var coat_magenta_color: Color:
	get: return Color("#b52085") if current_mode == ArtMode.COLOR else Color("#484650")

var coat_shadow_color: Color:
	get: return Color("#7a1258") if current_mode == ArtMode.COLOR else Color("#323038")

var coat_highlight_color: Color:
	get: return Color("#d2329e") if current_mode == ArtMode.COLOR else Color("#62606a")

var gold_accent_color: Color:
	get: return Color("#f4b820") if current_mode == ArtMode.COLOR else Color("#dcd8d0")

var gold_shadow_color: Color:
	get: return Color("#ba8810") if current_mode == ArtMode.COLOR else Color("#b0aca4")

var gold_highlight_color: Color:
	get: return Color("#ffe060") if current_mode == ArtMode.COLOR else Color("#f0ece4")

var navy_trim_color: Color:
	get: return Color("#1a2038") if current_mode == ArtMode.COLOR else Color("#222228")

var navy_shadow_color: Color:
	get: return Color("#101424") if current_mode == ArtMode.COLOR else Color("#16161c")

# Cap Emblem & Metal Buckles
var silver_badge_color: Color:
	get: return Color("#d8e0ec") if current_mode == ArtMode.COLOR else Color("#e0e0e4")

var silver_shadow_color: Color:
	get: return Color("#98a4b8") if current_mode == ArtMode.COLOR else Color("#a8a8b0")

var comm_node_color: Color:
	get: return Color("#4a78d8") if current_mode == ArtMode.COLOR else Color("#787884")

# Canine Fur & Anatomy
var fur_orange_color: Color:
	get: return Color("#e07538") if current_mode == ArtMode.COLOR else Color("#908a86")

var fur_shadow_color: Color:
	get: return Color("#b85422") if current_mode == ArtMode.COLOR else Color("#706a66")

var muzzle_cream_color: Color:
	get: return Color("#f2d5b0") if current_mode == ArtMode.COLOR else Color("#f5f2ee")

var muzzle_shadow_color: Color:
	get: return Color("#d8b48a") if current_mode == ArtMode.COLOR else Color("#d2cec8")

var ear_brown_color: Color:
	get: return Color("#8d4828") if current_mode == ArtMode.COLOR else Color("#58504c")

var ear_shadow_color: Color:
	get: return Color("#6a3218") if current_mode == ArtMode.COLOR else Color("#403a36")

var nose_black_color: Color:
	get: return Color("#1a181c")

var tongue_pink_color: Color:
	get: return Color("#f47285") if current_mode == ArtMode.COLOR else Color("#999999")

# Eyepatch & Eyes
var eyepatch_black_color: Color:
	get: return Color("#1a181c")

var eyepatch_cross_color: Color:
	get: return Color("#ffffff")

var eye_sclera_color: Color:
	get: return Color("#ffffff")

var eye_pupil_color: Color:
	get: return Color("#1a181c")

# Medal & Weapon
var medal_ribbon_color: Color:
	get: return Color("#48a0dc") if current_mode == ArtMode.COLOR else Color("#80808a")

var laser_red_color: Color:
	get: return Color("#ff2848") if current_mode == ArtMode.COLOR else Color("#333333")

var laser_cyan_color: Color:
	get: return Color("#38d0f8") if current_mode == ArtMode.COLOR else Color("#aaaaaa")

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()
