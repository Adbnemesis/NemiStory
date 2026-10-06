extends Node2D
## Original enlarged organic dryer illustration. Wrist origin is its handle top.
## Static comic hot air only: no flames, animation, randomness or new rig.
const Art = preload("res://nemi/episodes/ep03_scolded/thumbnail/promotional/2026-10-06/PromoArt.gd")
const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")

func _ready() -> void:
	var node = Drawing.new()
	var ink: String = Assets.profile("nemi").ink
	# Broad rounded barrel, curved heel and coral enamel vent band.
	Art.rounded(node,[[-55,-43],[-38,-58],[17,-55],[35,-39],[41,-16],[22,-3],[-43,-12]],"#566783",ink,3.2)
	Art.rounded(node,[[20,-51],[37,-34],[41,-14],[28,-4],[24,-26]],"#d76153",ink,2.6)
	Art.patch(node,[[-55,-43],[-76,-36],[-78,-16],[-49,-12]],"#283b51",ink,3.2)
	Art.line(node,[[-74,-34],[-75,-17]],"#8ac4ce",2.2)
	Art.rounded(node,[[-10,-9],[7,-5],[15,31],[2,40],[-10,33],[-15,5]],"#566783",ink,3.0)
	Art.line(node,[[-7,30],[4,34]],"#9aacbd",2.0)
	Art.line(node,[[1,39],[15,56],[3,72],[19,89],[5,103]],ink,2.0)
	Art.curve_line(node,[[-37,-45],[-14,-47],[3,-45]],"#c0d5df",4.0)
	for y in [-36,-29,-22]: Art.line(node,[[25,y],[33,y+2]],"#283b51",2.2)
	# A graphic flowing hot-air ribbon, visibly directed from nozzle to ice.
	Art.patch(node,[[-81,-35],[-116,-56],[-151,-62],[-190,-51],[-194,-27],[-158,-15],[-122,-19],[-81,-15]],"#f37a59dd")
	Art.rounded(node,[[-82,-30],[-114,-37],[-142,-48],[-181,-36],[-201,-13],[-164,-15],[-135,-27],[-101,-22]],"#ffd070", "", 0.0)
	Art.curve_line(node,[[-82,-35],[-111,-41],[-143,-36],[-177,-26]],"#fff3bf",4.8)
	Art.curve_line(node,[[-82,-17],[-112,-9],[-144,-16],[-184,-3]],"#d65c4c",3.5)
	Art.patch(node,[[-207,-16],[-217,-25],[-209,-43],[-199,-30]],"#ffe7aa")
	Art.patch(node,[[-202,-4],[-225,4],[-215,13],[-201,7]],"#f9ab68")
	node.prepare()
	node.progress = 1.0
	add_child(node)
