extends RefCounted
## Explicit author identity. Existing generic illustration defaults are unchanged.
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
static var _profiles: Dictionary = {}
static var _alphabets: Dictionary = {}

static func profile(author: String) -> Dictionary:
	assert(author in ["nemi", "adb"], "Choose an author: nemi or adb")
	if not _profiles.has(author):
		_profiles[author] = JSON.parse_string(FileAccess.get_file_as_string("res://common/storytime/profiles/%s.json" % author))
	return _profiles[author]

static func normalize(text: String) -> String:
	return text.replace("’", "'").replace("‘", "'").replace("“", "\"").replace("”", "\"").replace("—", "-").replace("–", "-").replace("…", "...")

static func compose(author: String, text: String, size: float = 32.0, accent: bool = false, variant: int = 0) -> Dictionary:
	var style := profile(author)
	if not _alphabets.has(author):
		_alphabets[author] = JSON.parse_string(FileAccess.get_file_as_string(style.lettering)).glyphs
	var alphabet: Dictionary = _alphabets[author]
	var strokes: Array[Dictionary] = []
	var x := 0.0
	var y := 0.0
	var width := 0.0
	var unit := size / 10.0
	var ink := Color(style.accent if accent else style.ink)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(author + normalize(text)) + variant
	var occurrences: Dictionary = {}
	for ch in normalize(text):
		if ch == "\n":
			width = maxf(width, x)
			x = 0.0
			y += size * 1.65
			continue
		if ch == " ":
			x += size * float(style.space)
			continue
		assert(alphabet.has(ch), "Unsupported drawn glyph '%s'; change the text or author the glyph." % ch)
		var glyph: Dictionary = alphabet[ch]
		var index: int = occurrences.get(ch, 0)
		occurrences[ch] = index + 1
		var paths: Array = glyph.variants[(index + absi(variant)) % glyph.variants.size()]
		var baseline := rng.randf_range(-float(style.baseline), float(style.baseline)) * size
		var slant := rng.randf_range(float(style.slant_min), float(style.slant_max))
		for i in range(paths.size()):
			var pts := PackedVector2Array()
			for raw in paths[i]:
				var pt := Vector2(x + (float(raw[0]) + (10.0-float(raw[1]))*slant)*unit, y + float(raw[1])*unit + baseline)
				pts.append(pt)
				width = maxf(width, pt.x + size * 0.04)
			strokes.append({"pts":pts, "smooth":glyph.smooth, "w":maxf(0.9,size*float(style.width)), "col":ink,
				"pause":float(style.pen_lift) if i==0 else float(style.pen_lift)*0.55,
				"pressure":PackedFloat32Array(style.pressure)})
		x += float(glyph.advance) * unit
	width = maxf(width,x)
	return {"strokes":strokes, "width":width, "height":y+size*1.45}

static func lettering(author: String, text: String, size: float = 32.0, accent: bool = false, variant: int = 0):
	var node := Drawing.new()
	var data := compose(author,text,size,accent,variant)
	node.stroke_list.assign(data.strokes)
	node.prepare()
	return node

static func mark(author: String, kind: String, accent: bool = false):
	var style := profile(author)
	assert(style.marks.has(kind), "Unknown %s mark: %s" % [author,kind])
	var node := Drawing.new()
	for path in style.marks[kind]:
		var pts := PackedVector2Array()
		for pt in path.points:
			pts.append(Vector2(pt[0],pt[1]))
		node.stroke_list.append({"pts":pts,"smooth":path.get("smooth",true),
			"w":path.get("width",3.0),"col":Color(style.accent if accent else style.ink),
			"pause":path.get("pause",style.pen_lift),"pressure":PackedFloat32Array(style.pressure)})
	node.prepare()
	return node
