class_name PropChicken
extends "res://nemi/world/props/NemiProp.gd"

## Illustrated Chicken Prop (The Permafrost Disaster)
## Rock-solid frozen chicken block on a kitchen plate, with frost spikes and cold vapor.
## State "frozen": Indestructible Arctic block.
## State "defrost_fail": Half-rubbery burnt mutant corner, center frozen ice.

const FROST_COLOR: Color = Color("#d8eaf5")
const CHICKEN_PINK: Color = Color("#f4c2b8")
const RUBBER_BURNT: Color = Color("#b87858")
const ICE_BLUE: Color = Color("#aed4eb")
const PLATE_COLOR: Color = Color("#f7f5f0")

func _init() -> void:
	prop_name = "chicken"
	current_state = "frozen"

func _draw() -> void:
	var w := 54.0
	var h := 32.0
	
	# 1. Contact shadow
	_draw_shadow_ellipse(Vector2(0, h * 0.5 + 8), w * 0.65, 7.0, Color(0.17, 0.15, 0.14, 0.14))
	
	# 2. Ceramic kitchen plate
	var plate_pts := PackedVector2Array()
	var steps := 22
	for i in range(steps + 1):
		var ang := (float(i) / float(steps)) * TAU
		plate_pts.append(Vector2(cos(ang) * (w * 0.75), sin(ang) * 9.0 + 4.0))
	draw_colored_polygon(plate_pts, PLATE_COLOR)
	draw_polyline(plate_pts, Color("#2b2623"), 2.8)
	
	# 3. Chicken block silhouette
	var block_pts: PackedVector2Array = [
		Vector2(-w * 0.45, -h * 0.4),
		Vector2(w * 0.35, -h * 0.45),
		Vector2(w * 0.48, h * 0.1),
		Vector2(w * 0.32, h * 0.35),
		Vector2(-w * 0.38, h * 0.32),
		Vector2(-w * 0.50, -0.05)
	]
	
	var base_fill = CHICKEN_PINK if current_state == "frozen" else RUBBER_BURNT
	draw_colored_polygon(block_pts, base_fill)
	draw_polyline(block_pts, Color("#2b2623"), 3.2, true)
	
	# 4. State details
	if current_state == "frozen":
		# Ice permafrost overlay & crystal shards
		var ice_cap: PackedVector2Array = [
			Vector2(-w * 0.42, -h * 0.38),
			Vector2(w * 0.32, -h * 0.42),
			Vector2(w * 0.20, -h * 0.05),
			Vector2(-w * 0.15, -h * 0.02),
			Vector2(-w * 0.35, -h * 0.10)
		]
		draw_colored_polygon(ice_cap, FROST_COLOR)
		
		# Sharp ice cracks & gleams
		draw_polyline([Vector2(-12, -8), Vector2(-2, 2), Vector2(10, -5)], ICE_BLUE, 2.0)
		draw_polyline([Vector2(-4, -12), Vector2(4, -8), Vector2(8, 5)], ICE_BLUE, 2.0)
		
		# Star glint on frozen permafrost
		draw_line(Vector2(-15, -15), Vector2(-15, -9), Color.WHITE, 2.0)
		draw_line(Vector2(-18, -12), Vector2(-12, -12), Color.WHITE, 2.0)
		
	elif current_state == "defrost_fail":
		# Melted / rubbery burnt left corner
		var burnt_corner: PackedVector2Array = [
			Vector2(-w * 0.48, -h * 0.42),
			Vector2(-w * 0.15, -h * 0.4),
			Vector2(-w * 0.2, h * 0.15),
			Vector2(-w * 0.50, -0.05)
		]
		draw_colored_polygon(burnt_corner, Color("#8c4d32"))
		draw_polyline(burnt_corner, Color("#3a1d12"), 2.2)
		
		# Steam curls rising from burnt side
		draw_polyline([Vector2(-18, -15), Vector2(-22, -25), Vector2(-18, -32)], Color("#887c78"), 1.8)
		
		# Center still ice permafrost
		draw_circle(Vector2(12, -2), 10.0, ICE_BLUE)
		draw_line(Vector2(6, -6), Vector2(18, 2), Color.WHITE, 2.0)

func _draw_shadow_ellipse(pos: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var count := 18
	for i in range(count):
		var th := (float(i) / float(count)) * TAU
		pts.append(pos + Vector2(cos(th) * rx, sin(th) * ry))
	draw_colored_polygon(pts, col)
