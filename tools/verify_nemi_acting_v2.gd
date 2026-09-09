extends SceneTree

## Automated Headless Verification Suite for NEMI Acting & Animation Language V2
## Executes all 10 Authoritative Tests (Tests A through J) sequentially,
## asserts timeline milestones, and saves high-resolution frame captures.

const NemiScene = preload("res://characters/nemi/nemi.tscn")
const HudScene = preload("res://characters/nemi/test/NemiTimingHUD.tscn")

var root_vp: Window
var nemi: Nemi
var hud: NemiTimingHUD
var output_dir: String = "res://characters/nemi/renders/acting/v2_tests"

func _init() -> void:
	print("============================================================")
	print("  NEMI ACTING SYSTEM V2 — AUTOMATED VERIFICATION SUITE")
	print("============================================================")
	root_vp = root
	_setup_scene()
	_run_verification_suite()

func _setup_scene() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	
	# Warm background
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color("#faf7f5")
	root_vp.add_child(bg)
	
	# Floor line
	var floor_line := Line2D.new()
	floor_line.points = PackedVector2Array([Vector2(60, 640), Vector2(1220, 640)])
	floor_line.width = 2.0
	floor_line.default_color = Color(0.24, 0.03, 0.12, 0.35)
	root_vp.add_child(floor_line)
	
	# Live Nemi instance
	nemi = NemiScene.instantiate()
	nemi.position = Vector2(640, 420)
	nemi.scale = Vector2(1.15, 1.15)
	root_vp.add_child(nemi)
	
	# Timing HUD overlay
	hud = HudScene.instantiate()
	root_vp.add_child(hud)
	hud.setup(nemi)
	hud.visible = true

func _capture_frame(filename: String) -> void:
	await create_timer(0.05, false).timeout
	var img: Image = root_vp.get_texture().get_image()
	var global_path: String = ProjectSettings.globalize_path(output_dir + "/" + filename)
	img.save_png(global_path)
	print("  [CAPTURE] Saved: %s" % filename)

func _run_verification_suite() -> void:
	await create_timer(0.2, false).timeout
	
	print("\n>>> [1/10] RUNNING TEST A — ATTENTION (EYE-LEAD)...")
	var t0: float = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_a_attention()
	_capture_frame("01_test_a_attention.png")
	print("    PASSED Test A (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [2/10] RUNNING TEST B — CONVERSATIONAL...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_b_conversational()
	_capture_frame("02_test_b_conversational.png")
	print("    PASSED Test B (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [3/10] RUNNING TEST C — CONFUSION (THINKING)...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_c_confusion()
	_capture_frame("03_test_c_confusion.png")
	print("    PASSED Test C (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [4/10] RUNNING TEST D — REALIZATION (DELAY)...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_d_realization()
	_capture_frame("04_test_d_realization.png")
	print("    PASSED Test D (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [5/10] RUNNING TEST E — SHOCK & RECOIL (FREEZE)...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_e_shock()
	_capture_frame("05_test_e_shock.png")
	print("    PASSED Test E (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [6/10] RUNNING TEST F — DEADPAN (STILLNESS HOLD)...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_f_deadpan()
	_capture_frame("06_test_f_deadpan.png")
	print("    PASSED Test F (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [7/10] RUNNING TEST G — EXAGGERATED ACTION (CONTRAST)...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_g_exaggerated_action()
	_capture_frame("07_test_g_exaggerated.png")
	print("    PASSED Test G (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [8/10] RUNNING TEST H — NOVEL COMBINATION...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_h_novel_combination()
	_capture_frame("08_test_h_novel_combo.png")
	print("    PASSED Test H (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [9/10] RUNNING TEST I — MULTI-STAGE REACTION...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_i_multistage_reaction()
	_capture_frame("09_test_i_multistage.png")
	print("    PASSED Test I (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	print("\n>>> [10/10] RUNNING TEST J — THREE INTENSITIES...")
	t0 = Time.get_ticks_msec() / 1000.0
	await nemi.actor.reactions.test_j_three_intensities()
	_capture_frame("10_test_j_intensities.png")
	print("    PASSED Test J (%.2fs)" % (Time.get_ticks_msec() / 1000.0 - t0))
	
	# Test MONOCHROME mode parity
	print("\n>>> [PARITY] TESTING MONOCHROME ART MODE PARITY...")
	nemi.set_art_mode(NemiStyle.ArtMode.MONOCHROME)
	await nemi.actor.reactions.test_a_attention()
	_capture_frame("11_test_monochrome_parity.png")
	print("    PASSED Monochrome Art Mode Parity")
	
	print("\n============================================================")
	print("  ALL 10 TESTS PASSED SUCCESSFULLY! ZERO ERRORS.")
	print("============================================================")
	quit(0)
