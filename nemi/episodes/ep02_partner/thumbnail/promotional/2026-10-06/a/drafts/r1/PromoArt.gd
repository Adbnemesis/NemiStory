extends RefCounted
## Newly authored promotional metaphors; exact main-character rigs are separate.
const H = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Profiles = preload("res://common/storytime/ProfileAssets.gd")

static func phone(parent: Node2D, corners: Array, screen: Array, color: String, ink: String) -> void:
	H.rounded(parent,corners,color,ink,8.0,.06)
	H.shape(parent,screen,"#fff1dd",ink,5.0)

static func chat(parent: Node2D, x: float, y: float, s: float, color: String, ink: String) -> void:
	H.rounded(parent,[[x-s,y-s*.45],[x+s,y-s*.35],[x+s*.93,y+s*.4],[x+s*.28,y+s*.45],[x-s*.02,y+s*.73],[x-s*.05,y+s*.42],[x-s,y+s*.34]],color,ink,4.5,.1)
	for i in range(3): H.oval(parent,x+(float(i)-1.0)*s*.42,y,s*.095,s*.095,ink)

static func magnet(parent: Node2D, x: float, y: float, s: float, flip: float, ink: String) -> void:
	var group: Node2D=Node2D.new()
	group.position=Vector2(x,y)
	group.scale=Vector2(s*flip,s)
	parent.add_child(group)
	H.rounded(group,[[-105,-120],[-105,22],[-77,111],[0,145],[84,106],[107,29],[107,-120],[41,-120],[41,21],[25,65],[-23,64],[-42,24],[-42,-120]],"#ef727b",ink,6.0,.08)
	H.shape(group,[[-105,-121],[-42,-121],[-42,-62],[-105,-62]],"#d8e7e7",ink,4.0)
	H.shape(group,[[41,-121],[107,-121],[107,-62],[41,-62]],"#d8e7e7",ink,4.0)
	H.curve(group,[[-88,20],[-66,85],[1,108],[70,75],[89,11]],"#ffc0b1",8.0)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author=="nemi" and variant in ["a","b"])
	var node: Node2D=Node2D.new()
	var ink: String=Profiles.profile(author).ink
	match part:
		"background":
			if variant=="a":
				H.shape(node,[[0,0],[730,0],[1080,1080],[0,1080]],"#ee9b9f")
				H.shape(node,[[730,0],[1920,0],[1920,1080],[1080,1080]],"#a3c6cd")
				H.curve(node,[[150,910],[770,960],[1110,720],[1570,370],[1830,530]],"#724d6b",130.0)
				H.curve(node,[[150,897],[770,942],[1110,704],[1570,353],[1830,513]],"#fff0d7",103.0)
				H.heart(node,1020,555,360,"#cf5c79",ink,7.0)
				H.heart(node,1020,539,318,"#f999ad", "",0.0)
				H.curve(node,[[899,302],[947,271],[986,289]],"#ffd8d4",13.0)
			else:
				H.shape(node,[[0,0],[1920,0],[1920,1080],[0,1080]],"#352d4d")
				H.oval(node,1080,570,650,590,"#e9bda9")
				H.shape(node,[[0,0],[773,0],[670,215],[536,613],[390,1080],[0,1080]],"#ad485b",ink,8.0)
				H.shape(node,[[1573,0],[1920,0],[1920,1080],[1770,1080],[1680,630]],"#bd5364",ink,8.0)
				H.curve(node,[[445,0],[369,367],[194,948]],"#d9797a",25.0)
				H.curve(node,[[625,0],[525,321],[399,623]],"#843d59",17.0)
				H.curve(node,[[1746,0],[1790,542],[1890,999]],"#de8d88",20.0)
				H.curve(node,[[474,678],[846,893],[1338,882],[1732,697]],"#f8ce8c",12.0)
		"foreground":
			if variant=="a":
				phone(node,[[-122,821],[433,712],[840,1080],[-170,1120]],[[13,839],[412,763],[681,1015],[-4,1081]],"#655477",ink)
				phone(node,[[1281,1080],[1560,729],[2049,837],[2100,1115]],[[1400,1054],[1578,784],[1924,861],[1960,1068]],"#466779",ink)
				chat(node,360,946,104,"#c0dbe0",ink)
				chat(node,1698,943,104,"#f7b1b7",ink)
				H.curve(node,[[499,904],[762,847],[927,778],[1021,748]],"#fff1db",48.0)
				H.curve(node,[[1101,776],[1348,864],[1580,932]],"#fff1db",48.0)
				H.heart(node,965,885,42,"#ed7996",ink,4.0)
			else:
				phone(node,[[35,869],[366,657],[675,817],[444,1177]],[[103,865],[371,722],[564,825],[406,1074]],"#56777e",ink)
				phone(node,[[1512,730],[1870,843],[1961,1179],[1353,1080]],[[1532,786],[1816,877],[1878,1053],[1431,1016]],"#b47a82",ink)
				magnet(node,531,892,1.03,-1.0,ink)
				magnet(node,1454,922,1.08,1.0,ink)
				H.curve(node,[[666,801],[775,831],[852,809]],"#f3cf97",10.0)
				H.curve(node,[[666,859],[764,884],[841,864]],"#f3cf97",7.0)
				H.curve(node,[[1314,835],[1219,852],[1180,829]],"#f3cf97",10.0)
				H.heart(node,1060,872,79,"#e67787",ink,5.0)
		"burst":
			if variant=="a":
				H.rounded(node,[[747,35],[1320,56],[1313,290],[1160,281],[1088,355],[1083,280],[753,286]],"#fff4df",ink,5.0,.05)
			else:
				H.rounded(node,[[69,57],[690,33],[685,291],[558,307],[600,389],[451,314],[76,329]],"#fff1d9",ink,5.0,.05)
		_:
			assert(false,"Unknown promotional illustration part")
	return node
