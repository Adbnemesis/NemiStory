extends RefCounted
## EP15 attachment evidence and warm metaphors, sampled by the shared ink clock.
const Drawing=preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile=preload("res://common/storytime/ProfileAssets.gd")
const KINDS=["attachment_invite","attachment_busy","attachment_reunion","attachment_messages","attachment_neeko","attachment_heart_thread","attachment_phone_rest"]

static func line(n: Node2D,raw: Array,col: Color,w: float=3.5,fill: Variant=null,smooth: bool=true) -> void:
	var pts=PackedVector2Array()
	for p in raw:pts.append(Vector2(p[0],p[1]))
	if fill!=null:n.fills.append({"poly":pts,"col":fill,"at":.88})
	n.stroke_list.append({"pts":pts,"col":col,"w":w,"smooth":smooth,"pause":.07,"pressure":PackedFloat32Array([.42,1,.8,.96,.38])})

static func wash(n: Node2D,raw: Array,col: Color) -> void:
	var pts=PackedVector2Array()
	for p in raw:pts.append(Vector2(p[0],p[1]))
	n.fills.append({"poly":pts,"col":col,"at":.88})

static func make(author: String,kind: String) -> Node2D:
	assert(author=="nemi","Attachment episode artwork is authored for Nemi's rounded pen.")
	var n=Drawing.new()
	var ink=Color(Profile.profile(author).ink)
	var rose=Color("#ad5e69")
	var paper=Color("#fffdf8")
	var muted=Color("#9b858d")
	match kind:
		"attachment_invite":
			# Hopeful outgoing invitation: anonymous screen evidence, no font labels.
			line(n,[[-129,-184],[-108,-197],[112,-191],[133,-171],[128,167],[109,188],[-111,193],[-133,173],[-129,-184]],ink,4,paper)
			line(n,[[-111,-148],[111,-143],[109,148],[-113,151],[-111,-148]],muted,2.2,null,false)
			line(n,[[-27,-171],[24,-170]],ink,3)
			line(n,[[-18,170],[21,170]],ink,3.5)
			line(n,[[-86,-113],[87,-112],[91,-26],[65,-8],[65,-28],[-87,-28],[-86,-113]],rose,3.2,Color("#f3e1dc"))
			line(n,[[-66,-86],[64,-84]],rose,3)
			line(n,[[-66,-63],[30,-62]],rose,3)
			# A little cup suggests the hoped-for meeting without claiming a venue.
			line(n,[[-27,43],[28,44],[22,85],[-18,84],[-27,43]],ink,3,Color("#efe4d4"))
			line(n,[[27,48],[43,50],[44,67],[25,72]],ink,3)
			line(n,[[-39,92],[43,92]],muted,2.5)
			line(n,[[-8,29],[-14,17],[-8,6]],rose,2.5)
		"attachment_busy":
			# Two separate replies; neither bubble supplies an invented identity.
			line(n,[[-219,-165],[100,-162],[108,-55],[-130,-52],[-169,-16],[-166,-52],[-220,-57],[-219,-165]],ink,3.5,paper)
			line(n,[[-180,-110],[-179,-128],[-160,-141],[-142,-131],[-137,-111],[-151,-93],[-170,-95],[-180,-110]],muted,2.8)
			line(n,[[-159,-132],[-159,-113],[-145,-104]],rose,3,null,false)
			line(n,[[-111,-125],[64,-124]],ink,3)
			line(n,[[-110,-92],[17,-91]],muted,2.5)
			line(n,[[-94,24],[218,20],[223,129],[177,134],[175,166],[140,136],[-92,139],[-94,24]],ink,3.5,Color("#f2ece5"))
			# A tiny closed calendar and shorter lines distinguish this reply.
			line(n,[[-60,53],[-12,51],[-10,105],[-61,106],[-60,53]],muted,2.5,null,false)
			line(n,[[-61,67],[-11,65]],muted,2)
			line(n,[[-50,43],[-49,59]],muted,3)
			line(n,[[-25,42],[-24,58]],muted,3)
			line(n,[[-47,80],[-24,94]],rose,2.5,null,false)
			line(n,[[-25,80],[-47,95]],rose,2.5,null,false)
			line(n,[[23,62],[180,60]],ink,3)
			line(n,[[23,96],[117,96]],muted,2.5)
		"attachment_reunion":
			# Imagined cafe vignette: two empty chairs are the story evidence.
			line(n,[[-210,-77],[-146,-78],[-139,64],[-211,66],[-210,-77]],ink,3.5,Color("#f3e8d9"))
			line(n,[[144,-76],[211,-74],[214,65],[142,63],[144,-76]],ink,3.5,Color("#f3e8d9"))
			for x in [-180,176]:
				line(n,[[x-41,70],[x+40,69],[x+47,85],[x-44,86],[x-41,70]],ink,3,Color("#eadaca"),false)
				line(n,[[x-32,86],[x-35,181]],ink,3.5,null,false)
				line(n,[[x+30,85],[x+34,181]],ink,3.5,null,false)
			line(n,[[-123,52],[-99,27],[-10,17],[92,26],[122,49],[100,73],[5,82],[-94,74],[-123,52]],ink,3.7,Color("#f4e8d9"))
			line(n,[[-84,79],[-83,182]],ink,3.5,null,false)
			line(n,[[83,79],[85,182]],ink,3.5,null,false)
			for x in [-50,52]:
				line(n,[[x-15,17],[x+15,17],[x+12,42],[x-10,42],[x-15,17]],rose,2.8,paper)
				line(n,[[x+15,23],[x+25,24],[x+24,35],[x+13,37]],rose,2.5)
			line(n,[[-1,-178],[0,-119]],muted,2.7,null,false)
			line(n,[[-58,-81],[-35,-113],[34,-114],[60,-82],[-58,-81]],muted,3,Color("#f0e6d7"))
		"attachment_messages":
			# Size contrast expresses unequal enthusiasm, without fake screenshots.
			line(n,[[-221,-177],[201,-172],[215,-151],[213,-5],[145,0],[144,36],[100,1],[-217,3],[-227,-19],[-221,-177]],rose,4,Color("#f3e1dc"))
			line(n,[[-183,-135],[171,-133]],rose,4)
			line(n,[[-182,-96],[158,-92]],rose,3.5)
			line(n,[[-183,-56],[179,-54]],rose,3.5)
			line(n,[[-182,-20],[45,-17]],rose,3.5)
			line(n,[[105,81],[212,78],[221,90],[219,144],[192,146],[191,168],[166,148],[105,149],[99,135],[105,81]],ink,3,paper)
			line(n,[[124,112],[186,113]],muted,3)
		"attachment_neeko":
			# Symbolic memory illustration, derived from the existing Neeko rig art.
			# No replacement rig or autonomous animal motion is introduced.
			var fur=Color("#fbf8f3");var ginger=Color("#c85a3a")
			var cat_ink=Color("#2b2623")
			line(n,[[-128,71],[-174,76],[-209,47],[-217,5],[-203,-15],[-185,-12],[-179,8],[-185,23],[-182,41],[-156,49],[-126,45]],cat_ink,3.5,fur)
			wash(n,[[-217,5],[-203,-15],[-185,-12],[-179,8],[-185,23],[-198,25]],ginger)
			# The hidden upper body edge is omitted beneath the head.
			line(n,[[-90,-10],[-130,10],[-151,53],[-143,112],[-100,137],[-9,145],[91,135],[133,113],[142,70],[125,23],[84,0]],cat_ink,3.8,fur)
			wash(n,[[-130,10],[-90,-10],[-45,0],[-34,42],[-97,60],[-143,53]],ginger)
			# Ear outlines terminate at the head, avoiding ink through the face.
			line(n,[[-91,-87],[-104,-174],[-56,-139],[-39,-119]],cat_ink,3.5,fur)
			line(n,[[37,-119],[70,-144],[104,-174],[96,-85]],cat_ink,3.5,fur)
			wash(n,[[-95,-153],[-66,-133],[-88,-104]],Color("#f5cdc6"))
			wash(n,[[90,-153],[65,-132],[88,-103]],Color("#f5cdc6"))
			line(n,[[-89,-89],[-66,-123],[-15,-134],[36,-126],[76,-106],[101,-65],[114,-35],[95,-18],[83,4],[38,30],[0,35],[-41,28],[-81,7],[-96,-17],[-114,-34],[-100,-59],[-89,-89]],cat_ink,3.8,fur)
			wash(n,[[-89,-89],[-66,-123],[-15,-134],[-13,-66],[-57,-38],[-101,-58]],ginger)
			for x in [-48,49]:
				line(n,[[x-19,-47],[x-11,-60],[x+5,-63],[x+20,-53],[x+17,-30],[x+3,-22],[x-13,-29],[x-19,-47]],cat_ink,2.5,Color("#558268"))
				line(n,[[x,-56],[x-1,-29]],cat_ink,6)
				wash(n,[[x-8,-54],[x-2,-55],[x-1,-49],[x-7,-48]],paper)
			line(n,[[-12,-12],[13,-12],[1,2],[-12,-12]],cat_ink,2,Color("#e8928a"),false)
			line(n,[[1,2],[-7,13],[-21,8]],cat_ink,2.5)
			line(n,[[1,2],[10,13],[24,7]],cat_ink,2.5)
			for side in [-1,1]:
				for offset in [-9,7]:line(n,[[side*75,-10+offset],[side*137,-18+offset]],cat_ink,2.3)
			line(n,[[-99,117],[-69,112],[-48,127],[-57,137]],cat_ink,2.7)
			line(n,[[39,132],[49,113],[79,112],[96,125]],cat_ink,2.7)
		"attachment_heart_thread":
			line(n,[[-123,-67],[-150,-101],[-188,-96],[-204,-67],[-192,-33],[-125,39],[-59,-34],[-49,-68],[-65,-98],[-99,-99],[-123,-67]],rose,4,Color("#f0d8d5"))
			line(n,[[-125,39],[-113,94],[-76,133],[-11,140],[43,121],[73,88],[90,27]],rose,3.5)
			line(n,[[58,-116],[218,-111],[223,1],[148,5],[112,38],[113,7],[58,6],[58,-116]],ink,3.2,paper)
			line(n,[[83,-79],[197,-76]],muted,3)
			line(n,[[82,-44],[171,-41]],muted,2.7)
			line(n,[[89,26],[81,10],[92,1],[103,12],[96,28]],rose,2.7)
		"attachment_phone_rest":
			# Quiet face-down phone; no empty gripping hand is drawn into this asset.
			line(n,[[-230,-46],[182,-51],[236,79],[-203,91],[-230,-46]],ink,3.4,Color("#f1e5d5"),false)
			line(n,[[-203,91],[235,79],[235,94],[-203,108],[-203,91]],ink,2.8,Color("#e4d5c2"),false)
			line(n,[[-176,108],[-178,181]],ink,3.5,null,false)
			line(n,[[205,96],[207,180]],ink,3.5,null,false)
			line(n,[[-94,-31],[102,-37],[128,26],[-68,34],[-94,-31]],ink,3.6,Color("#d9c8cb"),false)
			line(n,[[-77,-21],[-43,-22],[-37,-6],[-70,-4],[-77,-21]],ink,2.3,Color("#f4ebe6"),false)
			line(n,[[-66,-17],[-58,-17],[-56,-11],[-63,-10],[-66,-17]],muted,2,null,false)
		_:
			assert(false,"Unknown attachment illustration: "+kind)
	n.prepare()
	return n
