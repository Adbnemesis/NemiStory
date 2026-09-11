class_name NemiFXDirector
extends Node2D

## Reusable Illustrated Expression & Reaction Orchestrator for NEMI.
## Bridges high-level comedic acting instructions (e.g. `nemi.react("shocked")`)
## with live procedural vector FX elements, facial exaggeration, and Bone2D tracking.

const NemiFXAnchor = preload("res://characters/nemi/fx/NemiFXAnchor.gd")
const NemiFXElement = preload("res://characters/nemi/fx/NemiFXElement.gd")

# Element preload map
const FX_CLASSES := {
	"confusion": preload("res://characters/nemi/fx/elements/FXConfusion.gd"),
	"question": preload("res://characters/nemi/fx/elements/FXConfusion.gd"),
	"shock": preload("res://characters/nemi/fx/elements/FXShock.gd"),
	"shocked": preload("res://characters/nemi/fx/elements/FXShock.gd"),
	"embarrassment": preload("res://characters/nemi/fx/elements/FXEmbarrassment.gd"),
	"embarrassed": preload("res://characters/nemi/fx/elements/FXEmbarrassment.gd"),
	"blush": preload("res://characters/nemi/fx/elements/FXEmbarrassment.gd"),
	"nervous": preload("res://characters/nemi/fx/elements/FXNervous.gd"),
	"sweat": preload("res://characters/nemi/fx/elements/FXNervous.gd"),
	"anger": preload("res://characters/nemi/fx/elements/FXAnger.gd"),
	"angry": preload("res://characters/nemi/fx/elements/FXAnger.gd"),
	"stress": preload("res://characters/nemi/fx/elements/FXAnger.gd"),
	"excitement": preload("res://characters/nemi/fx/elements/FXExcitement.gd"),
	"excited": preload("res://characters/nemi/fx/elements/FXExcitement.gd"),
	"sparkles": preload("res://characters/nemi/fx/elements/FXExcitement.gd"),
	"realization": preload("res://characters/nemi/fx/elements/FXRealization.gd"),
	"idea": preload("res://characters/nemi/fx/elements/FXRealization.gd"),
	"lightbulb": preload("res://characters/nemi/fx/elements/FXRealization.gd"),
	"panic": preload("res://characters/nemi/fx/elements/FXPanic.gd"),
	"sad": preload("res://characters/nemi/fx/elements/FXSad.gd"),
	"relief": preload("res://characters/nemi/fx/elements/FXRelief.gd"),
	"sigh": preload("res://characters/nemi/fx/elements/FXRelief.gd"),
	"deadpan": preload("res://characters/nemi/fx/elements/FXDeadpan.gd"),
	"silence": preload("res://characters/nemi/fx/elements/FXDeadpan.gd"),
	"ellipsis": preload("res://characters/nemi/fx/elements/FXDeadpan.gd"),
	"attention": preload("res://characters/nemi/fx/elements/FXAttention.gd")
}

const FXAttentionScript = preload("res://characters/nemi/fx/elements/FXAttention.gd")
const FXDeadpanScript = preload("res://characters/nemi/fx/elements/FXDeadpan.gd")

var character: Node2D = null
var active_fx_list: Array[NemiFXElement] = []

func _init(p_character: Node2D = null) -> void:
	character = p_character

func _ready() -> void:
	z_index = 25
	if not character and get_parent() is Node2D:
		character = get_parent()

# -------------------------------------------------------------------------
# HIGH-LEVEL REACTION COMPOSITION PRESETS (Section 22 & 23)
# Composes: eyes + brows + mouth + recoil/lean + FX + timing
# -------------------------------------------------------------------------

func react(reaction_name: String, intensity: int = 3, duration: float = 1.3) -> NemiFXElement:
	match reaction_name.to_lower():
		"shock", "shocked":
			return _react_shock(intensity, duration)
		"confusion", "confused":
			return _react_confusion(intensity, duration)
		"embarrassment", "embarrassed":
			return _react_embarrassment(intensity, duration)
		"nervous":
			return _react_nervous(intensity, duration)
		"anger", "angry":
			return _react_anger(intensity, duration)
		"excitement", "excited", "confident":
			return _react_excitement(intensity, duration)
		"realization", "idea":
			return _react_realization(intensity, duration)
		"panic":
			return _react_panic(intensity, duration)
		"sad":
			return _react_sad(intensity, duration)
		"relief":
			return _react_relief(intensity, duration)
		"deadpan":
			return _react_deadpan(intensity, duration)
		_:
			return fx(reaction_name, "head_top", intensity, duration)

func _react_shock(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("shocked")
	_apply_face_exaggeration("shock", intensity, duration * 0.7)
	
	# Recoil body slightly backward
	if character and character.get("skeleton"):
		var root: Bone2D = character.get("root_bone")
		if root:
			var tw := create_tween()
			var orig_rot := root.rotation
			tw.tween_property(root, "rotation", orig_rot - 0.08 * (float(intensity) / 3.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_interval(duration * 0.4)
			tw.tween_property(root, "rotation", orig_rot, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	return fx("shock", "head_top", intensity, duration)

func _react_confusion(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("confused")
	_apply_face_exaggeration("confusion", intensity, duration * 0.7)
	
	# Asymmetric brow + slight head tilt
	if character and character.get("head_bone"):
		var head: Bone2D = character.get("head_bone")
		var tw := create_tween()
		var orig_rot := head.rotation
		tw.tween_property(head, "rotation", orig_rot + 0.12, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_interval(duration * 0.5)
		tw.tween_property(head, "rotation", orig_rot, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	return fx("confusion", "head_right", intensity, duration)

func _react_embarrassment(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("embarrassed")
	_apply_face_exaggeration("embarrassment", intensity, duration * 0.7)
	
	# Eyes look away (down-left)
	if character and character.get("face"):
		var face: Node2D = character.get("face")
		if face.has_method("look"):
			face.look("down_left")
	
	return fx("embarrassment", "cheeks", intensity, duration)

func _react_nervous(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("annoyed")
	if character and character.get("face"):
		var face: Node2D = character.get("face")
		if face.has_method("look"):
			face.look("up_right")
	
	return fx("nervous", "head_right", intensity, duration)

func _react_anger(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("angry")
	_apply_face_exaggeration("anger", intensity, duration * 0.7)
	
	return fx("anger", "head_right", intensity, duration)

func _react_excitement(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("excited")
	_apply_face_exaggeration("excitement", intensity, duration * 0.7)
	
	# Chest puff upright
	if character and character.get("torso_bone"):
		var torso: Bone2D = character.get("torso_bone")
		var tw := create_tween()
		var orig_scale := torso.scale
		tw.tween_property(torso, "scale", orig_scale * Vector2(1.02, 1.05), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_interval(duration * 0.45)
		tw.tween_property(torso, "scale", orig_scale, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	return fx("excitement", "head_left", intensity, duration)

func _react_realization(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("excited")
	_apply_face_exaggeration("excitement", intensity, duration * 0.7)
	
	return fx("realization", "head_top", intensity, duration)

func _react_panic(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("terrified")
	_apply_face_exaggeration("panic", intensity, duration * 0.7)
	
	return fx("panic", "head_top", intensity, duration)

func _react_sad(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("sad")
	return fx("sad", "head_left", intensity, duration)

func _react_relief(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("happy")
	return fx("relief", "head_right", intensity, duration)

func _react_deadpan(intensity: int, duration: float) -> NemiFXElement:
	if character and character.has_method("set_expression"):
		character.set_expression("deadpan")
	return fx("deadpan", "face_center", intensity, duration)

func _apply_face_exaggeration(emotion: String, intensity: int, duration: float) -> void:
	if character and character.get("face"):
		var face: Node2D = character.get("face")
		if face.has_method("face_exaggerate"):
			face.face_exaggerate(emotion, intensity, duration)

# -------------------------------------------------------------------------
# LOW-LEVEL FX INSTANTIATION & LIFECYCLE (Section 59)
# -------------------------------------------------------------------------

func fx(fx_name: String, anchor_str: String = "", intensity: int = 3, duration: float = 1.2, custom_offset: Vector2 = Vector2.ZERO) -> NemiFXElement:
	var key := fx_name.to_lower().strip_edges()
	if not FX_CLASSES.has(key):
		push_warning("NemiFXDirector: Unknown FX type: %s" % fx_name)
		return null
	
	var element_script: Script = FX_CLASSES[key]
	var element: NemiFXElement = element_script.new()
	element.intensity = intensity
	if element is FXDeadpanScript:
		if key == "ellipsis":
			element.style_type = FXDeadpanScript.DeadpanStyle.ELLIPSIS
		else:
			element.style_type = FXDeadpanScript.DeadpanStyle.HORIZONTAL_DASH
	
	var anchor_type := element.anchor_type
	if not anchor_str.is_empty():
		anchor_type = NemiFXAnchor.from_string(anchor_str)
	
	# Determine palette from character style
	var is_mono := false
	var ink_col := Color("#3e081e")
	var acc_col := Color("#e67e22")
	var fill_col := Color("#fff8cc")
	
	if character and character.get("style"):
		var st: NemiStyle = character.get("style")
		is_mono = (st.current_mode == NemiStyle.ArtMode.MONOCHROME)
		ink_col = st.ink_line_color
		acc_col = Color("#e67e22") if not is_mono else ink_col
		fill_col = Color("#fff8cc") if not is_mono else Color(0.95, 0.95, 0.95, 0.85)
	
	element.set_palette(ink_col, acc_col, fill_col, is_mono)
	element.mount_to_anchor(character if character else self, anchor_type, custom_offset)
	
	add_child(element)
	active_fx_list.append(element)
	element.dismissed.connect(func(): active_fx_list.erase(element))
	print("[FX TRIGGERED] %s on %s (intensity: %d, dur: %.2fs)" % [key, anchor_str if not anchor_str.is_empty() else "default", intensity, duration])
	
	return element

# Convenience Direct Low-Level Helpers
func show_sweat(anchor: String = "head_right", intensity: int = 3, duration: float = 1.2) -> NemiFXElement:
	return fx("sweat", anchor, intensity, duration)

func show_question_mark(anchor: String = "head_right", intensity: int = 3, duration: float = 1.2) -> NemiFXElement:
	return fx("question", anchor, intensity, duration)

func show_shock_lines(anchor: String = "head_top", intensity: int = 3, duration: float = 1.0) -> NemiFXElement:
	return fx("shock", anchor, intensity, duration)

func show_blush(intensity: int = 3, duration: float = 1.5) -> NemiFXElement:
	return fx("blush", "cheeks", intensity, duration)

func show_stress_marks(anchor: String = "head_right", intensity: int = 3, duration: float = 1.2) -> NemiFXElement:
	return fx("stress", anchor, intensity, duration)

func show_sparkles(anchor: String = "head_left", intensity: int = 3, duration: float = 1.4) -> NemiFXElement:
	return fx("sparkles", anchor, intensity, duration)

func show_lightbulb(anchor: String = "head_top", intensity: int = 3, duration: float = 1.4) -> NemiFXElement:
	return fx("lightbulb", anchor, intensity, duration)

func show_panic(anchor: String = "head_top", intensity: int = 3, duration: float = 1.4) -> NemiFXElement:
	return fx("panic", anchor, intensity, duration)

func show_deadpan(intensity: int = 3, duration: float = 1.6) -> NemiFXElement:
	return fx("deadpan", "face_center", intensity, duration)

## Opt-in explicit three-dot ellipsis (Section 8: must be explicitly requested)
func show_ellipsis(anchor: String = "face_center", intensity: int = 2, duration: float = 1.5) -> NemiFXElement:
	return fx("ellipsis", anchor, intensity, duration)

# Attention directors
func draw_attention_circle(target_offset: Vector2, radius: float = 38.0, duration: float = 1.8) -> NemiFXElement:
	var el = fx("attention", "prop", 3, duration)
	if el is FXAttentionScript:
		el.attention_type = FXAttentionScript.AttentionType.CIRCLE
		el.target_offset = target_offset
		el.circle_radius = radius
	return el

func draw_attention_arrow(from_pos: Vector2, to_pos: Vector2, duration: float = 1.8) -> NemiFXElement:
	var el = fx("attention", "prop", 3, duration)
	if el is FXAttentionScript:
		el.attention_type = FXAttentionScript.AttentionType.ARROW
		el.arrow_start = from_pos
		el.arrow_end = to_pos
	return el

func draw_attention_highlight(target_offset: Vector2, width: float = 60.0, duration: float = 1.8) -> NemiFXElement:
	var el = fx("attention", "prop", 3, duration)
	if el is FXAttentionScript:
		el.attention_type = FXAttentionScript.AttentionType.HIGHLIGHT_UNDERLINE
		el.target_offset = target_offset
	return el

func clear_all_fx(immediate: bool = false) -> void:
	for elem in active_fx_list.duplicate():
		if is_instance_valid(elem):
			if immediate:
				elem.queue_free()
			else:
				elem.dismiss(0.15)
	active_fx_list.clear()
