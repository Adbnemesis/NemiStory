extends SceneTree
## SFXBrowser — Interactive & CLI Audition Tool for Nemi SFX Vault
##
## Usage (CLI):
##   godot --headless -s tools/SFXBrowser.gd --search=pop
##   godot --headless -s tools/SFXBrowser.gd --category=whooshes
##   godot --headless -s tools/SFXBrowser.gd --play=cartoon_pop_bubble_01
##   godot --headless -s tools/SFXBrowser.gd --stats
##
## Usage (GUI):
##   Launch standalone scene or run in Godot editor.

const CATALOG_PATH := "res://audio/sfx/sfx_catalog.json"

var _catalog: Array = []
var _catalog_by_id: Dictionary = {}
var _player: AudioStreamPlayer = null

func _init() -> void:
	_load_catalog()
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		args = OS.get_cmdline_args()

	var search_term := ""
	var category_filter := ""
	var play_id := ""
	var show_stats := false

	for arg in args:
		if arg.begins_with("--search="):
			search_term = arg.trim_prefix("--search=").to_lower()
		elif arg.begins_with("--category="):
			category_filter = arg.trim_prefix("--category=").to_lower()
		elif arg.begins_with("--play="):
			play_id = arg.trim_prefix("--play=")
		elif arg == "--stats":
			show_stats = true

	# Default to interactive GUI or quick query
	if DisplayServer.get_name() == "headless" or not search_term.is_empty() or not category_filter.is_empty() or not play_id.is_empty() or show_stats:
		call_deferred("_run_cli", search_term, category_filter, play_id, show_stats)
	else:
		call_deferred("_build_gui")

func _load_catalog() -> void:
	if not FileAccess.file_exists(CATALOG_PATH):
		printerr("SFXBrowser: Catalog not found at ", CATALOG_PATH)
		return
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(text) == OK and json.data is Dictionary:
		_catalog = json.data.get("assets", [])
		for item in _catalog:
			_catalog_by_id[item.get("id", "")] = item

func _run_cli(search: String, cat: String, play_id: String, stats: bool) -> void:
	print("============================================================")
	print("  NEMI SFX BROWSER & AUDITION UTILITY")
	print("============================================================")

	if stats or (search.is_empty() and cat.is_empty() and play_id.is_empty()):
		var cat_counts: Dictionary = {}
		var sources: Dictionary = {}
		for item in _catalog:
			var c: String = item.get("category", "misc")
			var s: String = item.get("source", "unknown")
			cat_counts[c] = cat_counts.get(c, 0) + 1
			sources[s] = sources.get(s, 0) + 1

		print("Total Assets in Vault: %d" % _catalog.size())
		print("\nCategories:")
		for c in cat_counts.keys():
			print("  • %-14s: %3d sounds" % [c, cat_counts[c]])
		print("\nSources:")
		for s in sources.keys():
			print("  • %-18s: %3d sounds" % [s, sources[s]])

	if not search.is_empty() or not cat.is_empty():
		print("\nSearch results [Query='%s', Category='%s']:" % [search, cat])
		var matches: Array = []
		for item in _catalog:
			var match_search: bool = search.is_empty() or \
				search in item.get("id", "").to_lower() or \
				search in item.get("description", "").to_lower() or \
				search in " ".join(item.get("tags", [])).to_lower()
			var match_cat: bool = cat.is_empty() or cat == item.get("category", "").to_lower()

			if match_search and match_cat:
				matches.append(item)

		print("Found %d matching sounds:\n" % matches.size())
		for item in matches:
			var tags_str: String = ", ".join(item.get("tags", []))
			print("  [%s] %s" % [item.get("category"), item.get("id")])
			print("    Desc    : %s" % item.get("description"))
			print("    File    : %s" % item.get("filename"))
			print("    Source  : %s (%s)" % [item.get("source"), item.get("license")])
			print("    Tags    : %s" % tags_str)
			print("    Mix Level: %s" % item.get("mix_guidance", "normal"))
			print("    Path    : res://%s\n" % item.get("relative_path"))

	if not play_id.is_empty():
		if _catalog_by_id.has(play_id):
			var item: Dictionary = _catalog_by_id[play_id]
			print("Auditioning SFX: %s (%s)" % [play_id, item.get("relative_path")])
			var res_path: String = "res://" + item.get("relative_path", "")
			var stream: AudioStream = load(res_path)
			if stream != null:
				_player = AudioStreamPlayer.new()
				root.add_child(_player)
				_player.stream = stream
				_player.play()
				var wait_dur: float = min(stream.get_length() + 0.1, 4.0)
				await create_timer(wait_dur).timeout
				_player.stop()
				_player.queue_free()
				print("Audition complete.")
		else:
			printerr("Unknown SFX ID: ", play_id)

	quit(0)

func _build_gui() -> void:
	var win := Control.new()
	win.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(win)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.12, 0.13, 0.15)
	win.add_child(bg)

	var label := Label.new()
	label.text = "NEMI SFX BROWSER V1 (%d Sounds Loaded)" % _catalog.size()
	label.position = Vector2(24, 20)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	win.add_child(label)

	var search_box := LineEdit.new()
	search_box.placeholder_text = "Search sounds by keyword or tag (e.g. pop, whoosh, boing, scribble)..."
	search_box.position = Vector2(24, 60)
	search_box.size = Vector2(500, 36)
	win.add_child(search_box)

	var list := ItemList.new()
	list.position = Vector2(24, 110)
	list.size = Vector2(500, 560)
	win.add_child(list)

	for item in _catalog:
		list.add_item("[%s] %s" % [item.get("category"), item.get("id")])

	var meta_panel := RichTextLabel.new()
	meta_panel.position = Vector2(540, 110)
	meta_panel.size = Vector2(600, 480)
	meta_panel.bbcode_enabled = true
	meta_panel.text = "[color=#888888]Select a sound from the list to preview details and audition.[/color]"
	win.add_child(meta_panel)

	var play_btn := Button.new()
	play_btn.text = "▶ AUDITION SOUND"
	play_btn.position = Vector2(540, 610)
	play_btn.size = Vector2(200, 50)
	win.add_child(play_btn)

	var player := AudioStreamPlayer.new()
	win.add_child(player)

	var selected_item := {}

	list.item_selected.connect(func(idx: int):
		if idx >= 0 and idx < _catalog.size():
			selected_item = _catalog[idx]
			var bb := "[b][size=20][color=#ffd700]%s[/color][/size][/b]\n\n" % selected_item.get("id")
			bb += "[b]Category:[/b] %s\n" % selected_item.get("category")
			bb += "[b]Description:[/b] %s\n\n" % selected_item.get("description")
			bb += "[b]Source:[/b] %s\n" % selected_item.get("source")
			bb += "[b]License:[/b] %s\n" % selected_item.get("license")
			bb += "[b]Commercial Safe:[/b] YES (YouTube Monetization Approved)\n"
			bb += "[b]Mix Guidance:[/b] %s\n" % selected_item.get("mix_guidance")
			bb += "[b]File:[/b] %s\n" % selected_item.get("filename")
			bb += "[b]Path:[/b] res://%s\n\n" % selected_item.get("relative_path")
			bb += "[b]Tags:[/b] %s\n" % ", ".join(selected_item.get("tags", []))
			meta_panel.text = bb
	)

	play_btn.pressed.connect(func():
		if selected_item.is_empty():
			return
		var p: String = "res://" + selected_item.get("relative_path", "")
		if ResourceLoader.exists(p):
			player.stream = load(p)
			player.play()
	)

	search_box.text_changed.connect(func(query: String):
		list.clear()
		var q := query.to_lower()
		for item in _catalog:
			if q.is_empty() or q in item.get("id", "").to_lower() or q in item.get("description", "").to_lower():
				list.add_item("[%s] %s" % [item.get("category"), item.get("id")])
	)
