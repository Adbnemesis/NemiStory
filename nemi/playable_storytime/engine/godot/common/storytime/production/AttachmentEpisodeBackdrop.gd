extends RefCounted
## EP15's home and unnamed city: paper, quiet washes, no saturated wall/road blocks.
const KINDS=["attachment_home","attachment_city"]
static func draw_set(c: Node2D,kind: String) -> void:
	var ink=Color("#79646e")
	var pale=Color("#faf7f2")
	var soft=Color("#b6a79e")
	c.draw_rect(Rect2(-3000,-3000,8000,8000),pale)
	if kind=="attachment_home":
		c.patch([[-1000,894],[3000,894],[3000,2000],[-1000,2000],[-1000,894]],Color("#f2ebe0"),2)
		c.ink([[-1000,894],[802,892],[3000,894]],ink,3)
		# A recognisable window, side table and drawing desk anchor the room.
		c.patch([[178,203],[512,208],[515,495],[174,490],[178,203]],Color("#eaf0ee"),3)
		c.ink([[342,208],[345,491]],ink,3)
		c.ink([[177,351],[514,354]],ink,2.5)
		c.ink([[160,501],[529,505]],ink,5)
		c.ink([[188,456],[250,430],[305,452]],Color("#c4d0c6"),3)
		c.ink([[364,447],[417,419],[502,447]],Color("#c4d0c6"),3)
		c.patch([[146,690],[419,687],[426,709],[141,714],[146,690]],Color("#e9ddcc"),3)
		for x in [170,396]:c.ink([[x,714],[x+2,894]],ink,4)
		c.patch([[205,665],[306,664],[319,688],[195,690],[205,665]],Color("#eee5d9"),2)
		# A lamp base and shade, held scenery rather than a live accent.
		c.ink([[255,664],[253,577]],soft,5)
		c.patch([[211,527],[292,527],[314,580],[191,580],[211,527]],Color("#f1e4cd"),2.5)
		c.patch([[1209,643],[1770,638],[1775,664],[1205,669],[1209,643]],Color("#eadfce"),3)
		for x in [1241,1736]:c.ink([[x,669],[x+2,894]],ink,4)
		c.patch([[1320,614],[1510,615],[1544,642],[1296,645],[1320,614]],Color("#fffdf8"),2)
		c.ink([[1361,626],[1465,626]],Color("#cdbab3"),2)
		c.ink([[1523,617],[1605,628]],Color("#ad5e69"),4)
		c.patch([[1661,587],[1715,586],[1710,636],[1667,637],[1661,587]],Color("#eee6da"),2.5)
		for p in [[[1679,589],[1670,547]],[[1691,588],[1696,542]],[[1702,589],[1716,556]]]:c.ink(p,soft,3)
		# Stool is grounded and kept behind the right-side illustration area.
		c.ink([[1350,710],[1599,708]],ink,8)
		for x in [1373,1576]:c.ink([[x,712],[x-3,894]],ink,3)
		return
	# An unnamed city. No landmark, signage, address or factual city is invented.
	c.patch([[-1000,960],[3000,960],[3000,2000],[-1000,2000],[-1000,960]],Color("#f1eee8"),2)
	c.patch([[-1000,756],[3000,756],[3000,960],[-1000,960],[-1000,756]],Color("#f5efe5"),2)
	for b in [[-40,211,385,545],[370,153,388,603],[1388,224,266,532],[1683,114,306,642]]:
		var x: float=b[0];var y: float=b[1];var w: float=b[2];var h: float=b[3]
		c.patch([[x,y],[x+w,y-4],[x+w+3,y+h],[x-2,y+h],[x,y]],Color("#faf5ee"),2.5)
		c.ink([[x-7,y-5],[x+w+5,y-9]],soft,5)
		for row in range(2):
			for column in range(2):
				var wx=x+40+column*(w-95)/2;var wy=y+70+row*131
				c.patch([[wx,wy],[wx+58,wy-1],[wx+60,wy+81],[wx-2,wy+83],[wx,wy]],Color("#edf1ee"),2)
		c.patch([[x+w*.5-35,y+h-130],[x+w*.5+38,y+h-130],[x+w*.5+39,y+h],[x+w*.5-36,y+h],[x+w*.5-35,y+h-130]],Color("#ede5da"),2)
	# Low greenery and a simple park bench support a plausible visit location.
	c.ink([[799,750],[810,709],[832,691],[857,708],[889,687],[914,709],[943,697],[966,725],[968,752]],Color("#becabb"),18)
	for y in [590,625,660]:c.ink([[1510,y],[1971,y-3]],Color("#bfa68e"),13)
	c.ink([[1500,710],[1983,707]],ink,9)
	for x in [1530,1952]:
		c.ink([[x,570],[x,710],[x+5,894]],ink,5)
	c.ink([[1477,684],[1528,683]],ink,5)
	c.ink([[1955,679],[2009,678]],ink,5)
	c.ink([[-1000,894],[3000,894]],Color("#c8bcb0"),2.5)
	c.ink([[-1000,960],[3000,960]],soft,3)
	for x in [90,611,1830]:c.ink([[x,759],[x-38,958]],Color("#ded4c8"),1.7)
	for x in [100,700,1300,1900]:c.ink([[x,1110],[x+195,1110]],Color("#dbd5ca"),6)
