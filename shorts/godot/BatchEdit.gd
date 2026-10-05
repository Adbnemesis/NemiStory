extends "res://shorts/godot/InkEdit.gd"
const BatchArt = preload("res://shorts/godot/BatchPoseArt.gd")
const Accents = preload("res://shorts/godot/BatchAccentArt.gd")
var marks: Node2D
var frontmarks: Node2D
var paper_material: ShaderMaterial
var effects: Array = []
var previous_audio_frame := -1

func _ready() -> void:
	super._ready()
	for id in actors:
		var entry: Dictionary = actors[id]
		entry.drawing.queue_free()
		var new_art = BatchArt.new()
		new_art.author = entry.author
		canvas.add_child(new_art)
		entry.drawing = new_art
	marks = Accents.new()
	marks.events = config.events
	marks.theme = config.theme.signature
	add_child(marks)
	move_child(marks,1)
	frontmarks = Accents.new()
	frontmarks.events = config.events
	frontmarks.foreground = true
	frontmarks.z_index = 50
	add_child(frontmarks)
	var shader = Shader.new()
	shader.code = "shader_type canvas_item; uniform vec4 paper:source_color;uniform vec4 edge:source_color;void fragment(){vec2 p=(UV-.5)*vec2(1.,.8);float s=smoothstep(.12,.72,length(p));vec3 c=mix(paper.rgb,edge.rgb,s);float g=sin(UV.x*2350.)*sin(UV.y*4178.)*.002;COLOR=vec4(c+g,1.);}"
	paper_material = ShaderMaterial.new()
	paper_material.shader = shader
	get_child(0).material = paper_material
	label.add_theme_font_size_override("font_size",50)
	label.position = Vector2(110,1490)
	label.size = Vector2(860,170)
	label.add_theme_constant_override("outline_size",6)
	if not manual:
		for cue in config.sfx:
			var player = AudioStreamPlayer.new()
			player.stream = Media.read("res://"+cue.file)
			player.volume_db = cue.gainDb
			add_child(player)
			var onset := 0
			for ev in config.events:
				if ev.id == cue.event: onset = int(ev.at)+int(cue.get("offsetFrames",0))
			effects.append({"player":player,"cue":cue,"onset":onset})
	sample(0)

func sample(frame: int) -> void:
	super.sample(frame)
	if not marks: return
	if not manual:
		if frame < previous_audio_frame:
			previous_audio_frame = -1
			for effect in effects: effect.player.stop()
		for effect in effects:
			if previous_audio_frame < effect.onset and frame >= effect.onset:
				effect.player.play(float(effect.cue.sourceStart)+float(frame-effect.onset)/config.fps)
			if frame >= effect.onset+int(effect.cue.duration*config.fps): effect.player.stop()
		previous_audio_frame = frame
	var dark = shot.get("palette","paper") == "ink"
	var ink_color = Color(config.theme.paper) if dark else Color(config.theme.ink)
	var paper_color = Color(config.theme.ink) if dark else Color(config.theme.paper)
	var age = frame-int(shot.frame)
	var u = clampf(float(age)/float(shot.get("settle",5)),0,1)
	if shot.move == "whip":
		canvas.position.x = 540.0-float(shot.center[0])*canvas.scale.x+pow(1-u,3)*420*int(shot.get("direction",1))
	marks.frame = frame
	marks.stage = shot.get("stage","plain")
	marks.ink = ink_color
	marks.accent = Color(config.theme.accent)
	marks.dark = dark
	marks.queue_redraw()
	frontmarks.frame = frame
	frontmarks.ink = ink_color
	frontmarks.accent = Color(config.theme.accent)
	frontmarks.queue_redraw()
	paper_material.set_shader_parameter("paper",paper_color)
	paper_material.set_shader_parameter("edge",paper_color.darkened(.085) if not dark else paper_color.lightened(.04))
	for id in actors:
		var entry: Dictionary = actors[id]
		var drawing = entry.drawing
		if not drawing.visible: continue
		var cue: Dictionary = entry.art_cues[0]
		for candidate in entry.art_cues:
			if frame >= int(candidate.frame): cue = candidate
		drawing.action = cue.get("action","rest")
		drawing.accessory = "headphones" if config.theme.signature == "sound" else ""
		drawing.ink = ink_color
		drawing.paper = paper_color
		drawing.shade = Color(config.theme.shade)
		drawing.accent = Color(config.theme.accent)
		drawing.shading = float(config.theme.get("shading",.28))
		drawing.scale.x *= int(shot.actors[id].get("flip",1))
		drawing.queue_redraw()
