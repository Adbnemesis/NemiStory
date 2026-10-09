extends RefCounted
## EP03 symbolic school/channel evidence, through shared stable/live ink playback.
## Faces are the existing illustrated ADB identity, never recovered human footage.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["school_youtube_browser","school_youtube_phone","school_youtube_subscribers","school_youtube_peers","school_youtube_private_public","school_youtube_archive","school_youtube_then_now"]
const PAPER=Color("#fffdf8")
const WASH=Color("#ece7de")
const RED=Color("#b34b48")
const SKIN=Color("#f3cfb6")
const HAIR=Color("#252b38")
const SHIRT=Color("#7b9c80")

static func line(n: Node2D,raw: Array,ink: Color,w: float=2.6,fill: Variant=null,smooth: bool=false,offset: Vector2=Vector2.ZERO,factor: float=1.0) -> void:
	var points=PackedVector2Array()
	for p in raw: points.append(offset+Vector2(p[0],p[1])*factor)
	if fill!=null: n.fills.append({"poly":points,"col":fill,"at":.88})
	n.stroke_list.append({"pts":points,"col":ink,"w":w*factor,"smooth":smooth,"pause":.025,"pressure":PackedFloat32Array([.65,.9,.86,.91,.5])})

static func label(n: Node2D,author: String,text: String,pos: Vector2,size: float=24.0) -> void:
	# Use the selected author's real lettering paths; no generic-font fallback.
	var data=Profile.compose(author,text,size)
	for source in data.strokes:
		var stroke: Dictionary=source.duplicate()
		var points=PackedVector2Array()
		for p in source.pts: points.append(p+pos)
		stroke["pts"]=points
		n.stroke_list.append(stroke)

static func adb_bust(n: Node2D,center: Vector2,factor: float,ink: Color,open_mouth: bool=true) -> void:
	# Compact reconstruction of the actual colour-mode rig: curtain hair and
	# green button shirt. The oatmeal-knit prose is not the rendered identity.
	line(n,[[-76,129],[-77,81],[-63,64],[-28,55],[-23,36],[22,36],[27,56],[61,64],[78,82],[80,129],[-76,129]],ink,3,SHIRT,false,center,factor)
	line(n,[[-21,38],[-18,61],[0,88],[19,62],[21,38]],ink,2.7,SKIN,false,center,factor)
	line(n,[[-29,53],[-24,83],[0,102],[24,83],[29,53]],ink,2.5,null,false,center,factor)
	line(n,[[0,102],[0,127]],ink,2,null,false,center,factor)
	for y in [110,122]: line(n,[[-1,y],[1,y]],ink,3,null,false,center,factor)
	line(n,[[-28,-83],[-39,-99],[-14,-88],[14,-87],[36,-97],[28,-83],[51,-72],[66,-43],[67,-9],[57,28],[35,50],[8,58],[-21,53],[-48,37],[-62,10],[-69,-27],[-62,-57],[-47,-75],[-28,-83]],ink,3,HAIR,false,center,factor)
	line(n,[[-45,0],[-32,-19],[-17,-36],[-3,-59],[10,-39],[24,-24],[43,-2],[45,15],[33,32],[14,43],[-1,46],[-24,39],[-39,24],[-45,0]],ink,2.4,SKIN,false,center,factor)
	line(n,[[-33,-70],[-11,-78],[5,-75]],Color("#46515b"),2,null,false,center,factor)
	line(n,[[16,-73],[39,-61],[48,-40]],Color("#46515b"),2,null,false,center,factor)
	line(n,[[-30,-4],[-18,-8],[-7,-4]],ink,2.4,null,false,center,factor)
	line(n,[[10,-4],[22,-7],[32,-2]],ink,2.4,null,false,center,factor)
	line(n,[[-20,-6],[-20,3]],ink,5,null,false,center,factor)
	line(n,[[22,-5],[22,3]],ink,5,null,false,center,factor)
	line(n,[[-31,-14],[-14,-16]],ink,1.9,null,false,center,factor)
	line(n,[[13,-17],[32,-13]],ink,1.9,null,false,center,factor)
	line(n,[[0,4],[-2,12],[3,14]],ink,1.6,null,false,center,factor)
	if open_mouth:
		line(n,[[-12,23],[12,23],[9,33],[0,37],[-9,32],[-12,23]],ink,2,Color("#49363a"),false,center,factor)
		line(n,[[-7,25],[7,25]],PAPER,2,null,false,center,factor)
	else: line(n,[[-12,27],[0,30],[12,27]],ink,2.2,null,false,center,factor)

static func play(n: Node2D,center: Vector2,size: float,ink: Color) -> void:
	line(n,[[-size,-size],[size,-size],[size,size],[-size,size],[-size,-size]],RED,1.8,RED,false,center)
	line(n,[[-size*.28,-size*.52],[size*.48,0],[-size*.28,size*.52],[-size*.28,-size*.52]],PAPER,1.8,PAPER,false,center)

static func browser(n: Node2D,author: String,ink: Color) -> void:
	line(n,[[-250,-145],[248,-143],[250,144],[-248,145],[-250,-145]],ink,3.2,PAPER)
	line(n,[[-250,-107],[250,-105]],ink,1.8)
	for x in [-230,-216,-202]: line(n,[[x,-126],[x+2,-126]],Color("#a8a29a"),4)
	line(n,[[-167,-133],[160,-132],[164,-117],[-169,-116],[-167,-133]],Color("#bbb3a7"),1.3,WASH)
	play(n,Vector2(208,-124),9,ink)
	line(n,[[-230,-86],[80,-84],[82,96],[-231,98],[-230,-86]],Color("#aaa59c"),1.6,Color("#f2ece3"))
	adb_bust(n,Vector2(-84,-15),.71,ink)
	# Deliberately illustrative recommendation cards, with no real names/views.
	for y in [-81,-20,41]:
		line(n,[[105,y],[228,y+1],[228,y+43],[104,y+44],[105,y]],Color("#c4beb3"),1.3,WASH)
		play(n,Vector2(128,y+22),8,ink)
		line(n,[[150,y+14],[210,y+14]],Color("#a99d90"),1.4)
		line(n,[[150,y+28],[198,y+28]],Color("#b6ada0"),1.2)
	line(n,[[-230,114],[-64,114]],ink,2)
	line(n,[[-230,128],[-100,128]],Color("#b6ada0"),1.4)
	play(n,Vector2(221,121),8,ink)

static func peer(n: Node2D,center: Vector2,factor: float,ink: Color,hair: Color,shirt: Color) -> void:
	# Anonymous observers smile toward the shared screen; no bullying gesture.
	line(n,[[-52,0],[-48,-69],[-30,-93],[27,-92],[50,-68],[55,0],[-52,0]],ink,2.6,shirt,false,center,factor)
	line(n,[[-24,-96],[-33,-117],[-28,-153],[-5,-172],[25,-160],[34,-132],[28,-107],[8,-91],[-24,-96]],ink,2.6,SKIN,false,center,factor)
	line(n,[[-32,-130],[-38,-151],[-22,-175],[4,-182],[28,-170],[36,-150],[30,-137],[17,-157],[-6,-163],[-24,-145],[-32,-130]],ink,2.6,hair,false,center,factor)
	line(n,[[-13,-130],[-5,-133],[2,-130]],ink,2,null,false,center,factor)
	line(n,[[14,-131],[20,-132],[25,-128]],ink,2,null,false,center,factor)
	line(n,[[-7,-111],[4,-107],[15,-111]],ink,2,null,false,center,factor)
	line(n,[[0,-83],[1,-5]],Color("#b0a69a"),1.5,null,false,center,factor)

static func make(author: String,kind: String) -> Node2D:
	var n=Drawing.new()
	var ink=Color(Profile.profile(author).ink)
	match kind:
		"school_youtube_browser": browser(n,author,ink)
		"school_youtube_phone":
			line(n,[[-96,-186],[97,-185],[100,186],[-98,190],[-96,-186]],ink,3.3,Color("#dadbd6"))
			line(n,[[-82,-151],[81,-150],[82,145],[-83,148],[-82,-151]],ink,1.8,PAPER)
			line(n,[[-21,-170],[22,-170]],ink,2)
			line(n,[[-15,168],[16,168]],ink,3)
			adb_bust(n,Vector2(0,-2),.89,ink)
			# The recording dot is bounded to the phone screen, never a fake photo.
			line(n,[[62,-131],[65,-131]],RED,9)
			line(n,[[-67,-129],[-47,-130]],Color("#bfb6a8"),1.6)
		"school_youtube_subscribers":
			line(n,[[-245,-145],[244,-143],[245,144],[-244,145],[-245,-145]],ink,3.1,PAPER)
			line(n,[[-245,-105],[245,-104]],ink,1.6)
			play(n,Vector2(-209,-123),10,ink)
			adb_bust(n,Vector2(-161,-39),.52,ink,false)
			line(n,[[-225,60],[-97,60]],Color("#b8aea0"),2)
			label(n,author,"1k",Vector2(-62,-53),75)
			label(n,author,"SUBSCRIBERS",Vector2(-63,45),26)
			line(n,[[-62,90],[199,90]],Color("#8a6245"),2.5)
		"school_youtube_peers":
			peer(n,Vector2(-176,0),1.15,ink,Color("#655f57"),Color("#d7d2c7"))
			peer(n,Vector2(0,0),1.36,ink,Color("#4c4542"),Color("#dce2dc"))
			peer(n,Vector2(178,0),1.15,ink,Color("#7a6b5d"),Color("#ddd5c9"))
		"school_youtube_private_public":
			line(n,[[-264,-124],[-61,-124],[-60,123],[-265,125],[-264,-124]],ink,2.6,PAPER)
			line(n,[[65,-124],[264,-121],[265,124],[63,125],[65,-124]],ink,2.6,PAPER)
			peer(n,Vector2(-162,52),.72,ink,Color("#655f57"),WASH)
			for x in [101,162,222]: peer(n,Vector2(x,59),.46,ink,Color("#655f57"),WASH)
			line(n,[[-28,0],[29,0]],RED,3.4)
			line(n,[[14,-13],[29,0],[15,13]],RED,3.4)
			label(n,author,"ONE FRIEND",Vector2(-243,84),20)
			label(n,author,"WHOLE CLASS",Vector2(76,83),19)
		"school_youtube_archive":
			# Unnamed work papers and a closed old-video folder, not a ban claim.
			line(n,[[-230,-145],[-211,-164],[-18,-162],[-15,89],[-232,91],[-230,-145]],ink,2.5,Color("#ece3d6"))
			line(n,[[-212,-175],[-193,-185],[9,-179],[11,69],[-213,71],[-212,-175]],ink,2.5,PAPER)
			for y in [-130,-97,-64,-31]: line(n,[[-181,y],[-25,y+1]],Color("#a69e92"),1.8)
			line(n,[[1,-54],[42,-55],[62,-88],[144,-85],[167,-50],[244,-50],[249,177],[-1,185],[1,-54]],ink,3,Color("#ded2bf"))
			play(n,Vector2(123,69),28,ink)
			line(n,[[-180,103],[-149,88],[-129,104],[-128,170],[-183,171],[-180,103]],ink,2.7,WASH)
			line(n,[[-156,103],[-156,130]],ink,2.1)
		"school_youtube_then_now":
			line(n,[[-290,-169],[-26,-167],[-24,165],[-288,170],[-290,-169]],ink,2.6,PAPER)
			line(n,[[29,-169],[288,-167],[290,164],[27,170],[29,-169]],ink,2.6,PAPER)
			label(n,author,"THEN",Vector2(-255,-142),27)
			label(n,author,"NOW",Vector2(69,-142),27)
			line(n,[[-265,-89],[-47,-90],[-45,97],[-266,98],[-265,-89]],Color("#b8afa1"),1.5,Color("#f2ece3"))
			adb_bust(n,Vector2(-154,-5),.71,ink)
			play(n,Vector2(-57,133),10,ink)
			line(n,[[49,-88],[268,-87],[269,80],[48,82],[49,-88]],Color("#b8afa1"),1.5,Color("#f2ece3"))
			adb_bust(n,Vector2(156,-14),.61,ink,false)
			# Current page has an authored animation timeline and drawing pen.
			line(n,[[56,109],[261,109]],Color("#a99d90"),1.6)
			for x in [67,122,177,232]: line(n,[[x,97],[x+22,97],[x+22,121],[x,121],[x,97]],ink,1.4)
			line(n,[[70,145],[244,145]],Color("#b8afa1"),1.4)
			line(n,[[206,38],[240,-14],[246,-10],[214,43],[206,38]],ink,2.3,Color("#8a6245"))
		_:
			assert(false,"Unknown school YouTube art kind: "+kind)
	n.prepare()
	return n
