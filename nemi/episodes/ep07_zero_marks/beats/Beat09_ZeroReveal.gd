extends "res://nemi/episodes/ep07_zero_marks/Ep07BaseBeat.gd"

## Beat 09: Escalating Hope & The Big ZERO Punchline (102.86s – 122.55s)
## Segments:
## - seg28_thought_id_get_something (102.86s – 106.94s, pause 0.40s)
## - seg29_maybe_ten_five_pity (107.34s – 111.42s, pause 0.55s)
## - seg30_sheets_back (111.97s – 113.41s, pause 0.40s)
## - seg31_there_it_was_zero (113.81s – 118.13s, pause 0.45s)
## - seg32_thirty_available_got_zero (118.58s – 121.70s, pause 0.85s)

var paper_prop: Node2D

func _ready() -> void:
	beat_number = 9
	beat_name = "Zero Reveal"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg28_thought_id_get_something.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_NORMAL_STUDIO, 0.0)

	nemi.reset()
	nemi.position = Vector2(480.0, 470.0)
	nemi.set_pose("relaxed_standing", 0.0)
	nemi.set_expression("candid")
	nemi.look("center")

	var cards = Episode07SubtitlesClass.get_cards_for_beat(9)
	var t: float = 102.86

	# Card 0: "And honestly?" (102.860 - 104.410) - Conversational lean
	nemi.set_pose("leaning_forward_confiding", 0.2)
	nemi.head_tilt(-2.0, 0.2)
	t = await play_card_sync(cards[0], t)

	# Card 1: "I thought I'd get" (104.410 - 105.798)
	nemi.set_pose("thinking_chin_touch", 0.2)
	nemi.look("up_right")
	t = await play_card_sync(cards[1], t)

	# Card 2: "SOMETHING." (105.798 - 106.940) - Hopeful smile
	cam_punch(Vector2(0, -10), 1.15, 0.15)
	nemi.set_expression("smile")
	t = await play_card_sync(cards[2], t)

	# Pause (106.94s - 107.34s) - Bargaining begins
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg29_maybe_ten_five_pity.wav")
		voice_player.play(0.0)

	nemi.set_pose("both_hands_explaining_asym", 0.2)

	# Card 3: "Maybe ten marks." (107.340 - 108.768) - 10 marks annotation appears
	doodle_director.draw_hope_marks(Vector2(850.0, 220.0), 0, 0.25).auto_dismiss(5.0)
	play_sfx("pop", -3.0)
	t = await play_card_sync(cards[3], t)

	# Card 4: "Maybe five." (108.768 - 109.870) - 5 marks annotation appears
	nemi.head_tilt(3.0, 0.18)
	doodle_director.draw_hope_marks(Vector2(850.0, 280.0), 1, 0.25).auto_dismiss(4.0)
	play_sfx("pop", -2.5, 1.1)
	t = await play_card_sync(cards[4], t)

	# Card 5: "Maybe pity marks." (109.870 - 111.420) - Pity marks annotation
	nemi.set_pose("hand_behind_head_sheepish", 0.2)
	nemi.set_expression("candid")
	doodle_director.draw_hope_marks(Vector2(850.0, 340.0), 2, 0.25).auto_dismiss(3.0)
	play_sfx("pop", -2.0, 1.2)
	t = await play_card_sync(cards[5], t)

	# Pause (111.42s - 111.97s) - Handing back answer sheets
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg30_sheets_back.wav")
		voice_player.play(0.0)

	paper_prop = spawn_prop("paper_sheet", Vector2(480.0, 430.0), fg_props_layer)
	play_sfx("whoosh", -5.0)

	# Card 6: "Then we got" (111.970 - 112.618)
	nemi.set_pose("holding_sheet_front", 0.2)
	nemi.look("down_center")
	t = await play_card_sync(cards[6], t)

	# Card 7: "our answer sheets back." (112.618 - 113.410)
	t = await play_card_sync(cards[7], t)

	# Pause (113.41s - 113.81s) - The Dramatic Reveal!
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg31_there_it_was_zero.wav")
		voice_player.play(0.0)

	transition_backdrop(MODE_ZERO_REVEAL, 0.35)

	# Card 8: "And there it was." (113.810 - 115.452)
	cam_punch(Vector2(0, -10), 1.2, 0.2)
	t = await play_card_sync(cards[8], t)

	# Card 9: "Zero." (115.452 - 116.488) - BIG ZERO PUNCHLINE (staged cleanly on right side)!
	cam_punch(Vector2(10, -15), 1.35, 0.12)
	doodle_director.draw_big_zero_punchline(Vector2(840.0, 240.0), 0.35).auto_dismiss(8.0)
	nemi.set_pose("shocked_recoil", 0.12)
	nemi.set_expression("horror")
	play_sfx("error", -1.0)
	t = await play_card_sync(cards[9], t)

	# Card 10: "Zero out of thirty." (116.488 - 118.130) - Complete disbelief
	nemi.set_pose("exam_blank_stare", 0.2)
	nemi.set_expression("deadpan")
	nemi.look("center")
	t = await play_card_sync(cards[10], t)

	# Pause (118.13s - 118.58s)
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep07_zero_marks/audio/segments/seg32_thirty_available_got_zero.wav")
		voice_player.play(0.0)

	# Card 11: "Thirty marks were available." (118.580 - 120.296)
	t = await play_card_sync(cards[11], t)

	# Card 12: "I got..." (120.296 - 120.982) - Suspended breath
	t = await play_card_sync(cards[12], t)

	# Card 13: "ZERO." (120.982 - 121.700) - Final deadpan hammer punch
	cam_punch(Vector2(0, -5), 1.45, 0.1)
	play_sfx("bruh", -3.0)
	t = await play_card_sync(cards[13], t)

	# Hold into Beat 10 (121.70s - 122.55s)
	await finish_beat_sync(t, 122.55)
