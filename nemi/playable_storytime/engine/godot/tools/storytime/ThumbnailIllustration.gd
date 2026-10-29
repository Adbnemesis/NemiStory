extends RefCounted
## Ordered held illustration primitives through the existing LiveDrawing route.
## Separate components ensure foreground fills correctly cover earlier ink.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Base=preload("res://tools/storytime/ThumbnailStoryArt.gd")

static func done(parent: Node2D,node: Node2D) -> void:
	node.prepare()
	node.progress=1.0
	parent.add_child(node)

static func shape(parent: Node2D,raw: Array,color: String,ink: String="",width: float=5.0) -> void:
	var node=Drawing.new()
	Base.patch(node,raw,color,ink,width)
	done(parent,node)

static func stroke(parent: Node2D,raw: Array,color: String,width: float=5.0) -> void:
	var node=Drawing.new()
	Base.line(node,raw,color,width)
	done(parent,node)

static func oval(parent: Node2D,x: float,y: float,rx: float,ry: float,color: String,ink: String="",width: float=5.0) -> void:
	var raw: Array=[]
	for i in range(49):
		var a=float(i)*TAU/48.0
		raw.append([x+cos(a)*rx,y+sin(a)*ry])
	shape(parent,raw,color,ink,width)

static func rounded(parent: Node2D,raw: Array,color: String,ink: String="",width: float=5.0,tension: float=.16) -> void:
	var pts: PackedVector2Array=Base.points(raw)
	var path=Curve2D.new()
	for i in range(pts.size()+1):
		var k: int=i%pts.size()
		var tangent: Vector2=(pts[(k+1)%pts.size()]-pts[(k-1+pts.size())%pts.size()])*tension
		path.add_point(pts[k],-tangent,tangent)
	var poly=path.tessellate(5,1.7)
	var node=Drawing.new()
	node.fills.append({"poly":poly,"col":Color(color),"at":0.0})
	if ink!="": node.stroke_list.append({"pts":poly,"w":width,"col":Color(ink),"smooth":false,"pressure":PackedFloat32Array([.7,1,.95,.7])})
	done(parent,node)

static func curve(parent: Node2D,raw: Array,color: String,width: float=5.0) -> void:
	var pts: PackedVector2Array=Base.points(raw)
	var path=Curve2D.new()
	for i in range(pts.size()):
		var before: Vector2=pts[maxi(0,i-1)]
		var after: Vector2=pts[mini(pts.size()-1,i+1)]
		var tangent: Vector2=(after-before)*.16
		path.add_point(pts[i],-tangent,tangent)
	var node=Drawing.new()
	node.stroke_list.append({"pts":path.tessellate(5,1.7),"w":width,"col":Color(color),"smooth":false,"pressure":PackedFloat32Array([.6,1,.95,.5])})
	done(parent,node)

static func heart(parent: Node2D,x: float,y: float,size: float,color: String,ink: String="",width: float=5.0) -> void:
	var raw: Array=[]
	for i in range(97):
		var a=float(i)*TAU/96.0
		raw.append([x+pow(sin(a),3.0)*size,y-(13*cos(a)-5*cos(2*a)-2*cos(3*a)-cos(4*a))*size/16.0])
	shape(parent,raw,color,ink,width)

static func burst(parent: Node2D,raw: Array,color: String,ink: String,width: float=5.0) -> void:
	shape(parent,raw,color,ink,width)
