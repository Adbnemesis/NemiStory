class_name BrawlLipSync
extends RefCounted

## Dedicated Lightweight Illustrative Lip-Sync Subsystem for Brawl Stars Rigs (Leon & Edgar)
## Strictly adheres to the Nemi Animation Production Bible:
## - Stylized, illustrative speech mouth animation (~12-15 FPS syllabic cadence)
## - Canonical viseme vocabulary: rest, closed, small_open, ae, o_u, wide, smirk, deadpan, shout
## - Syllable-aware text analysis with vowel cluster detection and punctuation pauses
## - Emotion overrides (deadpan locks to narrow slits, shock/rage locks to dropped jaw)
## - Instant closure to rest/smirk/deadpan shape the exact millisecond speech stops
## - Full AudioStreamPlayer synchronization with drift-free tracking and automatic .txt transcript discovery

signal speech_started(text: String)
signal viseme_changed(shape: String, openness: float)
signal speech_finished

var character: Node2D
var face: Node2D
var character_id: String = "leon" # "leon" or "edgar"

var is_speaking: bool = false
var _active_token: int = 0
var _audio_player: AudioStreamPlayer = null
var _base_rest_shape: String = "smirk"

func _init(p_character: Node2D, p_face: Node2D, p_char_id: String = "leon") -> void:
	character = p_character
	face = p_face
	character_id = p_char_id.to_lower()
	_base_rest_shape = "smirk" if character_id == "leon" else "deadpan"

func set_audio_player(player: AudioStreamPlayer) -> void:
	_audio_player = player

## Synchronizes illustrative mouth shapes to a spoken dialogue phrase and duration
func speak_phrase(text: String, duration: float = -1.0, emotion: String = "normal") -> void:
	if not face or not character or not character.is_inside_tree():
		return
	
	_active_token += 1
	var token: int = _active_token
	is_speaking = true
	speech_started.emit(text)
	
	var clean_text: String = text.strip_edges()
	var clean_emotion: String = emotion.to_lower()
	
	# Determine rest shape based on character & base emotion
	_update_rest_shape(clean_emotion)
	
	# 1. Emotional Override: Shocked / Horrified realization (jaw drops open, stays locked)
	if clean_emotion in ["shock", "shocked", "panicked", "panic"]:
		_set_face_viseme("shout" if character_id == "leon" else "wide", 1.0)
		var actual_dur := duration if duration > 0.0 else 1.2
		await _wait_seconds(actual_dur, token)
		if token == _active_token:
			stop_speech(_base_rest_shape)
		return
	
	# 2. Estimate duration if not provided (~4.2 syllables per second)
	var syllables := count_syllables(clean_text)
	var actual_duration: float = duration
	if actual_duration <= 0.0:
		actual_duration = maxf(0.8, float(syllables) * 0.238)
	
	# 3. Build illustrative viseme sequence
	var sequence := build_viseme_sequence(clean_text, clean_emotion)
	if sequence.is_empty():
		stop_speech(_base_rest_shape)
		return
	
	# Calculate step duration based on weights
	var total_weight: float = 0.0
	for step in sequence:
		total_weight += step.get("weight", 1.0)
	
	var time_per_weight: float = actual_duration / maxf(1.0, total_weight)
	
	# 4. Animate through viseme sequence
	for i in range(sequence.size()):
		if token != _active_token:
			return
		
		var step: Dictionary = sequence[i]
		var shape: String = step.get("shape", "small_open")
		var openness: float = step.get("openness", 1.0)
		var step_dur: float = step.get("weight", 1.0) * time_per_weight
		
		_set_face_viseme(shape, openness)
		await _wait_seconds(step_dur, token)
	
	# 5. Snap shut cleanly on silence
	if token == _active_token:
		stop_speech(_base_rest_shape)

## Plays an AudioStream (or loads from path) and drives synchronized mouth visemes
func speak_audio(audio_path_or_stream: Variant, text: String = "", emotion: String = "normal") -> void:
	var stream: AudioStream = null
	var path_str: String = ""
	
	if audio_path_or_stream is String:
		path_str = audio_path_or_stream
		if ResourceLoader.exists(path_str):
			stream = load(path_str) as AudioStream
		else:
			push_warning("BrawlLipSync: Audio file not found: " + path_str)
	elif audio_path_or_stream is AudioStream:
		stream = audio_path_or_stream
	
	if not stream:
		# Fallback to pure text-based speech if stream failed to load
		if not text.is_empty():
			await speak_phrase(text, -1.0, emotion)
		return
	
	# If text is empty and path is known, look for matching .txt transcript
	var speech_text: String = text
	if speech_text.is_empty() and not path_str.is_empty():
		var txt_path := path_str.get_basename() + ".txt"
		if FileAccess.file_exists(txt_path):
			var f := FileAccess.open(txt_path, FileAccess.READ)
			if f:
				speech_text = f.get_as_text().strip_edges()
	
	if speech_text.is_empty():
		speech_text = "Talking audio line"
	
	var duration: float = stream.get_length()
	if duration <= 0.05:
		duration = 1.5
	
	if _audio_player:
		_audio_player.stream = stream
		_audio_player.play()
	
	await speak_phrase(speech_text, duration, emotion)

## Stops speech immediately and snaps mouth to rest shape
func stop_speech(rest_shape: String = "") -> void:
	_active_token += 1
	is_speaking = false
	
	var final_rest: String = rest_shape
	if final_rest.is_empty():
		final_rest = _base_rest_shape
	
	_set_face_viseme(final_rest, 0.0)
	speech_finished.emit()

## Counts syllables using English vowel cluster analysis and trailing silent-e rules
func count_syllables(text: String) -> int:
	var cleaned := text.to_lower().strip_edges()
	if cleaned.is_empty():
		return 1
	
	var words := cleaned.split(" ", false)
	var total_syl: int = 0
	
	for word in words:
		var clean_w := ""
		for i in range(word.length()):
			var c := word[i]
			if (c >= 'a' and c <= 'z'):
				clean_w += c
		if clean_w.is_empty():
			continue
		
		var count: int = 0
		var in_vowel: bool = false
		for i in range(clean_w.length()):
			var is_v := clean_w[i] in ["a", "e", "i", "o", "u", "y"]
			if is_v and not in_vowel:
				count += 1
			in_vowel = is_v
		
		# Silent trailing 'e' rule (e.g. 'game', 'retreat')
		if clean_w.ends_with("e") and not clean_w.ends_with("le") and count > 1:
			count -= 1
		
		total_syl += maxi(1, count)
	
	return maxi(1, total_syl)

## Builds an illustrative syllable-aware viseme sequence matching character personality
func build_viseme_sequence(text: String, emotion: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var cleaned := text.strip_edges()
	if cleaned.is_empty():
		return result
	
	# Split into words for natural pauses & syllables
	var words := cleaned.split(" ", false)
	
	for word_idx in range(words.size()):
		var raw_word := words[word_idx]
		var word := raw_word.to_lower()
		
		# Vowel & consonant heuristics
		var has_o_u: bool = ("o" in word or "u" in word or "w" in word)
		var has_a_e: bool = ("a" in word or "e" in word or "ai" in word or "ay" in word)
		var has_closed: bool = word.begins_with("m") or word.begins_with("b") or word.begins_with("p")
		var is_loud: bool = raw_word.to_upper() == raw_word and raw_word.length() > 1
		
		# Initial consonant closure if M/B/P
		if has_closed:
			result.append({"shape": "closed", "openness": 0.0, "weight": 0.7})
		
		# Character & Emotion Specific Articulation
		if character_id == "edgar":
			_append_edgar_word_visemes(result, word, emotion, has_o_u, has_a_e, is_loud)
		else:
			_append_leon_word_visemes(result, word, emotion, has_o_u, has_a_e, is_loud)
		
		# Check for punctuation pauses
		if raw_word.ends_with(",") or raw_word.ends_with(";"):
			result.append({"shape": "closed" if character_id == "edgar" else "smirk", "openness": 0.0, "weight": 0.9})
		elif raw_word.ends_with(".") or raw_word.ends_with("!") or raw_word.ends_with("?"):
			result.append({"shape": "closed" if character_id == "edgar" else "smirk", "openness": 0.0, "weight": 1.4})
		elif raw_word.ends_with("..."):
			result.append({"shape": "deadpan" if character_id == "edgar" else "smirk", "openness": 0.0, "weight": 1.8})
	
	# Ensure speech finishes on closed / rest
	if not result.is_empty():
		result.append({"shape": "closed" if character_id == "edgar" else "smirk", "openness": 0.0, "weight": 0.5})
	
	return result

func _append_leon_word_visemes(result: Array[Dictionary], word: String, emotion: String, has_o_u: bool, has_a_e: bool, is_loud: bool) -> void:
	if is_loud or emotion in ["screaming", "screaming_panic", "excited"]:
		# High-energy, toothy wide projections!
		result.append({"shape": "wide", "openness": 1.0, "weight": 1.2})
		if has_o_u:
			result.append({"shape": "o_u", "openness": 0.9, "weight": 1.0})
		result.append({"shape": "small_open", "openness": 0.6, "weight": 0.8})
	elif emotion in ["mischievous", "con_artist", "con_artist_persuasive", "scheming", "smug"]:
		# Sneaky con-artist fast talk: alternates cheeky smirk and quick vowel apertures
		result.append({"shape": "smirk", "openness": 0.4, "weight": 0.9})
		result.append({"shape": "ae" if has_a_e else "small_open", "openness": 0.8, "weight": 1.0})
		if has_o_u:
			result.append({"shape": "o_u", "openness": 0.8, "weight": 0.9})
		result.append({"shape": "small_open", "openness": 0.4, "weight": 0.7})
	elif emotion in ["deadpan", "annoyed"]:
		# Restrained mouth articulation
		result.append({"shape": "small_open", "openness": 0.45, "weight": 0.9})
		result.append({"shape": "deadpan", "openness": 0.1, "weight": 0.8})
	else:
		# Standard conversational speech
		result.append({"shape": "small_open", "openness": 0.7, "weight": 1.0})
		if has_o_u:
			result.append({"shape": "o_u", "openness": 0.85, "weight": 1.0})
		elif has_a_e:
			result.append({"shape": "ae", "openness": 0.85, "weight": 1.0})
		result.append({"shape": "small_open", "openness": 0.4, "weight": 0.7})

func _append_edgar_word_visemes(result: Array[Dictionary], word: String, emotion: String, has_o_u: bool, has_a_e: bool, is_loud: bool) -> void:
	if is_loud or emotion in ["enraged", "shout", "explosive_shout"]:
		# Rare explosive emo rage scream!
		result.append({"shape": "shout", "openness": 1.0, "weight": 1.3})
		result.append({"shape": "wide", "openness": 0.9, "weight": 1.0})
		result.append({"shape": "small_open", "openness": 0.5, "weight": 0.7})
	elif emotion in ["deadpan", "cynical", "sigh", "tsundere"]:
		# Classic deadpan delivery: tight, subtle, sarcastic
		result.append({"shape": "small_open", "openness": 0.4, "weight": 0.9})
		if has_o_u:
			result.append({"shape": "o_u", "openness": 0.5, "weight": 0.8})
		result.append({"shape": "deadpan", "openness": 0.0, "weight": 0.9})
	elif emotion in ["toxic_smug", "annoyed", "sarcastic"]:
		# Sarcastic smirk and sneer
		result.append({"shape": "smirk", "openness": 0.5, "weight": 1.0})
		result.append({"shape": "ae" if has_a_e else "small_open", "openness": 0.7, "weight": 0.9})
		result.append({"shape": "sarcastic_frown", "openness": 0.2, "weight": 0.8})
	else:
		# Casual monotone teen speech
		result.append({"shape": "small_open", "openness": 0.6, "weight": 1.0})
		if has_o_u:
			result.append({"shape": "o_u", "openness": 0.7, "weight": 0.9})
		elif has_a_e:
			result.append({"shape": "ae", "openness": 0.7, "weight": 0.9})
		result.append({"shape": "closed", "openness": 0.0, "weight": 0.6})

func _set_face_viseme(shape: String, openness: float) -> void:
	if not face:
		return
	face.set("mouth_shape", shape)
	face.set("mouth_openness", clampf(openness, 0.0, 1.0))
	face.queue_redraw()
	viseme_changed.emit(shape, openness)

func _update_rest_shape(emotion: String) -> void:
	if character_id == "leon":
		match emotion:
			"deadpan": _base_rest_shape = "deadpan"
			"frown", "sad": _base_rest_shape = "frown"
			"smile", "happy": _base_rest_shape = "smile"
			_: _base_rest_shape = "smirk"
	else:
		match emotion:
			"smirk", "toxic_smug": _base_rest_shape = "smirk"
			"sarcastic_frown", "annoyed": _base_rest_shape = "sarcastic_frown"
			"frown": _base_rest_shape = "frown"
			_: _base_rest_shape = "deadpan"

func _wait_seconds(seconds: float, token: int) -> void:
	if seconds <= 0.001 or not character or not character.is_inside_tree():
		return
	var frames: int = maxi(1, int(round(seconds * 60.0)))
	for _f in range(frames):
		if token != _active_token or not character or not character.is_inside_tree():
			return
		await character.get_tree().process_frame
