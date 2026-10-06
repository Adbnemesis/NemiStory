extends Node2D
## New foreshortened cartoon film camera. Canonical wrist owns the grip.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
func _ready() -> void:
	var ink: String = Assets.profile("nemi").ink
	I.rounded(self,[[-38,-50],[79,-69],[102,-48],[102,28],[-41,33]],"#667485",ink,4.0,.05)
	I.shape(self,[[-30,-45],[81,-60],[80,-36],[-29,-21]],"#8b9da8")
	I.shape(self,[[77,-46],[145,-73],[145,47],[78,27]],"#263d53",ink,4.0)
	I.oval(self,147,-13,26,64,"#33495b",ink,4.0)
	I.oval(self,153,-13,19,47,"#88bdc3",ink,3.0)
	I.oval(self,155,-13,12,29,"#375b77",ink,2.0)
	I.curve(self,[[158,-45],[164,-22],[163,-6]],"#e1f6e4",3.5)
	I.oval(self,-12,-74,37,36,"#7f99a3",ink,3.5)
	I.oval(self,62,-86,39,37,"#7f99a3",ink,3.5)
	for p in [[-12,-74],[62,-86]]:
		var x: float = float(p[0])
		var y: float = float(p[1])
		I.oval(self,x,y,9,9,"#354657",ink,2.0)
		I.oval(self,x-19,y-10,6,6,"#c9d4cd")
		I.oval(self,x+16,y-12,6,6,"#c9d4cd")
		I.oval(self,x,y+20,6,6,"#c9d4cd")
	I.rounded(self,[[-10,7],[12,7],[15,46],[-4,53],[-15,34]],"#576575",ink,3.0,.06)
	I.shape(self,[[26,-16],[57,-22],[57,9],[26,12]],"#df7375",ink,2.5)
