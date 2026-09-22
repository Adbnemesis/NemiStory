class_name PropShopCounter
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Corner Shop Counter & Shopkeeper Prop
## Wooden convenience store counter with background shelves, brass service bell,
## and a friendly hand-drawn shopkeeper who looks at Neeko and nods in acceptance.

var bell_offset_y: float = 0.0
var shopkeeper_nod_y: float = 0.0
var shopkeeper_blink: bool = false
var show_shopkeeper: bool = true

func _init() -> void:
	prop_name = "shop_counter"
	current_state = "normal"

func ring_bell() -> void:
	var tw := create_tween()
	tw.tween_property(self, "bell_offset_y", -4.0, 0.06).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(self, "bell_offset_y", 0.0, 0.08).set_trans(Tween.TRANS_BOUNCE)

## Shopkeeper nods in approval / agreement
func nod_shopkeeper(duration: float = 0.6) -> void:
	var tw := create_tween()
	tw.tween_property(self, "shopkeeper_nod_y", 6.0, duration * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "shopkeeper_nod_y", 0.0, duration * 0.45).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func blink_shopkeeper() -> void:
	shopkeeper_blink = true
	queue_redraw()
	get_tree().create_timer(0.12).timeout.connect(func():
		shopkeeper_blink = false
		queue_redraw()
	)

func _draw() -> void:
	var w := 170.0
	var h := 74.0
	
	# -------------------------------------------------------------------------
	# 1. BACKGROUND SHELVES (Behind shopkeeper)
	# -------------------------------------------------------------------------
	var shelf_w := w * 0.85
	var shelf_y := -h * 0.9
	
	# Shelf wooden plank
	var shelf_pts := PackedVector2Array([
		Vector2(-shelf_w * 0.5, shelf_y),
		Vector2(shelf_w * 0.5, shelf_y),
		Vector2(shelf_w * 0.5, shelf_y + 6.0),
		Vector2(-shelf_w * 0.5, shelf_y + 6.0)
	])
	draw_illustrated_polygon(shelf_pts, Color("#c4a682"), 1.6)
	
	# Jars and boxes on shelf
	var jar_colors := [Color("#e8c599"), Color("#a8d5ba"), Color("#d4a5a5"), Color("#c9d6ea")]
	for i in range(4):
		var jx := -shelf_w * 0.38 + float(i) * (shelf_w * 0.25)
		var j_rect := Rect2(jx - 7.0, shelf_y - 18.0, 14.0, 18.0)
		draw_illustrated_polygon(PackedVector2Array([
			Vector2(j_rect.position.x, j_rect.end.y),
			Vector2(j_rect.position.x, j_rect.position.y),
			Vector2(j_rect.end.x, j_rect.position.y),
			Vector2(j_rect.end.x, j_rect.end.y)
		]), jar_colors[i], 1.4)
		# Jar lid
		draw_rect(Rect2(jx - 5.0, shelf_y - 21.0, 10.0, 3.0), Color("#2b2623"))
		
	# -------------------------------------------------------------------------
	# 2. SHOPKEEPER (Behind counter, standing left-of-center)
	# -------------------------------------------------------------------------
	if show_shopkeeper:
		var sk_pos := Vector2(-w * 0.12, -h * 0.42 + shopkeeper_nod_y)
		
		# Torso / Apron (navy blue apron over beige collared shirt)
		var body_pts := PackedVector2Array([
			sk_pos + Vector2(-18.0, 0.0),
			sk_pos + Vector2(-15.0, -32.0),
			sk_pos + Vector2(15.0, -32.0),
			sk_pos + Vector2(18.0, 0.0)
		])
		draw_illustrated_polygon(body_pts, Color("#3a4c5a"), 2.0) # Navy apron
		
		# White shirt collar
		var collar_pts := PackedVector2Array([
			sk_pos + Vector2(-7.0, -32.0),
			sk_pos + Vector2(0.0, -26.0),
			sk_pos + Vector2(7.0, -32.0)
		])
		draw_colored_polygon(collar_pts, Color("#fbf8f3"))
		draw_ink_line(collar_pts, 1.4)
		
		# Head (warm skin tone)
		var head_center := sk_pos + Vector2(0.0, -44.0)
		_draw_shadow_ellipse(head_center, 13.0, 15.0, Color("#f4dbcb"))
		draw_arc(head_center, 14.0, 0, TAU, 18, Color("#2b2623"), 1.8)
		
		# Bald head fringe / hair on sides
		draw_arc(head_center + Vector2(-12.0, 2.0), 4.0, -PI*0.5, PI*0.5, 8, Color("#4a4542"), 2.4)
		draw_arc(head_center + Vector2(12.0, 2.0), 4.0, PI*0.5, PI*1.5, 8, Color("#4a4542"), 2.4)
		
		# Friendly mustache & nose
		draw_circle(head_center + Vector2(0.0, 0.0), 2.2, Color("#e8bca6"))
		var stache := PackedVector2Array([
			head_center + Vector2(-8.0, 5.0),
			head_center + Vector2(0.0, 3.0),
			head_center + Vector2(8.0, 5.0)
		])
		draw_ink_line(stache, 2.2)
		
		# Eyes (looking warmly down-right toward Neeko)
		if shopkeeper_blink:
			draw_line(head_center + Vector2(-7.0, -3.0), head_center + Vector2(-2.0, -3.0), Color("#2b2623"), 1.6)
			draw_line(head_center + Vector2(3.0, -3.0), head_center + Vector2(8.0, -3.0), Color("#2b2623"), 1.6)
		else:
			# Crescent gentle smiling eyes looking right
			draw_arc(head_center + Vector2(-4.5, -4.0), 3.0, PI*1.1, PI*1.9, 8, Color("#2b2623"), 1.8)
			draw_arc(head_center + Vector2(5.5, -4.0), 3.0, PI*1.1, PI*1.9, 8, Color("#2b2623"), 1.8)
			
	# -------------------------------------------------------------------------
	# 3. COUNTER FOREGROUND (Wood front, seams, countertop, bell)
	# -------------------------------------------------------------------------
	# Counter shadow
	_draw_shadow_ellipse(Vector2(0, h * 0.5 + 4), w * 0.52, 10.0, Color(0.17, 0.15, 0.14, 0.12))
	
	# Main counter front panel (wood finish)
	var front_pts := PackedVector2Array([
		Vector2(-w * 0.5, -h * 0.3),
		Vector2(w * 0.5, -h * 0.3),
		Vector2(w * 0.48, h * 0.5),
		Vector2(-w * 0.48, h * 0.5)
	])
	draw_illustrated_polygon(front_pts, Color("#d6b28d"), 2.4)
	
	# Wooden vertical plank seams
	for x_off in [-w * 0.25, 0.0, w * 0.25]:
		draw_ink_line(PackedVector2Array([
			Vector2(x_off, -h * 0.3),
			Vector2(x_off * 0.96, h * 0.5)
		]), 1.4)
	
	# Countertop polished surface
	var top_pts := PackedVector2Array([
		Vector2(-w * 0.54, -h * 0.3),
		Vector2(-w * 0.48, -h * 0.5),
		Vector2(w * 0.48, -h * 0.5),
		Vector2(w * 0.54, -h * 0.3)
	])
	draw_illustrated_polygon(top_pts, Color("#e6c8a8"), 2.4)
	
	# Brass Counter Bell (placed on left side of counter)
	var bell_pos := Vector2(-w * 0.36, -h * 0.45 + bell_offset_y)
	# Bell base
	_draw_shadow_ellipse(bell_pos + Vector2(0, 3), 10.0, 3.5, Color("#2b2623"))
	# Bell dome (golden brass)
	var dome_pts := PackedVector2Array()
	var steps := 16
	for i in range(steps + 1):
		var ang := PI + (float(i) / float(steps)) * PI
		dome_pts.append(bell_pos + Vector2(cos(ang) * 8.0, sin(ang) * 6.0))
	draw_illustrated_polygon(dome_pts, Color("#e5b342"), 1.8)
	# Bell top tapper button
	draw_line(bell_pos + Vector2(0, -6), bell_pos + Vector2(0, -10), Color("#2b2623"), 2.2)
	draw_circle(bell_pos + Vector2(0, -10), 2.5, Color("#e5b342"))
	draw_arc(bell_pos + Vector2(0, -10), 2.5, 0, TAU, 10, Color("#2b2623"), 1.4)

func _draw_shadow_ellipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var count := 18
	for i in range(count):
		var th := (float(i) / float(count)) * TAU
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)
