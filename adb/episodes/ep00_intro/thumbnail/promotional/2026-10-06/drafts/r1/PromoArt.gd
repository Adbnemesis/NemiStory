extends RefCounted
## Original editorial metaphors; canonical ADB is composed separately.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Profiles = preload("res://common/storytime/ProfileAssets.gd")

static func paper(parent: Node2D,raw: Array,ink: String,fold: Array=[]) -> void:
	I.shape(parent,raw,"#fff3d7",ink,7)
	if not fold.is_empty(): I.shape(parent,fold,"#bfcfc9",ink,4)

static func make(author: String,variant: String,part: String) -> Node2D:
	assert(author=="adb")
	var n: Node2D=Node2D.new()
	var ink: String=Profiles.profile(author).ink
	if part=="background":
		if variant=="a":
			I.oval(n,920,650,730,625,"#28636b")
			I.oval(n,920,650,520,450,"#448482")
			I.oval(n,920,650,285,260,"#163c48")
			# Authored curved ribbons, with accelerating perspective paper sizes.
			I.curve(n,[[-80,975],[370,1060],[995,900],[1440,540],[1310,160],[740,60],[310,350]],"#d7e0c0",15)
			I.curve(n,[[105,860],[710,940],[1310,665],[1400,260],[925,10],[290,180]],"#87b8a4",8)
			paper(n,[[875,36],[1080,70],[1053,267],[852,232]],ink,[[1040,62],[1053,125],[1080,70]])
			I.stroke(n,[[881,116],[1020,144]],"#558f87",6)
			I.stroke(n,[[879,147],[1001,176]],"#558f87",4)
			paper(n,[[1450,188],[1665,328],[1535,512],[1352,378]],ink)
			I.stroke(n,[[1465,289],[1550,350],[1470,440]],"#a46b5e",7)
			paper(n,[[1415,694],[1709,773],[1681,1010],[1397,917]],ink,[[1687,783],[1631,848],[1709,773]])
			I.stroke(n,[[1453,782],[1627,830]],"#a46b5e",6)
			paper(n,[[258,479],[472,409],[547,636],[317,715]],ink)
			I.stroke(n,[[342,553],[428,507],[475,567],[401,610],[342,553]],"#69958a",6)
			# Single compact reaction bubble stays away from the main face.
			I.burst(n,[[73,63],[590,56],[656,175],[606,276],[380,284],[313,366],[291,275],[70,291]],"#ffd19b",ink,7)
		else:
			I.shape(n,[[0,0],[795,0],[1078,1080],[0,1080]],"#e8ddd3")
			I.shape(n,[[840,0],[1920,0],[1920,1080],[1160,1080]],"#4c3959")
			I.curve(n,[[1280,1060],[1770,846],[1870,426]],"#a087b0",9)
			I.stroke(n,[[897,340],[1340,290]],"#b49db8",5)
			I.stroke(n,[[1025,1040],[1320,847]],"#b49db8",7)
			# One court edge and one new drawn trajectory; never four hobby icons.
			I.shape(n,[[0,849],[446,778],[939,962],[680,1080],[0,1080]],"#617f74",ink,6)
			I.stroke(n,[[0,929],[515,871],[838,1004]],"#fff3d7",7)
			I.burst(n,[[930,36],[1845,28],[1880,216],[1512,255],[1424,329],[1407,257],[941,241]],"#fff3d7",ink,6)
	elif part=="foreground":
		assert(variant=="a")
		# A huge curling near paper swallows the torso, leaving the face complete.
		paper(n,[[-160,754],[560,612],[816,888],[1180,920],[1090,1230],[56,1190]],ink,[[560,612],[816,888],[416,952]])
		I.shape(n,[[416,952],[816,888],[1180,920],[925,1010]],"#dce2c8",ink,5)
		I.stroke(n,[[35,883],[346,807],[535,847]],"#6c9588",8)
		I.stroke(n,[[59,937],[292,894],[519,921]],"#6c9588",6)
		# Ghost pose on the work paper, a generic animation study not a new face.
		I.oval(n,277,977,32,37,"#fff3d7","#73978b",6)
		I.stroke(n,[[278,1016],[303,1110],[372,1150]],"#73978b",8)
		I.stroke(n,[[290,1045],[208,1074],[162,1035]],"#73978b",8)
		I.stroke(n,[[294,1048],[389,1032],[438,996]],"#73978b",8)
	elif part=="hybrid":
		assert(variant=="b")
		# One newly drawn object: paddle head plus perspective drawing pencil shaft.
		I.shape(n,[[-118,123],[-41,151],[565,-234],[458,-390]],"#e6bd86",ink,11)
		I.shape(n,[[-118,123],[458,-390],[475,-322],[-30,146]],"#ffd8a0")
		I.stroke(n,[[-64,116],[481,-296]],"#ba8c68",7)
		I.shape(n,[[-118,123],[-41,151],[-171,204]],"#f5e0b9",ink,7)
		I.shape(n,[[-171,204],[-151,164],[-116,185]],"#40343b")
		I.oval(n,627,-502,320,340,"#ad3f42",ink,14)
		I.oval(n,615,-524,292,315,"#ed7158",ink,7)
		I.oval(n,611,-520,213,232,"#f49365")
		I.curve(n,[[493,-712],[426,-630],[416,-490]],"#ffd49a",15)
		# Pencil hatch on the paddle face communicates drawing rather than a logo.
		I.stroke(n,[[504,-521],[677,-660],[761,-536],[587,-386],[504,-521]],"#8f4447",9)
		I.stroke(n,[[512,-491],[615,-402]],"#8f4447",6)
		I.oval(n,896,-61,59,58,"#fff3d7",ink,7)
		I.curve(n,[[917,-159],[1014,-293],[1008,-450]],"#fff3d7",8)
	else: assert(false,"Unknown intro part")
	return n
