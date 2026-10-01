extends Node2D
## Authored scenery selection. Not every beat needs an illustration reveal.
var kind := "paper"
func set_kind(value: String) -> void:
	if value!=kind:
		kind=value
		queue_redraw()
func ink(points: Array, color: Color=Color("#b6aa98"), width: float=2.0) -> void:
	var packed := PackedVector2Array()
	for p in points: packed.append(Vector2(p[0],p[1]))
	draw_polyline(packed,color,width,true)
func _draw() -> void:
	var paper := Color("#faf6ed")
	if kind=="thought": paper=Color("#ede8f0")
	elif kind=="evening": paper=Color("#e6e8ec")
	draw_rect(Rect2(-3000,-3000,8000,8000),paper)
	if kind in ["room","evening","studio_nemi","studio_adb"]:
		draw_colored_polygon(PackedVector2Array([Vector2(0,894),Vector2(1920,886),Vector2(1920,1400),Vector2(0,1400)]),Color("#efe5d3" if kind=="room" else "#d6d6db"))
		ink([[0,894],[815,890],[1920,886]])
		ink([[1190,220],[1540,217],[1544,465],[1187,470],[1190,220]])
		ink([[1365,220],[1364,466]])
		ink([[1190,346],[1542,342]])
		draw_colored_polygon(PackedVector2Array([Vector2(1196,226),Vector2(1534,224),Vector2(1537,458),Vector2(1195,463)]),Color("#dce6df" if kind=="room" else "#bdc8d8"))
		ink([[1365,228],[1364,458]])
		ink([[1197,346],[1535,342]])
		ink([[171,284],[392,280],[395,443],[170,445],[171,284]])
		ink([[206,406],[235,350],[278,379],[329,321],[359,404]])
		if kind=="studio_nemi":
			ink([[160,510],[385,506],[383,678],[166,684],[160,510]],Color("#bc9aa6"))
			ink([[205,569],[244,613],[284,548],[333,604]],Color("#bc9aa6"),3)
		elif kind=="studio_adb":
			ink([[165,518],[389,519],[388,656],[163,657],[165,518]],Color("#94a4ab"))
			ink([[188,585],[226,586],[246,552],[289,617],[319,582],[366,583]],Color("#94a4ab"),3)
	elif kind=="thought":
		ink([[170,160],[1744,155],[1748,910],[166,915],[170,160]],Color("#b8a7c0"),3)
		for x in [260,1690]:
			ink([[x,126],[x+4,181]],Color("#b8a7c0"),7)
