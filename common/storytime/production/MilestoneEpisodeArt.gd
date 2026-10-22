extends RefCounted
## EP17 evidence drawings: stable Nemi ink on the shared LiveDrawing clock.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["milestone_1000_card","milestone_bad_hand","milestone_redraw_hand","milestone_one_frame"]
const INK=Color("#513541")
const ROSE=Color("#ad5e69")
const MUTED=Color("#a18b91")
const PAPER=Color("#fffdf8")

static func line(n: Node2D,raw: Array,col: Color=INK,w: float=3.4,fill: Variant=null,smooth: bool=true) -> void:
	var pts=PackedVector2Array()
	for p in raw:pts.append(Vector2(p[0],p[1]))
	if fill!=null:n.fills.append({"poly":pts,"col":fill,"at":.88})
	n.stroke_list.append({"pts":pts,"col":col,"w":w,"smooth":smooth,"pause":.07,"pressure":PackedFloat32Array([.42,1,.8,.96,.38])})

static func label(n: Node2D,txt: String,pos: Vector2,size: float) -> void:
	var letters=Profile.compose("nemi",txt,size,false)
	for raw in letters.strokes:
		var s: Dictionary=raw.duplicate()
		var points=PackedVector2Array()
		for p in s.pts:points.append(p+pos)
		s.pts=points
		n.stroke_list.append(s)

static func page(n: Node2D) -> void:
	line(n,[[-235,-192],[230,-186],[238,184],[-230,191],[-235,-192]],INK,3.6,PAPER,false)
	line(n,[[-207,-160],[201,-155]],MUTED,2.3,null,false)
	line(n,[[-205,153],[-121,155]],MUTED,2.3)
	line(n,[[143,152],[204,151]],ROSE,2.8)

static func hand(n: Node2D,worse: bool) -> void:
	# A deliberately amateur drawing, never a replacement narrator hand/rig.
	line(n,[[-63,114],[-78,53],[-117,-4],[-125,-34],[-110,-43],[-91,-26],[-70,8],[-58,-92],[-48,-111],[-33,-106],[-24,-88],[-26,-8],[-2,-119],[12,-133],[27,-123],[29,-105],[15,-6],[53,-105],[70,-111],[81,-98],[76,-77],[50,20],[91,-64],[108,-66],[120,-51],[115,-31],[77,71],[46,106],[38,135],[-43,143],[-63,114]],ROSE,4.2,Color("#f1dfc7"))
	line(n,[[-26,38],[-6,58],[28,64],[47,44]],INK,2.5)
	line(n,[[-48,114],[34,107]],MUTED,2.2)
	if worse:
		line(n,[[-57,90],[-101,39],[-120,-19],[-132,-41],[-118,-51],[-98,-41],[-71,4]],MUTED,2.4)
		line(n,[[-33,-102],[-14,-126],[5,-137],[31,-134],[45,-116],[33,-21]],MUTED,2.4)
		line(n,[[52,-104],[80,-120],[98,-106],[94,-79],[69,-12]],MUTED,2.4)
		line(n,[[76,36],[136,1],[148,10],[144,29],[104,65]],ROSE,3.5)
		line(n,[[-80,-127],[-60,-140],[-44,-129]],INK,2.8)
		line(n,[[104,-111],[119,-128],[132,-110]],INK,2.8)

static func make(author: String,kind: String) -> Node2D:
	assert(author=="nemi","Milestone illustrations use Nemi's authored pen")
	var n=Drawing.new()
	match kind:
		"milestone_1000_card":
			line(n,[[-228,-130],[222,-126],[230,135],[-223,142],[-228,-130]],INK,3.5,PAPER,false)
			line(n,[[-226,-76],[223,-73]],MUTED,2.1,null,false)
			line(n,[[-193,-103],[-186,-102]],ROSE,5)
			line(n,[[-163,-102],[-156,-101]],Color("#9eafa0"),5)
			label(n,"1000",Vector2(-142,-22),98)
			line(n,[[-142,90],[-72,86],[3,92],[78,86],[145,90]],ROSE,3.1)
		"milestone_bad_hand","milestone_redraw_hand":
			page(n)
			hand(n,kind=="milestone_redraw_hand")
		"milestone_one_frame":
			page(n)
			line(n,[[-94,87],[-87,-58],[-44,-113],[35,-116],[89,-63],[100,91]],MUTED,2.5)
			line(n,[[-45,-49],[-29,-54],[-15,-46]],INK,3)
			line(n,[[22,-46],[36,-52],[51,-44]],INK,3)
			line(n,[[-15,17],[7,28],[31,16]],ROSE,3)
			line(n,[[-165,118],[-143,92],[-126,117],[-103,80]],Color("#769d87"),4,null,false)
	n.prepare()
	return n
