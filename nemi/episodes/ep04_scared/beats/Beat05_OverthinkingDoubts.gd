class_name Beat05OverthinkingDoubts
extends Ep04BaseBeat

## Beat 5: Overthinking Doubts (33.42s – 41.21s)
## seg05_what_if: "And my brain immediately goes: what if nobody watches, and I just never get better?"
## Dialogue Duration: 7.44s + 0.35s pause = 7.79s

func _ready() -> void:
	beat_number = 5
	beat_name = "Overthinking Doubts"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg05_what_if.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	set_night_mode(false, 0.2)

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("shocked")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg05_what_if")

	# Card 1: "And my brain immediately goes:" (2.00s)
	# Recoil with comic dutch angle + camera shake
	cam_dutch(6.0, 0.25)
	cam_shake(8.0, 0.35, 22.0)
	nemi.set_pose("recoiling", 0.12)
	nemi.shake(0.3)
	comic_brain_spiral(Vector2(0, -260), 2.5)
	var spiral_bubble = action_bubble("*SPIRAL*", Vector2(230, 140))
	await wait_seconds(2.00) # 2.00s reached

	# Card 2: "what if nobody watches," (2.00s)
	cam_dutch(0.0, 0.3)
	nemi.set_pose("casual_standing", 0.25)
	nemi.hands_together()
	nemi.set_expression("worried")
	nemi.look("down_left")
	var meter = panic_meter(Vector2(850, 260))
	comic_sweat(Vector2(-26, -100), 1.0)
	await wait_seconds(2.00) # 4.00s reached

	# Card 3: "and I just" (1.40s)
	nemi.look("center")
	nemi.head_tilt(-5.0, 0.25)
	var arrow = Ep04Doodles.HandDrawnArrow.new(Vector2(860, 240), Vector2(740, 260), "overthinking...", Color("#ff6b6b"), true)
	add_child(arrow)
	arrow.animate_draw_on(0.4)
	var brain_note = sticky_note("BRAIN:\nSHUT UP PLS", Vector2(230, 280), -4.0)
	await wait_seconds(1.40) # 5.40s reached

	# Card 4: "never get better?" (2.04s)
	cam_push_in(0.18, 2.5)
	nemi.set_expression("sad")
	nemi.nod(0.6, 0.4)
	var chibi = facepalm_chibi(Vector2(200, 420))
	await wait_seconds(2.04) # 7.44s reached (dialogue complete)

	# Post-dialogue pause (0.35s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if spiral_bubble and is_instance_valid(spiral_bubble):
		fade_tw.tween_property(spiral_bubble, "modulate:a", 0.0, 0.25)
	if meter and is_instance_valid(meter):
		fade_tw.parallel().tween_property(meter, "modulate:a", 0.0, 0.25)
	if brain_note and is_instance_valid(brain_note):
		fade_tw.parallel().tween_property(brain_note, "modulate:a", 0.0, 0.25)
	if chibi and is_instance_valid(chibi):
		fade_tw.parallel().tween_property(chibi, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.35) # 7.79s reached

	end_beat()
