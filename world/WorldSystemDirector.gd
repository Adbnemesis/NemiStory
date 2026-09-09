class_name WorldSystemDirector
extends Node2D

## High-Level AI-Friendly Director Orchestrator for Nemi Story Productions
## Unifies environment, props, annotations, doodles, and camera into a cohesive,
## high-level API matching the storyboard flow of the reference videos.

const WorldStyleScript = preload("res://world/style/WorldStyle.gd")
const StoryEnvironmentScript = preload("res://world/backgrounds/WorldEnvironment.gd")
const WorldDoodlesScript = preload("res://world/doodles/WorldDoodles.gd")
const WorldAnnotationScript = preload("res://world/annotations/WorldAnnotation.gd")
const StoryCamera2DScript = preload("res://world/camera/StoryCamera2D.gd")
const StoryCompositionScript = preload("res://world/composition/StoryComposition.gd")

# Props
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

@export var nemi_character: Node2D

var style: RefCounted
var environment: Node2D
var doodles: Node2D
var annotations: Node2D
var camera: Camera2D

var active_props: Dictionary = {} # String name -> Node2D

func _ready() -> void:
	# Initialize master style
	style = WorldStyleScript.new()
	style.set_mode(WorldStyleScript.ArtMode.COLOR)
	
	# Create environment if not present
	environment = get_node_or_null("Environment")
	if not environment:
		environment = StoryEnvironmentScript.new()
		environment.name = "Environment"
		add_child(environment)
	if environment.has_method("set_style"):
		environment.set_style(style)
	
	# Create annotation layer
	annotations = get_node_or_null("Annotations")
	if not annotations:
		annotations = WorldAnnotationScript.new()
		annotations.name = "Annotations"
		add_child(annotations)
	if annotations.has_method("set_style"):
		annotations.set_style(style)
	
	# Create doodle layer
	doodles = get_node_or_null("Doodles")
	if not doodles:
		doodles = WorldDoodlesScript.new()
		doodles.name = "Doodles"
		add_child(doodles)
	if doodles.has_method("set_style"):
		doodles.set_style(style)
	
	# Create or bind camera
	camera = get_node_or_null("Camera2D") as Camera2D
	if not camera:
		camera = StoryCamera2DScript.new()
		camera.name = "Camera2D"
		add_child(camera)
		
	# Enforce proper Z-ordering
	StoryCompositionScript.enforce_hierarchy(environment, nemi_character, null, [], annotations, doodles)

# -------------------------------------------------------------------------
# DIRECTING API
# -------------------------------------------------------------------------

## Switch visual rendering mode (COLOR vs MONOCHROME)
func set_monochrome(enabled: bool) -> void:
	style.set_mode(WorldStyleScript.ArtMode.MONOCHROME if enabled else WorldStyleScript.ArtMode.COLOR)
	for p_name in active_props:
		var prop: Node2D = active_props[p_name]
		if is_instance_valid(prop) and prop.has_method("set_style"):
			prop.set_style(style)
	if is_instance_valid(nemi_character) and nemi_character.has_method("set_style"):
		nemi_character.set_style("monochrome" if enabled else "color")

## Switch background setting and detail density
func set_environment(env_type: int, density: int = 2) -> void:
	if is_instance_valid(environment):
		environment.environment_type = env_type
		environment.density = density
		environment.queue_redraw()

## Spawn and track an illustrated prop
func spawn_prop(prop_type: String, pos: Vector2 = Vector2.ZERO) -> Node2D:
	var prop: Node2D = null
	match prop_type.to_lower():
		"phone": prop = PropPhoneScript.new()
		"laptop": prop = PropLaptopScript.new()
		"cup", "mug": prop = PropCupScript.new()
		"desk": prop = PropDeskScript.new()
		"chair": prop = PropChairScript.new()
		"book", "notebook": prop = PropBookScript.new()
		"backpack", "bag": prop = PropBackpackScript.new()
		"waterbottle", "bottle": prop = PropWaterBottleScript.new()
		"snack", "chips": prop = PropSnackPacketScript.new()
		"lamp": prop = PropLampScript.new()
		_:
			push_warning("WorldSystemDirector: Unknown prop type '" + prop_type + "'")
			return null
			
	prop.name = prop_type.capitalize() + "_" + str(active_props.size())
	prop.position = pos
	if prop.has_method("set_style"):
		prop.set_style(style)
	add_child(prop)
	active_props[prop.name] = prop
	if prop.has_method("pop_in"):
		prop.pop_in(0.2)
	return prop

## Direct character and prop staging
func apply_staging(preset: int, primary_prop: Node2D = null, duration: float = 0.3) -> void:
	StoryCompositionScript.apply_staging(preset as StoryCompositionScript.StagingPreset, nemi_character, primary_prop, duration)

## Trigger an emphatic reaction (combines camera punch/shake, doodles, and staging)
func trigger_shock_reaction(target_pos: Vector2 = Vector2.ZERO) -> void:
	if target_pos == Vector2.ZERO and is_instance_valid(nemi_character):
		target_pos = nemi_character.global_position + Vector2(0, -90)
		
	# Camera punch-in with snap overshoot
	if camera and camera.has_method("punch_in"):
		camera.punch_in(target_pos, 1.75, 0.16, 1.12)
	if camera and camera.has_method("shake"):
		camera.shake(14.0, 0.25)
	
	# Comic shock lines
	if doodles and doodles.has_method("spawn_shock_lines"):
		doodles.spawn_shock_lines(target_pos + Vector2(0, -30), 70.0)
	if doodles and doodles.has_method("spawn_exclamation"):
		doodles.spawn_exclamation(target_pos + Vector2(70, -80), 38.0)
	
	# Trigger Nemi shocked reaction
	if is_instance_valid(nemi_character):
		if nemi_character.has_method("run_reaction"):
			nemi_character.run_reaction("shock")
		elif "actor" in nemi_character and nemi_character.actor and nemi_character.actor.reactions:
			nemi_character.actor.reactions.test_e_shock()

## Focus camera and attention on a target object or character
func focus_target(target: Node2D, camera_preset: int = 3, add_highlight: bool = false) -> void:
	if camera and camera.has_method("apply_preset"):
		camera.apply_preset(camera_preset as StoryCamera2DScript.ShotPreset, 0.35, target)
	if add_highlight and is_instance_valid(target) and annotations and annotations.has_method("highlight"):
		annotations.highlight(target, Vector2(30, 30), 0)

## Reset all doodles, annotations, and return camera to wide
func reset_scene(duration: float = 0.25) -> void:
	if doodles and doodles.has_method("clear_all"):
		doodles.clear_all()
	if annotations and annotations.has_method("clear_annotations"):
		annotations.clear_annotations(duration)
	if camera and camera.has_method("reset_camera"):
		camera.reset_camera(duration)
