extends RefCounted
## ADB-authored school illustrations. Supporting pupils are held art, not replacement rigs.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["school_friend","school_friend_smile","school_friend_laugh","school_classmate","school_classmate_laugh","lunch_box","homework_notes","school_clock"]
static func make(author: String, kind: String) -> Node2D:
	var shapes: Array=[]
	var lines: Array=[]
	var skin=Color("#efd2b4")
	var paper=Color("#faf4e5")
	var blue=Color("#8cabb3")
	var dark=Color("#4c4542")
	if kind.begins_with("school_friend") or kind.begins_with("school_classmate"):
		var girl=kind.begins_with("school_friend")
		var laugh=kind.ends_with("laugh")
		var smile=kind.ends_with("smile")
		# Shoes/legs/garment use the same stable feet origin across expression variants.
		shapes.append([[[-28,-135],[-8,-137],[-8,-12],[-30,-12],[-28,-135]],skin if girl else Color("#68757c")])
		shapes.append([[[14,-137],[34,-133],[35,-12],[13,-12],[14,-137]],skin if girl else Color("#68757c")])
		shapes.append([[[-32,-19],[-6,-19],[-3,-4],[-37,-2],[-46,-6],[-42,-13],[-32,-19]],Color("#f2eee4")])
		shapes.append([[[12,-19],[34,-18],[43,-12],[47,-4],[12,-3],[12,-19]],Color("#f2eee4")])
		if girl:
			shapes.append([[[-36,-166],[39,-165],[57,-116],[-55,-115],[-36,-166]],Color("#737e8d")])
			lines.append([[[ -22,-158],[-32,-120]],1.8])
			lines.append([[[ 18,-158],[29,-119]],1.8])
		# Arms behind torso, then hands. A compact flexed elbow belongs to the laughing illustration.
		if laugh:
			shapes.append([[[37,-244],[53,-235],[65,-199],[34,-236],[28,-250],[37,-244]],blue if girl else Color("#b7baa1")])
			shapes.append([[[27,-251],[33,-263],[43,-260],[45,-248],[36,-235],[27,-251]],skin])
		else:
			shapes.append([[[34,-245],[49,-236],[57,-190],[51,-143],[38,-145],[40,-188],[28,-228],[34,-245]],blue if girl else Color("#b7baa1")])
			shapes.append([[[38,-149],[51,-149],[53,-132],[47,-124],[40,-128],[37,-139],[38,-149]],skin])
		shapes.append([[[-39,-240],[-54,-234],[-61,-189],[-56,-144],[-43,-143],[-43,-188],[-28,-222],[-39,-240]],blue if girl else Color("#b7baa1")])
		shapes.append([[[-56,-149],[-43,-148],[-40,-133],[-46,-124],[-54,-129],[-58,-139],[-56,-149]],skin])
		shapes.append([[[-32,-253],[29,-251],[42,-235],[39,-157],[-37,-155],[-43,-234],[-32,-253]],blue if girl else Color("#b7baa1")])
		shapes.append([[[-13,-258],[14,-258],[16,-237],[0,-230],[-16,-239],[-13,-258]],skin,false])
		shapes.append([[[-17,-245],[0,-231],[19,-245],[22,-231],[3,-219],[-20,-231],[-17,-245]],paper])
		lines.append([[[1,-225],[2,-160]],1.5])
		lines.append([[[18,-209],[31,-209],[31,-194],[18,-194]],1.3])
		# Dark tied-back hair is independent of Nemi's silhouette, palette and face.
		if girl:shapes.append([[[30,-324],[60,-318],[72,-290],[62,-250],[41,-272],[39,-302],[30,-324]],dark])
		shapes.append([[[-41,-303],[-39,-324],[-19,-344],[13,-347],[39,-330],[47,-302],[38,-271],[25,-253],[-4,-246],[-29,-263],[-42,-284],[-41,-303]],skin])
		shapes.append([[[-43,-291],[-48,-318],[-33,-345],[-8,-354],[25,-350],[44,-334],[48,-309],[36,-292],[28,-321],[9,-332],[-13,-319],[-31,-319],[-35,-289],[-43,-291]],dark])
		if not girl:
			shapes.append([[[-40,-326],[-46,-345],[-20,-347],[-2,-361],[14,-345],[30,-347],[43,-332],[31,-320],[-2,-327],[-40,-326]],dark])
		if laugh:
			lines.append([[[ -28,-291],[-19,-297],[-11,-292]],2.8])
			lines.append([[[ 11,-292],[20,-297],[28,-290]],2.8])
			shapes.append([[[-15,-276],[16,-276],[13,-264],[1,-257],[-11,-264],[-15,-276]],Color("#704e48")])
			lines.append([[[ -10,-272],[11,-272]],3.2])
		else:
			lines.append([[[ -29,-294],[-21,-298],[-12,-295]],2.5])
			lines.append([[[ 10,-295],[19,-298],[29,-294]],2.5])
			lines.append([[[ -20,-295],[-20,-289]],3.5])
			lines.append([[[ 19,-295],[19,-289]],3.5])
			lines.append([[[ -29,-305],[-14,-306]],2.0])
			lines.append([[[ 10,-306],[28,-303]],2.0])
			lines.append([[[ -12,-272],[-2,-269],[10,-272]] if smile or not girl else [[-10,-271],[10,-271]],2.0])
		lines.append([[[ -1,-290],[-4,-280],[2,-280]],1.3])
		lines.append([[[ -52,-138],[-49,-133]],1.2])
		if not laugh:lines.append([[[45,-138],[47,-133]],1.2])
	elif kind=="lunch_box":
		shapes=[[[[-108,-37],[89,-41],[111,-18],[110,35],[-109,37],[-119,13],[-108,-37]],blue],[[[-110,-37],[-84,-62],[76,-65],[91,-42],[-110,-37]],Color("#b3c8be")],[[[-78,-46],[-66,-90],[1,-94],[12,-51],[-78,-46]],paper],[[[15,-51],[24,-92],[77,-88],[79,-48],[15,-51]],Color("#ddb477")]]
		lines=[[[[-109,-12],[106,-14]],2.0],[[[-30,-11],[-31,11],[22,11],[23,-13]],2.0],[[[-70,-57],[-4,-61]],3.0],[[[28,-72],[68,-71]],3.0]]
	elif kind=="homework_notes":
		shapes=[[[[-100,-121],[89,-118],[97,111],[-99,116],[-100,-121]],Color("#c7a77b")],[[[-89,-111],[80,-108],[85,100],[-89,106],[-89,-111]],paper]]
		lines=[[[[-59,-80],[49,-80]],2.7],[[[-60,-51],[62,-49]],1.6],[[[-60,-26],[56,-25]],1.6],[[[-60,-1],[40,0]],1.6],[[[-60,25],[60,26]],1.6],[[[-58,51],[-28,51],[-18,40],[-8,62],[6,45],[47,46]],2.0],[[[-64,80],[64,80]],1.6]]
	elif kind=="school_clock":
		shapes=[[[[-46,-40],[-15,-58],[26,-52],[51,-25],[49,21],[21,49],[-25,48],[-53,18],[-56,-16],[-46,-40]],paper]]
		lines=[[[[0,-39],[0,-29]],2.0],[[[35,0],[25,0]],2.0],[[[0,35],[0,26]],2.0],[[[-37,0],[-27,0]],2.0],[[[0,-23],[1,1],[22,12]],3.0]]
	else:assert(false,"Unknown school art kind: "+kind)
	var node=Drawing.new()
	var ink=Color(Assets.profile(author).ink)
	for shape in shapes:
		var pts=PackedVector2Array()
		for p in shape[0]:pts.append(Vector2(p[0],p[1]))
		node.fills.append({"poly":pts,"col":shape[1],"at":0.0})
		if shape.size()<3 or shape[2]:
			node.stroke_list.append({"pts":pts,"w":2.6,"col":ink,"smooth":false,"pressure":PackedFloat32Array([0.65,1,0.85,0.9,0.5])})
	for line in lines:
		var pts=PackedVector2Array()
		for p in line[0]:pts.append(Vector2(p[0],p[1]))
		node.stroke_list.append({"pts":pts,"w":line[1],"col":ink,"smooth":false,"pressure":PackedFloat32Array([0.6,0.95,0.5])})
	node.prepare()
	return node
