class_name Episode00Subtitles
extends RefCounted

## Episode 00 Subtitle Segmentation System
## Enforces the Hard Constraint: ABSOLUTELY NO MORE THAN 5 WORDS PER CARD.
## All 22 dialogue segments are broken down into natural 1 to 5 word chunks.

const SEGMENTS: Dictionary = {
	"001": [
		{"text": "Wait, wait, wait—", "duration": 1.05, "emotion": "normal"},
		{"text": "listen to me.", "duration": 0.95, "emotion": "normal"}
	],
	"002": [
		{"text": "Please stop scrolling", "duration": 1.30, "emotion": "normal"},
		{"text": "for literally two seconds.", "duration": 1.42, "emotion": "normal"}
	],
	"003": [
		{"text": "Look at this drawing", "duration": 1.05, "emotion": "normal"},
		{"text": "right here.", "duration": 1.03, "emotion": "normal"}
	],
	"004": [
		{"text": "It is supposed to be", "duration": 1.40, "emotion": "normal"},
		{"text": "a hand holding a teacup.", "duration": 1.80, "emotion": "normal"},
		{"text": "It looks like", "duration": 1.20, "emotion": "deadpan"},
		{"text": "an angry ginger root.", "duration": 2.00, "emotion": "deadpan"}
	],
	"005": [
		{"text": "Hi. I'm Nemi.", "duration": 1.05, "emotion": "smiling"},
		{"text": "I'm 24.", "duration": 0.95, "emotion": "smiling"}
	],
	"006": [
		{"text": "And apparently...", "duration": 1.40, "emotion": "normal"},
		{"text": "I am making", "duration": 1.32, "emotion": "smiling"},
		{"text": "animated YouTube videos now.", "duration": 2.00, "emotion": "smiling"}
	],
	"007": [
		{"text": "I've spent years", "duration": 1.30, "emotion": "normal"},
		{"text": "watching storytime creators", "duration": 1.40, "emotion": "normal"},
		{"text": "talk about their lives,", "duration": 1.40, "emotion": "normal"},
		{"text": "and recently my brain", "duration": 1.30, "emotion": "normal"},
		{"text": "had a terrible idea:", "duration": 1.40, "emotion": "normal"}
	],
	"008": [
		{"text": "How hard", "duration": 0.85, "emotion": "excited"},
		{"text": "could that possibly be?", "duration": 1.07, "emotion": "excited"}
	],
	"009": [
		{"text": "As it turns out:", "duration": 1.30, "emotion": "deadpan"},
		{"text": "extraordinarily hard.", "duration": 1.66, "emotion": "deadpan"}
	],
	"010": [
		{"text": "I spent four hours", "duration": 1.60, "emotion": "normal"},
		{"text": "yesterday inbetweening", "duration": 1.60, "emotion": "normal"},
		{"text": "an arm movement.", "duration": 1.80, "emotion": "normal"},
		{"text": "And by the end,", "duration": 1.70, "emotion": "deadpan"},
		{"text": "my character", "duration": 1.60, "emotion": "deadpan"},
		{"text": "wasn't walking.", "duration": 1.86, "emotion": "deadpan"}
	],
	"011": [
		{"text": "It looked like", "duration": 0.90, "emotion": "normal"},
		{"text": "they were slipping", "duration": 0.90, "emotion": "normal"},
		{"text": "on three", "duration": 0.68, "emotion": "normal"},
		{"text": "invisible banana peels.", "duration": 1.20, "emotion": "deadpan"}
	],
	"012": [
		{"text": "...In slow motion.", "duration": 1.12, "emotion": "deadpan"}
	],
	"013": [
		{"text": "I go to the gym.", "duration": 1.40, "emotion": "normal"},
		{"text": "Where I walk in", "duration": 1.10, "emotion": "excited"},
		{"text": "with the confidence", "duration": 1.10, "emotion": "excited"},
		{"text": "of an anime hero", "duration": 1.30, "emotion": "excited"},
		{"text": "in a tournament arc...", "duration": 1.30, "emotion": "excited"},
		{"text": "and walk out", "duration": 1.00, "emotion": "normal"},
		{"text": "two sets later", "duration": 1.00, "emotion": "deadpan"},
		{"text": "completely paralyzed", "duration": 0.82, "emotion": "deadpan"},
		{"text": "by leg day.", "duration": 0.90, "emotion": "deadpan"}
	],
	"014": [
		{"text": "And I sing.", "duration": 1.30, "emotion": "smiling"},
		{"text": "Mostly in my car", "duration": 1.70, "emotion": "smiling"},
		{"text": "with the windows", "duration": 1.60, "emotion": "smiling"},
		{"text": "rolled up.", "duration": 1.96, "emotion": "smiling"}
	],
	"015": [
		{"text": "...Except last Tuesday", "duration": 1.50, "emotion": "normal"},
		{"text": "when the window", "duration": 1.10, "emotion": "normal"},
		{"text": "was not rolled up,", "duration": 1.20, "emotion": "normal"},
		{"text": "and a mail carrier", "duration": 1.20, "emotion": "normal"},
		{"text": "heard me hit", "duration": 1.00, "emotion": "excited"},
		{"text": "a high G", "duration": 1.00, "emotion": "excited"},
		{"text": "with absolute vibrato.", "duration": 1.88, "emotion": "excited"}
	],
	"016": [
		{"text": "Like last week,", "duration": 1.30, "emotion": "normal"},
		{"text": "when I spent", "duration": 1.10, "emotion": "normal"},
		{"text": "six entire hours", "duration": 1.40, "emotion": "excited"},
		{"text": "researching the exact", "duration": 1.50, "emotion": "excited"},
		{"text": "structural tension", "duration": 1.30, "emotion": "excited"},
		{"text": "of Victorian iron bridges...", "duration": 2.84, "emotion": "excited"}
	],
	"017": [
		{"text": "...just to draw", "duration": 1.30, "emotion": "deadpan"},
		{"text": "one single background", "duration": 1.30, "emotion": "deadpan"},
		{"text": "that is on screen", "duration": 1.30, "emotion": "deadpan"},
		{"text": "for half a second.", "duration": 1.54, "emotion": "deadpan"}
	],
	"018": [
		{"text": "Half.", "duration": 0.65, "emotion": "deadpan"},
		{"text": "A.", "duration": 0.65, "emotion": "deadpan"},
		{"text": "Second.", "duration": 0.78, "emotion": "deadpan"}
	],
	"019": [
		{"text": "...My posture was ruined.", "duration": 2.00, "emotion": "deadpan"},
		{"text": "My tea was ice cold.", "duration": 2.10, "emotion": "deadpan"},
		{"text": "But the bridge", "duration": 1.20, "emotion": "smiling"},
		{"text": "was architecturally sound.", "duration": 1.90, "emotion": "smiling"}
	],
	"020": [
		{"text": "I don't really know", "duration": 1.30, "emotion": "smiling"},
		{"text": "where this channel", "duration": 1.10, "emotion": "smiling"},
		{"text": "is going yet,", "duration": 1.10, "emotion": "smiling"},
		{"text": "but I want to", "duration": 1.00, "emotion": "smiling"},
		{"text": "have fun with it,", "duration": 1.10, "emotion": "smiling"},
		{"text": "get better at animation,", "duration": 1.40, "emotion": "smiling"},
		{"text": "and hopefully meet", "duration": 0.96, "emotion": "smiling"},
		{"text": "some cool people.", "duration": 1.00, "emotion": "smiling"}
	],
	"021": [
		{"text": "So, if any of that", "duration": 1.30, "emotion": "smiling"},
		{"text": "sounds like something", "duration": 1.20, "emotion": "smiling"},
		{"text": "you'd enjoy...", "duration": 1.18, "emotion": "smiling"},
		{"text": "I'd love it", "duration": 1.10, "emotion": "smiling"},
		{"text": "if you stayed.", "duration": 1.30, "emotion": "smiling"}
	],
	"022": [
		{"text": "Thank you for watching", "duration": 1.10, "emotion": "smiling"},
		{"text": "my very first video.", "duration": 1.10, "emotion": "smiling"},
		{"text": "See you", "duration": 0.44, "emotion": "smiling"},
		{"text": "in the next one.", "duration": 0.44, "emotion": "smiling"},
		{"text": "Bye!", "duration": 0.60, "emotion": "excited"}
	]
}

## Validates that every subtitle card adheres to the HARD CONSTRAINT: <= 5 visible words.
## Automatically called during production setup.
static func validate_all_segments() -> bool:
	var all_valid := true
	for seg_id in SEGMENTS.keys():
		var chunk_list: Array = SEGMENTS[seg_id]
		for c_idx in range(chunk_list.size()):
			var chunk: Dictionary = chunk_list[c_idx]
			var raw_text: String = chunk.get("text", "").strip_edges()
			var words := raw_text.split(" ", false)
			if words.size() > 5:
				push_error("SUBTITLE VALIDATION FAILURE: Segment %s, Chunk %d has %d words (>5): '%s'" % [seg_id, c_idx, words.size(), raw_text])
				all_valid = false
	if all_valid:
		print("✓ Subtitle Validation Passed: All %d segments strictly <= 5 words per card." % SEGMENTS.size())
	return all_valid

## Returns chunks for a specific segment ID
static func get_chunks(segment_id: String) -> Array:
	if segment_id == "001":
		validate_all_segments()
	if SEGMENTS.has(segment_id):
		return SEGMENTS[segment_id]
	return []

## Fire-and-forget subtitle driver. Creates a lightweight helper node that
## swaps subtitle text and triggers lip-sync at the correct frame offsets.
## No await loops — the beat script's wait_seconds() is the sole frame-clock owner.
static func play_segment(subtitle_label: Label, nemi: Node2D, segment_id: String, beat_node: Node) -> void:
	var chunks: Array = get_chunks(segment_id)
	if chunks.is_empty():
		return
	
	var driver := _SubtitleDriver.new()
	driver.subtitle_label = subtitle_label
	driver.nemi = nemi
	driver.name = "SubtitleDriver_%s" % segment_id
	
	# Pre-compute frame triggers: [{frame_offset, text, duration, emotion}]
	var frame_offset: int = 0
	for chunk in chunks:
		driver.schedule.append({
			"frame": frame_offset,
			"text": chunk.text,
			"duration": chunk.duration,
			"emotion": chunk.get("emotion", "normal")
		})
		frame_offset += int(round(chunk.duration * 60.0))
	driver.total_frames = frame_offset
	
	beat_node.add_child(driver)


## Lightweight inner node that drives subtitle text changes via _process().
## Self-destructs after all chunks have played.
class _SubtitleDriver extends Node:
	var subtitle_label: Label
	var nemi: Node2D
	var schedule: Array = []  # [{frame, text, duration, emotion}]
	var total_frames: int = 0
	var _elapsed_frames: int = 0
	var _next_idx: int = 0
	
	func _ready() -> void:
		# Apply first chunk immediately if it starts at frame 0
		if schedule.size() > 0 and schedule[0].frame == 0:
			_apply_chunk(schedule[0])
			_next_idx = 1
	
	func _process(_delta: float) -> void:
		_elapsed_frames += 1
		
		# Check if we've reached the next chunk's trigger frame
		while _next_idx < schedule.size() and _elapsed_frames >= schedule[_next_idx].frame:
			_apply_chunk(schedule[_next_idx])
			_next_idx += 1
		
		# Self-destruct after all chunks have played out
		if _elapsed_frames >= total_frames:
			if subtitle_label:
				subtitle_label.text = ""
			queue_free()
	
	func _apply_chunk(chunk: Dictionary) -> void:
		if subtitle_label:
			subtitle_label.text = chunk.text
		if nemi and nemi.has_method("speak"):
			nemi.speak(chunk.text, chunk.duration, chunk.emotion)
