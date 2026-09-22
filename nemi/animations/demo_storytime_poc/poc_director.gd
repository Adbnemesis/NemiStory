extends StoryDirector

## Demonstration Director for Proof-of-Concept
## Implements the 13-second scripted animatic showing the complete storytelling grammar.

@onready var clapboard_prop: StoryProp = $"../Props/Clapboard"
@onready var stylus_prop: StoryProp = $"../Props/Stylus"
@onready var cat_prop: StoryProp = $"../Props/CatDrawing"

func _ready() -> void:
	# Hide props initially
	if clapboard_prop:
		clapboard_prop.visible = false
	if stylus_prop:
		stylus_prop.visible = false
	if cat_prop:
		cat_prop.visible = false
	if speech_bubble:
		speech_bubble.visible = false

	# Start animatic after node initialization
	call_deferred("_run_story")

func _run_story() -> void:
	print("--- STORYTIME ANIMATIC STARTED ---")

	# =========================================================================
	# BEAT 1: Static Held Illustration (1.8s hold)
	# =========================================================================
	character.set_pose("neutral")
	character.set_expression("neutral")
	subtitle("I've never animated anything in my life...")
	print("[Beat 1] Static hold in neutral pose (1.8s)")
	await hold(1.8)

	# =========================================================================
	# BEAT 2: Subtle Facial Micro-Animations & Slow Camera Push (1.6s)
	# =========================================================================
	print("[Beat 2] Micro-blink + eye glance + creeping push-in")
	await character.blink(0.08)
	character.glance(Vector2(12, 3), 0.6)
	character.set_expression("happy")
	camera.slow_push(1.15, 2.0)
	subtitle("...so I thought I'd start a storytime channel!")
	await hold(1.6)

	# =========================================================================
	# BEAT 3: Pose Replacement & Prop Pop-In (1.8s)
	# =========================================================================
	print("[Beat 3] Instant pose swap to gesturing + stylus pop-in + sparkle eyes")
	character.set_pose("gesturing")
	character.set_expression("sparkle")
	if stylus_prop:
		stylus_prop.position = character.position + Vector2(100, 30)
		stylus_prop.pop_in(true, 0.16)
	subtitle("I got this cool tablet stylus and everything.")
	await hold(1.8)

	# =========================================================================
	# BEAT 4: Small Physical Movement - Stepped 2-frame Bounce (1.8s)
	# =========================================================================
	print("[Beat 4] Stepped bounce on 2s with cat mouth blep")
	character.set_expression("blep")
	character.start_stepped_bounce(20.0, 6.0)
	subtitle("How hard could it honestly be?")
	await hold(1.5)
	character.stop_stepped_bounce()
	await hold(0.3)

	# =========================================================================
	# BEAT 5: Exaggerated Comedic Reaction & Camera Punch-In Snap (1.8s)
	# =========================================================================
	print("[Beat 5] Recoil pose + shocked face + camera punch-in snap + screenshake!")
	if stylus_prop:
		stylus_prop.pop_out(true)
	character.set_pose("recoil")
	character.set_expression("shocked")
	# Instant punch-in snap to 1.35x zoom!
	camera.punch_in(1.35, true, character.position + Vector2(0, -60))
	camera.shake(0.9, 3.5, 14.0)
	character.apply_shake(0.9, 4.0)
	if speech_bubble:
		speech_bubble.show_text("WAIT.", character.position + Vector2(-150, -180), 0.12)
	subtitle("Wait...")
	await hold(1.8)

	# =========================================================================
	# BEAT 6: Deadpan Realization & Pan (2.0s INTENTIONAL DEADPAN HOLD)
	# =========================================================================
	print("[Beat 6] Pan to props + crossed arms + deadpan void face (2.0s hold)")
	if speech_bubble:
		speech_bubble.hide_bubble(true)
	# Reveal props on table / side
	if clapboard_prop:
		clapboard_prop.position = Vector2(200, 470)
		clapboard_prop.pop_in(false)
	if cat_prop:
		cat_prop.position = Vector2(380, 310)
		cat_prop.pop_in(true, 0.15)

	camera.pan_to(Vector2(540, 360), 0.4)
	character.set_pose("crossed_arms")
	character.set_expression("deadpan")
	subtitle("...why are there forty-two layers of line art?")
	await hold(2.0)

	# =========================================================================
	# BEAT 7: Aftermath & Comedic Closing Beat (1.8s)
	# =========================================================================
	print("[Beat 7] Camera reset + aftermath bubble + slow blink")
	camera.reset_framing(0.3)
	if speech_bubble:
		speech_bubble.show_text("Nevermind.", character.position + Vector2(220, -170), 0.15)
	await character.blink(0.12)
	subtitle("Nevermind. I like cats.")
	await hold(1.8)

	# =========================================================================
	# BEAT 8: Story Complete
	# =========================================================================
	print("[Beat 8] Animatic complete! Hard cut.")
	clear_subtitle()
	complete_story()
	get_tree().quit()
