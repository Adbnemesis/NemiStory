class_name NemiPropLibrary
extends RefCounted

## Master Catalog and Factory for All Illustrated Props in NEMI's Universe
## Provides unified registration, category indexing, and instantiation for
## 30+ reusable hand-drawn procedural vector props.

const PROPS: Dictionary = {
	# Everyday
	"phone": "res://nemi/world/props/PropPhone.gd",
	"laptop": "res://nemi/world/props/PropLaptop.gd",
	"notebook": "res://nemi/world/props/PropNotebook.gd",
	"pencil": "res://nemi/world/props/PropPencil.gd",
	"pen": "res://nemi/world/props/PropPen.gd",
	"cup": "res://nemi/world/props/PropCup.gd",
	"water_bottle": "res://nemi/world/props/PropWaterBottle.gd",
	"headphones": "res://nemi/world/props/PropHeadphones.gd",
	"backpack": "res://nemi/world/props/PropBackpack.gd",
	"keys": "res://nemi/world/props/PropKeys.gd",
	"desk": "res://nemi/world/props/PropDesk.gd",
	"chair": "res://nemi/world/props/PropChair.gd",
	"lamp": "res://nemi/world/props/PropLamp.gd",
	
	# Creative & Animation
	"stylus": "res://nemi/world/props/PropStylus.gd",
	"drawing_tablet": "res://nemi/world/props/PropDrawingTablet.gd",
	"sketchbook": "res://nemi/world/props/PropSketchbook.gd",
	"paper_sheet": "res://nemi/world/props/PropPaperSheet.gd",
	"storyboard": "res://nemi/world/props/PropStoryboard.gd",
	"animation_timeline": "res://nemi/world/props/PropAnimationTimeline.gd",
	
	# Gym
	"dumbbell": "res://nemi/world/props/PropDumbbell.gd",
	"barbell": "res://nemi/world/props/PropBarbell.gd",
	"weight_plate": "res://nemi/world/props/PropWeightPlate.gd",
	"gym_towel": "res://nemi/world/props/PropGymTowel.gd",
	
	# Travel / Car
	"steering_wheel": "res://nemi/world/props/PropSteeringWheel.gd",
	"car_window": "res://nemi/world/props/PropCarWindow.gd",
	"rear_view_mirror": "res://nemi/world/props/PropRearViewMirror.gd",
	
	# Food
	"plate": "res://nemi/world/props/PropPlate.gd",
	"bowl": "res://nemi/world/props/PropBowl.gd",
	"snack_packet": "res://nemi/world/props/PropSnackPacket.gd",
	"takeaway_box": "res://nemi/world/props/PropTakeawayBox.gd",
	
	# Technology
	"keyboard": "res://nemi/world/props/PropKeyboard.gd",
	"mouse": "res://nemi/world/props/PropMouse.gd",
	"monitor": "res://nemi/world/props/PropMonitor.gd",
	"browser_window": "res://nemi/world/props/PropBrowserWindow.gd",
	
	# Story & Metaphor
	"clock": "res://nemi/world/props/PropClock.gd",
	"warning_sign": "res://nemi/world/props/PropWarningSign.gd",
	"thought_bubble": "res://nemi/world/props/PropThoughtBubble.gd",
	"speech_bubble": "res://nemi/world/props/PropSpeechBubble.gd",
	"arrow": "res://nemi/world/props/PropArrow.gd",
	"victorian_bridge": "res://nemi/episodes/ep00_introduction/props/PropVictorianBridge.gd",
	"distorted_teacup": "res://nemi/episodes/ep00_introduction/props/PropDistortedTeacup.gd"
}

const CATEGORIES: Dictionary = {
	"everyday": ["phone", "laptop", "notebook", "pencil", "pen", "cup", "water_bottle", "headphones", "backpack", "keys", "desk", "chair", "lamp"],
	"creative": ["stylus", "drawing_tablet", "sketchbook", "paper_sheet", "storyboard", "animation_timeline"],
	"gym": ["dumbbell", "barbell", "weight_plate", "gym_towel"],
	"travel": ["steering_wheel", "car_window", "rear_view_mirror"],
	"food": ["plate", "bowl", "snack_packet", "takeaway_box"],
	"technology": ["keyboard", "mouse", "monitor", "browser_window"],
	"story_metaphor": ["clock", "warning_sign", "thought_bubble", "speech_bubble", "arrow", "victorian_bridge", "distorted_teacup"]
}

## Instantiates a prop by its registered ID string
static func create_prop(prop_id: String) -> Node2D:
	if not PROPS.has(prop_id):
		push_error("NemiPropLibrary: Unknown prop_id '%s'" % prop_id)
		return null
	var script_path: String = PROPS[prop_id]
	if not ResourceLoader.exists(script_path):
		push_error("NemiPropLibrary: Script not found at '%s'" % script_path)
		return null
	var script = load(script_path)
	var instance = script.new()
	return instance

## Checks if a prop ID is registered in the library
static func has_prop(prop_id: String) -> bool:
	return PROPS.has(prop_id)

## Returns array of all prop IDs in a specific category
static func get_props_in_category(category: String) -> Array:
	if CATEGORIES.has(category):
		return CATEGORIES[category]
	return []

## Returns array of all available categories
static func get_all_categories() -> Array:
	return CATEGORIES.keys()

## Returns total count of registered props
static func get_total_prop_count() -> int:
	return PROPS.size()

## Returns all registered prop IDs
static func get_all_prop_ids() -> Array:
	return PROPS.keys()
