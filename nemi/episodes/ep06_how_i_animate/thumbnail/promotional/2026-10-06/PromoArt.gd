extends RefCounted
## Two original process metaphors. Canonical Nemi is supplied by the compositor.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")

static func key(node: Node2D, x: float, y: float, size: float, col: String, ink: String) -> void:
	I.rounded(node,[[x,y-size],[x+size,y],[x,y+size],[x-size,y]],col,ink,4.0,.05)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author == "nemi" and variant in ["a","b"])
	var node: Node2D = Node2D.new()
	var ink: String = Assets.profile(author).ink
	match part:
		"background":
			if variant == "a":
				# A physical loop with converging timeline rails, not interface text.
				I.shape(node,[[1110,0],[1920,0],[1920,1080],[1700,1080],[1290,545]],"#fcad8c")
				I.curve(node,[[122,885],[479,767],[979,660],[1477,595],[1652,356],[1520,175],[1240,228],[1139,411],[1337,684],[1815,913]],ink,187.0)
				I.curve(node,[[122,885],[479,767],[979,660],[1477,595],[1652,356],[1520,175],[1240,228],[1139,411],[1337,684],[1815,913]],"#2696a4",170.0)
				I.curve(node,[[132,869],[487,752],[971,646],[1468,579],[1637,354],[1509,190],[1254,241],[1158,412],[1352,669],[1825,897]],"#9bdde1",12.0)
				I.curve(node,[[121,918],[480,796],[988,688],[1493,626],[1682,364],[1529,142],[1216,199],[1109,406],[1310,712],[1794,944]],"#174e64",7.0)
				for p in [[1287,230],[1511,211],[1609,374],[1464,571],[1207,640],[942,674],[1223,552],[1405,730]]:
					key(node,float(p[0]),float(p[1]),27.0,"#ffd263",ink)
				I.stroke(node,[[1789,172],[1871,140]],"#fff1d6",12.0)
				I.stroke(node,[[1787,254],[1900,240]],"#fff1d6",8.0)
			else:
				# Sketch sheet zoomed beyond its frame: one speck takes over the page.
				I.shape(node,[[40,44],[1164,28],[1261,1050],[0,1075]],"#426675",ink,7.0)
				I.shape(node,[[68,78],[1122,61],[1217,1010],[20,1039]],"#f5e9d6",ink,5.0)
				I.shape(node,[[138,161],[803,95],[941,446],[247,484]],"#e8d4d6")
				I.stroke(node,[[76,892],[371,856]],"#cbafa9",12.0)
				I.stroke(node,[[81,954],[426,913]],"#cbafa9",12.0)
				I.curve(node,[[1160,570],[1178,385],[1316,331]],"#dbc5d7",15.0)
				I.curve(node,[[1240,700],[1260,576],[1315,542]],"#dbc5d7",9.0)
		"foreground":
			assert(variant == "a")
			# Enlarged rail sweeps below her hands; never across the face.
			I.curve(node,[[-140,1227],[236,998],[689,942],[1174,1018],[1740,1195],[2000,1256]],ink,200.0)
			I.curve(node,[[-140,1227],[236,998],[689,942],[1174,1018],[1740,1195],[2000,1256]],"#176b81",181.0)
			I.curve(node,[[-140,1169],[236,945],[689,889],[1174,965],[1740,1142],[2000,1203]],"#85d2d9",12.0)
			for p in [[217,1006],[508,958],[877,971],[1214,1040]]:
				key(node,float(p[0]),float(p[1]),40.0,"#ffcb62",ink)
		"burst":
			if variant == "a":
				I.burst(node,[[46,65],[185,71],[218,20],[270,63],[615,50],[705,91],[720,228],[680,274],[685,341],[508,340],[425,379],[368,335],[83,343],[90,277],[23,237]],"#fff4da",ink,6.0)
			else:
				I.shape(node,[[1238,47],[1825,35],[1873,305],[1600,321],[1482,383],[1502,312],[1247,304]],"#fff4da",ink,6.0)
		_:
			assert(false,"Unknown original process promotional part")
	return node
