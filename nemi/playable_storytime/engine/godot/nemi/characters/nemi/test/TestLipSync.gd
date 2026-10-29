extends Node2D

## Diagnostic Test for Nemi Live Lip-Sync & Viseme System
## Tests 4 distinct vocal/emotional delivery modes:
## 1. Casual sentence ("Hi, I'm Nemi and I'm testing the new speech visemes.")
## 2. Excited sentence ("Look at how fast and dynamic this illustration is!")
## 3. Deadpan sentence ("As it turns out... extraordinarily hard.")
## 4. Shocked sentence (Speech locks into shock mouth)

@onready var nemi = $Nemi
@onready var label = $UI/TestLabel

func _ready() -> void:
	call_deferred("_run_lip_sync_test")

func _run_lip_sync_test() -> void:
	print("=== STARTING NEMI LIP-SYNC DIAGNOSTIC TEST ===")
	
	# 1. CASUAL SPEECH
	label.text = "[CASUAL] Hi, I'm Nemi and I'm testing the new speech visemes."
	nemi.set_expression("talking")
	await nemi.speak("Hi, I'm Nemi and I'm testing the new speech visemes.", 2.5, "normal")
	await _wait(0.5)
	
	# 2. EXCITED SPEECH
	label.text = "[EXCITED] Look at how fast and dynamic this illustration is!"
	nemi.set_expression("happy")
	await nemi.speak("Look at how fast and dynamic this illustration is!", 2.2, "excited")
	await _wait(0.5)
	
	# 3. DEADPAN SPEECH
	label.text = "[DEADPAN] As it turns out... extraordinarily hard."
	nemi.set_expression("skeptical")
	await nemi.speak("As it turns out... extraordinarily hard.", 2.5, "deadpan")
	await _wait(0.5)
	
	# 4. SHOCKED SPEECH
	label.text = "[SHOCKED] (Gasp / frozen shock)"
	nemi.set_expression("shocked")
	await nemi.speak("Gasp! What is that?!", 1.8, "shocked")
	await _wait(0.5)
	
	label.text = "LIP-SYNC DIAGNOSTIC TEST COMPLETED SUCCESSFULLY."
	print("=== LIP-SYNC DIAGNOSTIC TEST COMPLETED ===")

func _wait(seconds: float) -> void:
	var frames: int = int(round(seconds * 60.0))
	for f in range(frames):
		await get_tree().process_frame
