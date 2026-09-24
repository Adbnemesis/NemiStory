class_name HumanProps
extends Node2D

## HumanProps - Dedicated Hand-Drawn Storytime Props Library
## Props authored with Nemi's exact pen-and-ink linework DNA (#3E081E).
## Enforces:
## - Organic hand-drawn contours (not corporate SVGs or math rectangles)
## - Scene-specific personality and subtle asymmetries
## - Full cause-and-effect lifecycles (notice -> pick up -> inspect -> react)
## - Dynamic bone attachment for character hands

const InkStroke = preload("res://nemi/characters/nemi/drawing/InkStroke.gd")

# =========================================================================
# =========================================================================
# 1. STORYTIME SMARTPHONE PROP
# =========================================================================
class StoryPhone extends Node2D:
	enum ScreenState { SCREEN_OFF, BLANK_ON, ANALYTICS_NOTIF, VIEWS_RECAP, INSTAGRAM }
	
	var screen_state: ScreenState = ScreenState.VIEWS_RECAP
	var phone_color: Color = Color("#24171f") # Sleek dark chassis
	var edge_color: Color = Color("#4a3542")  # Subtle edge highlight
	var ink_color: Color = Color("#3e081e")   # Master burgundy inking
	var screen_glow: Color = Color("#fffdf8") # Warm bright paper screen glow
	var screen_off_col: Color = Color("#3a2a32")
	
	var is_held: bool = false
	var target_parent: Node2D = null
	var hold_offset: Vector2 = Vector2.ZERO
	var hold_rotation: float = 0.0
	var use_world_rotation: bool = true

	func _ready() -> void:
		z_index = 28 # In front of character torso & hands
		visible = false # Never clutters desk by default; only visible when in use!
		queue_redraw()

	func _process(_delta: float) -> void:
		if is_held and target_parent and is_instance_valid(target_parent):
			if use_world_rotation:
				global_position = target_parent.global_position + hold_offset
				global_rotation = hold_rotation
			else:
				global_position = target_parent.global_position + hold_offset.rotated(target_parent.global_rotation)
				global_rotation = target_parent.global_rotation + hold_rotation

	func attach_to_hand(hand_node: Node2D, offset: Vector2 = Vector2(0, -12), rot: float = 0.0) -> void:
		target_parent = hand_node
		hold_offset = offset
		hold_rotation = rot
		is_held = true
		visible = true
		if is_instance_valid(target_parent):
			if use_world_rotation:
				global_position = target_parent.global_position + hold_offset
				global_rotation = hold_rotation
			else:
				global_position = target_parent.global_position + hold_offset.rotated(target_parent.global_rotation)
				global_rotation = target_parent.global_rotation + hold_rotation
		queue_redraw()

	func detach() -> void:
		is_held = false
		target_parent = null

	func show_in_hand(hand_node: Node2D, state: ScreenState, offset: Vector2 = Vector2(4, -14), rot: float = deg_to_rad(5.0)) -> void:
		screen_state = state
		visible = true
		attach_to_hand(hand_node, offset, rot)
		queue_redraw()

	func stow_away() -> void:
		is_held = false
		target_parent = null
		visible = false
		queue_redraw()

	func set_screen(state: ScreenState) -> void:
		screen_state = state
		queue_redraw()

	func _draw() -> void:
		var pw := 46.0 # Width
		var ph := 82.0 # Height
		var corner_r := 9.0
		
		# 1. Outer Chassis: Hand-drawn rounded polygon with subtle organic asymmetry
		var body_pts := _generate_organic_rounded_rect(Vector2(-pw * 0.5, -ph * 0.5), Vector2(pw, ph), corner_r, 0.3)
		draw_colored_polygon(body_pts, phone_color)
		
		# Calligraphic outer ink contour
		var body_loop := body_pts.duplicate()
		body_loop.append(body_pts[0])
		var outer_stroke := InkStroke.from_points(body_loop, 3.4, InkStroke.Profile.UNIFORM, ink_color)
		outer_stroke.draw_to(self)
		
		# 2. Screen: Inset organic rectangle (Always warm & bright when active!)
		var sw := pw - 8.0
		var sh := ph - 14.0
		var screen_rect_pos := Vector2(-sw * 0.5, -sh * 0.5 + 1.0)
		var screen_pts := _generate_organic_rounded_rect(screen_rect_pos, Vector2(sw, sh), 5.0, 0.2)
		var s_col: Color = screen_glow if screen_state != ScreenState.SCREEN_OFF else screen_off_col
		draw_colored_polygon(screen_pts, s_col)
		
		var screen_loop := screen_pts.duplicate()
		screen_loop.append(screen_pts[0])
		var screen_stroke := InkStroke.from_points(screen_loop, 1.8, InkStroke.Profile.UNIFORM, ink_color)
		screen_stroke.draw_to(self)
		
		# 3. Speaker slit and front camera dot
		var notch_y := -ph * 0.5 + 4.5
		var speaker_pts := PackedVector2Array([Vector2(-5.0, notch_y), Vector2(5.0, notch_y)])
		var speaker_stroke := InkStroke.from_points(speaker_pts, 1.6, InkStroke.Profile.TAPER_BOTH, ink_color)
		speaker_stroke.draw_to(self)
		draw_circle(Vector2(11.0, notch_y), 1.2, ink_color)
		
		# 4. Screen Content Graphics based on state
		match screen_state:
			ScreenState.ANALYTICS_NOTIF:
				_draw_analytics_screen(sw, sh)
			ScreenState.VIEWS_RECAP:
				_draw_views_recap_screen(sw, sh)
			ScreenState.INSTAGRAM:
				_draw_instagram_screen(sw, sh)
			ScreenState.BLANK_ON:
				pass
			ScreenState.SCREEN_OFF:
				pass
		
		# 5. Home bar indicator
		var home_y := ph * 0.5 - 4.5
		var home_pts := PackedVector2Array([Vector2(-8.0, home_y), Vector2(8.0, home_y)])
		var home_stroke := InkStroke.from_points(home_pts, 1.8, InkStroke.Profile.TAPER_BOTH, ink_color)
		home_stroke.draw_to(self)

	func _draw_analytics_screen(sw: float, sh: float) -> void:
		# Mini hand-inked notification card
		var card_w := sw - 4.0
		var card_h := 18.0
		var card_pos := Vector2(-card_w * 0.5, -sh * 0.5 + 6.0)
		var card_pts := _generate_organic_rounded_rect(card_pos, Vector2(card_w, card_h), 3.0, 0.1)
		draw_colored_polygon(card_pts, Color("#fdf0f2")) # Soft pastel pink notification
		
		var card_stroke := InkStroke.from_points(card_pts, 1.4, InkStroke.Profile.UNIFORM, ink_color)
		card_stroke.draw_to(self)
		
		# Bell icon dot (coral red)
		draw_circle(Vector2(-card_w * 0.5 + 5.0, card_pos.y + 6.0), 2.4, Color("#d9485e"))
		
		# Notif header line
		var line1 := PackedVector2Array([Vector2(-card_w * 0.5 + 10.0, card_pos.y + 5.0), Vector2(card_w * 0.5 - 4.0, card_pos.y + 5.0)])
		var strk1 := InkStroke.from_points(line1, 1.4, InkStroke.Profile.TAPER_END, ink_color)
		strk1.draw_to(self)
		
		# Notif sub-line
		var line2 := PackedVector2Array([Vector2(-card_w * 0.5 + 10.0, card_pos.y + 11.0), Vector2(card_w * 0.5 - 8.0, card_pos.y + 11.0)])
		var strk2 := InkStroke.from_points(line2, 1.2, InkStroke.Profile.TAPER_END, Color("#6d4f58"))
		strk2.draw_to(self)
		
		# Mini climbing graph line below notif
		var graph_base_y := 12.0
		var graph_pts := PackedVector2Array([
			Vector2(-sw * 0.38, graph_base_y + 12.0),
			Vector2(-sw * 0.15, graph_base_y + 9.0),
			Vector2(0.0, graph_base_y + 10.0),
			Vector2(sw * 0.18, graph_base_y + 3.0),
			Vector2(sw * 0.38, graph_base_y - 8.0) # Sharp spike up!
		])
		var graph_stroke := InkStroke.from_points(graph_pts, 2.2, InkStroke.Profile.TAPER_END, Color("#d9485e"))
		graph_stroke.draw_to(self)
		
		# Mini arrow head on graph spike
		var arrow_tip := graph_pts[-1]
		var barb := PackedVector2Array([arrow_tip + Vector2(-4.0, 1.0), arrow_tip, arrow_tip + Vector2(-1.0, 4.0)])
		var barb_stroke := InkStroke.from_points(barb, 1.6, InkStroke.Profile.UNIFORM, Color("#d9485e"))
		barb_stroke.draw_to(self)

	func _draw_views_recap_screen(sw: float, sh: float) -> void:
		# 1. Distinctive Red YouTube Top Header Bar
		var header_h := 15.0
		var header_pts := PackedVector2Array([
			Vector2(-sw * 0.5, -sh * 0.5 + 2.0), Vector2(sw * 0.5, -sh * 0.5 + 2.0),
			Vector2(sw * 0.5, -sh * 0.5 + 2.0 + header_h), Vector2(-sw * 0.5, -sh * 0.5 + 2.0 + header_h)
		])
		draw_colored_polygon(header_pts, Color("#e62117")) # YouTube Red
		
		# YouTube white play icon triangle
		var play_cx := -sw * 0.28
		var play_cy := -sh * 0.5 + 2.0 + header_h * 0.5
		var play_pts := PackedVector2Array([
			Vector2(play_cx - 4.0, play_cy - 4.5),
			Vector2(play_cx - 4.0, play_cy + 4.5),
			Vector2(play_cx + 4.5, play_cy)
		])
		draw_colored_polygon(play_pts, Color("#ffffff"))
		
		# Hand-drawn mini "Studio" header text bar
		var h_line := PackedVector2Array([Vector2(play_cx + 8.0, play_cy), Vector2(sw * 0.38, play_cy)])
		var strk_h := InkStroke.from_points(h_line, 1.6, InkStroke.Profile.TAPER_END, Color("#ffffff"))
		strk_h.draw_to(self)
		
		# 2. Video thumbnail box in middle
		var thumb_w := sw - 6.0
		var thumb_h := 20.0
		var thumb_y := -18.0
		var thumb_pts := PackedVector2Array([
			Vector2(-thumb_w * 0.5, thumb_y), Vector2(thumb_w * 0.5, thumb_y),
			Vector2(thumb_w * 0.5, thumb_y + thumb_h), Vector2(-thumb_w * 0.5, thumb_y + thumb_h)
		])
		draw_colored_polygon(thumb_pts, Color("#f2e9ea")) # Soft preview frame
		var thumb_stroke := InkStroke.from_points(thumb_pts, 1.2, InkStroke.Profile.UNIFORM, ink_color)
		thumb_stroke.draw_to(self)
		
		# Red progress scrubber on thumbnail
		var scrub := PackedVector2Array([Vector2(-thumb_w * 0.5, thumb_y + thumb_h - 1.5), Vector2(-thumb_w * 0.1, thumb_y + thumb_h - 1.5)])
		var scrub_s := InkStroke.from_points(scrub, 1.8, InkStroke.Profile.UNIFORM, Color("#e62117"))
		scrub_s.draw_to(self)
		
		# 3. Bold, crisp "7 VIEWS" label below thumbnail
		var cy := 12.0
		# Little eye / views icon
		draw_circle(Vector2(-12.0, cy - 2.0), 3.2, Color("#d9485e"))
		draw_circle(Vector2(-12.0, cy - 2.0), 1.4, Color("#ffffff"))
		
		# Hand-drawn "7"
		var seven_pts := PackedVector2Array([
			Vector2(-3.0, cy - 8.0), Vector2(8.0, cy - 8.0), Vector2(2.0, cy + 6.0)
		])
		var s_stroke := InkStroke.from_points(seven_pts, 2.8, InkStroke.Profile.TAPER_END, Color("#e62117"))
		s_stroke.draw_to(self)
		
		# Mini "views" cursive hint
		var views_line := PackedVector2Array([Vector2(12.0, cy + 2.0), Vector2(sw * 0.38, cy + 2.0)])
		var strk_v := InkStroke.from_points(views_line, 1.6, InkStroke.Profile.TAPER_END, ink_color)
		strk_v.draw_to(self)
		
		# 4. Circular refresh arrows (refreshing at 2 AM!)
		var ref_y := cy + 13.0
		var ref_rad := 4.5
		var ref_pts := PackedVector2Array()
		for i in range(7):
			var a := (float(i) / 6.0) * (PI * 1.5)
			ref_pts.append(Vector2(cos(a) * ref_rad, ref_y + sin(a) * ref_rad))
		var ref_stroke := InkStroke.from_points(ref_pts, 1.4, InkStroke.Profile.TAPER_END, Color("#d9485e"))
		ref_stroke.draw_to(self)

	func _draw_instagram_screen(sw: float, sh: float) -> void:
		# 1. Instagram Sunset Gradient Header
		var header_h := 15.0
		var header_pts := PackedVector2Array([
			Vector2(-sw * 0.5, -sh * 0.5 + 2.0), Vector2(sw * 0.5, -sh * 0.5 + 2.0),
			Vector2(sw * 0.5, -sh * 0.5 + 2.0 + header_h), Vector2(-sw * 0.5, -sh * 0.5 + 2.0 + header_h)
		])
		draw_colored_polygon(header_pts, Color("#e1306c")) # Instagram Magenta/Pink
		
		# Camera glyph in header
		var cam_cx := -sw * 0.28
		var cam_cy := -sh * 0.5 + 2.0 + header_h * 0.5
		var cam_rect := PackedVector2Array([
			Vector2(cam_cx - 4.5, cam_cy - 4.0), Vector2(cam_cx + 4.5, cam_cy - 4.0),
			Vector2(cam_cx + 4.5, cam_cy + 4.0), Vector2(cam_cx - 4.5, cam_cy + 4.0)
		])
		draw_polyline(cam_rect, Color("#ffffff"), 1.2, true)
		draw_circle(Vector2(cam_cx, cam_cy), 1.6, Color("#ffffff"))
		
		# "@nemi" username line
		var user_line := PackedVector2Array([Vector2(cam_cx + 8.0, cam_cy), Vector2(sw * 0.38, cam_cy)])
		var strk_u := InkStroke.from_points(user_line, 1.5, InkStroke.Profile.TAPER_END, Color("#ffffff"))
		strk_u.draw_to(self)
		
		# 2. Profile Circle with Story Gradient Ring
		var prof_y := -10.0
		draw_circle(Vector2(-sw * 0.25, prof_y), 7.5, Color("#e1306c"))
		draw_circle(Vector2(-sw * 0.25, prof_y), 6.0, Color("#ffffff"))
		draw_circle(Vector2(-sw * 0.25, prof_y), 4.5, Color("#833ab4")) # Avatar
		
		# Profile stats lines beside avatar
		var stat1 := PackedVector2Array([Vector2(-2.0, prof_y - 3.0), Vector2(sw * 0.35, prof_y - 3.0)])
		var stat2 := PackedVector2Array([Vector2(-2.0, prof_y + 3.0), Vector2(sw * 0.25, prof_y + 3.0)])
		var s_strk1 := InkStroke.from_points(stat1, 1.4, InkStroke.Profile.TAPER_END, ink_color)
		var s_strk2 := InkStroke.from_points(stat2, 1.2, InkStroke.Profile.TAPER_END, Color("#a18b95"))
		s_strk1.draw_to(self)
		s_strk2.draw_to(self)
		
		# 3. Big bold "250" Followers
		var count_y := 12.0
		# Little follower heart
		draw_circle(Vector2(-14.0, count_y - 2.0), 3.0, Color("#e1306c"))
		
		# Hand-drawn "250"
		# '2'
		var two_pts := PackedVector2Array([
			Vector2(-6.0, count_y - 6.0), Vector2(-1.0, count_y - 8.0),
			Vector2(2.0, count_y - 4.0), Vector2(-6.0, count_y + 4.0), Vector2(3.0, count_y + 4.0)
		])
		var strk_2 := InkStroke.from_points(two_pts, 2.4, InkStroke.Profile.TAPER_END, ink_color)
		strk_2.draw_to(self)
		
		# '5'
		var five_pts := PackedVector2Array([
			Vector2(12.0, count_y - 8.0), Vector2(6.0, count_y - 8.0),
			Vector2(6.0, count_y - 2.0), Vector2(12.0, count_y), Vector2(10.0, count_y + 4.0), Vector2(5.0, count_y + 4.0)
		])
		var strk_5 := InkStroke.from_points(five_pts, 2.4, InkStroke.Profile.TAPER_END, ink_color)
		strk_5.draw_to(self)
		
		# '0'
		var zero_loop := PackedVector2Array([
			Vector2(16.0, count_y - 2.0), Vector2(19.0, count_y - 7.0),
			Vector2(22.0, count_y - 2.0), Vector2(19.0, count_y + 4.0), Vector2(16.0, count_y - 2.0)
		])
		draw_polyline(zero_loop, ink_color, 2.4, true)
		
		# Mini "followers" label line
		var fol_line := PackedVector2Array([Vector2(-10.0, count_y + 10.0), Vector2(18.0, count_y + 10.0)])
		var strk_fol := InkStroke.from_points(fol_line, 1.4, InkStroke.Profile.TAPER_BOTH, Color("#e1306c"))
		strk_fol.draw_to(self)
		
		# Tiny confetti dots
		draw_circle(Vector2(-sw * 0.32, count_y + 13.0), 1.5, Color("#f59e0b"))
		draw_circle(Vector2(sw * 0.32, count_y + 11.0), 1.8, Color("#ec4899"))
		draw_circle(Vector2(0.0, count_y + 15.0), 1.5, Color("#3b82f6"))

	func _generate_organic_rounded_rect(pos: Vector2, size: Vector2, radius: float, asymmetry: float = 0.3) -> PackedVector2Array:
		var pts := PackedVector2Array()
		var steps := 5
		var corners := [
			Vector2(pos.x + size.x - radius, pos.y + radius),          # top-right
			Vector2(pos.x + size.x - radius, pos.y + size.y - radius), # bottom-right
			Vector2(pos.x + radius, pos.y + size.y - radius),          # bottom-left
			Vector2(pos.x + radius, pos.y + radius)                   # top-left
		]
		var angles := [0.0, PI * 0.5, PI, PI * 1.5]
		
		for c in range(4):
			var center: Vector2 = corners[c]
			var start_ang: float = angles[c]
			for i in range(steps + 1):
				var a := start_ang + (float(i) / float(steps)) * (PI * 0.5)
				var dev := sin(a * 3.0 + float(c)) * asymmetry
				var r := radius + dev
				pts.append(center + Vector2(cos(a) * r, sin(a) * r))
		return pts

# =========================================================================
# 1.5. STORYTIME CERAMIC COFFEE MUG PROP
# =========================================================================
class StoryMug extends Node2D:
	var mug_fill: Color = Color("#e67a84") # Warm coral ceramic body
	var mug_ink: Color = Color("#3e081e")  # Master burgundy ink
	var coffee_col: Color = Color("#381e14") # Warm dark coffee inside
	
	var is_held: bool = false
	var target_parent: Node2D = null
	var hold_offset: Vector2 = Vector2.ZERO
	var hold_rotation: float = 0.0
	var desk_position: Vector2 = Vector2(720, 438) # Default position on desk surface
	var steam_time: float = 0.0
	var show_steam: bool = true
	
	var use_world_rotation: bool = true
	
	func _ready() -> void:
		z_index = 26 # Above desk and character torso
		position = desk_position
		queue_redraw()
		
	func _process(delta: float) -> void:
		steam_time += delta
		if is_held and target_parent and is_instance_valid(target_parent):
			if use_world_rotation:
				global_position = target_parent.global_position + hold_offset
				global_rotation = hold_rotation
			else:
				global_position = target_parent.global_position + hold_offset.rotated(target_parent.global_rotation)
				global_rotation = target_parent.global_rotation + hold_rotation
		queue_redraw()
		
	func attach_to_hand(hand_node: Node2D, offset: Vector2 = Vector2(0, -6), rot: float = deg_to_rad(-12.0)) -> void:
		target_parent = hand_node
		hold_offset = offset
		hold_rotation = rot
		is_held = true
		if is_instance_valid(target_parent):
			if use_world_rotation:
				global_position = target_parent.global_position + hold_offset
				global_rotation = hold_rotation
			else:
				global_position = target_parent.global_position + hold_offset.rotated(target_parent.global_rotation)
				global_rotation = target_parent.global_rotation + hold_rotation
		queue_redraw()
		
	func detach(target_pos: Vector2 = Vector2.ZERO) -> void:
		is_held = false
		target_parent = null
		if target_pos != Vector2.ZERO:
			position = target_pos
		else:
			position = desk_position
		rotation = 0.0
		queue_redraw()
		
	func _draw() -> void:
		var mw := 22.0
		var mh := 26.0
		
		# Mug body
		var mug_pts := PackedVector2Array([
			Vector2(-mw * 0.5, -mh),
			Vector2(mw * 0.5, -mh),
			Vector2(mw * 0.44, 0.0),
			Vector2(-mw * 0.44, 0.0)
		])
		draw_colored_polygon(mug_pts, mug_fill)
		
		# Cute mini heart doodle on front of mug
		var hx := 0.0
		var hy := -mh * 0.45
		draw_circle(Vector2(hx - 2.2, hy - 1.5), 2.2, Color("#fff5f6"))
		draw_circle(Vector2(hx + 2.2, hy - 1.5), 2.2, Color("#fff5f6"))
		var heart_tri := PackedVector2Array([
			Vector2(hx - 4.4, hy - 0.5), Vector2(hx + 4.4, hy - 0.5), Vector2(hx, hy + 4.0)
		])
		draw_colored_polygon(heart_tri, Color("#fff5f6"))
		
		# Outer ink stroke
		var mug_loop := mug_pts.duplicate()
		mug_loop.append(mug_pts[0])
		var mug_stroke := InkStroke.from_points(mug_loop, 2.2, InkStroke.Profile.UNIFORM, mug_ink)
		mug_stroke.draw_to(self)
		
		# Mug handle
		var handle_pts := PackedVector2Array([
			Vector2(mw * 0.45, -mh * 0.8),
			Vector2(mw * 0.9, -mh * 0.5),
			Vector2(mw * 0.42, -mh * 0.2)
		])
		var handle_stroke := InkStroke.from_points(handle_pts, 2.2, InkStroke.Profile.TAPER_BOTH, mug_ink)
		handle_stroke.draw_to(self)
		
		# Coffee fill ellipse at top rim
		var rim_pts := PackedVector2Array()
		for i in range(12):
			var a := (float(i) / 11.0) * TAU
			rim_pts.append(Vector2(cos(a) * (mw * 0.42), -mh + sin(a) * 3.0))
		draw_colored_polygon(rim_pts, coffee_col)
		draw_polyline(rim_pts, mug_ink, 1.4, true)
		
		# Rising animated steam curls
		if show_steam:
			var s_indices: Array[float] = [-1.0, 1.0]
			for s_idx: float in s_indices:
				var sx: float = s_idx * 4.0
				var st_pts := PackedVector2Array()
				for i in range(8):
					var frac := float(i) / 7.0
					var sy := -mh - 4.0 - frac * 22.0
					var sway := sin(steam_time * 3.5 + frac * 4.0 + s_idx * 1.5) * (2.8 * frac)
					st_pts.append(Vector2(sx + sway, sy))
				var s_strk := InkStroke.from_points(st_pts, 1.2, InkStroke.Profile.TAPER_END, Color("#d9c8b7"))
				s_strk.draw_to(self)

# =========================================================================
# 2. STORYTIME WOODEN STUDIO CHAIR / STOOL
# =========================================================================
class StoryChair extends Node2D:
	var wood_fill: Color = Color("#f4ece2") # Warm studio wood wash
	var wood_dark: Color = Color("#e0d0bf") # Shadow tone for back legs
	var wood_ink: Color = Color("#3e081e")  # Master burgundy ink
	
	func _ready() -> void:
		z_index = 2 # Behind Nemi's skirt (z=4) and torso (z=5)
		queue_redraw()

	func _draw() -> void:
		# Seat is at (0, 0), floor is at Y = +140.0
		# 1. Backrest Top Rail and Spindles (rises behind Nemi: Y = -95 to 0)
		var top_rail := PackedVector2Array([
			Vector2(-28, -92), Vector2(-10, -96), Vector2(10, -96), Vector2(28, -92)
		])
		var rail_stroke := InkStroke.from_points(top_rail, 3.8, InkStroke.Profile.TAPER_BOTH, wood_ink)
		rail_stroke.draw_to(self)
		
		# Vertical spindles
		var spindle_x: Array[float] = [-20.0, -7.0, 7.0, 20.0]
		for sx: float in spindle_x:
			var sp_pts := PackedVector2Array([Vector2(sx, -92), Vector2(sx * 0.9, -2)])
			var sp_stroke := InkStroke.from_points(sp_pts, 2.0, InkStroke.Profile.TAPER_BOTH, wood_ink)
			sp_stroke.draw_to(self)
		
		# 2. Back legs down to floor (drawn behind seat)
		var leg_bl := PackedVector2Array([Vector2(-26, 8), Vector2(-30, 140)])
		var s_bl := InkStroke.from_points(leg_bl, 3.0, InkStroke.Profile.TAPER_END, wood_dark)
		s_bl.draw_to(self)
		
		var leg_br := PackedVector2Array([Vector2(26, 8), Vector2(30, 140)])
		var s_br := InkStroke.from_points(leg_br, 3.0, InkStroke.Profile.TAPER_END, wood_dark)
		s_br.draw_to(self)
		
		# 3. Wooden Seat Platter (at Y = -2 to 14)
		var seat_pts := PackedVector2Array([
			Vector2(-48, -2), Vector2(-52, 12), Vector2(52, 12), Vector2(48, -2)
		])
		draw_colored_polygon(seat_pts, wood_fill)
		var seat_loop := seat_pts.duplicate()
		seat_loop.append(seat_pts[0])
		var seat_stroke := InkStroke.from_points(seat_loop, 3.2, InkStroke.Profile.UNIFORM, wood_ink)
		seat_stroke.draw_to(self)
		
		# 4. Foot-rest cross rung at Y = 88 (where seated feet rest comfortably!)
		var rung_pts := PackedVector2Array([Vector2(-38, 88), Vector2(38, 88)])
		var rung_stroke := InkStroke.from_points(rung_pts, 3.0, InkStroke.Profile.TAPER_BOTH, wood_ink)
		rung_stroke.draw_to(self)
		
		# 5. Front legs down to floor
		var leg_fl := PackedVector2Array([Vector2(-40, 12), Vector2(-44, 140)])
		var s_fl := InkStroke.from_points(leg_fl, 3.6, InkStroke.Profile.TAPER_END, wood_ink)
		s_fl.draw_to(self)
		
		var leg_fr := PackedVector2Array([Vector2(40, 12), Vector2(44, 140)])
		var s_fr := InkStroke.from_points(leg_fr, 3.4, InkStroke.Profile.TAPER_END, wood_ink)
		s_fr.draw_to(self)

# =========================================================================
# 3. STORYTIME WORKSPACE CREATOR DESK
# =========================================================================
class StoryDesk extends Node2D:
	var desk_width: float = 540.0
	var desk_height: float = 140.0
	var wood_fill: Color = Color("#f5ede3") # Warm paper wood wash
	var wood_apron: Color = Color("#ebd9c8") # Subtle underside shadow
	var wood_ink: Color = Color("#3e081e")
	
	func _ready() -> void:
		z_index = 6 # In front of Nemi's seated thighs/skirt, behind hands
		queue_redraw()

	func _draw() -> void:
		# Desk origin is at top-left: (0, 0), floor is at Y = +desk_height (140)
		
		# 1. Sturdy wooden legs down to floor
		# Left leg
		var leg_l := PackedVector2Array([Vector2(24, 22), Vector2(24, desk_height)])
		var strk_ll := InkStroke.from_points(leg_l, 4.2, InkStroke.Profile.TAPER_END, wood_ink)
		strk_ll.draw_to(self)
		
		# Right leg
		var leg_r := PackedVector2Array([Vector2(desk_width - 24, 22), Vector2(desk_width - 24, desk_height)])
		var strk_lr := InkStroke.from_points(leg_r, 4.2, InkStroke.Profile.TAPER_END, wood_ink)
		strk_lr.draw_to(self)
		
		# Cross stretcher brace between legs
		var brace := PackedVector2Array([Vector2(24, 110), Vector2(desk_width - 24, 110)])
		var strk_br := InkStroke.from_points(brace, 2.4, InkStroke.Profile.TAPER_BOTH, Color("#d0bead"))
		strk_br.draw_to(self)
		
		# 2. Desk Apron (front face below top)
		var apron_pts := PackedVector2Array([
			Vector2(8, 12), Vector2(desk_width - 8, 12),
			Vector2(desk_width - 8, 24), Vector2(8, 24)
		])
		draw_colored_polygon(apron_pts, wood_apron)
		var apron_line := PackedVector2Array([Vector2(8, 24), Vector2(desk_width - 8, 24)])
		var strk_ap := InkStroke.from_points(apron_line, 2.0, InkStroke.Profile.TAPER_BOTH, wood_ink)
		strk_ap.draw_to(self)
		
		# 3. Desktop Surface Slab (Y = -2 to 12)
		var top_pts := PackedVector2Array([
			Vector2(-4, -2), Vector2(desk_width + 4, -2),
			Vector2(desk_width + 6, 12), Vector2(-6, 12)
		])
		draw_colored_polygon(top_pts, wood_fill)
		
		var top_loop := top_pts.duplicate()
		top_loop.append(top_pts[0])
		var top_stroke := InkStroke.from_points(top_loop, 3.4, InkStroke.Profile.UNIFORM, wood_ink)
		top_stroke.draw_to(self)
		
		# Woodgrain lines on table surface
		var g1 := PackedVector2Array([Vector2(60, 5), Vector2(160, 5)])
		var sg1 := InkStroke.from_points(g1, 1.2, InkStroke.Profile.TAPER_BOTH, Color("#d9c8b7"))
		sg1.draw_to(self)
		
		var g2 := PackedVector2Array([Vector2(320, 6), Vector2(440, 5)])
		var sg2 := InkStroke.from_points(g2, 1.2, InkStroke.Profile.TAPER_BOTH, Color("#d9c8b7"))
		sg2.draw_to(self)
		
		# 4. Illustrated Desk Props: Laptop & Coffee Mug
		_draw_desk_accessories()

	var laptop_state: int = 0 # 0: normal chart, 1: milestone spike (+1,000), 2: comments feed

	func set_laptop_state(s: int) -> void:
		laptop_state = s
		queue_redraw()

	func _draw_desk_accessories() -> void:
		# Creator Laptop (at X = 280, Y = -2)
		var lx := 280.0
		var ly := -2.0
		
		# Base keyboard chassis
		var base_pts := PackedVector2Array([
			Vector2(lx - 46, ly - 6), Vector2(lx + 46, ly - 6),
			Vector2(lx + 50, ly), Vector2(lx - 50, ly)
		])
		draw_colored_polygon(base_pts, Color("#d5cbcf"))
		var base_loop := base_pts.duplicate()
		base_loop.append(base_pts[0])
		var b_strk := InkStroke.from_points(base_loop, 2.2, InkStroke.Profile.UNIFORM, wood_ink)
		b_strk.draw_to(self)
		
		# Trackpad & keyboard hint
		var pad_pts := PackedVector2Array([Vector2(lx - 14, ly - 3), Vector2(lx + 14, ly - 3)])
		draw_polyline(pad_pts, Color("#a89ba2"), 1.4)
		
		# Open tilted laptop screen
		var scr_pts := PackedVector2Array([
			Vector2(lx - 44, ly - 6), Vector2(lx + 44, ly - 6),
			Vector2(lx + 48, ly - 58), Vector2(lx - 48, ly - 58)
		])
		draw_colored_polygon(scr_pts, Color("#f3fbfb")) # Gentle screen glow
		var scr_loop := scr_pts.duplicate()
		scr_loop.append(scr_pts[0])
		var s_strk := InkStroke.from_points(scr_loop, 2.4, InkStroke.Profile.UNIFORM, wood_ink)
		s_strk.draw_to(self)
		
		# Laptop Screen Visuals based on laptop_state
		match laptop_state:
			0: # Normal studio analytics bar charts
				var bar_colors := [Color("#d9485e"), Color("#3b82f6"), Color("#10b981")]
				for i in range(3):
					var bx := lx - 22.0 + float(i) * 16.0
					var bh := 12.0 + float(i) * 10.0
					var b_rect := PackedVector2Array([
						Vector2(bx - 4, ly - 12), Vector2(bx + 4, ly - 12),
						Vector2(bx + 4, ly - 12 - bh), Vector2(bx - 4, ly - 12 - bh)
					])
					draw_colored_polygon(b_rect, bar_colors[i])
			1: # Milestone Spike! Sharp red vertical peak reaching top of screen
				var spike_bar := PackedVector2Array([
					Vector2(lx - 12, ly - 12), Vector2(lx + 12, ly - 12),
					Vector2(lx + 12, ly - 50), Vector2(lx - 12, ly - 50)
				])
				draw_colored_polygon(spike_bar, Color("#d93b2b")) # Milestone Red
				# Mini golden peak star
				draw_circle(Vector2(lx, ly - 52), 3.0, Color("#f59e0b"))
			2: # Comments list
				for i in range(3):
					var cy := ly - 42.0 + float(i) * 12.0
					var cline := PackedVector2Array([Vector2(lx - 34, cy), Vector2(lx + 32, cy)])
					draw_polyline(cline, Color("#9ca3af"), 1.6)
					draw_circle(Vector2(lx - 38, cy), 2.2, Color("#3b82f6"))
