extends RefCounted
## Static thumbnail scenery. Uses the existing LiveDrawing/profile ink route.
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const Backdrop = preload("res://common/storytime/production/Backdrop.gd")

static func points(raw: Array) -> PackedVector2Array:
	var result = PackedVector2Array()
	for p in raw: result.append(Vector2(p[0],p[1]))
	return result

static func patch(node: Node2D, raw: Array, col: String, outline: String="", width: float=3.0) -> void:
	var pts = points(raw)
	node.fills.append({"poly":pts,"col":Color(col),"at":0.0})
	if outline != "":
		var closed = pts.duplicate()
		closed.append(pts[0])
		node.stroke_list.append({"pts":closed,"w":width,"col":Color(outline),"smooth":false})

static func line(node: Node2D, raw: Array, col: String, width: float=3.0) -> void:
	node.stroke_list.append({"pts":points(raw),"w":width,"col":Color(col),"smooth":false,"pressure":PackedFloat32Array([.7,1.0,.85,.65])})

static func ellipse(node: Node2D, x: float, y: float, rx: float, ry: float, col: String) -> void:
	var raw: Array=[]
	for i in range(48):
		var a = float(i)*TAU/48
		raw.append([x+cos(a)*rx,y+sin(a)*ry])
	patch(node,raw,col)

static func background(parent: Node2D, author: String, config: Dictionary) -> void:
	var kind: String=config.kind
	var ink: String=Assets.profile(author).ink
	if config.has("set"):
		var scenery=Backdrop.new()
		scenery.set_kind(config.set)
		scenery.modulate.a=float(config.get("set_opacity",.5))
		parent.add_child(scenery)
	var node=Drawing.new()
	match kind:
		"gaming":
			patch(node,[[1000,0],[1920,0],[1920,1080],[1150,1080],[920,600]],"#287f88")
			ellipse(node,1450,520,600,600,"#46b1b0")
			line(node,[[1060,210],[1110,120],[1260,65]],"#a8e8db",7)
			line(node,[[1720,995],[1830,870],[1870,720]],"#a8e8db",7)
			patch(node,[[0,790],[920,745],[970,1080],[0,1080]],"#173a48")
		"sketchbook":
			patch(node,[[0,0],[1130,0],[1040,1080],[0,1080]],"#faf3e7")
			for y in [670,745,820,895,970,1045]: line(node,[[0,y],[1000,y-5]],"#d5dfd5",2)
			line(node,[[87,0],[95,1080]],"#e4afa0",3)
			ellipse(node,1490,690,480,590,"#d6e5c6")
			patch(node,[[100,735],[850,680],[900,1020],[80,1060]],"#e7d8be")
		"rain":
			patch(node,[[0,965],[1920,912],[1920,1080],[0,1080]],"#5d7773")
			ellipse(node,510,1000,480,65,"#a5bbb0")
			ellipse(node,510,1000,360,30,"#c7d6be")
			# A row of mailboxes, the place where Neeko was found.
			for x in [970,1190,1410]:
				patch(node,[[x,570],[x+150,565],[x+156,720],[x-4,725]],"#819e93","#354c4d",4)
				line(node,[[x+25,630],[x+125,627]],"#354c4d",7)
				line(node,[[x+77,725],[x+80,945]],"#405b59",12)
			for p in [[60,625],[920,175],[1050,300],[1850,420],[120,900],[850,820],[970,510],[1730,110]]:
				line(node,[[p[0],p[1]],[p[0]-24,p[1]+60]],"#9ab5b5",4)
		"chat":
			ellipse(node,365,865,550,650,"#e6d4f0")
			ellipse(node,1530,860,560,650,"#c3dbe8")
			patch(node,[[690,590],[1130,576],[1140,695],[1050,702],[985,750],[990,705],[685,713]],"#fff4ee",ink,4)
			patch(node,[[865,790],[1220,775],[1225,885],[1180,887],[1230,940],[1100,893],[858,911]],"#d8c7e5",ink,4)
			for x in [820,910,1000]: ellipse(node,x,648,13,13,"#986984")
			for x in [960,1040,1120]: ellipse(node,x,844,11,11,"#715980")
		"kitchen":
			for y in [580,705,830]: line(node,[[0,y],[1100,y-4]],"#cfaa91",3)
			for x in [120,350,580,810,1040]:line(node,[[x,580],[x-5,930]],"#cfaa91",3)
			patch(node,[[0,905],[1140,877],[1140,1080],[0,1080]],"#c6b398",ink,4)
			line(node,[[0,918],[1130,892]],"#f4e5ca",14)
			patch(node,[[1790,320],[1920,285],[1920,1080],[1800,1080]],"#ac8a76",ink,4)
		"night":
			patch(node,[[75,60],[670,65],[680,670],[65,675]],"#151a3a","#716991",4)
			line(node,[[370,65],[375,665]],"#716991",7)
			line(node,[[70,365],[675,360]],"#716991",7)
			ellipse(node,510,200,58,58,"#c6c4db")
			ellipse(node,535,184,55,55,"#151a3a")
			patch(node,[[800,980],[1920,927],[1920,1080],[800,1080]],"#302b4f")
		"celebration":
			ellipse(node,550,535,690,670,"#ffdb82")
			# Fixed celebratory paper flecks, kept off the face and type.
			for c in [[950,80,"#b66b94"],[1120,190,"#4b9ca1"],[1660,80,"#dba34c"],[1820,280,"#816cac"],[75,800,"#4b9ca1"],[820,955,"#c6687c"],[920,740,"#816cac"]]:
				patch(node,[[c[0],c[1]],[c[0]+22,c[1]-8],[c[0]+40,c[1]+48],[c[0]+18,c[1]+56]],c[2])
		"animation":
			patch(node,[[0,0],[1050,0],[980,1080],[0,1080]],"#f4eada")
			patch(node,[[80,635],[1060,625],[1130,1080],[55,1080]],"#8dbcb4",ink,4)
			for x in [130,350,570,790]:
				patch(node,[[x,710],[x+150,710],[x+153,945],[x-3,947]],"#e4ece0","#588f8b",3)
			line(node,[[130,985],[1050,977]],"#426e70",5)
		"exam":
			# Calm sage chalkboard framing behind the actual answer-paper art.
			patch(node,[[0,0],[820,0],[730,1080],[0,1080]],"#b3c5ad")
			line(node,[[65,680],[630,665]],"#86997f",3)
			line(node,[[75,790],[660,773]],"#86997f",3)
		"crush":
			patch(node,[[0,0],[1080,0],[975,545],[0,610]],"#f6e9df")
			ellipse(node,1430,750,570,770,"#f1ccd1")
		"channel":
			patch(node,[[0,450],[995,422],[860,1080],[0,1080]],"#b6d3bd")
			patch(node,[[995,422],[1920,440],[1920,1080],[860,1080]],"#e5c684")
			line(node,[[910,630],[1010,710],[955,808]],"#f6f1df",12)
		"collision":
			# San Francisco travel context behind the separate highway event vignette.
			var bridge=Backdrop.new()
			bridge.set_kind("sf_bridge")
			bridge.scale=Vector2(.55,.55)
			bridge.position=Vector2(845,425)
			bridge.modulate=Color(1,1,1,.6)
			parent.add_child(bridge)
			patch(node,[[700,815],[1920,790],[1920,1080],[700,1080]],"#687a86")
			for x in [800,1170,1540]: line(node,[[x,1043],[x+210,1038]],"#f1dbc0",8)
			patch(node,[[0,0],[760,0],[950,630],[740,1080],[0,1080]],"#f0dcc0")
		_: assert(false,"Unknown thumbnail background: "+kind)
	node.prepare()
	node.progress=1.0
	parent.add_child(node)

static func headline(parent: Node2D, item: Dictionary) -> void:
	# Editorial type can use several concentric strokes without repeating copy
	# in the layout's headline phrase. Order outermost to innermost.
	for edge in item.get("outline_layers",[]):
		# System fonts can produce much thinner native outlines than requested.
		# Concentric offset glyphs keep the editorial stroke width in canvas pixels.
		for step in range(48):
			var back: Dictionary=item.duplicate(true)
			back.erase("outline_layers")
			var offset=Vector2.from_angle(float(step)*TAU/48.0)*float(edge.size)
			back.position=[float(item.position[0])+offset.x,float(item.position[1])+offset.y]
			back.outline=0
			back.color=edge.color
			back.shadow_color="#00000000"
			headline(parent,back)
	var font=load(item.get("font","res://assets/fonts/Impact.ttf"))
	var size_px: int=item.size
	while font.get_string_size(item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px).x>float(item.max_width):size_px-=1
	assert(size_px>=120,"Shorten headline rather than shrinking it to caption size")
	var label=Label.new()
	label.text=item.text
	label.position=Vector2(item.position[0],item.position[1])
	label.rotation_degrees=float(item.get("angle",0))
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",size_px)
	label.add_theme_color_override("font_color",Color(item.color))
	label.add_theme_color_override("font_outline_color",Color(item.get("outline_color","#ffffff")))
	label.add_theme_constant_override("outline_size",int(item.get("outline",0)))
	label.add_theme_color_override("font_shadow_color",Color(item.get("shadow_color","#182e3844")))
	label.add_theme_constant_override("shadow_offset_x",3)
	label.add_theme_constant_override("shadow_offset_y",6)
	parent.add_child(label)
