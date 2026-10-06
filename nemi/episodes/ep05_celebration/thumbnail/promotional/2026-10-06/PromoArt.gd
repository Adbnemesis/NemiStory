extends RefCounted
## Original community-wave and curtain-reveal illustration, not literal crowds.
const H = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Profiles = preload("res://common/storytime/ProfileAssets.gd")

static func viewer(parent: Node2D, x: float, y: float, s: float, color: String, ink: String, reaching: bool=false) -> void:
	var group: Node2D=Node2D.new()
	group.position=Vector2(x,y)
	group.scale=Vector2.ONE*s
	parent.add_child(group)
	H.oval(group,0,-37,23,25,color,ink,3.0)
	H.rounded(group,[[-20,-10],[20,-10],[25,38],[-24,38]],color,ink,3.0,.12)
	H.stroke(group,[[-12,37],[-16,67]],color,12.0)
	H.stroke(group,[[12,37],[18,67]],color,12.0)
	if reaching:
		H.curve(group,[[-17,3],[-33,-21],[-41,-38]],color,11.0)
		H.curve(group,[[17,3],[38,-20],[46,-37]],color,11.0)
	else:
		H.curve(group,[[-18,3],[-37,32],[-45,10]],color,10.0)
		H.curve(group,[[18,3],[35,-17],[43,-25]],color,10.0)

static func card(parent: Node2D, x: float, y: float, s: float, angle: float, ink: String) -> void:
	var group: Node2D=Node2D.new()
	group.position=Vector2(x,y)
	group.scale=Vector2.ONE*s
	group.rotation_degrees=angle
	parent.add_child(group)
	H.rounded(group,[[-102,-65],[103,-67],[112,60],[49,62],[29,97],[11,64],[-103,67]],"#fff1d9",ink,5.0,.06)
	H.heart(group,0,4,41,"#e6798d",ink,3.0)

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author=="nemi" and variant in ["a","b"])
	var node: Node2D=Node2D.new()
	var ink: String=Profiles.profile(author).ink
	match part:
		"background":
			if variant=="a":
				H.shape(node,[[0,0],[1920,0],[1920,1080],[0,1080]],"#325d65")
				H.shape(node,[[0,875],[1920,453],[1920,1080],[0,1080]],"#679e9c")
				H.heart(node,603,687,615,"#cf6987",ink,8.0)
				H.heart(node,603,655,550,"#eb92a0", "",0.0)
				H.curve(node,[[0,919],[348,935],[744,843],[1070,801],[1448,910],[1920,710]],"#214f5b",105.0)
				H.curve(node,[[0,900],[348,916],[744,824],[1070,782],[1448,891],[1920,691]],"#f5c783",80.0)
				# Representative community silhouettes express people, not a count grid.
				for i in range(7):
					var x: float=135.0+float(i)*123.0
					var y: float=676.0+sin(float(i)*.8)*110.0
					viewer(node,x,y,.84+float(i%3)*.12,"#f6dcab",ink,true)
				for i in range(6):
					viewer(node,181.0+float(i)*145.0,877.0+sin(float(i)*.65)*37.0,.9,"#e6b97b",ink,false)
				card(node,971,282,.74,-15.0,ink)
				card(node,1726,101,1.1,13.0,ink)
				card(node,1828,655,.55,-20.0,ink)
				H.stroke(node,[[95,500],[65,460]],"#f4d9a0",11.0)
				H.stroke(node,[[1819,422],[1862,377]],"#f4d9a0",10.0)
			else:
				H.shape(node,[[0,0],[1920,0],[1920,1080],[0,1080]],"#eec993")
				H.shape(node,[[533,0],[1558,0],[1866,1080],[294,1080]],"#fff0ce")
				H.oval(node,1215,1020,636,136,"#c89a93")
				H.shape(node,[[0,0],[964,0],[777,214],[539,360],[218,831],[210,1080],[0,1080]],"#b84962",ink,7.0)
				H.shape(node,[[1514,0],[1920,0],[1920,1080],[1822,1080],[1703,604],[1650,213]],"#b84962",ink,7.0)
				H.curve(node,[[380,0],[278,312],[92,686]],"#df8292",23.0)
				H.curve(node,[[624,0],[434,278],[247,557]],"#903552",18.0)
				H.curve(node,[[1771,0],[1779,371],[1882,696]],"#da7786",20.0)
				H.curve(node,[[0,56],[333,133],[601,88]],"#eab36f",12.0)
		"foreground":
			if variant=="a":
				H.rounded(node,[[-42,1028],[173,921],[510,964],[800,869],[1067,912],[1370,1001],[1675,892],[1977,928],[1951,1138],[-55,1115]],"#edb571",ink,7.0,.12)
				viewer(node,161,1001,1.17,"#fff0ce",ink,true)
				viewer(node,436,1040,1.25,"#eb889e",ink,true)
				viewer(node,726,939,1.03,"#fff0ce",ink,true)
				card(node,1501,991,1.01,9.0,ink)
				H.curve(node,[[803,1080],[1126,1029],[1351,959]],"#ffe3b2",11.0)
			else:
				# New viewers pull a visible continuous rope at curtain tie height.
				H.curve(node,[[145,534],[274,574],[476,790],[797,964]],"#8c6659",8.0)
				H.curve(node,[[1778,569],[1763,774],[1608,1002]],"#8c6659",8.0)
				H.shape(node,[[0,964],[928,982],[1657,1045],[1920,950],[1920,1080],[0,1080]],"#679994",ink,5.0)
				for i in range(5):
					var x: float=300.0+float(i)*98.0
					var y: float=891.0+float(i)*20.0
					viewer(node,x,y,.73+float(i)*.025,"#456f76",ink,false)
					H.curve(node,[[x+14,y-1],[x+36,y-52],[x+63,y-53]],"#456f76",9.0)
				for i in range(3): viewer(node,1580.0+float(i)*107.0,1000.0-float(i)*20.0,.8,"#456f76",ink,true)
				H.heart(node,992,984,49,"#db7890",ink,4.0)
		"burst":
			if variant=="a":
				H.rounded(node,[[49,45],[711,39],[773,192],[701,340],[52,345],[-1,201]],"#fff0d0",ink,6.0,.045)
			else:
				H.rounded(node,[[358,91],[941,67],[969,425],[853,480],[791,547],[784,464],[327,455]],"#fff4df",ink,5.0,.04)
		_:
			assert(false,"Unknown promotional illustration part")
	return node
