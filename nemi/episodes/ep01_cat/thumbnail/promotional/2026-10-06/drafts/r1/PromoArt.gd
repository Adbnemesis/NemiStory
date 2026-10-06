extends RefCounted
## Rescue intimacy and parental-refusal metaphor. Neeko/Nemi rigs unchanged.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Profiles = preload("res://common/storytime/ProfileAssets.gd")

static func make(author: String,variant: String,part: String) -> Node2D:
	assert(author=="nemi")
	var n: Node2D=Node2D.new()
	var ink: String=Profiles.profile(author).ink
	if part=="background":
		if variant=="a":
			# Care is a warm pool amid stylised damp exterior, not a death scene.
			I.shape(n,[[0,890],[1920,782],[1920,1080],[0,1080]],"#537779")
			I.oval(n,1183,690,664,624,"#b5bca0")
			I.oval(n,1183,690,532,512,"#e3ce9d")
			I.oval(n,1183,690,423,412,"#f9ddb0")
			for raw in [[[116,54],[67,163]],[[345,30],[305,120]],[[594,55],[562,139]],[[80,498],[36,589]],[[1674,384],[1635,481]],[[1816,516],[1774,611]],[[1840,168],[1797,270]],[[461,754],[420,848]]]:I.stroke(n,raw,"#90b4b4",7)
			I.oval(n,267,1009,320,39,"#88a7a0")
			# New perspective box back and flaps, oversized like a protective nest.
			I.shape(n,[[647,855],[1051,711],[1672,749],[1732,1005],[680,1052]],"#a57b55",ink,8)
			I.shape(n,[[1051,711],[1093,649],[1746,693],[1672,749]],"#dfbb83",ink,7)
			I.shape(n,[[647,855],[500,770],[883,650],[1051,711]],"#d4ac76",ink,7)
			I.burst(n,[[1103,34],[1853,32],[1884,264],[1497,290],[1450,351],[1419,283],[1097,266]],"#fff0d2",ink,6)
		else:
			# Warm possible home glimpsed beyond a looming icon-only refusal barrier.
			I.shape(n,[[942,0],[1920,0],[1920,1080],[1040,1080]],"#efc39b")
			I.shape(n,[[1138,139],[1807,204],[1807,949],[1112,990]],"#ffe7bf",ink,6)
			I.oval(n,1484,727,470,477,"#fff1cf")
			I.shape(n,[[-100,-50],[1008,27],[1153,1064],[-100,1210]],"#35434a",ink,13)
			I.shape(n,[[34,80],[832,123],[925,989],[40,1068]],"#4e6265",ink,8)
			I.shape(n,[[101,156],[750,191],[781,507],[126,535]],"#607679",ink,5)
			I.shape(n,[[139,620],[801,600],[845,918],[166,970]],"#607679",ink,5)
			# Prohibition is purely pictorial: no small NO-PETS text.
			I.oval(n,478,355,176,169,"#edbbae",ink,8)
			I.rounded(n,[[391,393],[379,331],[386,287],[421,312],[471,302],[516,267],[546,317],[558,388],[530,426],[415,438]],"#5f646a",ink,6)
			I.oval(n,434,364,11,15,"#fff3d7")
			I.oval(n,502,358,11,15,"#fff3d7")
			I.stroke(n,[[360,235],[592,471]],"#bc554c",24)
			I.oval(n,915,632,39,44,"#d9b58a",ink,6)
			I.stroke(n,[[866,639],[930,639]],"#efd4ae",12)
			I.burst(n,[[1302,29],[1849,43],[1883,219],[1690,268],[1668,337],[1577,275],[1300,249]],"#fff0d1",ink,6)
	elif part=="foreground":
		if variant=="a":
			# Front flap hides the cat body without hiding the gentle face.
			I.shape(n,[[629,911],[1044,905],[1740,859],[1692,1194],[676,1225]],"#c89d68",ink,10)
			I.shape(n,[[629,911],[1044,905],[965,1094],[563,1102]],"#e8c18a",ink,7)
			I.shape(n,[[1044,905],[1740,859],[1798,1059],[1163,1104]],"#e3b77d",ink,7)
			I.stroke(n,[[1198,974],[1244,1080]],"#987b58",7)
			I.stroke(n,[[1498,941],[1546,1071]],"#987b58",6)
			I.oval(n,744,1058,57,26,"#a38060")
		else:
			# Lower edge can frame the intimate huddle without cutting either face.
			I.shape(n,[[1060,981],[1920,942],[1920,1080],[1068,1080]],"#caa983")
			I.stroke(n,[[1100,1007],[1728,997]],"#9b8474",6)
	else: assert(false,"Unknown rescue part")
	return n
