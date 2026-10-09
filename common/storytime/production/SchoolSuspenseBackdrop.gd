extends RefCounted
## Held Nemi school-neighbourhood sets; world geometry fixed through reframes.
const KINDS=["residential_lane","stationery_shop","home_curtain","school_office"]
static func draw_set(c: Node2D,kind: String) -> void:
	c.draw_rect(Rect2(-3000,-3000,8000,8000),Color("#ece5df"))
	if kind in ["residential_lane","stationery_shop"]:
		c.patch([[0,0],[1920,0],[1920,690],[0,690],[0,0]],Color("#c9d1d8"))
		c.patch([[0,690],[1920,692],[1920,1400],[0,1400],[0,690]],Color("#b7b5b7"))
		c.patch([[0,759],[1920,759],[1920,901],[0,900],[0,759]],Color("#dfd3c5"))
		c.ink([[0,894],[1920,894]],Color("#938789"),3)
		for b in [[-50,122,420,638],[384,232,470,528],[896,151,425,610],[1368,82,620,677]]:
			var x: float=b[0];var y: float=b[1];var w: float=b[2];var h: float=b[3]
			c.patch([[x,y],[x+w,y-4],[x+w+2,y+h],[x-3,y+h],[x,y]],Color("#c8b9b3"))
			for wx in [x+66,x+w-153]:c.patch([[wx,y+64],[wx+90,y+63],[wx+91,y+201],[wx-2,y+204],[wx,y+64]],Color("#e8d3a3"))
			c.patch([[x+72,y+h-276],[x+210,y+h-277],[x+213,y+h],[x+68,y+h],[x+72,y+h-276]],Color("#94a3ac"))
		if kind=="stationery_shop":
			c.patch([[908,353],[1314,348],[1318,724],[906,727],[908,353]],Color("#f1e4c8"))
			c.patch([[876,314],[1336,312],[1355,353],[862,357],[876,314]],Color("#a1757a"))
			for x in [934,1037,1140,1243]:
				c.patch([[x,424],[x+61,422],[x+64,490],[x-2,492],[x,424]],Color("#b2c0b2"))
				c.patch([[x,535],[x+60,532],[x+61,609],[x,611],[x,535]],Color("#bca9bc"))
			for y in [499,616]:c.ink([[914,y],[1308,y-2]],Color("#9b8d7c"),5)
		else:
			c.patch([[901,663],[1343,661],[1344,895],[899,895],[901,663]],Color("#8f9eac"))
			for x in range(920,1340,40):c.ink([[x,669],[x+1,890]],Color("#687c8e"),4)
		c.ink([[841,261],[840,894]],Color("#867b7a"),7)
		c.patch([[806,241],[874,239],[862,299],[817,300],[806,241]],Color("#e5d7b8"))
	else:
		c.patch([[0,0],[1920,0],[1920,894],[0,894],[0,0]],Color("#e5d9cf" if kind=="home_curtain" else "#dedfd5"))
		c.patch([[0,894],[1920,894],[1920,1400],[0,1400],[0,894]],Color("#c9bab1"))
		c.ink([[0,894],[1920,894]],Color("#938789"),3)
		if kind=="home_curtain":
			c.patch([[965,105],[1538,102],[1543,665],[961,668],[965,105]],Color("#f4e8d3"))
			c.patch([[993,131],[1513,130],[1515,641],[990,643],[993,131]],Color("#7e899f"))
			c.ink([[1254,131],[1254,641]],Color("#b7b0a4"),5)
			c.ink([[991,393],[1515,392]],Color("#b7b0a4"),4)
			c.patch([[974,119],[1094,121],[1063,652],[973,655],[974,119]],Color("#b59aa7"))
			c.patch([[1409,121],[1531,117],[1539,653],[1431,651],[1409,121]],Color("#b59aa7"))
			c.ink([[944,93],[1566,92]],Color("#6e5c67"),6)
		else:
			c.patch([[1040,161],[1560,159],[1564,503],[1036,505],[1040,161]],Color("#edf0e5"))
			for y in [226,277]:c.ink([[1120,y],[1480,y-1]],Color("#9ca598"),3)
			c.patch([[1670,177],[1872,176],[1876,894],[1668,894],[1670,177]],Color("#b5a896"))
			c.ink([[1816,526],[1838,526]],Color("#716b67"),5)
