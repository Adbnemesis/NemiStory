extends Node2D
const Motion=preload("res://common/storytime/production/Motion.gd")
## Seekable sketchbook scenery. Canonical Nemi acting remains in ProductionStage.
var objects: Array=[]
var events: Array=[]
var location := "sketchbook"
var scene_start := 0.0
var clock := 0.0
var wall_index := 0
var focus_wall := 0
var entry_card: Dictionary={}
var font := ThemeDB.fallback_font
const INK=Color("#553b47")
const PAPER=Color("#faf7f1")
const SHADOW=Color("#d6cec6")
const ROSE=Color("#bd7885")
const SAGE=Color("#8d9b85")

func sample(time: float) -> void:
	clock=time
	queue_redraw()

func line(points: Array, color: Color=INK, width: float=4.0) -> void:
	draw_polyline(PackedVector2Array(points),color,width,true)

func shape(points: Array, fill: Color, width: float=4.0, stroke: Color=INK) -> void:
	draw_colored_polygon(PackedVector2Array(points),fill)
	var edge:=points.duplicate()
	edge.append(points[0])
	line(edge,stroke,width)

func text_center(text: String, p: Vector2, size: int, width: float, color: Color=INK) -> void:
	var fitted:=size
	var measured:=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	if measured>width: fitted=maxi(20,int(floor(size*width/measured)))
	draw_string(font,p-Vector2(width/2.0,0),text,HORIZONTAL_ALIGNMENT_CENTER,width,fitted,color)

func oval(p: Vector2, radius: Vector2, fill: Color, width: float=4.0) -> void:
	var points: Array=[]
	for i in range(65):
		var a:=TAU*i/64.0
		points.append(p+Vector2(cos(a)*radius.x,sin(a)*radius.y))
	shape(points,fill,width)

func progress(item_id: String, kind: String) -> float:
	for event in events:
		if str(event.object)==item_id and str(event.kind)==kind and clock>=float(event.at):
			return smoothstep(0.0,1.0,clampf((clock-float(event.at))/(float(event.end)-float(event.at)),0.0,1.0))
	return 0.0

func event_age(item_id: String, kind: String) -> float:
	for event in events:
		if str(event.object)==item_id and str(event.kind)==kind:
			return clock-float(event.at)
	return -1.0

func action_label(text: String, p: Vector2, selected: bool=false) -> void:
	if text.is_empty(): return
	var fill:=Color("#eee3d8") if not selected else Color("#e1e7da")
	shape([p+Vector2(-235,-53),p+Vector2(233,-49),p+Vector2(230,14),p+Vector2(-232,12)],fill,3)
	text_center(text,p-Vector2(0,8),39,430)

func notice_panel(text: String, p: Vector2, color: Color=INK) -> void:
	# A short paper notice masks held scenery labels without reaching Nemi's
	# hair. Its absolute placement is stable during both playback and seeks.
	var bounds:=Rect2(p+Vector2(-750,-70),Vector2(1500,110))
	draw_rect(bounds,PAPER)
	draw_rect(bounds,Color("#c4abb0"),false,2)
	text_center(text,p,46,1300,color)

func object_visible(item: Dictionary) -> bool:
	if not item.has("visible_from_event"): return true
	for event in events:
		if str(event.get("event",""))==str(item.visible_from_event):
			return clock>=float(event.at)
	return false

func draw_door(item: Dictionary, p: Vector2) -> void:
	var flat:=progress(str(item.id),"door_flatten")
	flat*=1.0-progress(str(item.id),"rewind")
	var left:=p.x-150.0-flat*32.0
	var right:=p.x+150.0+flat*32.0
	var bottom:=p.y+295.0
	var top:=lerpf(p.y-300.0,bottom-17.0,flat)
	# The door is an ink illusion: no extruded jamb or cast shadow.
	shape([Vector2(left-14,top-12),Vector2(right+14,top-8),Vector2(right+10,bottom+5),Vector2(left-11,bottom+5)],PAPER,6)
	shape([Vector2(left,top),Vector2(right,top+4),Vector2(right-3,bottom),Vector2(left+3,bottom)],Color("#f0e9df"),5)
	var h:=bottom-top
	line([Vector2(left+38,top+h*.12),Vector2(right-39,top+h*.13),Vector2(right-38,top+h*.49),Vector2(left+37,top+h*.48),Vector2(left+38,top+h*.12)],Color("#aa9696"),3)
	line([Vector2(left+37,top+h*.61),Vector2(right-39,top+h*.62),Vector2(right-38,top+h*.90),Vector2(left+36,top+h*.89),Vector2(left+37,top+h*.61)],Color("#aa9696"),3)
	oval(Vector2(right-34,top+h*.56),Vector2(11,maxf(2,10*(1-flat))),Color("#b99c81"),3)
	if flat>.95:
		line([Vector2(left-33,bottom-32),Vector2(left-63,bottom-53)],ROSE,5)
		line([Vector2(right+23,bottom-32),Vector2(right+54,bottom-52)],ROSE,5)
	var label:=str(item.get("text",""))
	if flat>.4: label="ONLY INK."
	action_label(label,Vector2(p.x,p.y-355))
	var age:=event_age(str(item.id),"door_flatten")
	if age>=0 and age<.6:
		var amount:=sin(age/.6*PI)
		line([p+Vector2(-210,10),p+Vector2(-240,-5)],Color(ROSE,amount),6)
		line([p+Vector2(205,20),p+Vector2(243,4)],Color(ROSE,amount),6)
	var rewind:=event_age(str(item.id),"rewind")
	if rewind>=0 and rewind<1.1:
		text_center("BACK IT UP",p+Vector2(0,-80),43,440,ROSE)
		for i in range(2):
			var x:=p.x-80+i*115
			shape([Vector2(x+28,p.y-26),Vector2(x-24,p.y+6),Vector2(x+28,p.y+38)],ROSE,0,ROSE)

func draw_tear(item: Dictionary, p: Vector2) -> void:
	var opened:=progress(str(item.id),"tear_open")
	if item.get("opened",false): opened=1.0
	var gap:=lerpf(26.0,148.0,opened)
	var top:=p.y-300.0
	var bottom:=p.y+295.0
	var l: Array=[]
	var r: Array=[]
	# Fixed authored fibres; material motion opens them, completed geometry holds.
	var offsets: Array=[-7,14,-12,8,-15,17,-8,11,-5]
	for i in range(offsets.size()):
		var y:=lerpf(top,bottom,float(i)/(offsets.size()-1))
		l.append(Vector2(p.x-gap+float(offsets[i]),y))
		r.push_front(Vector2(p.x+gap+float(offsets[i])*.7,y+4))
	var hole:=l+r
	shape(hole,Color("#756b71"),3)
	if opened>.05:
		# A second paper plane and receding path make actual space visible.
		shape([p+Vector2(-gap+30,-237),p+Vector2(gap-25,-229),p+Vector2(gap-20,243),p+Vector2(-gap+25,247)],Color("#e7e4db"),2,Color("#b3aaa4"))
		shape([p+Vector2(-35,-80),p+Vector2(20,-76),p+Vector2(gap-25,245),p+Vector2(-gap+25,247)],Color("#c1c6b5"),2,Color("#8c9680"))
		for i in range(3):
			var y:=p.y+35+i*60
			line([Vector2(p.x-gap*.55,y),Vector2(p.x+gap*.5,y+6)],Color("#f8f4e9"),5)
		if opened>.8:
			draw_set_transform(p+Vector2(0,-30),0,Vector2(.28,.28))
			draw_studio({},Vector2.ZERO)
			draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	# Curled fibres sit over the shadow and behind the untouched face of the page.
	shape([Vector2(p.x-gap-13,top+11),Vector2(p.x-gap+28,top+80),Vector2(p.x-gap-6,p.y-70),Vector2(p.x-gap+25,p.y+80),Vector2(p.x-gap-15,bottom),Vector2(p.x-gap-55,p.y+50),Vector2(p.x-gap-35,p.y-95)],Color("#eee7db"),3)
	shape([Vector2(p.x+gap+3,top+7),Vector2(p.x+gap+58,p.y-138),Vector2(p.x+gap+41,p.y+62),Vector2(p.x+gap+53,bottom-29),Vector2(p.x+gap-15,bottom+5),Vector2(p.x+gap+16,p.y+20),Vector2(p.x+gap-13,p.y-90)],PAPER,3)
	line([p+Vector2(gap+23,-193),p+Vector2(gap+40,-70),p+Vector2(gap+20,64)],SHADOW,3)
	action_label("A REAL WAY THROUGH" if opened>.8 else str(item.get("text","")),Vector2(p.x,p.y-355),opened>.8)
	var age:=event_age(str(item.id),"tear_open")
	if age>=0 and age<1.2:
		for i in range(5):
			var t:=clampf(age/1.2,0,1)
			var base:=p+Vector2(-95+i*49,-200+i*57)
			var q:=base+Vector2((i-2)*40*t,-60*sin(t*PI))
			line([q,q+Vector2(9,5)],Color("#c3afa5"),3)

func draw_eraser(item: Dictionary, p: Vector2) -> void:
	var amount:=progress(str(item.id),"erase_sweep")
	if amount==0: amount=progress(str(item.id),"eraser_pass")
	if item.get("erased",false): amount=1.0
	var erased:=260*amount
	var q:=p-Vector2(erased,0)
	# The swept strip exposes the space below the paper, with a pale cut edge.
	if amount>0:
		shape([q+Vector2(20,-15),p+Vector2(215,-15),p+Vector2(275,112),q+Vector2(-32,112)],Color("#66565f"),3)
		shape([q+Vector2(-32,112),p+Vector2(275,112),p+Vector2(279,118),q+Vector2(-30,118)],Color("#fffaf0"),3)
		line([q+Vector2(-30,120),p+Vector2(279,120)],Color("#c1b2aa"),4)
		for i in range(5):
			var edge:=q+Vector2(12+i*62,116)
			line([edge,edge+Vector2(6,7)],Color("#c4b6ad"),2)
	oval(q+Vector2(50,32),Vector2(192,24),Color("#d7cdc6"),0)
	shape([q+Vector2(-181,-114),q+Vector2(130,-139),q+Vector2(192,-53),q+Vector2(-125,-26)],Color("#dcb1b6"),5)
	shape([q+Vector2(-125,-26),q+Vector2(192,-53),q+Vector2(178,26),q+Vector2(-135,55)],Color("#bb7d8a"),5)
	shape([q+Vector2(-181,-114),q+Vector2(-125,-26),q+Vector2(-135,55),q+Vector2(-191,-36)],Color("#eee3d8"),5)
	line([q+Vector2(-129,-94),q+Vector2(111,-112)],Color("#efd3ce"),8)
	text_center("ERASER",q+Vector2(18,-53),35,220,Color("#855865"))
	var age:=event_age(str(item.id),"erase_sweep")
	if age>=0 and age<1.25:
		var t:=clampf(age/1.25,0,1)
		for i in range(8):
			var start:=q+Vector2(-170+i*13,15)
			var end:=start+Vector2(-46-i*9,35+i%3*12)
			var dust:=start.lerp(end,t)-Vector2(0,sin(t*PI)*(35+i%4*10))
			line([dust,dust+Vector2(8+i%3*2,-5)],Color("#aa8590"),4)
	elif amount>0:
		for i in range(5):
			var dust:=q+Vector2(-214-i*15,57+i%2*9)
			line([dust,dust+Vector2(10,-4)],Color("#b7a29d"),3)

func draw_shelf(p: Vector2) -> void:
	shape([p+Vector2(-225,20),p+Vector2(193,-6),p+Vector2(240,65),p+Vector2(-179,92)],Color("#ece4d6"),5)
	line([p+Vector2(-179,92),p+Vector2(-170,160)],SHADOW,6)
	line([p+Vector2(240,65),p+Vector2(250,127)],SHADOW,6)
	line([p+Vector2(-210,40),p+Vector2(210,12)],Color("#bfb0a4"),3)
	text_center("FOLD HERE",p+Vector2(0,42),32,300,Color("#998a89"))

func draw_tree(p: Vector2) -> void:
	line([p+Vector2(-18,200),p+Vector2(-24,-60),p+Vector2(-85,-155)],INK,6)
	line([p+Vector2(15,198),p+Vector2(26,-80),p+Vector2(77,-130)],INK,5)
	line([p+Vector2(-190,-80),p+Vector2(-215,-138),p+Vector2(-178,-203),p+Vector2(-105,-210),p+Vector2(-65,-270),p+Vector2(27,-281),p+Vector2(76,-227),p+Vector2(149,-228),p+Vector2(191,-171),p+Vector2(166,-94),p+Vector2(115,-84)],Color("#97a18b"),8)
	line([p+Vector2(-170,212),p+Vector2(161,212)],Color("#bdb0a1"),3)
	# The missing bottom of the canopy is an intentional unfinished drawing.
	line([p+Vector2(-160,-44),p+Vector2(-113,-65)],Color("#c6b8aa"),3)

func draw_pencil(p: Vector2) -> void:
	shape([p+Vector2(-290,-45),p+Vector2(255,-154),p+Vector2(272,-105),p+Vector2(-272,5)],Color("#d0b383"),5)
	shape([p+Vector2(255,-154),p+Vector2(350,-150),p+Vector2(272,-105)],Color("#e1ccaa"),4)
	shape([p+Vector2(328,-151),p+Vector2(350,-150),p+Vector2(331,-139)],INK,2)
	line([p+Vector2(-240,-27),p+Vector2(254,-127)],Color("#f4dfaa"),8)
	line([p+Vector2(-294,29),p+Vector2(320,-93)],SHADOW,6)

func draw_ruler(p: Vector2) -> void:
	# Held drawing-tool scale reference; its front edge rests on p.y.
	shape([p+Vector2(-330,-70),p+Vector2(250,-70),p+Vector2(290,0),p+Vector2(-350,0)],Color("#ded0ac"),5)
	shape([p+Vector2(-350,0),p+Vector2(290,0),p+Vector2(290,15),p+Vector2(-350,15)],Color("#baa38d"),4)
	for i in range(22):
		var x: float=-315+i*26
		var depth: float=37 if i%5==0 else 19
		line([p+Vector2(x,-64),p+Vector2(x+depth*.25,-64+depth)],Color("#88766c"),3)
	line([p+Vector2(-324,-9),p+Vector2(264,-9)],Color("#f4e9ce"),5)

func draw_ink_bottle(p: Vector2) -> void:
	# One closed bottle beside the unfinished ink, never another interaction.
	oval(p+Vector2(0,3),Vector2(74,13),SHADOW,0)
	shape([p+Vector2(-60,-195),p+Vector2(-32,-224),p+Vector2(-32,-245),p+Vector2(30,-245),p+Vector2(30,-224),p+Vector2(60,-195),p+Vector2(60,-11),p+Vector2(48,0),p+Vector2(-48,0),p+Vector2(-60,-11)],Color("#b8aaa8"),5)
	shape([p+Vector2(-51,-151),p+Vector2(51,-151),p+Vector2(51,-15),p+Vector2(-51,-15)],Color("#715762"),3)
	shape([p+Vector2(-39,-255),p+Vector2(38,-255),p+Vector2(38,-234),p+Vector2(-39,-234)],Color("#7d6c71"),4)
	line([p+Vector2(-36,-194),p+Vector2(-39,-164),p+Vector2(-39,-48)],Color("#eee4dc"),6)
	line([p+Vector2(-23,-245),p+Vector2(22,-245)],Color("#c7bab2"),3)

func draw_paper_stack(p: Vector2) -> void:
	# A few thick real pages establish the same material as the foldable flap.
	shape([p+Vector2(-180,-100),p+Vector2(200,-100),p+Vector2(200,0),p+Vector2(-180,0)],Color("#e7dac7"),5)
	shape([p+Vector2(-160,-160),p+Vector2(160,-160),p+Vector2(200,-100),p+Vector2(-180,-100)],Color("#f5edde"),5)
	for i in range(1,5):
		var y: float=-100+i*20
		line([p+Vector2(-178,y),p+Vector2(199,y)],Color("#bba99c"),3)
	line([p+Vector2(-142,-145),p+Vector2(138,-145),p+Vector2(164,-109)],Color("#fffaf0"),5)
	line([p+Vector2(-164,4),p+Vector2(194,4)],SHADOW,5)

func draw_paper_clip(p: Vector2) -> void:
	# A flat held wire loop on the stack. Its two ends are intentionally open.
	var wire: Array=[p+Vector2(-55,8),p+Vector2(27,-25),p+Vector2(45,-22),p+Vector2(57,-9),p+Vector2(52,2),p+Vector2(-28,33),p+Vector2(-43,29),p+Vector2(-48,17),p+Vector2(-40,7),p+Vector2(24,-17),p+Vector2(34,-13),p+Vector2(34,-5),p+Vector2(-23,17)]
	line(wire,Color("#796b6d"),8)
	line(wire,Color("#bdb6ad"),3)

func draw_bridge(item: Dictionary, p: Vector2) -> void:
	var fall:=progress(str(item.id),"bridge_break")*(1.0-progress(str(item.id),"rewind"))
	shape([p+Vector2(-390,-60),p+Vector2(450,-60),p+Vector2(480,260),p+Vector2(-420,260)],Color("#6e626b"),4)
	# A separate page bank shows where the missing span would have ended.
	# It is not a far bridge support or a filled-in crossing.
	shape([p+Vector2(310,-60),p+Vector2(420,-60),p+Vector2(450,85),p+Vector2(290,85)],Color("#eee6d9"),5)
	shape([p+Vector2(290,85),p+Vector2(450,85),p+Vector2(450,116),p+Vector2(290,116)],Color("#cbbbad"),4)
	line([p+Vector2(300,95),p+Vector2(446,95)],Color("#fffaf0"),5)
	# Only the near half was drawn. A broad deck and paired tall rails make
	# that unfinished structure visible without lifting the y905 sole plane.
	var drop:=fall*142
	line([p+Vector2(-330,-60+drop),p+Vector2(-320,-260+drop),p+Vector2(-60,-260+drop),p+Vector2(-70,-60+drop)],INK,7)
	line([p+Vector2(-190,-60+drop),p+Vector2(-190,-260+drop)],INK,5)
	shape([p+Vector2(-330,-60+drop),p+Vector2(-70,-60+drop),p+Vector2(-30,85+drop),p+Vector2(-370,85+drop)],Color("#e2d2ba"),6)
	shape([p+Vector2(-370,85+drop),p+Vector2(-30,85+drop),p+Vector2(-30,115+drop),p+Vector2(-370,115+drop)],Color("#baa28f"),5)
	for i in range(1,5):
		var back_x: float=lerpf(-330,-70,float(i)/5)
		var front_x: float=lerpf(-370,-30,float(i)/5)
		line([p+Vector2(back_x,-58+drop),p+Vector2(front_x,84+drop)],Color("#9b7f7c"),4)
	line([p+Vector2(-360,85+drop),p+Vector2(-345,-170+drop),p+Vector2(-32,-170+drop),p+Vector2(-40,85+drop)],INK,7)
	line([p+Vector2(-208,-170+drop),p+Vector2(-208,85+drop)],INK,5)
	# Broken edge and dashed future pencil guide never imply a finished bridge.
	line([p+Vector2(-36,12+drop),p+Vector2(-23,35+drop),p+Vector2(-35,58+drop),p+Vector2(-25,83+drop)],ROSE,6)
	for i in range(4): line([p+Vector2(10+i*65,-54),p+Vector2(40+i*65,-54)],Color("#bfada8"),3)
	action_label("NO SUPPORT." if fall>.8 else str(item.get("text","")),p+Vector2(0,-350))
	var age:=event_age(str(item.id),"rewind")
	if age>=0 and age<1.1: text_center("BACK IT UP",p+Vector2(0,-145),38,440,ROSE)

func paper_face(p: Vector2, folded: float) -> Array:
	# The front hinge stays on y905 for the episode's p.y837 throughout.
	var hinge:=p+Vector2(-260,68)
	var theta:=lerpf(-PI*.5,0.0,clampf(folded,0,1))
	var free:=hinge+Vector2(cos(theta),sin(theta))*560.0
	var transverse:=Vector2(220.0*(1.0-folded),-160.0*folded)
	return [hinge,hinge+transverse,free+transverse,free]

func paper_polygon_has_area(points: Array) -> bool:
	var twice_area:=0.0
	for i in range(points.size()):
		var a: Vector2=points[i]
		var b: Vector2=points[(i+1)%points.size()]
		twice_area+=a.x*b.y-b.x*a.y
	return absf(twice_area)>=560.0

func paper_shape(points: Array, fill: Color, width: float=4.0) -> void:
	# A turning sheet changes face orientation through one edge-on instant.
	# That instant is an authored visible edge, never an invalid filled polygon.
	if paper_polygon_has_area(points) and not Geometry2D.triangulate_polygon(PackedVector2Array(points)).is_empty():
		shape(points,fill,width)
	else:
		var edge:=points.duplicate()
		edge.append(points[0])
		line(edge,INK,width)

func draw_tab(item: Dictionary, p: Vector2) -> void:
	var folded:=progress(str(item.id),"tab_fold")
	if item.get("folded",false): folded=1.0
	shape([p+Vector2(-290,-92),p+Vector2(380,-92),p+Vector2(410,227),p+Vector2(-320,227)],Color("#6e626b"),4)
	# Supported bank edges are held; only the broad sheet face folds.
	shape([p+Vector2(-380,-92),p+Vector2(-260,-92),p+Vector2(-260,68),p+Vector2(-390,68)],Color("#e9dece"),4)
	shape([p+Vector2(300,-92),p+Vector2(380,-92),p+Vector2(405,68),p+Vector2(300,68)],Color("#e9dece"),4)
	var face:=paper_face(p,folded)
	var hinge: Vector2=face[0]
	var free: Vector2=face[3]
	var transverse: Vector2=face[1]-face[0]
	# Paper thickness is below the front edge; feet retain the exact y905.
	var thickness:=Vector2(12.0*(1.0-folded),30.0*folded)
	paper_shape([hinge,free,free+thickness,hinge+thickness],Color("#c9b79e"),4)
	paper_shape([free,face[2],face[2]+Vector2(10,19),free+Vector2(10,19)],Color("#d8c7ab"),4)
	var length_axis: Vector2=(free-hinge).normalized()
	var depth_axis:=transverse.normalized()
	paper_shape([hinge,face[1],face[2]-length_axis*18,face[2]-length_axis*6-depth_axis*14,face[2]-depth_axis*25,free],Color("#f1e6cf"),6)
	line([hinge.lerp(free,.12),hinge.lerp(free,.12)+transverse],Color("#a18a7d"),5)
	line([hinge.lerp(free,.135),hinge.lerp(free,.135)+transverse*.94],Color("#fffaf0"),4)
	# One torn corner and a few fibres identify a sheet, not wooden planks.
	var torn: Vector2=free.lerp(face[2],.76)
	line([torn,torn+Vector2(7,-8),torn+transverse*.11+Vector2(-3,3),face[2]],Color("#a58e82"),3)
	line([face[2].lerp(hinge+transverse,.22),face[2].lerp(hinge+transverse,.22)+Vector2(13,3)],Color("#d0bca1"),3)
	line([face[2].lerp(hinge+transverse,.29),face[2].lerp(hinge+transverse,.29)+Vector2(9,-2)],Color("#d0bca1"),3)
	if folded>.8:
		line([hinge+Vector2(-12,34),hinge+Vector2(32,34)],SHADOW,5)
		line([free+Vector2(-26,34),free+Vector2(23,34)],SHADOW,5)
	action_label("THE PAPER HOLDS" if folded>.8 else str(item.get("text","")),p+Vector2(0,-560),folded>.8)

func draw_edge(p: Vector2) -> void:
	shape([p+Vector2(-250,50),p+Vector2(247,47),p+Vector2(315,215),p+Vector2(-290,215)],Color("#75666f"),4)
	shape([p+Vector2(-250,39),p+Vector2(-40,41),p+Vector2(0,119),p+Vector2(-270,122)],Color("#f0e6d7"),4)
	line([p+Vector2(-270,123),p+Vector2(1,120)],PAPER,8)
	for i in range(3): line([p+Vector2(-230+i*67,49),p+Vector2(-198+i*67,90)],SHADOW,3)

func draw_erased_ink_strip(item: Dictionary, p: Vector2) -> void:
	# This is the missing drawn road behind one solid eraser, not torn paper.
	# The named path/action owns its finite advance; direct seeks reconstruct
	# the same completed straight edge without a particle loop or saved state.
	if not item.has("path") or clock<float(item.path[0].at): return
	var first:=Vector2(item.path[0].position[0],item.path[0].position[1])
	if absf(p.x-first.x)<.5: return
	var direction:=signf(p.x-first.x)
	var start_edge:=first.x-210.0*direction
	var current_edge:=p.x-210.0*direction
	var left:=minf(start_edge,current_edge)
	var right:=maxf(start_edge,current_edge)
	var surface:=first.y-20.0
	shape([Vector2(left,surface),Vector2(right,surface),Vector2(right+32,surface+110),Vector2(left-32,surface+110)],Color("#66565f"),3)
	# A clean pale page edge distinguishes rubbed-out ink from ripping fibres.
	line([Vector2(left-32,surface+112),Vector2(right+32,surface+112)],PAPER,7)
	line([Vector2(left-32,surface+118),Vector2(right+32,surface+118)],Color("#b9a89e"),3)

func draw_ride_eraser(item: Dictionary, base: Vector2) -> void:
	var p: Vector2=Motion.point(item.path,clock) if item.has("path") else base
	if item.get("erasing",false): draw_erased_ink_strip(item,p)
	oval(p+Vector2(8,95),Vector2(224,22),SHADOW,0)
	# The front edge is level: rider soles share this exact supported y plane.
	shape([p+Vector2(-210,-20),p+Vector2(210,-20),p+Vector2(251,-90),p+Vector2(-170,-90)],Color("#dfb2b8"),5)
	shape([p+Vector2(-210,-20),p+Vector2(210,-20),p+Vector2(210,83),p+Vector2(-210,83)],Color("#bd7f8f"),5)
	shape([p+Vector2(210,-20),p+Vector2(251,-90),p+Vector2(251,10),p+Vector2(210,83)],Color("#a96b7e"),5)
	line([p+Vector2(-145,-65),p+Vector2(191,-65)],Color("#f5d2cf"),8)
	text_center("ERASER",p+Vector2(0,48),36,300,Color("#704957"))
	if not str(item.get("text","")).is_empty(): action_label(str(item.text),base+Vector2(0,-600))
	if item.has("path") and clock>=float(item.path[0].at) and clock<float(item.path[-1].at):
		for i in range(3): line([p+Vector2(-290-i*32,8+i*20),p+Vector2(-247-i*32,8+i*20)],ROSE,4)

func draw_studio(item: Dictionary, p: Vector2) -> void:
	# A recognizable desk/chair/window arrangement, not a location label.
	shape([p+Vector2(-275,-118),p+Vector2(247,-118),p+Vector2(300,-57),p+Vector2(-300,-57)],Color("#dfcdbb"),5)
	shape([p+Vector2(-300,-57),p+Vector2(300,-57),p+Vector2(300,-25),p+Vector2(-300,-25)],Color("#c3a793"),5)
	line([p+Vector2(-255,-24),p+Vector2(-255,145)],INK,9)
	line([p+Vector2(255,-24),p+Vector2(255,145)],INK,9)
	shape([p+Vector2(-188,-116),p+Vector2(24,-116),p+Vector2(52,-72),p+Vector2(-202,-72)],PAPER,3)
	line([p+Vector2(-81,-114),p+Vector2(-76,-73)],Color("#a88a93"),3)
	# Open book contains a miniature, explicitly flat door — the final callback.
	shape([p+Vector2(-154,-106),p+Vector2(-105,-106),p+Vector2(-99,-80),p+Vector2(-162,-80)],Color("#eee5d6"),2)
	draw_circle(p+Vector2(-111,-86),2,INK)
	line([p+Vector2(125,-120),p+Vector2(125,-255),p+Vector2(206,-300)],INK,7)
	shape([p+Vector2(161,-331),p+Vector2(237,-298),p+Vector2(172,-265)],Color("#c0c6b3"),4)
	oval(p+Vector2(125,-119),Vector2(42,9),Color("#b4a096"),3)
	shape([p+Vector2(40,-11),p+Vector2(160,-11),p+Vector2(160,67),p+Vector2(40,67)],Color("#c2c9b6"),5)
	line([p+Vector2(66,65),p+Vector2(48,144)],INK,6)
	line([p+Vector2(139,65),p+Vector2(156,144)],INK,6)
	if location=="studio":
		shape([p+Vector2(-245,-460),p+Vector2(14,-460),p+Vector2(14,-246),p+Vector2(-245,-246)],Color("#e2e7e4"),4)
		line([p+Vector2(-116,-455),p+Vector2(-116,-251)],Color("#b0b8ae"),4)
		line([p+Vector2(-240,-350),p+Vector2(8,-350)],Color("#b0b8ae"),4)
		if progress(str(item.get("id","")),"escape_reveal")>.8: text_center("A BORING, SOLID DESK.",p+Vector2(0,210),35,650,SAGE)

func draw_orientation() -> void:
	if entry_card.is_empty() or clock<scene_start or clock>=scene_start+float(entry_card.get("duration",3)):return
	var delta: int=(focus_wall-wall_index+4)%4
	var instruction: String=["HERE","TURN RIGHT →","TURN AROUND","← TURN LEFT"][delta]
	# Face-canvas y77 lies above the normal 90-degree rectilinear viewport.
	# Keep the brief direction receipt inside the view and above Nemi's hair.
	notice_panel(str(entry_card.get("title",""))+" · "+instruction,Vector2(960,330),ROSE)

func _draw() -> void:
	draw_rect(Rect2(0,0,1920,1080),PAPER)
	draw_rect(Rect2(0,905,1920,175),Color("#ece6db"))
	line([Vector2(0,905),Vector2(1920,905)],Color("#b9a89e"),3)
	line([Vector2(0,1017),Vector2(1920,1017)],Color("#d2c5b6"),3)
	for i in range(7):
		line([Vector2(i*320-100,905),Vector2(i*420-400,1080)],Color("#d2c5b6"),3)
	if wall_index==0:
		if location=="sketchbook": text_center("VOICE + STORYBOARD AUDITION",Vector2(960,48),24,700,Color("#a28f90"))
		if clock<24:
			text_center("CLICK + DRAG TO LOOK",Vector2(960,175),34,800,Color("#826a75"))
			text_center("ON PHONE: SWIPE THE PICTURE",Vector2(960,218),29,900,Color("#826a75"))
			if location!="sketchbook": text_center("PHONE CHOICES: MATCHING NUMBERED CHAPTER",Vector2(960,262),25,1100,Color("#826a75"))
	else:
		# Held landscape fragments establish an unfinished physical sketchbook.
		line([Vector2(30,735),Vector2(150,716),Vector2(280,735),Vector2(340,707)],Color("#cec3b3"),3)
		line([Vector2(1660,736),Vector2(1760,716),Vector2(1900,735)],Color("#cec3b3"),3)
	for item in objects:
		if not object_visible(item): continue
		var p:=Vector2(float(item.x),float(item.y))
		match str(item.kind):
			"sketch_door": draw_door(item,p)
			"page_tear": draw_tear(item,p)
			"eraser": draw_eraser(item,p)
			"paper_shelf": draw_shelf(p)
			"sketch_tree": draw_tree(p)
			"pencil": draw_pencil(p)
			"ruler": draw_ruler(p)
			"ink_bottle": draw_ink_bottle(p)
			"paper_stack": draw_paper_stack(p)
			"paper_clip": draw_paper_clip(p)
			"sketch_bridge": draw_bridge(item,p)
			"paper_tab": draw_tab(item,p)
			"page_edge": draw_edge(p)
			"ride_eraser": draw_ride_eraser(item,p)
			"studio_desk": draw_studio(item,p)
			"paper_exit":
				if item.has("visible_from_event"):
					notice_panel(str(item.get("text","")),p)
				else:
					text_center(str(item.get("text","")),p,44,800,INK)
					if wall_index!=0: line([p+Vector2(-170,28),p+Vector2(170,28)],ROSE,3)
			"binder_ring":
				for i in range(3):
					var q:=p+Vector2(i*350,0)
					oval(q+Vector2(5,75),Vector2(110,25),SHADOW,0)
					draw_arc(q,112,-2.8,.15,64,Color("#b9b5ae"),28,true)
					draw_arc(q,112,-2.8,.15,64,INK,4,true)
					draw_circle(q+Vector2(-106,-37),17,Color("#b3a5a0"))
			_:
				push_error("Unsupported drawing-world object: "+str(item.kind))
	draw_orientation()
