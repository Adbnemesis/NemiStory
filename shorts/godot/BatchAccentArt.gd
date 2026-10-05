extends Node2D
## Authored event drawings. Completed marks stay fixed; entry motion has a finite span.
var frame := 0
var events: Array = []
var ink := Color("#343039")
var accent := Color("#9a849f")
var theme := "sound"
var stage := "plain"
var dark := false
var foreground := false

func poly(points: Array, color: Color, width := 2.0) -> void:
	var pts = PackedVector2Array()
	for p in points: pts.append(Vector2(p[0],p[1]))
	draw_polyline(pts,color,width,true)

func star(p: Vector2, r: float, color: Color) -> void:
	var pts = PackedVector2Array()
	for i in range(9):
		var a = i*PI/4-PI/2
		pts.append(p+Vector2(cos(a),sin(a))*r*(1.0 if i%2==0 else .24))
	draw_polyline(pts,color,2.8,true)

func _draw() -> void:
	# Sparse stage drawings stay behind characters, selected for each edit's thought.
	if not foreground and stage == "door":
		poly([[666,322],[971,322],[971,1390],[666,1390],[666,322]],ink,2.8)
		poly([[689,351],[933,381],[933,1384]],ink,1.3)
		draw_line(Vector2(540,1392),Vector2(1020,1392),ink,1.5,true)
		draw_circle(Vector2(911,892),7,ink)
		draw_rect(Rect2(748,430,151,75),ink,false,2)
		draw_string(ThemeDB.fallback_font,Vector2(770,480),"LAB 3",HORIZONTAL_ALIGNMENT_LEFT,-1,30,ink)
	elif not foreground and stage == "columns":
		draw_line(Vector2(540,252),Vector2(540,1366),Color(ink,.24),2,true)
		poly([[80,1390],[1010,1390]],Color(ink,.34),1.3)
	elif not foreground and stage == "page":
		poly([[86,289],[992,245],[1012,1363],[100,1416],[86,289]],Color(ink,.38),1.7)
		for y in [320,380,440,500,560,620,680,740,800,860,920,980,1040,1100,1160,1220,1280,1340]:
			draw_line(Vector2(77,y),Vector2(110,y-3),ink,2.2,true)
	elif not foreground and stage == "viewfinder":
		for x in [155,925]:
			var dx = 1 if x == 155 else -1
			poly([[x,445],[x,340],[x+dx*106,340]],ink,3.0)
			poly([[x,1215],[x,1320],[x+dx*106,1320]],ink,3.0)
	elif not foreground and stage == "runway":
		for x in [82,998]: draw_line(Vector2(x,260),Vector2(x,1390),Color(ink,.28),1.4,true)
		poly([[140,1360],[540,1210],[940,1360]],Color(ink,.24),1.7)
	for ev in events:
		if foreground != (ev.kind in ["pencil","flash"]): continue
		if frame < int(ev.at) or frame >= int(ev.end): continue
		var age = frame-int(ev.at)
		var p = Vector2(ev.position[0],ev.position[1])
		var size = float(ev.get("scale",1))
		if ev.kind == "pencil": p.x += lerpf(-1600,1600,float(age)/maxf(1,float(ev.end-ev.at-1)))
		# A four-frame, deterministic entry. Every completed mark then stays exactly still.
		var entry = 1.0-.16*pow(1-clampf(float(age)/4,0,1),3)
		draw_set_transform(p,deg_to_rad(float(ev.get("rotation",0))),Vector2.ONE*size*entry)
		var c = accent if ev.get("accent",true) else ink
		match ev.kind:
			"stars":
				star(Vector2.ZERO,56,c); star(Vector2(82,57),25,c);star(Vector2(-55,74),16,c)
			"arcs":
				for r in [42,64,88]: draw_arc(Vector2.ZERO,r,-.72,.72,28,c,2.5,true)
			"notes":
				draw_circle(Vector2(-13,37),12,c);draw_line(Vector2(-3,34),Vector2(-3,-46),c,3.4,true)
				poly([[-3,-46],[42,-57],[42,22]],c,3.4);draw_circle(Vector2(30,26),12,c)
			"heart":
				poly([[0,45],[-39,6],[-37,-20],[-20,-32],[0,-12],[20,-32],[37,-20],[39,6],[0,45]],c,2.8)
			"zigzag": poly([[-57,-26],[-14,-42],[-30,0],[19,-16],[9,29],[55,9]],c,3.4)
			"brackets":
				poly([[-55,25],[-55,-32],[-2,-32]],c,3.0)
				poly([[4,31],[55,31],[55,-23]],c,3.0)
			"moon": poly([[27,-54],[-9,-41],[-26,-13],[-21,18],[4,39],[37,40],[15,16],[5,-17],[27,-54]],c,2.6)
			"cloud": poly([[-57,25],[-63,7],[-49,-6],[-31,-8],[-25,-32],[-3,-40],[22,-26],[24,-8],[47,-9],[59,6],[55,25],[-57,25]],c,2.3)
			"leaf":
				poly([[-3,66],[5,20],[0,-30],[15,-68]],c,2.0)
				poly([[4,22],[-25,14],[-42,-7],[-19,-5],[4,22]],c,1.8)
				poly([[2,-10],[25,-22],[39,-46],[18,-35],[2,-10]],c,1.8)
			"rays":
				for i in range(8):
					var a = i*TAU/8
					draw_line(Vector2(cos(a),sin(a))*48,Vector2(cos(a),sin(a))*82,c,2.7,true)
			"dash": poly([[-52,0],[52,0]],c,3.2)
			"pencil":
				var pts = PackedVector2Array([Vector2(-550,-38),Vector2(420,-38),Vector2(520,0),Vector2(420,38),Vector2(-550,38)])
				draw_colored_polygon(pts,c);draw_polyline(pts,ink,3,true)
				draw_line(Vector2(-480,-20),Vector2(417,-20),Color("#e7e5e0"),3,true)
			"flash": draw_rect(Rect2(-1080,-1920,2160,3840),Color(1,1,1,.34))
		draw_set_transform(Vector2.ZERO)
