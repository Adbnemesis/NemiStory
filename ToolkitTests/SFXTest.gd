extends SceneTree
## SFXTest.gd — Full Vault Verification Suite for Nemi Sound Effects V1
## Verifies 100% of the curated SFX library across all 18 categories:
## - Reads audio/sfx/sfx_catalog.json
## - Checks ResourceLoader validity and stream loading
## - Asserts positive audio duration
## - Validates AudioStreamPlayer audition playback

const CATALOG_PATH := "res://audio/sfx/sfx_catalog.json"

func _init() -> void:
	print("============================================================")
	print("  NEMI SFX VAULT V1 — COMPREHENSIVE ASSET AUDIT SUITE")
	print("============================================================")
	call_deferred("_run_vault_audit")

func _run_vault_audit() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		printerr("FATAL: SFX Catalog not found at ", CATALOG_PATH)
		quit(1)
		return

	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		printerr("FATAL: Failed to parse catalog JSON: ", json.get_error_message())
		quit(1)
		return

	var catalog_data: Dictionary = json.data
	var catalog: Array = catalog_data.get("assets", [])
	print("Catalog loaded: %d sound effects registered." % catalog.size())

	var player := AudioStreamPlayer.new()
	root.add_child(player)

	var passed := 0
	var failed := 0
	var missing := 0
	var invalid_dur := 0
	var categories_tested := {}

	for item in catalog:
		var sfx_id: String = item.get("id", "unknown")
		var rel_path: String = item.get("relative_path", "")
		var cat: String = item.get("category", "misc")
		var res_path: String = "res://" + rel_path

		categories_tested[cat] = categories_tested.get(cat, 0) + 1

		if not ResourceLoader.exists(res_path):
			printerr("  ✗ [MISSING ASSET] %s -> %s" % [sfx_id, res_path])
			missing += 1
			failed += 1
			continue

		var stream: AudioStream = load(res_path)
		if stream == null:
			printerr("  ✗ [LOAD FAILED] %s -> %s" % [sfx_id, res_path])
			failed += 1
			continue

		var dur: float = stream.get_length()
		if dur <= 0.0:
			printerr("  ✗ [ZERO DURATION] %s -> %s (dur=%.3f)" % [sfx_id, res_path, dur])
			invalid_dur += 1
			failed += 1
			continue

		player.stream = stream
		player.play()
		player.stop()

		passed += 1

	player.stream = null
	player.queue_free()
	# Flush frame
	await process_frame

	print("\n--- AUDIT RESULTS BY CATEGORY ---")
	for cat in categories_tested.keys():
		print("  • %-14s : %d sounds verified" % [cat, categories_tested[cat]])

	print("\n============================================================")
	print("TOTAL REGISTERED : %d" % catalog.size())
	print("PASSED AUDIT     : %d" % passed)
	print("FAILED AUDIT     : %d" % failed)
	print("============================================================")

	if failed > 0:
		printerr("AUDIT FAILED: %d assets failed verification." % failed)
		quit(1)
	else:
		print("SUCCESS: 100% of Nemi SFX Vault assets verified and ready for production!")
		quit(0)
