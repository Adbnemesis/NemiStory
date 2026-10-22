extends SceneTree
const SceneArt=preload("res://common/storytime/production/SceneArt.gd")
const Milestone=preload("res://common/storytime/production/MilestoneEpisodeArt.gd")
const Stage=preload("res://common/storytime/production/ProductionStage.tscn")
var failures:=0
func _init() -> void:call_deferred("run")
func require(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)
func run() -> void:
	for kind in Milestone.KINDS:
		var n=SceneArt.make("nemi",kind)
		root.add_child(n)
		require(n.stroke_list.size()>0,"Empty art: "+kind)
		var signature=var_to_str(n.stroke_list)+var_to_str(n.fills)
		for t in [0.0,.25,.5,.9,1.1,4.0]:
			n.sample(t,0.0,1.0,10.0)
			await process_frame
			require(signature==var_to_str(n.stroke_list)+var_to_str(n.fills),"Geometry changed on shared clock: "+kind)
			require(is_equal_approx(n.progress,clampf(t,0,1)),"Wrong progress: "+kind)
		for stroke in n.stroke_list:
			for pt in stroke.pts:require(is_finite(pt.x) and is_finite(pt.y),"Nonfinite art point: "+kind)
		for fill in n.fills:require(is_equal_approx(fill.at,.88),"Unexpected fill reveal: "+kind)
		n.free()
	var stage=Stage.instantiate()
	stage.manual=true
	stage.spec_path="res://nemi/episodes/ep17_i_thought_1000_subscribers_would_fix_everything/art_example.json"
	root.add_child(stage)
	await process_frame
	require(stage.pictures.size()==4,"Example must stage all four milestone kinds")
	for t in [.2,2.7,5.2,7.7]:
		stage.sample(t)
		var visible_count:=0
		for entry in stage.pictures:
			if entry.node.visible:
				visible_count+=1
				require(entry.node.progress==1.0,"Held example art not complete")
		require(visible_count==1,"Example art overlap or empty stage")
	stage.free()
	if failures:quit(1)
	else:
		print("PASS: four Nemi milestone kinds registered; finite original geometry, stable shared-clock holds/reveals, late fills; silent example stages one held artwork at a time.")
		quit()
