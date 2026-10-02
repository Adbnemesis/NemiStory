extends RefCounted
## Held travel objects, authored as stable fill/ink geometry through LiveDrawing.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["suitcase","car","damaged_car","police_car","steering_wheel","boarding_pass","clipboard","flashlight","traffic_cone","tissue_box","seat_front"]
static func make(author: String, kind: String) -> Node2D:
	var shapes: Array=[]
	var lines: Array=[]
	var pale=Color("#f1e6cf")
	var slate=Color("#81999f")
	match kind:
		"car","damaged_car","police_car":
			var rear: Array=[[-309,-98],[-305,18]]
			if kind=="damaged_car": rear=[[-299,-96],[-272,-83],[-292,-58],[-268,-29],[-291,-11],[-275,18]]
			var body: Array=[[-305,18],[-312,-63]]
			body=rear+[[305,18],[319,-24],[297,-86],[208,-111],[116,-215],[-130,-218],[-229,-113],[-309,-98]]
			shapes.append([body,Color("#7d939c" if kind=="police_car" else "#f1e9dc")])
			shapes.append([[[-116,-196],[-204,-116],[-17,-119],[-17,-194],[-116,-196]],Color("#c3d7da")])
			shapes.append([[[4,-194],[103,-193],[176,-119],[4,-119],[4,-194]],Color("#c3d7da")])
			lines=[[[[-11,-110],[-10,11]],2.2],[[[200,-97],[206,10]],2.2],[[[20,-87],[53,-87]],3.2],[[[270,-57],[300,-54]],4.5],[[[-295,-67],[-272,-64]],4.5]]
			for x in [-192,194]:
				var wheel: Array=[]
				for i in range(13):
					var angle=float(i)*TAU/12
					var radius=43.0+float(i%3)
					wheel.append([x+cos(angle)*radius,20+sin(angle)*radius])
				shapes.append([wheel,Color("#514750")])
				var hub: Array=[]
				for i in range(13):
					var angle=float(i)*TAU/12
					hub.append([x+cos(angle)*21,20+sin(angle)*21])
				shapes.append([hub,Color("#ddd6ca")])
			if kind=="police_car":
				shapes.append([[[5,-237],[60,-235],[61,-216],[4,-216],[5,-237]],Color("#c97579")])
				shapes.append([[[61,-235],[112,-236],[113,-215],[61,-216],[61,-235]],Color("#77a2bb")])
				shapes.append([[[38,-80],[65,-91],[91,-79],[88,-45],[65,-27],[40,-43],[38,-80]],pale])
		"suitcase":
			shapes=[[[[-62,-157],[-45,-165],[57,-162],[68,-145],[66,15],[49,30],[-50,27],[-66,9],[-62,-157]],slate],[[[-34,-201],[33,-200],[35,-164],[-34,-164],[-34,-201]],pale]]
			lines=[[[[-37,-136],[-39,1]],2],[[[37,-136],[35,3]],2],[[[-62,-106],[65,-103]],1.5],[[[-46,31],[-44,41]],7],[[[44,30],[45,41]],7]]
		"steering_wheel":
			var outer: Array=[]
			for i in range(17):
				var angle=float(i)*TAU/16
				outer.append([cos(angle)*(106+float(i%2)*2),sin(angle)*105])
			shapes=[[outer,Color("#d2c9be")],[[[-27,-19],[27,-22],[31,22],[-24,25],[-27,-19]],slate]]
			lines=[[[[-27,0],[-98,-19]],10],[[[28,0],[98,-22]],10],[[[3,23],[4,97]],10]]
		"boarding_pass":
			shapes=[[[[-130,-64],[126,-61],[129,54],[-131,59],[-130,-64]],pale]]
			lines=[[[[65,-58],[64,52]],1.8],[[[-104,-33],[-24,-34]],4],[[[-103,-14],[38,-13]],2],[[[-103,15],[-7,14]],2]]
			for x in range(80,116,5): lines.append([[[x,-30],[x,25]],2])
		"clipboard":
			shapes=[[[[-81,-111],[78,-108],[82,109],[-80,112],[-81,-111]],Color("#c8ac82")],[[[-68,-96],[65,-93],[68,95],[-66,97],[-68,-96]],pale],[[[-32,-116],[32,-117],[35,-90],[-35,-89],[-32,-116]],slate]]
			for y in [-59,-22,16,54]: lines.append([[[ -44,y],[48,y+2]],2])
		"flashlight":
			shapes=[[[[-98,-22],[38,-20],[70,-34],[94,-32],[96,30],[70,32],[37,19],[-97,21],[-98,-22]],slate],[[[83,-29],[96,-30],[97,28],[84,29],[83,-29]],pale]]
			lines=[[[[-62,-19],[-64,20]],2],[[[-42,-19],[-43,20]],2]]
		"traffic_cone":
			shapes=[[[[-8,-123],[13,-122],[51,3],[-51,5],[-8,-123]],Color("#c88b68")],[[[-31,-50],[32,-51],[42,-20],[-40,-18],[-31,-50]],pale],[[[-64,4],[62,2],[70,20],[-68,22],[-64,4]],slate]]
		"tissue_box":
			shapes=[[[[-94,-28],[38,-42],[96,-18],[94,48],[-94,47],[-94,-28]],Color("#b6c7bb")],[[[-35,-32],[-45,-100],[-8,-85],[13,-106],[33,-41],[-35,-32]],pale]]
			lines=[[[[-93,-27],[34,-13],[94,-18]],2],[[[35,-12],[34,45]],2],[[[-42,-32],[39,-36]],3]]
		"seat_front":
			shapes=[[[[-175,-230],[-143,-266],[133,-263],[173,-225],[197,198],[-202,201],[-175,-230]],Color("#9cabaa")],[[[-103,-341],[102,-338],[106,-252],[-105,-255],[-103,-341]],Color("#8d9c9b")]]
			lines=[[[[-132,-213],[-144,152],[140,153],[126,-213]],2],[[[-43,-250],[-43,167]],1.5]]
		_:
			assert(false,"Unknown travel prop: "+kind)
	var node=Drawing.new()
	var ink=Color(Assets.profile(author).ink)
	for shape in shapes:
		var pts=PackedVector2Array()
		for p in shape[0]: pts.append(Vector2(p[0],p[1]))
		node.fills.append({"poly":pts,"col":shape[1],"at":0.0})
		node.stroke_list.append({"pts":pts,"w":3.2 if author=="nemi" else 2.6,"col":ink,"smooth":false,"pressure":PackedFloat32Array([0.6,1.0,0.85,0.95,0.45])})
	for line in lines:
		var pts=PackedVector2Array()
		for p in line[0]:pts.append(Vector2(p[0],p[1]))
		node.stroke_list.append({"pts":pts,"w":line[1],"col":ink,"smooth":false,"pressure":PackedFloat32Array([0.5,1.0,0.7])})
	node.prepare()
	return node
