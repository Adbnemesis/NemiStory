extends RefCounted
## R5 places use held scenery, cream paper and a shared y894 standing plane.
const KINDS=["attachment_visit_r5","attachment_cafe_r5","attachment_school_nook_r5","attachment_home_care_r5"]
const INK=Color("#88767c")
const PAPER=Color("#faf7f2")
const SOFT=Color("#bcafa3")
const WOOD=Color("#e7d9c6")

static func plane(c: Node2D) -> void:
	c.draw_rect(Rect2(-3000,-3000,8000,8000),PAPER)
	c.patch([[-1000,894],[3000,894],[3000,2000],[-1000,2000],[-1000,894]],Color("#f2ebe0"),2)
	c.ink([[-1000,894],[813,892],[3000,894]],SOFT,3)
	c.ink([[-1000,919],[3000,919]],Color("#e5dacb"),1.6)

static func window(c: Node2D,x: float,y: float,w: float,h: float,city: bool=false) -> void:
	c.patch([[x,y],[x+w,y+3],[x+w+3,y+h],[x-3,y+h+1],[x,y]],Color("#eaf0ee"),2.8)
	if city:
		for b in [[x+21,y+h-131,70,131],[x+105,y+h-184,82,184],[x+201,y+h-147,72,147]]:
			c.patch([[b[0],b[1]],[b[0]+b[2],b[1]-2],[b[0]+b[2],b[1]+b[3]-10],[b[0],b[1]+b[3]-10],[b[0],b[1]]],Color("#edf0e9"),1.7)
			for row in range(2):
				c.ink([[b[0]+19,b[1]+30+row*43],[b[0]+b[2]-17,b[1]+30+row*43]],Color("#c4d0c8"),5)
	else:
		c.ink([[x+13,y+h-35],[x+60,y+h-64],[x+119,y+h-43],[x+173,y+h-71],[x+w-12,y+h-31]],Color("#c5d1c2"),12)
	c.ink([[x+w*.5,y+3],[x+w*.5,y+h]],INK,3)
	c.ink([[x+1,y+h*.52],[x+w,y+h*.52+2]],INK,2.5)
	c.ink([[x-16,y+h+10],[x+w+18,y+h+13]],INK,5)

static func bag(c: Node2D,x: float,y: float,w: float,h: float,col: Color) -> void:
	c.patch([[x+5,y-h],[x+w-7,y-h-3],[x+w,y-h+11],[x+w-1,y-12],[x+w-12,y],[x+8,y],[x,y-14],[x+1,y-h+13],[x+5,y-h]],col,3)
	c.ink([[x+w*.34,y-h-4],[x+w*.35,y-h-31],[x+w*.67,y-h-32],[x+w*.68,y-h-3]],INK,3.5)
	for bx in [x+w*.2,x+w*.8]:c.ink([[bx,y-h+12],[bx,y-13]],SOFT,3)
	c.patch([[x+w*.63,y-h+39],[x+w*.86,y-h+40],[x+w*.85,y-h+69],[x+w*.62,y-h+67],[x+w*.63,y-h+39]],Color("#fffdf8"),1.7)
	c.ink([[x+w*.68,y-h+49],[x+w*.79,y-h+50]],SOFT,1.8)
	c.ink([[x+16,y],[x+16,y+8]],INK,5)
	c.ink([[x+w-16,y],[x+w-16,y+8]],INK,5)

static func chair(c: Node2D,x: float,back_top: float,seat: float,w: float=144) -> void:
	c.patch([[x-w*.43,back_top],[x+w*.43,back_top-2],[x+w*.46,seat-49],[x-w*.46,seat-47],[x-w*.43,back_top]],Color("#eee4d7"),3)
	for sy in [back_top+44,back_top+89]:
		c.ink([[x-w*.35,sy],[x+w*.35,sy-1]],Color("#cebba6"),5)
	c.patch([[x-w*.55,seat-8],[x+w*.53,seat-10],[x+w*.59,seat+11],[x-w*.59,seat+14],[x-w*.55,seat-8]],WOOD,3)
	for dx in [-w*.38,w*.38]:
		c.ink([[x+dx,seat+13],[x+dx*1.14,894]],INK,4)

static func draw_set(c: Node2D,kind: String) -> void:
	assert(kind in KINDS,"Unknown attachment revision background: "+kind)
	plane(c)
	match kind:
		"attachment_visit_r5":
			# Arrival corner, no landmark, transport mode or family identity invented.
			window(c,115,147,337,355,true)
			c.ink([[80,117],[487,119]],SOFT,4)
			for x in [94,472]:
				c.ink([[x,122],[x-8,523]],Color("#d7c5ba"),10)
			c.patch([[1457,694],[1818,691],[1826,720],[1451,724],[1457,694]],WOOD,3)
			for x in [1480,1796]:c.ink([[x,724],[x+1,894]],INK,4)
			c.patch([[1497,665],[1671,665],[1687,694],[1480,697],[1497,665]],Color("#e8dfd2"),2.5)
			c.ink([[1535,674],[1629,676]],Color("#c7b4a7"),2)
			bag(c,153,884,159,216,Color("#dccbb8"))
			bag(c,329,886,112,156,Color("#d4d3c5"))
			c.ink([[1652,215],[1823,213]],SOFT,4)
			for x in [1680,1741,1802]:
				c.ink([[x,215],[x,234],[x+9,242],[x+17,235]],INK,3)
			c.patch([[1748,245],[1770,244],[1784,257],[1804,385],[1720,386],[1735,264],[1748,245]],Color("#ece4d8"),2)
			c.ink([[1760,257],[1761,373]],SOFT,2)
			c.ink([[1108,894],[1079,927]],Color("#ded2c3"),1.6)
		"attachment_cafe_r5":
			# Three chairs are actual set furniture. Table ellipse holds cup overlays.
			window(c,100,170,285,312,true)
			c.ink([[117,514],[365,514]],SOFT,3)
			c.ink([[1342,-80],[1343,337]],INK,3.5)
			c.patch([[1273,396],[1306,337],[1375,337],[1415,398],[1273,396]],Color("#eee2cb"),3)
			c.ink([[1287,405],[1400,405]],Color("#d1ba97"),4)
			chair(c,930,494,719,150)
			chair(c,1335,390,632,160)
			chair(c,1742,494,719,150)
			c.patch([[1035,624],[1102,595],[1341,579],[1578,602],[1645,632],[1587,666],[1346,685],[1100,667],[1035,624]],WOOD,3.5)
			c.ink([[1043,643],[1110,680],[1344,699],[1583,680],[1635,649]],INK,3.5)
			# A stable pedestal gives the wide table a believable grounded support.
			c.patch([[1318,697],[1367,696],[1377,859],[1309,860],[1318,697]],Color("#d9c6b1"),3)
			c.ink([[1339,858],[1212,888],[1467,888],[1343,859]],INK,5)
			c.ink([[1201,895],[1481,895]],SOFT,2.5)
			# A small quiet counter stays out of the actor and conversation lanes.
			c.patch([[74,708],[324,705],[331,725],[70,728],[74,708]],WOOD,3)
			for x in [95,306]:c.ink([[x,729],[x,894]],INK,3.5)
			c.patch([[158,634],[227,633],[220,706],[165,708],[158,634]],Color("#e0e3d3"),2.5)
			for p in [[[184,634],[176,574],[157,545]],[[193,634],[215,574],[238,565]],[[190,634],[193,552],[208,529]]]:
				c.ink(p,Color("#a8b49b"),5)
			c.ink([[1786,257],[1806,238],[1835,239],[1854,261],[1847,289],[1824,300],[1797,286],[1786,257]],SOFT,2.8)
			c.ink([[1821,246],[1821,268],[1838,276]],INK,2.5)
		"attachment_school_nook_r5":
			# A grounded bench, bag and architecture make a school memory a place.
			for x in [74,206,338]:
				c.patch([[x,181],[x+112,182],[x+112,892],[x-2,893],[x,181]],Color("#eee9df"),2.3)
				c.ink([[x+15,231],[x+94,231]],SOFT,2)
				c.ink([[x+15,244],[x+94,244]],SOFT,2)
				c.ink([[x+88,496],[x+88,541]],INK,3)
				c.ink([[x+13,825],[x+97,825]],SOFT,2)
			c.patch([[1666,162],[1953,162],[1954,893],[1664,893],[1666,162]],Color("#eee5d9"),3)
			c.patch([[1702,204],[1917,205],[1917,457],[1700,459],[1702,204]],Color("#edf1eb"),2.5)
			c.ink([[1738,587],[1738,625]],INK,4)
			c.ink([[1653,151],[1964,151]],SOFT,5)
			window(c,1022,171,398,242,false)
			for y in [568,607,646]:c.ink([[1243,y],[1598,y-1]],Color("#c6b199"),12)
			c.ink([[1236,714],[1610,713]],INK,8)
			for x in [1265,1585]:
				c.ink([[x,550],[x,717],[x+2,894]],INK,4)
			c.ink([[1220,682],[1264,682]],INK,4)
			c.ink([[1587,680],[1631,681]],INK,4)
			c.patch([[1762,731],[1853,732],[1873,769],[1871,879],[1750,881],[1746,772],[1762,731]],Color("#d5d1be"),3)
			c.ink([[1778,733],[1781,709],[1824,708],[1830,732]],INK,3)
			c.ink([[1774,786],[1844,787],[1850,841],[1768,843],[1774,786]],SOFT,2.5)
			c.ink([[1767,756],[1780,803]],SOFT,3)
		"attachment_home_care_r5":
			# New reachable console, y510 contact surface. Original home is unchanged.
			window(c,166,185,336,317,false)
			c.ink([[143,143],[528,145]],SOFT,4)
			c.patch([[1210,510],[1733,510],[1742,531],[1205,532],[1210,510]],WOOD,3.5)
			c.patch([[1223,533],[1725,532],[1724,869],[1223,870],[1223,533]],Color("#efe4d5"),3)
			c.ink([[1474,549],[1474,851]],SOFT,2.5)
			c.ink([[1240,553],[1456,553],[1457,849],[1241,849],[1240,553]],Color("#ccb9a7"),2)
			c.ink([[1493,552],[1706,551],[1706,849],[1494,849],[1493,552]],Color("#ccb9a7"),2)
			for x in [1438,1512]:c.ink([[x,644],[x,684]],INK,3.5)
			for x in [1250,1693]:c.ink([[x,871],[x,894]],INK,5)
			c.ink([[1496,243],[1786,241]],INK,6)
			c.ink([[1531,244],[1531,271]],SOFT,3)
			c.ink([[1758,243],[1758,271]],SOFT,3)
			c.patch([[1581,171],[1650,170],[1651,239],[1582,240],[1581,171]],Color("#e9dfd1"),2.4)
			c.ink([[1603,170],[1592,125],[1609,94]],Color("#a9b39d"),4)
			c.ink([[1620,170],[1630,119],[1650,105]],Color("#a9b39d"),4)
			c.patch([[1679,175],[1753,176],[1753,239],[1678,240],[1679,175]],PAPER,2)
			c.ink([[1693,220],[1712,195],[1738,222]],Color("#c7b5a8"),2.2)

