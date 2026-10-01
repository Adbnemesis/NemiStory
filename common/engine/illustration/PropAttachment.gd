extends Node
## External hand/prop attachment. Keeps character implementations untouched.
var prop: Node2D
var target: Node2D
var grip_offset := Vector2.ZERO
var inherit_rotation := true
var inherit_scale := true
var angle_offset := 0.0
var scale_multiplier := Vector2.ONE

func _ready() -> void:
	process_priority = 100 # after the character updates its hand node

func _process(_delta: float) -> void:
	update_attachment()

func update_attachment() -> void:
	if not is_instance_valid(prop) or not is_instance_valid(target):
		return
	if inherit_rotation:
		prop.global_rotation = target.global_rotation + angle_offset
	if inherit_scale:
		prop.global_scale = target.global_scale * scale_multiplier
	# Grip point belongs to the prop's local space, not the parent canvas.
	prop.global_position = target.global_position - prop.global_transform.basis_xform(grip_offset)
