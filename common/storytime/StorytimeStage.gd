extends Node2D
## Data-driven NEW productions. Does not load or rewrite episode scripts.
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const Acting = preload("res://common/storytime/PerformancePlayer.gd")
const Track = preload("res://common/engine/illustration/IllustrationTrack.gd")
const Scenes = {
	"nemi":preload("res://nemi/characters/nemi/nemi.tscn"),
	"adb":preload("res://adb/characters/adb/ADB.tscn")}
var spec: Dictionary
var actors: Array[Dictionary] = []
var track: Node
var caption: Label
var voice: AudioStreamPlayer
var elapsed := 0.0
var manual := false

func _ready() -> void:
	var spec_path := "res://common/storytime/examples/two_authors_10s.json"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="):
			spec_path=arg.trim_prefix("--spec=")
	spec=JSON.parse_string(FileAccess.get_file_as_string(spec_path))
	var paper := ColorRect.new()
	paper.color=Color("#faf7f1")
	paper.size=Vector2(1920,1080)
	add_child(paper)
	track=Track.new()
	add_child(track)
	for item in spec.actors:
		var actor: Node2D = Scenes[item.author].instantiate()
		actor.position=Vector2(item.position[0],item.position[1])
		actor.scale=Vector2.ONE*float(item.scale)
		add_child(actor)
		# The production clock owns acting; suppress autonomous springs/timers.
		actor.process_mode=Node.PROCESS_MODE_DISABLED
		actors.append({"node":actor,"spec":item})
		var label := Label.new()
		label.position=Vector2(85 if item.author=="nemi" else 1045,78)
		label.text="Nemi / loose story pen" if item.author=="nemi" else "ADB / compact margin pen"
		label.add_theme_font_size_override("font_size",27)
		label.add_theme_color_override("font_color",Color(Assets.profile(item.author).ink))
		add_child(label)
	for item in spec.drawings:
		var node: Node2D
		if item.kind=="text":
			node=Assets.lettering(item.author,item.text,float(item.size),item.get("accent",false),item.get("variant",0))
		else:
			node=Assets.mark(item.author,item.kind,item.get("accent",false))
		node.position=Vector2(item.position[0],item.position[1])
		var scale_value: Array = item.get("scale",[1,1])
		node.scale=Vector2(scale_value[0],scale_value[1])
		node.rotation_degrees=float(item.get("tilt",0))
		add_child(node)
		track.add_drawing(node,item.at,item.duration,item.end)
	caption=Label.new()
	caption.position=Vector2(120,978)
	caption.size=Vector2(1680,55)
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",28)
	caption.add_theme_color_override("font_color",Color("#54464a"))
	add_child(caption)
	if spec.get("audio") and not manual:
		voice=AudioStreamPlayer.new()
		voice.stream=load(spec.audio)
		add_child(voice)
		voice.play()
	sample(0)

func _process(delta: float) -> void:
	if not manual:
		elapsed+=delta
		var time := elapsed
		if voice and voice.playing:
			time=maxf(0.0,voice.get_playback_position()+AudioServer.get_time_since_last_mix()-AudioServer.get_output_latency())
			elapsed=time
		sample(time)
		if elapsed>=float(spec.duration):
			get_tree().quit()

func sample(time: float) -> void:
	track.sample(time)
	for entry in actors:
		Acting.sample(entry.node,entry.spec.author,entry.spec.performances,time)
		for mouth in entry.spec.get("mouths",[]):
			if time>=float(mouth.start) and time<float(mouth.end):
				if entry.spec.author=="nemi": entry.node.set_mouth_shape(mouth.shape)
				else: entry.node.set_mouth(mouth.shape)
	caption.text=""
	for card in spec.get("captions",[]):
		if time>=float(card.start) and time<float(card.end):
			caption.text=card.text
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2(960,100),Vector2(960,925),Color("#e6ded5"),1,true)
