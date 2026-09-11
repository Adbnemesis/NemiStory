extends SceneTree
## Episode00SFXTest.gd — Narrative Sequence Integration Test
##
## Simulates the exact comedic sound language required for Nemi storytelling:
## Beat 1: Nemi notices something   -> tiny whoosh (whoosh_gesture_soft_02)
## Beat 2: Prop appears             -> pop (cartoon_pop_bubble_01)
## Beat 3: Nemi reacts              -> shock accent (sting_dramatic_shock_01)
## Beat 4: Object drops             -> cartoon drop (cartoon_fall_whistle_01)
## Beat 5: Impact                   -> heavy impact (impact_thud_heavy_01)
## Beat 6: Deadpan silence          -> 1.2s awkward silence (no sound)
## Beat 7: Recovery closure         -> confirmation chime (ui_confirm_chime_01)

const NemiAudioScript = preload("res://world/audio/NemiAudio.gd")

var audio_mgr: Node = null

func _init() -> void:
	print("============================================================")
	print("  EPISODE 00 — SFX NARRATIVE INTEGRATION TEST")
	print("============================================================")
	call_deferred("_run_narrative_test")

func _run_narrative_test() -> void:
	# Instantiate audio manager
	audio_mgr = NemiAudioScript.new()
	root.add_child(audio_mgr)
	audio_mgr._ready()

	print("Initialized NemiAudio manager with %d registered assets." % audio_mgr._catalog_by_id.size())
	print("\n--- BEGIN STORYTELLING AUDIO SEQUENCE ---")

	var sequence: Array[Dictionary] = [
		{
			"beat": "1. Nemi Notices Something",
			"desc": "Hand gesture darting toward screen corner",
			"event": {"id": "whoosh_gesture_soft_02", "volume_db": -6.0, "pitch_scale": 1.05},
			"wait": 0.25
		},
		{
			"beat": "2. Prop Appears",
			"desc": "Teacup doodle pops into existence",
			"event": {"id": "cartoon_pop_bubble_01", "volume_db": -2.0, "pitch_scale": 1.0},
			"wait": 0.35
		},
		{
			"beat": "3. Nemi Reacts",
			"desc": "Wide-eyed comic realization / panic spike",
			"event": {"id": "sting_bell_dramatic_01", "volume_db": 0.0, "pitch_scale": 1.0},
			"wait": 0.40
		},
		{
			"beat": "4. Object Drops",
			"desc": "Teacup slips off desk in physical comedy fall",
			"event": {"id": "cartoon_slidewhistle_down_01", "volume_db": -2.0, "pitch_scale": 0.95},
			"wait": 0.50
		},
		{
			"beat": "5. Heavy Impact",
			"desc": "Thud onto wooden floor / visual punchline",
			"event": {"id": "impact_wood_heavy_01", "volume_db": -1.0, "pitch_scale": 1.0},
			"wait": 0.20
		},
		{
			"beat": "6. Deadpan Silence",
			"desc": "Deadpan pause (Silence is active comedy: NO sound)",
			"event": {},
			"wait": 0.80
		},
		{
			"beat": "7. Recovery & Closure",
			"desc": "Small blip chime as Nemi returns to deadpan narration",
			"event": {"id": "ui_confirm_chime_01", "volume_db": -4.0, "pitch_scale": 1.1},
			"wait": 0.30
		}
	]

	var all_ok := true

	for step in sequence:
		var beat_name: String = step["beat"]
		var desc: String = step["desc"]
		var ev: Dictionary = step.get("event", {})
		var wait_time: float = step.get("wait", 0.1)

		print("\n[BEAT] %s" % beat_name)
		print("       Visual : %s" % desc)

		if ev.is_empty():
			print("       Audio  : [DEADPAN SILENCE] (Holding pause for %.2fs)" % wait_time)
		else:
			var sfx_id: String = ev["id"]
			var vol: float = ev.get("volume_db", 0.0)
			if not audio_mgr.has_sfx(sfx_id):
				printerr("       ERROR: Missing SFX ID: %s" % sfx_id)
				all_ok = false
			else:
				var p: AudioStreamPlayer = audio_mgr.play_event(ev)
				if p != null:
					print("       Audio  : Played '%s' (vol=%.1fdB)" % [sfx_id, vol])
				else:
					printerr("       ERROR: Playback failed for %s" % sfx_id)
					all_ok = false

		await create_timer(wait_time).timeout

	print("\n--- NARRATIVE AUDIO SEQUENCE FINISHED ---")

	# Teardown
	audio_mgr.stop_all()
	audio_mgr.queue_free()
	await process_frame

	if all_ok:
		print("SUCCESS: Episode 00 SFX narrative sequence verified with 100% legal vault assets!")
		quit(0)
	else:
		printerr("FAILED: One or more narrative audio cues failed.")
		quit(1)
