extends "res://tools/storytime/ThumbnailStoryArt.gd"
## Original held promotional illustration, in Nemi's rounded ink/fill language.
## This factory draws supporting art only; the main character is the exact rig.

static func rounded(node: Node2D, raw: Array, col: String, outline: String = "", width: float = 5.0, tension: float = 0.18) -> void:
	var curve = Curve2D.new()
	var pts: PackedVector2Array = points(raw)
	for i in range(pts.size() + 1):
		var k: int = i % pts.size()
		var tangent: Vector2 = (pts[(k+1)%pts.size()] - pts[(k-1+pts.size())%pts.size()]) * tension
		curve.add_point(pts[k], -tangent, tangent)
	var poly = curve.tessellate(5, 2.0)
	node.fills.append({"poly":poly,"col":Color(col),"at":0.0})
	if outline != "":
		node.stroke_list.append({"pts":poly,"w":width,"col":Color(outline),"smooth":false,"pressure":PackedFloat32Array([.7,1,.95,.8])})

static func curve_line(node: Node2D, raw: Array, col: String, width: float = 5.0) -> void:
	var curve = Curve2D.new()
	var pts: PackedVector2Array = points(raw)
	for i in range(pts.size()):
		var before: Vector2 = pts[maxi(0,i-1)]
		var after: Vector2 = pts[mini(pts.size()-1,i+1)]
		var tangent: Vector2 = (after-before)*.16
		curve.add_point(pts[i],-tangent,tangent)
	node.stroke_list.append({"pts":curve.tessellate(5,1.5),"w":width,"col":Color(col),"smooth":false,"pressure":PackedFloat32Array([.65,1,.9,.6])})

static func frozen_food(node: Node2D, ink: String) -> void:
	# Huge jewel-like ice housing a newly drawn raw whole cartoon chicken.
	patch(node,[[-228,-103],[-137,-154],[125,-146],[206,-71],[224,94],[126,145],[-157,137],[-236,54]],"#64cadb",ink,6.0)
	patch(node,[[-228,-103],[-137,-154],[125,-146],[162,-98],[-143,-109],[-203,-53]],"#a7ecf0")
	patch(node,[[162,-98],[206,-71],[224,94],[174,117],[172,-47]],"#32a5be")
	# Organic plump breast, tucked wing and projecting drumstick.
	rounded(node,[[-167,-23],[-119,-94],[-41,-112],[48,-93],[112,-45],[119,38],[62,103],[-45,118],[-128,82]],"#f1b5ad",ink,5.0)
	rounded(node,[[-147,-32],[-162,-70],[-138,-108],[-100,-109],[-85,-80],[-96,-49]],"#e7a198",ink,4.5)
	rounded(node,[[52,41],[91,3],[133,9],[151,46],[130,72],[163,88],[157,108],[118,98],[90,108],[50,87]],"#e69e96",ink,5.0)
	rounded(node,[[148,84],[170,69],[191,72],[199,88],[184,94],[196,109],[185,121],[163,112]],"#fff0dc",ink,4.0)
	rounded(node,[[-96,-6],[-58,-27],[-24,0],[-24,39],[-55,58],[-92,34]],"#df8f87",ink,3.5)
	curve_line(node,[[-81,4],[-66,27],[-41,37]],"#bb706e",3.5)
	curve_line(node,[[-45,-87],[8,-78],[50,-48]],"#ffd7c6",11.0)
	# Translucent forward facet preserves recognizable chicken silhouette.
	patch(node,[[-218,-86],[162,-99],[175,114],[-162,123],[-222,49]],"#bcf5f033")
	patch(node,[[-218,-86],[-175,-106],[-144,115],[-177,119],[-222,49]],"#d9ffff80")
	patch(node,[[112,-112],[162,-99],[174,114],[145,128]],"#d9ffff66")
	line(node,[[-135,-102],[-64,-42],[-85,5],[8,36]],"#2d9db6",4.5)
	line(node,[[46,-99],[18,-51],[92,-4],[78,67]],"#53b9d0",4.5)
	line(node,[[-218,-86],[162,-99],[175,114],[-162,123],[-222,49],[-218,-86]],"#d7ffff",4.5)
	# Large fixed crystals and gleams, deliberately few and readable.
	patch(node,[[-185,98],[-174,160],[-115,174],[-91,119],[-137,102]],"#a8eef1",ink,4.5)
	line(node,[[-137,102],[-145,170]],"#64c7dc",3.0)
	patch(node,[[90,-127],[112,-207],[156,-141],[147,-114]],"#d8ffff",ink,4.5)
	patch(node,[[-200,-119],[-246,-172],[-225,-77]],"#b6f6fa",ink,4.0)
	line(node,[[-205,-65],[-205,-37]],"#ffffff",7.0)
	line(node,[[-219,-51],[-191,-51]],"#ffffff",7.0)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author == "nemi")
	assert(variant in ["a", "b"])
	var node = Drawing.new()
	var ink: String = Assets.profile(author).ink
	match part:
		"food":
			frozen_food(node,ink)
		"background":
			if variant == "a":
				# Diagonal hot/cold planes and large directional hand-ink sweeps.
				patch(node,[[0,0],[880,0],[1150,1080],[0,1080]],"#157d96")
				patch(node,[[785,0],[1920,0],[1920,1080],[1170,1080]],"#f49678")
				patch(node,[[1020,390],[1920,205],[1920,680],[1080,900]],"#f8bb8b")
				patch(node,[[0,996],[885,755],[1150,1080],[0,1080]],"#086477")
				curve_line(node,[[0,700],[95,471],[251,374]],"#5cc8d5",15.0)
				curve_line(node,[[70,873],[142,661],[294,547]],"#41aebb",9.0)
				line(node,[[1665,56],[1800,6]],"#ffdcc1",14.0)
				line(node,[[1715,156],[1879,101]],"#ffdcc1",8.0)
				line(node,[[1765,259],[1920,210]],"#ffdcc1",6.0)
			else:
				# Oversized entry light and looming parent-shaped cast shadow.
				patch(node,[[1010,0],[1920,0],[1920,1080],[767,1080]],"#f6d38a")
				patch(node,[[1215,-30],[1870,-60],[1840,1080],[970,1080]],"#fbe9b7",ink,8.0)
				patch(node,[[1195,0],[1250,0],[1030,1080],[960,1080]],"#bc987f")
				patch(node,[[0,1050],[1190,710],[1920,973],[1920,1080],[0,1080]],"#77bbc4")
				# Faceless symbolic silhouette; newly authored, not a factual portrait.
				ellipse(node,1551,216,129,147,"#473d65")
				ellipse(node,1657,95,77,66,"#473d65")
				rounded(node,[[1431,338],[1550,300],[1694,348],[1777,497],[1791,605],[1698,716],[1688,946],[1460,979],[1421,726],[1305,613],[1318,478]],"#473d65", "", 0.0)
				patch(node,[[1460,960],[1680,942],[1920,1080],[438,1080]],"#655976")
				curve_line(node,[[1369,485],[1390,570],[1458,614]],"#6b5d82",7.0)
				curve_line(node,[[1720,462],[1693,560],[1623,595]],"#6b5d82",7.0)
		"burst":
			if variant == "a":
				patch(node,[[48,65],[165,83],[193,25],[259,70],[468,50],[486,83],[640,69],[631,136],[731,153],[685,224],[727,332],[660,343],[610,433],[516,398],[361,435],[347,393],[159,410],[167,360],[41,327],[81,264],[20,186],[70,150]],"#fff7df",ink,5.0)
			else:
				patch(node,[[63,67],[192,77],[206,27],[252,79],[531,58],[550,85],[691,111],[659,168],[702,258],[603,291],[537,347],[459,296],[261,327],[265,288],[84,296],[104,246],[35,167],[85,141]],"#fff7df",ink,5.0)
		_:
			assert(false,"Unknown original promotional art part")
	node.prepare()
	node.progress = 1.0
	return node
