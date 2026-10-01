extends Node2D
## Version 2: shot grammar, grounded acting, props, held/live art, VFX, sound.
const OldStage=preload("res://common/storytime/StorytimeStage.gd")
const Acting=preload("res://common/storytime/production/ActingTimeline.gd")
const Art=preload("res://common/storytime/production/SceneArt.gd")
const Assets=preload("res://common/storytime/ProfileAssets.gd")
const Background=preload("res://common/storytime/production/Backdrop.gd")
const Media=preload("res://common/storytime/production/ProductionAudio.gd")
const Accent=preload("res://common/storytime/production/BeatVFX.gd")
var spec: Dictionary
var manual := false
var spec_path := "res://common/storytime/examples/storytime_direction_10s.json"
var world: Node2D
var backdrop: Node2D
var actors: Dictionary={}
var pictures: Array[Dictionary]=[]
var effects: Array[Dictionary]=[]
var caption: Label
var acting := Acting.new()
var elapsed := 0.0
var audio_clock: AudioStreamPlayer
var sfx_players: Array[Dictionary]=[]
var last_time := -1.0
var current_shot := ""

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="): spec_path=arg.trim_prefix("--spec=")
	spec=JSON.parse_string(FileAccess.get_file_as_string(spec_path))
	world=Node2D.new()
	add_child(world)
	backdrop=Background.new()
	world.add_child(backdrop)
	for item in spec.actors:
		var actor: Node2D=OldStage.Scenes[item.author].instantiate()
		world.add_child(actor)
		actor.process_mode=Node.PROCESS_MODE_DISABLED
		actor.z_index=1
		acting.bind(actor,item.author)
		actors[item.id]={"node":actor,"spec":item}
	for item in spec.drawings+spec.get("props",[]):
		var node: Node2D
		if item.kind=="text": node=Assets.lettering(item.author,item.text,item.size,item.get("accent",false),item.get("variant",0))
		else: node=Art.make(item.author,item.kind)
		world.add_child(node)
		node.z_index=item.get("layer",2)
		pictures.append({"node":node,"spec":item})
	for item in spec.get("vfx",[]):
		var node=Accent.new()
		node.kind=item.kind
		node.author=item.author
		node.z_index=5
		world.add_child(node)
		effects.append({"node":node,"spec":item})
	caption=Label.new()
	caption.position=Vector2(120,974)
	caption.size=Vector2(1680,65)
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",32)
	caption.add_theme_color_override("font_color",Color("#493a42"))
	add_child(caption)
	if not manual:
		if spec.get("audio"):
			audio_clock=AudioStreamPlayer.new()
			audio_clock.stream=Media.read(spec.audio)
			audio_clock.volume_db=-2.0
			add_child(audio_clock)
			audio_clock.play()
		for item in spec.get("sfx",[]):
			var player := AudioStreamPlayer.new()
			player.stream=Media.read(item.file)
			player.volume_db=item.gain_db
			add_child(player)
			sfx_players.append({"node":player,"spec":item})
	sample(0.0)

func _process(delta: float) -> void:
	if manual: return
	elapsed+=delta
	if audio_clock and audio_clock.playing:
		elapsed=maxf(0,audio_clock.get_playback_position()+AudioServer.get_time_since_last_mix()-AudioServer.get_output_latency())
	sample(elapsed)
	if elapsed>=float(spec.duration): get_tree().quit()

func sample(time: float) -> void:
	var shot: Dictionary=spec.shots[0]
	for item in spec.shots:
		if time>=item.start and time<item.end: shot=item
	current_shot=shot.id
	backdrop.set_kind(shot.background)
	var camera: Dictionary=shot.get("camera",{})
	var zoom: float=camera.get("zoom",1.0)
	var center: Array=camera.get("center",[960,540])
	world.scale=Vector2.ONE*zoom
	world.position=Vector2(960,540)-Vector2(center[0],center[1])*zoom
	for id in actors:
		var entry: Dictionary=actors[id]
		var node: Node2D=entry.node
		node.visible=shot.actors.has(id)
		if not node.visible: continue
		var block: Dictionary=shot.actors[id]
		node.position=Vector2(block.position[0],block.position[1])
		node.scale=Vector2.ONE*float(block.scale)
		acting.sample(node,entry.spec.author,entry.spec.performances,time)
		for mouth in entry.spec.get("mouths",[]):
			if time>=mouth.start and time<mouth.end:
				if entry.spec.author=="nemi": node.set_mouth_shape(mouth.shape)
				else: node.set_mouth(mouth.shape)
	for entry in pictures:
		var item: Dictionary=entry.spec
		var node: Node2D=entry.node
		node.visible=time>=item.at and time<item.end and (not item.has("shots") or current_shot in item.shots)
		if not node.visible: continue
		var scale_value: Array=item.get("scale",[1,1])
		node.scale=Vector2(scale_value[0],scale_value[1])
		node.rotation_degrees=item.get("tilt",0)
		if item.has("attach"):
			var attach: Dictionary=item.attach
			var actor: Node2D=actors[attach.actor].node
			node.visible=actor.visible
			var hand: Node2D=actor.get(attach.hand+"_hand_bone") if actors[attach.actor].spec.author=="nemi" else actor.get(attach.hand+"_hand_node")
			node.global_scale=actor.global_scale*Vector2(scale_value[0],scale_value[1])
			node.global_rotation=hand.global_rotation+deg_to_rad(float(attach.get("angle",0)))
			var grip: Array=attach.grip
			var socket: Vector2=hand.get_prop_anchor() if hand.has_method("get_prop_anchor") else Vector2(0,8)
			if attach.has("socket"): socket=Vector2(attach.socket[0],attach.socket[1])
			node.global_position=hand.to_global(socket)-node.global_transform.basis_xform(Vector2(grip[0],grip[1]))
		else: node.position=Vector2(item.position[0],item.position[1])
		node.progress=clampf((time-item.at)/float(item.duration),0,1) if item.get("mode","hold")=="live" else 1.0
	for entry in effects:
		var item: Dictionary=entry.spec
		var node: Node2D=entry.node
		node.visible=time>=item.at and time<item.end and (not item.has("shots") or current_shot in item.shots)
		if not node.visible: continue
		if item.has("actor"):
			var actor: Node2D=actors[item.actor].node
			node.visible=actor.visible
			var offset: Array=item.get("offset",[80,-30])
			node.global_position=actor.face.global_position+world.global_transform.basis_xform(Vector2(offset[0],offset[1]))
		else: node.position=Vector2(item.position[0],item.position[1])
		node.sample((time-item.at)/(item.end-item.at))
	caption.text=""
	for item in spec.get("captions",[]):
		if time>=item.start and time<item.end: caption.text=item.text
	# Audio events follow the same absolute timeline and never retrigger on hold.
	for entry in sfx_players:
		var item: Dictionary=entry.spec
		if time<last_time:
			entry.node.stop()
			if time>=item.at and time<item.at+item.duration: entry.node.play(time-item.at)
		elif last_time<item.at and time>=item.at: entry.node.play(maxf(0,time-item.at))
		if time>=item.at+item.duration: entry.node.stop()
	last_time=time
