extends Node2D
## New enormous creator invitation. Origin is the handle grip.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
func _ready() -> void:
	var ink: String = Assets.profile("nemi").ink
	I.rounded(self,[[-12,-26],[12,-25],[13,22],[0,32],[-12,21]],"#607582",ink,3.5,.05)
	I.shape(self,[[-22,-59],[132,-105],[132,27],[-22,-19]],"#eb776e",ink,4.0)
	I.shape(self,[[-16,-52],[118,-93],[118,-69],[-16,-30]],"#ffccad")
	I.oval(self,132,-39,25,68,"#ae4d64",ink,4.0)
	I.oval(self,137,-39,15,55,"#382f4d",ink,3.0)
	I.rounded(self,[[-32,-66],[-11,-65],[-11,-14],[-33,-16]],"#718995",ink,3.0,.07)
	# One unlettered play emblem is part of the invented object, not a caption.
	I.shape(self,[[26,-62],[70,-46],[27,-29]],"#fff1d3",ink,2.2)
	I.curve(self,[[173,-78],[192,-45],[182,-11]],"#e99a59",5.0)
	I.curve(self,[[195,-93],[217,-48],[208,0]],"#e99a59",3.8)
