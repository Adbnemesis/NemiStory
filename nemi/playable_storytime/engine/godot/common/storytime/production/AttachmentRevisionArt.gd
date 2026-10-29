extends RefCounted
## Nemi EP15 revision art. Geometry is authored once and played only by LiveDrawing.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile=preload("res://common/storytime/ProfileAssets.gd")
const Original=preload("res://common/storytime/production/AttachmentEpisodeArt.gd")
const KINDS=[
	"attachment_contract_scroll","attachment_contract_seal","attachment_time_apart",
	"attachment_journey_friends","attachment_journey_route","attachment_cafe_conversation",
	"attachment_cafe_cup_one","attachment_cafe_cup_two","attachment_cafe_cup_three",
	"attachment_busy_pair","attachment_busy_first","attachment_busy_second","attachment_life_calendar",
	"attachment_school_message_build","attachment_school_message_frame","attachment_school_message_first",
	"attachment_school_message_second","attachment_school_message_reply","attachment_message_edit",
	"attachment_message_edit_crossout","attachment_neeko_care","attachment_memory_drawer",
	"attachment_memory_keepsakes","attachment_memory_overflow","attachment_worth_reply","attachment_worth_heart"
]
const INK=Color("#513541")
const ROSE=Color("#ad5e69")
const MUTED=Color("#a18b91")
const PAPER=Color("#fffdf8")
const SAGE=Color("#9eafa0")
const WASH=Color("#f1e3dc")

static func line(n: Node2D,raw: Array,col: Color=INK,w: float=3.5,fill: Variant=null,smooth: bool=true) -> void:
	var pts=PackedVector2Array()
	for p in raw:pts.append(Vector2(p[0],p[1]))
	if fill!=null:n.fills.append({"poly":pts,"col":fill,"at":.88})
	n.stroke_list.append({"pts":pts,"col":col,"w":w,"smooth":smooth,"pause":.07,"pressure":PackedFloat32Array([.42,1,.8,.96,.38])})

static func label(n: Node2D,txt: String,pos: Vector2,size: float,accent: bool=false) -> void:
	var letters=Profile.compose("nemi",txt,size,accent)
	for raw in letters.strokes:
		var s: Dictionary=raw.duplicate()
		var points=PackedVector2Array()
		for p in s.pts:points.append(p+pos)
		s.pts=points
		n.stroke_list.append(s)

static func heart(n: Node2D,x: float,y: float,s: float=1.0,col: Color=ROSE,fill: Variant=null) -> void:
	var points=[]
	for p in [[0,-19],[-19,-42],[-43,-39],[-57,-18],[-47,9],[0,55],[47,9],[57,-18],[43,-39],[19,-42],[0,-19]]:
		points.append([x+p[0]*s,y+p[1]*s])
	line(n,points,col,3.6,fill)

static func portrait(n: Node2D,x: float,y: float,s: float=1.0) -> void:
	line(n,[[x-29*s,y-7*s],[x-32*s,y-39*s],[x-18*s,y-59*s],[x+10*s,y-62*s],[x+30*s,y-40*s],[x+29*s,y-11*s],[x+12*s,y+9*s],[x-9*s,y+12*s],[x-29*s,y-7*s]],MUTED,2.7,Color("#eee2d6"))
	line(n,[[x-57*s,y+67*s],[x-47*s,y+31*s],[x-21*s,y+15*s],[x+20*s,y+17*s],[x+49*s,y+34*s],[x+57*s,y+67*s]],MUTED,3,null)
	line(n,[[x-11*s,y-24*s],[x-9*s,y-22*s]],INK,3.8)
	line(n,[[x+12*s,y-24*s],[x+14*s,y-22*s]],INK,3.8)
	line(n,[[x-8*s,y-4*s],[x+1*s,y],[x+10*s,y-5*s]],ROSE,2.5)

static func cup(n: Node2D,x: float,y: float,s: float=1.0) -> void:
	line(n,[[x-35*s,y-53*s],[x+34*s,y-53*s],[x+29*s,y-9*s],[x+15*s,y+1*s],[x-20*s,y],[x-29*s,y-10*s],[x-35*s,y-53*s]],ROSE,3.4,PAPER)
	line(n,[[x+35*s,y-45*s],[x+55*s,y-44*s],[x+58*s,y-25*s],[x+47*s,y-13*s],[x+30*s,y-12*s]],ROSE,3)
	line(n,[[x-48*s,y+7*s],[x-31*s,y+15*s],[x+30*s,y+15*s],[x+46*s,y+6*s]],MUTED,2.8)
	line(n,[[x-23*s,y-46*s],[x+25*s,y-45*s]],Color("#cdb4a1"),2.2)
	line(n,[[x-8*s,y-69*s],[x-15*s,y-83*s],[x-6*s,y-97*s]],MUTED,2.5)

static func phone_frame(n: Node2D) -> void:
	line(n,[[-248,-228],[-233,-242],[227,-237],[244,-218],[239,211],[224,231],[-229,235],[-246,217],[-248,-228]],INK,4.2,PAPER)
	line(n,[[-224,-188],[220,-184],[218,187],[-223,192],[-224,-188]],MUTED,2.3,null,false)
	line(n,[[-36,-215],[35,-213]],INK,3.2)
	line(n,[[-23,212],[27,211]],INK,3.5)

static func school_first(n: Node2D) -> void:
	line(n,[[-184,-153],[176,-150],[184,-138],[181,-62],[144,-61],[144,-37],[113,-60],[-182,-58],[-190,-70],[-184,-153]],ROSE,3.5,WASH)
	for p in [[-158,-124,145,-123],[-157,-91,97,-90]]:
		line(n,[[p[0],p[1]],[p[2],p[3]]],ROSE,3)
	line(n,[[156,-98],[157,-116]],ROSE,3)
	line(n,[[157,-88],[158,-86]],ROSE,4)

static func school_second(n: Node2D) -> void:
	line(n,[[-144,-23],[177,-23],[184,-10],[182,67],[147,68],[147,91],[116,68],[-142,70],[-151,56],[-144,-23]],ROSE,3.5,Color("#f5e8df"))
	line(n,[[-118,6],[146,7]],ROSE,3)
	line(n,[[-118,40],[84,40]],ROSE,3)
	heart(n,116,39,.23,ROSE)

static func school_reply(n: Node2D) -> void:
	line(n,[[-181,117],[-55,117],[-45,128],[-45,162],[-66,171],[-148,171],[-168,187],[-165,170],[-184,168],[-189,154],[-181,117]],INK,3.2,Color("#eeeae3"))
	line(n,[[-163,144],[-81,144]],MUTED,3)

static func busy(n: Node2D,second: bool) -> void:
	var x: float=102 if second else -65
	var y: float=107 if second else -103
	line(n,[[x-174,y-67],[x+151,y-65],[x+162,y-53],[x+160,y+37],[x+137,y+49],[x-88,y+51],[x-124,y+83],[x-121,y+49],[x-174,y+50],[x-185,y+37],[x-184,y-53],[x-174,y-67]],INK,3.7,Color("#f1eae3") if second else PAPER)
	if second:
		line(n,[[x-141,y-30],[x-90,y-30],[x-89,y+23],[x-143,y+24],[x-141,y-30]],MUTED,2.6,null,false)
		line(n,[[x-140,y-15],[x-91,y-15]],MUTED,2.1)
		line(n,[[x-131,y-43],[x-131,y-24]],MUTED,3)
		line(n,[[x-101,y-43],[x-100,y-25]],MUTED,3)
		line(n,[[x-129,y-1],[x-102,y+15]],ROSE,2.7)
		line(n,[[x-103,y-1],[x-130,y+15]],ROSE,2.7)
	else:
		line(n,[[x-146,y-6],[x-138,y-30],[x-115,y-40],[x-94,y-29],[x-86,y-5],[x-96,y+18],[x-119,y+25],[x-140,y+14],[x-146,y-6]],MUTED,2.8)
		line(n,[[x-116,y-29],[x-116,y-6],[x-100,y+4]],ROSE,3,null,false)
	line(n,[[x-58,y-24],[x+128,y-24]],INK,3.5)
	line(n,[[x-58,y+10],[x+68,y+11]],MUTED,3)

static func photo(n: Node2D,x: float,y: float,s: float=1.0) -> void:
	line(n,[[x-58*s,y-74*s],[x+59*s,y-73*s],[x+61*s,y+72*s],[x-60*s,y+74*s],[x-58*s,y-74*s]],INK,2.8,PAPER,false)
	portrait(n,x,y-2*s,.58*s)

static func memory_keepsakes(n: Node2D) -> void:
	photo(n,-135,-95,.93)
	line(n,[[-21,-161],[108,-158],[119,-145],[116,-80],[60,-78],[36,-54],[37,-79],[-19,-78],[-21,-161]],ROSE,3.1,WASH)
	line(n,[[0,-135],[91,-134]],ROSE,2.5)
	line(n,[[0,-108],[63,-107]],ROSE,2.5)
	# Cream/ginger cat keepsake is a symbolic portrait, not a new animal rig.
	line(n,[[147,-61],[137,-119],[162,-102],[188,-106],[216,-124],[211,-67],[225,-40],[215,-9],[192,8],[159,3],[139,-18],[135,-40],[147,-61]],INK,3.2,Color("#fbf8f3"))
	line(n,[[147,-61],[137,-119],[162,-102],[172,-74],[150,-49]],Color("#c85a3a"),7)
	line(n,[[153,-40],[160,-44],[166,-39]],INK,2.8)
	line(n,[[192,-40],[199,-44],[205,-39]],INK,2.8)
	line(n,[[176,-21],[185,-21],[181,-14],[176,-21]],ROSE,2.3)
	line(n,[[180,-14],[173,-7],[166,-10]],INK,2.2)
	line(n,[[181,-14],[189,-7],[196,-11]],INK,2.2)

static func make(author: String,kind: String) -> Node2D:
	assert(author=="nemi","Attachment revision illustrations are Nemi-only.")
	assert(kind in KINDS,"Unknown attachment revision kind: "+kind)
	var n=Drawing.new()
	match kind:
		"attachment_contract_scroll":
			line(n,[[-205,-193],[184,-193],[202,-178],[201,147],[235,149],[235,170],[224,183],[202,174],[-205,174],[-205,-193]],INK,4,PAPER)
			line(n,[[-205,-193],[-223,-183],[-226,-161],[-211,-149],[-193,-155],[-191,-177],[-206,-184]],INK,3.6,Color("#eadbc8"))
			line(n,[[-205,-148],[-205,174],[204,174]],INK,3.7,null,false)
			label(n,"lifetime",Vector2(-133,-137),43,true)
			for p in [[-160,-60,157,-58],[-160,-22,132,-20],[-159,17,162,20],[-159,57,61,58]]:
				line(n,[[p[0],p[1]],[p[2],p[3]]],MUTED,2.8)
			line(n,[[-151,133],[-20,133]],INK,2.8)
			line(n,[[-144,118],[-122,105],[-94,122],[-70,105],[-41,121]],ROSE,3.2)
		"attachment_contract_seal":
			line(n,[[104,92],[90,126],[99,153],[126,163],[154,153],[162,125],[150,99],[127,89],[104,92]],ROSE,3.7,Color("#e4b9b5"))
			heart(n,126,124,.36,INK)
			line(n,[[106,155],[98,193],[124,181],[143,196],[148,157]],ROSE,3.3,Color("#edcfbf"),false)
		"attachment_time_apart":
			for i in range(3):
				var x: float=i*18-27
				var y: float=i*-14+30
				line(n,[[x-172,y-142],[x+162,y-139],[x+169,y+130],[x-177,y+135],[x-172,y-142]],MUTED,3,PAPER,false)
			line(n,[[-159,-111],[160,-109]],INK,3)
			for x in [-93,96]:line(n,[[x,-176],[x+1,-133]],INK,5)
			label(n,"2-3",Vector2(-77,-83),62,true)
			label(n,"years",Vector2(-86,-2),39)
			portrait(n,-86,74,.42)
			portrait(n,79,75,.42)
			line(n,[[-41,71],[-4,87],[35,72]],ROSE,3)
		"attachment_journey_friends":
			line(n,[[-236,59],[-227,44],[-98,44],[-84,61],[-87,165],[-101,178],[-224,178],[-238,161],[-236,59]],INK,3.8,Color("#e9decd"))
			line(n,[[-190,43],[-187,15],[-144,14],[-141,43]],INK,3.5,null,false)
			for x in [-212,-111]:line(n,[[x,51],[x,171]],MUTED,2.8)
			line(n,[[-219,182],[-218,192]],INK,5)
			line(n,[[-105,180],[-104,191]],INK,5)
			for p in [[113,-98],[212,46]]:
				portrait(n,p[0],p[1],.66)
				line(n,[[p[0]-12,p[1]+49],[p[0],p[1]+80],[p[0]+13,p[1]+48]],ROSE,3.5)
		"attachment_journey_route":
			line(n,[[-143,11],[-126,-38],[-78,-89],[-40,-63],[-38,-13],[0,-4],[34,-53],[64,-88]],ROSE,4.5)
			line(n,[[47,-87],[68,-93],[65,-71]],ROSE,3.8,null,false)
			line(n,[[4,-3],[44,45],[82,43],[111,73],[157,91]],ROSE,3.5)
			line(n,[[138,98],[160,92],[149,73]],ROSE,3.4,null,false)
		"attachment_cafe_cup_one":
			cup(n,1120,631,.77)
		"attachment_cafe_cup_two":
			cup(n,1335,613,.76)
		"attachment_cafe_cup_three":
			cup(n,1555,634,.77)
		"attachment_cafe_conversation":
			# Transparent thought arcs; cups are separate world-aligned overlays.
			line(n,[[-207,-139],[-99,-159],[1,-133],[107,-145],[212,-121]],ROSE,4)
			line(n,[[192,-143],[215,-121],[190,-108]],ROSE,3.3,null,false)
			line(n,[[190,-53],[95,-30],[-4,-53],[-112,-38],[-207,-61]],MUTED,3.2)
			line(n,[[-190,-41],[-212,-62],[-186,-76]],MUTED,3,null,false)
			for item in [[-155,-193],[6,-202],[163,-181]]:
				heart(n,item[0],item[1],.22,ROSE)
		"attachment_busy_pair":
			busy(n,false)
			busy(n,true)
		"attachment_busy_first":
			busy(n,false)
		"attachment_busy_second":
			busy(n,true)
		"attachment_life_calendar":
			line(n,[[-226,-188],[112,-185],[122,159],[-229,166],[-226,-188]],INK,3.8,PAPER,false)
			line(n,[[-227,-128],[115,-125]],INK,3)
			for x in [-155,45]:line(n,[[x,-211],[x+1,-166]],INK,5)
			for x in [-143,-61,21]:line(n,[[x,-98],[x+2,137]],MUTED,1.7,null,false)
			for y in [-40,21,82]:line(n,[[-204,y],[95,y+2]],MUTED,1.7,null,false)
			for r in [[-193,-90,-158,-63],[-48,-27,4,6],[-130,95,-81,123]]:
				line(n,[[r[0],r[1]],[r[2],r[1]],[r[2],r[3]],[r[0],r[3]],[r[0],r[1]]],Color("#bcaa9d"),2.2,Color("#eee6dc"),false)
			line(n,[[93,-48],[119,-89],[166,-101],[208,-77],[227,-37],[218,11],[176,34],[128,25],[98,-4],[93,-48]],ROSE,3.8,Color("#f4e4dc"))
			line(n,[[161,-77],[161,-34],[194,-15]],INK,4,null,false)
			line(n,[[150,55],[191,70],[213,110]],MUTED,3)
			line(n,[[197,101],[214,113],[216,91]],MUTED,3,null,false)
		"attachment_school_message_frame":
			phone_frame(n)
		"attachment_school_message_first":
			school_first(n)
		"attachment_school_message_second":
			school_second(n)
		"attachment_school_message_reply":
			school_reply(n)
		"attachment_school_message_build":
			phone_frame(n)
			school_first(n)
			school_second(n)
			school_reply(n)
		"attachment_message_edit":
			line(n,[[-224,-175],[212,-170],[224,-153],[220,105],[169,107],[151,149],[133,109],[-220,113],[-232,96],[-224,-175]],INK,3.8,PAPER)
			for y in [-126,-75,-24]:line(n,[[-185,y],[117 if y==-24 else 173,y+2]],ROSE,3.5)
			for x in [114,147,179]:
				line(n,[[x,13],[x-1,51]],ROSE,4)
				line(n,[[x,67],[x,70]],ROSE,5)
			line(n,[[-186,65],[-40,65]],MUTED,3)
			# A separate eraser, not an invented literal message quotation.
			line(n,[[-197,167],[-140,133],[-95,159],[-153,196],[-197,167]],INK,3.2,Color("#e6bdba"),false)
			line(n,[[-166,148],[-121,176]],INK,2.3,null,false)
		"attachment_message_edit_crossout":
			line(n,[[95,0],[112,34],[131,-2],[146,37],[166,-1],[181,36],[199,1]],ROSE,4.4,null,false)
			line(n,[[92,53],[201,10]],ROSE,3.2)
			line(n,[[-107,180],[-75,183]],MUTED,2.5)
			line(n,[[-91,193],[-57,194]],MUTED,2.5)
		"attachment_neeko_care":
			# Cushion and bowl sit on one stable drawn baseline. Cat geometry is
			# transformed from the existing canonical EP15 memory illustration.
			line(n,[[-231,177],[-219,144],[-180,128],[-146,140]],MUTED,3.3,Color("#eadaca"))
			line(n,[[48,143],[80,134],[106,155],[109,184],[68,202],[-176,204],[-218,193],[-231,177]],MUTED,3.3,Color("#eadaca"))
			line(n,[[-195,181],[-140,189],[-68,187],[14,191],[78,180]],Color("#c6afa0"),2.3)
			var cat=Original.make("nemi","attachment_neeko")
			for raw in cat.fills:
				var f: Dictionary=raw.duplicate()
				var points=PackedVector2Array()
				for p in f.poly:points.append(p*.72+Vector2(-59,45))
				f.poly=points
				n.fills.append(f)
			for raw in cat.stroke_list:
				var s: Dictionary=raw.duplicate()
				var points=PackedVector2Array()
				for p in s.pts:points.append(p*.72+Vector2(-59,45))
				s.pts=points
				s.w=float(s.w)*.85
				n.stroke_list.append(s)
			cat.free()
			line(n,[[112,141],[228,140],[211,191],[130,193],[112,141]],INK,3.5,Color("#eee2cd"))
			line(n,[[112,141],[128,126],[210,126],[228,140],[210,151],[131,152],[112,141]],INK,3.2,PAPER)
			line(n,[[132,137],[151,133],[182,133],[208,138]],Color("#b39278"),6)
			heart(n,171,171,.18,ROSE)
		"attachment_memory_drawer":
			line(n,[[-227,-59],[205,-60],[237,17],[231,151],[-224,158],[-247,22],[-227,-59]],INK,3.7,Color("#eee1d1"),false)
			line(n,[[-227,-59],[-191,-99],[173,-101],[205,-60]],MUTED,3.1,PAPER,false)
			line(n,[[-247,22],[-204,-18],[186,-19],[237,17],[-247,22]],INK,3.5,Color("#e2cfbd"),false)
			line(n,[[-247,22],[-235,170],[230,164],[237,17]],INK,3.5,null,false)
			line(n,[[-55,77],[45,76],[46,110],[-55,111],[-55,77]],MUTED,3,PAPER,false)
			line(n,[[-25,93],[19,93]],MUTED,3.4)
		"attachment_memory_keepsakes":
			memory_keepsakes(n)
		"attachment_memory_overflow":
			photo(n,-251,-4,.68)
			line(n,[[198,25],[267,-4],[287,17],[284,80],[262,80],[249,101],[248,81],[207,80],[198,25]],ROSE,3.2,WASH)
			line(n,[[219,24],[266,25]],ROSE,2.8)
			line(n,[[220,49],[257,49]],ROSE,2.8)
			line(n,[[-119,-174],[-129,-202]],ROSE,3.4)
			line(n,[[-85,-171],[-81,-209]],ROSE,3.4)
			line(n,[[15,-180],[34,-205]],ROSE,3.4)
		"attachment_worth_reply":
			# A quiet reply and a loose implication arrow; no written verdict.
			line(n,[[-238,-156],[26,-153],[37,-140],[33,-49],[-7,-44],[-31,-15],[-29,-45],[-235,-42],[-246,-56],[-244,-142],[-238,-156]],INK,3.8,PAPER)
			line(n,[[-207,-106],[-38,-104]],MUTED,3.5)
			line(n,[[-206,-77],[-118,-77]],MUTED,3)
			line(n,[[53,-82],[94,-64],[105,-24],[82,9],[78,44],[112,74]],MUTED,3.1)
			line(n,[[92,72],[115,77],[111,54]],MUTED,3,null,false)
			line(n,[[-205,154],[213,153]],Color("#d7c7bf"),2.5)
		"attachment_worth_heart":
			heart(n,124,99,1.10,ROSE,Color("#efdad4"))
			line(n,[[111,139],[98,112],[119,88],[144,112],[128,139]],INK,3.2)
	n.prepare()
	return n

