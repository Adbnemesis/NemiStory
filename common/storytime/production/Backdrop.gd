extends Node2D
## Authored scenery selection. Not every beat needs an illustration reveal.
var kind := "paper"
const School=preload("res://common/storytime/production/SchoolBackdrop.gd")
const Suspense=preload("res://common/storytime/production/SchoolSuspenseBackdrop.gd")
const Episode=preload("res://common/storytime/production/SchoolEpisodeBackdrop.gd")
const ADBEp=preload("res://common/storytime/production/ADBEpisodeBackdrop.gd")
const CreatorArt=preload("res://common/storytime/production/CreatorEpisodeArt.gd")
const SchoolYoutube=preload("res://common/storytime/production/SchoolYoutubeBackdrop.gd")
func set_kind(value: String) -> void:
	if value!=kind:
		kind=value
		queue_redraw()
func ink(points: Array, color: Color=Color("#b6aa98"), width: float=2.0) -> void:
	var packed := PackedVector2Array()
	for p in points: packed.append(Vector2(p[0],p[1]))
	draw_polyline(packed,color,width,true)
func _draw() -> void:
	if kind in SchoolYoutube.KINDS:
		SchoolYoutube.draw_set(self,kind)
		return
	if kind=="nemi_creator_studio":
		CreatorArt.draw_set(self)
		return
	if kind in ADBEp.KINDS:
		ADBEp.draw_set(self,kind)
		return
	if kind in Episode.KINDS:
		Episode.draw_set(self,kind)
		return
	if kind in Suspense.KINDS:
		Suspense.draw_set(self,kind)
		return
	if kind in ["school_classroom","school_corridor","school_courtyard"]:
		School.draw_set(self,kind)
		return
	if kind in ["sf_street","sf_bridge","tech_auditorium","car_cabin","airport_road","roadside"]:
		_draw_travel()
		return
	var paper := Color("#faf6ed")
	if kind=="thought": paper=Color("#ede8f0")
	elif kind=="evening": paper=Color("#e6e8ec")
	draw_rect(Rect2(-3000,-3000,8000,8000),paper)
	if kind in ["room","evening","studio_nemi","studio_adb"]:
		draw_colored_polygon(PackedVector2Array([Vector2(0,894),Vector2(1920,886),Vector2(1920,1400),Vector2(0,1400)]),Color("#efe5d3" if kind=="room" else "#d6d6db"))
		ink([[0,894],[815,890],[1920,886]])
		ink([[1190,220],[1540,217],[1544,465],[1187,470],[1190,220]])
		ink([[1365,220],[1364,466]])
		ink([[1190,346],[1542,342]])
		draw_colored_polygon(PackedVector2Array([Vector2(1196,226),Vector2(1534,224),Vector2(1537,458),Vector2(1195,463)]),Color("#dce6df" if kind=="room" else "#bdc8d8"))
		ink([[1365,228],[1364,458]])
		ink([[1197,346],[1535,342]])
		ink([[171,284],[392,280],[395,443],[170,445],[171,284]])
		ink([[206,406],[235,350],[278,379],[329,321],[359,404]])
		if kind=="studio_nemi":
			ink([[160,510],[385,506],[383,678],[166,684],[160,510]],Color("#bc9aa6"))
			ink([[205,569],[244,613],[284,548],[333,604]],Color("#bc9aa6"),3)
		elif kind=="studio_adb":
			ink([[165,518],[389,519],[388,656],[163,657],[165,518]],Color("#94a4ab"))
			ink([[188,585],[226,586],[246,552],[289,617],[319,582],[366,583]],Color("#94a4ab"),3)
	elif kind=="thought":
		ink([[170,160],[1744,155],[1748,910],[166,915],[170,160]],Color("#b8a7c0"),3)
		for x in [260,1690]:
			ink([[x,126],[x+4,181]],Color("#b8a7c0"),7)

func patch(points: Array, color: Color, width: float=2.2) -> void:
	var pts=PackedVector2Array()
	for p in points:pts.append(Vector2(p[0],p[1]))
	draw_colored_polygon(pts,color)
	ink(points,Color("#857a7f"),width)

func _draw_travel() -> void:
	var warm=Color("#f7eee0")
	var blue=Color("#ccdfe1")
	var green=Color("#b7c8b4")
	if kind=="sf_street":
		patch([[0,0],[1920,0],[1920,718],[0,717],[0,0]],blue)
		# Hills and individually blocked row houses establish San Francisco.
		patch([[0,497],[394,366],[786,461],[1330,334],[1920,448],[1920,769],[0,768],[0,497]],green)
		var blocks: Array=[[70,338,240,420,"#d9c3ad"],[335,403,260,355,"#c5ccbd"],[1120,340,235,420,"#dfc9ac"],[1390,281,260,479,"#c4cad4"],[1680,394,215,367,"#d6b6ad"]]
		for b in blocks:
			var x: float=b[0];var y: float=b[1];var w: float=b[2];var h: float=b[3]
			patch([[x,y],[x+w,y-4],[x+w+2,y+h],[x-3,y+h],[x,y]],Color(b[4]))
			ink([[x-12,y],[x+w/2,y-39],[x+w+13,y-4]],Color("#857a7f"),3)
			for row in range(2):
				for column in range(2):
					var wx=x+35+column*int(w/2);var wy=y+38+row*95
					patch([[wx,wy],[wx+57,wy-1],[wx+56,wy+63],[wx-1,wy+65],[wx,wy]],Color("#f1e7d4"),1.6)
			patch([[x+w/2-25,y+h-105],[x+w/2+29,y+h-105],[x+w/2+31,y+h],[x+w/2-27,y+h],[x+w/2-25,y+h-105]],Color("#a39791"),1.6)
		patch([[0,760],[1920,763],[1920,960],[0,955],[0,760]],warm)
		ink([[0,894],[1920,895]],Color("#aa9d92"))
		for x in [150,570,990,1410,1830]:ink([[x,764],[x-90,894]],Color("#c5b7a4"),1.4)
		ink([[1020,350],[1014,888]],Color("#8c9290"),5)
		patch([[987,331],[1047,330],[1039,393],[992,393],[987,331]],Color("#eee4c8"))
	elif kind=="sf_bridge":
		patch([[0,0],[1920,0],[1920,634],[0,635],[0,0]],Color("#e9ded1"))
		patch([[0,544],[301,474],[527,523],[960,423],[1380,504],[1920,425],[1920,658],[0,656],[0,544]],green)
		patch([[0,594],[1920,595],[1920,862],[0,859],[0,594]],blue)
		var rust=Color("#b66f58")
		for x in [864,1478]:
			patch([[x-20,220],[x+19,219],[x+23,661],[x-24,660],[x-20,220]],rust,2.8)
			patch([[x-94,225],[x-60,224],[x-58,658],[x-95,658],[x-94,225]],rust,2.8)
			ink([[x-80,305],[x+3,305]],rust,17)
			ink([[x-80,426],[x+4,426]],rust,15)
		ink([[648,577],[777,485],[875,282],[982,423],[1100,482],[1220,507],[1340,467],[1420,269],[1520,411],[1685,533],[1850,577]],rust,4)
		ink([[620,585],[1870,576]],rust,13)
		for x in range(680,1810,50):ink([[x,520 if x<820 or x>1580 else 470],[x,580]],rust,2)
		for y in [688,741,789]:ink([[800,y],[1180,y-5],[1690,y+4]],Color("#a6c4cc"),2)
		patch([[0,847],[1920,847],[1920,1080],[0,1080],[0,847]],warm)
		ink([[0,892],[1920,894]],Color("#a89e94"),3)
		ink([[0,683],[1920,678]],Color("#989899"),5)
		for x in [45,640,1060,1620,1890]:ink([[x,680],[x,846]],Color("#989899"),4)
	elif kind=="tech_auditorium":
		patch([[0,0],[1920,0],[1920,894],[0,892],[0,0]],Color("#dce3de"))
		patch([[697,134],[1776,137],[1784,663],[694,665],[697,134]],Color("#faf5ea"),3)
		ink([[934,407],[1049,307],[1186,414],[1316,310],[1450,424],[1588,310]],Color("#8cafa4"),6)
		patch([[663,731],[1815,729],[1904,892],[612,892],[663,731]],Color("#b1bbb8"))
		patch([[1647,561],[1761,562],[1761,729],[1644,730],[1647,561]],Color("#899c97"))
		ink([[0,894],[1920,894]],Color("#a09589"),3)
	elif kind=="car_cabin":
		patch([[0,0],[1920,0],[1920,1080],[0,1080],[0,0]],Color("#e0ddd3"))
		patch([[80,160],[815,159],[839,476],[61,483],[80,160]],blue,4)
		patch([[977,159],[1822,161],[1842,484],[961,480],[977,159]],blue,4)
		for x in [130,361,590,1100,1390,1670]:
			ink([[x,284],[x+30,272],[x+80,281],[x+98,321]],Color("#97b1b2"),2)
		patch([[991,451],[1793,453],[1820,915],[952,916],[991,451]],Color("#a9b7b0"),3)
		ink([[1090,510],[1104,878]],Color("#7c918b"),3)
		ink([[1730,509],[1712,878]],Color("#7c918b"),3)
		patch([[0,710],[955,711],[928,979],[0,981],[0,710]],Color("#b9b5aa"))
	elif kind in ["airport_road","roadside"]:
		patch([[0,0],[1920,0],[1920,621],[0,621],[0,0]],Color("#d6e2df" if kind=="airport_road" else "#dadfe5"))
		patch([[0,517],[318,447],[629,505],[970,463],[1330,505],[1701,447],[1920,492],[1920,681],[0,680],[0,517]],green)
		patch([[1425,397],[1884,395],[1882,613],[1423,617],[1425,397]],Color("#c0cbd0"))
		for x in range(1460,1850,70):ink([[x,432],[x,585]],Color("#91a3ac"),2)
		patch([[0,684],[1920,683],[1920,957],[0,959],[0,684]],Color("#b9bcbb"))
		ink([[0,693],[1920,691]],Color("#ece4cb"),5)
		ink([[0,894],[1920,894]],Color("#efe4c9"),4)
		for x in [80,430,790,1150,1510]:ink([[x,913],[x+190,912]],Color("#f8f1d9"),6)
		ink([[0,617],[1920,615]],Color("#97a39e"),7)
		for x in [90,450,830,1210,1590,1870]:ink([[x,620],[x,682]],Color("#97a39e"),4)
		if kind=="airport_road":
			patch([[934,289],[1328,289],[1326,463],[934,466],[934,289]],Color("#6d9281"),3)
			ink([[969,336],[1146,337]],Color("#eef0dc"),4)
			ink([[1192,396],[1262,330],[1240,336],[1262,330],[1260,356]],Color("#eef0dc"),4)
			ink([[940,466],[940,612]],Color("#99a5a1"),5)
