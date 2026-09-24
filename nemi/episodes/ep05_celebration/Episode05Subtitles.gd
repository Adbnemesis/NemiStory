class_name Episode05Subtitles
extends RefCounted

## Episode 05 Subtitle Segmentation System: "WHAT IS GOING ON WITH YOUTUBE?"
## Voice: Sohee (EP00 Voice Parity, 92.45s runtime)
## AUTHORITATIVE: Rebuilt from actual audio waveform energy.
## Enforces Hard Constraint: ABSOLUTELY NO MORE THAN 5 WORDS PER CARD.
## All cards appear on spoken syllables and clear on pauses.

const SEGMENTS: Dictionary = {
	"seg01_freeze_hook": [
		{"text": "Guys... what is", "duration": 0.77, "emotion": "confused"},
		{"text": "going on with YouTube", "duration": 1.39, "emotion": "confused"},
		{"text": "right now?", "duration": 0.69, "emotion": "candid"}
	],
	"seg02_sat_at_desk": [
		{"text": "I sat down", "duration": 0.86, "emotion": "normal"},
		{"text": "at my desk today,", "duration": 1.40, "emotion": "normal"},
		{"text": "opened my analytics...", "duration": 1.83, "emotion": "candid"},
		{"text": "and I just froze.", "duration": 1.40, "emotion": "shock"}
	],
	"seg03_last_week_seven_views": [
		{"text": "Because literally last week,", "duration": 2.20, "emotion": "candid"},
		{"text": "I was refreshing", "duration": 1.28, "emotion": "hyperfocus"},
		{"text": "at two in the morning,", "duration": 1.56, "emotion": "hyperfocus"},
		{"text": "staring at seven views...", "duration": 1.74, "emotion": "deadpan"}
	],
	"seg04_from_my_own_phone": [
		{"text": "And honestly?", "duration": 0.89, "emotion": "sheepish"},
		{"text": "Three of those were", "duration": 1.18, "emotion": "sheepish"},
		{"text": "from my own phone.", "duration": 1.03, "emotion": "sheepish"}
	],
	"seg05_opened_dashboard": [
		{"text": "So I opened the dashboard", "duration": 1.51, "emotion": "normal"},
		{"text": "today, expecting nothing...", "duration": 1.51, "emotion": "candid"}
	],
	"seg06_counter_climbing": [
		{"text": "And the subscriber counter", "duration": 2.11, "emotion": "normal"},
		{"text": "was just climbing.", "duration": 1.38, "emotion": "suspense"},
		{"text": "One...", "duration": 0.37, "emotion": "suspense"},
		{"text": "seventeen...", "duration": 0.83, "emotion": "suspense"},
		{"text": "eighty-four...", "duration": 1.01, "emotion": "suspense"},
		{"text": "five hundred...", "duration": 1.01, "emotion": "suspense"}
	],
	"seg07_nine_ninety_nine": [
		{"text": "Nine hundred ninety-nine...", "duration": 1.60, "emotion": "shock"}
	],
	"seg08_one_thousand": [
		{"text": "And then...", "duration": 1.09, "emotion": "suspense"},
		{"text": "one thousand.", "duration": 1.71, "emotion": "shock"}
	],
	"seg09_wait_what_one_thousand": [
		{"text": "Wait, what?!", "duration": 1.52, "emotion": "shock"},
		{"text": "One thousand", "duration": 1.67, "emotion": "excited"},
		{"text": "subscribers?!", "duration": 1.98, "emotion": "excited"}
	],
	"seg10_are_you_serious": [
		{"text": "Are you guys actually", "duration": 0.99, "emotion": "excited"},
		{"text": "serious right now?!", "duration": 0.94, "emotion": "excited"}
	],
	"seg11_process_that": [
		{"text": "I don't even know", "duration": 1.36, "emotion": "vulnerable"},
		{"text": "how to process that.", "duration": 1.56, "emotion": "vulnerable"}
	],
	"seg12_living_human_beings": [
		{"text": "That's not just a", "duration": 1.45, "emotion": "earnest"},
		{"text": "digital number on screen.", "duration": 2.17, "emotion": "earnest"},
		{"text": "That is one thousand", "duration": 1.76, "emotion": "heartfelt"},
		{"text": "actual, living human beings.", "duration": 2.38, "emotion": "heartfelt"}
	],
	"seg13_checked_comments": [
		{"text": "And then I checked", "duration": 0.86, "emotion": "casual"},
		{"text": "the comments,", "duration": 0.63, "emotion": "casual"},
		{"text": "and there are around", "duration": 0.97, "emotion": "shock"},
		{"text": "one thousand comments", "duration": 1.09, "emotion": "shock"},
		{"text": "across the videos.", "duration": 0.86, "emotion": "shock"}
	],
	"seg14_thousand_comments_shout": [
		{"text": "A thousand comments?!", "duration": 2.33, "emotion": "exasperated"},
		{"text": "Guys... what?!", "duration": 1.22, "emotion": "shock"}
	],
	"seg15_reading_promise": [
		{"text": "I promise I read them,", "duration": 1.65, "emotion": "heartfelt"},
		{"text": "even if I can't", "duration": 1.16, "emotion": "apologetic"},
		{"text": "reply to everyone.", "duration": 1.45, "emotion": "apologetic"},
		{"text": "They make me smile", "duration": 1.45, "emotion": "warm"},
		{"text": "like an idiot.", "duration": 1.06, "emotion": "small_smile"}
	],
	"seg16_instagram_surprise": [
		{"text": "And then Instagram hit", "duration": 1.10, "emotion": "excited"},
		{"text": "two hundred and fifty", "duration": 1.04, "emotion": "excited"},
		{"text": "followers too!", "duration": 0.75, "emotion": "excited"}
	],
	"seg17_drawing_by_hand": [
		{"text": "When you sit alone", "duration": 1.32, "emotion": "reflective"},
		{"text": "drawing every single frame", "duration": 2.03, "emotion": "reflective"},
		{"text": "by hand,", "duration": 0.53, "emotion": "reflective"},
		{"text": "this kind of support", "duration": 1.50, "emotion": "heartfelt"},
		{"text": "means everything to me.", "duration": 1.67, "emotion": "tender"}
	],
	"seg18_warm_signoff": [
		{"text": "So from the bottom", "duration": 1.78, "emotion": "heartfelt"},
		{"text": "of my heart,", "duration": 1.07, "emotion": "heartfelt"},
		{"text": "thank you so much.", "duration": 1.67, "emotion": "warm"},
		{"text": "New video soon.", "duration": 1.43, "emotion": "determined"},
		{"text": "Bye!", "duration": 0.48, "emotion": "happy"}
	]
}

static func play_segment(label: Label, character: Node2D, seg_id: String, caller: Node) -> void:
	if not SEGMENTS.has(seg_id):
		push_warning("Segment %s not found in Episode05Subtitles!" % seg_id)
		return
	var cards: Array = SEGMENTS[seg_id]
	(func(): await caller._run_subtitle_cards(label, character, cards)).call()
