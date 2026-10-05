extends "res://shorts/godot/InkPoseArt.gd"
## The approved ink art, extended with authored contact poses and stable ink washes.
## These are separate Shorts illustrations. Original storytime art is read-only.
var action := "rest"
var shade := Color("#aaa6af")
var accent := Color("#ab8fab")
var shading := 0.28
var accessory := ""

func _draw() -> void:
	if view == "back" and author == "adb":
		draw_adb_back()
		wash()
		return
	super._draw()
	wash()
	if action == "listen" or accessory == "headphones": headphones()
	if action == "glasses": glasses()
	if action == "phone": phone()
	if action == "sketch": sketchbook()

func draw_body() -> void:
	var saved_emotion = emotion
	if author == "adb" and action != "rest":
		draw_adb_action_body()
	else:
		if author == "nemi" and action != "rest": emotion = "shy"
		super.draw_body()
	emotion = saved_emotion
	if action != "rest": gesture()

func draw_adb_action_body() -> void:
	curve([[71,-216],[83,-225],[91,-217],[94,-205]],1.8)
	curve([[-27,-257],[-65,-251],[-92,-237],[-111,-208],[-127,-159],[-118,-96],[-122,-51],[-105,-38],[-86,-43],[-74,-77],[-61,-120],[-62,-160],[-58,-176]],1.9,true)
	curve([[-74,-216],[-66,-163],[-73,-100],[-66,-21],[-29,-12],[33,-14],[73,-25],[67,-98],[72,-156],[71,-216]],1.9,true)
	line([[-27,-257],[-42,-237],[-17,-191],[0,-232],[17,-191],[41,-236],[26,-256]],1.4)
	curve([[-17,-191],[-3,-145],[0,-76],[0,-15]],1.0)
	for y in [-159,-119,-79,-39]: draw_circle(Vector2(3,y),2.1,ink)
	line([[-116,-63],[-86,-56]],1.2)
	curve([[-105,-40],[-107,-26],[-112,-17],[-105,-5],[-98,2],[-91,-1],[-87,-16],[-87,-31]],1.3,true)
	curve([[-65,-20],[-76,61],[-70,128],[-65,200],[-70,260],[-83,330],[-69,348],[-47,351],[-16,341],[-10,276],[-5,211],[1,97],[6,42],[15,79],[20,168],[30,246],[37,343],[59,351],[83,345],[87,322],[76,233],[80,156],[79,76],[72,-24]],1.9,true)
	curve([[-52,20],[-56,77],[-42,137],[-49,178]],1.0)
	curve([[54,16],[51,55],[64,109],[57,165]],1.0)
	curve([[-41,203],[-27,224],[-25,274],[-29,305]],1.0)
	line([[-66,337],[-18,334]],1.2);line([[36,335],[82,335]],1.2)
	shoe(-43,349);shoe(62,349)

func draw_shy_hand() -> void:
	if action == "rest": super.draw_shy_hand()

func gesture() -> void:
	match action:
		"listen", "glasses":
			curve([[94,-205],[123,-168],[138,-175],[136,-199],[120,-253],[95,-303],[82,-307],[68,-294],[70,-277],[95,-229],[93,-210]],1.8,true)
			curve([[111,-182],[113,-203],[98,-234],[86,-266]],.9)
			line([[69,-290],[87,-304]],1.1)
			curve([[73,-298],[64,-306],[59,-322],[64,-327],[72,-316],[70,-334],[75,-337],[81,-323],[87,-331],[92,-328],[86,-310],[87,-302],[73,-298]],1.2,true)
			line([[73,-314],[84,-309]],.8)
		"peace", "wave":
			curve([[94,-205],[126,-182],[143,-187],[150,-211],[157,-253],[164,-303],[153,-314],[138,-311],[128,-292],[126,-247],[109,-221]],1.8,true)
			curve([[137,-198],[144,-222],[150,-263],[151,-293]],.9)
			if action == "peace":
				curve([[141,-298],[128,-311],[120,-342],[124,-346],[134,-319],[132,-353],[137,-355],[144,-326],[152,-337],[157,-334],[150,-310],[152,-302],[141,-298]],1.2,true)
			else:
				curve([[139,-298],[128,-315],[119,-335],[122,-340],[132,-323],[127,-348],[131,-351],[140,-328],[137,-354],[142,-355],[149,-329],[150,-350],[155,-349],[156,-324],[164,-334],[169,-331],[162,-309],[153,-300],[139,-298]],1.2,true)
		"phone":
			curve([[94,-208],[129,-163],[128,-121],[107,-98],[91,-112],[87,-158],[71,-198]],1.8,true)
			curve([[91,-112],[81,-125],[81,-147],[93,-155],[108,-147],[109,-127],[102,-111],[91,-112]],1.2,true)
			line([[88,-145],[101,-140],[88,-136],[103,-131]],.8)
		"sketch":
			curve([[95,-205],[113,-170],[119,-137],[96,-107],[49,-93],[40,-107],[44,-124],[86,-144],[82,-178]],1.8,true)
			curve([[41,-125],[26,-127],[20,-116],[29,-100],[40,-100],[47,-106],[46,-120],[41,-125]],1.2,true)
			line([[23,-119],[38,-114],[27,-109],[40,-107]],.8)
		"point":
			curve([[94,-207],[122,-169],[132,-145],[161,-142],[194,-144],[198,-159],[170,-173],[145,-181],[109,-222]],1.8,true)
			curve([[194,-144],[205,-135],[216,-135],[220,-143],[232,-144],[238,-151],[213,-153],[224,-161],[221,-166],[209,-162],[198,-159]],1.2,true)
		_:
			curve([[94,-204],[115,-157],[122,-104],[113,-55],[96,-51],[87,-96],[78,-152]],1.8,true)

func headphones() -> void:
	curve([[-67,-332],[-93,-452],[103,-448],[74,-326]],9.0)
	curve([[-67,-332],[-86,-442],[97,-440],[74,-326]],3.4)
	draw_style_box(headphone_pad(),Rect2(-76,-347,24,43))
	draw_style_box(headphone_pad(),Rect2(58,-347,25,43))
	line([[75,-303],[85,-270],[88,-231]],1.0)

func headphone_pad() -> StyleBoxFlat:
	var b = StyleBoxFlat.new()
	b.bg_color = shade
	b.border_color = ink
	b.set_border_width_all(2)
	b.set_corner_radius_all(8)
	return b

func glasses() -> void:
	var dark = ink
	draw_colored_polygon(PackedVector2Array([Vector2(-46,-330),Vector2(-5,-330),Vector2(-9,-307),Vector2(-37,-309)]),dark)
	draw_colored_polygon(PackedVector2Array([Vector2(7,-330),Vector2(49,-330),Vector2(40,-309),Vector2(13,-307)]),dark)
	line([[-6,-324],[8,-324],[56,-327]],3.0)
	draw_line(Vector2(-38,-324),Vector2(-21,-313),paper,1.4,true)
	draw_line(Vector2(20,-324),Vector2(38,-317),paper,1.4,true)

func phone() -> void:
	var b = StyleBoxFlat.new()
	b.bg_color = paper.darkened(.10)
	b.border_color = ink
	b.set_border_width_all(2)
	b.set_corner_radius_all(5)
	draw_style_box(b,Rect2(84,-195,42,68))
	draw_circle(Vector2(92,-185),3.8,ink)
	draw_circle(Vector2(103,-184),3.8,ink)
	line([[94,-142],[117,-142]],.7)
	curve([[88,-155],[79,-151],[78,-143],[87,-134],[94,-137],[91,-146],[88,-155]],1.1,true)
	line([[119,-154],[128,-148],[125,-143],[119,-145],[126,-139],[124,-134],[117,-137]],1.0)

func sketchbook() -> void:
	var pts = PackedVector2Array([Vector2(-17,-147),Vector2(92,-154),Vector2(102,-48),Vector2(-8,-40)])
	draw_colored_polygon(pts,paper.lightened(.05))
	draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),ink,1.5,true)
	for y in range(-139,-43,12): line([[-20,y],[-8,y-1]],1.1)
	curve([[19,-99],[26,-133],[71,-130],[76,-101],[81,-74],[22,-72],[19,-99]],.9)
	line([[28,-100],[38,-103],[50,-100],[58,-103],[69,-100]],.8)
	curve([[41,-87],[49,-81],[56,-81],[62,-88]],.9)
	# Pencil extends from the authored finger grip; it cannot slide away from the hand.
	draw_line(Vector2(26,-114),Vector2(81,-146),ink,4.0,true)
	draw_line(Vector2(26,-114),Vector2(78,-145),paper,1.0,true)
	line([[78,-149],[90,-153],[81,-143]],1.0)
	# Fingers overlap the pencil at the grip; the completed tool and hand remain locked.
	curve([[26,-124],[21,-120],[24,-113],[32,-107],[39,-109],[38,-116],[32,-118],[26,-124]],1.1,true)
	line([[23,-119],[34,-114],[26,-112],[37,-110]],.8)

func wash() -> void:
	var w = Color(shade,shading)
	if view == "back":
		draw_colored_polygon(PackedVector2Array([Vector2(37,-337),Vector2(65,-299),Vector2(58,-178),Vector2(39,-157),Vector2(27,-260)]),w)
	else:
		# Deliberate light-from-left shadow shapes; no unstable procedural grain on ink.
		draw_colored_polygon(PackedVector2Array([Vector2(32,-188),Vector2(64,-195),Vector2(63,-43),Vector2(26,-36),Vector2(14,-98)]),w)
		if author == "nemi":
			draw_colored_polygon(PackedVector2Array([Vector2(59,-272),Vector2(73,-246),Vector2(64,-174),Vector2(46,-151),Vector2(42,-224)]),w)
			draw_colored_polygon(PackedVector2Array([Vector2(39,18),Vector2(64,20),Vector2(87,92),Vector2(42,105)]),w)
		else:
			draw_colored_polygon(PackedVector2Array([Vector2(46,44),Vector2(67,48),Vector2(68,194),Vector2(77,310),Vector2(48,315)]),w)
		for y in [-172,-157,-142,-127,-112]: line([[48,y],[60,y-7]],.55)
		if author == "nemi":
			for y in [-218,-202,-186]: line([[54,y],[67,y-6]],.55)
			for y in [38,50,62,74,86]: line([[48,y],[68,y-6]],.55)

func draw_adb_head() -> void:
	if view != "profile": draw_adb_front_head(); return
	curve([[-31,-377],[-1,-397],[39,-382],[48,-351],[50,-327],[62,-311],[73,-303],[62,-297],[64,-281],[50,-269],[44,-254],[29,-252],[10,-266],[-22,-281],[-40,-321],[-41,-355],[-31,-377]],1.8,true)
	var hair = PackedVector2Array([Vector2(-43,-310),Vector2(-64,-338),Vector2(-55,-367),Vector2(-67,-388),Vector2(-36,-381),Vector2(-26,-407),Vector2(-4,-396),Vector2(25,-410),Vector2(31,-393),Vector2(60,-382),Vector2(53,-355),Vector2(36,-342),Vector2(30,-366),Vector2(8,-363),Vector2(-12,-339),Vector2(-26,-334),Vector2(-35,-302)])
	draw_colored_polygon(hair,ink)
	line([[15,-260],[16,-239],[31,-228]],1.2)

func draw_adb_back() -> void:
	curve([[-31,-257],[-85,-240],[-111,-202],[-121,-151],[-118,-74],[-104,-49],[-84,-52],[-79,-114],[-70,-166]],1.9,true)
	curve([[31,-257],[85,-240],[111,-202],[121,-151],[118,-74],[104,-49],[84,-52],[79,-114],[70,-166]],1.9,true)
	curve([[-72,-218],[-64,-135],[-73,-36],[-43,-12],[43,-12],[73,-36],[64,-135],[72,-218]],1.9,true)
	line([[-33,-252],[0,-239],[33,-252]],1.2)
	line([[-65,-210],[65,-210]],.9)
	curve([[-66,-20],[-76,90],[-65,197],[-78,339],[-37,350],[-16,336],[-4,159],[4,49],[17,149],[31,337],[66,350],[85,332],[75,194],[78,84],[68,-23]],1.8,true)
	line([[-64,332],[-19,334]],1.0);line([[33,334],[79,332]],1.0)
	shoe(-41,348);shoe(59,348)
	curve([[-37,-273],[-51,-299],[-55,-342],[-43,-374],[-12,-391],[22,-385],[47,-368],[57,-333],[48,-295],[33,-274],[2,-263],[-37,-273]],1.8,true)
	var hair = PackedVector2Array([Vector2(-51,-297),Vector2(-67,-337),Vector2(-59,-367),Vector2(-72,-390),Vector2(-40,-380),Vector2(-33,-408),Vector2(-11,-394),Vector2(17,-408),Vector2(33,-387),Vector2(62,-384),Vector2(57,-360),Vector2(74,-341),Vector2(59,-309),Vector2(45,-283),Vector2(16,-291),Vector2(-9,-284),Vector2(-32,-289)])
	draw_colored_polygon(hair,ink)
	curve([[-12,-281],[-12,-258],[13,-256],[21,-280]],1.0)

func draw_adb_front_head() -> void:
	curve([[-43,-370],[-56,-353],[-59,-326],[-55,-302],[-38,-276],[-12,-257],[5,-256],[23,-264],[46,-282],[59,-311],[58,-346],[42,-369],[13,-384],[-24,-383],[-43,-370]],1.8,true)
	curve([[-54,-312],[-64,-319],[-70,-310],[-65,-299],[-58,-296]],1.2,true)
	curve([[58,-314],[66,-317],[73,-305],[65,-298],[58,-298]],1.2,true)
	curve([[-24,-264],[-24,-244],[-27,-235],[-33,-229]],1.3)
	curve([[22,-264],[22,-245],[28,-235],[33,-230]],1.3)
	# Tousled navy hair: short uneven tufts, no symmetrical helmet silhouette.
	var hair := PackedVector2Array()
	for point in [[-60,-301],[-74,-330],[-67,-357],[-78,-377],[-46,-367],[-41,-396],[-22,-388],[-32,-410],[-2,-400],[23,-409],[37,-391],[60,-395],[52,-375],[76,-354],[64,-336],[69,-317],[56,-299],[52,-334],[32,-346],[31,-324],[15,-344],[0,-358],[-15,-338],[-36,-316],[-44,-327],[-43,-346],[-53,-335],[-60,-301]]: hair.append(v(point))
	draw_colored_polygon(hair,ink)
	draw_polyline(hair,ink,1.7,true)
	curve([[-27,-387],[-16,-383],[-5,-376],[3,-366]],.8)
	curve([[27,-388],[34,-377],[46,-362],[53,-350]],.8)
