class_name Beat06ProdigiesAndChaos
extends Ep04BaseBeat

## Beat 6: Prodigies vs Timeline Chaos (41.21s – 48.73s)
## seg06_other_animators: "I see all these insane animators online, and then I look at my timeline, and it's just pure chaos."
## Dialogue Duration: 7.12s + 0.40s pause = 7.52s

var chaos_card: Node2D = null

func _ready() -> void:
	beat_number = 6
	beat_name = "Prodigies vs Timeline Chaos"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg06_other_animators.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)
	set_night_mode(false, 0.3)

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("neutral")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg06_other_animators")

	# Card 1: "I see all these" (1.40s)
	cam_push_in(0.15, 3.0)
	nemi.look("right")
	nemi.head_tilt(-5.0, 0.25)
	await wait_seconds(1.40) # 1.40s reached

	# Card 2: "insane animators online," (2.00s)
	nemi.set_expression("excited")
	nemi.look("up_right")
	comic_sparkles(Vector2(940, 230), 1.8)
	if doodle_director:
		doodle_director.emphasis(Vector2(950, 260), 45.0, 0.25)
	var star_note = sticky_note("12-YR-OLD GODS\nOF BLENDER ★", Vector2(880, 160), 5.0)
	await wait_seconds(2.00) # 3.40s reached

	# Card 3: "and then I look" (1.30s)
	cam_punch(Vector2(-35, -10), 1.15, 0.25)
	nemi.head_turn(-18.0, 0.15)
	nemi.look("down_left")
	chaos_card = Ep04Doodles.spawn_timeline_chaos(self, Vector2(360, 360))
	await wait_seconds(1.30) # 4.70s reached

	# Card 4: "at my timeline," (1.10s)
	nemi.set_expression("deadpan")
	var mug = coffee_mug(Vector2(480, 500))
	await wait_seconds(1.10) # 5.80s reached

	# Card 5: "and it's just pure chaos." (1.32s)
	cam_shake(10.0, 0.35, 24.0)
	nemi.set_expression("annoyed")
	nemi.shrug(0.8)
	var crash_bubble = action_bubble("*CRASH!*", Vector2(250, 180))
	var chibi = facepalm_chibi(Vector2(850, 300))
	await wait_seconds(1.32) # 7.12s reached (dialogue complete)

	# Post-dialogue pause (0.40s)
	nemi.stop_speech()
	var fade_tw := create_tween()
	if chaos_card and is_instance_valid(chaos_card) and chaos_card.has_method("fade_out"):
		chaos_card.fade_out(0.25)
	if star_note and is_instance_valid(star_note):
		fade_tw.tween_property(star_note, "modulate:a", 0.0, 0.25)
	if crash_bubble and is_instance_valid(crash_bubble):
		fade_tw.parallel().tween_property(crash_bubble, "modulate:a", 0.0, 0.25)
	if chibi and is_instance_valid(chibi):
		fade_tw.parallel().tween_property(chibi, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.40) # 7.52s reached

	end_beat()
