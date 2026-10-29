extends Node2D
## Episode data supplies layout; this renderer supplies readable school objects.
var objects: Array=[]
var events: Array=[]
var location := "hallway"
var scene_start := 0.0
var clock := 0.0
var wall_index := 0
var entry_card: Dictionary={}
var font := ThemeDB.fallback_font
const INK=Color("#553b47")
const PAPER=Color("#faf7f1")
const WASH=Color("#e9e2d8")

func sample(time: float) -> void:
	clock=time
	queue_redraw()

func rect(box: Rect2, fill: Color, stroke: float=4.0) -> void:
	draw_rect(box,fill)
	draw_rect(box,INK,false,stroke,true)

func label_at(text: String, point: Vector2, size: int=44, color: Color=INK) -> void:
	var lines:=text.split("\n")
	for index in range(lines.size()):
		draw_string(font,point+Vector2(0,index*(size+8)),lines[index],HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func clue_label(text: String, point: Vector2) -> void:
	var lines:=text.split("\n")
	for index in range(lines.size()):
		var size:=64
		var measured:=font.get_string_size(lines[index],HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
		if measured>440.0: size=int(floor(64.0*440.0/measured))
		draw_string(font,point+Vector2(0,index*76),lines[index],HORIZONTAL_ALIGNMENT_LEFT,-1,size,INK)

func fitted_object_label(text: String, point: Vector2, preferred_size: int, width: float) -> void:
	for index in range(text.split("\n").size()):
		var line: String=text.split("\n")[index]
		var size:=preferred_size
		var measured:=font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
		if measured>width: size=maxi(28,int(floor(preferred_size*width/measured)))
		draw_string(font,point+Vector2(0,index*(preferred_size+8)),line,HORIZONTAL_ALIGNMENT_LEFT,-1,size,INK)

func entry_card_active() -> bool:
	return not entry_card.is_empty() and clock>=scene_start and clock<scene_start+float(entry_card.get("duration",0.0))

func card_line(text: String, baseline: float, size: int, color: Color=INK) -> void:
	# Completed result lettering remains still throughout the brief entry hold.
	var measured:=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	var fitted_size:=size
	if measured>1260.0: fitted_size=maxi(24,int(floor(size*1260.0/measured)))
	draw_string(font,Vector2(330,baseline),text,HORIZONTAL_ALIGNMENT_CENTER,1260,fitted_size,color)

func draw_entry_card() -> void:
	if not entry_card_active(): return
	if wall_index==0:
		# A compact receipt leaves the performer visible from the first word.
		rect(Rect2(980,240,690,230),PAPER,5.0)
		draw_line(Vector2(1000,262),Vector2(1648,262),Color("#ad5e69"),5,true)
		fitted_object_label(str(entry_card.get("title","")),Vector2(1005,318),48,638)
		fitted_object_label(str(entry_card.get("subtitle","")),Vector2(1005,378),34,638)
		label_at("NEMI IS HERE",Vector2(1005,438),30,Color("#6e8b74"))
		return
	# Large peripheral receipts preserve feedback when the viewer is facing away.
	rect(Rect2(270,318,1380,396),PAPER,7.0)
	draw_line(Vector2(340,349),Vector2(1580,349),Color("#ad5e69"),7,true)
	card_line(str(entry_card.get("title","")),438,72)
	card_line(str(entry_card.get("subtitle","")),520,44)
	var orientation: String=["NEMI IS HERE","TURN LEFT TO NEMI","TURN AROUND TO NEMI","TURN RIGHT TO NEMI"][wall_index]
	card_line(orientation,636,50,Color("#6e8b74"))

func oval(center: Vector2, radius: Vector2, color: Color, width: float=4.0) -> void:
	var points:=PackedVector2Array()
	for index in range(49):
		var angle:=TAU*index/48.0
		points.append(center+Vector2(cos(angle)*radius.x,sin(angle)*radius.y))
	draw_colored_polygon(points,color)
	draw_polyline(points,INK,width,true)

func badge_star(center: Vector2) -> void:
	# A held, deliberately uneven star belongs to the badge artwork.
	var points:=PackedVector2Array([
		center+Vector2(-2,-57),center+Vector2(17,-19),center+Vector2(59,-14),
		center+Vector2(29,14),center+Vector2(37,57),center+Vector2(0,36),
		center+Vector2(-39,58),center+Vector2(-31,15),center+Vector2(-61,-13),
		center+Vector2(-20,-19),center+Vector2(-2,-57)])
	draw_colored_polygon(points,Color("#d7b675"))
	draw_polyline(points,INK,5,true)

func toy(kind: String, p: Vector2) -> void:
	var fill:=Color("#dcc8ae") if kind=="bear" else Color("#efe8dc")
	if kind=="duck":
		fill=Color("#ead399")
		oval(p+Vector2(0,35),Vector2(95,70),fill)
		oval(p+Vector2(50,-45),Vector2(59,60),fill)
		var beak:=PackedVector2Array([p+Vector2(99,-39),p+Vector2(148,-22),p+Vector2(98,-9),p+Vector2(99,-39)])
		draw_colored_polygon(beak,Color("#c89978"));draw_polyline(beak,INK,4,true)
		oval(p+Vector2(-20,40),Vector2(48,30),Color("#e2c786"),3)
		draw_circle(p+Vector2(64,-56),6,INK)
		return
	if kind=="bear":
		oval(p+Vector2(-51,-85),Vector2(28,29),fill)
		oval(p+Vector2(51,-85),Vector2(28,29),fill)
	else:
		oval(p+Vector2(-37,-126),Vector2(24,72),fill)
		oval(p+Vector2(37,-126),Vector2(24,72),fill)
		oval(p+Vector2(-37,-128),Vector2(11,49),Color("#ddbdbe"),2)
		oval(p+Vector2(37,-128),Vector2(11,49),Color("#ddbdbe"),2)
	oval(p+Vector2(0,45),Vector2(77,91),fill)
	oval(p+Vector2(-72,42),Vector2(26,48),fill)
	oval(p+Vector2(72,42),Vector2(26,48),fill)
	oval(p+Vector2(-42,120),Vector2(37,25),fill)
	oval(p+Vector2(42,120),Vector2(37,25),fill)
	oval(p+Vector2(0,-39),Vector2(73,67),fill)
	oval(p+Vector2(0,-11),Vector2(35,24),Color("#f4e8d9"),3)
	draw_circle(p+Vector2(-25,-49),6,INK)
	draw_circle(p+Vector2(25,-49),6,INK)
	draw_circle(p+Vector2(0,-20),7,INK)
	draw_line(p+Vector2(0,-12),p+Vector2(0,-2),INK,3,true)
	draw_line(p+Vector2(0,17),p+Vector2(0,85),Color("#ad9494"),2,true)

func _draw() -> void:
	draw_rect(Rect2(0,0,1920,1080),PAPER)
	draw_rect(Rect2(0,850,1920,230),WASH)
	draw_line(Vector2(0,850),Vector2(1920,850),Color("#b9aaa8"),4,true)
	draw_line(Vector2(0,1015),Vector2(1920,1015),Color("#d5cbc1"),3,true)
	for item in objects:
		var p:=Vector2(float(item.x),float(item.y))
		var tick:=0.0
		var pulse:=0.0
		var flap:=0.0
		for event in events:
			if str(event.object)!=str(item.id) or clock<float(event.at): continue
			var progress:=clampf((clock-float(event.at))/(float(event.end)-float(event.at)),0.0,1.0)
			if event.kind=="clock_tick": tick+=smoothstep(0.0,1.0,progress)*deg_to_rad(6.0)
			elif progress<1.0 and event.kind=="speaker_pulse": pulse=sin(progress*PI)
			elif progress<1.0 and event.kind=="paper_flap": flap=sin(progress*TAU)*sin(progress*PI)*0.035
		if not is_zero_approx(flap):
			draw_set_transform(p,flap,Vector2.ONE)
			p=Vector2.ZERO
		var text: String=item.get("text","")
		var accent:=Color(item.get("accent","#d7d9d3"))
		match item.kind:
			"locker":
				rect(Rect2(p.x-95,p.y-250,190,500),accent)
				for y in [-205,-185,-165]: draw_line(p+Vector2(-55,y),p+Vector2(55,y),INK,3,true)
				draw_line(p+Vector2(64,-10),p+Vector2(64,34),INK,7,true)
				if not text.is_empty(): label_at(text,p+Vector2(-64,-90),40)
			"door":
				rect(Rect2(p.x-150,p.y-300,300,600),Color("#e6d6c6"),6)
				rect(Rect2(p.x-105,p.y-240,210,180),Color("#f4f0e7"),4)
				draw_circle(p+Vector2(112,44),10,INK)
				label_at(text,p+Vector2(-110,-160),32)
			"board":
				rect(Rect2(p.x-310,p.y-175,620,350),Color("#dce0d6"),8)
				fitted_object_label(text,p+Vector2(-270,-95),52,540.0)
				if item.get("crossed",false):
					draw_line(p+Vector2(-290,-145),p+Vector2(290,135),Color("#aa4f61"),12,true)
					draw_line(p+Vector2(-285,126),p+Vector2(288,-138),Color("#aa4f61"),10,true)
			"bench":
				rect(Rect2(p.x-220,p.y-65,440,42),Color("#d6beab"))
				draw_line(p+Vector2(-185,-20),p+Vector2(-185,110),INK,9,true)
				draw_line(p+Vector2(185,-20),p+Vector2(185,110),INK,9,true)
			"poster":
				rect(Rect2(p.x-155,p.y-165,310,330),Color("#fffaf0"),3)
				draw_line(p+Vector2(-130,-180),p+Vector2(-95,-145),Color("#bdac91"),22,true)
				label_at(text,p+Vector2(-130,-95),33)
			"clock":
				draw_circle(p,100,PAPER)
				draw_arc(p,100,0,TAU,96,INK,5,true)
				for i in range(12):
					var a:=i*TAU/12.0
					draw_line(p+Vector2(sin(a),-cos(a))*82,p+Vector2(sin(a),-cos(a))*92,INK,3,true)
				draw_line(p,p+Vector2(sin(tick),-cos(tick))*62,INK,6,true)
				draw_line(p,p+Vector2(44,12),INK,8,true)
			"clue":
				rect(Rect2(p.x-250,p.y-145,500,290),Color("#f5e4b3"),5)
				clue_label(text,p+Vector2(-220,-65))
				if text.begins_with("TODAY\n"):
					badge_star(p+Vector2(170,-80))
			"badge":
				draw_polyline(PackedVector2Array([p+Vector2(-65,-130),p+Vector2(-80,-215),p+Vector2(62,-215),p+Vector2(65,-130)]),Color("#a56b78"),12,true)
				rect(Rect2(p.x-150,p.y-130,300,260),Color("#f3e3b9"),6)
				if text.begins_with("STAR\n"):
					badge_star(p+Vector2(0,-43))
					fitted_object_label(text.trim_prefix("STAR\n"),p+Vector2(-130,92),52,260.0)
				else:
					# Badge lettering owns the pass width, not the larger clue-card width.
					fitted_object_label(text,p+Vector2(-130,-35),56,260.0)
			"form":
				# Held paper is deliberately uneven and stays fixed after authoring.
				var sheet:=PackedVector2Array([p+Vector2(-274,-174),p+Vector2(274,-166),p+Vector2(268,160),p+Vector2(-280,156),p+Vector2(-274,-174)])
				draw_colored_polygon(sheet,Color("#fffaf0"))
				draw_polyline(sheet,INK,5,true)
				draw_line(p+Vector2(-244,-146),p+Vector2(-248,132),Color("#d1a5a8"),3,true)
				draw_line(p+Vector2(-222,-56),p+Vector2(238,-56),Color("#baa8a6"),3,true)
				fitted_object_label(text,p+Vector2(-221,-109),44,458.0)
				rect(Rect2(p.x-220,p.y+74,28,28),PAPER,3)
				draw_polyline(PackedVector2Array([p+Vector2(-215,86),p+Vector2(-207,96),p+Vector2(-190,71)]),Color("#95606e"),5,true)
				draw_line(p+Vector2(-169,97),p+Vector2(188,97),INK,2,true)
				draw_polyline(PackedVector2Array([p+Vector2(-157,87),p+Vector2(-137,73),p+Vector2(-127,88),p+Vector2(-104,76),p+Vector2(-83,89),p+Vector2(-51,78),p+Vector2(-25,91)]),Color("#95606e"),3,true)
			"pencil_cup":
				# Every pencil is authored once. The opaque cup hides their lower shafts.
				var tips: Array[Vector2]=[Vector2(-76,-174),Vector2(-39,-225),Vector2(5,-192),Vector2(47,-214),Vector2(86,-157)]
				var pencil_washes: Array[Color]=[Color("#c9ad7f"),Color("#b99499"),Color("#a9b5a0"),Color("#c7b387"),Color("#b5a5b6")]
				for pencil_index in range(tips.size()):
					var tip: Vector2=p+tips[pencil_index]
					var base: Vector2=p+Vector2(tips[pencil_index].x*0.55,70)
					var axis: Vector2=(base-tip).normalized()
					var side:=Vector2(-axis.y,axis.x)*7.0
					var wood: Vector2=tip+axis*23.0
					var shaft:=PackedVector2Array([wood-side,wood+side,base+side,base-side,wood-side])
					draw_colored_polygon(shaft,pencil_washes[pencil_index])
					draw_polyline(shaft,INK,2.5,true)
					var point:=PackedVector2Array([tip,wood-side,wood+side,tip])
					draw_colored_polygon(point,Color("#dfc6a7"))
					draw_polyline(point,INK,2.5,true)
					draw_line(tip,tip+axis*7.0,INK,4,true)
				oval(p+Vector2(92,51),Vector2(45,48),PAPER,5)
				var cup:=PackedVector2Array([p+Vector2(-91,-19),p+Vector2(92,-18),p+Vector2(76,115),p+Vector2(-76,115),p+Vector2(-91,-19)])
				draw_colored_polygon(cup,Color("#e6cdd0"))
				draw_polyline(cup,INK,5,true)
				oval(p+Vector2(0,-20),Vector2(91,17),Color("#c8b3b6"),4)
				# Redraw the exposed pencils across the rim; their ends remain hidden.
				for pencil_index in range(tips.size()):
					var tip: Vector2=p+tips[pencil_index]
					var base: Vector2=p+Vector2(tips[pencil_index].x*0.55,70)
					var rim_point: Vector2=tip.lerp(base,(-30.0-tips[pencil_index].y)/(70.0-tips[pencil_index].y))
					draw_line(rim_point+Vector2(0,-12),rim_point+Vector2(0,9),pencil_washes[pencil_index],10,true)
				if not text.is_empty(): fitted_object_label(text,p+Vector2(-64,53),30,132.0)
			"sandwich":
				var bread:=PackedVector2Array([p+Vector2(-125,65),p+Vector2(110,65),p+Vector2(-100,-100),p+Vector2(-125,65)])
				draw_colored_polygon(bread,Color("#eed9ac"));draw_polyline(bread,INK,5,true)
				draw_line(p+Vector2(-122,49),p+Vector2(84,49),Color("#8b9b76"),15,true)
				draw_line(p+Vector2(-118,67),p+Vector2(107,67),Color("#bd8a7d"),12,true)
				draw_line(p+Vector2(-118,82),p+Vector2(107,82),INK,4,true)
				fitted_object_label(text,p+Vector2(-150,135),32,300.0)
			"duck", "bear", "rabbit":
				toy(item.kind,p)
			"microphone":
				draw_line(p+Vector2(0,-150),p+Vector2(0,130),INK,10,true)
				draw_line(p+Vector2(0,130),p+Vector2(-85,165),INK,8,true)
				draw_line(p+Vector2(0,130),p+Vector2(85,165),INK,8,true)
				oval(p+Vector2(0,-205),Vector2(35,65),Color("#9f9497"),5)
				for y in [-235,-215,-195,-175]: draw_line(p+Vector2(-25,y),p+Vector2(25,y),Color("#69555f"),3,true)
				draw_polyline(PackedVector2Array([p+Vector2(8,-142),p+Vector2(16,120),p+Vector2(130,170),p+Vector2(190,164)]),INK,4,true)
			"trophy":
				draw_colored_polygon(PackedVector2Array([p+Vector2(-65,-100),p+Vector2(65,-100),p+Vector2(45,-5),p+Vector2(-45,-5)]),Color("#d8bd7b"))
				draw_polyline(PackedVector2Array([p+Vector2(-65,-100),p+Vector2(65,-100),p+Vector2(45,-5),p+Vector2(-45,-5),p+Vector2(-65,-100)]),INK,5,true)
				draw_line(p+Vector2(0,0),p+Vector2(0,60),INK,10,true)
				rect(Rect2(p.x-75,p.y+55,150,35),Color("#d1b6a0"))
				label_at(text,p+Vector2(-120,140),30)
			"speaker":
				rect(Rect2(p.x-100,p.y-160,200,320),Color("#a79c9b"),6)
				draw_arc(p+Vector2(0,30),62,0,TAU,48,INK,6,true)
				draw_arc(p+Vector2(0,-94),30,0,TAU,32,INK,4,true)
				if pulse>0:
					draw_arc(p+Vector2(0,30),76+pulse*38,-0.7,0.7,24,Color(0.45,0.31,0.36,pulse),6,true)
					draw_arc(p+Vector2(0,30),76+pulse*38,PI-0.7,PI+0.7,24,Color(0.45,0.31,0.36,pulse),6,true)
			_:
				push_error("Unsupported school object: "+str(item.kind))
		draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	draw_entry_card()
