extends RefCounted
## EP03 recognisable computer lab and present-day corner in cream-paper treatment.
const KINDS=["adb_computer_lab","adb_creator_studio_ep03"]
const PAPER=Color("#faf7f2")
const FLOOR=Color("#f2ebe0")
const INK=Color("#7f7a70")
const FAINT=Color("#c9c1b4")
const BLUE=Color("#e8eff1")
const WOOD=Color("#e8dfd0")

static func line(c: Node2D,raw: Array,col: Color=INK,w: float=2.2) -> void:
	var p=PackedVector2Array()
	for v in raw: p.append(Vector2(v[0],v[1]))
	c.draw_polyline(p,col,w,true)

static func patch(c: Node2D,raw: Array,col: Color,outline: Color=INK,w: float=2.2) -> void:
	var p=PackedVector2Array()
	for v in raw: p.append(Vector2(v[0],v[1]))
	c.draw_colored_polygon(p,col)
	line(c,raw,outline,w)

static func monitor(c: Node2D,x: float,y: float,width: float,height: float) -> void:
	patch(c,[[x,y],[x+width,y-1],[x+width+1,y+height],[x-1,y+height+1],[x,y]],Color("#deded8"),INK,2.5)
	patch(c,[[x+13,y+13],[x+width-13,y+12],[x+width-13,y+height-13],[x+13,y+height-12],[x+13,y+13]],Color("#fdfbf5"),Color("#aaa89f"),1.5)
	var center=x+width*.5
	line(c,[[center-9,y+height+1],[center-9,y+height+35],[center-46,y+height+43],[center+45,y+height+43],[center+10,y+height+34],[center+10,y+height]],INK,2.4)

static func keyboard(c: Node2D,x: float,y: float,width: float) -> void:
	patch(c,[[x,y],[x+width,y],[x+width+14,y+16],[x-12,y+16],[x,y]],Color("#e7e5de"),INK,1.6)
	for offset in [5,10]: line(c,[[x+8,y+offset],[x+width-4,y+offset]],Color("#b9b4a9"),.9)
	for offset in range(20,int(width),22): line(c,[[x+offset,y+2],[x+offset+3,y+12]],Color("#b9b4a9"),.8)

static func station(c: Node2D,x: float,y: float,width: float,hero: bool=false) -> void:
	patch(c,[[x,y],[x+width,y-2],[x+width+2,y+17],[x-2,y+19],[x,y]],WOOD,INK,2.4)
	for leg in [x+24,x+width-25]: line(c,[[leg,y+19],[leg+2,894]],INK,3)
	var mx=x+125 if hero else x+40
	var mw=370.0 if hero else width*.64
	var mh=204.0 if hero else 144.0
	var my=440.0 if hero else y-mh-47
	monitor(c,mx,my,mw,mh)
	keyboard(c,mx+32,y-20,mw*.57)
	line(c,[[mx+mw-32,y-20],[mx+mw-14,y-17],[mx+mw-10,y-5],[mx+mw-27,y-3],[mx+mw-32,y-20]],INK,1.5)
	# Recognisable tower below desk, with drive, power button and vent lines.
	patch(c,[[x+width-114,y+31],[x+width-40,y+32],[x+width-40,890],[x+width-117,890],[x+width-114,y+31]],Color("#e1e0d9"),INK,2)
	line(c,[[x+width-100,y+51],[x+width-52,y+51]],INK,1.6)
	line(c,[[x+width-78,y+68],[x+width-76,y+68]],INK,4)
	for offset in [94,107,120]: line(c,[[x+width-101,y+offset],[x+width-54,y+offset]],Color("#b2ada0"),1.3)
	# Chair occupies its own grounded bay; it is not seated-actor contact.
	var cx=x+width*.52
	patch(c,[[cx-58,y+72],[cx+58,y+73],[cx+57,y+91],[cx-59,y+91],[cx-58,y+72]],Color("#e4e4dc"),INK,2)
	line(c,[[cx-48,y+91],[cx-50,892]],INK,2.4)
	line(c,[[cx+47,y+91],[cx+50,892]],INK,2.4)
	line(c,[[cx-57,y+71],[cx-56,y+22],[cx+58,y+23],[cx+59,y+71]],INK,2)
	line(c,[[cx-54,y+41],[cx+55,y+41]],Color("#bbb5a9"),1.2)

static func draw_set(c: Node2D,kind: String) -> void:
	c.draw_rect(Rect2(-3000,-3000,8000,8000),PAPER)
	c.draw_rect(Rect2(-3000,894,8000,3000),FLOOR)
	line(c,[[-3000,894],[3000,894]],Color("#a69c8e"),2.4)
	if kind=="adb_computer_lab":
		# Pale window and a rear workstation row establish a computer period.
		patch(c,[[119,207],[447,208],[446,437],[118,436],[119,207]],BLUE,INK,2.3)
		line(c,[[283,208],[283,436]],INK,1.5)
		line(c,[[118,321],[446,321]],INK,1.5)
		line(c,[[459,116],[460,621]],FAINT,1.3)
		line(c,[[0,626],[485,625]],FAINT,1.5)
		# Compact rear desks keep center stage clear, without coloured walls.
		station(c,15,674,420)
		station(c,1090,694,720,true)
		# A socket strip and tidy cables identify the functional lab setting.
		patch(c,[[1220,310],[1652,310],[1654,333],[1219,333],[1220,310]],Color("#f5f0e7"),FAINT,1.2)
		for x in [1246,1350,1454,1558]: line(c,[[x,316],[x,326]],Color("#aba395"),2)
		line(c,[[1759,894],[1760,860],[1773,835]],FAINT,1.1)
		line(c,[[1480,690],[1478,718],[1730,736],[1733,750]],FAINT,1.1)
		# Small shelf with blank manuals; no school name or fabricated timetable.
		line(c,[[1687,232],[1872,232]],INK,3)
		for x in [1704,1733,1768,1804,1837]:
			patch(c,[[x,179],[x+18,178],[x+18,230],[x,230],[x,179]],Color("#e7e1d4"),FAINT,1.3)
	elif kind=="adb_creator_studio_ep03":
		patch(c,[[200,208],[486,208],[487,460],[199,462],[200,208]],BLUE,INK,2.4)
		line(c,[[343,208],[343,461]],INK,1.6)
		line(c,[[200,336],[487,336]],INK,1.6)
		station(c,1090,694,720,true)
		line(c,[[1450,240],[1787,240]],INK,3)
		for x in [1491,1515,1542,1568]:
			patch(c,[[x,178],[x+18,178],[x+18,238],[x,238],[x,178]],Color("#e5dfd2"),FAINT,1.3)
		patch(c,[[1598,201],[1640,201],[1636,238],[1603,238],[1598,201]],WOOD,FAINT,1.4)
		line(c,[[1618,201],[1610,182],[1620,173],[1627,194]],Color("#9dafa0"),2)
	else: assert(false,"Unknown school YouTube backdrop: "+kind)
