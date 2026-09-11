class_name NemiPropLibrary
extends RefCounted

## Master Catalog and Factory for All Illustrated Props in NEMI's Universe
## Provides unified registration, category indexing, and instantiation for
## 30+ reusable hand-drawn procedural vector props.

const PROPS: Dictionary = {
	# Everyday
	"phone": "res://world/props/PropPhone.gd",
	"laptop": "res://world/props/PropLaptop.gd",
	"notebook": "res://world/props/PropNotebook.gd",
	"pencil": "res://world/props/PropPencil.gd",
	"pen": "res://world/props/PropPen.gd",
	"cup": "res://world/props/PropCup.gd",
	"water_bottle": "res://world/props/PropWaterBottle.gd",
	"headphones": "res://world/props/PropHeadphones.gd",
	"backpack": "res://world/props/PropBackpack.gd",
	"keys": "res://world/props/PropKeys.gd",
	"desk": "res://world/props/PropDesk.gd",
	"chair": "res://world/props/PropChair.gd",
	"lamp": "res://world/props/PropLamp.gd",
	
	# Creative & Animation
	"stylus": "res://world/props/PropStylus.gd",
	"drawing_tablet": "res://world/props/PropDrawingTablet.gd",
	"sketchbook": "res://world/props/PropSketchbook.gd",
	"paper_sheet": "res://world/props/PropPaperSheet.gd",
	"storyboard": "res://world/props/PropStoryboard.gd",
	"animation_timeline": "res://world/props/PropAnimationTimeline.gd",
	
	# Gym
	"dumbbell": "res://world/props/PropDumbbell.gd",
	"barbell": "res://world/props/PropBarbell.gd",
	"weight_plate": "res://world/props/PropWeightPlate.gd",
	"gym_towel": "res://world/props/PropGymTowel.gd",
	
	# Travel / Car
	"steering_wheel": "res://world/props/PropSteeringWheel.gd",
	"car_window": "res://world/props/PropCarWindow.gd",
	"rear_view_mirror": "res://world/props/PropRearViewMirror.gd",
	
	# Food
	"plate": "res://world/props/PropPlate.gd",
	"bowl": "res://world/props/PropBowl.gd",
	"snack_packet": "res://world/props/PropSnackPacket.gd",
	"takeaway_box": "res://world/props/PropTakeawayBox.gd",
	
	# Technology
	"keyboard": "res://world/props/PropKeyboard.gd",
	"mouse": "res://world/props/PropMouse.gd",
	"monitor": "res://world/props/PropMonitor.gd",
	"browser_window": "res://world/props/PropBrowserWindow.gd",
	
	# Story & Metaphor
	"clock": "res://world/props/PropClock.gd",
	"warning_sign": "res://world/props/PropWarningSign.gd",
	"thought_bubble": "res://world/props/PropThoughtBubble.gd",
	"speech_bubble": "res://world/props/PropSpeechBubble.gd",
	"arrow": "res://world/props/PropArrow.gd",
	"victorian_bridge": "res://episodes/ep00_introduction/props/PropVictorianBridge.gd",
	"distorted_teacup": "res://episodes/ep00_introduction/props/PropDistortedTeacup.gd"
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
