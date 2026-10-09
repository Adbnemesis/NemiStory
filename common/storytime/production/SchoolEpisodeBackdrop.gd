extends RefCounted
## EP06-style cream paper, readable ink, selective focal colour and rich location detail.
const KINDS=["school_day_r4","school_corridor_r4","school_courtyard_r4","school_street_r4","bedroom_evening_r4","lane_night_r4","school_office_r4"]
static func draw_set(c: Node2D,kind: String) -> void:
	var night=kind in ["bedroom_evening_r4","lane_night_r4"]
	c.draw_rect(Rect2(-3000,-3000,8000,8000),Color("#faf7f2" if night else "#faf7f2"))
	var ink=Color("#554754");var deep=Color("#6b5763")
	if kind in ["school_street_r4","lane_night_r4"]:
		c.patch([[0,0],[1920,0],[1920,690],[0,690],[0,0]],Color("#f3f0ee" if night else "#faf7f2"))
		c.patch([[0,690],[1920,690],[1920,1400],[0,1400],[0,690]],Color("#ece8e2" if night else "#f1eee8"))
		c.patch([[0,759],[1920,759],[1920,895],[0,895],[0,759]],Color("#f2ebe0" if night else "#f2ebe0"))
		for b in [[-20,138,390,621,"#fbf6ef"],[385,246,440,513,"#f8f4ed"],[905,160,430,599,"#fcf8f2"],[1380,100,560,659,"#f7f2ea"]]:
			var x: float=b[0];var y: float=b[1];var w: float=b[2];var h: float=b[3]
			c.patch([[x,y],[x+w,y-6],[x+w+3,y+h],[x-4,y+h],[x,y]],Color(b[4]),3)
			c.ink([[x-7,y],[x+w*.5,y-35],[x+w+8,y-5]],deep,5)
			for wx in [x+53,x+w-134]:
				c.patch([[wx,y+72],[wx+85,y+69],[wx+90,y+190],[wx-2,y+195],[wx,y+72]],Color("#f0ece7" if night else "#ebf4fa"),2)
				c.ink([[wx+41,y+72],[wx+43,y+190]],deep,3)
			c.patch([[x+70,y+h-252],[x+190,y+h-255],[x+194,y+h],[x+66,y+h],[x+70,y+h-252]],Color("#eee8df"),3)
		if not night:
			c.patch([[884,331],[1350,327],[1378,386],[862,391],[884,331]],Color("#e0c7b1"),3)
			for x in range(890,1350,63):c.ink([[x,335],[x-14,387]],Color("#f4ebe1"),22)
			c.patch([[924,407],[1315,404],[1318,715],[920,716],[924,407]],Color("#fffdf8"),3)
			for x in [954,1066,1182]:
				for y in [474,574]:
					c.patch([[x,y],[x+57,y-3],[x+60,y+61],[x-3,y+65],[x,y]],Color("#c8dbd5" if y==474 else "#e4d1d8"),2)
			c.ink([[930,545],[1310,543]],ink,4)
			c.ink([[930,652],[1310,650]],ink,4)
		else:
			c.patch([[996,142],[1234,139],[1240,431],[992,434],[996,142]],Color("#f0c371"),4)
			c.ink([[1115,142],[1118,432]],deep,7)
			c.ink([[994,285],[1235,284]],deep,5)
			c.patch([[901,663],[1343,661],[1344,895],[899,895],[901,663]],Color("#efe9e2"),3)
			for x in range(922,1340,40):c.ink([[x,669],[x,890]],deep,4)
		c.ink([[842,240],[838,894]],deep,8)
		c.patch([[800,214],[878,212],[861,288],[819,289],[800,214]],Color("#f1ce83"),3)
		c.ink([[0,894],[1920,894]],ink,4)
		return
	c.patch([[0,0],[1920,0],[1920,894],[0,894],[0,0]],Color("#faf7f2" if night else "#faf7f2" if kind=="school_day_r4" else "#faf4eb"),3)
	c.patch([[0,894],[1920,894],[1920,1400],[0,1400],[0,894]],Color("#f2ebe0" if night else "#f2ebe0"),3)
	c.ink([[0,894],[1920,894]],ink,4)
	for x in [100,480,920,1370,1770]:c.ink([[x,894],[x-170,1360]],Color("#d8cfc4" if night else "#dfd5c7"),2)
	if kind=="school_day_r4":
		c.patch([[64,171],[410,164],[415,525],[61,529],[64,171]],Color("#ebf4fa"),4)
		c.ink([[230,171],[235,527]],Color("#6b5763"),6)
		c.ink([[65,353],[414,346]],Color("#6b5763"),5)
		c.patch([[892,128],[1514,122],[1518,471],[888,478],[892,128]],Color("#45514b"),4)
		c.ink([[900,469],[1510,463]],Color("#d5a66a"),12)
		for y in [205,254,306]:c.ink([[954,y],[1128,y-4]],Color("#e7eed7"),4)
		c.ink([[1238,371],[1320,191],[1430,360],[1238,371]],Color("#e7eed7"),4)
		for x in [785,1250]:
			c.patch([[x-115,586],[x+105,580],[x+111,596],[x-118,602],[x-115,586]],Color("#deccba"),3)
			c.ink([[x-88,600],[x-90,759]],deep,5);c.ink([[x+85,594],[x+89,759]],deep,5)
		c.patch([[1670,231],[1866,227],[1871,894],[1667,894],[1670,231]],Color("#efe7dc"),3)
		c.patch([[1698,270],[1830,267],[1834,437],[1695,440],[1698,270]],Color("#ebf4fa"),3)
	elif kind in ["school_corridor_r4","school_courtyard_r4"]:
		if kind=="school_courtyard_r4":
			c.patch([[0,0],[1920,0],[1920,700],[0,700],[0,0]],Color("#faf7f2"))
			c.patch([[99,113],[1792,109],[1799,654],[94,663],[99,113]],Color("#f9f3e9"),4)
			for x in [220,480,950,1220,1510]:c.patch([[x,225],[x+152,221],[x+160,400],[x-2,406],[x,225]],Color("#ebf4fa"),3)
			c.patch([[698,390],[860,387],[866,657],[695,658],[698,390]],Color("#e9dfd1"),3)
		else:
			for x in [100,300,500,1010,1210,1410]:
				c.patch([[x,192],[x+177,187],[x+180,894],[x-4,894],[x,192]],Color("#f1ebe2"),3)
				for y in [248,270]:c.ink([[x+27,y],[x+151,y-2]],Color("#8a7d79"),3)
				c.ink([[x+144,485],[x+144,524]],deep,5)
		c.patch([[1660,238],[1872,233],[1876,894],[1657,894],[1660,238]],Color("#ece3d6"),3)
	elif kind=="bedroom_evening_r4":
		c.patch([[946,94],[1540,88],[1545,670],[941,675],[946,94]],Color("#e7d6c1"),4)
		c.patch([[982,123],[1509,117],[1516,643],[975,649],[982,123]],Color("#ebf4fa"),3)
		c.ink([[1242,123],[1249,643]],Color("#6b5763"),6)
		c.ink([[979,383],[1510,377]],Color("#6b5763"),5)
		c.patch([[955,111],[1073,108],[1056,655],[946,664],[955,111]],Color("#eee7df"),3)
		c.patch([[1398,109],[1536,102],[1541,664],[1419,658],[1398,109]],Color("#eee7df"),3)
		c.ink([[926,75],[1566,70]],Color("#6b5763"),7)
		c.patch([[103,214],[309,210],[313,749],[98,754],[103,214]],Color("#eee8df"),4)
		for y in [339,488,623]:
			c.ink([[105,y],[309,y-3]],Color("#9a8275"),5)
			for x in [124,154,190,225,266]:c.ink([[x,y-89],[x+5,y-7]],Color("#ad8d66" if x%2==0 else "#8ca599"),17)
		c.patch([[85,773],[322,771],[337,835],[74,840],[85,773]],Color("#e3d0bf"),4)
		c.ink([[118,841],[116,894]],deep,6);c.ink([[295,835],[304,894]],deep,6)
	else:
		c.patch([[1093,118],[1619,112],[1624,449],[1088,454],[1093,118]],Color("#fffdf8"),4)
		for y in [190,251,313]:c.ink([[1160,y],[1533,y-2]],Color("#ab9c8c"),4)
		c.patch([[149,361],[334,357],[335,808],[145,813],[149,361]],Color("#eee6dc"),4)
		for y in [510,655]:c.ink([[153,y],[333,y-3]],deep,4)
		c.patch([[1753,697],[1840,694],[1826,815],[1765,816],[1753,697]],Color("#d9c4b6"),3)
		for p in [[[1790,703],[1721,589],[1711,533]],[[1795,704],[1851,586],[1863,536]],[[1796,704],[1790,532]]]:c.ink(p,Color("#8ca899"),17)
