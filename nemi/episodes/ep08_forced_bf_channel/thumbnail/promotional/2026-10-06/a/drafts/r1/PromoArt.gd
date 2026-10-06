extends RefCounted
## Original persuasion/recording metaphors. Both main characters stay canonical.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author == "nemi" and variant in ["a","b"])
	var node: Node2D = Node2D.new()
	var ink: String = Assets.profile(author).ink
	match part:
		"background":
			if variant == "a":
				# Expanding invitation, connecting the megaphone and reluctant face.
				I.shape(node,[[812,874],[1920,151],[1920,1080],[907,965]],"#ffdda0")
				I.shape(node,[[870,846],[1815,360],[1920,515],[945,924]],"#fff2cb")
				I.shape(node,[[0,948],[725,893],[970,1080],[0,1080]],"#689e97")
				I.curve(node,[[1022,768],[1204,620],[1432,542]],"#f0b65d",12.0)
				I.curve(node,[[1115,862],[1363,787],[1577,780]],"#f0b65d",8.0)
				I.stroke(node,[[132,206],[80,139]],"#fff0d8",12.0)
				I.stroke(node,[[237,118],[225,42]],"#fff0d8",8.0)
			else:
				# A physical stage of cartoon recording, not a literal movie set.
				I.shape(node,[[1300,-160],[1920,-160],[1880,1080],[816,1080]],"#fce5b3")
				I.shape(node,[[1427,-110],[1661,-110],[1703,1056],[1033,1056]],"#fff3d1")
				I.shape(node,[[0,1017],[1044,890],[1920,987],[1920,1080],[0,1080]],"#2c3b51")
				I.oval(node,1330,1020,459,163,"#422c45",ink,8.0)
				I.oval(node,1330,991,459,163,"#c74f64",ink,8.0)
				I.oval(node,1330,969,388,126,"#f57779",ink,6.0)
				I.curve(node,[[1002,969],[1177,873],[1401,855],[1603,924]],"#ffd2b6",12.0)
				I.stroke(node,[[1804,488],[1846,458]],"#fdbfa9",9.0)
				I.stroke(node,[[1827,574],[1896,572]],"#fdbfa9",7.0)
		"burst":
			if variant == "a":
				I.shape(node,[[1051,55],[1829,36],[1876,239],[1701,276],[1463,270],[1245,348],[1270,272],[1063,278]],"#fff4da",ink,6.0)
			else:
				I.shape(node,[[874,42],[1682,35],[1719,255],[1556,300],[1292,271],[1197,364],[1207,279],[893,277]],"#fff4da",ink,6.0)
		_:
			assert(false,"Unknown original channel promotional part")
	return node
