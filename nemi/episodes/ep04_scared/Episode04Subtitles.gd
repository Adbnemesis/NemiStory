class_name Episode04Subtitles
extends RefCounted

## Episode 04 Subtitle Segmentation System: "Guys, I'm Scared."
## Enforces the Hard Constraint: ABSOLUTELY NO MORE THAN 5 WORDS PER CARD.
## All 9 dialogue segments are broken down into natural 1 to 5 word cards
## with frame-accurate durations synchronized to the Qwen3-TTS Sohee master audio.

const SEGMENTS: Dictionary = {
	"seg01_terrified": [
		{"text": "Okay, so...", "duration": 1.80, "emotion": "candid"},
		{"text": "I don't know", "duration": 1.40, "emotion": "normal"},
		{"text": "how to say this", "duration": 1.60, "emotion": "normal"},
		{"text": "without sounding dramatic,", "duration": 2.10, "emotion": "self_aware"},
		{"text": "but... I'm kind of terrified.", "duration": 2.62, "emotion": "whisper"}
	],
	"seg02_not_horror": [
		{"text": "Not like horror movie terrified.", "duration": 2.50, "emotion": "smug"},
		{"text": "Just... what if", "duration": 1.80, "emotion": "vulnerable"},
		{"text": "this whole YouTube thing", "duration": 1.40, "emotion": "normal"},
		{"text": "doesn't work?", "duration": 1.18, "emotion": "confessional"}
	],
	"seg03_love_making": [
		{"text": "Like, I love making", "duration": 1.80, "emotion": "affectionate"},
		{"text": "these animations.", "duration": 1.40, "emotion": "affectionate"},
		{"text": "I spend days obsessing", "duration": 1.80, "emotion": "hyperfocus"},
		{"text": "over every little frame...", "duration": 1.88, "emotion": "hyperfocus"}
	],
	"seg04_refresh_2am": [
		{"text": "...and then I refresh", "duration": 1.80, "emotion": "normal"},
		{"text": "at two AM,", "duration": 1.40, "emotion": "normal"},
		{"text": "and it's seven views.", "duration": 2.20, "emotion": "deadpan"},
		{"text": "Half of them", "duration": 1.40, "emotion": "sheepish"},
		{"text": "from my phone.", "duration": 1.84, "emotion": "deadpan"}
	],
	"seg05_what_if": [
		{"text": "And my brain immediately goes:", "duration": 2.00, "emotion": "panic"},
		{"text": "what if nobody watches,", "duration": 2.00, "emotion": "doubt"},
		{"text": "and I just", "duration": 1.40, "emotion": "vulnerable"},
		{"text": "never get better?", "duration": 2.04, "emotion": "sad"}
	],
	"seg06_other_animators": [
		{"text": "I see all these", "duration": 1.40, "emotion": "normal"},
		{"text": "insane animators online,", "duration": 2.00, "emotion": "shock"},
		{"text": "and then I look", "duration": 1.30, "emotion": "normal"},
		{"text": "at my timeline,", "duration": 1.10, "emotion": "deadpan"},
		{"text": "and it's just pure chaos.", "duration": 1.32, "emotion": "exasperated"}
	],
	"seg07_because_i_care": [
		{"text": "And the only reason", "duration": 1.60, "emotion": "reflective"},
		{"text": "it's scary", "duration": 1.20, "emotion": "vulnerable"},
		{"text": "is because I actually care.", "duration": 2.00, "emotion": "heartfelt"},
		{"text": "Like, a lot.", "duration": 1.60, "emotion": "intimate"}
	],
	"seg08_overthinking": [
		{"text": "Look, I'm probably", "duration": 1.50, "emotion": "casual"},
		{"text": "just overthinking again.", "duration": 1.80, "emotion": "small_smile"},
		{"text": "But I'm still gonna", "duration": 1.60, "emotion": "determined"},
		{"text": "make the next video.", "duration": 1.82, "emotion": "determined"}
	],
	"seg09_signoff": [
		{"text": "So yeah,", "duration": 2.20, "emotion": "friendly"},
		{"text": "wish me luck.", "duration": 2.40, "emotion": "warm"},
		{"text": "Okay, bye!", "duration": 5.00, "emotion": "happy"}
	]
}

static func play_segment(label: Label, character: Node2D, seg_id: String, caller: Node) -> void:
	if not SEGMENTS.has(seg_id):
		push_warning("Segment %s not found in Episode04Subtitles!" % seg_id)
		return
	var cards: Array = SEGMENTS[seg_id]
	(func(): await caller._run_subtitle_cards(label, character, cards)).call()
