class_name NemiReactions
extends RefCounted

## Master Reaction Compositions for NEMI (V2 Temporal Rework)
## Implements the 10 Authoritative Acting Tests (Tests A through J)
## Calibrated specifically against the reference videos:
## - Over 85% stillness holds
## - Eyes lead head (attention establishes focus first)
## - Delayed realization & psychological progression
## - Sharp contrast between static holds and snappy physical action

var director: Node # Reference to NemiActingDirector

func _init(p_director: Node) -> void:
	director = p_director

# =========================================================================
# THE 10 AUTHORITATIVE ACTING TESTS (TESTS A THROUGH J)
# =========================================================================

## TEST A — ATTENTION
## Sequence: Nemi neutral -> hold 0.6s -> eyes look right -> hold 0.15s -> head follows -> hold 0.5s -> reset.
## Movement is subtle, eyes clearly establish attention first.
func test_a_attention() -> void:
	# 1. Neutral baseline + intentional hold
	await director.reset()
	await director.hold(0.60)
	
	# 2. Eyes look right first (0.00s)
	await director.eyes.look("right", "fast")
	
	# 3. Brief visual processing pause (0.15s)
	await director.hold(0.15)
	
	# 4. Head follows eyes (subtle 14° turn with secondary hair follow-through)
	await director.head.turn(14.0, "normal", false, true)
	
	# 5. Sustained attention hold (0.50s)
	await director.hold(0.50)
	
	# 6. Reset to neutral
	await director.reset()

## TEST B — CONVERSATIONAL
## Sequence: Nemi neutral -> small eye movement -> eyebrow raise -> tiny head tilt -> small smile -> hold -> return.
## No unnecessary body animation; purely micro-acting and facial communication.
func test_b_conversational() -> void:
	await director.reset()
	await director.hold(0.40)
	
	# 1. Small eye movement
	await director.eyes.look(Vector2(0.55, -0.2), "fast")
	await director.hold(0.15)
	
	# 2. Eyebrow raise (inquisitive / friendly)
	director.face.set_eyebrows("both", 6.0, 0.12, 0.14)
	
	# 3. Tiny head tilt (3.5°)
	await director.head.tilt(3.5, 0.18)
	
	# 4. Small warm smile
	director.face.set_mouth("smile")
	
	# 5. Meaningful hold
	await director.hold(0.70)
	
	# 6. Return smoothly to neutral
	await director.eyes.look(Vector2.ZERO, "fast")
	await director.head.tilt(0.0, 0.16)
	director.face.reset(0.16)
	await director.hold(0.40)

## TEST C — CONFUSION
## Sequence: Neutral -> attention -> pause -> asymmetric eyebrow movement -> slight head tilt -> hold -> tiny second eye movement.
## The character appears to genuinely THINK.
func test_c_confusion() -> void:
	await director.reset()
	await director.hold(0.35)
	
	# 1. Attention shift (eyes look up-left)
	await director.eyes.look("up_left", "fast")
	
	# 2. Processing pause
	await director.hold(0.25)
	
	# 3. Asymmetric eyebrow movement (left raised, right furrowed)
	director.face.set_eyebrows("left", 8.0, 0.25, 0.15)
	director.face.set_eyebrows("right", -3.0, 0.10, 0.15)
	
	# 4. Slight head tilt (4.5°)
	await director.head.tilt(4.5, 0.18)
	director.face.set_mouth("wavy")
	director.face.set_accent("question", true)
	
	# 5. Thoughtful hold
	await director.hold(0.55)
	
	# 6. Tiny second eye movement (re-evaluating thought)
	await director.eyes.look(Vector2(0.4, 0.3), "fast")
	await director.hold(0.60)

## TEST D — REALIZATION
## Sequence: Neutral -> notice -> pause -> eyes widen -> brows rise -> mouth begins changing -> head turns -> hold.
## The delay is visible; does NOT jump instantly from neutral to shocked.
func test_d_realization() -> void:
	await director.reset()
	await director.hold(0.40)
	
	# 1. Notice glance
	await director.eyes.look("right", "fast")
	
	# 2. Crucial cognitive delay
	await director.hold(0.20)
	
	# 3. Eyes widen slightly (1.20x)
	director.eyes.widen(1.20, 0.10)
	await director.hold(0.12)
	
	# 4. Brows pop up & mouth begins opening in realization
	director.face.set_eyebrows("both", 8.0, 0.15, 0.12)
	director.face.set_mouth("open_excited")
	director.face.set_accent("sparkles", true)
	
	# 5. Head turns to face the realization (8°)
	await director.head.turn(8.0, "fast")
	
	# 6. Sustained realization hold
	await director.hold(0.75)

## TEST E — SHOCK
## Sequence: Neutral -> notice -> pause -> eyes widen -> brows rise -> mouth opens -> anticipation -> recoil -> hair follows -> settle -> freeze -> long hold.
## Full physical and facial shock reaction with aftermath freeze.
func test_e_shock() -> void:
	await director.reset()
	await director.hold(0.40)
	
	# 1. Notice glance
	await director.eyes.look("right", "snap")
	
	# 2. Brief cognitive beat before reaction
	await director.hold(0.12)
	
	# 3. Eyes widen, brows rise, mouth snaps open
	director.face.set_expression("shocked", "snap")
	
	# 4. Body recoil with anticipation, defensive arms, and trauma shake
	await director.body.recoil(1.0, true, 0.14)
	
	# 5. Hair follows and settles
	# 6. Instant freeze in the shocked recoil pose
	director.freeze()
	
	# 7. Crucial aftermath hold (shock landing)
	await director.hold(0.90)

## TEST F — DEADPAN
## Sequence: Notice -> tiny head tilt -> minimal facial change -> hold 1.0s.
## The lack of movement is completely intentional and comedic.
func test_f_deadpan() -> void:
	await director.reset()
	await director.hold(0.40)
	
	# 1. Small understated side-eye glance
	await director.eyes.look(Vector2(0.65, 0.0), "fast")
	await director.hold(0.25)
	
	# 2. Tiny 3-degree unamused head tilt
	await director.head.tilt(3.0, 0.20)
	
	# 3. Minimal facial change: flat unamused mouth and half-lidded eyes
	director.face.set_expression("deadpan", "snap")
	
	# 4. Long deadpan silence hold
	await director.hold(1.00)

## TEST G — EXAGGERATED COMEDIC ACTION
## Sequence: Neutral -> anticipation -> fast pointing action -> overshoot -> settle -> hold -> sudden recoil -> freeze.
## Strong contrast between total stillness and snappy action.
func test_g_exaggerated_action() -> void:
	await director.reset()
	await director.hold(0.35)
	
	# 1. Anticipation pre-load (slight backward lean and prep)
	director.body.lean(-4.0, 0.12)
	await director.hold(0.12)
	
	# 2. Fast point with distinct +6° overshoot and settle
	await director.body.point("right", "fast", false, true)
	
	# 3. Punctuation hold
	await director.hold(0.50)
	
	# 4. Sudden panic recoil and freeze
	director.face.set_expression("shocked", "snap")
	await director.body.recoil(0.95, true, 0.12)
	director.freeze()
	
	# 5. Aftermath hold
	await director.hold(0.70)

## TEST H — NEW COMBINATION (ZERO NEW ARTWORK)
## Sequence: Looks left with eyes, turns head right, raises one eyebrow, leans backward, raises right arm, bends elbow, points upward, opens mouth slightly, hair follows, freezes.
func test_h_novel_combination() -> void:
	await director.reset()
	await director.hold(0.35)
	
	# Staggered multi-joint composition:
	# 1. Torso leans backward (-14°)
	director.body.lean(-14.0, 0.20)
	
	# 2. Head turns right (+16°) with secondary hair follow
	director.head.turn(16.0, "normal", false, true)
	
	# 3. Eyes cut left (-1.0)
	director.eyes.look("left", "fast")
	
	# 4. Asymmetric brow & mouth
	director.face.set_eyebrows("left", 8.0, 0.22, 0.15)
	director.face.set_mouth("open_excited")
	
	# 5. Right arm points upward with bent elbow
	await director.body.point("right", "fast", false, true)
	
	# 6. Settle and freeze
	director.freeze()
	await director.hold(0.90)

## TEST I — MULTI-STAGE REACTION (THE CORE ACTING TEST)
## Sequence: NORMAL -> NOTICE -> CONFUSION -> REALIZATION -> SHOCK -> AFTERMATH.
## Each stage features distinct timing, intensity, and movement progression.
func test_i_multistage_reaction() -> void:
	# Phase 1: NORMAL (Neutral rest)
	await director.reset()
	await director.hold(0.50)
	
	# Phase 2: NOTICE (Eyes shift to target, hold processing beat)
	await director.eyes.look("right", "fast")
	await director.hold(0.20)
	
	# Phase 3: CONFUSION (Head tilts slightly, one brow raises, question mark)
	await director.head.tilt(4.0, 0.18)
	director.face.set_eyebrows("left", 6.0, 0.20, 0.15)
	director.face.set_mouth("wavy")
	director.face.set_accent("question", true)
	await director.hold(0.45)
	
	# Phase 4: REALIZATION (Eyes widen, both brows jump, excited mouth, head snaps up)
	director.face.clear_accents()
	director.eyes.widen(1.22, 0.10)
	director.face.set_eyebrows("both", 8.0, 0.15, 0.12)
	director.face.set_mouth("open_excited")
	director.face.set_accent("sparkles", true)
	await director.head.turn(12.0, "fast")
	await director.hold(0.50)
	
	# Phase 5: SHOCK (Sudden expression snap, violent recoil backward, screen trauma)
	director.face.clear_accents()
	director.face.set_expression("shocked", "snap")
	await director.body.recoil(1.0, true, 0.12)
	
	# Phase 6: AFTERMATH (Absolute motionless freeze landing)
	director.freeze()
	await director.hold(1.00)

## TEST J — SAME EVENT, THREE INTENSITIES
## Sequence: Recoil tested at 0.2 (subtle), 0.5 (normal), 1.0 (exaggerated).
## Demonstrates scaling movement, speed, overshoot, and facial reaction from the same system.
func test_j_three_intensities() -> void:
	# 1. Subtle Recoil (0.2x)
	await director.reset()
	await director.hold(0.30)
	director.eyes.look(Vector2(0.3, 0.0), "fast")
	director.face.set_eyebrows("both", 3.0, 0.05, 0.12)
	await director.body.recoil(0.2, false, 0.20)
	await director.hold(0.50)
	
	# 2. Normal Recoil (0.5x)
	await director.reset()
	await director.hold(0.30)
	director.eyes.look("right", "fast")
	director.face.set_eyebrows("both", 6.0, 0.12, 0.12)
	director.face.set_mouth("surprised")
	await director.body.recoil(0.5, true, 0.16)
	await director.hold(0.60)
	
	# 3. Exaggerated Recoil (1.0x)
	await director.reset()
	await director.hold(0.30)
	director.face.set_expression("shocked", "snap")
	await director.body.recoil(1.0, true, 0.12)
	director.freeze()
	await director.hold(0.80)

# =========================================================================
# ADDITIONAL COMEDIC & STORYTELLING CONVENIENCES
# =========================================================================

func notice(direction: String = "right") -> void:
	await director.look_at_target(direction, "fast", 0.15, true)
	await director.hold(NemiTiming.HOLD_BEAT)

func confusion() -> void:
	await test_c_confusion()

func realization() -> void:
	await test_d_realization()

func shock(intensity: float = 1.0) -> void:
	await director.reset()
	director.face.set_expression("shocked", "snap")
	await director.body.recoil(intensity, true)
	director.freeze()
	await director.hold(NemiTiming.HOLD_AFTERMATH)

func deadpan() -> void:
	await test_f_deadpan()

func embarrassment() -> void:
	await director.reset()
	await director.eyes.look(Vector2(0.65, 0.25), "fast")
	await director.hold(0.15)
	director.face.set_expression("embarrassed", "snap")
	await director.head.turn(6.0, "fast")
	await director.hold(0.70)

func awkward_pause() -> void:
	await director.hold(0.60)
	await director.eyes.eye_dart("left", 0.20)
	await director.hold(0.50)
	director.face.set_expression("deadpan", "snap")
	await director.hold(0.80)

func comedic_timing() -> void:
	director.face.set_expression("happy", "snap")
	await director.body.point("right", "fast", false, true)
	await director.hold(0.55)
	await director.hold(0.40)
	await director.eyes.look("left", "fast")
	director.face.set_eyebrows("left", 5.0, 0.2, 0.12)
	await director.hold(0.30)
	director.face.set_expression("shocked", "snap")
	await director.body.recoil(0.85, true)
	director.freeze()
	await director.hold(0.85)

func exaggerated_action() -> void:
	await test_g_exaggerated_action()
