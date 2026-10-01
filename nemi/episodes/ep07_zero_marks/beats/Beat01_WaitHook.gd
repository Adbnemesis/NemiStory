extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 01: Wait Hook (0.00s – 5.08s)
## Segments:
## - seg01_wait (0.00s – 0.48s, pause 0.45s)
## - seg02_fastest_way (0.93s – 4.53s, pause 0.55s)

func _ready() -> void:
	beat_number = 1
	beat_name = "Wait Hook"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg01_wait.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.0)
	transition_backdrop(MODE_NORMAL_STUDIO, 0.0)

	nemi.reset()
	nemi.position = Vector2(540.0, 465.0)
	nemi.set_pose("shocked_recoil", 0.0)
	nemi.set_expression("shock")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(1)
	var t: float = 0.0

	# Card 0: "WAIT." (0.000 - 0.480) - Sudden energetic freeze & eye contact
	cam_punch(Vector2(0, -10), 1.22, 0.1)
	nemi.head_tilt(-2.0, 0.1)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	nemi.set_hand_pose_left(NemiLimbPart.HandPose.OPEN_PALM_UP)
	play_sfx("whoosh", -4.0, 1.1)
	t = await play_card_sync(cards[0], t)

	# Comedic pause (0.48s - 0.93s) - Eyes narrow, slight forward lean, conspiratorial shift
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg02_fastest_way.wav")
		voice_player.play(0.0)

	nemi.set_pose("leaning_forward_confiding", 0.2)
	nemi.set_expression("candid")
	nemi.look("center")

	# Card 1: "I think I discovered" (0.930 - 2.010)
	t = await play_card_sync(cards[1], t)

	# Card 2: "the fastest way" (2.010 - 2.802) - Gestures with right hand
	nemi.set_pose("one_hand_explaining", 0.18)
	nemi.head_tilt(3.0, 0.15)
	t = await play_card_sync(cards[2], t)

	# Card 3: "to get zero marks" (2.802 - 3.810) - Sudden wide eyes, punch in
	cam_punch(Vector2(10, -5), 1.28, 0.12)
	nemi.set_pose("both_hands_explaining_asym", 0.15)
	nemi.set_expression("shock")
	doodle_director.spawn_speech_bubble(Vector2(850.0, 240.0), "ZERO?!", INK_RED).auto_dismiss(1.8)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[3], t)

	# Card 4: "in an exam." (3.810 - 4.530) - Small self-aware shrug
	nemi.set_pose("casual_hand_on_hip", 0.2)
	nemi.set_expression("deadpan")
	nemi.head_tilt(-4.0, 0.2)
	t = await play_card_sync(cards[4], t)

	# Hold / trailing breath before Beat 02 (4.53s - 5.08s)
	await finish_beat_sync(t, 5.08)
