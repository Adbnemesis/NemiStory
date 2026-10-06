extends "res://tools/storytime/ThumbnailStoryArt.gd"
## Held kitchen staging only. Production characters/props remain separate nodes.
static func make(author: String, variant: String, part: String) -> Node2D:
	assert(author == "nemi")
	assert(variant in ["a", "b"])
	var node = Drawing.new()
	var ink: String = Assets.profile(author).ink
	if part == "background":
		# Small location cues support the single caught-in-the-act event.
		patch(node, [[0,415],[785,425],[790,800],[0,797]], "#ece8dc")
		for y in [535,650,766]:
			line(node, [[0,y],[790,y+7]], "#c6bfb0", 3.0)
		for x in [110,330,550,770]:
			line(node, [[x,423],[x+5,803]], "#c6bfb0", 3.0)
		# A real opening doorway, with the viewer's title providing the mother.
		var dx := 1515.0 if variant == "a" else 1540.0
		var dy := 330.0 if variant == "a" else 205.0
		patch(node, [[dx,dy],[1878,dy-7],[1888,1030],[dx-7,1030]], "#8199a1", ink, 5.0)
		patch(node, [[dx+22,dy+25],[1854,dy+21],[1861,1010],[dx+15,1015]], "#bed0ce")
		patch(node, [[dx+155,dy+6],[1878,dy-7],[1888,1030],[dx+162,972]], "#d1ac89", ink, 5.0)
		line(node, [[dx+186,dy+80],[1850,dy+63],[1857,942],[dx+191,901],[dx+186,dy+80]], "#b48d70", 3.0)
		ellipse(node, dx+192, 668 if variant == "a" else 635, 8, 11, "#635546")
		# Faint upper cabinet edge, away from the headline and eyes.
		line(node, [[0,360],[755,367]], "#bcb5a7", 4.0)
	elif part == "foreground":
		# Perspective counter plane below hands. Its edge covers the lower torso.
		patch(node, [[0,790],[1490,828],[1545,909],[0,870]], "#ddc9ac", ink, 5.0)
		patch(node, [[0,870],[1545,909],[1552,1080],[0,1080]], "#c4ac8d", ink, 5.0)
		line(node, [[0,881],[1545,920]], "#f5e5cb", 10.0)
		line(node, [[980,941],[985,1080]], "#aa9279", 4.0)
		line(node, [[80,961],[825,980]], "#aa9279", 3.0)
	else:
		assert(false, "Unknown held kitchen layer")
	node.prepare()
	node.progress = 1.0
	return node
