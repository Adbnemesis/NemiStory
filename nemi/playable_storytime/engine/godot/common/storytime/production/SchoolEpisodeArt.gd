extends RefCounted
## Episode-specific Nemi ink evidence. Existing rig/hand definitions are untouched.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile=preload("res://common/storytime/ProfileAssets.gd")
const Supporting=preload("res://common/storytime/production/SchoolSuspenseArt.gd")
const KINDS=["route_map","route_main","route_detour","school_questions","unknown_contact","sealed_message","bedroom_lamp","window_sightline","evidence_folder","screenshot_stack","school_satchel","mother_phone","clock_light"]
static func line(n: Node2D,raw: Array,col: Color,w: float=3.2,smooth: bool=true,fill: Variant=null) -> void:
	var p=PackedVector2Array()
	for v in raw:p.append(Vector2(v[0],v[1]))
	if fill!=null:n.fills.append({"poly":p,"col":fill,"at":.9})
	n.stroke_list.append({"pts":p,"col":col,"w":w,"smooth":smooth,"pause":.06,"pressure":PackedFloat32Array([.35,1,.78,.94,.25])})
static func make(author: String,kind: String) -> Node2D:
	var n=Drawing.new();var ink=Color(Profile.profile(author).ink);var rose=Color("#b54869");var teal=Color("#579b9a");var gold=Color("#e2ae5a")
	if kind=="route_map":
		line(n,[[-290,-210],[288,-203],[302,206],[-295,218],[-290,-210]],ink,4,false,Color("#fffdf8"))
		# Three recognizable destination silhouettes, not place-name substitutes.
		line(n,[[-260,-131],[-211,-185],[-159,-134],[-163,-64],[-257,-65],[-260,-131]],ink,3,false,Color("#e8efea"))
		line(n,[[-225,-124],[-199,-126],[-197,-65],[-226,-65]],ink,2,false)
		line(n,[[112,-153],[186,-203],[252,-148],[251,-75],[117,-72],[112,-153]],ink,3,false,Color("#f1e3d3"))
		line(n,[[157,-157],[209,-159],[211,-104],[156,-104],[157,-157]],ink,2,false)
		line(n,[[-37,59],[35,59],[42,142],[-39,145],[-37,59]],ink,3,false,Color("#ede9ef"))
		line(n,[[-51,61],[50,59],[42,34],[-40,36],[-51,61]],rose,4,false,Color("#d8b7c0"))
		line(n,[[-240,17],[-118,-7],[40,-18],[227,17]],Color("#c9bcb0"),12)
		line(n,[[-264,167],[-92,164],[102,171],[277,166]],Color("#c9bcb0"),12)
	elif kind=="route_main":
		line(n,[[-207,-61],[-197,8],[-86,13],[74,4],[184,-6],[185,-70]],teal,7)
		line(n,[[166,-52],[185,-70],[201,-49]],teal,6,false)
	elif kind=="route_detour":
		line(n,[[-207,-62],[-236,94],[-176,164],[-24,172],[92,130],[114,60],[199,49],[185,-74]],rose,7)
		line(n,[[171,-52],[185,-74],[201,-49]],rose,6,false)
		line(n,[[-68,-4],[-6,36],[-76,31],[-7,-10]],rose,5,false)
	elif kind=="school_questions":
		line(n,[[-226,-169],[225,-162],[232,182],[-234,187],[-226,-169]],ink,4,false,Color("#fffdf8"))
		# Home outline, clock and two companion silhouettes encode intrusive questions.
		line(n,[[-184,-45],[-124,-112],[-64,-44],[-68,34],[-179,35],[-184,-45]],teal,4,false)
		line(n,[[-139,-22],[-107,-20],[-110,35],[-138,35]],teal,3,false)
		line(n,[[65,-105],[110,-125],[155,-108],[176,-70],[164,-24],[124,-6],[78,-19],[53,-58],[65,-105]],rose,4)
		line(n,[[117,-103],[121,-59],[151,-43]],rose,4,false)
		for x in [-98,58]:
			line(n,[[x-20,96],[x-22,70],[x-7,54],[x+13,56],[x+23,73],[x+20,94],[x-20,96]],ink,3,true)
			line(n,[[x-28,149],[x-21,107],[x+22,108],[x+31,148]],ink,3,true)
	elif kind=="unknown_contact":
		line(n,[[-175,-139],[179,-133],[180,139],[-178,147],[-175,-139]],ink,4,false,Color("#f1e8ec"))
		line(n,[[-43,-75],[-55,-47],[-49,-21],[-23,-4],[5,-12],[23,-34],[18,-61],[-3,-77],[-43,-75]],ink,4)
		line(n,[[-87,80],[-63,22],[-4,3],[62,19],[82,73]],ink,5)
		line(n,[[95,-37],[98,-55],[114,-65],[135,-48],[126,-28],[109,-15],[112,4]],rose,5)
		line(n,[[111,20],[113,23]],rose,6)
	elif kind=="sealed_message":
		line(n,[[-185,-126],[189,-117],[192,125],[-183,133],[-185,-126]],ink,4,false,Color("#f3e4d5"))
		line(n,[[-184,-118],[1,39],[190,-113]],ink,4,false)
		line(n,[[-175,124],[-40,4]],ink,3,false)
		line(n,[[185,121],[47,2]],ink,3,false)
		line(n,[[-44,25],[-20,3],[19,1],[43,19],[48,64],[29,87],[-19,88],[-45,67],[-44,25]],rose,5,true,Color("#d4a7b9"))
		line(n,[[-12,38],[-3,31],[9,35],[9,49],[3,55],[8,68],[-8,68],[-3,53],[-12,38]],ink,3,false)
	elif kind=="bedroom_lamp":
		line(n,[[-41,82],[37,82],[47,100],[-51,102],[-41,82]],ink,4,false,Color("#7aa9a1"))
		line(n,[[0,80],[0,-57]],ink,9,false)
		line(n,[[-90,-66],[92,-63],[60,-160],[-60,-165],[-90,-66]],ink,4,false,gold)
		line(n,[[57,-63],[55,-15]],ink,3,false)
		line(n,[[53,-16],[58,-15]],rose,7,false)
		for raw in [[[112,-104],[144,-92]],[[95,-175],[117,-202]],[[-108,-107],[-143,-99]],[[-87,-177],[-112,-205]]]:line(n,raw,gold,5,false)
	elif kind=="window_sightline":
		line(n,[[-240,162],[-115,99],[43,30],[194,-87]],rose,5)
		line(n,[[168,-89],[194,-87],[180,-59]],rose,5,false)
		line(n,[[139,-166],[214,-164],[231,-117],[216,-66],[162,-54],[125,-88],[122,-131],[139,-166]],rose,4)
	elif kind=="evidence_folder":
		line(n,[[-227,-90],[-142,-96],[-106,-135],[40,-133],[83,-90],[227,-87],[233,132],[-224,141],[-227,-90]],ink,4,false,Color("#dec7aa"))
		line(n,[[-200,-81],[201,-79],[205,107],[-196,116],[-200,-81]],ink,3,false,Color("#fffdf8"))
		line(n,[[-131,-46],[-46,-47],[-31,30],[-138,32],[-131,-46]],rose,4,false)
		line(n,[[-21,-42],[143,-43]],ink,3)
		line(n,[[-17,-8],[160,-8]],ink,2)
		line(n,[[-129,73],[-108,94],[-70,53]],teal,6,false)
	elif kind=="screenshot_stack":
		for i in range(3):
			var x: float=i*24;var y: float=i*-23
			line(n,[[x-88,y-127],[x+90,y-124],[x+94,y+125],[x-89,y+127],[x-88,y-127]],ink,3,false,Color("#fffdf8"))
			line(n,[[x-56,y-91],[x+47,y-89],[x+49,y-38],[x-55,y-35],[x-56,y-91]],teal,3,false)
			line(n,[[x-54,y+4],[x+58,y+3]],rose,3)
			line(n,[[x-51,y+40],[x+52,y+38]],ink,2)
	elif kind=="school_satchel":
		line(n,[[-65,-48],[-45,-89],[47,-92],[67,-45]],ink,6)
		line(n,[[-105,-55],[103,-59],[115,118],[-108,121],[-105,-55]],ink,4,false,Color("#ded3ce"))
		line(n,[[-90,-48],[-88,25],[85,20],[88,-51]],ink,3,false)
		line(n,[[-43,30],[45,28],[47,88],[-42,91],[-43,30]],ink,3,false,Color("#e7d8ca"))
		for x in [-65,67]:line(n,[[x,-1],[x,37]],Color("#edc76e"),5,false)
	elif kind=="clock_light":
		line(n,[[-91,-75],[-18,-102],[57,-78],[88,-13],[62,69],[-8,99],[-83,69],[-105,-7],[-91,-75]],ink,4,true,Color("#f2ce7f"))
		line(n,[[0,-66],[0,0],[53,25]],rose,6,false)
		for raw in [[[0,-82],[0,-70]],[[71,0],[60,0]],[[0,77],[0,62]],[[-82,0],[-67,0]]]:line(n,raw,ink,3,false)
	elif kind=="mother_phone":
		n.free()
		n=Supporting.make(author,"nemi_mother")
		var phone=Drawing.new();var palm=Drawing.new()
		line(phone,[[49,-304],[77,-302],[80,-245],[48,-244],[49,-304]],ink,2,false,Color("#7aa9a1"))
		line(phone,[[53,-296],[73,-296],[74,-258],[52,-257],[53,-296]],ink,1.4,false,Color("#fffdf8"))
		line(palm,[[54,-275],[74,-270],[71,-245],[63,-236],[51,-247],[54,-275]],ink,2.5,true,Color("#ead4be"))
		phone.prepare();phone.progress=1;palm.prepare();palm.progress=1;n.add_child(phone);n.add_child(palm)
	n.prepare()
	# A question/contact is drawn on a held piece of coloured paper. Keep that
	# substrate visible while its ink is authored; other fills arrive late.
	if kind in ["school_questions","unknown_contact","sealed_message"] and not n.fills.is_empty():
		n.fills[0]["at"]=0.0
	return n
