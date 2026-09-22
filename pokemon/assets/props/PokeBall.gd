class_name PokeBall
extends "res://pokemon/scripts/PokemonBaseProp.gd"

## Reusable Illustrated Poké Ball Prop
## Native 2D hand-drawn vector art with red top, white bottom, center latch, and opening capability.

var ball_radius: float = 16.0
var open_gap: float = 0.0: # 0.0 = closed, >0 = open halves
	set(val):
		open_gap = val
		queue_redraw()

var is_captured_shaking: bool = false

func _draw() -> void:
	var ink_col := Color("#262224")
	var red_col := Color("#d9383a")
	var white_col := Color("#fbf8f3")
	var shadow_col := Color(0.15, 0.15, 0.15, 0.18)
	
	# Top Half (Red Dome)
	var top_c := Curve2D.new()
	var ty := -open_gap
	top_c.add_point(Vector2(-ball_radius, ty), Vector2(0, 0), Vector2(0, -ball_radius * 1.3))
	top_c.add_point(Vector2(0, ty - ball_radius), Vector2(-ball_radius * 0.7, 0), Vector2(ball_radius * 0.7, 0))
	top_c.add_point(Vector2(ball_radius, ty), Vector2(0, -ball_radius * 1.3), Vector2(0, 0))
	top_c.add_point(Vector2(-ball_radius, ty), Vector2(0, 0), Vector2(0, 0))
	var top_poly := top_c.tessellate(4, 2.0)
	draw_colored_polygon(top_poly, red_col)
	
	# Top specular highlight
	draw_circle(Vector2(-ball_radius * 0.35, ty - ball_radius * 0.45), ball_radius * 0.22, Color(1, 1, 1, 0.65))
	
	draw_polyline(top_poly, ink_col, 2.8, true)
	
	# Bottom Half (White Dome)
	var bot_c := Curve2D.new()
	var by := open_gap
	bot_c.add_point(Vector2(-ball_radius, by), Vector2(0, 0), Vector2(0, ball_radius * 1.3))
	bot_c.add_point(Vector2(0, by + ball_radius), Vector2(-ball_radius * 0.7, 0), Vector2(ball_radius * 0.7, 0))
	bot_c.add_point(Vector2(ball_radius, by), Vector2(0, ball_radius * 1.3), Vector2(0, 0))
	bot_c.add_point(Vector2(-ball_radius, by), Vector2(0, 0), Vector2(0, 0))
	var bot_poly := bot_c.tessellate(4, 2.0)
	draw_colored_polygon(bot_poly, white_col)
	
	# Bottom shadow
	var bot_shadow := PackedVector2Array([
		Vector2(-ball_radius * 0.7, by + ball_radius * 0.7),
		Vector2(0, by + ball_radius),
		Vector2(ball_radius * 0.7, by + ball_radius * 0.7),
		Vector2(0, by + ball_radius * 0.4)
	])
	draw_colored_polygon(bot_shadow, shadow_col)
	
	draw_polyline(bot_poly, ink_col, 2.8, true)
	
	# Center Equator Band & Button (When closed)
	if open_gap < 1.0:
		draw_line(Vector2(-ball_radius, 0), Vector2(ball_radius, 0), ink_col, 3.2)
		
		# Center latch button
		draw_circle(Vector2.ZERO, 5.5, ink_col)
		draw_circle(Vector2.ZERO, 3.8, white_col)
		draw_circle(Vector2.ZERO, 2.0, Color("#ffffff"))
		draw_arc(Vector2.ZERO, 5.5, 0, TAU, 20, ink_col, 1.2, true)

func open_ball(duration: float = 0.25) -> void:
	var tw := create_tween()
	tw.tween_property(self, "open_gap", 8.0, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func close_ball(duration: float = 0.2) -> void:
	var tw := create_tween()
	tw.tween_property(self, "open_gap", 0.0, duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
