class_name Episode00DebugOverlay
extends CanvasLayer

## Development Debug Overlay for Episode 00 Directing
## Displays:
## - Exact elapsed playback timecode
## - Active beat and dialogue segment
## - Active subtitle card text
## - Active expression FX & active SFX
## - Camera scale / framing
##
## HARD REQUIREMENT: Defaults to DISABLED (debug_mode = false) so production renders remain 100% clean.

@export var debug_mode: bool = false

var current_beat: String = "Beat 1"
var current_segment: String = "001"
var active_subtitle: String = ""
var active_fx: String = "none"
var active_sfx: String = "none"
var camera_status: String = "1.0x (Normal)"

var _panel: PanelContainer
var _info_label: Label
var _start_time: float = 0.0
var _elapsed_time: float = 0.0

func _ready() -> void:
	layer = 120 # Top-most UI overlay
	if not debug_mode:
		visible = false
		set_process(false)
		return
		
	_setup_hud()
	_start_time = Time.get_ticks_msec() / 1000.0

func _setup_hud() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(20, 20)
	
	# Dark semi-transparent background style
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.08, 0.12, 0.85)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	style_box.content_margin_left = 14
	style_box.content_margin_right = 14
	style_box.content_margin_top = 10
	style_box.content_margin_bottom = 10
	_panel.add_theme_stylebox_override("panel", style_box)
	
	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 14)
	_info_label.add_theme_color_override("font_color", Color("#4da6ff"))
	_panel.add_child(_info_label)
	add_child(_panel)

func _process(delta: float) -> void:
	if not debug_mode:
		return
	_elapsed_time += delta
	var minutes := int(_elapsed_time) / 60
	var seconds := int(_elapsed_time) % 60
	var centis := int((_elapsed_time - int(_elapsed_time)) * 100.0)
	var time_str := "%02d:%02d.%02d" % [minutes, seconds, centis]
	
	_info_label.text = """[NEMI EP00 DIRECTING HUD]
TIME   : %s
BEAT   : %s | SEGMENT: %s
SUBTITLE: %s
FX     : %s
SFX    : %s
CAMERA : %s""" % [time_str, current_beat, current_segment, active_subtitle, active_fx, active_sfx, camera_status]

func update_event(p_beat: String, p_seg: String, p_sub: String = "", p_fx: String = "none", p_sfx: String = "none", p_cam: String = "1.0x") -> void:
	current_beat = p_beat
	current_segment = p_seg
	if not p_sub.is_empty(): active_subtitle = p_sub
	active_fx = p_fx
	active_sfx = p_sfx
	camera_status = p_cam
