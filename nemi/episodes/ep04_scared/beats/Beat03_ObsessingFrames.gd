class_name Beat03ObsessingFrames
extends Ep04BaseBeat

## Beat 3: Obsessing Over Frames (17.15s – 24.33s)
## seg03_love_making: "Like, I love making these animations. I spend days obsessing over every little frame..."
## Dialogue Duration: 6.88s + 0.30s pause = 7.18s

var tablet_card: Node2D = null

func _ready() -> void:
	beat_number = 3
	beat_name = "Obsessing Over Frames"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg03_love_making.wav")
		voice_player.play(0.0)

	# 1. Staging & Initial Framing
	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	if studio_backdrop and studio_backdrop.has_method("set_desk_visible"):
		studio_backdrop.set_desk_visible(true)

	nemi.reset()
	nemi.set_pose("hand_on_heart", 0.0)
	nemi.set_expression("warm")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg03_love_making")

	# Card 1: "Like, I love making" (1.80s)
	nemi.head_tilt(-6.0, 0.3)
	var hearts = heart_burst(Vector2(530, 330))
	await wait_seconds(1.80) # 1.80s reached

	# Card 2: "these animations." (1.40s)
	comic_sparkles(Vector2(530, 280), 1.6)
	nemi.nod(0.8, 0.35)
	await wait_seconds(1.40) # 3.20s reached

	# Card 3: "I spend days obsessing" (1.80s)
	cam_push_in(0.18, 3.5)
	nemi.set_pose("leaning", 0.25)
	nemi.set_expression("excited")
	nemi.look("right")
	# Hand-drawn hunched shrimp posture doodle ("<- My posture")
	tablet_card = Ep04Doodles.spawn_shrimp_posture(self, Vector2(850, 310))
	var mug = coffee_mug(Vector2(380, 520))
	await wait_seconds(1.80) # 5.00s reached

	# Card 4: "over every little frame..." (1.88s)
	cam_punch(Vector2(30, -10), 1.12, 0.25)
	nemi.nod(0.8, 0.4)
	var frame_note = sticky_note("FRAME 4,291:\n(fix hair strand!)", Vector2(230, 260), 4.0)
	await wait_seconds(1.88) # 6.88s reached (dialogue complete)

	# Post-dialogue pause (0.30s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if tablet_card and is_instance_valid(tablet_card):
		fade_tw.tween_property(tablet_card, "modulate:a", 0.0, 0.25)
	if frame_note and is_instance_valid(frame_note):
		fade_tw.parallel().tween_property(frame_note, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.30) # 7.18s reached

	end_beat()
