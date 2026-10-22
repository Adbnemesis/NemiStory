extends SceneTree
const Assets=preload("res://common/storytime/ProfileAssets.gd")
const EP="res://nemi/episodes/ep17_i_thought_1000_subscribers_would_fix_everything/"
func _init() -> void:
	var spec=JSON.parse_string(FileAccess.get_file_as_string(EP+"scene_r6_1080p.json"))
	var rows=[]
	var failed=false
	for item in spec.drawings:
		if item.kind!="text":continue
		var data=Assets.compose(item.author,item.text,item.size,item.get("accent",false),item.get("variant",0))
		var low=Vector2(INF,INF);var high=Vector2(-INF,-INF)
		var scale_v=Vector2(item.get("scale",[1,1])[0],item.get("scale",[1,1])[1])
		var origin=Vector2(item.position[0],item.position[1])
		for stroke in data.strokes:
			for point in stroke.pts:
				var p=(point*scale_v).rotated(deg_to_rad(item.get("tilt",0)))+origin
				var pad=Vector2.ONE*(stroke.w*maxf(absf(scale_v.x),absf(scale_v.y))+.5)
				low=low.min(p-pad);high=high.max(p+pad)
		var projections=[]
		for shot in spec.shots:
			if maxf(item.at,shot.start)>=minf(item.end,shot.end):continue
			if item.has("shots") and not shot.id in item.shots:continue
			var camera=shot.get("camera",{"center":[960,540],"zoom":1})
			var cameras=[camera]
			for point in camera.get("path",[]):cameras.append(point)
			for frame in cameras:
				var center=Vector2(frame.center[0],frame.center[1]);var zoom=frame.zoom
				var a=Vector2(960,540)+(low-center)*zoom
				var b=Vector2(960,540)+(high-center)*zoom
				var inside=a.x>=0 and a.y>=0 and b.x<=1920 and b.y<=1080
				failed=failed or not inside
				projections.append({"shot":shot.id,"screen_bounds":[a.x,a.y,b.x,b.y],"fully_inside_frame":inside,"right_margin_px":1920-b.x})
		rows.append({"text":item.text,"size":item.size,"position":item.position,"exact_profile_width":data.width,"stroke_world_bounds":[low.x,low.y,high.x,high.y],"projections":projections})
	var output={"spec":"scene_r6_1080p.json","method":"Exact ProfileAssets.compose stroke geometry with stroke-width padding, art scale/rotation and each overlapping shot camera/path point; all five text drawings","all_text_inside_frame":not failed,"drawings":rows}
	var file=FileAccess.open(EP+"review/TEXT_BOUNDS_R6.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(output,"  ")+"\n");file.close()
	print(JSON.stringify(output))
	quit(1 if failed else 0)
