extends RefCounted
## New supporting sketches embody a drawing struggle, never a deformed main rig.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Profiles = preload("res://common/storytime/ProfileAssets.gd")

static func arm_sketch(n: Node2D,x: float,y: float,angle: float,ink: String) -> void:
	var group: Node2D=Node2D.new()
	group.position=Vector2(x,y)
	group.rotation_degrees=angle
	n.add_child(group)
	I.rounded(group,[[-96,-26],[-27,-39],[71,12],[103,43],[79,69],[8,35],[-75,31]],"#7c9c7f",ink,6)
	I.rounded(group,[[79,17],[113,19],[142,8],[160,16],[155,27],[177,33],[172,49],[145,62],[115,68],[80,58]],"#f5d9bc",ink,5)
	I.curve(group,[[92,35],[119,42],[140,43]],ink,3)

static func make(author: String,variant: String,part: String) -> Node2D:
	assert(author=="nemi")
	var n: Node2D=Node2D.new()
	var ink: String=Profiles.profile(author).ink
	if part=="background":
		if variant=="a":
			I.shape(n,[[0,0],[1040,0],[1110,1080],[0,1080]],"#9ec2ad")
			I.oval(n,1440,600,640,650,"#ffe1bd")
			# Tilted page recedes under the illustration that breaks its perimeter.
			I.shape(n,[[92,106],[966,155],[1131,1003],[28,1088]],"#688f82")
			I.shape(n,[[71,73],[930,130],[1084,951],[10,1038]],"#fff5e3",ink,7)
			I.stroke(n,[[105,843],[963,799]],"#d2dfce",4)
			I.stroke(n,[[112,899],[994,854]],"#d2dfce",4)
			# Giant lumpy ginger-root hand, deliberately NOT Nemi anatomy.
			I.rounded(n,[[229,729],[277,642],[258,543],[162,450],[179,378],[229,377],[301,455],[321,419],[302,290],[352,229],[406,273],[429,421],[474,421],[488,301],[548,261],[597,307],[566,471],[638,482],[686,406],[745,401],[769,457],[708,558],[696,716],[592,804],[355,825]],"#dba476",ink,10)
			I.shape(n,[[229,729],[355,825],[592,804],[696,716],[708,558],[641,662],[541,721],[366,731]],"#be8065")
			I.curve(n,[[301,455],[331,535],[312,610]],"#986955",7)
			I.curve(n,[[430,428],[454,530],[424,621]],"#986955",7)
			I.curve(n,[[566,471],[572,550],[541,618]],"#986955",7)
			# Large mismatched ceramic cup and awkward root fingers are the comic gag.
			I.oval(n,627,523,159,146,"#fff4db",ink,9)
			I.oval(n,627,523,104,93,"#d5dbc2",ink,8)
			I.shape(n,[[369,437],[695,409],[676,614],[620,664],[417,679],[374,617]],"#b7d3c2",ink,10)
			I.shape(n,[[377,525],[682,510],[676,614],[620,664],[417,679]],"#80ae99")
			I.oval(n,531,431,168,42,"#d8e6cb",ink,8)
			I.oval(n,530,430,127,25,"#8b6551")
			I.curve(n,[[467,317],[441,265],[464,206]],"#a7c5ad",8)
			I.curve(n,[[586,322],[608,263],[586,218]],"#a7c5ad",8)
			I.rounded(n,[[230,729],[292,688],[345,683],[380,711],[362,749],[307,767]],"#e8b78a",ink,7)
			# Small bubble for an ironic reaction, not a large text poster.
			I.burst(n,[[33,20],[791,25],[806,215],[598,231],[561,276],[539,231],[27,218]],"#fff6e4",ink,6)
		else:
			I.oval(n,960,600,730,630,"#bb6d75")
			I.oval(n,960,600,530,460,"#d7968e")
			# One continuous perspective ribbon rather than a grid of frames.
			I.rounded(n,[[-60,353],[219,179],[534,141],[804,282],[999,520],[909,667],[655,489],[459,405],[222,442],[32,625]],"#fff1d5",ink,8)
			I.curve(n,[[-35,376],[217,215],[510,189],[754,316],[945,544]],"#846972",5)
			I.curve(n,[[52,591],[276,407],[476,379],[668,452],[876,618]],"#846972",5)
			for raw in [[[197,203],[244,433]],[[466,160],[449,403]],[[689,223],[628,469]],[[853,355],[777,554]]]: I.stroke(n,raw,"#b99a95",5)
			arm_sketch(n,282,323,-11,ink)
			arm_sketch(n,570,322,43,ink)
			arm_sketch(n,806,460,-64,ink)
			# A no-number clock supplies time pressure without second text.
			I.oval(n,290,828,189,189,"#f8ddb0",ink,10)
			I.oval(n,290,828,158,158,"#fff3dc",ink,5)
			for i in range(12):
				var a: float=float(i)*TAU/12.0
				I.stroke(n,[[290+cos(a)*133,828+sin(a)*133],[290+cos(a)*148,828+sin(a)*148]],ink,6)
			I.stroke(n,[[290,710],[290,828],[385,883]],"#a35258",13)
			I.oval(n,290,828,13,13,"#a35258")
			I.burst(n,[[1390,34],[1890,50],[1907,345],[1720,365],[1650,420],[1610,359],[1390,347]],"#fff0d4",ink,7)
	elif part=="pencil":
		assert(variant=="a")
		# Local wrist origin. Foreshortened broad near end tapers to a nib at left.
		I.shape(n,[[-740,209],[-688,279],[133,40],[142,-73]],"#d7a463",ink,9)
		I.shape(n,[[-740,209],[142,-73],[129,-12],[-719,232]],"#ffd088")
		I.stroke(n,[[-690,243],[130,-12]],"#ad784b",7)
		I.shape(n,[[-740,209],[-688,279],[-829,285]],"#f3d7a7",ink,7)
		I.shape(n,[[-829,285],[-788,246],[-782,282]],"#42333a")
		I.shape(n,[[133,40],[142,-73],[193,-95],[201,17]],"#df8d80",ink,7)
		I.stroke(n,[[136,40],[145,-73]],"#776c66",17)
	elif part=="foreground":
		assert(variant=="b")
		I.rounded(n,[[689,778],[934,742],[1276,730],[1642,594],[1974,582],[1998,816],[1723,837],[1418,936],[1027,1008],[730,1039],[635,937]],"#fff1d5",ink,10)
		I.curve(n,[[705,817],[963,786],[1291,780],[1658,645],[1957,642]],"#b99a95",5)
		I.curve(n,[[715,988],[1020,958],[1398,890],[1710,788],[1980,765]],"#b99a95",5)
		for raw in [[[920,757],[932,974]],[[1233,739],[1270,925]],[[1574,625],[1630,818]],[[1845,590],[1855,800]]]: I.stroke(n,raw,"#b99a95",5)
		arm_sketch(n,801,887,-12,ink)
		arm_sketch(n,1110,862,51,ink)
		arm_sketch(n,1469,776,-22,ink)
		arm_sketch(n,1778,710,61,ink)
	else: assert(false,"Unknown drawing-struggle part")
	return n
