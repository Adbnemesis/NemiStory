extends RefCounted
## Nemi supporting art, foot-origin adults and held evidence. Main rigs unchanged.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["teacher_ordinary","teacher_distant","nemi_mother","curtain_closed","window_lit","evidence_phone","school_gate","school_notebook","watching_shadow"]
static func stroke(n: Node2D,p: Array,col: Color,w: float=3.0,fill: Variant=null) -> void:
	var pts=PackedVector2Array()
	for v in p:pts.append(Vector2(v[0],v[1]))
	if fill!=null:n.fills.append({"poly":pts,"col":fill,"at":0.0})
	n.stroke_list.append({"pts":pts,"col":col,"w":w,"smooth":false,"pressure":PackedFloat32Array([0.65,1.0,0.8,0.95,0.5])})
static func make(author: String,kind: String) -> Node2D:
	var n=Drawing.new()
	var ink=Color(Assets.profile(author).ink)
	var skin=Color("#ead4be")
	if kind in ["teacher_ordinary","teacher_distant","nemi_mother","watching_shadow"]:
		var shirt=Color("#aebac0" if kind!="nemi_mother" else "#bca09d")
		if kind=="watching_shadow":shirt=Color("#625c68");skin=shirt
		stroke(n,[[-46,-235],[47,-233],[39,-26],[10,-24],[-2,-168],[-18,-25],[-47,-25],[-46,-235]],ink,3,Color("#777b85"))
		stroke(n,[[-48,-28],[-17,-28],[-9,-8],[-12,0],[-63,0],[-66,-10],[-48,-28]],ink,3,Color("#4c4650"))
		stroke(n,[[11,-28],[40,-28],[59,-11],[60,0],[9,0],[5,-10],[11,-28]],ink,3,Color("#4c4650"))
		stroke(n,[[-33,-429],[30,-430],[60,-393],[53,-235],[-53,-235],[-63,-390],[-33,-429]],ink,3,shirt)
		stroke(n,[[-27,-451],[27,-451],[25,-419],[0,-400],[-26,-419],[-27,-451]],ink,3,skin)
		stroke(n,[[-44,-537],[-26,-561],[19,-561],[45,-537],[46,-484],[27,-455],[-17,-452],[-45,-478],[-44,-537]],ink,3,skin)
		stroke(n,[[-44,-532],[-41,-558],[-13,-579],[27,-571],[47,-546],[44,-516],[25,-531],[-1,-535],[-34,-523],[-44,-532]],ink,3,Color("#625653"))
		stroke(n,[[-60,-392],[-39,-382],[-57,-283],[-53,-252],[-67,-242],[-80,-268],[-77,-316],[-60,-392]],ink,3,shirt)
		stroke(n,[[53,-392],[69,-380],[82,-306],[72,-266],[54,-270],[58,-301],[44,-363],[53,-392]],ink,3,shirt)
		stroke(n,[[-68,-267],[-51,-256],[-50,-229],[-58,-217],[-71,-228],[-74,-251],[-68,-267]],ink,2.8,skin)
		stroke(n,[[54,-279],[74,-272],[71,-239],[63,-228],[51,-240],[54,-279]],ink,2.8,skin)
		if kind!="watching_shadow":
			for p in [[[-33,-499],[-22,-502],[-11,-498]],[[10,-498],[22,-502],[33,-499]],[[-20,-494],[-20,-490]],[[21,-494],[21,-490]],[[1,-492],[-2,-479],[5,-478]],[[-13,-467],[2,-465],[16,-468]],[[-31,-419],[-8,-391],[0,-405],[13,-391],[31,-419]],[[0,-405],[0,-244]]]:stroke(n,p,ink,2)
		if kind=="nemi_mother":
			stroke(n,[[-44,-536],[-51,-496],[-57,-435],[-42,-419],[-35,-474],[-35,-526],[-44,-536]],ink,3,Color("#625653"))
			stroke(n,[[40,-536],[56,-507],[61,-439],[44,-420],[37,-480],[40,-536]],ink,3,Color("#625653"))
	elif kind in ["curtain_closed","window_lit"]:
		stroke(n,[[-179,-231],[182,-229],[187,202],[-184,205],[-179,-231]],ink,3,Color("#e6d9c1"))
		stroke(n,[[-159,-210],[161,-208],[165,183],[-164,185],[-159,-210]],ink,2.5,Color("#ecd499"))
		if kind=="curtain_closed":
			stroke(n,[[-171,-216],[-8,-219],[8,191],[-178,198],[-171,-216]],ink,3,Color("#e6ddd3"))
			stroke(n,[[1,-219],[172,-216],[180,198],[4,192],[1,-219]],ink,3,Color("#d9cec5"))
			for x in [-137,-104,-65,40,80,127]:stroke(n,[[x,-206],[x-6,-32],[x+2,178]],ink,2)
		else:
			stroke(n,[[0,-207],[2,183]],ink,4)
			stroke(n,[[-159,-12],[162,-11]],ink,3)
		stroke(n,[[-197,-245],[201,-243]],ink,6)
		for x in [-151,-99,-47,6,59,113,163]:stroke(n,[[x,-243],[x,-220]],ink,3)
	elif kind=="evidence_phone":
		stroke(n,[[-146,-260],[-121,-280],[119,-277],[146,-254],[143,260],[120,279],[-125,280],[-147,259],[-146,-260]],ink,4,Color("#d1c9c2"))
		stroke(n,[[-127,-236],[126,-235],[125,233],[-125,234],[-127,-236]],ink,2,Color("#faf3e6"))
		stroke(n,[[-26,-253],[29,-253]],ink,4)
		for y in [-162,-53,62]:
			stroke(n,[[-107,y],[100,y-2],[102,y+76],[-108,y+78],[-107,y]],ink,1.5,Color("#d7dfe0"))
			stroke(n,[[-86,y+23],[69,y+24]],ink,2)
			stroke(n,[[-84,y+48],[33,y+48]],ink,2)
	elif kind=="school_gate":
		stroke(n,[[-255,-391],[-224,-394],[-222,0],[-257,0],[-255,-391]],ink,3,Color("#c3b4a1"))
		stroke(n,[[223,-393],[256,-391],[258,0],[221,0],[223,-393]],ink,3,Color("#c3b4a1"))
		stroke(n,[[-225,-355],[224,-354],[226,0],[-227,0],[-225,-355]],ink,3,Color("#e1e7e8"))
		for x in [-192,-143,-93,-43,8,58,109,159,197]:stroke(n,[[x,-348],[x+2,-8]],ink,4)
		for p in [[[-220,-292],[220,-292]],[[-221,-68],[221,-68]],[[0,-354],[0,0]],[[-18,-180],[-3,-180]]]:stroke(n,p,ink,4)
	elif kind=="school_notebook":
		stroke(n,[[-129,-89],[126,-91],[136,83],[-120,91],[-129,-89]],ink,3,Color("#e8d3ab"))
		stroke(n,[[-106,-73],[110,-75],[115,62],[-101,67],[-106,-73]],ink,2,Color("#faf4e7"))
		for y in [-40,-11,19]:stroke(n,[[-79,y],[87,y-2]],ink,1.6)
	n.prepare()
	return n
