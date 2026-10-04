extends RefCounted
## Held classroom/corridor sets. World geometry stays fixed through reframes.
static func draw_set(canvas: Node2D,kind: String) -> void:
	canvas.draw_rect(Rect2(-3000,-3000,8000,8000),Color("#faf3e5"))
	canvas.patch([[0,0],[1920,0],[1920,894],[0,894],[0,0]],Color("#f3ecdf"))
	canvas.patch([[0,894],[1920,894],[1920,1400],[0,1400],[0,894]],Color("#e1d2b9"))
	canvas.ink([[0,894],[1920,894]],Color("#9a8e7d"),3)
	for x in [110,510,930,1350,1770]:canvas.ink([[x,895],[x-200,1300]],Color("#cbbca5"),1.3)
	canvas.ink([[0,1045],[1920,1044]],Color("#cbbca5"),1.3)
	if kind=="school_classroom":
		# Window, green teaching board, corridor door: a real place, not a title card.
		canvas.patch([[63,173],[392,169],[398,507],[60,511],[63,173]],Color("#d1e0df"))
		canvas.ink([[226,174],[228,507]],Color("#9caaa7"),5)
		canvas.ink([[67,342],[395,340]],Color("#9caaa7"),5)
		canvas.ink([[88,281],[157,248],[187,266],[199,281]],Color("#a7bdb3"),2)
		canvas.patch([[867,162],[1502,159],[1509,483],[864,488],[867,162]],Color("#739589"),3)
		canvas.ink([[875,478],[1504,474]],Color("#bba77d"),9)
		# Chalk lesson and simple diagram are background detail, not narration captions.
		canvas.ink([[929,235],[1083,233]],Color("#d9e2d0"),3)
		canvas.ink([[928,277],[1117,279]],Color("#d9e2d0"),2)
		canvas.ink([[931,320],[1074,321]],Color("#d9e2d0"),2)
		canvas.ink([[1228,348],[1311,227],[1410,348],[1228,348]],Color("#d9e2d0"),2)
		canvas.ink([[1289,258],[1359,285],[1311,333]],Color("#d9e2d0"),1.5)
		canvas.patch([[1660,231],[1854,230],[1860,894],[1656,894],[1660,231]],Color("#d5bda2"))
		canvas.patch([[1691,268],[1820,267],[1824,427],[1688,429],[1691,268]],Color("#c4d6d4"))
		canvas.ink([[1821,553],[1837,554]],Color("#81796f"),5)
		# Rear desks and chairs are purposefully smaller in perspective.
		for x in [780,1260]:
			canvas.patch([[x-104,567],[x+100,564],[x+106,578],[x-108,581],[x-104,567]],Color("#c4ae89"))
			canvas.ink([[x-83,579],[x-87,757]],Color("#8d8f83"),4)
			canvas.ink([[x+82,578],[x+88,757]],Color("#8d8f83"),4)
			canvas.patch([[x+29,523],[x+93,522],[x+95,565],[x+30,565],[x+29,523]],Color("#b3beb0"))
			canvas.ink([[x+47,581],[x+45,726]],Color("#8d8f83"),3)
	else:
		for x in [122,310,498,1010,1198,1386]:
			canvas.patch([[x,191],[x+162,189],[x+167,893],[x-3,893],[x,191]],Color("#adc0ba"))
			canvas.ink([[x+30,247],[x+130,247]],Color("#7e9792"),2)
			canvas.ink([[x+30,262],[x+130,262]],Color("#7e9792"),2)
			canvas.ink([[x+128,486],[x+129,520]],Color("#7e9792"),4)
		canvas.patch([[1640,254],[1850,251],[1855,893],[1637,893],[1640,254]],Color("#d5bda2"))
		canvas.patch([[1680,287],[1812,285],[1816,472],[1677,474],[1680,287]],Color("#d1e0df"))
