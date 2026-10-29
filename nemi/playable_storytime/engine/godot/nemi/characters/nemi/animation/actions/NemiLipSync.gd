class_name NemiLipSync
extends RefCounted

## Dedicated Lightweight Live Lip-Sync Subsystem for NEMI
## Implements natural, illustrative speech mouth animation that coexists with emotional acting.
## Enforces:
## - Syllabic articulation synchronized to spoken English phrases (~4-5 phonemes/sec)
## - Specific, tailored viseme sequences for punchy dialogue beats (e.g. "absolutely not")
## - Restrained deadpan modulation (subtle syllable switches without frozen lockups)
## - Automatic return to base/rest shape during pauses

var character: Node2D
var face: Node2D

var _active_speech_token: int = 0
var is_speaking: bool = false

func _init(p_character: Node2D) -> void:
	character = p_character
	if character:
		face = character.get_node_or_null("Skeleton2D/RootBone/TorsoBone/NeckBone/HeadBone/FaceVisual")

## Synchronizes illustrative mouth shapes to a spoken dialogue phrase and duration
func speak_phrase(text: String, duration: float, emotion: String = "normal") -> void:
	if not face or duration <= 0.0:
		return
		
	_active_speech_token += 1
	var token: int = _active_speech_token
	is_speaking = true
	
	var clean_text: String = text.strip_edges().to_lower()
	var clean_emotion: String = emotion.to_lower()
	
	# Special Emotional Override: Shocked gasp
	if clean_emotion == "shocked" or clean_emotion == "shock":
		face.set_mouth_shape("shock")
		if character and character.get_tree():
			await _wait_tree(duration, token)
		if token == _active_speech_token:
			is_speaking = false
		return

	# Build illustrative syllable-aware viseme sequence
	var viseme_sequence: Array[String] = _build_viseme_sequence(clean_text, clean_emotion)
	var step_count: int = viseme_sequence.size()
	var step_duration: float = duration / float(step_count)
	
	for i in range(step_count):
		if token != _active_speech_token:
			return
		var shape: String = viseme_sequence[i]
		face.set_mouth_shape(shape)
		await _wait_tree(step_duration, token)
		
	if token == _active_speech_token:
		# Return to rest / base emotional mouth
		if clean_emotion == "smiling":
			face.set_mouth_shape("smile")
		elif clean_emotion == "deadpan":
			face.set_mouth_shape("neutral")
		elif clean_emotion == "frown":
			face.set_mouth_shape("frown")
		elif clean_emotion == "wavy":
			face.set_mouth_shape("wavy")
		else:
			face.set_mouth_shape("rest")
		is_speaking = false

## Stops speech immediately and rests mouth
func stop_speech(rest_shape: String = "rest") -> void:
	_active_speech_token += 1
	is_speaking = false
	if face:
		face.set_mouth_shape(rest_shape)

## Counts syllables in a phrase using vowel cluster analysis
func _count_syllables(text: String) -> int:
	var cleaned := text.to_lower().strip_edges()
	var words := cleaned.split(" ", false)
	var total_syl := 0
	for word in words:
		var clean_w := ""
		for i in range(word.length()):
			var c := word[i]
			if (c >= 'a' and c <= 'z'):
				clean_w += c
		if clean_w.is_empty():
			continue
		var count := 0
		var in_vowel := false
		for i in range(clean_w.length()):
			var is_v := clean_w[i] in ["a", "e", "i", "o", "u", "y"]
			if is_v and not in_vowel:
				count += 1
			in_vowel = is_v
		# Trailing silent 'e'
		if clean_w.ends_with("e") and not clean_w.ends_with("le") and count > 1:
			count -= 1
		total_syl += maxi(1, count)
	return maxi(1, total_syl)

## Builds an illustrative sequence of mouth shapes matching natural syllabic flow
func _build_viseme_sequence(text: String, emotion: String) -> Array[String]:
	# Specific high-impact phrase mappings
	if text.contains("absolutely"):
		# "ab" (ae) -> "so" (o_u) -> "lute" (small_open) -> "ly" (wide) -> "not" (ae) -> close (small_open)
		return ["ae", "o_u", "small_open", "wide", "ae", "small_open"]
	
	var syl_count: int = _count_syllables(text)
	var target_visemes: int = clampi(syl_count, 2, 8)
	var result: Array[String] = []
	
	var has_o_u: bool = ("o" in text or "u" in text or "w" in text or "ow" in text)
	var has_a_e: bool = ("a" in text or "e" in text or "ah" in text or "ai" in text)
	
	if emotion == "smiling":
		for i in range(target_visemes):
			if i % 2 == 0:
				result.append("wide")
			else:
				result.append("small_open")
	elif emotion == "punchy" or emotion == "excited" or emotion == "shout":
		for i in range(target_visemes):
			match i % 4:
				0: result.append("ae")
				1: result.append("o_u" if has_o_u else "small_open")
				2: result.append("wide")
				3: result.append("small_open")
	elif emotion == "deadpan":
		# Controlled subtle deadpan articulation: rapid low-amplitude switches
		for i in range(target_visemes):
			if i % 2 == 0:
				result.append("small_open")
			else:
				result.append("neutral")
	else: # "normal"
		for i in range(target_visemes):
			match i % 4:
				0: result.append("small_open")
				1: result.append("ae" if has_a_e else "small_open")
				2: result.append("o_u" if has_o_u else "closed")
				3: result.append("small_open")
				
	# Ensure last shape closes naturally before rest
	if result.size() > 0:
		result[result.size() - 1] = "small_open"
		
	return result

func _wait_tree(duration: float, token: int) -> void:
	if not character or not is_instance_valid(character) or not character.is_inside_tree():
		return
	await character.get_tree().create_timer(duration).timeout
	if token != _active_speech_token:
		return
