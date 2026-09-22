class_name Episode01Subtitles
extends RefCounted

## Episode 01 Subtitle Segmentation System: "I Used To Have A Cat"
## Enforces the Hard Constraint: ABSOLUTELY NO MORE THAN 5 WORDS PER CARD.
## All 19 dialogue segments are broken down into natural 1 to 5 word chunks
## with frame-accurate durations synchronized to the Qwen3-TTS Sohee master audio.

const SEGMENTS: Dictionary = {
	"001": [
		{"text": "Wait.", "duration": 0.75, "emotion": "normal"},
		{"text": "I used to have", "duration": 1.00, "emotion": "normal"},
		{"text": "a cat.", "duration": 0.97, "emotion": "normal"}
	],
	"002": [
		{"text": "Okay—not like that.", "duration": 1.10, "emotion": "normal"},
		{"text": "I didn't buy one.", "duration": 0.90, "emotion": "normal"}
	],
	"003": [
		{"text": "I was sixteen", "duration": 1.60, "emotion": "normal"},
		{"text": "when I found her,", "duration": 1.50, "emotion": "normal"},
		{"text": "abandoned behind", "duration": 1.50, "emotion": "normal"},
		{"text": "a row of mailboxes.", "duration": 1.64, "emotion": "normal"}
	],
	"004": [
		{"text": "She was tiny.", "duration": 1.80, "emotion": "normal"},
		{"text": "Like, fit-in-my-pocket", "duration": 1.40, "emotion": "smiling"},
		{"text": "tiny.", "duration": 1.36, "emotion": "smiling"}
	],
	"005": [
		{"text": "Just sitting inside", "duration": 1.10, "emotion": "normal"},
		{"text": "a damp cardboard box,", "duration": 1.14, "emotion": "normal"},
		{"text": "shivering.", "duration": 0.80, "emotion": "normal"}
	],
	"006": [
		{"text": "So naturally,", "duration": 1.00, "emotion": "smiling"},
		{"text": "I brought her", "duration": 0.90, "emotion": "smiling"},
		{"text": "a little bowl", "duration": 0.85, "emotion": "smiling"},
		{"text": "of warm milk.", "duration": 0.85, "emotion": "smiling"}
	],
	"007": [
		{"text": "At first,", "duration": 1.00, "emotion": "normal"},
		{"text": "she hissed", "duration": 0.94, "emotion": "normal"},
		{"text": "at my shoelaces.", "duration": 1.10, "emotion": "normal"}
	],
	"008": [
		{"text": "But ten minutes later?", "duration": 1.60, "emotion": "smiling"},
		{"text": "Purring like", "duration": 1.10, "emotion": "smiling"},
		{"text": "a tiny lawnmower.", "duration": 1.30, "emotion": "smiling"}
	],
	"009": [
		{"text": "I wanted to keep her", "duration": 1.90, "emotion": "normal"},
		{"text": "so badly.", "duration": 1.86, "emotion": "normal"}
	],
	"010": [
		{"text": "Then my parents", "duration": 1.30, "emotion": "normal"},
		{"text": "took one look", "duration": 1.20, "emotion": "normal"},
		{"text": "and said:", "duration": 0.86, "emotion": "normal"},
		{"text": "absolutely not.", "duration": 1.20, "emotion": "punchy"}
	],
	"011": [
		{"text": "I couldn't just", "duration": 0.90, "emotion": "normal"},
		{"text": "leave her outside.", "duration": 0.94, "emotion": "normal"}
	],
	"012": [
		{"text": "So I convinced", "duration": 1.10, "emotion": "normal"},
		{"text": "the corner shopkeeper", "duration": 1.20, "emotion": "normal"},
		{"text": "to let her stay", "duration": 0.94, "emotion": "normal"},
		{"text": "behind the counter.", "duration": 1.00, "emotion": "normal"}
	],
	"013": [
		{"text": "And for four days,", "duration": 2.40, "emotion": "smiling"},
		{"text": "she basically ran", "duration": 2.40, "emotion": "smiling"},
		{"text": "the register.", "duration": 2.88, "emotion": "smiling"}
	],
	"014": [
		{"text": "Meanwhile, I was texting", "duration": 1.70, "emotion": "normal"},
		{"text": "everyone I knew,", "duration": 1.54, "emotion": "normal"},
		{"text": "putting up little drawings...", "duration": 1.80, "emotion": "normal"}
	],
	"015": [
		{"text": "and asking every", "duration": 1.20, "emotion": "normal"},
		{"text": "single customer", "duration": 1.20, "emotion": "normal"},
		{"text": "who walked into", "duration": 1.10, "emotion": "normal"},
		{"text": "the shop.", "duration": 1.30, "emotion": "normal"}
	],
	"016": [
		{"text": "And finally...", "duration": 1.40, "emotion": "smiling"},
		{"text": "this really lovely family", "duration": 1.50, "emotion": "smiling"},
		{"text": "came in and", "duration": 1.00, "emotion": "smiling"},
		{"text": "adopted her", "duration": 0.90, "emotion": "smiling"},
		{"text": "on the spot.", "duration": 0.88, "emotion": "smiling"}
	],
	"017": [
		{"text": "Her name was Neeko.", "duration": 1.12, "emotion": "smiling"}
	],
	"018": [
		{"text": "I still think about", "duration": 1.10, "emotion": "normal"},
		{"text": "her sometimes.", "duration": 1.06, "emotion": "smiling"}
	],
	"019": [
		{"text": "I'm just really glad", "duration": 1.60, "emotion": "smiling"},
		{"text": "I got to help.", "duration": 1.60, "emotion": "smiling"}
	]
}

## Validates that every chunk in every segment has <= 5 words
static func validate_all() -> bool:
	var passed := true
	for seg_id in SEGMENTS.keys():
		var chunks: Array = SEGMENTS[seg_id]
		for i in range(chunks.size()):
			var chunk: Dictionary = chunks[i]
			var words := (chunk["text"] as String).strip_edges().split(" ", false)
			if words.size() > 5:
				print("FATAL SUBTITLE ERROR: Segment %s chunk %d exceeds 5 words (%d words): '%s'" % [seg_id, i, words.size(), chunk["text"]])
				passed = false
	if passed:
		print("✓ Subtitle Validation Passed: All 19 segments strictly <= 5 words per card.")
	return passed

## Helper to display a segment's subtitle chunks sequentially and drive lip sync
static func play_segment(label: Label, nemi_node: Node, seg_id: String, caller_node: Node) -> void:
	if not SEGMENTS.has(seg_id):
		return
	var chunks: Array = SEGMENTS[seg_id]
	for chunk in chunks:
		if is_instance_valid(label):
			label.text = chunk["text"]
		if is_instance_valid(nemi_node):
			var emo: String = chunk.get("emotion", "normal")
			var dur: float = chunk.get("duration", 1.0)
			var txt: String = chunk.get("text", "")
			if nemi_node.has_method("speak"):
				nemi_node.speak(txt, dur, emo)
			elif nemi_node.has_method("speak_syllables"):
				nemi_node.speak_syllables(dur, 13.0)
			elif nemi_node.has_method("play_speech"):
				nemi_node.play_speech(dur, emo)
		if is_instance_valid(caller_node):
			if caller_node.has_method("wait_seconds"):
				await caller_node.wait_seconds(chunk["duration"])
			else:
				await caller_node.get_tree().create_timer(chunk["duration"]).timeout
	if is_instance_valid(label):
		label.text = ""
	if is_instance_valid(nemi_node) and nemi_node.has_method("stop_speech"):
		nemi_node.stop_speech()
