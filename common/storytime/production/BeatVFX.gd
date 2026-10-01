extends Node2D
## Short authored accents sampled by the scene clock. No timers/random jitter.
var kind := "realization"
var author := "nemi"
var phase := 0.0
func sample(value: float) -> void:
	phase=clampf(value,0,1)
	queue_redraw()
func _draw() -> void:
	if phase<=0 or phase>=1: return
	var ink := Color("#ad5e69" if author=="nemi" else "#8a6245")
	var reveal := clampf(phase/0.22,0,1)
	var settle := clampf((1-phase)/0.25,0,1)
	ink.a=settle
	if kind in ["realization","impact"]:
		for i in range(3):
			var angle := -0.95+float(i)*0.5
			var from := Vector2(30,0).rotated(angle)
			var to := Vector2(30+24*reveal,0).rotated(angle)
			draw_line(from,to,ink,2.8,true)
	elif kind=="sweat":
		var y := 9*phase
		var pts := PackedVector2Array([Vector2(0,-15+y),Vector2(-7,0+y),Vector2(-3,7+y),Vector2(5,6+y),Vector2(8,0+y),Vector2(0,-15+y)])
		draw_polyline(pts,ink,2,true)
	elif kind=="focus":
		var radius := 10+3*reveal
		draw_line(Vector2(-radius,0),Vector2(radius,0),ink,2,true)
		draw_line(Vector2(0,-radius),Vector2(0,radius),ink,2,true)
