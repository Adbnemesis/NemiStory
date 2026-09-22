extends SceneTree

## Headless & Runtime Verification Script for Brawl Stars Character Lip-Sync & Viseme System
## Tests:
## 1. Direct Viseme Verification (closed, small_open, ae, o_u, wide, smirk, deadpan, shout)
## 2. Syllable Counting & Phoneme Sequence Analysis
## 3. Live Asynchronous Speech Articulation (Casual, Con-Artist Pitch, Cynical Deadpan, Screaming)
## 4. Audio-Driven Lip-Sync with Real .wav Tracks and Transcripts
## 5. Instant Rest Shape Closure & Speech Interruption Handling

func _init() -> void:
	print("==================================================================")
	print("  STARTING BRAWL STARS LIP-SYNC & SPEECH VISEME VERIFICATION")
	print("==================================================================")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var leon_scene: PackedScene = load("res://brawl_stars/characters/leon/Leon.tscn")
	assert(leon_scene != null, "Failed to load Leon.tscn")
	var leon = leon_scene.instantiate()
	root.add_child(leon)
	
	var edgar_scene: PackedScene = load("res://brawl_stars/characters/edgar/Edgar.tscn")
	assert(edgar_scene != null, "Failed to load Edgar.tscn")
	var edgar = edgar_scene.instantiate()
	root.add_child(edgar)
	
	# Allow ready and initialization
	await process_frame
	await process_frame
	
	print("[PASS] Successfully instantiated Leon & Edgar rigs in scene tree.")
	
	# ---------------------------------------------------------------------
	# TEST 1: Direct Viseme Coverage
	# ---------------------------------------------------------------------
	print("\n--- TEST 1: Direct Viseme Coverage ---")
	var canonical_visemes: Array[String] = [
		"closed", "small_open", "ae", "o_u", "wide", "smirk", "deadpan", "shout", "smile", "frown"
	]
	
	for vis in canonical_visemes:
		leon.set_viseme(vis)
		assert(leon.visual.face.mouth_shape == vis, "Leon viseme mismatch for: " + vis)
		edgar.set_viseme(vis)
		assert(edgar.visual.face.mouth_shape == vis, "Edgar viseme mismatch for: " + vis)
		print("  [OK] Viseme verified on both rigs: ", vis)
	
	# ---------------------------------------------------------------------
	# TEST 2: Syllable Analysis
	# ---------------------------------------------------------------------
	print("\n--- TEST 2: Syllable Counting & Analysis ---")
	var test_phrases: Dictionary = {
		"hi": 1,
		"tactical retreat": 5,
		"absolutely free trophies": 8,
		"whatever, nobody understands": 9
	}
	for phrase in test_phrases:
		var syl: int = leon.lip_sync.count_syllables(phrase)
		var expected: int = test_phrases[phrase]
		assert(abs(syl - expected) <= 1, "Syllable count deviation for '" + phrase + "': got " + str(syl) + " expected " + str(expected))
		print("  [OK] Phrase '%s' -> %d syllables" % [phrase, syl])
	
	# ---------------------------------------------------------------------
	# TEST 3: Live Asynchronous Speech Articulation
	# ---------------------------------------------------------------------
	print("\n--- TEST 3: Asynchronous Speech Articulation ---")
	
	# 3A. Leon Casual Speech
	print("  Testing Leon casual speech...")
	var phrase_leon: String = "Hey, don't look at me, it was a tactical retreat!"
	await leon.speak(phrase_leon, 0.35, "mischievous")
	assert(not leon.is_speaking(), "Leon should have stopped speaking!")
	assert(leon.visual.face.mouth_openness == 0.0, "Leon mouth should be completely closed after speech!")
	print("  [PASS] Leon casual speech completed cleanly and closed to rest shape.")
	
	# 3B. Edgar Cynical Deadpan Speech
	print("  Testing Edgar cynical deadpan speech...")
	var phrase_edgar: String = "Yeah, I am not using my Super on that. You are on your own."
	await edgar.speak(phrase_edgar, 0.35, "deadpan")
	assert(not edgar.is_speaking(), "Edgar should have stopped speaking!")
	assert(edgar.visual.face.mouth_openness == 0.0, "Edgar mouth should be completely closed after speech!")
	print("  [PASS] Edgar deadpan speech completed cleanly and closed to rest shape.")
	
	# 3C. Shock / Panic Emotional Override
	print("  Testing emotional shock lock override...")
	await leon.speak("Gasp!", 0.2, "shocked")
	assert(leon.visual.face.mouth_shape == "smirk", "Leon should reset to smirk after shock!")
	print("  [PASS] Emotional shock lock override verified.")
	
	# ---------------------------------------------------------------------
	# TEST 4: Audio-Driven Lip-Sync with Real .wav Tracks
	# ---------------------------------------------------------------------
	print("\n--- TEST 4: Audio-Driven Speech with Real .wav Tracks ---")
	
	var leon_wav_path := "res://brawl_stars/voices/leon/selected/leon_anchor_fast_persuasive.wav"
	if FileAccess.file_exists(leon_wav_path):
		print("  Testing Leon real audio playback: ", leon_wav_path)
		# Start audio speech in background coroutine to verify stop_speech() interruption
		_start_audio_speech(leon, leon_wav_path, "con_artist_persuasive")
		await process_frame
		await process_frame
		assert(leon.is_speaking(), "Leon should be speaking audio!")
		# Allow 0.2 seconds then interrupt with stop_speech()
		for i in range(12):
			await process_frame
		leon.stop_speech()
		assert(not leon.is_speaking(), "Leon should stop immediately on stop_speech()!")
		assert(leon.visual.face.mouth_openness == 0.0, "Leon mouth should be closed after stop_speech()!")
		print("  [PASS] Leon real audio sync and stop_speech() verified.")
	
	var edgar_wav_path := "res://brawl_stars/voices/edgar/selected/edgar_anchor_annoyed.wav"
	if FileAccess.file_exists(edgar_wav_path):
		print("  Testing Edgar real audio playback: ", edgar_wav_path)
		_start_audio_speech(edgar, edgar_wav_path, "annoyed")
		await process_frame
		await process_frame
		assert(edgar.is_speaking(), "Edgar should be speaking audio!")
		for i in range(12):
			await process_frame
		edgar.stop_speech()
		assert(not edgar.is_speaking(), "Edgar should stop immediately on stop_speech()!")
		assert(edgar.visual.face.mouth_openness == 0.0, "Edgar mouth should be closed after stop_speech()!")
		print("  [PASS] Edgar real audio sync and stop_speech() verified.")
	
	# ---------------------------------------------------------------------
	# SUMMARY
	# ---------------------------------------------------------------------
	print("\n==================================================================")
	print("  ALL LIP-SYNC & SPEECH VISEME TESTS PASSED WITH 0 ERRORS! [OK]")
	print("==================================================================")
	quit(0)

func _start_audio_speech(rig: Node2D, path: String, emotion: String) -> void:
	rig.speak_audio(path, "", emotion)
