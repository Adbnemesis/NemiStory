extends RefCounted
## Newly authored promotional travel illustration. No TravelArt car reuse.
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const E = preload("res://tools/storytime/ThumbnailStoryArt.gd")
const INK = "#513541"

static func attach(n: Node2D, drawing: Node2D) -> void:
	drawing.prepare()
	drawing.progress=1.0
	n.add_child(drawing)

static func fill(n: Node2D, raw: Array, color: String) -> void:
	var drawing=Drawing.new()
	E.patch(drawing,raw,color)
	attach(n,drawing)

static func shape(n: Node2D, raw: Array, color: String, w: float=6.0) -> void:
	var drawing=Drawing.new()
	E.patch(drawing,raw,color,INK,w)
	attach(n,drawing)

static func stroke(n: Node2D, raw: Array, color: String=INK, w: float=5.0) -> void:
	var drawing=Drawing.new()
	drawing.stroke_list.append({"pts":E.points(raw),"w":w,"col":Color(color),"smooth":false,"pressure":PackedFloat32Array([.55,1.0,.82,.94,.38])})
	attach(n,drawing)

static func oval(n: Node2D, x: float, y: float, rx: float, ry: float, color: String, w: float=5.0) -> void:
	var raw: Array=[]
	for i in range(49):
		var a=float(i)*TAU/48.0
		raw.append([x+cos(a)*rx,y+sin(a)*ry])
	shape(n,raw,color,w)

static func wheel(n: Node2D, x: float, y: float, rx: float, ry: float) -> void:
	oval(n,x,y,rx,ry,INK,6.0)
	oval(n,x,y,rx*.48,ry*.48,"#e5d8bf",4.0)

static func balloon(n: Node2D, variant: String) -> void:
	if variant=="a":
		shape(n,[[1300,56],[1718,38],[1839,92],[1870,250],[1815,357],[1439,378],[1275,455],[1300,350],[1220,285],[1218,122]],"#fff0d1",8.0)
	else:
		shape(n,[[1365,54],[1785,39],[1880,111],[1886,318],[1784,410],[1400,416],[1306,487],[1317,374],[1285,295],[1291,116]],"#fff0d1",8.0)

static func rear_taxi_back(n: Node2D) -> void:
	# Original low 3/4 rear perspective with exaggerated passenger glass.
	shape(n,[[116,755],[174,363],[306,224],[866,235],[1038,439],[1140,738]],"#f5dfb2",10.0)
	shape(n,[[203,697],[249,367],[341,294],[822,312],[972,478],[1042,708]],"#aad1d4",8.0)
	fill(n,[[251,369],[345,296],[820,313],[973,480],[899,489],[775,349],[376,335],[283,402]],"#d4ebdf")
	stroke(n,[[175,362],[312,257],[851,268]],"#ffefcc",14.0)
	# Side plane produces depth without an old side-view car silhouette.
	shape(n,[[1038,439],[1120,389],[1327,698],[1258,988],[1128,1031],[1140,738]],"#d0af8f",8.0)
	shape(n,[[1115,431],[1154,419],[1262,593],[1207,670],[1144,548]],"#739fac",6.0)
	stroke(n,[[1248,721],[1215,919]],INK,5.0)
	shape(n,[[1165,702],[1227,690],[1232,708],[1169,723]],"#6d747d",4.0)

static func rear_taxi_front(n: Node2D) -> void:
	# Rear trunk/body hides the rig below the windshield while the face leads.
	shape(n,[[142,696],[1042,712],[1161,763],[1228,811],[1192,858],[1240,902],[1191,948],[1222,985],[1130,1033],[43,1021],[10,845]],"#f5dfb2",10.0)
	fill(n,[[144,697],[1044,713],[1156,765],[1230,811],[1073,844],[63,828]],"#fff0cd")
	stroke(n,[[59,829],[1078,847],[1191,948]],INK,6.0)
	shape(n,[[98,843],[293,855],[304,933],[89,916]],"#dc756c",6.0)
	shape(n,[[929,866],[1132,880],[1147,941],[932,934]],"#dc756c",6.0)
	fill(n,[[113,857],[282,867],[282,886],[107,878]],"#ffdca4")
	fill(n,[[947,880],[1118,891],[1121,907],[946,901]],"#ffdca4")
	shape(n,[[472,882],[751,890],[755,963],[471,957]],"#e8e3cf",5.0)
	stroke(n,[[516,919],[706,925]],"#a28e80",5.0)
	shape(n,[[14,963],[466,976],[967,984],[1207,951],[1184,1029],[944,1072],[44,1059]],"#91a7ac",7.0)
	stroke(n,[[29,991],[928,1022],[1164,992]],"#d6e0d6",8.0)
	# Accordion corner and torn bumper directly at incoming-car contact.
	stroke(n,[[1125,782],[1172,823],[1135,856],[1182,902],[1127,954]],INK,8.0)
	stroke(n,[[1092,800],[1132,840],[1091,869],[1139,909]],INK,5.0)

static func incoming_nose(n: Node2D) -> void:
	shape(n,[[1556,442],[1738,346],[1940,363],[2057,679],[1910,891],[1467,809]],"#d9766c",8.0)
	shape(n,[[1610,468],[1750,399],[1909,412],[1991,640],[1571,687]],"#82b5bd",7.0)
	fill(n,[[1638,475],[1747,426],[1803,430],[1680,601],[1602,634]],"#b8dadc")
	shape(n,[[1353,771],[1890,660],[2035,934],[1948,1081],[1325,1082],[1224,924],[1279,851]],"#e8937c",10.0)
	fill(n,[[1354,772],[1890,661],[1942,735],[1331,854],[1280,851]],"#ffb49a")
	stroke(n,[[1330,854],[1926,747]],INK,7.0)
	shape(n,[[1300,871],[1458,849],[1514,907],[1339,939]],"#f6eac9",6.0)
	shape(n,[[1746,801],[1892,777],[1943,836],[1796,868]],"#f6eac9",6.0)
	shape(n,[[1511,919],[1758,869],[1812,943],[1548,1001]],INK,5.0)
	for i in range(6):
		var x=1530+i*41
		stroke(n,[[x,925-i*7],[x+18,973-i*9]],"#96858d",5.0)
	wheel(n,1900,1055,104,111)
	stroke(n,[[1259,871],[1195,799]],INK,10.0)
	stroke(n,[[1254,855],[1320,757]],INK,10.0)
	stroke(n,[[1282,918],[1340,963]],INK,9.0)

static func suitcase(n: Node2D) -> void:
	# Newly drawn flying luggage: a travel metaphor, not an injury claim.
	shape(n,[[24,296],[163,327],[187,588],[17,570],[-38,470]],"#638f98",7.0)
	shape(n,[[56,233],[132,250],[139,315],[111,310],[106,275],[77,268],[72,305],[46,300]],"#eff0d6",6.0)
	stroke(n,[[42,338],[52,526]],"#a8d4cf",7.0)
	stroke(n,[[140,363],[155,549]],INK,4.0)
	oval(n,55,597,15,20,INK,4.0)
	oval(n,166,616,15,20,INK,4.0)
	shape(n,[[185,361],[230,335],[249,407],[213,442]],"#fff1ce",4.0)
	stroke(n,[[14,231],[36,193]],INK,5.0)
	stroke(n,[[130,202],[141,168]],INK,5.0)

static func plane(n: Node2D, ox: float, oy: float, s: float, color: String=INK) -> void:
	var raw=[[0,-59],[12,-46],[14,-13],[58,17],[58,32],[14,18],[11,51],[31,65],[28,75],[0,65],[-27,74],[-31,64],[-12,51],[-14,19],[-60,30],[-59,16],[-14,-14],[-12,-47],[0,-59]]
	var moved: Array=[]
	for p in raw:moved.append([ox+p[0]*s,oy+p[1]*s])
	fill(n,moved,color)

static func safe_autonomous(n: Node2D) -> void:
	# Original calm 3/4 autonomous pod. The roof sensor identifies the ride.
	shape(n,[[26,535],[75,349],[181,270],[476,238],[688,367],[748,535],[640,613],[143,625]],"#ecedcf",8.0)
	shape(n,[[139,448],[164,348],[232,304],[460,279],[601,365],[619,455]],"#729fa6",7.0)
	fill(n,[[169,349],[235,308],[313,300],[231,446],[143,446]],"#bfded8")
	shape(n,[[50,487],[651,482],[721,552],[642,617],[110,624],[25,568]],"#8fcbc8",8.0)
	fill(n,[[51,487],[651,482],[681,509],[42,519]],"#c8e9d8")
	shape(n,[[81,502],[207,500],[208,535],[70,537]],"#fff2cb",5.0)
	shape(n,[[486,503],[628,502],[660,536],[488,538]],"#fff2cb",5.0)
	stroke(n,[[261,556],[468,555]],INK,9.0)
	wheel(n,143,615,69,43)
	wheel(n,640,591,62,43)
	shape(n,[[348,235],[344,203],[417,195],[425,225]],"#8dbbb9",5.0)
	oval(n,383,198,65,20,"#e6e9cd",5.0)
	stroke(n,[[152,166],[197,217],[315,81]],"#49695e",26.0)

static func crumpled_human_cab(n: Node2D) -> void:
	# New three-quarter ordinary taxi, crushed at its left/rear corner.
	shape(n,[[1353,762],[1414,649],[1664,620],[1815,723],[1898,932],[1758,1047],[1392,980],[1311,871]],"#f6dfb5",8.0)
	shape(n,[[1426,678],[1649,655],[1771,735],[1780,840],[1381,812]],"#88afb7",6.0)
	fill(n,[[1433,680],[1526,670],[1484,809],[1391,804]],"#c2dcda")
	shape(n,[[1379,813],[1779,840],[1899,931],[1784,1033],[1309,987],[1326,935],[1276,891],[1321,849],[1284,817]],"#ffe8bd",8.0)
	fill(n,[[1780,840],[1814,722],[1899,931],[1785,1033]],"#c9a888")
	shape(n,[[1394,868],[1515,879],[1510,932],[1377,917]],"#e37770",5.0)
	shape(n,[[1656,900],[1775,911],[1784,954],[1652,947]],"#e37770",5.0)
	shape(n,[[1487,928],[1634,946],[1618,994],[1478,978]],"#ebe4d1",4.0)
	stroke(n,[[1374,808],[1346,849],[1390,887],[1347,929],[1399,971]],INK,7.0)
	stroke(n,[[1338,834],[1300,889],[1353,934]],INK,7.0)
	wheel(n,1843,997,52,81)
	shape(n,[[1301,947],[1474,986],[1751,1021],[1794,992],[1781,1048],[1717,1075],[1360,1024],[1278,994]],"#839da5",6.0)
	stroke(n,[[1260,864],[1215,815]],INK,7.0)
	stroke(n,[[1293,834],[1280,771]],INK,7.0)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author=="nemi" and variant in ["a","b"] and part in ["background","foreground"])
	assert(str(Assets.profile(author).ink)==INK)
	var n=Node2D.new()
	if variant=="a" and part=="background":
		fill(n,[[0,0],[1140,0],[980,738],[0,1040]],"#b5dcdd")
		fill(n,[[1050,405],[1920,221],[1920,1080],[0,1080]],"#7397a2")
		stroke(n,[[1379,380],[1001,1078]],"#e8dbb9",19.0)
		stroke(n,[[1700,291],[1696,454]],"#e8dbb9",9.0)
		stroke(n,[[1700,539],[1671,807]],"#e8dbb9",12.0)
		stroke(n,[[1065,54],[1136,70],[1187,116]],"#f8ebce",7.0)
		plane(n,1041,99,.45,"#527481")
		suitcase(n)
		rear_taxi_back(n)
		balloon(n,"a")
	elif variant=="a" and part=="foreground":
		# Clear only the scene floor under the rig before the new car fronts.
		# Prevent green costume/leg pixels protruding beneath the foreground.
		fill(n,[[0,1000],[1920,1000],[1920,1080],[0,1080]],"#7397a2")
		rear_taxi_front(n)
		incoming_nose(n)
	elif variant=="b" and part=="background":
		fill(n,[[0,0],[995,0],[1114,1080],[0,1080]],"#b2dcd8")
		fill(n,[[994,0],[1920,0],[1920,1080],[1082,1080]],"#e99e91")
		# The clean half of an oversized boarding pass becomes the safe world.
		shape(n,[[10,653],[1052,409],[1570,657],[1791,943],[1661,1079],[0,1066]],"#faf0d5",7.0)
		fill(n,[[10,653],[1052,409],[1197,479],[61,764]],"#d8e6d5")
		stroke(n,[[420,139],[512,160],[539,210]],"#e8f0d3",8.0)
		safe_autonomous(n)
		balloon(n,"b")
	elif variant=="b" and part=="foreground":
		# New travel-paper prop and folded, crushed corner. Grip point (750,780).
		shape(n,[[31,787],[1056,704],[1261,804],[1308,831],[1258,859],[1313,898],[1267,928],[1327,968],[1276,1001],[1306,1080],[40,1080]],"#fff0d0",8.0)
		fill(n,[[40,787],[1056,704],[1261,804],[986,816],[49,901]],"#f8e2bd")
		stroke(n,[[1109,796],[1148,840],[1105,882],[1167,925],[1111,977],[1188,1043]],"#b39885",5.0)
		for i in range(11):
			var x=900+i*7.0
			var y=859+i*15.0
			stroke(n,[[x,y],[x+4,y+10]],"#bba896",4.0)
		# Barcode and plane symbol convey travel without secondary words.
		for i in range(18):
			var x=146+i*21.0
			stroke(n,[[x,947],[x+2,1042]],INK,5.0 if i%3 else 9.0)
		plane(n,143,851,.65,"#7a979c")
		shape(n,[[1147,947],[1237,912],[1287,966],[1390,944],[1416,1066],[1317,1080]],"#e7bca5",5.0)
		stroke(n,[[1167,958],[1241,952],[1290,1008],[1404,1053]],INK,4.0)
		crumpled_human_cab(n)
	return n
