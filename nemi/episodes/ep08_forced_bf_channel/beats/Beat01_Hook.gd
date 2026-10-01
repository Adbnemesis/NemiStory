extends "res://nemi/episodes/ep08_forced_bf_channel/Ep08BaseBeat.gd"

## Beat 01: The Hook (0.00s -> 6.16s | 6.16s, buffer to 6.71s)
## Segments:
## - seg01_new_problem: "I HAVE A NEW PROBLEM."
## - seg02_convinced_bf: "I somehow convinced my boyfriend to start a YouTube channel."

func _ready() -> void:
	beat_number = 1
	beat_name = "The Hook"
	super._ready()

func _run_beat_choreography() -> void:
	# 1. Instant environment cut (ZERO delay)
	backdrop.set_mode(0, 0.0) # NORMAL_STUDIO

	# 2. Camera framing: Medium close-up on Nemi center stage
	cam_punch(1.18, true, Vector2(960, 520))

	# 3. Character initial pose
	nemi.position = Vector2(960, NEMI_BASE_Y)
	nemi.reset()
	nemi.set_pose("shocked_recoil", 0.0)
	nemi.set_expression("shock")
	nemi.look("camera")

	var cards = Episode08SubtitlesClass.get_cards_for_beat(1)
	var t: float = 0.0

	# Card 0: "I have a new problem." (0.000 - 1.252)
	play_sfx("whoosh", -2.5, 1.10)
	cam_shake(0.45, 3.5)
	nemi.head_tilt(-4.0, 0.10)
	doodles.spawn_comic_exclamation(Vector2(960, 240), 0.18).auto_dismiss(2.0)
	doodles.spawn_stress_spiral(Vector2(960, 290), doodles.INK_MAIN, 0.28).auto_dismiss(2.5)
	t = await play_card_sync(cards[0], t)

	# Spoken pause: Nemi leans forward confidingly
	nemi.set_pose("leaning_forward_confiding", 0.18)
	nemi.set_expression("candid")
	nemi.look("camera")
	cam_push(1.12, 4.0)

	# Card 1: "I somehow convinced" (1.635 - 2.991)
	doodles.spawn_sweat_drop(Vector2(995, 395), 0.20).auto_dismiss(2.0)
	t = await play_card_sync(cards[1], t)

	# Card 2: "my boyfriend to start" (2.991 - 4.709)
	nemi.set_pose("one_hand_explaining", 0.18)
	nemi.head_tilt(2.8, 0.15)
	doodles.spawn_question_marks(Vector2(1180, 420), 2, 0.22).auto_dismiss(2.2)
	t = await play_card_sync(cards[2], t)

	# Card 3: "a YouTube channel." (4.709 - 6.155)
	nemi.set_pose("both_hands_explaining_asym", 0.16)
	nemi.set_expression("shock")
	cam_punch(1.18, false, Vector2(960, 500))
	play_sfx("pop", -2.0, 1.15)
	doodles.spawn_idea_lightbulb(Vector2(960, 260), doodles.INK_RED, 0.25).auto_dismiss(2.2)
	t = await play_card_sync(cards[3], t)

	# Transition to Beat 2 (6.16s -> 6.71s)
	await finish_beat_sync(t, 6.707)
