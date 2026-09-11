class_name PropCarEnvironment
extends Node2D

## Illustrated Car Environment with Rolling Window & Mail Carrier for Beat 4
## Shows:
## - Car frame & steering wheel
## - Rolling car window (drops down smoothly)
## - Mail carrier doodle appearing outside with mail bag and comedic shock lines

var window_y: float = -40.0 # -40 = rolled up, +40 = rolled down
var mail_carrier_visible: bool = false
var mail_carrier_shocked: bool = false

func _ready() -> void:
	z_index = 10

func roll_down_window(duration: float = 1.2) -> Signal:
	mail_carrier_visible = true
	var tw := create_tween()
	tw.tween_property(self, "window_y", 45.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	return tw.finished

func shock_mail_carrier() -> void:
	mail_carrier_shocked = true
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var ink_col := Color("#2b111e")
	var car_tint := Color(0.92, 0.90, 0.86, 0.8)
	var window_glass := Color(0.85, 0.92, 0.96, 0.45)
	
	# 1. MAIL CARRIER (drawn outside the window behind door frame)
	if mail_carrier_visible:
		var mc_x: float = -180.0
		var mc_y: float = -10.0
		
		# Mail Carrier Head & Cap
		draw_circle(Vector2(mc_x, mc_y - 45), 16.0, Color.WHITE)
		draw_arc(Vector2(mc_x, mc_y - 45), 16.0, 0, TAU, 24, ink_col, 2.2)
		
		# Postman visor cap
		draw_line(Vector2(mc_x - 16, mc_y - 52), Vector2(mc_x + 22, mc_y - 48), ink_col, 3.0)
		draw_polygon(PackedVector2Array([
			Vector2(mc_x - 14, mc_y - 52), Vector2(mc_x + 14, mc_y - 52),
			Vector2(mc_x + 10, mc_y - 62), Vector2(mc_x - 10, mc_y - 62)
		]), [Color("#354b66")])
		
		# Mail carrier eyes
		if mail_carrier_shocked:
			# Wide horrified shock eyes
			draw_circle(Vector2(mc_x - 6, mc_y - 45), 4.5, Color.WHITE)
			draw_arc(Vector2(mc_x - 6, mc_y - 45), 4.5, 0, TAU, 12, ink_col, 1.8)
			draw_circle(Vector2(mc_x + 6, mc_y - 45), 4.5, Color.WHITE)
			draw_arc(Vector2(mc_x + 6, mc_y - 45), 4.5, 0, TAU, 12, ink_col, 1.8)
			# Small pinpoint pupils
			draw_circle(Vector2(mc_x - 5, mc_y - 45), 1.2, ink_col)
			draw_circle(Vector2(mc_x + 7, mc_y - 45), 1.2, ink_col)
			# Open shocked 'O' mouth
			draw_arc(Vector2(mc_x, mc_y - 35), 4.0, 0, TAU, 12, ink_col, 2.0)
			
			# Comedic shock lines / vibration marks
			draw_string(ThemeDB.fallback_font, Vector2(mc_x - 25, mc_y - 75), "?!?", HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color("#a83232"))
			draw_line(Vector2(mc_x - 22, mc_y - 55), Vector2(mc_x - 30, mc_y - 62), Color("#a83232"), 2.0)
			draw_line(Vector2(mc_x + 22, mc_y - 55), Vector2(mc_x + 30, mc_y - 62), Color("#a83232"), 2.0)
		else:
			# Normal neutral eyes
			draw_circle(Vector2(mc_x - 5, mc_y - 45), 2.0, ink_col)
			draw_circle(Vector2(mc_x + 5, mc_y - 45), 2.0, ink_col)
			draw_line(Vector2(mc_x - 4, mc_y - 36), Vector2(mc_x + 4, mc_y - 36), ink_col, 1.8)
			
		# Mail carrier torso & blue uniform
		draw_line(Vector2(mc_x, mc_y - 29), Vector2(mc_x, mc_y + 40), ink_col, 2.5)
		# Mail bag strap across chest
		draw_line(Vector2(mc_x - 18, mc_y - 20), Vector2(mc_x + 18, mc_y + 30), Color("#7a5230"), 3.5)
		# Mail bag on hip
		draw_rect(Rect2(Vector2(mc_x + 8, mc_y + 15), Vector2(30, 35)), Color("#8c5e37"))
		draw_rect(Rect2(Vector2(mc_x + 8, mc_y + 15), Vector2(30, 35)), ink_col, false, 2.0)
	
	# 2. CAR WINDOW & DOOR FRAME
	# Window opening cut-out
	var window_rect := Rect2(Vector2(-260, -90), Vector2(160, 140))
	
	# Glass plane (moves down as window rolls down)
	var glass_top := clampf(window_y, -90.0, 50.0)
	if glass_top < 45.0:
		var glass_rect := Rect2(Vector2(-258, glass_top), Vector2(156, 50.0 - glass_top))
		draw_rect(glass_rect, window_glass)
		draw_line(Vector2(-258, glass_top), Vector2(-102, glass_top), Color(0.9, 0.95, 1.0, 0.8), 2.0)
	
	# Window Frame outline
	draw_rect(window_rect, ink_col, false, 3.5)
	
	# Lower Car Door Panel
	var door_rect := Rect2(Vector2(-280, 50), Vector2(200, 160))
	draw_rect(door_rect, car_tint)
	draw_line(Vector2(-280, 50), Vector2(-80, 50), ink_col, 3.0)
	
	# Car roof frame line
	draw_line(Vector2(-280, -90), Vector2(-80, -90), ink_col, 3.0)
	draw_line(Vector2(-80, -90), Vector2(-40, 50), ink_col, 3.0)
