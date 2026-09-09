class_name WorldStyle
extends RefCounted

## Master Style & Palette Controller for NEMI's Illustrated World
## Guarantees that all props, environments, doodles, and annotations appear
## as though they were hand-drawn by the exact same creator who drew Nemi.
##
## Supports instant switching between:
## - COLOR: Restrained, soft pastel paper palette harmonizing with Nemi's outfit
## - MONOCHROME: Authentic ink-on-paper illustration style (deep ink + white/light washes)

signal style_changed

enum ArtMode {
	COLOR,
	MONOCHROME
}

var current_mode: ArtMode = ArtMode.COLOR

# Shared line weight hierarchy
var outer_contour_width: float = 2.4      # Primary outer silhouette ink
var structural_width: float = 2.0         # Secondary structural forms (desk edges, screen bevels)
var inner_line_width: float = 1.5         # Seams, keys, details
var detail_line_width: float = 1.1        # Subtle hatching, creases, minor accents
var doodle_width: float = 2.2             # Expressive hand-drawn doodle weight

# Master inking color (shared with Nemi)
var ink_line_color: Color:
	get:
		return Color("#38101e") # Deep warm blackberry inking

# Background paper canvas color
var paper_bg_color: Color:
	get:
		return Color("#faf7f5")

var floor_line_color: Color:
	get:
		return Color(0.24, 0.03, 0.12, 0.35) if current_mode == ArtMode.COLOR else Color(0.22, 0.08, 0.14, 0.40)

# Environmental materials (wood, surfaces, furniture)
var wood_surface: Color:
	get:
		return Color("#e2d5c5") if current_mode == ArtMode.COLOR else Color("#ffffff")

var wood_shadow: Color:
	get:
		return Color("#c4b39e") if current_mode == ArtMode.COLOR else Color("#edeae4")

var wood_dark: Color:
	get:
		return Color("#8c7661") if current_mode == ArtMode.COLOR else Color("#38101e")

# Tech & metal materials (laptops, phones, desk lamp)
var metal_slate: Color:
	get:
		return Color("#4a4752") if current_mode == ArtMode.COLOR else Color("#38101e")

var metal_dark: Color:
	get:
		return Color("#2e2b32") if current_mode == ArtMode.COLOR else Color("#222021")

var metal_light: Color:
	get:
		return Color("#f0eef5") if current_mode == ArtMode.COLOR else Color("#ffffff")

var screen_glow: Color:
	get:
		return Color("#e6f4f8") if current_mode == ArtMode.COLOR else Color("#ffffff")

var screen_off: Color:
	get:
		return Color("#1e1b21") if current_mode == ArtMode.COLOR else Color("#181717")

# Fabric & decorative room accents (bedding, plants, curtains)
var accent_mint: Color:
	get:
		return Color("#8cb399") if current_mode == ArtMode.COLOR else Color("#ffffff")

var accent_mint_shadow: Color:
	get:
		return Color("#6b9177") if current_mode == ArtMode.COLOR else Color("#edeae4")

var accent_rose: Color:
	get:
		return Color("#d98c8c") if current_mode == ArtMode.COLOR else Color("#ffffff")

var accent_yellow: Color:
	get:
		return Color("#f6d365") if current_mode == ArtMode.COLOR else Color("#ffffff")

var accent_blue: Color:
	get:
		return Color("#82aaff") if current_mode == ArtMode.COLOR else Color("#ffffff")

var plant_pot: Color:
	get:
		return Color("#d48872") if current_mode == ArtMode.COLOR else Color("#ffffff")

# Doodle and annotation ink accents
var doodle_accent_color: Color:
	get:
		# Vivid storytime red in color mode; master ink in monochrome
		return Color("#d64937") if current_mode == ArtMode.COLOR else Color("#38101e")

var doodle_highlight_color: Color:
	get:
		return Color(0.96, 0.83, 0.40, 0.45) if current_mode == ArtMode.COLOR else Color(0.85, 0.85, 0.85, 0.35)

func set_mode(mode: ArtMode) -> void:
	if current_mode != mode:
		current_mode = mode
		style_changed.emit()

func toggle_mode() -> void:
	if current_mode == ArtMode.COLOR:
		set_mode(ArtMode.MONOCHROME)
	else:
		set_mode(ArtMode.COLOR)

func get_mode_name() -> String:
	return "COLOR" if current_mode == ArtMode.COLOR else "MONOCHROME"

func is_color() -> bool:
	return current_mode == ArtMode.COLOR

func is_monochrome() -> bool:
	return current_mode == ArtMode.MONOCHROME

func get_ink_color() -> Color:
	return ink_line_color

func get_paper_color() -> Color:
	return paper_bg_color


