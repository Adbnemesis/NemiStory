extends Node2D
## Music edit director. Existing rig and pose/face/hand definitions are unchanged.
const Acting = preload("res://common/storytime/production/ActingTimeline.gd")
const Base = preload("res://common/storytime/PerformancePlayer.gd")
const NemiScene = preload("res://nemi/characters/nemi/nemi.tscn")
const AdbScene = preload("res://adb/characters/adb/ADB.tscn")
const PoseArt = preload("res://shorts/godot/InkPoseArt.gd")
const Media = preload("res://common/storytime/production/ProductionAudio.gd")
@export var config_path := "res://shorts/godot/ink-proof/short.json"
var manual := false
var clock_audio: AudioStreamPlayer
var elapsed := 0.0
var config: Dictionary
var actors: Dictionary = {}
var acting = Acting.new()
var canvas: Node2D
var label: Label
var at_frame := 0
var shot: Dictionary

func _ready() -> void:
	if config.is_empty(): config = JSON.parse_string(FileAccess.get_file_as_string(config_path))
	var backdrop = ColorRect.new()
	backdrop.size = Vector2(1080,1920)
	var paper_shader = Shader.new()
	paper_shader.code = "shader_type canvas_item; void fragment(){vec2 p=(UV-.5)*vec2(1.,.8);float shade=smoothstep(.08,.65,length(p));float c=mix(.925,.80,shade);COLOR=vec4(vec3(c),1.);}"
	var paper_material = ShaderMaterial.new()
	paper_material.shader = paper_shader
	backdrop.material = paper_material
	add_child(backdrop)
	canvas = Node2D.new()
	add_child(canvas)
	for item in config.actors:
		var actor = (NemiScene if item.author == "nemi" else AdbScene).instantiate()
		canvas.add_child(actor)
		actor.process_mode = Node.PROCESS_MODE_DISABLED
		if item.author == "nemi": actor.set_art_mode(NemiStyle.ArtMode.MONOCHROME)
		var shader = Shader.new()
		shader.code = "shader_type canvas_item; void fragment(){float l=dot(COLOR.rgb,vec3(.299,.587,.114)); COLOR.rgb=vec3(l);}" if item.author == "nemi" else "shader_type canvas_item; void fragment(){float l=dot(COLOR.rgb,vec3(.299,.587,.114));float k=smoothstep(.24,.35,l); COLOR.rgb=vec3(mix(l*.45,.985,k));}"
		var material_ink = ShaderMaterial.new()
		material_ink.shader = shader
		apply_material(actor,material_ink)
		acting.bind(actor,item.author)
		var cues: Array = []
		for j in range(item.cues.size()):
			var cue: Dictionary = item.cues[j]
			var name_key = "ink_edit_%s_%d" % [item.id,j]
			Base.recipes()[item.author][name_key] = {"pose":cue.pose,"expression":cue.expression,"gaze":cue.gaze,"eyes":cue.get("eyes",.95),"head_degrees":cue.get("head",0),"duration":cue.get("duration",.2),"face":{},"controls":{},"gesture_arc":0}
			cues.append({"at":float(cue.frame)/config.fps,"recipe":name_key,"duration":cue.get("duration",.2),"motion":cue.get("motion","snap"),"blinks":cue.get("blinks",[])})
		var drawing = PoseArt.new()
		drawing.author = item.author
		canvas.add_child(drawing)
		actors[item.id] = {"node":actor,"drawing":drawing,"author":item.author,"cues":cues,"art_cues":item.cues}
	label = Label.new()
	label.z_index = 100
	label.text = config.premise
	label.position = Vector2(115,1460)
	label.size = Vector2(780,180)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var caption_font = SystemFont.new()
	caption_font.font_names = PackedStringArray(["Arial"])
	caption_font.font_weight = 700
	label.add_theme_font_override("font",caption_font)
	label.add_theme_font_size_override("font_size",64)
	label.add_theme_color_override("font_color",Color("#fafafa"))
	label.add_theme_color_override("font_outline_color",Color("#272727"))
	label.add_theme_constant_override("outline_size",8)
	add_child(label)
	if not manual:
		get_window().size = Vector2i(1080,1920)
		get_window().content_scale_size = Vector2i(1080,1920)
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		clock_audio = AudioStreamPlayer.new()
		clock_audio.stream = Media.read("res://"+config.music.file)
		clock_audio.volume_db = config.music.gainDb
		add_child(clock_audio)
		clock_audio.play(config.music.sourceStart)
	sample(0)

func _process(delta: float) -> void:
	if manual: return
	elapsed += delta
	if clock_audio and clock_audio.playing:
		elapsed = maxf(0,clock_audio.get_playback_position()+AudioServer.get_time_since_last_mix()-AudioServer.get_output_latency()-config.music.sourceStart)
	if elapsed >= float(config.frames)/config.fps:
		elapsed = 0.0
		clock_audio.play(config.music.sourceStart)
	sample(int(elapsed*config.fps))

func apply_material(node: Node, material_ink: ShaderMaterial) -> void:
	if node is CanvasItem: node.material = material_ink
	for child in node.get_children(): apply_material(child,material_ink)

func sample(frame: int) -> void:
	at_frame = frame
	shot = config.shots[0]
	for entry in config.shots:
		if frame >= int(entry.frame): shot = entry
	var age = frame-int(shot.frame)
	var u = clampf(float(age)/float(shot.get("settle",5)),0,1)
	var e = 1-pow(1-u,3)
	var z = float(shot.zoom)
	if shot.move == "punch": z *= 1+.13*(1-e)
	elif shot.move == "pull": z *= 1+.23*(1-e)
	var center = Vector2(shot.center[0],shot.center[1])
	canvas.scale = Vector2.ONE*z
	canvas.rotation_degrees = float(shot.get("angle",0))*(1-e)
	canvas.position = Vector2(540,960)-center*z
	if shot.move == "whip": canvas.position.x += (1-e)*420*(1 if frame%2 else -1)
	for id in actors:
		var entry: Dictionary = actors[id]
		var actor: Node2D = entry.node
		var drawing: Node2D = entry.drawing
		actor.visible = false
		drawing.visible = shot.actors.has(id)
		if not drawing.visible: continue
		var block: Dictionary = shot.actors[id]
		actor.position = Vector2(block.position[0],block.position[1])
		actor.scale = Vector2.ONE*float(block.scale)
		acting.sample(actor,entry.author,entry.cues,float(frame)/config.fps)
		drawing.position = actor.position
		drawing.scale = actor.scale
		var art_cue: Dictionary = entry.art_cues[0]
		for cue in entry.art_cues:
			if frame >= int(cue.frame): art_cue = cue
		drawing.view = art_cue.get("view","front")
		drawing.emotion = art_cue.get("emotion","shy")
		drawing.gaze = art_cue.gaze[0]
		drawing.smear = age < 2 and shot.move == "whip"
		# A brief eye-lead/pose settle. The illustrated lines stop after the transition.
		var age_art = frame-int(art_cue.frame)
		var art_u = clampf(float(age_art)/5,0,1)
		drawing.rotation_degrees = float(art_cue.get("head",0))*(1-pow(1-art_u,3))*.24
		drawing.queue_redraw()
	queue_redraw()
