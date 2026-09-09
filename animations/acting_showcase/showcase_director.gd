extends Node

## Director script for the Nemi Character Production Showcase
## Demonstrates:
## - Act 1: 15 Canonical Poses (Full-body & Bust) with 0-frame snaps and ground anchoring
## - Act 2: 12 Facial Expressions + Micro-events on close-up punch-in framing
## - Act 3: Story Props, Stepped 2s Bouncing, Recoil & Trauma Screen Shake

@export var nemi: Nemi
@export var camera: StoryCamera
@export var category_label: Label
@export var action_label: Label
@export var subtitle_label: Label

func _ready() -> void:
	if nemi:
		nemi.position = Vector2(640, 580)
	if camera:
		camera.position = Vector2(640, 360)
		camera.reset_framing()

	_run_showcase()

func _run_showcase() -> void:
	print("--- NEMI PRODUCTION SHOWCASE STARTED ---")

	# -------------------------------------------------------------------------
	# INTRO
	# -------------------------------------------------------------------------
	_set_ui("NEMI - 2D ANIMATION SYSTEM", "INITIALIZING", "Authoritative Reference: nemi_sheet.png")
	nemi.pose("standing")
	await get_tree().create_timer(1.0).timeout

	# -------------------------------------------------------------------------
	# ACT 1: ALL 15 CANONICAL POSES
	# -------------------------------------------------------------------------
	# Full-body poses (Camera at zoom 1.0)
	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "FULL-BODY: Standing", "Ground-aligned anchor, rock-still hold")
	nemi.pose("standing")
	await get_tree().create_timer(0.5).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "FULL-BODY: Walking", "0-frame snap, preserved silhouette")
	nemi.pose("walking")
	await get_tree().create_timer(0.5).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "FULL-BODY: Running", "Dynamic action pose")
	nemi.pose("running")
	await get_tree().create_timer(0.5).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "FULL-BODY: Pointing", "Story demonstration / presentation")
	nemi.pose("pointing")
	await get_tree().create_timer(0.5).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "FULL-BODY: Sitting", "Grounded seat alignment")
	nemi.pose("sitting")
	await get_tree().create_timer(0.5).timeout

	# Bust poses: punch-in slightly to frame waist-up
	camera.punch_in(1.35, true, Vector2(640, 440))

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Thinking", "Half-body expressive contemplation")
	nemi.pose("thinking")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Shrugging", "Casual comedic shrug")
	nemi.pose("shrugging")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Leaning", "Conversational engagement")
	nemi.pose("leaning")
	nemi.lean(5.0, 0.12)
	await get_tree().create_timer(0.45).timeout
	nemi.reset_lean(0.1)

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Looking Up", "Curiosity / upward eyeline")
	nemi.pose("looking_up")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Looking Down", "Pondering / introspective")
	nemi.pose("looking_down")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Surprised", "Sparkle reaction")
	nemi.pose("surprised")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Excited", "High energy arm gesture")
	nemi.pose("excited")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Angry", "Crossed arms pout")
	nemi.pose("angry")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Sad", "Gentle downcast emotion")
	nemi.pose("sad")
	await get_tree().create_timer(0.45).timeout

	_set_ui("ACT 1: 15 CANONICAL STORY POSES", "BUST: Laughing", "Joyful hands-on-cheeks laugh")
	nemi.pose("laughing")
	await get_tree().create_timer(0.55).timeout

	# -------------------------------------------------------------------------
	# ACT 2: 12 FACIAL EXPRESSIONS & MICRO-EVENTS (CLOSE-UP FRAMING)
	# -------------------------------------------------------------------------
	camera.punch_in(1.85, true, Vector2(640, 440))

	var expr_list = [
		["neutral", "Expression: Neutral", "Baseline calm expression"],
		["happy", "Expression: Happy", "Warm closed-eye smile"],
		["excited", "Expression: Excited", "Open sparkle enthusiasm"],
		["confused", "Expression: Confused", "Question mark tilt"],
		["angry", "Expression: Angry", "Determined fierce gaze"],
		["sad", "Expression: Sad", "Subtle wistful frown"],
		["surprised", "Expression: Surprised", "Wide-eyed gasp"],
		["embarrassed", "Expression: Embarrassed", "Soft blush reaction"],
		["smug", "Expression: Smug", "Playful side-eye smirk"],
		["annoyed", "Expression: Annoyed", "Frustrated sweat mark"],
		["shocked", "Expression: Shocked", "Stunned open mouth"],
		["laughing", "Expression: Laughing", "Cheerful hearty smile"]
	]

	for item in expr_list:
		var ename: String = item[0]
		var title: String = item[1]
		var desc: String = item[2]
		_set_ui("ACT 2: 12 FACIAL EXPRESSIONS (Bust Framing)", title, desc)
		nemi.expression(ename)
		await get_tree().create_timer(0.4).timeout

	# Micro-events
	_set_ui("ACT 2: MICRO-EVENTS", "Micro: 2-Frame Blink", "Sub-frame eye closure and reopen")
	nemi.expression("neutral")
	await get_tree().create_timer(0.25).timeout
	await nemi.blink(0.12)
	await get_tree().create_timer(0.35).timeout

	_set_ui("ACT 2: MICRO-EVENTS", "Micro: Eye Dart Glance", "Rapid directional attention shift")
	await nemi.eye_dart("left", 0.45)
	await get_tree().create_timer(0.35).timeout

	_set_ui("ACT 2: MICRO-EVENTS", "Micro: Eyebrow Raise", "Inquisitive reaction pop")
	await nemi.eyebrow_raise(0.45)
	await get_tree().create_timer(0.35).timeout

	# -------------------------------------------------------------------------
	# ACT 3: PROPS, STEPPED TALKING BOUNCE & STORY REACTIONS
	# -------------------------------------------------------------------------
	camera.punch_in(1.15, true, Vector2(640, 420))

	_set_ui("ACT 3: PROPS & ACCESSORIES", "Equipped: Drink", "Prop snap to hand anchor")
	nemi.pose("pointing")
	nemi.equip_prop("drink", Vector2(40, -50))
	await get_tree().create_timer(0.7).timeout

	_set_ui("ACT 3: PROPS & ACCESSORIES", "Equipped: Laptop", "Story context prop switch")
	nemi.pose("sitting")
	nemi.equip_prop("laptop", Vector2(10, -20))
	await get_tree().create_timer(0.7).timeout

	_set_ui("ACT 3: PROPS & ACCESSORIES", "Equipped: Smartphone", "Everyday storytelling prop")
	nemi.pose("standing")
	nemi.equip_prop("phone", Vector2(25, -60))
	await get_tree().create_timer(0.7).timeout
	nemi.unequip_prop()

	_set_ui("ACT 3: STEPPED ANIMATION", "Stepped Bounce on 2s", "Rhythmic talking bounce (6 Hz, held on 2s)")
	nemi.pose("excited")
	nemi.start_stepped_bounce(16.0, 6.0)
	await get_tree().create_timer(1.6).timeout
	nemi.stop_stepped_bounce()

	_set_ui("ACT 3: REACTION SHAKE & RECOIL", "Sudden Impact Shock", "0-frame punch-in + trauma screen shake")
	camera.punch_in(1.6, true, Vector2(640, 420))
	camera.shake(0.9, 4.0)
	nemi.pose("surprised")
	nemi.recoil(Vector2(-35, 12), 0.12)
	await get_tree().create_timer(1.2).timeout

	# -------------------------------------------------------------------------
	# OUTRO HOLD
	# -------------------------------------------------------------------------
	camera.reset_framing()
	nemi.pose("standing")
	_set_ui("NEMI PRODUCTION 2D SYSTEM", "READY FOR STORYTELLING", "15 Poses • 12 Expressions • 5 Micro-Events • 6 Props")
	await get_tree().create_timer(1.5).timeout

	print("--- NEMI PRODUCTION SHOWCASE COMPLETED SUCCESSFULLY ---")
	get_tree().quit()

func _set_ui(cat: String, action: String, desc: String) -> void:
	if category_label:
		category_label.text = cat
	if action_label:
		action_label.text = action
	if subtitle_label:
		subtitle_label.text = desc
