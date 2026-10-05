extends "res://shorts/godot/BatchPoseArt.gd"
## Editable, explicitly authored Shorts art. The feet do not follow the head motion.
## Arrival motion owns a finite 0..1 interval; completed contours never wobble.
## This is supplemental Godot illustration source, not an altered storytime rig.
var pose_progress := 1.0
var head_angle := 0.0
var look_x := 0.0
var eye_open := 1.0
var torso_lean := 0.0
var _upper := Transform2D.IDENTITY
var _head := Transform2D.IDENTITY
var _left_wrist := Vector2.ZERO
var _right_wrist := Vector2.ZERO
var _left_elbow := Vector2.ZERO
var _right_elbow := Vector2.ZERO
var _book_center := Vector2.ZERO

func _draw() -> void:
	var pivot := Vector2(0,-10)
	_upper = Transform2D(deg_to_rad(clampf(torso_lean,-5,5)),Vector2.ZERO)
	_upper.origin = pivot-_upper.basis_xform(pivot)
	var hp := Vector2(0,-305)
	var turn := Transform2D(deg_to_rad(clampf(head_angle,-12,12)),Vector2.ZERO)
	turn.origin = hp-turn.basis_xform(hp)
	_head = _upper*turn
	if smear:
		curve([[-210,-370],[-110,-358],[85,-358],[200,-342]],1.0)
		curve([[-240,-238],[-88,-234],[103,-222],[236,-215]],1.4)
	if view == "back":
		draw_rear_body()
		draw_set_transform_matrix(_head)
		draw_rear_head()
		if action == "listen" or accessory == "headphones": headphones()
		draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	# Long hair is behind the shoulders, while all its contours share the head clock.
	if author == "nemi":
		draw_set_transform_matrix(_head)
		draw_nemi_hair()
		draw_set_transform_matrix(Transform2D.IDENTITY)
	draw_lower_body()
	plan_hands()
	draw_set_transform_matrix(_upper)
	draw_sleeve(-1,_left_elbow,_left_wrist)
	draw_sleeve(1,_right_elbow,_right_wrist)
	draw_upper_body()
	draw_body_wash()
	# A held book and both grips use the same sampled center: no slipping prop layer.
	if action == "book_show": show_book()
	draw_set_transform_matrix(_head)
	if author == "nemi": draw_nemi_head()
	else: draw_adb_head()
	if view == "profile": draw_profile_face()
	else: draw_face()
	if action == "listen" or accessory == "headphones": headphones()
	if action == "glasses": glasses()
	# Hands in front of the mouth/ear must overlap the face instead of being erased.
	draw_hands_and_props()
	draw_set_transform_matrix(Transform2D.IDENTITY)

func arrival() -> float:
	var p := clampf(pose_progress,0,1)
	return p*p*(3.0-2.0*p)

func plan_hands() -> void:
	var p := arrival()
	_left_wrist = Vector2(-39,-170) if author == "nemi" else Vector2(-101,-47)
	_left_elbow = Vector2(-103,-111) if author == "nemi" else Vector2(-111,-121)
	_right_wrist = Vector2(112,-51)
	_right_elbow = Vector2(105,-138)
	match action:
		"rest":
			if emotion in ["shy","cover"]:
				var goal := head_contact(Vector2(22,-252))
				_right_wrist = Vector2(105,-90).lerp(goal,p)
				_right_elbow = Vector2(110,-151)
		"listen", "glasses":
			_right_wrist = Vector2(121,-221).lerp(head_contact(Vector2(80,-305)),p)
			_right_elbow = Vector2(142,-175).lerp(Vector2(138,-205),p)
		"peace", "wave":
			_right_wrist = Vector2(153,-244).lerp(Vector2(152,-311),p)
			_right_elbow = Vector2(135,-170).lerp(Vector2(137,-203),p)
		"thumbsup":
			_right_wrist = Vector2(151,-156).lerp(Vector2(147,-238),p)
			_right_elbow = Vector2(128,-154).lerp(Vector2(133,-172),p)
		"heart_hand":
			_right_wrist = Vector2(120,-182).lerp(Vector2(100,-266),p)
			_right_elbow = Vector2(132,-156).lerp(Vector2(139,-191),p)
		"chin":
			_right_wrist = Vector2(79,-194).lerp(head_contact(Vector2(28,-256)),p)
			_right_elbow = Vector2(118,-135).lerp(Vector2(114,-150),p)
		"hip":
			_right_wrist = Vector2(123,-52).lerp(Vector2(82,-69),p)
			_right_elbow = Vector2(118,-128).lerp(Vector2(147,-116),p)
		"point":
			_right_wrist = Vector2(162,-153).lerp(Vector2(201,-172),p)
			_right_elbow = Vector2(137,-149).lerp(Vector2(142,-174),p)
		"phone", "phone_up":
			var end := Vector2(130,-277) if action == "phone_up" else Vector2(108,-160)
			_right_wrist = Vector2(114,-109).lerp(end,p)
			_right_elbow = Vector2(121,-141).lerp(Vector2(145,-173),p)
		"sketch":
			_left_wrist = Vector2(-18,-57)
			_left_elbow = Vector2(-126,-115)
			_right_wrist = Vector2(70,-85).lerp(Vector2(35,-111),p)
			_right_elbow = Vector2(117,-135).lerp(Vector2(122,-127),p)
		"shrug", "arms_open":
			var end_x := 219.0 if action == "arms_open" else 187.0
			var end_y := -218.0 if action == "arms_open" else -179.0
			_left_wrist = Vector2(-110,-83).lerp(Vector2(-end_x,end_y),p)
			_right_wrist = Vector2(110,-83).lerp(Vector2(end_x,end_y),p)
			_left_elbow = Vector2(-136,-148).lerp(Vector2(-145,end_y+20),p)
			_right_elbow = Vector2(136,-148).lerp(Vector2(145,end_y+20),p)
		"book_show":
			_book_center = Vector2(0,-86).lerp(Vector2(0,-145),p)
			_left_wrist = _book_center+Vector2(-87,33)
			_right_wrist = _book_center+Vector2(87,33)
			_left_elbow = Vector2(-132,-102).lerp(Vector2(-138,-145),p)
			_right_elbow = Vector2(132,-102).lerp(Vector2(138,-145),p)

func head_contact(point: Vector2) -> Vector2:
	# Hands resting against a moving ear/chin share its transformed contact goal.
	return _upper.affine_inverse()*(_head*point)

func draw_sleeve(side: int,elbow: Vector2,wrist: Vector2) -> void:
	var shoulder := Vector2(74*side,-225)
	var c1 := shoulder+(elbow-shoulder)*.85
	var c2 := wrist+(elbow-wrist)*.78
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	var centers := PackedVector2Array()
	for j in range(25):
		var t := float(j)/24.0
		var u := 1.0-t
		var center := u*u*u*shoulder+3*u*u*t*c1+3*u*t*t*c2+t*t*t*wrist
		var tangent := (3*u*u*(c1-shoulder)+6*u*t*(c2-c1)+3*t*t*(wrist-c2)).normalized()
		var normal := Vector2(-tangent.y,tangent.x)
		var half_width := lerpf(25.0 if author == "nemi" else 21.0,13.5,t)
		outer.append(center+normal*half_width)
		inner.append(center-normal*half_width)
		centers.append(center)
	var shape := outer.duplicate()
	for j in range(inner.size()-1,-1,-1): shape.append(inner[j])
	# Short ribbon triangles remain valid even at a closely folded elbow. A single
	# outline polygon would self-overlap there and fail Godot's polygon triangulator.
	for j in range(outer.size()-1):
		draw_colored_polygon(PackedVector2Array([outer[j],inner[j],outer[j+1]]),paper)
		draw_colored_polygon(PackedVector2Array([inner[j],inner[j+1],outer[j+1]]),paper)
	shape.append(shape[0])
	draw_polyline(shape,ink,1.8,true)
	var cuff_tangent := (wrist-c2).normalized()
	var cuff_normal := Vector2(-cuff_tangent.y,cuff_tangent.x)
	draw_line(wrist+cuff_normal*13.5,wrist-cuff_normal*13.5,ink,1.2,true)
	draw_line(wrist-cuff_tangent*6+cuff_normal*13,wrist-cuff_tangent*6-cuff_normal*13,ink,.8,true)
	var fold := centers[13]
	draw_line(fold+Vector2(side*9,-9),fold+Vector2(-side*4,9),ink,.9,true)
	draw_line(fold+Vector2(side*12,-2),fold+Vector2(side*1,13),ink,.55,true)

func draw_upper_body() -> void:
	if author == "nemi":
		curve([[-27,-254],[-59,-248],[-75,-233],[-80,-209],[-80,-147],[-76,-79],[-88,-28],[-69,0],[-15,4],[23,5],[73,0],[87,-20],[74,-81],[78,-154],[79,-209],[72,-229],[51,-245],[25,-250]],1.9,true)
		curve([[-28,-254],[-43,-262],[-61,-263],[-68,-249],[-72,-231],[-49,-220],[-24,-209],[-12,-217],[0,-217],[12,-209],[45,-221],[73,-230],[67,-251],[62,-262],[43,-262],[25,-250]],1.6)
		curve([[-24,-209],[-3,-195],[5,-194],[12,-209]],1.4)
		line([[-18,-215],[-17,-166],[-23,-160]],1.0)
		line([[15,-213],[20,-168],[26,-161]],1.0)
		curve([[-78,-237],[-42,-174],[26,-74],[80,-2]],5.0)
		curve([[-69,-240],[-29,-173],[36,-79],[86,-12]],1.1)
		curve([[-71,-46],[-53,-42],[-33,-49],[-21,-55]],.9)
		curve([[15,-85],[4,-68],[4,-50],[17,-43]],1.0)
	else:
		curve([[-27,-257],[-55,-246],[-72,-231],[-74,-216],[-66,-163],[-73,-100],[-66,-21],[-29,-12],[33,-14],[73,-25],[67,-98],[72,-156],[71,-216],[65,-233],[44,-249],[26,-256]],1.9,true)
		line([[-27,-257],[-42,-237],[-17,-191],[0,-232],[17,-191],[41,-236],[26,-256]],1.4)
		curve([[-17,-191],[-3,-145],[0,-76],[0,-15]],1.0)
		for y in [-159,-119,-79,-39]: draw_circle(Vector2(3,y),2.1,ink)
		curve([[-62,-41],[-48,-34],[-33,-36],[-27,-39]],.8)

func draw_lower_body() -> void:
	if author == "nemi":
		curve([[-87,-24],[-84,22],[-112,69],[-112,107],[-71,125],[-15,120],[3,125],[33,116],[62,122],[107,99],[99,50],[82,14],[84,-14]],1.9,true)
		for xs in [-70,-43,-14,20,48,73]: curve([[xs,-10],[xs-3,25],[xs-9,64],[xs-8,111]],.9)
		curve([[-70,122],[-66,166],[-52,205],[-48,245],[-51,274],[-63,315],[-61,345]],1.7)
		curve([[-16,125],[-14,169],[-10,205],[-21,248],[-28,290],[-32,330],[-30,345]],1.7)
		curve([[26,123],[38,166],[47,208],[36,246],[20,284],[18,325],[23,345]],1.7)
		curve([[71,123],[80,165],[88,202],[72,246],[64,285],[60,325],[65,345]],1.7)
		line([[-57,286],[-27,290]],1.0);line([[20,285],[64,291]],1.0)
		shoe(-45,346);shoe(46,346)
		curve([[36,-30],[62,-35],[96,-30],[101,-14],[108,23],[106,61],[94,73],[71,76],[37,68],[27,53],[24,18],[23,-14],[36,-30]],1.5,true)
		line([[30,-12],[101,-9],[86,21],[48,23],[30,-12]],1.1)
		line([[63,23],[70,29],[74,22]],1.1)
	else:
		curve([[-65,-20],[-76,61],[-70,128],[-65,200],[-70,260],[-83,330],[-69,348],[-47,351],[-16,341],[-10,276],[-5,211],[1,97],[6,42],[15,79],[20,168],[30,246],[37,343],[59,351],[83,345],[87,322],[76,233],[80,156],[79,76],[72,-24]],1.9,true)
		curve([[-52,20],[-56,77],[-42,137],[-49,178]],1.0)
		curve([[54,16],[51,55],[64,109],[57,165]],1.0)
		curve([[-41,203],[-27,224],[-25,274],[-29,305]],1.0)
		line([[-66,337],[-18,334]],1.2);line([[36,335],[82,335]],1.2)
		shoe(-43,349);shoe(62,349)
	var w := Color(shade,shading)
	if author == "nemi":
		draw_colored_polygon(PackedVector2Array([Vector2(39,18),Vector2(64,20),Vector2(87,92),Vector2(42,105)]),w)
		for y in [38,50,62,74,86]: line([[48,y],[68,y-6]],.55)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(46,44),Vector2(67,48),Vector2(68,194),Vector2(77,310),Vector2(48,315)]),w)

func draw_body_wash() -> void:
	var w := Color(shade,shading)
	draw_colored_polygon(PackedVector2Array([Vector2(32,-188),Vector2(64,-195),Vector2(63,-43),Vector2(26,-36),Vector2(14,-98)]),w)
	for y in [-172,-157,-142,-127,-112]: line([[48,y],[60,y-7]],.55)

func hand_transform(wrist: Vector2,angle: float) -> Transform2D:
	return _upper*Transform2D(deg_to_rad(angle),wrist)

func draw_hands_and_props() -> void:
	var both := action in ["shrug","arms_open","book_show"]
	if action == "sketch":
		draw_set_transform_matrix(_upper)
		draw_sketch_page()
		draw_set_transform_matrix(hand_transform(_left_wrist,0))
		book_grip(-1)
		draw_set_transform_matrix(hand_transform(_right_wrist,-23))
		# The writing pencil shares the wrist matrix for its entire finite arrival.
		draw_line(Vector2(-11,-12),Vector2(42,-44),ink,4.0,true)
		draw_line(Vector2(-11,-12),Vector2(39,-43),paper,1.0,true)
		line([[39,-47],[51,-51],[42,-41]],1.0)
		grip_hand()
		return
	if not both:
		draw_set_transform_matrix(hand_transform(_left_wrist,0))
		if author == "nemi": grip_hand()
		else: relaxed_hand()
	draw_set_transform_matrix(_upper)
	if action in ["phone","phone_up"]:
		draw_set_transform_matrix(hand_transform(_right_wrist,-7))
		held_phone()
		return
	if action == "book_show":
		for side in [-1,1]:
			draw_set_transform_matrix(hand_transform(_left_wrist if side == -1 else _right_wrist,0))
			book_grip(side)
		return
	if both:
		for side in [-1,1]:
			draw_set_transform_matrix(hand_transform(_left_wrist if side == -1 else _right_wrist,75*side if action == "shrug" else 45*side))
			open_hand()
		return
	var angle := 0.0
	if action == "wave": angle = -18.0+36.0*sin(clampf(pose_progress,0,1)*PI*.5)
	if action == "point": angle = 75.0
	if action == "hip": angle = 138.0
	if action == "chin": angle = -22.0
	draw_set_transform_matrix(hand_transform(_right_wrist,angle))
	match action:
		"peace": peace_hand()
		"wave": open_hand()
		"thumbsup": thumbs_up_hand()
		"heart_hand": finger_heart_hand()
		"point": point_hand()
		"listen", "glasses", "chin", "hip": grip_hand()
		_:
			if emotion in ["shy","cover"]:
				if action == "rest": mouth_hand()
				else: relaxed_hand()
			else: relaxed_hand()

func mouth_hand() -> void:
	curve([[-11,0],[-18,-12],[-21,-23],[-19,-30],[-15,-31],[-9,-25],[-16,-44],[-14,-48],[-9,-47],[-2,-32],[-2,-52],[2,-55],[7,-51],[10,-33],[12,-47],[17,-49],[21,-45],[20,-25],[25,-30],[29,-28],[30,-22],[23,-8],[11,0]],1.2,true)
	line([[-9,-20],[2,-16],[9,-16]],.75)

func draw_sketch_page() -> void:
	var pts := PackedVector2Array([Vector2(-17,-147),Vector2(92,-154),Vector2(102,-48),Vector2(-8,-40)])
	draw_colored_polygon(pts,paper.lightened(.05))
	draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]),ink,1.5,true)
	for y in range(-139,-43,12): line([[-20,y],[-8,y-1]],1.1)
	curve([[19,-99],[26,-133],[71,-130],[76,-101],[81,-74],[22,-72],[19,-99]],.9)
	line([[28,-100],[38,-103],[50,-100],[58,-103],[69,-100]],.8)
	curve([[41,-87],[49,-81],[56,-81],[62,-88]],.9)

func relaxed_hand() -> void:
	curve([[-10,0],[-13,11],[-11,29],[-4,35],[3,34],[8,24],[12,9],[10,0]],1.2,true)
	line([[-5,13],[-4,29]],.7);line([[2,13],[2,28]],.7)

func grip_hand() -> void:
	curve([[-11,0],[-15,-10],[-10,-25],[-4,-29],[3,-25],[10,-22],[14,-10],[10,0]],1.2,true)
	curve([[-10,-17],[-3,-23],[4,-18],[7,-13]],1.0)
	line([[-8,-11],[9,-8]],.7);line([[-7,-6],[8,-3]],.7)

func open_hand() -> void:
	curve([[-11,0],[-15,-14],[-25,-29],[-24,-34],[-19,-33],[-10,-21],[-14,-47],[-11,-51],[-7,-49],[-2,-26],[-3,-56],[1,-59],[5,-56],[6,-28],[10,-51],[15,-52],[18,-48],[15,-24],[20,-39],[25,-38],[28,-34],[22,-16],[13,-5],[10,0]],1.2,true)
	curve([[-9,-15],[-4,-19],[3,-18],[9,-14]],.7)

func peace_hand() -> void:
	curve([[-11,0],[-16,-15],[-20,-44],[-17,-50],[-12,-48],[-6,-22],[0,-54],[4,-58],[9,-55],[12,-50],[6,-20],[12,-28],[17,-26],[16,-19],[22,-21],[26,-16],[19,-5],[10,0]],1.2,true)
	line([[-9,-12],[8,-8]],.8)

func thumbs_up_hand() -> void:
	curve([[-11,0],[-16,-13],[-12,-30],[-5,-40],[-4,-62],[0,-68],[6,-66],[9,-60],[8,-40],[16,-34],[22,-31],[22,-21],[20,-10],[12,0]],1.3,true)
	curve([[-4,-36],[6,-38],[16,-35],[21,-32]],.8)
	line([[7,-26],[20,-24]],.8);line([[7,-17],[19,-15]],.8)

func finger_heart_hand() -> void:
	curve([[-11,0],[-16,-12],[-15,-23],[-5,-33],[6,-42],[10,-43],[14,-40],[13,-36],[2,-27],[14,-28],[19,-25],[20,-20],[17,-17],[11,-17],[14,-11],[12,0]],1.2,true)
	curve([[-10,-30],[-15,-37],[-13,-42],[-8,-42],[-3,-34],[3,-24],[10,-20]],1.2,true)
	line([[-9,-12],[10,-9]],.8);line([[-8,-7],[10,-4]],.7)

func point_hand() -> void:
	curve([[-11,0],[-15,-15],[-11,-23],[-6,-30],[-5,-59],[-1,-64],[4,-62],[6,-57],[6,-31],[14,-33],[18,-29],[16,-23],[23,-24],[27,-19],[23,-12],[16,-4],[10,0]],1.2,true)
	line([[-4,-19],[12,-13]],.8)

func held_phone() -> void:
	var b := StyleBoxFlat.new()
	b.bg_color = paper.darkened(.10)
	b.border_color = ink
	b.set_border_width_all(2)
	b.set_corner_radius_all(5)
	draw_style_box(b,Rect2(-18,-68,39,71))
	draw_circle(Vector2(-9,-58),3.7,ink);draw_circle(Vector2(2,-58),3.7,ink)
	line([[-8,-5],[11,-5]],.7)
	# The thumb crosses the front; three opposing fingers wrap the far edge.
	curve([[-10,0],[-19,-12],[-22,-28],[-18,-34],[-12,-31],[-9,-19],[0,-15],[4,-10],[0,-5],[-6,-7],[-3,0]],1.2,true)
	for y in [-27,-19,-11]:
		curve([[17,y-4],[26,y-3],[28,y+2],[23,y+5],[17,y+1]],1.0,true)

func show_book() -> void:
	var y := _book_center.y
	var pts := PackedVector2Array([Vector2(-83,y-55),Vector2(82,y-55),Vector2(87,y+63),Vector2(-84,y+64)])
	draw_colored_polygon(pts,paper.lightened(.035))
	pts.append(pts[0]);draw_polyline(pts,ink,1.5,true)
	for dy in range(-46,59,12): line([[-90,y+dy],[-78,y+dy]],1.0)
	# A finished tiny cat on the held page, with unmistakable ears and whiskers.
	curve([[-26,y-32],[-27,y-39],[-29,y-50],[-31,y-58],[-21,y-51],[-16,y-47],[-12,y-42]],1.0,true)
	curve([[17,y-42],[24,y-48],[30,y-54],[35,y-58],[34,y-48],[35,y-38],[33,y-32]],1.0,true)
	curve([[-29,y-18],[-33,y-39],[-16,y-43],[3,y-43],[23,y-43],[35,y-38],[33,y-18],[32,y+7],[-27,y+6],[-29,y-18]],1.0,true)
	curve([[-23,y-20],[-17,y-25],[-10,y-25],[-5,y-20]],.9)
	curve([[8,y-20],[15,y-25],[21,y-25],[27,y-20]],.9)
	curve([[-5,y-5],[3,y+1],[9,y+1],[14,y-5]],.9)
	line([[-19,y+19],[-29,y+39],[29,y+39],[21,y+19]],1.0)
	line([[-22,y-11],[-40,y-16]],.8);line([[-22,y-5],[-40,y-2]],.8)
	line([[24,y-11],[44,y-16]],.8);line([[24,y-5],[44,y-2]],.8)
	curve([[28,y+37],[49,y+35],[56,y+19],[47,y+16],[37,y+14],[37,y+25],[46,y+25]],.9)

func book_grip(side: int) -> void:
	curve([[-11,0],[-15,-13],[-13,-24],[-7,-29],[1,-25],[7,-20],[11,-10],[10,0]],1.2,true)
	for y in [-20,-13,-6]: line([[-10,y],[6,y+3]],.75)
	if side == -1: curve([[6,-21],[15,-26],[20,-24],[20,-18],[11,-14]],1.0,true)
	else: curve([[-10,-21],[-20,-26],[-23,-23],[-21,-17],[-13,-14]],1.0,true)

func draw_face() -> void:
	var skew := 10.0 if view == "threequarter" else 0.0
	var opening := clampf(eye_open,0,1)
	var y := -316.0
	for side in [-1,1]:
		var x: float = side*28.0+skew
		var sx := .77 if side == -1 and view == "threequarter" else 1.0
		if emotion == "cover" or emotion == "deadpan" or opening < .08:
			curve([[x-15*sx,y],[x-3*sx,y-3],[x+6*sx,y-2],[x+15*sx,y]],2.0)
		else:
			var h := (6.0 if author == "adb" else 11.0)*opening
			curve([[x-17*sx,y],[x-8*sx,y-h],[x+8*sx,y-h],[x+17*sx,y+1]],2.2 if author == "adb" else 2.8)
			curve([[x-14*sx,y+2],[x-4*sx,y+h*.7],[x+8*sx,y+h*.7],[x+14*sx,y+3]],.8)
			draw_ellipse_eye(Vector2(x+clampf(look_x,-1,1)*5,y),sx,(5.5 if author == "adb" else 9.0)*opening)
			line([[x-17*sx,y],[x-21*sx,y-4]],1.1)
		curve([[x-16*sx,y-21],[x-6*sx,y-25],[x+6*sx,y-25],[x+16*sx,y-20]],1.2)
	curve([[skew+1,-308],[skew+5,-303],[skew+4,-298],[skew,-297]],.8)
	if emotion == "shock":
		curve([[skew-4,-281],[skew-9,-292],[skew+10,-292],[skew+7,-280],[skew+5,-274],[skew,-274],[skew-4,-281]],1.0,true)
	elif emotion == "deadpan": line([[skew-9,-283],[skew+9,-283]],1.1)
	else: curve([[skew-12,-283],[skew-2,-278],[skew+6,-278],[skew+13,-284]],1.0)
	if emotion in ["shy","cover"]:
		for side in [-1,1]:
			for j in range(4): line([[side*31+j*3,-294],[side*31+j*3-3,-286]],.8)

func draw_profile_face() -> void:
	var opening := clampf(eye_open,0,1)
	if opening < .08 or emotion in ["deadpan","cover"]:
		curve([[29,-320],[39,-317],[47,-317],[51,-320]],1.8)
	else:
		curve([[29,-320],[39,-320-7*opening],[48,-320-5*opening],[51,-318]],2.2)
		curve([[32,-318],[37,-315],[46,-315],[49,-320]],.8)
		draw_ellipse_eye(Vector2(42+clampf(look_x,-1,1)*2,-320),.65,8.0*opening)
	curve([[30,-337],[38,-341],[45,-340],[50,-334]],1.1)
	line([[56,-282],[63,-281]],.8)
	if emotion in ["shy","cover"]:
		for j in range(4):line([[39+j*4,-292],[36+j*4,-286]],.8)

func draw_ellipse_eye(p: Vector2,sx: float,ry := 9.0) -> void:
	var pts := PackedVector2Array()
	for j in range(33): pts.append(p+Vector2(cos(j*TAU/32)*7*sx,sin(j*TAU/32)*ry))
	draw_colored_polygon(pts,ink)
	draw_circle(p+Vector2(-2,-ry*.45),minf(2.4,ry*.28),paper)
	if ry > 4: draw_circle(p+Vector2(2,ry*.45),.9,paper)

func draw_rear_body() -> void:
	if author == "adb":
		curve([[-66,-20],[-76,90],[-65,197],[-78,339],[-37,350],[-16,336],[-4,159],[4,49],[17,149],[31,337],[66,350],[85,332],[75,194],[78,84],[68,-23]],1.8,true)
		line([[-64,332],[-19,334]],1.0);line([[33,334],[79,332]],1.0)
		shoe(-41,348);shoe(59,348)
	else:
		curve([[-75,-11],[-57,40],[-83,105],[-22,119],[31,113],[87,101],[68,35],[76,-11]],1.8,true)
		for x in [-45,-15,18,47]:curve([[x,0],[x-6,35],[x+1,79],[x,114]],.9)
		curve([[-56,117],[-53,170],[-39,209],[-47,261],[-52,304],[-51,339],[-45,346]],1.7)
		curve([[-11,119],[-6,159],[0,207],[-11,254],[-19,294],[-21,325],[-18,344]],1.7)
		curve([[27,117],[37,164],[49,207],[44,253],[38,292],[42,324],[42,346]],1.7)
		curve([[69,109],[81,161],[90,201],[86,252],[82,291],[87,324],[88,344]],1.7)
		shoe(-37,346);shoe(66,346)
	draw_set_transform_matrix(_upper)
	for side in [-1,1]:
		var wrist := Vector2(side*103,-65)
		draw_sleeve(side,Vector2(side*117,-153),wrist)
		draw_set_transform_matrix(hand_transform(wrist,0))
		relaxed_hand()
		draw_set_transform_matrix(_upper)
	if author == "adb":
		curve([[-72,-218],[-64,-135],[-73,-36],[-43,-12],[43,-12],[73,-36],[64,-135],[72,-218]],1.9,true)
		line([[-33,-252],[0,-239],[33,-252]],1.2)
		line([[-65,-210],[65,-210]],.9)
	else:
		curve([[-70,-218],[-77,-145],[-69,-72],[-77,-10],[-29,9],[34,7],[77,-12],[71,-72],[80,-150],[70,-217]],1.9,true)
		curve([[-45,-258],[-76,-254],[-86,-233],[-51,-197],[-5,-188],[41,-196],[85,-230],[75,-254],[40,-259]],1.7,true)
		curve([[-35,-255],[-21,-245],[17,-245],[35,-255]],1.0)
		curve([[45,-244],[13,-151],[-27,-75],[-70,-15]],5.0)
	draw_body_wash()
	draw_set_transform_matrix(Transform2D.IDENTITY)

func draw_rear_head() -> void:
	if author == "nemi":
		curve([[-42,-386],[-76,-354],[-71,-299],[-76,-239],[-83,-170],[-64,-131],[-88,-106],[-56,-97],[-38,-118],[-16,-141],[8,-146],[24,-124],[55,-90],[81,-103],[67,-119],[77,-144],[69,-189],[88,-245],[91,-314],[70,-366],[39,-399],[5,-410],[-42,-386]],1.8,true)
		curve([[-23,-397],[-36,-355],[-26,-315],[-35,-274],[-37,-209],[-32,-174],[-57,-127]],1.0)
		curve([[24,-398],[18,-360],[41,-320],[37,-269],[38,-206],[61,-164],[48,-134]],1.0)
		curve([[-2,-401],[8,-426],[19,-439],[33,-437],[17,-414],[12,-403],[-2,-401]],1.2)
		var w := Color(shade,shading)
		draw_colored_polygon(PackedVector2Array([Vector2(37,-337),Vector2(65,-299),Vector2(58,-178),Vector2(39,-157),Vector2(27,-260)]),w)
	else:
		curve([[-37,-273],[-51,-299],[-55,-342],[-43,-374],[-12,-391],[22,-385],[47,-368],[57,-333],[48,-295],[33,-274],[2,-263],[-37,-273]],1.8,true)
		var hair := PackedVector2Array([Vector2(-51,-297),Vector2(-67,-337),Vector2(-59,-367),Vector2(-72,-390),Vector2(-40,-380),Vector2(-33,-408),Vector2(-11,-394),Vector2(17,-408),Vector2(33,-387),Vector2(62,-384),Vector2(57,-360),Vector2(74,-341),Vector2(59,-309),Vector2(45,-283),Vector2(16,-291),Vector2(-9,-284),Vector2(-32,-289)])
		draw_colored_polygon(hair,ink)
		curve([[-12,-281],[-12,-258],[13,-256],[21,-280]],1.0)
