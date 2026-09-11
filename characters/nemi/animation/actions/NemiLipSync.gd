class_name NemiLipSync
extends RefCounted

## Dedicated Lightweight Live Lip-Sync Subsystem for NEMI
## Implements natural, illustrative speech mouth animation that coexists with emotional acting.
## Enforces:
## - 2-5 meaningful mouth changes per short phrase (not robotic phoneme flapping)
## - Automatic return to REST during pauses
## - Emotional modulation (deadpan: minimal movement; shock: locked open; smiling: speaking while smiling)

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
	
	# Special Emotional Overrides
	if clean_emotion == "shocked" or clean_emotion == "shock":
		face.set_mouth_shape("shock")
		if character and character.get_tree():
			await _wait_tree(duration, token)
		if token == _active_speech_token:
			is_speaking = false
		return
		
	if clean_emotion == "deadpan":
		# Minimal, subtle deadpan movement: tiny twitch between neutral and small_open
		var cycles: int = maxi(1, int(round(duration / 0.7)))
		var slice: float = duration / float(cycles * 2)
		for c in range(cycles):
			if token != _active_speech_token: return
			face.set_mouth_shape("small_open")
			await _wait_tree(slice * 0.4, token)
			if token != _active_speech_token: return
			face.set_mouth_shape("neutral")
			await _wait_tree(slice * 1.6, token)
		if token == _active_speech_token:
			face.set_mouth_shape("neutral")
			is_speaking = false
		return

	# Standard / Excited / Smiling Speech
	# Generate 2 to 5 meaningful illustrative mouth shapes based on phrase content
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

## Builds an illustrative sequence of 2-5 mouth shapes matching natural speech flow
func _build_viseme_sequence(text: String, emotion: String) -> Array[String]:
	var result: Array[String] = []
	
	# Determine base count of visemes for this phrase (2-5)
	var word_count: int = text.split(" ", false).size()
	var target_visemes: int = clampi(word_count + 1, 2, 5)
	
	# Extract primary vowel presence in text
	var has_o_u: bool = ("o" in text or "u" in text or "w" in text or "ow" in text)
	var has_a_e: bool = ("a" in text or "e" in text or "ah" in text or "ai" in text)
	
	if emotion == "smiling":
		for i in range(target_visemes):
			if i % 2 == 0:
				result.append("wide")
			else:
				result.append("small_open")
	elif emotion == "excited":
		for i in range(target_visemes):
			match i % 3:
				0: result.append("ae")
				1: result.append("wide")
				2: result.append("o_u" if has_o_u else "small_open")
	else: # "normal"
		for i in range(target_visemes):
			match i % 4:
				0: result.append("small_open")
				1: result.append("ae" if has_a_e else "small_open")
				2: result.append("o_u" if has_o_u else "closed")
				3: result.append("small_open")
				
	# Ensure last shape closes naturally or tapers to small_open before rest
	if result.size() > 0:
		result[result.size() - 1] = "small_open"
		
	return result

func _wait_tree(duration: float, token: int) -> void:
	if not character or not is_instance_valid(character) or not character.is_inside_tree():
		return
	var frames: int = maxi(1, int(round(duration * 60.0)))
	var counter := _FrameCounter.new()
	counter.target_frames = frames
	character.add_child(counter)
	await counter.tree_exited
	# Token check after wait completes
	if token != _active_speech_token:
		return

## Lightweight helper node: counts _process frames then self-destructs.
## Does NOT consume frame_post_draw signals — the beat's wait_seconds() 
## remains the sole frame-clock owner.
class _FrameCounter extends Node:
	var target_frames: int = 0
	var _count: int = 0
	func _process(_delta: float) -> void:
		_count += 1
		if _count >= target_frames:
			queue_free()

