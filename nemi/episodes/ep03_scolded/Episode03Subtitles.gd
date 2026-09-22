class_name Episode03Subtitles
extends RefCounted

## Episode 03 Subtitle Segmentation System: "My Mom Scolded Me"
## Enforces the Hard Constraint: ABSOLUTELY NO MORE THAN 5 WORDS PER CARD.
## All 23 dialogue segments are broken down into natural 1 to 5 word chunks
## with frame-accurate durations synchronized to the Qwen3-TTS Sohee master audio.

const SEGMENTS: Dictionary = {
	"001": [
		{"text": "My mom has scolded", "duration": 1.80, "emotion": "normal"},
		{"text": "me many times", "duration": 1.80, "emotion": "normal"},
		{"text": "in my life.", "duration": 2.24, "emotion": "reflective"}
	],
	"002": [
		{"text": "Most of them", "duration": 1.00, "emotion": "normal"},
		{"text": "were completely unfair.", "duration": 1.16, "emotion": "defensive"}
	],
	"003": [
		{"text": "...Except this one.", "duration": 1.80, "emotion": "whisper"},
		{"text": "This one was", "duration": 1.10, "emotion": "confessional"},
		{"text": "entirely deserved.", "duration": 1.42, "emotion": "deadpan"}
	],
	"004": [
		{"text": "Mom left the house", "duration": 1.30, "emotion": "normal"},
		{"text": "around ten in the morning", "duration": 1.40, "emotion": "normal"},
		{"text": "with one simple rule.", "duration": 1.38, "emotion": "punchy"}
	],
	"005": [
		{"text": "Take the chicken out", "duration": 1.20, "emotion": "normal"},
		{"text": "of the freezer", "duration": 0.80, "emotion": "normal"},
		{"text": "at two PM", "duration": 0.90, "emotion": "emphasis"},
		{"text": "to defrost for dinner.", "duration": 0.94, "emotion": "normal"}
	],
	"006": [
		{"text": "Now, two PM", "duration": 1.80, "emotion": "normal"},
		{"text": "was four hours away.", "duration": 2.00, "emotion": "normal"},
		{"text": "That is basically", "duration": 1.20, "emotion": "smug"},
		{"text": "infinite time.", "duration": 1.24, "emotion": "smug"}
	],
	"007": [
		{"text": "I told myself:", "duration": 1.20, "emotion": "normal"},
		{"text": "I have full control", "duration": 1.40, "emotion": "confident"},
		{"text": "over this situation.", "duration": 1.40, "emotion": "heroic"}
	],
	"008": [
		{"text": "At one fifty-five,", "duration": 1.20, "emotion": "normal"},
		{"text": "I sat at my tablet", "duration": 1.40, "emotion": "normal"},
		{"text": "to fix just one", "duration": 0.90, "emotion": "hyperfocus"},
		{"text": "single animation line.", "duration": 0.90, "emotion": "hyperfocus"}
	],
	"009": [
		{"text": "I blinked twice...", "duration": 1.70, "emotion": "shock"},
		{"text": "and suddenly", "duration": 0.90, "emotion": "panic"},
		{"text": "it was five forty-five.", "duration": 1.32, "emotion": "horror"}
	],
	"010": [
		{"text": "And that was", "duration": 1.10, "emotion": "suspense"},
		{"text": "the exact moment", "duration": 1.20, "emotion": "suspense"},
		{"text": "I heard gravel crunch", "duration": 1.20, "emotion": "shock"},
		{"text": "in the driveway.", "duration": 1.22, "emotion": "shock"}
	],
	"011": [
		{"text": "Followed by the", "duration": 0.90, "emotion": "dread"},
		{"text": "car door slamming shut.", "duration": 1.18, "emotion": "dread"}
	],
	"012": [
		{"text": "I sprinted", "duration": 1.00, "emotion": "panic"},
		{"text": "to the freezer.", "duration": 1.20, "emotion": "panic"},
		{"text": "The chicken was", "duration": 0.90, "emotion": "realization"},
		{"text": "not defrosting.", "duration": 0.98, "emotion": "deadpan"}
	],
	"013": [
		{"text": "It was an", "duration": 0.80, "emotion": "deadpan"},
		{"text": "indestructible block", "duration": 1.60, "emotion": "deadpan"},
		{"text": "of Arctic permafrost.", "duration": 1.68, "emotion": "deadpan"}
	],
	"014": [
		{"text": "You could have built", "duration": 1.10, "emotion": "sarcastic"},
		{"text": "a house out of this poultry.", "duration": 1.22, "emotion": "deadpan"}
	],
	"015": [
		{"text": "I initiated", "duration": 1.40, "emotion": "formal"},
		{"text": "emergency defrost protocol.", "duration": 2.20, "emotion": "dramatic"},
		{"text": "Hot water bath:", "duration": 1.80, "emotion": "normal"},
		{"text": "complete failure.", "duration": 1.96, "emotion": "deadpan"}
	],
	"016": [
		{"text": "Microwave defrost", "duration": 1.50, "emotion": "annoyed"},
		{"text": "turned one corner", "duration": 1.20, "emotion": "annoyed"},
		{"text": "into rubber", "duration": 1.20, "emotion": "disgust"},
		{"text": "while center stayed ice.", "duration": 1.94, "emotion": "exasperated"}
	],
	"017": [
		{"text": "So naturally...", "duration": 1.20, "emotion": "conspiratorial"},
		{"text": "I grabbed my hairdryer", "duration": 1.40, "emotion": "determined"},
		{"text": "and put it on", "duration": 0.80, "emotion": "extreme"},
		{"text": "maximum heat.", "duration": 0.92, "emotion": "blaster"}
	],
	"018": [
		{"text": "Right as the hairdryer", "duration": 1.60, "emotion": "chaos"},
		{"text": "hit maximum blast...", "duration": 1.80, "emotion": "chaos"},
		{"text": "the kitchen door", "duration": 1.20, "emotion": "freeze"},
		{"text": "swung open.", "duration": 1.32, "emotion": "terror"}
	],
	"019": [
		{"text": "My mom stood there.", "duration": 1.20, "emotion": "deadpan"},
		{"text": "Just looking at me.", "duration": 1.20, "emotion": "deadpan"}
	],
	"020": [
		{"text": "Then she said:", "duration": 1.10, "emotion": "deadpan"},
		{"text": "'You have a", "duration": 1.10, "emotion": "scold"},
		{"text": "college degree,", "duration": 1.20, "emotion": "scold"},
		{"text": "and you are", "duration": 1.10, "emotion": "scold"},
		{"text": "blow-drying raw meat.'", "duration": 1.34, "emotion": "devastating"}
	],
	"021": [
		{"text": "I didn't even try", "duration": 1.50, "emotion": "surrender"},
		{"text": "to defend myself.", "duration": 1.60, "emotion": "surrender"},
		{"text": "There was zero", "duration": 1.20, "emotion": "deadpan"},
		{"text": "scientific rebuttal.", "duration": 1.30, "emotion": "deadpan"}
	],
	"022": [
		{"text": "We ate cold cereal", "duration": 1.40, "emotion": "deadpan"},
		{"text": "for dinner", "duration": 0.60, "emotion": "deadpan"},
		{"text": "in complete silence.", "duration": 0.96, "emotion": "deadpan"}
	],
	"023": [
		{"text": "And I have", "duration": 0.80, "emotion": "normal"},
		{"text": "officially been banned", "duration": 1.00, "emotion": "solemn"},
		{"text": "from the freezer.", "duration": 0.92, "emotion": "punchy"}
	]
}

## Subtitle playback engine
static func play_segment(label: Label, nemi: Node2D, seg_id: String, host_node: Node) -> void:
	if not SEGMENTS.has(seg_id):
		push_warning("Subtitle segment %s not found!" % seg_id)
		return
		
	var cards: Array = SEGMENTS[seg_id]
	host_node.call_deferred("_run_subtitle_cards", label, nemi, cards)
