class_name NemiRigDebug
extends Node2D

## Visual debug overlay for NEMI's live Skeleton2D / Bone2D rig.
## Renders joint pivot circles, articulated bone connection lines, and labels.
## Zero runtime cost when disabled.

@export var enabled: bool = false:
	set(val):
		enabled = val
		visible = val
		set_process(val)
		queue_redraw()

@export var skeleton: Skeleton2D

func _ready() -> void:
	visible = enabled
	set_process(enabled)
	z_index = 200 # Above character

func _process(_delta: float) -> void:
	if enabled:
		queue_redraw()

func _draw() -> void:
	if not enabled or not skeleton:
		return
	
	# Traverse skeleton bone hierarchy
	for child in skeleton.get_children():
		if child is Bone2D:
			_draw_bone_recursive(child)

func _draw_bone_recursive(bone: Bone2D) -> void:
	var bone_global_pos: Vector2 = to_local(bone.global_position)
	
	# Determine color category
	var bone_name := bone.name.to_lower()
	var color := Color("#f1c40f") # Gold default
	if "hair" in bone_name:
		color = Color("#2ecc71") # Green
	elif "left" in bone_name:
		color = Color("#00d2d3") # Cyan
	elif "right" in bone_name:
		color = Color("#ff9ff3") # Pink/Magenta
	elif "torso" in bone_name or "root" in bone_name:
		color = Color("#ff6b6b") # Red/Orange
	elif "neck" in bone_name or "head" in bone_name:
		color = Color("#feca57") # Yellow
	elif "skirt" in bone_name:
		color = Color("#54a0ff") # Blue
	
	# Draw joint pivot circle
	draw_circle(bone_global_pos, 4.0, color)
	draw_circle(bone_global_pos, 2.0, Color.WHITE)
	
	# Draw lines to child Bone2Ds
	for child in bone.get_children():
		if child is Bone2D:
			var child_global_pos: Vector2 = to_local(child.global_position)
			draw_line(bone_global_pos, child_global_pos, color, 2.5)
			_draw_bone_recursive(child)
	
	# Draw name label (filter out tip bones for readability)
	if not "tip" in bone_name:
		var label_str := bone.name.replace("Bone", "")
		var font := ThemeDB.fallback_font
		var font_size := 10
		var text_pos := bone_global_pos + Vector2(6, 4)
		draw_string(font, text_pos + Vector2(1, 1), label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, 0.8))
		draw_string(font, text_pos, label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
