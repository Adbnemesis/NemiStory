extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 01: The Question & The Laptop Hook (0.0s – 13.28s)
## Segments:
## - seg01_people_ask (8.04s)
## - seg02_laptop_magic (4.79s)

var laptop_prop: Node2D
var cup_prop: Node2D

func _ready() -> void:
	beat_number = 1
	beat_name = "The Question"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg01_people_ask.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.WIDE, 0.0)
	transition_backdrop(MODE_NORMAL_STUDIO, 0.0)

	# 1. Physical Staging & Props Setup (ZERO intersection: Desk at 340, Nemi at 580)
	var desk = spawn_prop("desk", Vector2(340.0, 485.0))
	laptop_prop = spawn_prop("laptop", Vector2(340.0, 440.0))
	cup_prop = spawn_prop("cup", Vector2(395.0, 446.0))

	nemi.reset()
	nemi.position = Vector2(580.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("smile")
	nemi.look("center")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(1)

	# Card 1: "People always ask me" (1.78s) - Natural conversational open
	nemi.look("center")
	nemi.head_tilt(-2.0, 0.15)
	nemi.set_pose("one_hand_explaining", 0.22)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	doodle_director.spawn_question_burst(Vector2(780.0, 240.0)).auto_dismiss(3.0)
	await _run_card(cards[0])

	# Card 2: "how I actually make" (1.87s) - Hand gesture shifts
	nemi.head_tilt(3.0, 0.18)
	nemi.set_pose("both_hands_explaining_asym", 0.22)
	await _run_card(cards[1])

	# Card 3: "storytime animations." (1.87s) - Camera punch with ink accent
	cam_punch(Vector2(20, -10), 1.15, 0.18)
	nemi.set_expression("warm")
	nemi.look("center")
	doodle_director.spawn_speech_bubble(Vector2(800.0, 270.0), "STORYTIME", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[2])

	# Card 4: "Like, do they just" (1.78s) - Gaze shifts to the laptop desk
	nemi.look("down_left")
	nemi.head_tilt(-4.0, 0.2)
	nemi.set_pose("casual_lean_left", 0.22)
	await _run_card(cards[3])

	# Card 5: "pop out of my" (1.20s) - Gestures toward the laptop
	nemi.set_pose("pointing_forward", 0.18)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.POINTING)
	doodle_director.spawn_magic_sparks(Vector2(340.0, 360.0)).auto_dismiss(2.5)
	play_sfx("pop", -3.0)
	await _run_card(cards[4])

	# Card 6: "laptop magically?" (1.00s) - Skeptical pause with comic speech bubble
	cam_punch(Vector2(-15, -15), 1.25, 0.12)
	nemi.set_pose("arms_crossed_skeptical", 0.15)
	nemi.set_expression("candid")
	nemi.look("center")
	doodle_director.spawn_speech_bubble(Vector2(780.0, 280.0), "MAGIC??", INK_RED).auto_dismiss(1.8)
	await _run_card(cards[5])

	# Comedic hold between seg01 and seg02 (0.45s) — Deadpan stare
	nemi.stop_speech()
	nemi.blink(0.12)
	await wait_seconds(0.45)

	# Card 7: "I wish." (1.08s) - Defeated slump & anime sweat
	nemi.set_pose("defeated_slump", 0.18)
	nemi.set_expression("deadpan")
	nemi.head_tilt(4.0, 0.2)
	doodle_director.spawn_deadpan_sweat(Vector2(650.0, 300.0)).auto_dismiss(2.2)
	play_sfx("bruh", -5.0)
	await _run_card(cards[6])

	# Card 8: "Here's what actually" (1.18s) - Energetic recovery
	nemi.set_pose("presenting_prop", 0.22)
	nemi.set_expression("smile")
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	cam_reset(0.3)
	await _run_card(cards[7])

	# Card 9: "happens." (1.08s) - Hand-drawn truth stamp
	nemi.set_pose("one_hand_explaining", 0.2)
	nemi.set_expression("laugh")
	doodle_director.spawn_handwritten_stamp(Vector2(800.0, 240.0), "THE TRUTH", INK_RED, 26).auto_dismiss(2.0)
	await _run_card(cards[8])

	# Pause after beat (0.45s)
	nemi.stop_speech()
	await wait_seconds(0.45)
	end_beat()
