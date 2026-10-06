extends "res://tools/storytime/ThumbnailStoryArt.gd"
## Newly authored cover illustration; the symbolic props are not movie events.
const Base=preload("res://tools/storytime/ThumbnailStoryArt.gd")

static func p(parent: Node2D,raw: Array,col: String,outline: String="",width: float=3.0) -> void:
	var component=Drawing.new()
	Base.patch(component,raw,col,outline,width)
	component.prepare()
	component.progress=1.0
	parent.add_child(component)

static func l(parent: Node2D,raw: Array,col: String,width: float=3.0) -> void:
	var component=Drawing.new()
	Base.line(component,raw,col,width)
	component.prepare()
	component.progress=1.0
	parent.add_child(component)

static func ell(parent: Node2D,x: float,y: float,rx: float,ry: float,col: String) -> void:
	var raw: Array=[]
	for i in range(49):
		var a=float(i)*TAU/48.0
		raw.append([x+cos(a)*rx,y+sin(a)*ry])
	p(parent,raw,col)

static func heart(node: Node2D,x: float,y: float,size: float,col: String,ink: String="",w: float=6.0) -> void:
	var raw: Array=[]
	for i in range(97):
		var t=float(i)*TAU/96.0
		var px=pow(sin(t),3.0)
		var py=-(13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t))/16.0
		raw.append([x+px*size,y+py*size])
	p(node,raw,col,ink,w)

static func arc_line(node: Node2D,cx: float,cy: float,rx: float,ry: float,a: float,b: float,col: String,w: float) -> void:
	var pts: Array=[]
	for i in range(49):
		var t=lerpf(a,b,float(i)/48)
		pts.append([cx+cos(t)*rx,cy+sin(t)*ry])
	l(node,pts,col,w)

static func make(author: String,variant: String,part: String) -> Node2D:
	assert(author=="adb")
	var node=Node2D.new()
	var ink: String=Assets.profile(author).ink
	if part=="background":
		if variant=="a":
			# Asymmetric luminous paper field and windows receding into a vanishing point.
			ell(node,1250,560,860,750,"#fff4e2")
			p(node,[[0,0],[550,0],[825,430],[0,760]],"#a3bed0")
			p(node,[[0,90],[160,70],[760,420],[70,650]],"#dce6e8",ink,5)
			p(node,[[230,25],[395,30],[803,405],[720,432]],"#e4e6f1",ink,4)
			for p in [[[20,310],[784,428]],[[140,80],[751,446]],[[0,790],[803,445]],[[0,1060],[810,500]]]: l(node,p,"#8194ac",5)
			for h in [[720,72,35],[1860,910,48],[45,900,32]]:heart(node,h[0],h[1],h[2],"#eda6b6")
			# A compact speech field, not a headline banner.
			p(node,[[45,30],[730,21],[754,238],[605,249],[632,321],[493,257],[51,264]],"#fff9e9",ink,5)
		else:
			# A theatrical romance target is visibly a comic metaphor.
			heart(node,1335,626,900,"#4a405f")
			heart(node,1335,626,745,"#756078")
			heart(node,1335,626,590,"#ca8c9d")
			heart(node,1335,626,450,"#f3c3bd")
			for p in [[[0,95],[710,422]],[[0,231],[681,478]],[[40,1065],[802,685]],[[1820,1010],[1600,750]]]:l(node,p,"#b7a6bd",9)
			for h in [[752,95,44],[1870,598,50],[34,661,24]]:heart(node,h[0],h[1],h[2],"#ef9dad")
			p(node,[[1370,35],[1870,20],[1887,222],[1751,235],[1757,286],[1658,242],[1371,247]],"#fff1d9",ink,6)
	elif part=="foreground":
		if variant=="a":
			# New foreshortened uniform sleeve behind a giant confession envelope.
			p(node,[[244,709],[347,630],[646,828],[737,985],[594,1080],[440,898]],"#8cabb3",ink,11)
			p(node,[[285,763],[335,700],[571,878],[610,1035],[532,1036]],"#668b9b")
			l(node,[[348,782],[421,791],[467,853]],"#526674",5)
			# Perspective envelope: its long edges create a single incoming diagonal.
			p(node,[[57,886],[786,543],[1177,834],[408,1190]],"#c08699",ink,13)
			p(node,[[70,848],[788,514],[1147,785],[397,1146]],"#fff2de",ink,12)
			p(node,[[70,848],[750,884],[1147,785],[397,1146]],"#f5d8c6",ink,5)
			p(node,[[70,848],[788,514],[750,884]],"#ffeada",ink,5)
			p(node,[[788,514],[1147,785],[750,884]],"#fff8e9",ink,5)
			heart(node,760,790,135,"#983d65",ink,7)
			heart(node,746,767,132,"#ee6b84",ink,7)
			arc_line(node,714,718,29,26,-2.7,-1.05,"#ffd6d1",9)
			# New foreground grip wraps the near edge: original character style, no rig edits.
			p(node,[[450,985],[470,919],[518,891],[559,914],[621,906],[665,925],[705,943],[733,976],[714,1001],[674,1002],[668,1036],[636,1062],[581,1071],[511,1053]],"#efd2b4",ink,11)
			p(node,[[474,984],[511,1017],[581,1043],[637,1032],[669,1002],[714,1001],[670,1036],[636,1062],[581,1071],[511,1053]],"#d5b19d")
			l(node,[[548,916],[565,948],[626,974],[673,974]],ink,5)
			l(node,[[620,915],[640,943],[687,962]],ink,4)
			l(node,[[487,949],[499,978],[520,991]],ink,4)
			for p in [[[122,718],[518,567]],[[180,751],[492,621]],[[464,436],[672,370]]]:l(node,p,"#dc6683",8)
		else:
			# New huge Cupid bow and tapering shaft, posed as playful visual exaggeration.
			arc_line(node,352,716,237,408,-1.6,1.5,"#282739",28)
			arc_line(node,352,716,237,408,-1.6,1.5,"#efd1a5",16)
			l(node,[[345,308],[512,735],[369,1080]],"#fff0d3",5)
			p(node,[[406,714],[435,659],[566,662],[560,786],[445,789]],"#8cabb3",ink,9)
			p(node,[[480,678],[518,666],[552,682],[564,719],[550,748],[527,733],[507,735],[484,708]],"#efd2b4",ink,8)
			# Arrow is emphatically a huge paper-heart icon and stops before the actor.
			p(node,[[115,981],[765,641],[793,681],[157,1020]],"#ffd2af",ink,10)
			l(node,[[167,986],[750,679]],"#fff2dc",7)
			p(node,[[156,969],[41,834],[3,895],[41,1018],[119,1045]],"#ed7f94",ink,7)
			p(node,[[151,1010],[125,1110],[242,1101],[269,1012]],"#f4a2ac",ink,7)
			heart(node,876,579,235,"#913c5e",ink,11)
			heart(node,849,555,231,"#ee768d",ink,11)
			arc_line(node,787,478,62,47,-2.7,-.9,"#ffd6c9",14)
			for p in [[[314,945],[558,797]],[[406,1007],[626,859]],[[554,409],[676,360]]]:l(node,p,"#eed6bc",7)
	else:assert(false,"Unknown promotional art layer")
	return node
