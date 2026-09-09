class_name WorldSystemTest
extends Node2D

## Interactive Showcase Sandbox for the Illustrated World System V1
## Demonstrates native 2D procedural props, environments, doodles, annotations,
## and camera choreography working seamlessly with the approved Nemi character.

const WorldEnvironmentScript = preload("res://world/backgrounds/WorldEnvironment.gd")
const StoryCamera2DScript = preload("res://world/camera/StoryCamera2D.gd")
const StoryCompositionScript = preload("res://world/composition/StoryComposition.gd")
const DoodleInstanceScript = preload("res://world/doodles/DoodleInstance.gd")
const WorldAnnotationScript = preload("res://world/annotations/WorldAnnotation.gd")

# Props explicit preloads
const PropPhoneScript = preload("res://world/props/PropPhone.gd")
const PropLaptopScript = preload("res://world/props/PropLaptop.gd")
const PropCupScript = preload("res://world/props/PropCup.gd")
const PropDeskScript = preload("res://world/props/PropDesk.gd")
const PropChairScript = preload("res://world/props/PropChair.gd")
const PropBookScript = preload("res://world/props/PropBook.gd")
const PropBackpackScript = preload("res://world/props/PropBackpack.gd")
const PropWaterBottleScript = preload("res://world/props/PropWaterBottle.gd")
const PropSnackPacketScript = preload("res://world/props/PropSnackPacket.gd")
const PropLampScript = preload("res://world/props/PropLamp.gd")

@onready var director: Node2D = $Director
@onready var nemi: Node2D = $Nemi
@onready var hud: CanvasLayer = $WorldHUD

var _current_env_idx: int = 2 # WORKSPACE
var _current_density: int = 2
var _is_monochrome: bool = false
var _active_props: Array[Node2D] = []
var _is_running_sequence: bool = false

func _ready() -> void:
	# Wire director to character
	director.nemi_character = nemi
	
	# Initial positioning
	nemi.position = StoryCompositionScript.POS_CENTER
	
	# Setup initial scene
	run_scene_1_desk_and_laptop()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: run_scene_1_desk_and_laptop()
			KEY_2: run_scene_2_phone_shock()
			KEY_3: run_scene_3_cozy_tea_and_book()
			KEY_4: run_scene_4_street_backpack()
			KEY_5: run_scene_5_annotations_and_doodles()
			KEY_6: run_scene_6_staging_and_camera()
			KEY_M: toggle_monochrome()
			KEY_D: cycle_density()
			KEY_E: cycle_environment()
			KEY_SPACE: reset_all()

# -------------------------------------------------------------------------
# SCENE 1: DESK & LAPTOP (STORYTELLING / EXPLAINING)
# -------------------------------------------------------------------------
func run_scene_1_desk_and_laptop() -> void:
	_cleanup_props()
	director.reset_scene(0.1)
	
	_current_env_idx = WorldEnvironmentScript.EnvType.WORKSPACE
	director.set_environment(WorldEnvironmentScript.EnvType.WORKSPACE, _current_density)
	
	nemi.position = StoryCompositionScript.POS_CENTER
	if nemi.has_method("reset_state"):
		nemi.reset_state()
		
	# Spawn Desk in front of Nemi
	var desk: Node2D = director.spawn_prop("desk", nemi.position + Vector2(0, 35))
	if desk:
		desk.z_index = StoryCompositionScript.Z_FOREGROUND_FURNITURE
		_active_props.append(desk)
	
	# Spawn Laptop on Desk
	var laptop: Node2D = director.spawn_prop("laptop", nemi.position + Vector2(-60, -15))
	if laptop:
		laptop.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(laptop)
	
	# Spawn Coffee Cup on Desk
	var cup: Node2D = director.spawn_prop("cup", nemi.position + Vector2(120, -15))
	if cup:
		cup.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(cup)
	
	# Camera framing
	director.camera.apply_preset(StoryCamera2DScript.ShotPreset.MEDIUM, 0.4, nemi)
	
	# Comic Speech Bubble
	director.doodles.spawn_speech_bubble(nemi.position + Vector2(160, -160), "Welcome back! ♡", 120.0, true)
	
	# Trigger conversational micro-acting if available
	if "actor" in nemi and nemi.actor and nemi.actor.reactions:
		nemi.actor.reactions.test_b_conversational()
		
	_update_hud("Scene 1: Desk & Laptop (Storytelling)")

# -------------------------------------------------------------------------
# SCENE 2: SMARTPHONE REACTION (SHOCK / PUNCH-IN)
# -------------------------------------------------------------------------
func run_scene_2_phone_shock() -> void:
	_cleanup_props()
	director.reset_scene(0.1)
	
	_current_env_idx = WorldEnvironmentScript.EnvType.BEDROOM
	director.set_environment(WorldEnvironmentScript.EnvType.BEDROOM, _current_density)
	
	nemi.position = StoryCompositionScript.POS_CENTER
	if nemi.has_method("reset_state"):
		nemi.reset_state()
		
	# Spawn smartphone
	var phone: Node2D = director.spawn_prop("phone", nemi.position + Vector2(60, 20))
	if phone:
		_active_props.append(phone)
		# Attach phone to Nemi's right hand if available
		if "right_hand_visual" in nemi and nemi.right_hand_visual:
			phone.attach_to(nemi.right_hand_visual, Vector2(10, 15), 15.0)
		elif "right_hand_bone" in nemi and nemi.right_hand_bone:
			phone.attach_to(nemi.right_hand_bone, Vector2(10, 15), 15.0)
		
	# Start in Medium shot
	director.camera.apply_preset(StoryCamera2DScript.ShotPreset.MEDIUM, 0.3, nemi)
	_update_hud("Scene 2: Looking at phone...")
	
	# Sequence: glance at phone -> pause -> dramatic realization punch-in
	var tw := create_tween()
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		if "actor" in nemi and nemi.actor and nemi.actor.eyes:
			nemi.actor.eyes.look("down_right", "fast")
	)
	tw.tween_interval(0.4)
	tw.tween_callback(func():
		director.trigger_shock_reaction(nemi.global_position + Vector2(0, -60))
		_update_hud("Scene 2: Phone SHOCK Reaction!")
	)

# -------------------------------------------------------------------------
# SCENE 3: COZY LIVING ROOM (TEA & BOOK)
# -------------------------------------------------------------------------
func run_scene_3_cozy_tea_and_book() -> void:
	_cleanup_props()
	director.reset_scene(0.1)
	
	_current_env_idx = WorldEnvironmentScript.EnvType.LIVING_ROOM
	director.set_environment(WorldEnvironmentScript.EnvType.LIVING_ROOM, _current_density)
	
	nemi.position = StoryCompositionScript.POS_CENTER
	if nemi.has_method("reset_state"):
		nemi.reset_state()
		
	# Spawn Desk / Table
	var desk: Node2D = director.spawn_prop("desk", nemi.position + Vector2(0, 35))
	if desk:
		desk.z_index = StoryCompositionScript.Z_FOREGROUND_FURNITURE
		_active_props.append(desk)
	
	# Spawn Open Book
	var book: Node2D = director.spawn_prop("book", nemi.position + Vector2(-50, -10))
	if book:
		book.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(book)
	
	# Spawn Steaming Cup
	var cup: Node2D = director.spawn_prop("cup", nemi.position + Vector2(110, -15))
	if cup:
		cup.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(cup)
	
	# Spawn Desk Lamp
	var lamp: Node2D = director.spawn_prop("lamp", nemi.position + Vector2(210, -50))
	if lamp:
		lamp.z_index = StoryCompositionScript.Z_FOREGROUND_FURNITURE
		_active_props.append(lamp)
	
	# Warm closeup
	director.camera.apply_preset(StoryCamera2DScript.ShotPreset.MEDIUM_CLOSEUP, 0.4, nemi)
	
	# Cute heart accent
	director.doodles.spawn_heart(nemi.position + Vector2(110, -150), 30.0, true)
	
	if "face" in nemi and nemi.face and nemi.face.has_method("set_mouth"):
		nemi.face.set_mouth("smile_small")
		
	_update_hud("Scene 3: Cozy Living Room (Tea & Book)")

# -------------------------------------------------------------------------
# SCENE 4: STREET WALK & BACKPACK
# -------------------------------------------------------------------------
func run_scene_4_street_backpack() -> void:
	_cleanup_props()
	director.reset_scene(0.1)
	
	_current_env_idx = WorldEnvironmentScript.EnvType.STREET
	director.set_environment(WorldEnvironmentScript.EnvType.STREET, _current_density)
	
	nemi.position = StoryCompositionScript.POS_CENTER
	if nemi.has_method("reset_state"):
		nemi.reset_state()
		
	# Spawn Backpack resting nearby or attached
	var bag: Node2D = director.spawn_prop("backpack", nemi.position + Vector2(-80, 45))
	if bag:
		bag.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(bag)
	
	# Spawn Water Bottle
	var bottle: Node2D = director.spawn_prop("waterbottle", nemi.position + Vector2(-130, 50))
	if bottle:
		bottle.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(bottle)
	
	# Wide street framing
	director.camera.apply_preset(StoryCamera2DScript.ShotPreset.WIDE, 0.4, nemi)
	
	# Motion lines accent
	director.doodles.spawn_motion_lines(nemi.position + Vector2(-70, -20), 70.0, true)
	
	_update_hud("Scene 4: Street Walk & Backpack")

# -------------------------------------------------------------------------
# SCENE 5: VISUAL ANNOTATIONS & DOODLES SHOWCASE
# -------------------------------------------------------------------------
func run_scene_5_annotations_and_doodles() -> void:
	_cleanup_props()
	director.reset_scene(0.1)
	
	_current_env_idx = WorldEnvironmentScript.EnvType.NEUTRAL
	director.set_environment(WorldEnvironmentScript.EnvType.NEUTRAL, 1) # Minimal floor line
	
	nemi.position = StoryCompositionScript.POS_LEFT_THIRD
	if nemi.has_method("reset_state"):
		nemi.reset_state()
		
	# Spawn Laptop as focal presentation item on right
	var laptop: Node2D = director.spawn_prop("laptop", StoryCompositionScript.POS_RIGHT_THIRD + Vector2(0, -10))
	if laptop:
		laptop.z_index = StoryCompositionScript.Z_PROPS_HELD
		_active_props.append(laptop)
	
	# Camera medium wide
	director.camera.apply_preset(StoryCamera2DScript.ShotPreset.WIDE, 0.3)
	
	# Dim background for high-contrast focus
	director.annotations.dim_background(0.4, 0.25)
	
	# Highlight Box around Laptop
	if laptop:
		director.annotations.highlight(laptop, Vector2(60, 45), WorldAnnotationScript.HighlightStyle.BOX)
		# Arrow pointing from Nemi to Laptop
		director.annotations.point_arrow_to(laptop, Vector2(-140, -90), true)
		# Callout note
		director.annotations.add_callout(laptop, "IMPORTANT BUG!", Vector2(0, -80))
	
	# Comic accents on Nemi: sweat drop + question mark
	director.doodles.spawn_sweat_drop(nemi.position + Vector2(-45, -130), 26.0, true)
	director.doodles.spawn_question(nemi.position + Vector2(45, -140), 32.0, true)
	
	_update_hud("Scene 5: Visual Annotations & Doodles Showcase")

# -------------------------------------------------------------------------
# SCENE 6: STAGING & CAMERA CHOREOGRAPHY
# -------------------------------------------------------------------------
func run_scene_6_staging_and_camera() -> void:
	_cleanup_props()
	director.reset_scene(0.1)
	
	_current_env_idx = WorldEnvironmentScript.EnvType.WORKSPACE
	director.set_environment(WorldEnvironmentScript.EnvType.WORKSPACE, 2)
	
	nemi.position = StoryCompositionScript.POS_CENTER
	if nemi.has_method("reset_state"):
		nemi.reset_state()
		
	var phone: Node2D = director.spawn_prop("phone", nemi.position + Vector2(100, 20))
	if phone:
		_active_props.append(phone)
	
	_update_hud("Scene 6: Choreography (Starting Centered)")
	
	# Dynamic sequence:
	# 1. Start Centered Wide
	director.camera.apply_preset(StoryCamera2DScript.ShotPreset.WIDE, 0.2)
	
	var tw := create_tween()
	# Step A: Shift Nemi Left, Prop Right (Rule of Thirds)
	tw.tween_interval(0.4)
	tw.tween_callback(func():
		director.apply_staging(StoryCompositionScript.StagingPreset.NEMI_LEFT_PROP_RIGHT, phone, 0.4)
		director.camera.apply_preset(StoryCamera2DScript.ShotPreset.MEDIUM, 0.4)
		_update_hud("Scene 6: Re-staged to Rule of Thirds")
	)
	
	# Step B: Camera pushes in on Nemi closeup
	tw.tween_interval(0.8)
	tw.tween_callback(func():
		director.camera.apply_preset(StoryCamera2DScript.ShotPreset.CLOSEUP, 0.35, nemi)
		_update_hud("Scene 6: Camera Push-In Closeup")
	)
	
	# Step C: Punch-In Shock Snap
	tw.tween_interval(0.8)
	tw.tween_callback(func():
		director.trigger_shock_reaction(nemi.global_position + Vector2(0, -60))
		_update_hud("Scene 6: Punch-In Snap with Screen Shake")
	)

# -------------------------------------------------------------------------
# GLOBAL CONTROLS
# -------------------------------------------------------------------------
func toggle_monochrome() -> void:
	_is_monochrome = not _is_monochrome
	director.set_monochrome(_is_monochrome)
	_update_hud("Toggled Mode: " + ("MONOCHROME" if _is_monochrome else "COLOR"))

func cycle_density() -> void:
	_current_density = (_current_density + 1) % 4
	director.set_environment(_current_env_idx, _current_density)
	_update_hud("Cycled Density to " + str(_current_density))

func cycle_environment() -> void:
	_current_env_idx = (_current_env_idx + 1) % 5
	director.set_environment(_current_env_idx, _current_density)
	_update_hud("Cycled Environment to " + _get_env_name(_current_env_idx))

func reset_all() -> void:
	_cleanup_props()
	director.reset_scene(0.2)
	if nemi.has_method("reset_state"):
		nemi.reset_state()
	nemi.position = StoryCompositionScript.POS_CENTER
	_update_hud("Reset scene and camera.")

func _cleanup_props() -> void:
	for p in _active_props:
		if is_instance_valid(p):
			p.queue_free()
	_active_props.clear()
	director.active_props.clear()

func _update_hud(status_msg: String = "") -> void:
	if hud and hud.has_method("update_status"):
		var env_name := _get_env_name(_current_env_idx)
		var cam_name: String = "WIDE"
		if director and director.camera:
			var preset_idx: int = director.camera.current_preset
			var keys = StoryCamera2DScript.ShotPreset.keys()
			if preset_idx >= 0 and preset_idx < keys.size():
				cam_name = str(keys[preset_idx])
		hud.update_status(env_name, _current_density, _is_monochrome, cam_name, _active_props.size(), status_msg)

func _get_env_name(idx: int) -> String:
	match idx:
		0: return "NEUTRAL"
		1: return "BEDROOM"
		2: return "WORKSPACE"
		3: return "LIVING_ROOM"
		4: return "STREET"
		_: return "UNKNOWN"
