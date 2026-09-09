class_name StoryComposition
extends RefCounted

## Story Composition & Visual Hierarchy System
## Coordinates scene staging, spatial rule of thirds, depth layering (Z-ordering),
## and visual density controls to prevent clutter and maintain visual clarity.

enum StagingPreset {
	CENTERED,               # Nemi at center (x=960)
	NEMI_LEFT_PROP_RIGHT,   # Nemi at left-third (x=640), prop/presentation at right-third (x=1280)
	NEMI_RIGHT_PROP_LEFT,   # Nemi at right-third (x=1280), prop/presentation at left-third (x=640)
	TWO_SHOT_INTERACTION,   # Nemi and interactive desk/laptop setup
	OVER_SHOULDER           # Foreground prop silhouette framing Nemi
}

enum DensityLevel {
	MINIMAL = 0,    # Floor line only, maximum negative space
	SPARSE = 1,     # Floor line + 1 environmental anchor (window or poster)
	NORMAL = 2,     # Standard bedroom / desk environment
	BUSY = 3        # Rich environmental details for establishing shots
}

# Strict 2D Z-Ordering Architecture
const Z_PAPER_BACKGROUND = -10
const Z_ENVIRONMENT_LINES = -5
const Z_BACKGROUND_FURNITURE = 0
const Z_CHARACTER_NEMI = 10
const Z_FOREGROUND_FURNITURE = 15
const Z_PROPS_HELD = 20
const Z_ANNOTATIONS = 25
const Z_DOODLES_ACCENTS = 30
const Z_FOREGROUND_FRAME = 40
const Z_HUD = 100

# Canonical 1280x720 Viewport Anchors
const POS_CENTER = Vector2(640, 440)
const POS_LEFT_THIRD = Vector2(460, 440)
const POS_RIGHT_THIRD = Vector2(840, 440)
const POS_LEFT_FAR = Vector2(240, 440)
const POS_RIGHT_FAR = Vector2(1040, 440)

## Apply spatial layout staging to character and active props
static func apply_staging(preset: StagingPreset, nemi: Node2D, primary_prop: Node2D = null, duration: float = 0.3) -> void:
	var nemi_target := POS_CENTER
	var prop_target := POS_RIGHT_THIRD
	
	match preset:
		StagingPreset.CENTERED:
			nemi_target = POS_CENTER
			prop_target = POS_CENTER + Vector2(140, 40)
		StagingPreset.NEMI_LEFT_PROP_RIGHT:
			nemi_target = POS_LEFT_THIRD
			prop_target = POS_RIGHT_THIRD
		StagingPreset.NEMI_RIGHT_PROP_LEFT:
			nemi_target = POS_RIGHT_THIRD
			prop_target = POS_LEFT_THIRD
		StagingPreset.TWO_SHOT_INTERACTION:
			nemi_target = POS_CENTER + Vector2(-80, 0)
			prop_target = POS_CENTER + Vector2(160, 40)
		StagingPreset.OVER_SHOULDER:
			nemi_target = POS_CENTER + Vector2(120, -30)
			prop_target = POS_LEFT_THIRD + Vector2(0, 100)
			
	if is_instance_valid(nemi):
		if duration > 0.001:
			var tw := nemi.create_tween()
			tw.tween_property(nemi, "position", nemi_target, duration)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			nemi.position = nemi_target
			
	if is_instance_valid(primary_prop):
		if duration > 0.001:
			var tw := primary_prop.create_tween()
			tw.tween_property(primary_prop, "position", prop_target, duration)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			primary_prop.position = prop_target

## Ensure all scene elements conform to the strict Z-index hierarchy
static func enforce_hierarchy(
	env: Node2D = null,
	nemi: Node2D = null,
	desk: Node2D = null,
	props: Array[Node2D] = [],
	annotations: Node2D = null,
	doodles: Node2D = null
) -> void:
	if is_instance_valid(env):
		env.z_index = Z_ENVIRONMENT_LINES
	if is_instance_valid(nemi):
		nemi.z_index = Z_CHARACTER_NEMI
	if is_instance_valid(desk):
		desk.z_index = Z_FOREGROUND_FURNITURE
	for p in props:
		if is_instance_valid(p):
			p.z_index = Z_PROPS_HELD
	if is_instance_valid(annotations):
		annotations.z_index = Z_ANNOTATIONS
	if is_instance_valid(doodles):
		doodles.z_index = Z_DOODLES_ACCENTS
