extends RefCounted
## EP11's restrained creator-diary illustrations, played by the shared ink clock.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["creator_reach_chart","creator_calendar","creator_comment","creator_story_pages","creator_upload","creator_draft_choices","creator_hour_steps","creator_viewers"]
static func line(n: Node2D,raw: Array,col: Color,w: float=3.2,fill: Variant=null,smooth: bool=true) -> void:
	var pts=PackedVector2Array()
	for v in raw:pts.append(Vector2(v[0],v[1]))
	if fill!=null:n.fills.append({"poly":pts,"col":fill,"at":0.0})
	n.stroke_list.append({"pts":pts,"col":col,"w":w,"smooth":smooth,"pause":.07,"pressure":PackedFloat32Array([.4,1,.82,.96,.35])})
static func make(author: String,kind: String) -> Node2D:
	var n=Drawing.new();var ink=Color(Profile.profile(author).ink);var rose=Color("#ad5e69")
	match kind:
		"creator_upload":
			line(n,[[-228,-140],[219,-138],[230,103],[-226,109],[-228,-140]],ink,3.5,Color("#fffdf8"),false)
			line(n,[[-228,-96],[221,-94]],ink,2,null,false)
			line(n,[[-191,-119],[-187,-118]],rose,5)
			line(n,[[-162,-119],[-158,-118]],Color("#d0b286"),5)
			line(n,[[-44,-55],[58,-53],[60,17],[-45,18],[-44,-55]],ink,2.5,Color("#edf1e9"),false)
			line(n,[[-5,-38],[24,-19],[-5,1],[-5,-38]],rose,3,null,false)
			line(n,[[-133,55],[125,55]],Color("#d3c5bd"),10,null,false)
			line(n,[[-133,55],[91,55]],Color("#769d87"),6,null,false)
		"creator_draft_choices":
			# Two alternative drafts, visibly different rather than a pile of tabs.
			line(n,[[-210,-110],[-17,-105],[-20,135],[-209,140],[-210,-110]],ink,3,Color("#fffdf8"),false)
			line(n,[[16,-147],[209,-140],[214,99],[20,105],[16,-147]],ink,3,Color("#f2e9df"),false)
			line(n,[[-183,-76],[-50,-73]],rose,4)
			line(n,[[-184,-38],[-93,-39]],ink,2)
			line(n,[[-182,1],[-54,4]],ink,2)
			line(n,[[-182,43],[-91,44]],ink,2)
			line(n,[[48,-99],[176,-96],[179,-6],[49,-4],[48,-99]],Color("#769d87"),3,null,false)
			line(n,[[86,-28],[112,-70],[141,-25]],rose,3)
			line(n,[[48,35],[176,37]],ink,3)
		"creator_hour_steps":
			# A finite climb metaphor, not a physical walking rig.
			line(n,[[-205,145],[-205,84],[-113,84],[-113,25],[-23,25],[-23,-37],[66,-37],[66,-98],[161,-98],[161,-153],[230,-153]],ink,5,null,false)
			line(n,[[-215,155],[232,153]],Color("#d5c3bf"),3,null,false)
			line(n,[[-175,56],[-169,6],[-137,-19],[-102,-4],[-98,38],[-121,57],[-153,65],[-175,56]],rose,3.5,Color("#f5e4dc"))
			line(n,[[-139,-9],[-140,24],[-116,33]],rose,3,null,false)
			line(n,[[206,-183],[209,-241],[254,-229],[210,-214]],Color("#769d87"),4,null,false)
		"creator_viewers":
			for item in [[-136,24,"#9eb4a0"],[-30,-32,"#d9b99a"],[87,27,"#c6a1aa"]]:
				var x: float=item[0];var y: float=item[1]
				line(n,[[x-22,y-43],[x-27,y-60],[x-17,y-80],[x+7,y-85],[x+22,y-65],[x+18,y-44],[x-1,y-35],[x-22,y-43]],ink,3,Color("#f2e4d7"))
				line(n,[[x-48,y+48],[x-41,y-3],[x-19,y-26],[x+21,y-25],[x+45,y+8],[x+46,y+48],[x-48,y+48]],ink,3,Color(item[2]))
			line(n,[[-67,94],[-26,117],[18,99]],rose,3)
			line(n,[[-45,87],[-24,72],[-10,83],[-12,95],[-28,108],[-44,98],[-45,87]],rose,3)
		"creator_reach_chart":
			# Deliberately no fabricated analytical values or dashboard screenshot.
			line(n,[[-265,-183],[265,-181],[268,183],[-270,185],[-265,-183]],Color("#d8c9bf"),1.7,Color("#fffdf8"),false)
			line(n,[[-231,-150],[-235,137],[244,139]],ink,3.2,null,false)
			line(n,[[-214,103],[-167,69],[-118,-103],[-67,-135],[-18,66],[52,96],[121,109],[182,111],[235,117]],rose,5)
			line(n,[[-218,153],[-198,152]],ink,2)
			line(n,[[205,154],[230,155]],ink,2)
		"creator_calendar":
			line(n,[[-156,-164],[155,-158],[164,154],[-160,162],[-156,-164]],ink,3.5,Color("#fffdf8"),false)
			line(n,[[-155,-107],[155,-104]],ink,2.7,null,false)
			for x in [-90,84]:line(n,[[x,-183],[x+2,-139]],ink,5)
			for y in [-45,18,81]:line(n,[[-127,y],[127,y+2]],Color("#d5c3bf"),1.5,null,false)
			for x in [-63,0,65]:line(n,[[x,-78],[x+1,120]],Color("#d5c3bf"),1.5,null,false)
			line(n,[[-127,-48],[-66,-48],[-62,13],[-127,17],[-127,-48]],rose,3,Color("#efdad8"),false)
		"creator_comment":
			line(n,[[-214,-113],[210,-116],[219,77],[31,83],[-19,127],[-17,81],[-216,86],[-214,-113]],ink,3.5,Color("#fffdf8"),false)
			line(n,[[-167,-68],[-183,-58],[-178,-37],[-158,-28],[-144,-40],[-148,-61],[-167,-68]],Color("#769d87"),3)
			line(n,[[-118,-49],[167,-48]],ink,2.3)
			line(n,[[-179,0],[162,1]],Color("#9c828b"),2)
			line(n,[[-178,39],[100,37]],Color("#9c828b"),2)
			# One small authored heart; no invented subscriber name/testimonial.
			line(n,[[160,30],[151,20],[138,24],[141,36],[160,51],[177,34],[175,23],[164,23],[160,30]],rose,2.8)
		"creator_story_pages":
			for i in range(3):
				var x: float=i*19;var y: float=i*-15
				line(n,[[x-143,y-106],[x+119,y-102],[x+126,y+114],[x-141,y+119],[x-143,y-106]],ink,3,Color("#fffdf8"),false)
			line(n,[[-80,-98],[67,-95],[74,3],[-83,7],[-80,-98]],Color("#a68c94"),2,null,false)
			line(n,[[-22,-75],[-42,-54],[-40,-30],[-21,-17],[0,-29],[2,-54],[-22,-75]],rose,2.8)
			line(n,[[-64,-1],[-54,-20],[-22,-17],[16,-20],[27,-4]],rose,2.8)
			line(n,[[-82,38],[83,38]],ink,2)
			line(n,[[-80,72],[60,71]],ink,2)
	n.prepare()
	return n
static func draw_set(n: Node2D) -> void:
	n.draw_rect(Rect2(-3000,-3000,8000,8000),Color("#faf7f2"))
	var ink=Color("#8f7980")
	# A single studio corner: window, modest drawing desk, grounded stool.
	n.draw_colored_polygon(PackedVector2Array([Vector2(-1000,894),Vector2(3000,894),Vector2(3000,2000),Vector2(-1000,2000)]),Color("#f2ebe0"))
	n.draw_polyline(PackedVector2Array([Vector2(-1000,894),Vector2(805,890),Vector2(3000,894)]),ink,2.5,true)
	n.draw_colored_polygon(PackedVector2Array([Vector2(210,205),Vector2(480,209),Vector2(479,465),Vector2(207,460)]),Color("#eaf1f3"))
	n.draw_polyline(PackedVector2Array([Vector2(210,205),Vector2(480,209),Vector2(479,465),Vector2(207,460),Vector2(210,205)]),ink,3,true)
	n.draw_line(Vector2(344,208),Vector2(345,463),ink,2,true)
	n.draw_line(Vector2(208,340),Vector2(480,342),ink,2,true)
	n.draw_colored_polygon(PackedVector2Array([Vector2(1090,701),Vector2(1640,698),Vector2(1643,726),Vector2(1088,730)]),Color("#e9ddcc"))
	n.draw_polyline(PackedVector2Array([Vector2(1090,701),Vector2(1640,698),Vector2(1643,726),Vector2(1088,730),Vector2(1090,701)]),ink,3,true)
	for x in [1120,1605]:n.draw_line(Vector2(x,729),Vector2(x+3,892),ink,4,true)
	n.draw_colored_polygon(PackedVector2Array([Vector2(1234,679),Vector2(1383,680),Vector2(1410,702),Vector2(1210,701)]),Color("#fffdf8"))
	n.draw_polyline(PackedVector2Array([Vector2(1234,679),Vector2(1383,680),Vector2(1410,702),Vector2(1210,701),Vector2(1234,679)]),ink,2,true)
	n.draw_line(Vector2(1389,673),Vector2(1460,689),Color("#ad5e69"),4,true)
	n.draw_line(Vector2(1240,805),Vector2(1478,806),ink,8,true)
	for x in [1260,1458]:n.draw_line(Vector2(x,809),Vector2(x-3,891),ink,3,true)
