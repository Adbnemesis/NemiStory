extends SceneTree
const Production=preload("res://common/storytime/production/ProductionStage.gd")
const Wall=preload("res://SchoolWall.gd")
const DrawingWall=preload("res://DrawingWorld.gd")
const Motion=preload("res://common/storytime/production/Motion.gd")
var timeline: Dictionary
var walls: Array=[]
var wall_viewports: Array=[]
var world_continuity := false
var continuous_world_events: Array=[]
var continuity_events_by_group: Dictionary={}
var stage: Node2D
var shader_material: ShaderMaterial
var last_scene := ""
var mode := "sphere"
var native_scale := 1.0
var start := 0.0
var duration := -1.0
var scene_path := "res://nemi/playable_storytime/episodes/episode_001/scene.json"

func _init() -> void:
	call_deferred("run")

func viewport(transparent: bool=false) -> SubViewport:
	var view:=SubViewport.new()
	view.size=Vector2i(int(1920*native_scale),int(1080*native_scale))
	view.transparent_bg=transparent
	view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	return view

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--spec="): scene_path=arg.trim_prefix("--spec=")
		if arg.begins_with("--mode="): mode=arg.trim_prefix("--mode=")
		if arg=="--4k": native_scale=2.0
		if arg.begins_with("--start="): start=float(arg.trim_prefix("--start="))
		if arg.begins_with("--duration="): duration=float(arg.trim_prefix("--duration="))
	root.size=Vector2i(2160,1080) if mode=="sphere" else Vector2i(1920,1080)
	if native_scale>1.0: root.size=Vector2i(3840,1920) if mode=="sphere" else Vector2i(3840,2160)
	timeline=JSON.parse_string(FileAccess.get_file_as_string(scene_path.get_base_dir()+"/storyboard/timeline.json"))
	var world_renderer:=str(timeline.get("world_renderer","school"))
	if world_renderer not in ["school","drawing"]:
		push_error("Unknown world renderer: "+world_renderer)
		quit(1)
		return
	var wall_script: Script=DrawingWall if world_renderer=="drawing" else Wall
	world_continuity=world_renderer=="drawing" and timeline.get("world_continuity",false)==true
	if world_continuity:
		for scene in timeline.scenes:
			continuous_world_events.append_array(scene.get("environment_events",[]))
	elif world_renderer=="drawing":
		for scene in timeline.scenes:
			var group:=str(scene.get("continuity_group",""))
			if group.is_empty(): continue
			if not continuity_events_by_group.has(group): continuity_events_by_group[group]=[]
			continuity_events_by_group[group].append_array(scene.get("environment_events",[]))
	for index in range(4):
		var view:=viewport()
		var wall=wall_script.new()
		wall.wall_index=index
		wall.scale=Vector2.ONE*native_scale
		view.add_child(wall)
		walls.append(wall)
		wall_viewports.append(view)
	var actor_view:=viewport(true)
	stage=Production.new()
	stage.scale=Vector2.ONE*native_scale
	stage.manual=true
	stage.spec_path=scene_path
	actor_view.add_child(stage)
	stage.backdrop.visible=false
	var screen:=ColorRect.new()
	screen.size=Vector2(root.size)
	shader_material=ShaderMaterial.new()
	shader_material.shader=load("res://cube_to_sphere.gdshader")
	for index in range(4):
		shader_material.set_shader_parameter(["wall_front","wall_right","wall_back","wall_left"][index],wall_viewports[index].get_texture())
	shader_material.set_shader_parameter("stage_front",actor_view.get_texture())
	shader_material.set_shader_parameter("perspective",mode=="review")
	screen.material=shader_material
	root.add_child(screen)
	if mode=="review":
		# The director can frame a face without projecting/cropping subtitles.
		# Text and timing remain owned by the unchanged canonical stage.
		stage.remove_child(stage.caption)
		root.add_child(stage.caption)
		stage.caption.scale=Vector2.ONE*native_scale
		stage.caption.position=Vector2(120,974)*native_scale
	sample(start)
	await process_frame
	var fps:=int(timeline.fps)
	if duration<0: duration=float(timeline.duration)-start
	var frames:=int(round(duration*fps))
	for frame in range(1,frames):
		var time:=start+float(frame)/fps
		sample(time)
		RenderingServer.force_draw.call_deferred(false,1.0/fps)
		await process_frame
	print("AUDITION COMPLETE: " if timeline.get("kind","")=="audition" else "PLAYABLE COMPLETE: ",frames," authored frames; mode=",mode)
	quit()

func sample(time: float) -> void:
	var scene: Dictionary=timeline.scenes[0]
	for candidate in timeline.scenes:
		if time>=float(candidate.start) and time<float(candidate.end): scene=candidate;break
	if str(scene.id)!=last_scene:
		for index in range(4):
			walls[index].objects=[]
			if timeline.get("world_renderer","school")=="drawing": walls[index].focus_wall=int(scene.get("actor_wall",0))
			walls[index].events=scene.get("environment_events",[])
			walls[index].location=scene.location
			walls[index].scene_start=float(scene.start)
			walls[index].entry_card=scene.get("entry_card",{})
		for wall in scene.walls:
			walls[int(wall.index)].objects=wall.objects
		last_scene=str(scene.id)
	var group:=str(scene.get("continuity_group",""))
	if world_continuity or continuity_events_by_group.has(group):
		# Absolute-time reconstruction works after a cut or a direct seek. Future
		# actions stay absent; completed results persist only in their own set.
		var event_pool: Array=continuous_world_events if world_continuity else continuity_events_by_group[group]
		var active_events: Array=[]
		for event in event_pool:
			if time>=float(event.at): active_events.append(event)
		for wall in walls: wall.events=active_events
	for wall in walls: wall.sample(time)
	stage.sample(time)
	var transport: Dictionary=scene.get("actor_transport",{})
	if not transport.is_empty():
		for wall in scene.walls:
			for object in wall.objects:
				if str(object.id)==str(transport.object):
					# The existing stage resets its world transform each sample.
					# Both vehicle and rider use the same canonical seekable path;
					# this is an already-aboard transport cut, not a walking system.
					stage.world.position+=Motion.point(object.path,time)-Vector2(float(object.x),float(object.y))
	stage.backdrop.visible=false
	# Authored staging cuts place the unchanged actor/ink texture beside the
	# selected environment object. Default zero preserves front-wall episodes.
	shader_material.set_shader_parameter("stage_wall",int(scene.get("actor_wall",0)))
	# The front receipt sits beside Nemi. Her opening thought and reaction stay
	# visible; peripheral walls retain the larger orientation-safe receipt.
	stage.visible=true
	var yaw:=float(scene.get("review_yaw",0.0))
	var fov:=float(scene.get("review_fov",64.0))
	var pitch:=0.0
	var path: Array=scene.get("review_yaw_path",[])
	var camera_beats: Array=scene.get("review_camera_beats",[])
	if not camera_beats.is_empty():
		yaw=0.0
		for beat in camera_beats:
			if time<float(beat.at): break
			var span:=float(beat.get("duration",0.32))
			var amount:=1.0 if span<=0.0 else smoothstep(0.0,1.0,clampf((time-float(beat.at))/span,0.0,1.0))
			yaw=lerp_angle(deg_to_rad(yaw),deg_to_rad(float(beat.yaw)),amount)*180.0/PI
			fov=lerpf(fov,float(beat.fov),amount)
			pitch=lerpf(pitch,float(beat.get("pitch",0.0)),amount)
	elif not path.is_empty():
		yaw=float(path[0].yaw)
		for index in range(1,path.size()):
			if time>=float(path[index].at): yaw=float(path[index].yaw)
			elif time>=float(path[index-1].at):
				var amount:=clampf((time-float(path[index-1].at))/(float(path[index].at)-float(path[index-1].at)),0.0,1.0)
				yaw=lerpf(float(path[index-1].yaw),float(path[index].yaw),smoothstep(0.0,1.0,amount))
				break
	shader_material.set_shader_parameter("yaw",yaw)
	shader_material.set_shader_parameter("pitch",pitch)
	shader_material.set_shader_parameter("fov",fov)
