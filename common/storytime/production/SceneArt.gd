extends RefCounted
## Small authored production prop catalog. Fills/ink, no bitmap dependencies.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets=preload("res://common/storytime/ProfileAssets.gd")
static func make(author: String, kind: String) -> Node2D:
	if kind in Assets.profile(author).marks: return Assets.mark(author,kind)
	var node=Drawing.new()
	var ink := Color(Assets.profile(author).ink)
	var pale := Color("#efe2c8" if author=="nemi" else "#e0e4e1")
	var shapes: Array=[]
	var lines: Array=[]
	match kind:
		"laptop":
			shapes=[[[[-125,-103],[111,-105],[119,27],[-120,29],[-125,-103]],pale],[[[-120,29],[119,27],[150,61],[-153,63],[-120,29]],Color("#e6d9c4")]]
			lines=[[[[-105,-87],[94,-89],[98,10],[-104,12],[-105,-87]],2.1],[[[-66,43],[68,42]],1.4],[[[-33,51],[32,50]],1.2]]
		"phone":
			shapes=[[[[-22,-62],[23,-61],[25,24],[-24,25],[-22,-62]],pale]]
			if author=="nemi": shapes=[[[[-23,-60],[-16,-66],[17,-62],[25,-53],[22,19],[15,26],[-17,23],[-25,16],[-23,-60]],pale]]
			lines=[[[[-15,-49],[16,-48],[16,8],[-16,9],[-15,-49]],1.3],[[[-5,16],[5,16]],1.8],[[[-5,-55],[5,-55]],1.3]]
		"mug":
			shapes=[[[[-29,-44],[25,-42],[24,9],[-26,11],[-29,-44]],pale]]
			if author=="nemi": shapes=[[[[-28,-44],[-30,-20],[-25,9],[-6,14],[19,9],[27,-18],[25,-42],[-28,-44]],pale]]
			lines=[[[[25,-34],[43,-30],[44,-6],[24,-4]],2.3],[[[-29,-44],[-10,-48],[25,-42]],2.0]]
		"tabs":
			for i in range(5):
				var x := float(i)*13
				var y := float(i)*-12
				shapes.append([[[x-112,y-72],[x+105,y-75],[x+112,y+62],[x-110,y+67],[x-112,y-72]],pale.lightened(float(i)*0.04)])
				if i==4:
					lines.append([[[x-108,y-45],[x+108,y-48]],1.7])
					lines.append([[[x-95,y-60],[x-74,y-61]],1.8])
		"cloud":
			lines=[[[[-105,28],[-128,8],[-112,-17],[-85,-23],[-84,-52],[-48,-71],[-13,-53],[14,-78],[53,-65],[65,-43],[98,-38],[114,-14],[105,20],[73,39],[-72,42],[-105,28]],2.7]]
		"desk":
			shapes=[[[[-245,0],[237,-2],[242,13],[-247,15],[-245,0]],pale]]
			lines=[[[[-216,15],[-221,177]],3.2],[[[211,13],[215,178]],3.2]]
		_:
			assert(false,"Unknown production prop: "+kind)
	for shape_index in range(shapes.size()):
		var shape: Array=shapes[shape_index]
		var pts := PackedVector2Array()
		for raw in shape[0]: pts.append(Vector2(raw[0],raw[1]))
		node.fills.append({"poly":pts,"col":shape[1],"at":0.0})
		var outline := pts
		if kind=="tabs" and shape_index<4:
			# Back cards expose only a left edge and bottom edge. Their hidden
			# borders must not be inked through the front card's paper fill.
			outline=PackedVector2Array([pts[0]+Vector2(13,0),pts[0],pts[3],pts[2]])
		node.stroke_list.append({"pts":outline,"smooth":author=="nemi" and kind in ["phone","mug"],"w":3.0 if author=="nemi" else 2.6,"col":ink,"pressure":PackedFloat32Array([0.65,1.0,0.85,0.95,0.6])})
	for line in lines:
		var pts := PackedVector2Array()
		for raw in line[0]: pts.append(Vector2(raw[0],raw[1]))
		node.stroke_list.append({"pts":pts,"smooth":kind=="cloud","w":line[1],"col":ink})
	node.prepare()
	return node
