class_name Beat02NotHorror
extends Ep04BaseBeat

## Beat 2: Not Horror (9.92s – 17.15s)
## seg02_not_horror: "Not like horror movie terrified. Just... what if this whole YouTube thing doesn't work?"
## Dialogue Duration: 6.88s + 0.35s pause = 7.23s

var ghost_card: Node2D = null

func _ready() -> void:
	beat_number = 2
	beat_name = "Not Horror"
	super._ready()

func _run_beat_choreography() -> void:
	if is_standalone and voice_player and not OS.has_feature("movie"):
		voice_player.stream = load("res://nemi/episodes/ep04_scared/audio/segments/seg02_not_horror.wav")
		voice_player.play(0.0)

	cam_preset(StoryCamera2D.ShotPreset.MEDIUM, 0.0)

	nemi.reset()
	nemi.set_pose("casual_standing", 0.0)
	nemi.set_expression("smug")
	nemi.look("center")

	# Start subtitle cards and live illustrative speech
	play_segment("seg02_not_horror")

	# Card 1: "Not like horror movie terrified." (2.50s)
	# Playful shrug and ghost sketchcard pop-in
	nemi.head_tilt(-8.0, 0.2)
	nemi.shrug(0.8)
	ghost_card = Ep04Doodles.spawn_ghost_card(self, Vector2(840, 260))
	
	await wait_seconds(1.20)
	# Cross out the ghost with a big red X and comedic NOPE bubble!
	if ghost_card and is_instance_valid(ghost_card) and ghost_card.has_method("trigger_crossout"):
		ghost_card.trigger_crossout(0.25)
	var nope_bubble = action_bubble("*NOPE!*", Vector2(850, 130))
	await wait_seconds(1.30) # 2.50s reached

	# Card 2: "Just... what if" (1.80s)
	# Playful dutch angle tilt as Nemi ponders
	cam_dutch(-3.5, 0.3)
	if ghost_card and is_instance_valid(ghost_card):
		var tw := create_tween()
		tw.tween_property(ghost_card, "modulate:a", 0.0, 0.25)
		tw.tween_callback(ghost_card.queue_free)
	if nope_bubble and is_instance_valid(nope_bubble):
		var tw_b := create_tween()
		tw_b.tween_property(nope_bubble, "modulate:a", 0.0, 0.25)
		tw_b.tween_callback(nope_bubble.queue_free)
		
	nemi.set_pose("thinking", 0.25)
	nemi.set_expression("confused")
	nemi.look("up_left")
	comic_question(Vector2(25, -135), 1.4)
	var whatif_note = sticky_note("WHAT IF...??", Vector2(230, 250), -5.0)
	await wait_seconds(1.80) # 4.30s reached

	# Card 3: "this whole YouTube thing" (1.40s)
	cam_dutch(0.0, 0.25)
	nemi.look("center")
	nemi.set_expression("worried")
	nemi.head_tilt(4.0, 0.2)
	var yt_doodle = Ep04Doodles.spawn_youtube_card(self, Vector2(840, 280))
	await wait_seconds(1.40) # 5.70s reached

	# Card 4: "doesn't work?" (1.18s)
	cam_punch(Vector2(0, -12), 1.15, 0.2)
	nemi.set_expression("worried")
	nemi.head_tilt(4.0, 0.2)
	nemi.nod(0.5, 0.3)
	comic_sweat(Vector2(-24, -95), 1.0)
	var chibi = facepalm_chibi(Vector2(210, 360))
	await wait_seconds(1.18) # 6.88s reached (dialogue complete)

	# Post-dialogue pause (0.35s)
	nemi.stop_speech()
	if yt_doodle and is_instance_valid(yt_doodle):
		var tw_yt := create_tween()
		tw_yt.tween_property(yt_doodle, "modulate:a", 0.0, 0.25)
	if whatif_note and is_instance_valid(whatif_note):
		var tw_n := create_tween()
		tw_n.tween_property(whatif_note, "modulate:a", 0.0, 0.25)
	if chibi and is_instance_valid(chibi):
		var tw_c := create_tween()
		tw_c.tween_property(chibi, "modulate:a", 0.0, 0.25)
	await wait_seconds(0.35) # 7.23s reached

	end_beat()

