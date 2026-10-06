extends "res://nemi/characters/nemi/fx/elements/FXSad.gd"
## Exact canonical Nemi tear, fully held for this static promotional image.
func _ready() -> void:
	style_type = SadStyle.TEARDROP
	entrance_style = EntranceStyle.SNAP
	auto_dismiss_time = 0.0
	follow_anchor = false
	anchor_offset = Vector2.ZERO
	draw_progress = 1.0
	erase_progress = 0.0
	super._ready()
	process_mode = Node.PROCESS_MODE_DISABLED
