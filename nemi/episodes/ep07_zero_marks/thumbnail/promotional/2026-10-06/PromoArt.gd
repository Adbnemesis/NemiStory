extends RefCounted
## The grade as a meteor and as a zero-shaped trapdoor. No new factual events.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")

static func paper(node: Node2D, x: float, y: float, scale: float, angle: float, ink: String) -> void:
	var sheet: Node2D = Node2D.new()
	sheet.position = Vector2(x,y)
	sheet.scale = Vector2.ONE*scale
	sheet.rotation_degrees = angle
	node.add_child(sheet)
	I.shape(sheet,[[-67,-93],[60,-98],[73,87],[-58,94]],"#fff4dc",ink,3.5)
	for i in range(5):
		var yy: float = -55.0+float(i)*27.0
		I.curve(sheet,[[-37,yy],[-8,yy-3],[21,yy+1],[45,yy-1]],"#9e8d86",3.0)
		I.stroke(sheet,[[-46,yy-5],[-42,yy+3],[-34,yy-10]],"#55666c",2.8)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author == "nemi" and variant in ["a","b"])
	var node: Node2D = Node2D.new()
	var ink: String = Assets.profile(author).ink
	match part:
		"background":
			if variant == "a":
				I.shape(node,[[690,0],[1920,0],[1920,1080],[1300,1080]],"#acd1c9")
				I.shape(node,[[0,862],[1140,648],[1920,843],[1920,1080],[0,1080]],"#57777b",ink,6.0)
				I.stroke(node,[[1299,31],[1775,-128]],"#cf756b",14.0)
				I.stroke(node,[[1469,125],[1934,-43]],"#cf756b",10.0)
				I.stroke(node,[[1688,375],[1992,228]],"#cf756b",8.0)
			else:
				I.shape(node,[[0,760],[1350,563],[1920,856],[1920,1080],[0,1080]],"#3d435e")
				I.shape(node,[[80,679],[1036,469],[1405,967],[101,1160]],"#eed8c8",ink,7.0)
				I.shape(node,[[106,707],[1025,506],[1342,954],[137,1120]],"#fff4dd",ink,4.0)
				I.curve(node,[[143,926],[467,851],[1024,718]],"#c0aeb1",11.0)
				I.curve(node,[[153,1001],[509,915],[1074,776]],"#c0aeb1",11.0)
				I.curve(node,[[1454,170],[1559,88],[1656,81]],"#a698b0",13.0)
		"paper":
			assert(variant == "a")
			# Wide perspective page with plentiful authored answer strokes.
			I.shape(node,[[701,783],[1421,570],[1918,934],[1055,1190]],"#d6bfb3",ink,8.0)
			I.shape(node,[[699,743],[1417,534],[1918,898],[1042,1154]],"#fff7df",ink,6.0)
			for i in range(6):
				var yy: float = 671.0+float(i)*49.0
				I.curve(node,[[925,yy+49],[1100,yy-2],[1335,yy-55],[1502,yy-96]],"#8f8581",7.0)
				I.stroke(node,[[882,yy+46],[902,yy+65],[921,yy+23]],"#789790",6.0)
		"grade":
			assert(variant == "a")
			# The impossible stamp is an emotional metaphor, never a teacher weapon.
			I.shape(node,[[773,523],[1023,534],[1121,683],[1231,663],[1335,808],[1400,686],[1648,679],[1503,575],[1551,486],[1361,473],[1227,415],[1110,481],[971,433]],"#f6c96c",ink,6.0)
			I.rounded(node,[[809,129],[1579,-8],[1841,347],[1081,530]],"#a65052",ink,9.0,.08)
			I.rounded(node,[[809,77],[1579,-60],[1799,260],[1040,443]],"#f87567",ink,8.0,.08)
			I.shape(node,[[778,709],[844,666],[864,734],[827,779]],"#fff7df",ink,5.0)
			I.shape(node,[[1605,751],[1649,803],[1610,834],[1579,777]],"#fff7df",ink,5.0)
		"portal":
			assert(variant == "b")
			# A foreshortened zero rim, open into empty ink. All work falls through.
			I.oval(node,650,828,411,232,"#cf7b87",ink,9.0)
			I.oval(node,650,802,411,218,"#ee9aa2",ink,8.0)
			I.oval(node,650,802,306,152,"#262f49",ink,7.0)
			I.curve(node,[[318,888],[460,958],[683,985],[918,929]],"#ffd4be",10.0)
			paper(node,835,550,1.45,-17.0,ink)
			paper(node,543,663,1.0,21.0,ink)
			paper(node,739,796,.58,39.0,ink)
			I.curve(node,[[1061,518],[1017,617],[973,682]],"#ebc8bd",12.0)
			I.curve(node,[[909,430],[905,491],[885,535]],"#ebc8bd",7.0)
		"burst":
			assert(variant == "b")
			I.shape(node,[[53,46],[873,31],[919,317],[871,353],[630,353],[577,407],[558,353],[77,374]],"#fff3da",ink,6.0)
		_:
			assert(false,"Unknown original exam promotional part")
	return node
