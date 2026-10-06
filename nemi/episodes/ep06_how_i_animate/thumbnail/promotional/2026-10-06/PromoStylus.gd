extends Node2D
## New comic-scale stylus. Origin is its grip, driven by the canonical wrist.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
func _ready() -> void:
	var ink: String = Assets.profile("nemi").ink
	I.rounded(self,[[-10,-108],[10,-110],[17,40],[10,64],[0,85],[-12,65],[-16,43]],"#343d57",ink,3.8,.06)
	I.shape(self,[[-16,29],[17,28],[13,48],[-13,50]],"#f29b7b",ink,2.8)
	I.shape(self,[[-12,64],[0,85],[10,64]],"#e9d6b7",ink,3.0)
	I.shape(self,[[-4,78],[0,85],[4,78]],ink)
	I.curve(self,[[-6,-97],[-3,-52],[-3,-15]],"#a6c9d1",3.0)
	I.rounded(self,[[7,-61],[13,-58],[13,-30],[8,-31]],"#8ebbc1",ink,2.0)
