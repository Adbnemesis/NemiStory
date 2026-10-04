extends RefCounted
## Held story-specific evidence pictures; stroke revelation uses the shared LiveDrawing.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["crush_heart","wrong_homework","clue_board","ban_stamp","prank_plan","blank_classwork"]
static func make(author: String,kind: String) -> Node2D:
	var shapes: Array=[]
	var lines: Array=[]
	var paper=Color("#faf3e5")
	var brown=Color("#b89e7e")
	var blue=Color("#9bb8bd")
	var red=Color("#a8736e")
	match kind:
		"crush_heart":
			shapes=[[[[0,64],[-67,4],[-77,-30],[-61,-56],[-31,-62],[0,-37],[32,-63],[61,-56],[78,-29],[66,5],[0,64]],red]]
			lines=[[[[-44,-43],[-60,-28],[-57,-9]],3.0],[[[-91,-63],[-111,-80]],3.0],[[[90,-57],[110,-70]],3.0]]
		"wrong_homework", "blank_classwork":
			shapes=[[[[-181,-211],[163,-219],[183,205],[-169,215],[-181,-211]],brown],[[[-166,-197],[150,-203],[165,190],[-154,199],[-166,-197]],paper]]
			lines=[[[[-137,-148],[85,-153]],3.0],[[[-133,27],[110,24]],2.0],[[[-133,65],[109,63]],2.0],[[[-131,104],[105,100]],2.0],[[[-129,145],[107,143]],2.0]]
			if kind=="wrong_homework":
				lines.append([[[ -125,-69],[-105,-83],[-84,-68],[-105,-48],[-125,-28],[-84,-28]],4.0])
				lines.append([[[ -57,-59],[-22,-60]],3.0])
				lines.append([[[ -41,-77],[-40,-41]],3.0])
				lines.append([[[ 4,-79],[24,-83],[37,-65],[29,-45],[8,-26],[42,-27]],4.0])
				lines.append([[[ 67,-62],[95,-62]],3.0])
				lines.append([[[ 68,-47],[94,-47]],3.0])
				lines.append([[[ 122,-84],[105,-60],[123,-61],[130,-41],[121,-27],[106,-32]],4.0])
				lines.append([[[ -146,-114],[145,-11]],4.0,red])
				lines.append([[[ -141,-7],[143,-109]],4.0,red])
		"clue_board":
			shapes=[[[[-289,-219],[276,-225],[291,227],[-282,231],[-289,-219]],brown],[[[-270,-201],[259,-205],[273,208],[-262,213],[-270,-201]],Color("#d2bfa1")]]
			# Three pinned memories: lunch, conversation, homework. Purposefully uneven paper.
			for card in [[-227,-156,-66,-23],[39,-165,215,-20],[-98,60,104,185]]:
				var x:float=card[0];var y:float=card[1];var r:float=card[2];var b:float=card[3]
				shapes.append([[[x,y],[r,y-3],[r+4,b],[x-3,b+2],[x,y]],paper])
				shapes.append([[[x+72,y-8],[x+81,y-9],[x+84,y+1],[x+74,y+3],[x+72,y-8]],red])
			shapes.append([[[ -208,-64],[-183,-101],[-127,-102],[-101,-67],[-208,-64]],Color("#dab985")])
			lines.append([[[ -204,-60],[-172,-50],[-143,-54],[-104,-58]],4.0])
			lines.append([[[ 68,-92],[101,-109],[131,-91]],2.8])
			lines.append([[[ 145,-82],[173,-101],[198,-82]],2.8])
			lines.append([[[ 79,-76],[100,-67],[120,-78]],2.8])
			lines.append([[[ 150,-66],[175,-57],[195,-69]],2.8])
			lines.append([[[ -65,86],[74,86]],2.7])
			lines.append([[[ -63,116],[66,115]],2.0])
			lines.append([[[ -62,143],[20,141],[37,126],[53,154],[73,138]],2.0])
			lines.append([[[ -149,-161],[-26,-37],[123,-166]],2.4,red])
			lines.append([[[ 125,-163],[26,58],[-148,-162]],2.4,red])
		"ban_stamp":
			lines=[[[[-163,-53],[161,-58],[167,58],[-159,62],[-163,-53]],5.0,red],[[[-151,-41],[149,-46],[154,45],[-147,48]],2.0,red]]
		"prank_plan":
			shapes=[[[[-234,-200],[222,-207],[237,203],[-229,211],[-234,-200]],paper]]
			lines=[[[[-186,-139],[172,-145]],3.0],[[[-177,-42],[149,-41]],2.0],[[[-178,44],[151,39]],2.0],[[[-175,127],[154,122]],2.0]]
			for y in [-91,-6,78]:lines.append([[[ -180,y],[-170,y+9],[-150,y-13]],3.2,red])
	var node=Drawing.new()
	var ink=Color(Assets.profile(author).ink)
	for shape in shapes:
		var pts=PackedVector2Array()
		for p in shape[0]:pts.append(Vector2(p[0],p[1]))
		node.fills.append({"poly":pts,"col":shape[1],"at":0.0})
		node.stroke_list.append({"pts":pts,"w":2.8,"col":ink,"smooth":false,"pressure":PackedFloat32Array([.65,1,.85,.9,.5])})
	for line in lines:
		var pts=PackedVector2Array()
		for p in line[0]:pts.append(Vector2(p[0],p[1]))
		node.stroke_list.append({"pts":pts,"w":line[1],"col":line[2] if line.size()>2 else ink,"smooth":false,"pressure":PackedFloat32Array([.65,.95,.5])})
	node.prepare()
	return node
