class_name Beat07BecauseICare
extends Ep04BaseBeat

## Beat 7: Because I Care (48.73s – 55.63s)
## seg07_because_i_care: "And the only reason it's scary is because I actually care. Like, a lot."
## Dialogue Duration: 6.40s + 0.50s pause = 6.90s

var heart_card: Node2D = null

func _ready() -> void:
	beat_number = 7
	beat_name = "Because I Care"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg07_because_i_care.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM_CLOSEUP, 0.0)

	nemi.reset()
	nemi.set_pose("hand_on_heart", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# Cinematic slow push in over the confession
	cam_push_in(0.20, 5.0)

	# Start subtitle cards and live illustrative speech
	play_segment("seg07_because_i_care")

	# Card 1: "And the only reason" (1.60s)
	nemi.head_tilt(-4.0, 0.3)
	await wait_seconds(1.60) # 1.60s reached

	# Card 2: "it's scary" (1.20s)
	nemi.set_expression("worried")
	nemi.blink(0.18)
	var dot_bubble = action_bubble("...", Vector2(420, 180))
	await wait_seconds(1.20) # 2.80s reached

	# Card 3: "is because I actually care." (2.00s)
	nemi.set_expression("warm")
	nemi.nod(0.7, 0.35)
	heart_card = Ep04Doodles.spawn_heart_card(self, Vector2(880, 260))
	var hearts = heart_burst(Vector2(540, 310))
	comic_sparkles(Vector2(880, 160), 2.2)
	nemi.set_micro_accent("blush", true)
	await wait_seconds(2.00) # 4.80s reached

	# Card 4: "Like, a lot." (1.60s)
	cam_punch(Vector2(0, -15), 1.12, 0.3)
	nemi.head_tilt(4.0, 0.3)
	nemi.set_expression("happy")
	var care_note = sticky_note("WORTH IT ♡", Vector2(230, 240), -4.0)
	comic_sparkles(Vector2(530, 290), 1.5)
	await wait_seconds(1.60) # 6.40s reached (dialogue complete)

	# Post-dialogue pause (0.50s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if heart_card and is_instance_valid(heart_card) and heart_card.has_method("fade_out"):
		heart_card.fade_out(0.25)
	if dot_bubble and is_instance_valid(dot_bubble):
		fade_tw.tween_property(dot_bubble, "modulate:a", 0.0, 0.25)
	if care_note and is_instance_valid(care_note):
		fade_tw.parallel().tween_property(care_note, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.50) # 6.90s reached

	end_beat()
