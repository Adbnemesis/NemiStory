extends SceneTree

const AshScene = preload("res://pokemon/characters/ash/Ash.tscn")
const PikachuScene = preload("res://pokemon/characters/pikachu/Pikachu.tscn")
const PokeBallScene = preload("res://pokemon/assets/props/PokeBall.tscn")
const FONT_IMPACT: Font = preload("res://assets/fonts/Impact.ttf")

func _init() -> void:
	print("============================================================")
	print("  RENDERING POLISHED SOLID JJ THUMBNAILS (1920x1080)")
	print("============================================================")
	
	DirAccess.make_dir_recursive_absolute("res://renders")
	
	# Master Thumbnail: The Iconic Confrontation (Ash holding Pokéball + Disgusted Pikachu)
	await render_master_confrontation()
	
	# Variant 2: Pikachu Hero Close-up (Pikachu supreme disdain + rejected Pokéball)
	await render_pikachu_hero()
	
	# Variant 3: Split Meme Face-Off ("I HATE" / "POKEBALLS")
	await render_split_faceoff()
	
	print("\n>>> ALL THUMBNAILS COMPLETED! <<<")
	quit(0)

# ==============================================================================
# MASTER THUMBNAIL: The Iconic Solid JJ Two-Shot Confrontation
# Matches: "WE HIRE WOMEN?", "WE'RE TOO POPULAR TO DIE", "ACTUALLY I WIN"
# ==============================================================================
func render_master_confrontation() -> void:
	print("\n[Thumbnail 1/3] Generating Master Two-Shot Confrontation...")
	var vp := SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	
	# 1. Retro Comic Saturated Royal Blue Background with Action Rays
	var bg := Control.new()
	bg.size = Vector2(1920, 1080)
	bg.draw.connect(func():
		var center := Vector2(800, 660)
		var num_rays := 36
		for i in range(num_rays):
			var a1 := float(i) / num_rays * TAU
			var a2 := float(i + 1) / num_rays * TAU
			var col := Color("#1a3c75") if i % 2 == 0 else Color("#122a54")
			var p1 := center
			var p2 := center + Vector2(cos(a1), sin(a1)) * 2000.0
			var p3 := center + Vector2(cos(a2), sin(a2)) * 2000.0
			bg.draw_colored_polygon(PackedVector2Array([p1, p2, p3]), col)
			
		# Outer border vignette
		bg.draw_rect(Rect2(0, 0, 1920, 1080), Color(0, 0, 0, 0.42), false, 28.0)
	)
	vp.add_child(bg)
	
	# 2. Ash Ketchum (Left side, medium close-up, pleading/deadpan)
	var ash := AshScene.instantiate()
	vp.add_child(ash)
	
	# 3. Pikachu (Right side, massive scale, glaring with arms crossed/recoiled)
	var pika := PikachuScene.instantiate()
	vp.add_child(pika)
	# 4. The Pokéball (Held right in front of Ash's glove, presented to Pikachu)
	var ball := PokeBallScene.instantiate()
	vp.add_child(ball)
	ball.position = Vector2(620, 760)
	ball.scale = Vector2(5.5, 5.5)
	
	# Wait for nodes to enter tree and execute _ready
	await process_frame
	
	# Ash configuration (framed waist/chest up, large scale)
	ash.position = Vector2(300, 1400)
	ash.scale = Vector2(5.3, 5.3)
	ash.set_expression("deadpan")
	ash.set_pose("holding_pokeball", 0.0)
	ash.look_at_direction(Vector2(0.92, 0.18))
	var ash_face = ash.get_node_or_null("AshVisual/HeadPivot/Head/Face")
	if ash_face:
		ash_face.set("show_sweat", true)
		ash_face.set("mouth_shape", "wavy")
	
	# Pikachu configuration (large, dominant, arms recoiled, squinting disdain)
	pika.position = Vector2(1420, 1260)
	pika.scale = Vector2(6.5, 6.5)
	pika.set_expression("annoyed")
	pika.set_pose("recoil", 0.0)
	var pika_face = pika.get_node_or_null("PikachuVisual/HeadPivot/Face")
	if pika_face:
		pika_face.set("eye_state", "squint")
		pika_face.set("eye_openness", 0.38)
		pika_face.set("mouth_shape", "dash")
		pika_face.set("gaze_direction", Vector2(-0.95, 0.1))
		pika_face.set("is_sparking", true)
	var pika_ears = pika.get_node_or_null("PikachuVisual/HeadPivot/Ears")
	if pika_ears:
		pika_ears.set("left_ear_angle", -0.75)
		pika_ears.set("right_ear_angle", 0.65)
	var pika_vis = pika.get_node_or_null("PikachuVisual")
	if pika_vis:
		pika_vis.head_tilt = 0.09
		
	# Dynamic rejection lightning bolt connecting Pikachu cheek to Pokéball
	var lightning_layer := Control.new()
	lightning_layer.size = Vector2(1920, 1080)
	lightning_layer.draw.connect(func():
		var p_start := Vector2(1240, 840)
		var p_end := Vector2(700, 760)
		var mid1 := Vector2(1060, 750)
		var mid2 := Vector2(880, 830)
		var pts := PackedVector2Array([p_start, mid1, mid2, p_end])
		# Thick comic black outline
		lightning_layer.draw_polyline(pts, Color.BLACK, 15.0)
		# Glowing bright electric yellow core
		lightning_layer.draw_polyline(pts, Color("#ffe600"), 8.0)
		
		# Comic impact stars around the rejected Pokéball
		_draw_comic_star(lightning_layer, Vector2(710, 710), 26.0, Color("#ffe600"))
		_draw_comic_star(lightning_layer, Vector2(740, 810), 20.0, Color("#fff275"))
		_draw_comic_star(lightning_layer, Vector2(560, 680), 22.0, Color("#ffe600"))
	)
	vp.add_child(lightning_layer)
	
	# 5. GIANT IMPACT TITLE BANNER: "I HATE POKEBALLS"
	var banner := Label.new()
	banner.text = "I HATE POKEBALLS"
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.size = Vector2(1920, 240)
	banner.position = Vector2(0, 25)
	banner.add_theme_font_override("font", FONT_IMPACT)
	banner.add_theme_font_size_override("font_size", 195)
	banner.add_theme_color_override("font_color", Color.WHITE)
	banner.add_theme_color_override("font_outline_color", Color.BLACK)
	banner.add_theme_constant_override("outline_size", 54)
	vp.add_child(banner)
	
	for f in range(4):
		await process_frame
		
	var img: Image = vp.get_texture().get_image()
	var out_path := "renders/pokemon_thumbnail_solid_jj_master.png"
	img.save_png(out_path)
	print("  Saved Master: ", out_path, " (1920x1080)")
	root.remove_child(vp)
	vp.queue_free()

# ==============================================================================
# VARIANT 2: Solo Pikachu Hero Shot ("MUTANT RACISM" / "ACTUALLY I WIN" Style)
# ==============================================================================
func render_pikachu_hero() -> void:
	print("\n[Thumbnail 2/3] Generating Solo Pikachu Hero Shot...")
	var vp := SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	
	# 1. Saturated Comic Teal/Cyan Action Burst
	var bg := Control.new()
	bg.size = Vector2(1920, 1080)
	bg.draw.connect(func():
		var center := Vector2(1100, 680)
		var num_rays := 32
		for i in range(num_rays):
			var a1 := float(i) / num_rays * TAU
			var a2 := float(i + 1) / num_rays * TAU
			var col := Color("#0e6d85") if i % 2 == 0 else Color("#094a5b")
			var p1 := center
			var p2 := center + Vector2(cos(a1), sin(a1)) * 2000.0
			var p3 := center + Vector2(cos(a2), sin(a2)) * 2000.0
			bg.draw_colored_polygon(PackedVector2Array([p1, p2, p3]), col)
			
		# Edge vignette
		bg.draw_rect(Rect2(0, 0, 1920, 1080), Color(0, 0, 0, 0.45), false, 28.0)
	)
	vp.add_child(bg)
	
	# 2. Pikachu (Huge, filling center & right of frame, smug squint, sparking cheeks)
	var pika := PikachuScene.instantiate()
	vp.add_child(pika)
	
	# 3. Rejected Pokéball on left side
	var ball := PokeBallScene.instantiate()
	vp.add_child(ball)
	ball.position = Vector2(380, 680)
	ball.scale = Vector2(6.5, 6.5)
	
	await process_frame
	
	pika.position = Vector2(1280, 1280)
	pika.scale = Vector2(7.2, 7.2)
	pika.set_expression("smug")
	pika.set_pose("idle", 0.0)
	var pika_face = pika.get_node_or_null("PikachuVisual/HeadPivot/Face")
	if pika_face:
		pika_face.set("eye_state", "squint")
		pika_face.set("eye_openness", 0.45)
		pika_face.set("mouth_shape", "dash")
		pika_face.set("gaze_direction", Vector2(-0.85, 0.2))
		pika_face.set("is_sparking", true)
	var pika_ears = pika.get_node_or_null("PikachuVisual/HeadPivot/Ears")
	if pika_ears:
		pika_ears.set("left_ear_angle", -0.35)
		pika_ears.set("right_ear_angle", 0.65)
	var pika_vis = pika.get_node_or_null("PikachuVisual")
	if pika_vis:
		pika_vis.head_tilt = 0.08
		
	# Red Prohibition Symbol 🚫 and Lightning Bolts
	var fx := Control.new()
	fx.size = Vector2(1920, 1080)
	fx.draw.connect(func():
		var center := Vector2(380, 680)
		var r := 155.0
		# Red outer ring
		fx.draw_arc(center, r, 0, TAU, 48, Color.BLACK, 36.0, true)
		fx.draw_arc(center, r, 0, TAU, 48, Color("#dc2626"), 22.0, true)
		
		# Diagonal slash bar
		var p1 := center + Vector2(-r * 0.707, -r * 0.707)
		var p2 := center + Vector2(r * 0.707, r * 0.707)
		fx.draw_line(p1, p2, Color.BLACK, 36.0)
		fx.draw_line(p1, p2, Color("#dc2626"), 22.0)
		
		# Electric spark bolt repelling
		var spark_col := Color("#facc15")
		var bolt := PackedVector2Array([
			Vector2(950, 680), Vector2(780, 640), Vector2(650, 710), Vector2(540, 680)
		])
		fx.draw_polyline(bolt, Color.BLACK, 14.0)
		fx.draw_polyline(bolt, spark_col, 7.0)
		_draw_comic_star(fx, Vector2(540, 680), 28.0, spark_col)
	)
	vp.add_child(fx)
	
	# GIANT IMPACT BANNER: "I HATE POKEBALLS"
	var banner := Label.new()
	banner.text = "I HATE POKEBALLS"
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.size = Vector2(1920, 240)
	banner.position = Vector2(0, 25)
	banner.add_theme_font_override("font", FONT_IMPACT)
	banner.add_theme_font_size_override("font_size", 195)
	banner.add_theme_color_override("font_color", Color.WHITE)
	banner.add_theme_color_override("font_outline_color", Color.BLACK)
	banner.add_theme_constant_override("outline_size", 54)
	vp.add_child(banner)
	
	for f in range(4):
		await process_frame
		
	var img: Image = vp.get_texture().get_image()
	var out_path := "renders/pokemon_thumbnail_pikachu_solo.png"
	img.save_png(out_path)
	print("  Saved Solo: ", out_path, " (1920x1080)")
	root.remove_child(vp)
	vp.queue_free()

# ==============================================================================
# VARIANT 3: Split Meme Face-Off ("WE'RE TOO POPULAR TO DIE" Style)
# ==============================================================================
func render_split_faceoff() -> void:
	print("\n[Thumbnail 3/3] Generating Split Meme Face-Off...")
	var vp := SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	
	# Dual-Tone Comic Split Background
	var bg := Control.new()
	bg.size = Vector2(1920, 1080)
	bg.draw.connect(func():
		var poly_left := PackedVector2Array([
			Vector2(0, 0), Vector2(980, 0), Vector2(860, 1080), Vector2(0, 1080)
		])
		bg.draw_colored_polygon(poly_left, Color("#1e3a8a"))
		
		var poly_right := PackedVector2Array([
			Vector2(980, 0), Vector2(1920, 0), Vector2(1920, 1080), Vector2(860, 1080)
		])
		bg.draw_colored_polygon(poly_right, Color("#b43403"))
		
		# Center black dividing line
		bg.draw_line(Vector2(980, 0), Vector2(860, 1080), Color.BLACK, 14.0)
		bg.draw_rect(Rect2(0, 0, 1920, 1080), Color(0, 0, 0, 0.4), false, 28.0)
	)
	vp.add_child(bg)
	
	# Ash Close-up (Left, shifted further left so bottom text is clear)
	var ash := AshScene.instantiate()
	vp.add_child(ash)
	
	# Pikachu Close-up (Right, shifted right)
	var pika := PikachuScene.instantiate()
	vp.add_child(pika)
	
	# Pokéball between them
	var ball := PokeBallScene.instantiate()
	vp.add_child(ball)
	ball.position = Vector2(920, 520)
	ball.scale = Vector2(5.0, 5.0)
	
	await process_frame
	
	ash.position = Vector2(280, 1400)
	ash.scale = Vector2(5.5, 5.5)
	ash.set_expression("annoyed")
	ash.set_pose("point", 0.0)
	ash.look_at_direction(Vector2(0.95, 0.1))
	
	pika.position = Vector2(1580, 1280)
	pika.scale = Vector2(6.4, 6.4)
	pika.set_expression("angry")
	pika.set_pose("battle_stance", 0.0)
	var pika_face = pika.get_node_or_null("PikachuVisual/HeadPivot/Face")
	if pika_face:
		pika_face.set("gaze_direction", Vector2(-0.95, -0.05))
		pika_face.set("is_sparking", true)
	
	# Split Impact Text: "I HATE" at Top, "POKEBALLS" at Bottom (layered above characters)
	var top_banner := Label.new()
	top_banner.text = "I HATE"
	top_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_banner.size = Vector2(1920, 200)
	top_banner.position = Vector2(0, 25)
	top_banner.z_index = 100
	top_banner.add_theme_font_override("font", FONT_IMPACT)
	top_banner.add_theme_font_size_override("font_size", 195)
	top_banner.add_theme_color_override("font_color", Color.WHITE)
	top_banner.add_theme_color_override("font_outline_color", Color.BLACK)
	top_banner.add_theme_constant_override("outline_size", 54)
	vp.add_child(top_banner)
	
	var bot_banner := Label.new()
	bot_banner.text = "POKEBALLS"
	bot_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bot_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bot_banner.size = Vector2(1920, 200)
	bot_banner.position = Vector2(0, 860)
	bot_banner.z_index = 100
	bot_banner.add_theme_font_override("font", FONT_IMPACT)
	bot_banner.add_theme_font_size_override("font_size", 195)
	bot_banner.add_theme_color_override("font_color", Color.WHITE)
	bot_banner.add_theme_color_override("font_outline_color", Color.BLACK)
	bot_banner.add_theme_constant_override("outline_size", 54)
	vp.add_child(bot_banner)
	
	for f in range(4):
		await process_frame
		
	var img: Image = vp.get_texture().get_image()
	var out_path := "renders/pokemon_thumbnail_split_meme.png"
	img.save_png(out_path)
	print("  Saved Split: ", out_path, " (1920x1080)")
	root.remove_child(vp)
	vp.queue_free()

func _draw_comic_star(canvas: Control, center: Vector2, radius: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var num_pts := 8
	for i in range(num_pts):
		var a := float(i) / float(num_pts) * TAU - PI * 0.5
		var r := radius if i % 2 == 0 else radius * 0.38
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	canvas.draw_colored_polygon(pts, col)
	canvas.draw_polyline(pts, Color.BLACK, 4.0, true)
