extends RefCounted
## Held cab/highway supporting scenery in Nemi's actual production ink.
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
const Editorial = preload("res://tools/storytime/ThumbnailStoryArt.gd")

static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author == "nemi")
	assert(variant in ["a", "b"])
	assert(part in ["background", "foreground"])
	var node = Drawing.new()
	var ink: String = Assets.profile(author).ink
	if variant == "a" and part == "background":
		# Quiet daylight highway. The rear contact is the whole promise.
		Editorial.patch(node, [[0,410],[500,345],[1050,397],[1480,350],[1920,415],[1920,610],[0,610]], "#b7c6b3")
		Editorial.line(node, [[0,560],[1920,560]], "#8b9b94", 6.0)
		Editorial.patch(node, [[0,610],[1920,610],[1920,1080],[0,1080]], "#858e95")
		Editorial.line(node, [[0,660],[1920,660]], "#e2e5dc", 9.0)
		for x in [70,570,1070,1570]:
			Editorial.line(node, [[x,1045],[x+255,1045]], "#eee1c2", 11.0)
	elif variant == "a" and part == "foreground":
		# Hide the passenger below the car, before original car body/wheels.
		Editorial.patch(node, [[0,944],[1920,944],[1920,1080],[0,1080]], "#858e95")
		for x in [70,570,1070,1570]:
			Editorial.line(node, [[x,1045],[x+255,1045]], "#eee1c2", 11.0)
	elif variant == "b" and part == "background":
		# Interior cab surfaces and a real roadside view through a large window.
		Editorial.patch(node, [[0,0],[1920,0],[1920,1080],[0,1080]], "#bdc8c7")
		Editorial.patch(node, [[0,36],[1050,14],[1105,667],[0,697]], "#d5dede", ink, 6.0)
		Editorial.patch(node, [[0,82],[997,62],[1035,597],[0,621]], "#dce5e4")
		Editorial.patch(node, [[0,350],[270,286],[635,335],[1020,302],[1035,535],[0,561]], "#b7c5b2")
		Editorial.patch(node, [[0,476],[1026,462],[1035,597],[0,621]], "#909a9e")
		Editorial.line(node, [[0,525],[1030,505]], "#e7dfc8", 7.0)
		Editorial.patch(node, [[1077,0],[1170,0],[1260,762],[1135,790]], "#8c9d9d", ink, 5.0)
		Editorial.patch(node, [[840,863],[1920,824],[1920,1080],[802,1080]], "#879d99", ink, 5.0)
		Editorial.line(node, [[912,924],[1880,891]], "#526e6b", 4.0)
	elif variant == "b" and part == "foreground":
		# Bottom door/seat edge crops seated legs without touching the face.
		Editorial.patch(node, [[0,1020],[1090,1020],[1205,1080],[0,1080]], "#809795", ink, 4.0)
	node.prepare()
	node.progress = 1.0
	return node
