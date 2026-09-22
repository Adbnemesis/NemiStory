class_name Episode02Subtitles
extends RefCounted

## Episode 02 Subtitle Segmentation System: "How I Met My Partner"
## Enforces the Hard Constraint: ABSOLUTELY NO MORE THAN 5 WORDS PER CARD.
## All 22 dialogue segments are broken down into natural 1 to 5 word chunks
## with frame-accurate durations synchronized to the Qwen3-TTS Sohee master audio.

const SEGMENTS: Dictionary = {
	"001": [
		{"text": "Okay...", "duration": 1.20, "emotion": "whisper"},
		{"text": "I have a secret.", "duration": 2.24, "emotion": "secret"}
	],
	"002": [
		{"text": "Do not tell anyone.", "duration": 1.28, "emotion": "shh"}
	],
	"003": [
		{"text": "I have a partner.", "duration": 0.96, "emotion": "proud"}
	],
	"004": [
		{"text": "The person I met...", "duration": 1.20, "emotion": "normal"},
		{"text": "is ADB.", "duration": 0.96, "emotion": "punchy"}
	],
	"005": [
		{"text": "We actually met", "duration": 1.20, "emotion": "normal"},
		{"text": "during college,", "duration": 1.10, "emotion": "normal"},
		{"text": "right in the middle", "duration": 1.28, "emotion": "normal"},
		{"text": "of the COVID lockdown.", "duration": 1.30, "emotion": "normal"}
	],
	"006": [
		{"text": "So basically...", "duration": 2.10, "emotion": "normal"},
		{"text": "everything happened online.", "duration": 2.78, "emotion": "comedic"}
	],
	"007": [
		{"text": "And for two to three", "duration": 1.50, "emotion": "normal"},
		{"text": "months?", "duration": 0.90, "emotion": "normal"},
		{"text": "We just texted.", "duration": 1.32, "emotion": "normal"},
		{"text": "Constantly.", "duration": 1.40, "emotion": "punchy"}
	],
	"008": [
		{"text": "Messages all day...", "duration": 1.10, "emotion": "laughing"},
		{"text": "and random memes", "duration": 0.90, "emotion": "laughing"},
		{"text": "until three", "duration": 0.52, "emotion": "normal"},
		{"text": "in the morning.", "duration": 0.60, "emotion": "punchy"}
	],
	"009": [
		{"text": "At first it was", "duration": 0.90, "emotion": "normal"},
		{"text": "just casual chatting.", "duration": 0.94, "emotion": "normal"}
	],
	"010": [
		{"text": "Then we realized...", "duration": 1.60, "emotion": "warm"},
		{"text": "our brains are wired", "duration": 1.50, "emotion": "warm"},
		{"text": "in the exact same", "duration": 1.52, "emotion": "warm"},
		{"text": "chaotic way.", "duration": 1.70, "emotion": "smiling"}
	],
	"011": [
		{"text": "And then...", "duration": 1.80, "emotion": "suspense"},
		{"text": "one day,", "duration": 1.50, "emotion": "suspense"},
		{"text": "we got drunk.", "duration": 2.62, "emotion": "drunk"}
	],
	"012": [
		{"text": "...And things happened.", "duration": 1.92, "emotion": "deadpan"}
	],
	"013": [
		{"text": "Look, ADB is", "duration": 1.60, "emotion": "gushing"},
		{"text": "really cute.", "duration": 1.80, "emotion": "gushing"},
		{"text": "Like,", "duration": 1.20, "emotion": "gushing"},
		{"text": "ridiculously cute.", "duration": 2.76, "emotion": "fond"}
	],
	"014": [
		{"text": "And ADB is", "duration": 1.60, "emotion": "normal"},
		{"text": "completely obsessed", "duration": 1.50, "emotion": "excited"},
		{"text": "with anime.", "duration": 1.78, "emotion": "anime"}
	],
	"015": [
		{"text": "Which means we can", "duration": 1.00, "emotion": "excited"},
		{"text": "talk about storylines", "duration": 1.10, "emotion": "excited"},
		{"text": "for hours.", "duration": 1.02, "emotion": "excited"}
	],
	"016": [
		{"text": "Now... does ADB", "duration": 1.40, "emotion": "skeptical"},
		{"text": "irritate me sometimes?", "duration": 1.94, "emotion": "annoyed"},
		{"text": "Absolutely.", "duration": 1.70, "emotion": "deadpan"}
	],
	"017": [
		{"text": "Every single day.", "duration": 1.52, "emotion": "deadpan"}
	],
	"018": [
		{"text": "But I also irritate ADB", "duration": 2.40, "emotion": "smug"},
		{"text": "every single day.", "duration": 1.80, "emotion": "smug"},
		{"text": "So the balance", "duration": 2.20, "emotion": "balance"},
		{"text": "is completely even.", "duration": 2.80, "emotion": "punchy"}
	],
	"019": [
		{"text": "Whenever things get chaotic,", "duration": 1.70, "emotion": "warm"},
		{"text": "we're always backing", "duration": 0.92, "emotion": "warm"},
		{"text": "each other up.", "duration": 0.90, "emotion": "warm"}
	],
	"020": [
		{"text": "No matter what happens,", "duration": 1.10, "emotion": "warm"},
		{"text": "we help each other", "duration": 0.70, "emotion": "warm"},
		{"text": "through it.", "duration": 0.60, "emotion": "sincere"}
	],
	"021": [
		{"text": "So yeah.", "duration": 1.60, "emotion": "soft"},
		{"text": "My partner...", "duration": 2.12, "emotion": "warm"},
		{"text": "and my absolute", "duration": 1.80, "emotion": "warm"},
		{"text": "best friend.", "duration": 2.00, "emotion": "affectionate"}
	],
	"022": [
		{"text": "Okay...", "duration": 1.30, "emotion": "secret"},
		{"text": "now you know.", "duration": 1.50, "emotion": "secret"},
		{"text": "Keep it between us.", "duration": 1.76, "emotion": "secret"}
	]
}

## Subtitle playback engine
static func play_segment(label: Label, nemi: Node2D, seg_id: String, host_node: Node) -> void:
	if not SEGMENTS.has(seg_id):
		push_warning("Subtitle segment %s not found!" % seg_id)
		return
		
	var cards: Array = SEGMENTS[seg_id]
	host_node.call_deferred("_run_subtitle_cards", label, nemi, cards)
