class_name Beat08GroundedDetermination
extends Ep04BaseBeat

## Beat 8: Grounded Determination (55.63s – 62.80s)
## seg08_overthinking: "Look, I'm probably just overthinking again. But I'm still gonna make the next video."
## Dialogue Duration: 6.72s + 0.45s pause = 7.17s

var next_video_card: Node2D = null

func _ready() -> void:
	beat_number = 8
	beat_name = "Grounded Determination"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg08_overthinking.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg08_overthinking")

	# Card 1: "Look, I'm probably" (1.50s)
	nemi.shrug(0.8)
	nemi.head_tilt(-5.0, 0.25)
	await wait_seconds(1.50) # 1.50s reached

	# Card 2: "just overthinking again." (1.80s)
	nemi.set_expression("happy")
	nemi.nod(0.6, 0.3)
	var cat = cat_mascot(Vector2(360, 520))
	await wait_seconds(1.80) # 3.30s reached

	# Card 3: "But I'm still gonna" (1.60s)
	nemi.set_expression("warm")
	nemi.gesture_open_palm("right", 0.25)
	comic_lightbulb(Vector2(0, -145), 1.4)
	next_video_card = Ep04Doodles.spawn_next_video(self, Vector2(840, 300))
	var goal_note = sticky_note("DON'T QUIT!\n(make stuff anyway)", Vector2(230, 220), 4.0)
	await wait_seconds(1.60) # 4.90s reached

	# Card 4: "make the next video." (1.82s)
	cam_punch(Vector2(0, -20), 1.20, 0.25)
	nemi.set_expression("excited")
	nemi.nod(1.0, 0.35)
	var bubble = action_bubble("*LET'S GO!*", Vector2(860, 140))
	comic_sparkles(Vector2(880, 240), 1.8)
	await wait_seconds(1.82) # 6.72s reached (dialogue complete)

	# Post-dialogue pause (0.45s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if next_video_card and is_instance_valid(next_video_card) and next_video_card.has_method("fade_out"):
		next_video_card.fade_out(0.25)
	if goal_note and is_instance_valid(goal_note):
		fade_tw.tween_property(goal_note, "modulate:a", 0.0, 0.25)
	if bubble and is_instance_valid(bubble):
		fade_tw.parallel().tween_property(bubble, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.45) # 7.17s reached

	end_beat()
