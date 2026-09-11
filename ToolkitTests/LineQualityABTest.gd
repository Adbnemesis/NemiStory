extends Node2D
## LineQualityABTest — CURRENT InkStroke ribbons (left) vs AntialiasedLine2D (right).
## Vendored MIT addon used RUNTIME-ONLY (no editor plugin enabled, no addons/ touch).
## Render headless: Tools > Render A/B (editor) or --write-movie; dummy rasterizer can't render.

const InkStrokeScript = preload("res://characters/nemi/drawing/InkStroke.gd")
const CurveUtil = preload("res://ToolkitTests/_support/BezierUtil.gd")
const StrokePainter = preload("res://ToolkitTests/_support/StrokePainter.gd")
const AASingleton = preload("res://ToolkitTests/_vendor/antialiased_line2d/texture.gd")

var ink_color := Color("#38101e")
var accent_color := Color("#d64937")
var cam: Camera2D
var label_status: Label
var aa_texture: ImageTexture

func _ready() -> void:
	aa_texture = _generate_aa_texture()
	_build_stage()
	_build_current_column(Vector2(40, 0))
	_build_aa_column(Vector2(660, 0))
	_build_ui()
	_apply_zoom(1.0)

## Inline copy of the vendored addon's mipmap-generation routine
## (avoids _ready-order race: the singleton child is NOT ready yet in _ready).
func _generate_aa_texture() -> ImageTexture:
	var data := PackedByteArray()
	for mipmap in [256, 128, 64, 32, 16, 8, 4, 2, 1]:
		for y in mipmap:
			for x in mipmap:
				data.push_back(255)
				if mipmap >= 4:
					data.push_back(0 if (y == 0 or y == mipmap - 1) else 255)
				elif mipmap == 2:
					data.push_back(0 if y == 1 else 255)
				else:
					data.push_back(128)
	var image := Image.create_from_data(256, 256, true, Image.FORMAT_LA8, data)
	return ImageTexture.create_from_image(image)

func _build_stage() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#faf7f5")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -100
	add_child(bg)
	cam = Camera2D.new()
	cam.position = Vector2(640, 360)
	add_child(cam)
	cam.make_current()

func _title(col: Node2D, text: String) -> void:
	var lbl := Label.new()
	lbl.position = Vector2(10, 14)
	lbl.add_theme_font_size_override("font_size", 19)
	lbl.add_theme_color_override("font_color", ink_color)
	lbl.text = text
	col.add_child(lbl)

func _stroke_host(col: Node2D, at: Vector2) -> Node2D:
	var host := Node2D.new()
	host.position = at
	col.add_child(host)
	return host

func _paint_stroke(host: Node2D, stroke: RefCounted) -> void:
	var painter := Node2D.new()
	painter.set_script(StrokePainter)
	painter.set_meta("stroke", stroke)
	host.add_child(painter)

func _aa_line(parent: Node2D, pts: PackedVector2Array, width: float, col: Color) -> Line2D:
	var line := Line2D.new()
	line.points = pts
	line.width = width
	line.default_color = col
	line.antialiased = true
	line.texture = aa_texture
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	parent.add_child(line)
	return line

func _organic_curve() -> PackedVector2Array:
	var c := Curve2D.new()
	c.add_point(Vector2(-90, 40))
	c.add_point(Vector2(-30, -55))
	c.add_point(Vector2(55, 30))
	c.add_point(Vector2(100, -25))
	return c.tessellate(5, 2.0)

func _arrow_pts() -> PackedVector2Array:
	return PackedVector2Array([Vector2(-100, 15), Vector2(-20, -12), Vector2(60, 8), Vector2(100, -14)])

func _question_pts() -> PackedVector2Array:
	return PackedVector2Array([Vector2(-16, -30), Vector2(16, -32), Vector2(14, -6), Vector2(-2, 6)])

func _shock_set() -> Array:
	var out: Array = []
	for k in range(5):
		var a := -0.5 + float(k) * 0.25
		var dir := Vector2(sin(a), -cos(a))
		out.append(PackedVector2Array([dir * 14.0, dir * 40.0]))
	return out

func _build_current_column(offset: Vector2) -> void:
	var col := Node2D.new()
	col.name = "CurrentRenderer"
	col.position = offset
	add_child(col)
	_title(col, "A — CURRENT (InkStroke ribbons)")
	_paint_stroke(_stroke_host(col, Vector2(130, 120)),
		InkStrokeScript.from_points(_organic_curve(), 5.0, 0, ink_color))
	_paint_stroke(_stroke_host(col, Vector2(130, 270)),
		InkStrokeScript.from_points(_arrow_pts(), 4.0, 0, accent_color))
	var qh := _stroke_host(col, Vector2(80, 450))
	_paint_stroke(qh, InkStrokeScript.from_points(_question_pts(), 4.5, 0, ink_color))
	_paint_stroke(qh, InkStrokeScript.from_points(
		PackedVector2Array([Vector2(0, 24), Vector2(0, 26)]), 4.5, 0, ink_color))
	var sh := _stroke_host(col, Vector2(330, 450))
	for pair in _shock_set():
		_paint_stroke(sh, InkStrokeScript.from_points(pair, 2.2, 0, ink_color))
	_paint_stroke(_stroke_host(col, Vector2(130, 590)),
		InkStrokeScript.from_points(CurveUtil.scribble_points(90.0, 26.0, 3), 2.2, 0, ink_color))
	_paint_stroke(_stroke_host(col, Vector2(360, 590)),
		InkStrokeScript.from_points(
			PackedVector2Array([Vector2(-60, 0), Vector2(0, 3), Vector2(60, -1)]), 2.2, 0, accent_color))

func _build_aa_column(offset: Vector2) -> void:
	var col := Node2D.new()
	col.name = "AARenderer"
	col.position = offset
	add_child(col)
	_title(col, "B — ANTIALIASED Line2D (MIT)")
	_aa_line(_stroke_host(col, Vector2(130, 120)), _organic_curve(), 5.0, ink_color)
	_aa_line(_stroke_host(col, Vector2(130, 270)), _arrow_pts(), 4.0, accent_color)
	var qh := _stroke_host(col, Vector2(80, 450))
	_aa_line(qh, _question_pts(), 4.5, ink_color)
	_aa_line(qh, PackedVector2Array([Vector2(0, 24), Vector2(0, 26)]), 4.5, ink_color)
	var sh := _stroke_host(col, Vector2(330, 450))
	for pair in _shock_set():
		_aa_line(sh, pair, 2.2, ink_color)
	_aa_line(_stroke_host(col, Vector2(130, 590)),
		CurveUtil.scribble_points(90.0, 26.0, 3), 2.2, ink_color)
	_aa_line(_stroke_host(col, Vector2(360, 590)),
		PackedVector2Array([Vector2(-60, 0), Vector2(0, 3), Vector2(60, -1)]), 2.2, accent_color)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	label_status = Label.new()
	label_status.position = Vector2(24, 676)
	label_status.add_theme_font_size_override("font_size", 15)
	label_status.add_theme_color_override("font_color", ink_color)
	layer.add_child(label_status)
	_update_status(1.0)

func _update_status(z: float) -> void:
	label_status.text = "Line A/B — CURRENT (left) vs Antialiased Line2D (right) — zoom %.2fx — keys 1/2" % z

func _apply_zoom(z: float) -> void:
	cam.zoom = Vector2(z, z)
	_update_status(z)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_apply_zoom(1.0)
			KEY_2:
				_apply_zoom(2.5)
