extends "res://nemi/episodes/ep06_how_i_animate/Ep06BaseBeat.gd"

## Beat 07: Godot Animation & The Timeline Scare (81.46s – 96.15s)
## Segments:
## - seg13_open_godot (8.85s)
## - seg14_forty_tracks_dread (5.34s)

func _ready() -> void:
	beat_number = 7
	beat_name = "Godot Animation & The Timeline Scare"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep06_how_i_animate/audio/segments/seg13_open_godot.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	transition_backdrop(MODE_NORMAL_STUDIO, 0.0)

	nemi.reset()
	nemi.position = Vector2(540.0, 480.0)
	nemi.set_pose("relaxed_standing_right_weight", 0.0)
	nemi.set_expression("smile")
	nemi.look("center")

	var cards = Episode06SubtitlesClass.get_cards_for_beat(7)

	# Card 1: "Then I open Godot" (1.87s) - Typing on laptop sound, speech bubble in open space
	nemi.position = Vector2(545.0, 480.0)
	nemi.set_pose("one_hand_explaining", 0.22)
	doodle_director.spawn_speech_bubble(Vector2(760.0, 240.0), "GODOT 4", INK_GOLD).auto_dismiss(2.5)
	await _run_card(cards[0])

	# Card 2: "to animate." (1.36s)
	nemi.set_hand_pose_right(NemiLimbPart.HandPose.OPEN_PALM_UP)
	await _run_card(cards[1])

	# Card 3: "I tell myself," (1.53s)
	nemi.head_tilt(-4.0, 0.2)
	nemi.look("up_right")
	await _run_card(cards[2])

	# Card 4: "'Oh, this will be" (1.87s) - Excited bounce
	nemi.position = Vector2(540.0, 476.0)
	nemi.set_pose("excited", 0.2)
	nemi.set_expression("laugh")
	doodle_director.spawn_magic_sparks(Vector2(540.0, 220.0)).auto_dismiss(2.0)
	await _run_card(cards[3])

	# Card 5: "so simple and fast!'" (1.87s) - Confident stance
	nemi.position = Vector2(540.0, 480.0)
	nemi.set_pose("relaxed_standing_left_weight", 0.2)
	doodle_director.spawn_handwritten_stamp(Vector2(750.0, 300.0), "EASY PEASY", INK_MINT).auto_dismiss(1.8)
	await _run_card(cards[4])

	# Pause between seg13 and seg14 (0.35s) — Transition to Godot Grid
	nemi.stop_speech()
	transition_backdrop(MODE_GODOT_GRID, 0.25)
	await wait_seconds(0.35)

	# Card 6: "And then I see" (1.29s) - Lean left, looking down at timeline tracks
	nemi.position = Vector2(520.0, 482.0)
	nemi.set_pose("casual_lean_left", 0.18)
	nemi.set_expression("neutral")
	nemi.look("down_right")
	await _run_card(cards[5])

	# Card 7: "forty keyframe tracks." (1.39s) — Overwhelm hits! Recoil step back to left
	cam_punch(Vector2(-30, 25), 1.18, 0.12)
	cam_shake(5.0, 0.2)
	nemi.position = Vector2(470.0, 465.0)
	nemi.set_pose("recoiling", 0.10)
	nemi.set_expression("shock")
	doodle_director.spawn_keyframe_overwhelm(Vector2(720.0, 240.0)).auto_dismiss(3.5)
	play_sfx("error", -6.0)
	await _run_card(cards[6])

	# Card 8: "And my soul briefly" (1.29s) - Slump into defeat
	nemi.set_pose("defeated_slump", 0.22)
	nemi.set_expression("deadpan")
	nemi.look("center")
	await _run_card(cards[7])

	# Card 9: "leaves my body." (1.39s) - Dramatic despair, stamp in upper right
	nemi.set_pose("dramatic_despair", 0.22)
	doodle_director.spawn_handwritten_stamp(Vector2(780.0, 240.0), "SOUL EXITED", INK_RED).auto_dismiss(2.5)
	await _run_card(cards[8])

	# Pause after beat (0.50s)
	nemi.stop_speech()
	cam_reset(0.3)
	await wait_seconds(0.50)
	end_beat()
