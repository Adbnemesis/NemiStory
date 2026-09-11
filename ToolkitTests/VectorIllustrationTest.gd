extends Node2D
## VectorIllustrationTest — CURRENT (left) vs Scalable Vector Shapes (right).
## SVS runtime-only (no editor plugin): ScalableVectorShape2D + assigned Line2D.
## Render: open scene in editor, keys 1/2, or --write-movie (dummy can't render).

const InkStrokeScript = preload("res://characters/nemi/drawing/InkStroke.gd")
const CurveUtil = preload("res://ToolkitTests/_support/BezierUtil.gd")
const StrokePainter = preload("res://ToolkitTests/_support/StrokePainter.gd")
const SVS = preload("res://ToolkitTests/_vendor/scalable_vector_shapes/scalable_vector_shape_2d.gd")

var ink_color := Color("#38101e")
var accent_color := Color("#d64937")
var cam: Camera2D
var label_status: Label
var cur_root: Node2D
var svs_root: Node2D

func _ready() -> void:
	_build_stage()
	_build_current_column(Vector2(40, 0))
	_build_svs_column(Vector2(660, 0))
	_build_ui()
	_apply_zoom(1.0)

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


func _build_current_column(offset: Vector2) -> void:
	cur_root = Node2D.new()
	cur_root.name = "CurrentRenderer"
	cur_root.position = offset
	add_child(cur_root)
	_title(cur_root, "A — CURRENT (InkStroke ribbons)")
	var curve := Curve2D.new()
	curve.add_point(Vector2(-90, 40))
	curve.add_point(Vector2(-30, -55))
	curve.add_point(Vector2(55, 30))
	curve.add_point(Vector2(100, -25))
	_paint_stroke(_stroke_host(cur_root, Vector2(130, 120)),
		InkStrokeScript.from_points(curve.tessellate(5, 2.0), 5.0, 0, ink_color))
	_paint_stroke(_stroke_host(cur_root, Vector2(130, 270)),
		InkStrokeScript.from_points(
			PackedVector2Array([Vector2(-100, 15), Vector2(-20, -12), Vector2(60, 8), Vector2(100, -14)]),
			4.0, 0, accent_color))
	var qc := Curve2D.new()
	qc.add_point(Vector2(-16, -30))
	qc.add_point(Vector2(16, -32))
	qc.add_point(Vector2(14, -6))
	qc.add_point(Vector2(-2, 6))
	var qh := _stroke_host(cur_root, Vector2(80, 450))
	_paint_stroke(qh, InkStrokeScript.from_points(qc.tessellate(5, 2.0), 4.5, 0, ink_color))
	_paint_stroke(qh, InkStrokeScript.from_points(
		PackedVector2Array([Vector2(0, 24), Vector2(0, 26)]), 4.5, 0, ink_color))
	var pts := PackedVector2Array([Vector2(0, -28)])
	for i in range(13):
		var a := lerpf(0.15 * PI, 0.85 * PI, float(i) / 12.0)
		pts.append(Vector2(cos(a), sin(a)) * 13.0 + Vector2(0, 6))
	pts.append(pts[0])
	_paint_stroke(_stroke_host(cur_root, Vector2(200, 450)),
		InkStrokeScript.from_points(pts, 2.4, 0, ink_color))
	var sh := _stroke_host(cur_root, Vector2(330, 450))
	for k in range(5):
		var a := -0.5 + float(k) * 0.25
		var dir := Vector2(sin(a), -cos(a))
		_paint_stroke(sh, InkStrokeScript.from_points(
			PackedVector2Array([dir * 14.0, dir * 40.0]), 2.2, 0, ink_color))
	_paint_stroke(_stroke_host(cur_root, Vector2(130, 590)),
		InkStrokeScript.from_points(CurveUtil.scribble_points(90.0, 26.0, 3), 2.2, 0, ink_color))
	_paint_stroke(_stroke_host(cur_root, Vector2(360, 590)),
		InkStrokeScript.from_points(
			PackedVector2Array([Vector2(-60, 0), Vector2(0, 3), Vector2(60, -1)]), 2.2, 0, accent_color))

func _svs_stroke(parent: Node2D, pts: PackedVector2Array, width: float, col: Color,
		closed: bool = false) -> Node:
	var shape: Node2D = SVS.new()
	shape.set("update_curve_at_runtime", true)
	var line := Line2D.new()
	line.width = width
	line.default_color = col
	line.antialiased = true
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	shape.add_child(line)
	parent.add_child(shape)
	var c := Curve2D.new()
	for p in pts:
		c.add_point(p)
	if closed and pts.size() > 0:
		c.add_point(pts[0])
	shape.set("curve", c)
	shape.set("line", line)
	shape.set("stroke_width", width)
	shape.set("stroke_color", col)
	shape.call("_update_curve")
	return shape

func _build_svs_column(offset: Vector2) -> void:
	svs_root = Node2D.new()
	svs_root.name = "SVSRenderer"
	svs_root.position = offset
	add_child(svs_root)
	_title(svs_root, "B — SCALABLE VECTOR SHAPES (MIT)")
	_svs_stroke(_stroke_host(svs_root, Vector2(130, 120)),
		PackedVector2Array([Vector2(-90, 40), Vector2(-30, -55), Vector2(55, 30), Vector2(100, -25)]),
		5.0, ink_color)
	_svs_stroke(_stroke_host(svs_root, Vector2(130, 270)),
		PackedVector2Array([Vector2(-100, 15), Vector2(-20, -12), Vector2(60, 8), Vector2(100, -14)]),
		4.0, accent_color)
	var qh := _stroke_host(svs_root, Vector2(80, 450))
	_svs_stroke(qh, PackedVector2Array(
		[Vector2(-16, -30), Vector2(16, -32), Vector2(14, -6), Vector2(-2, 6)]), 4.5, ink_color)
	_svs_stroke(qh, PackedVector2Array([Vector2(0, 24), Vector2(0, 26)]), 4.5, ink_color)
	var sweat := PackedVector2Array([Vector2(0, -28)])
	for i in range(13):
		var a := lerpf(0.15 * PI, 0.85 * PI, float(i) / 12.0)
		sweat.append(Vector2(cos(a), sin(a)) * 13.0 + Vector2(0, 6))
	_svs_stroke(_stroke_host(svs_root, Vector2(200, 450)), sweat, 2.4, ink_color, true)
	var sh := _stroke_host(svs_root, Vector2(330, 450))
	for k in range(5):
		var a := -0.5 + float(k) * 0.25
		var dir := Vector2(sin(a), -cos(a))
		_svs_stroke(sh, PackedVector2Array([dir * 14.0, dir * 40.0]), 2.2, ink_color)
	_svs_stroke(_stroke_host(svs_root, Vector2(130, 590)),
		CurveUtil.scribble_points(90.0, 26.0, 3), 2.2, ink_color)
	_svs_stroke(_stroke_host(svs_root, Vector2(360, 590)),
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
	label_status.text = "Vector A/B — CURRENT (left) vs Scalable Vector Shapes (right) — zoom %.2fx — keys 1/2" % z

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