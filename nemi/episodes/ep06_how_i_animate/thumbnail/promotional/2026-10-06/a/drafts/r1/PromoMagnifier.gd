extends Node2D
## The nuisance is a promotional metaphor for the recorded jittering hair pixel.
## Ordered children keep all lens fills behind the illustration and rim.
const I = preload("res://tools/storytime/ThumbnailIllustration.gd")
const Assets = preload("res://common/storytime/ProfileAssets.gd")
func _ready() -> void:
	var ink: String = Assets.profile("nemi").ink
	I.rounded(self,[[-11,17],[14,16],[29,-8],[-63,-105],[-86,-86]],"#526174",ink,4.0,.08)
	I.oval(self,-156,-166,130,122,"#fff7de",ink,9.0)
	I.oval(self,-156,-166,119,111,"#d3edf0", "#9cbac6",3.0)
	# Cartoon speck with one unruly hair and grumpy expression, not another Nemi.
	I.rounded(self,[[-185,-186],[-164,-212],[-139,-205],[-113,-179],[-131,-135],[-179,-134],[-197,-160]],"#db6f63",ink,4.0,.13)
	I.curve(self,[[-172,-198],[-178,-223],[-155,-233],[-162,-250]],ink,4.5)
	I.oval(self,-174,-173,10,14,"#fff5e0",ink,2.5)
	I.oval(self,-142,-169,10,14,"#fff5e0",ink,2.5)
	I.oval(self,-168,-172,3,6,ink)
	I.oval(self,-137,-168,3,6,ink)
	I.stroke(self,[[-186,-188],[-165,-185]],ink,3.0)
	I.stroke(self,[[-149,-183],[-129,-187]],ink,3.0)
	I.curve(self,[[-169,-143],[-154,-149],[-139,-142]],ink,3.0)
	I.stroke(self,[[-187,-152],[-202,-134],[-222,-135]],ink,4.0)
	I.stroke(self,[[-124,-154],[-103,-139],[-87,-147]],ink,4.0)
	I.stroke(self,[[-170,-135],[-181,-115]],ink,4.0)
	I.stroke(self,[[-145,-135],[-133,-115]],ink,4.0)
	I.curve(self,[[-247,-184],[-240,-213],[-219,-238]],"#ffffff",7.0)
	I.stroke(self,[[-242,-157],[-240,-169]],"#ffffff",7.0)
	# Rim/connector remain behind grip overlay, with no lens crossing Nemi's face.
	I.curve(self,[[-77,-69],[-45,-45],[-14,-7]],"#8da7b5",5.0)
