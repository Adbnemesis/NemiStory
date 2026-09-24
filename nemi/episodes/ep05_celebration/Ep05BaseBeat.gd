class_name Ep05BaseBeat
extends Node2D

## Base Class for Episode 05 Beat Scenes: "WHAT IS GOING ON WITH YOUTUBE?"
## Provides:
## - Continuous lifelike character motion (organic idle breathing, natural blinks, micro-sways) to prevent ANY visual freezes.
## - Integrated dynamic celebration studio backdrop (smoothly evolves from studio to celebration wall to quiet warmth).
## - Hand-drawn live draw-on stroke helpers and comic expression FX.
## - Subtitle card sequencing (<= 5 words per card) and deterministic MovieWriter timing.

signal beat_finished()

const Episode05SubtitlesClass = preload("res://nemi/episodes/ep05_celebration/Episode05Subtitles.gd")
const NemiDoodleDirectorClass = preload("res://nemi/world/doodles/NemiDoodleDirector.gd")
const Ep05DoodlesClass = preload("res://nemi/episodes/ep05_celebration/Ep05Doodles.gd")
const Ep05LiveDoodlesClass = preload("res://nemi/episodes/ep05_celebration/Ep05LiveDoodles.gd")
const Ep05CelebrationBackdropClass = preload("res://nemi/episodes/ep05_celebration/Ep05CelebrationBackdrop.gd")
const HumanProps = preload("res://nemi/world/props/HumanProps.gd")
const HumanDoodles = preload("res://nemi/world/doodles/HumanDoodles.gd")

const STATE_NORMAL_STUDIO: int = 0
const STATE_SUSPENSE_WALL: int = 1
const STATE_CELEBRATION_WALL: int = 2
const STATE_COMMENT_IMMERSION: int = 3
const STATE_SINCERE_WARMTH: int = 4

@export var is_standalone: bool = false
@export var beat_number: int = 1
@export var beat_name: String = "Beat"

@onready var nemi = get_node_or_null("Nemi")
@onready var camera = get_node_or_null("StoryCamera2D")
@onready var world = get_node_or_null("WorldSystem")
@onready var subtitle_label: Label = get_node_or_null("UI/Subtitle")
@onready var voice_player: AudioStreamPlayer = get_node_or_null("VoicePlayer")

var studio_backdrop: Node2D
var doodle_director: Node2D
var human_props_layer: Node2D
var human_doodles_layer: Node2D

# V2 Hand-Drawn Furniture & Props
var chair_prop: Node2D
var desk_prop: Node2D
var phone_prop: Node2D
var mug_prop: Node2D
var r_hand: Node2D
var l_hand: Node2D

# V2 Stillness Principle: Zero procedural sinusoidal breathing bobbing during dialogue
var enable_lifelike_breathing: bool = false
var _breath_time: float = 0.0
var _blink_timer: float = 2.5
var _nemi_base_y: float = 480.0

func _ready() -> void:
	# 1. Setup workspace environment
	if world and world.has_method("set_environment"):
		world.set_environment(2, 2) # Workspace studio

	# 2. V2 Layers for Props and Hand-Drawn Doodles
	human_props_layer = Node2D.new()
	human_props_layer.name = "HumanPropsLayer"
	human_props_layer.z_index = 0
	add_child(human_props_layer)

	human_doodles_layer = HumanDoodles.new()
	human_doodles_layer.name = "HumanDoodlesLayer"
	human_doodles_layer.z_index = 20
	add_child(human_doodles_layer)

	# 3. Cache hand bones for dynamic prop attachment
	if nemi:
		r_hand = nemi.right_hand_bone if ("right_hand_bone" in nemi and nemi.right_hand_bone) else nemi.get_node_or_null("Skeleton2D/RootBone/TorsoBone/RightUpperArmBone/RightLowerArmBone/RightHandBone")
		l_hand = nemi.left_hand_bone if ("left_hand_bone" in nemi and nemi.left_hand_bone) else nemi.get_node_or_null("Skeleton2D/RootBone/TorsoBone/LeftUpperArmBone/LeftLowerArmBone/LeftHandBone")
		_nemi_base_y = nemi.position.y

	# 4. Spawn doodle director for legacy accents if needed
	doodle_director = NemiDoodleDirectorClass.new()
	doodle_director.name = "DoodleDirector"
	add_child(doodle_director)

	if subtitle_label:
		subtitle_label.visible = false
		subtitle_label.text = ""
		var font: FontFile = Ep05DoodlesClass.get_handwriting_font(false)
		if font:
			subtitle_label.add_theme_font_override("font", font)
		subtitle_label.add_theme_font_size_override("font_size", 34)
		subtitle_label.add_theme_color_override("font_color", Color("#fffef5"))
		subtitle_label.add_theme_color_override("font_outline_color", Color("#200b14"))
		subtitle_label.add_theme_constant_override("outline_size", 7)
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		subtitle_label.z_index = 25

	if is_standalone:
		call_deferred("start_beat")

func _process(delta: float) -> void:
	if not enable_lifelike_breathing or not is_instance_valid(nemi):
		return

	_breath_time += delta

	# 1. Subtle rhythmic chest/torso breathing cycle (~2.2s gentle sine wave)
	var breath_phase: float = sin(_breath_time * 2.8)
	var breath_bob: float = breath_phase * 1.6
	nemi.position.y = _nemi_base_y + breath_bob

	# Micro torso & head compensation
	if nemi.torso_bone:
		nemi.torso_bone.rotation += breath_phase * 0.008 * delta
	if nemi.head_bone:
		nemi.head_bone.rotation += -breath_phase * 0.005 * delta

	# 2. Natural automatic blinking cycle (every 2.8 to 4.2 seconds)
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_timer = randf_range(2.8, 4.2)
		if nemi.has_method("blink"):
			nemi.blink(0.14)

func start_beat() -> void:
	print("--- EPISODE 05 BEAT %d: %s STARTED ---" % [beat_number, beat_name.to_upper()])
	_run_beat_choreography()

func _run_beat_choreography() -> void:
	pass

func end_beat() -> void:
	hide_phone() # Always ensure phone is stowed away between beats!
	if doodle_director:
		doodle_director.clear_all(0.20)
	if subtitle_label:
		subtitle_label.text = ""
		subtitle_label.visible = false
	print("--- EPISODE 05 BEAT %d: %s COMPLETED at frame %d ---" % [beat_number, beat_name.to_upper(), Engine.get_process_frames()])
	beat_finished.emit()
	if is_standalone:
		await wait_seconds(0.2)
		get_tree().quit(0)

func wait_seconds(duration: float) -> void:
	var frames: int = maxi(1, int(round(duration * 30.0)))
	for i in range(frames):
		await RenderingServer.frame_post_draw

func play_segment(seg_id: String) -> void:
	Episode05SubtitlesClass.play_segment(subtitle_label, nemi, seg_id, self)

func _run_subtitle_cards(label: Label, character: Node2D, cards: Array) -> void:
	for c in cards:
		var dur: float = c["duration"]
		var emo: String = c.get("emotion", "normal")
		if label and is_instance_valid(label):
			label.visible = true
			label.text = c["text"]
		if character and is_instance_valid(character) and character.has_method("speak"):
			character.speak(c["text"], dur, emo)
		await wait_seconds(dur)
	if label and is_instance_valid(label):
		label.visible = false
		label.text = ""

# -----------------------------------------------------------------------------
# DYNAMIC CAMERA HELPERS
# -----------------------------------------------------------------------------

func cam_preset(preset: StoryCamera2D.ShotPreset, dur: float = 0.25, target: Node2D = null) -> void:
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(preset, dur, target)

func cam_punch(arg1: Variant = null, arg2: Variant = null, arg3: Variant = null) -> void:
	if not camera:
		return
	if arg1 is StoryCamera2D.ShotPreset:
		var dur: float = 0.15
		if arg2 is float:
			dur = arg2
		if camera.has_method("apply_preset"):
			camera.apply_preset(arg1, dur)
	elif arg1 is Vector2:
		var target_pos: Vector2 = camera.position + arg1
		var zoom_mult: float = 1.2
		var dur: float = 0.2
		if arg2 is float:
			zoom_mult = arg2
		if arg3 is float:
			dur = arg3
		if camera.has_method("punch_in"):
			camera.punch_in(target_pos, zoom_mult, dur)
		elif camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, dur)
	else:
		if camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.15)

func cam_push_in(amount: float = 0.20, dur: float = 3.0) -> void:
	if camera and camera.has_method("push_in"):
		camera.push_in(amount, dur)

func cam_shake(intensity: float = 6.0, dur: float = 0.35, _freq: float = 20.0) -> void:
	if camera and camera.has_method("shake"):
		camera.shake(intensity, dur)

func cam_reset(dur: float = 0.3) -> void:
	if camera:
		var tw := create_tween().set_parallel(true)
		tw.tween_property(camera, "rotation", 0.0, dur)
		if camera.has_method("apply_preset"):
			camera.apply_preset(StoryCamera2D.ShotPreset.MEDIUM, dur)

# -----------------------------------------------------------------------------
# V2 HAND-DRAWN STUDIO FURNITURE & PROP LIFECYCLE
# -----------------------------------------------------------------------------

func setup_studio_furniture(seated: bool = true) -> void:
	if not human_props_layer:
		return
	# 1. Studio wooden chair
	chair_prop = HumanProps.StoryChair.new()
	chair_prop.position = Vector2(540, 440)
	human_props_layer.add_child(chair_prop)

	# 2. Studio creator desk spanning across the right side
	desk_prop = HumanProps.StoryDesk.new()
	desk_prop.position = Vector2(590, 440)
	human_props_layer.add_child(desk_prop)

	# 3. Dynamic Interactive Ceramic Coffee Mug
	mug_prop = HumanProps.StoryMug.new()
	mug_prop.position = Vector2(720, 438) # Neatly placed on desk surface
	human_props_layer.add_child(mug_prop)

	# 4. Smartphone: Hidden by default! Only revealed when Nemi shows it!
	phone_prop = HumanProps.StoryPhone.new()
	phone_prop.visible = false
	human_props_layer.add_child(phone_prop)

	if nemi:
		if seated:
			nemi.position = Vector2(540, 360)
			nemi.set_pose("seated_at_desk_relaxed", 0.0)
		else:
			nemi.position = Vector2(540, 430)
			nemi.set_pose("relaxed_standing_left_weight", 0.0)

# Prop Lifecycle: Smartphone
func show_phone(state: HumanProps.StoryPhone.ScreenState = HumanProps.StoryPhone.ScreenState.VIEWS_RECAP, rot_deg: float = 4.0) -> void:
	if phone_prop and r_hand:
		phone_prop.show_in_hand(r_hand, state, Vector2(10, -18), deg_to_rad(rot_deg))
		if nemi:
			nemi.set_hand_pose_right(NemiLimbPart.HandPose.HOLD_PROP)

func attach_phone_to_hand(state: HumanProps.StoryPhone.ScreenState = HumanProps.StoryPhone.ScreenState.VIEWS_RECAP, rot_deg: float = 4.0) -> void:
	show_phone(state, rot_deg)

func hide_phone() -> void:
	if phone_prop:
		phone_prop.stow_away()
		if nemi:
			nemi.set_hand_pose_right(NemiLimbPart.HandPose.RELAXED)

# Prop Lifecycle: Coffee Mug
func attach_mug_to_hand(left_hand: bool = true) -> void:
	var target_hand = l_hand if left_hand else r_hand
	if mug_prop and target_hand:
		mug_prop.attach_to_hand(target_hand, Vector2(2, 4), deg_to_rad(-8.0 if left_hand else 8.0))
		if nemi:
			if left_hand:
				nemi.set_hand_pose_left(NemiLimbPart.HandPose.HOLD_PROP)
			else:
				nemi.set_hand_pose_right(NemiLimbPart.HandPose.HOLD_PROP)

func detach_mug_to_desk() -> void:
	if mug_prop:
		mug_prop.detach(Vector2(720, 438))
		if nemi:
			nemi.set_hand_pose_left(NemiLimbPart.HandPose.RELAXED)

func take_coffee_sip() -> void:
	attach_mug_to_hand(true)
	if nemi:
		nemi.set_pose("coffee_sip", 0.25)

# Background Interaction: Laptop
func type_on_laptop() -> void:
	if nemi:
		nemi.set_pose("seated_typing_laptop", 0.2)

func set_laptop_screen(state: int) -> void:
	if desk_prop and desk_prop.has_method("set_laptop_state"):
		desk_prop.set_laptop_state(state)

# -----------------------------------------------------------------------------
# CELEBRATION PROPS & DOODLE SPAWN HELPERS
# -----------------------------------------------------------------------------

func subscriber_counter(pos: Vector2 = Vector2(820, 240)) -> Node2D:
	return Ep05DoodlesClass.spawn_subscriber_counter(self, pos)

func giant_1000(pos: Vector2 = Vector2(820, 260)) -> Node2D:
	return Ep05DoodlesClass.spawn_giant_1000(self, pos)

func comment_bubble(pos: Vector2, w: float = 170.0, h: float = 65.0) -> Node2D:
	return Ep05DoodlesClass.spawn_comment_bubble(self, pos, w, h)

func tiny_crowd(base_y: float = 520.0) -> Node2D:
	return Ep05DoodlesClass.spawn_tiny_crowd(self, base_y)

func phone_instagram(pos: Vector2 = Vector2(480, 500)) -> Node2D:
	return Ep05DoodlesClass.spawn_phone_instagram(self, pos)

func physical_card(pos: Vector2, text: String, checked: bool = false, col: Color = Color("#fffdfa")) -> Node2D:
	return Ep05DoodlesClass.spawn_physical_card(self, pos, text, checked, col)

func draw_live_wavy_underline(start_pt: Vector2, width: float, dur: float = 0.3) -> Node2D:
	var pts := PackedVector2Array()
	var waves: int = maxi(3, int(width / 16.0))
	for i in range(waves * 4):
		var frac: float = float(i) / float(waves * 4)
		var x: float = start_pt.x + frac * width
		var y: float = start_pt.y + sin(frac * float(waves) * TAU) * 4.5
		pts.append(Vector2(x, y))
	var stroke := Ep05DoodlesClass.HandDrawnStroke.new(pts, Color("#d93b2b"), 3.2, 1.8)
	add_child(stroke)
	stroke.animate_draw_on(dur)
	return stroke

# -----------------------------------------------------------------------------
# TRUE LIVE DOODLE FACTORIES (Organic progressive hand-drawn linework)
# -----------------------------------------------------------------------------

func live_sticky_note(pos: Vector2, text: String = "TODO: DON'T PANIC", size: Vector2 = Vector2(170, 95), draw_dur: float = 0.6) -> Node2D:
	var note = Ep05LiveDoodlesClass.LiveStickyNote.new(text, size)
	note.position = pos
	add_child(note)
	note.start_live_draw(draw_dur)
	return note

func live_recap_card(pos: Vector2, draw_dur: float = 0.8) -> Node2D:
	var card = Ep05LiveDoodlesClass.LiveRecapCard.new()
	card.position = pos
	add_child(card)
	card.start_live_draw(draw_dur)
	return card

func live_counter_box(pos: Vector2, draw_dur: float = 0.5) -> Node2D:
	var box = Ep05LiveDoodlesClass.LiveCounterBox.new()
	box.position = pos
	add_child(box)
	box.start_live_draw(draw_dur)
	return box

func live_giant_1000(pos: Vector2, draw_dur: float = 0.7) -> Node2D:
	var giant = Ep05LiveDoodlesClass.LiveGiant1000.new()
	giant.position = pos
	add_child(giant)
	giant.start_live_draw(draw_dur)
	return giant

func live_tiny_crowd(pos: Vector2 = Vector2(640, 520), draw_dur: float = 1.0) -> Node2D:
	var crowd = Ep05LiveDoodlesClass.LiveTinyCrowd.new()
	crowd.position = pos
	add_child(crowd)
	crowd.start_live_draw(draw_dur)
	return crowd

func live_comment_bubble(pos: Vector2, text: String, size: Vector2 = Vector2(210, 60), draw_dur: float = 0.5) -> Node2D:
	var bubble = Ep05LiveDoodlesClass.LiveCommentBubble.new(text, size)
	bubble.position = pos
	add_child(bubble)
	bubble.start_live_draw(draw_dur)
	return bubble

func live_heart_card(pos: Vector2, draw_dur: float = 0.7) -> Node2D:
	var card = Ep05LiveDoodlesClass.LiveHeartCard.new()
	card.position = pos
	add_child(card)
	card.start_live_draw(draw_dur)
	return card

func live_phone_instagram(pos: Vector2 = Vector2(460, 480), draw_dur: float = 0.7) -> Node2D:
	var phone = Ep05LiveDoodlesClass.LiveInstagramPhone.new()
	phone.position = pos
	add_child(phone)
	phone.start_live_draw(draw_dur)
	return phone

func live_physical_card(pos: Vector2, text: String, checked: bool = true, draw_dur: float = 0.7) -> Node2D:
	var card = Ep05LiveDoodlesClass.LivePhysicalCard.new(text, checked)
	card.position = pos
	add_child(card)
	card.start_live_draw(draw_dur)
	return card

func transition_backdrop(target_state: int, dur: float = 0.6) -> Signal:
	if studio_backdrop and studio_backdrop.has_method("transition_to_state"):
		return studio_backdrop.transition_to_state(target_state, dur)
	return get_tree().process_frame


