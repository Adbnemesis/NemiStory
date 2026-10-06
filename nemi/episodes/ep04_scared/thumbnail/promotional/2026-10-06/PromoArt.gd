extends RefCounted
## Original effort-versus-attention and empty-stage metaphors; held warm pen.
const H = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Profiles = preload("res://common/storytime/ProfileAssets.gd")

static func sheet(parent: Node2D, x: float, y: float, s: float, angle: float, ink: String, pose: int) -> void:
	var group: Node2D=Node2D.new()
	group.position=Vector2(x,y)
	group.scale=Vector2.ONE*s
	group.rotation_degrees=angle
	parent.add_child(group)
	H.shape(group,[[-130,-162],[107,-164],[135,-132],[126,160],[-128,162]],"#fff1d9",ink,5.0)
	H.shape(group,[[107,-164],[107,-131],[135,-132]],"#d7cab3",ink,4.0)
	H.stroke(group,[[-95,-128],[41,-126]],"#ad9598",4.0)
	H.oval(group,0,-48,39,39,"#e8a9a3",ink,4.0)
	H.curve(group,[[0,-8],[8,43],[0,99]],ink,4.5)
	if pose%2==0:
		H.curve(group,[[-60,12],[8,43],[70,11]],ink,4.5)
		H.stroke(group,[[0,99],[-53,132]],ink,4.5)
		H.stroke(group,[[0,99],[51,130]],ink,4.5)
	else:
		H.curve(group,[[-68,62],[8,43],[69,-4]],ink,4.5)
		H.stroke(group,[[0,99],[-70,99]],ink,4.5)
		H.stroke(group,[[0,99],[48,142]],ink,4.5)

static func seat(parent: Node2D, x: float, y: float, s: float, ink: String) -> void:
	var group: Node2D=Node2D.new()
	group.position=Vector2(x,y)
	group.scale=Vector2.ONE*s
	parent.add_child(group)
	H.rounded(group,[[-95,-118],[-75,-149],[76,-149],[95,-114],[102,68],[-100,66]],"#833d59",ink,5.0,.14)
	H.rounded(group,[[-81,-125],[75,-125],[74,25],[-76,25]],"#ab5d71", "",0.0,.15)
	H.rounded(group,[[-123,41],[113,41],[133,123],[-137,121]],"#5e314c",ink,5.0,.06)
	H.stroke(group,[[-87,117],[-90,194]],"#31283d",13.0)
	H.stroke(group,[[89,117],[90,194]],"#31283d",13.0)
	H.rounded(group,[[-138,29],[-104,33],[-105,94],[-143,93]],"#d29a79",ink,4.0,.08)
	H.rounded(group,[[110,33],[145,32],[145,92],[108,93]],"#d29a79",ink,4.0,.08)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author=="nemi" and variant in ["a","b"])
	var node: Node2D=Node2D.new()
	var ink: String=Profiles.profile(author).ink
	match part:
		"background":
			if variant=="a":
				H.shape(node,[[0,0],[1920,0],[1920,1080],[0,1080]],"#4d465e")
				H.shape(node,[[0,788],[710,425],[1920,925],[1920,1080],[0,1080]],"#8b7382")
				H.oval(node,527,582,610,587,"#736279")
				H.curve(node,[[365,690],[576,290],[1006,93],[1425,228],[1801,445]],"#bc9cad",17.0)
				H.curve(node,[[522,746],[798,368],[1194,224],[1482,299]],"#d5b4bd",9.0)
				# Newly drawn generic in-between tests, not replacement Nemi faces.
				sheet(node,540,355,1.02,-32,ink,0)
				sheet(node,866,184,.78,18,ink,1)
				sheet(node,1146,211,.52,41,ink,0)
				sheet(node,1430,285,.33,65,ink,1)
				H.oval(node,128,99,83,83,"#f1d4a9")
				H.oval(node,157,78,72,70,"#4d465e")
			else:
				H.shape(node,[[0,0],[1920,0],[1920,1080],[0,1080]],"#332d46")
				H.shape(node,[[840,142],[1210,142],[1630,955],[367,955]],"#dfc493")
				H.shape(node,[[967,161],[1092,161],[1331,955],[746,955]],"#f5dfb0")
				H.oval(node,1007,933,770,144,"#ac8390")
				H.oval(node,1007,914,509,93,"#e8bd9f")
				H.shape(node,[[0,975],[1920,966],[1920,1080],[0,1080]],"#665069")
				H.curve(node,[[0,882],[241,895],[386,931]],"#66546e",8.0)
				H.curve(node,[[1630,923],[1771,895],[1920,876]],"#66546e",8.0)
		"foreground":
			if variant=="a":
				# Dramatic monitor perspective occupies the near left foreground.
				H.shape(node,[[-120,505],[611,357],[835,912],[60,1108]],"#292d43",ink,8.0)
				H.shape(node,[[-47,530],[573,421],[736,857],[97,1011]],"#bed5d9",ink,6.0)
				H.shape(node,[[37,553],[548,470],[680,818],[134,949]],"#eef0db",ink,4.0)
				H.shape(node,[[182,1023],[660,925],[724,1080],[229,1097]],"#1f2638",ink,6.0)
				H.shape(node,[[-13,1006],[190,1039],[696,958],[843,1074],[0,1145]],"#716b80",ink,6.0)
				H.shape(node,[[112,1028],[623,969],[711,1049],[170,1102]],"#a096a3",ink,4.0)
				H.curve(node,[[483,416],[515,285],[613,191]],"#fff1d9",33.0)
				# One broad play glyph supports the single count headline.
				H.shape(node,[[227,727],[277,706],[279,765]],"#c45970",ink,4.0)
			else:
				seat(node,114,890,1.72,ink)
				seat(node,584,1084,2.12,ink)
				seat(node,1480,1084,2.06,ink)
				seat(node,1915,894,1.65,ink)
		"burst":
			if variant=="a":
				# Count is editorial type on the giant screen, not a second label.
				H.rounded(node,[[95,529],[663,506],[690,696],[124,771]],"#fff3d7",ink,4.0,.035)
			else:
				H.rounded(node,[[40,55],[699,55],[704,323],[563,326],[527,404],[476,327],[37,334]],"#fff1d9",ink,5.0,.05)
				# Oversized practical spotlight remains an illustrative stage cue.
				H.shape(node,[[817,-45],[1230,-45],[1220,113],[846,146]],"#8c8799",ink,7.0)
				H.oval(node,1034,132,212,54,"#1e283a",ink,6.0)
				H.oval(node,1034,139,176,34,"#fbe2a0",ink,4.0)
		_:
			assert(false,"Unknown promotional illustration part")
	return node
