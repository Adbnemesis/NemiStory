extends Node2D
## Short authored accents sampled by the scene clock. No timers/random jitter.
var kind := "realization"
var author := "nemi"
var phase := 0.0
var strength := 1.0
func sample(value: float) -> void:
	phase=clampf(value,0,1)
	queue_redraw()
func _draw() -> void:
	if phase<=0 or phase>=1: return
	var ink := Color("#ad5e69" if author=="nemi" else "#8a6245")
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE*strength)
	var reveal := clampf(phase/0.22,0,1)
	var settle := clampf((1-phase)/0.25,0,1)
	ink.a=settle
	if kind in ["realization","impact"]:
		for i in range(3):
			var angle := -0.95+float(i)*0.5
			var from := Vector2(30,0).rotated(angle)
			var to := Vector2(30+24*reveal,0).rotated(angle)
			draw_line(from,to,ink,2.8,true)
	elif kind=="tears":
		# Stable, asymmetric open ink contours tied to the lower-eye region.
		# A short bead and a longer tear differ from two identical stock icons.
		ink=Color("#513541" if author=="nemi" else "#5b4a46",settle)
		draw_polyline(PackedVector2Array([Vector2(-25,1),Vector2(-28,4),Vector2(-27,9),Vector2(-23,10),Vector2(-21,6)]),ink,1.7,true)
		draw_polyline(PackedVector2Array([Vector2(22,1),Vector2(28,0),Vector2(30,4),Vector2(27,7),Vector2(26,21),Vector2(27,27)]),ink,1.8,true)
		draw_line(Vector2(31,7),Vector2(31,23),ink,1.3,true)
	elif kind=="sweat":
		var pts := PackedVector2Array([Vector2(2,-13),Vector2(-3,-15),Vector2(-6,-10),Vector2(-5,-5),Vector2(0,-3)])
		draw_polyline(pts,ink,1.8,true)
		draw_polyline(PackedVector2Array([Vector2(10,2),Vector2(7,5),Vector2(8,9),Vector2(12,11)]),ink,1.5,true)
	elif kind=="focus":
		var radius := 10+3*reveal
		draw_line(Vector2(-radius,0),Vector2(radius,0),ink,2,true)
		draw_line(Vector2(0,-radius),Vector2(0,radius),ink,2,true)
	elif kind=="tension":
		for i in range(3):
			var x := float(i)*9
			draw_polyline(PackedVector2Array([Vector2(x,-14),Vector2(x-2,7*reveal),Vector2(x+1,15*reveal)]),ink,1.8,true)
	elif kind=="relief":
		var x := phase*12
		draw_polyline(PackedVector2Array([Vector2(x,1),Vector2(x+8,-5),Vector2(x+17,-2),Vector2(x+19,5)]),ink,1.8,true)
