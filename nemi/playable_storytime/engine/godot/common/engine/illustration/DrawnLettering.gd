extends RefCounted
## Original centerline alphabet. No system-font substitution in artwork.
static var _alphabet: Dictionary = {}
static var _warned: Dictionary = {}

static func compose(text: String, size: float = 32.0, color: Color = Color("#423035"), seed_value: int = 0) -> Dictionary:
	if _alphabet.is_empty():
		var data = JSON.parse_string(FileAccess.get_file_as_string("res://common/assets/lettering/story_pen.json"))
		_alphabet = data.glyphs
	var strokes: Array[Dictionary] = []
	var x := 0.0
	var y := 0.0
	var max_width := 0.0
	var unit := size / 10.0
	var normalized := text.replace("’", "'").replace("‘", "'").replace("“", "\"").replace("”", "\"").replace("—", "-").replace("–", "-").replace("…", "...").replace("🎉", "*").replace("🔔", "*")
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(normalized) + seed_value
	var occurrences: Dictionary = {}
	for ch in normalized:
		if ch == "\n":
			max_width = maxf(max_width, x)
			x = 0.0
			y += size * 1.65
			continue
		if ch == " ":
			x += size * 0.43
			continue
		if not _alphabet.has(ch):
			if not _warned.has(ch):
				push_warning("Drawn lettering: missing glyph '" + ch + "'; showing visible question mark.")
				_warned[ch] = true
			ch = "?"
		var glyph: Dictionary = _alphabet[ch]
		var occurrence: int = occurrences.get(ch, 0)
		occurrences[ch] = occurrence + 1
		var variant: Array = glyph.variants[(occurrence + absi(seed_value)) % glyph.variants.size()]
		var baseline := rng.randf_range(-0.025, 0.025) * size
		var slant := rng.randf_range(-0.045, 0.065)
		var stretch := rng.randf_range(0.96, 1.045)
		for i in range(variant.size()):
			var pts := PackedVector2Array()
			for point in variant[i]:
				pts.append(Vector2(x + (float(point[0]) + (10.0 - float(point[1])) * slant) * unit, y + float(point[1]) * unit * stretch + baseline))
			strokes.append({"pts": pts, "smooth": glyph.smooth, "w": maxf(1.0, size * 0.057), "col": color,
				"pause": 0.045 if i == 0 else 0.018,
				"pressure": PackedFloat32Array([0.44, 0.88, 1.0, 0.72, 0.26])})
		x += float(glyph.advance) * unit * stretch
	max_width = maxf(max_width, x)
	return {"strokes": strokes, "width": max_width, "height": y + size * 1.4}
