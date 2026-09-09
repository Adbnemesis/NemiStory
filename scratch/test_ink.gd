extends SceneTree

func _init():
	var S = load("res://characters/nemi/drawing/InkStroke.gd")
	print("S is: ", S)
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(10, 10)])
	var s = S.from_points(pts)
	print("s is: ", s)
	quit(0)
