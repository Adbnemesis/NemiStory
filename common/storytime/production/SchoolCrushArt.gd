extends RefCounted
## SchoolCrushArt — Hand-inked storytime illustrations for ADB EP04 "My School Crush"
## Adheres strictly to the EP06 paper colour reference:
## - Contours in #2b2623 (charcoal ink)
## - Pale sepia/wood washes (#eedfc8, #e5d4bb), warm cream paper (#faf6ee)
## - Selective rose/red accents (#c05c58) for the crush, slate blue for classroom uniforms
## - 100% Vector LiveDrawing format with stable held and live stroke playback

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"classroom_double_desk",
	"crush_desk_partner",
	"border_line_dispute",
	"confession_paper_note",
	"gossip_betrayal_tree",
	"hallway_paralysis",
	"twin_crush_disaster"
]

const INK_MAIN: Color = Color("#2b2623")
const INK_FAINT: Color = Color(0.17, 0.15, 0.14, 0.25)
const INK_SOFT: Color = Color(0.17, 0.15, 0.14, 0.45)
const PAPER: Color = Color("#fffdf8")
const WASH: Color = Color("#ece5d8")
const WOOD_TOP: Color = Color("#e8dac5")
const WOOD_LEG: Color = Color("#8d8173")
const ROSE_CRUSH: Color = Color("#c76b66")
const BLUE_UNIFORM: Color = Color("#7b92a4")
const SKIN_TONE: Color = Color("#f4d6c1")
const HAIR_DARK: Color = Color("#2b2a30")

static func _add_stroke(n: Node2D, pts_raw: Array, col: Color = INK_MAIN, w: float = 2.6, smooth: bool = false) -> void:
	var pts := PackedVector2Array()
	for p in pts_raw: pts.append(Vector2(p[0], p[1]))
	n.stroke_list.append({"pts": pts, "col": col, "w": w, "smooth": smooth, "pause": 0.03, "pressure": PackedFloat32Array([0.65, 0.95, 0.85, 0.9, 0.5])})

static func _add_fill(n: Node2D, pts_raw: Array, col: Color) -> void:
	var pts := PackedVector2Array()
	for p in pts_raw: pts.append(Vector2(p[0], p[1]))
	n.fills.append({"poly": pts, "col": col, "at": 0.0})

static func make(author: String, kind: String) -> Node2D:
	var n = Drawing.new()
	var ink := INK_MAIN

	match kind:
		"classroom_double_desk":
			# Wooden primary school double desk with two seats and center divider
			# Desk top surface
			var top_poly := [[-260, -30], [260, -30], [290, 45], [-290, 45], [-260, -30]]
			_add_fill(n, top_poly, WOOD_TOP)
			_add_stroke(n, top_poly, ink, 3.2)
			# Pencil groove along the top
			_add_stroke(n, [[-230, -18], [230, -18]], INK_SOFT, 1.8)
			# Center pencil dividing line
			_add_stroke(n, [[0, -28], [0, 43]], INK_MAIN, 2.8)
			# Metal legs
			_add_stroke(n, [[-240, 45], [-240, 180]], WOOD_LEG, 4.0)
			_add_stroke(n, [[-210, 45], [-210, 180]], WOOD_LEG, 4.0)
			_add_stroke(n, [[210, 45], [210, 180]], WOOD_LEG, 4.0)
			_add_stroke(n, [[240, 45], [240, 180]], WOOD_LEG, 4.0)
			# Crossbar
			_add_stroke(n, [[-245, 140], [245, 140]], WOOD_LEG, 3.0)
			# Two open notebooks on the desk
			_add_fill(n, [[-180, -10], [-80, -10], [-75, 35], [-175, 35], [-180, -10]], PAPER)
			_add_stroke(n, [[-180, -10], [-80, -10], [-75, 35], [-175, 35], [-180, -10]], ink, 1.8)
			_add_fill(n, [[80, -10], [180, -10], [175, 35], [75, 35], [80, -10]], PAPER)
			_add_stroke(n, [[80, -10], [180, -10], [175, 35], [75, 35], [80, -10]], ink, 1.8)

		"crush_desk_partner":
			# Hand-inked illustration of the 8yo female classmate (sitting politely at desk)
			# Distinct child silhouette: braided hair ribbons, innocent smile, school pinafore
			# Hair / Head
			var head_poly := [[-30, -110], [30, -110], [38, -60], [25, -20], [-25, -20], [-38, -60], [-30, -110]]
			_add_fill(n, head_poly, SKIN_TONE)
			# Hair back volume and twin braided pigtails
			var hair_top := [[-42, -125], [42, -125], [50, -80], [38, -35], [-38, -35], [-50, -80], [-42, -125]]
			_add_fill(n, hair_top, HAIR_DARK)
			_add_stroke(n, hair_top, ink, 2.8)
			# Left pigtail
			var left_braid := [[-45, -70], [-68, -40], [-60, 15], [-50, 20], [-55, -40], [-45, -70]]
			_add_fill(n, left_braid, HAIR_DARK)
			_add_stroke(n, left_braid, ink, 2.2)
			# Right pigtail
			var right_braid := [[45, -70], [68, -40], [60, 15], [50, 20], [55, -40], [45, -70]]
			_add_fill(n, right_braid, HAIR_DARK)
			_add_stroke(n, right_braid, ink, 2.2)
			# Hair ribbon accents (rose crush)
			_add_fill(n, [[-62, -45], [-50, -45], [-56, -30], [-62, -45]], ROSE_CRUSH)
			_add_fill(n, [[62, -45], [50, -45], [56, -30], [62, -45]], ROSE_CRUSH)
			# Face contours & eyes
			_add_stroke(n, head_poly, ink, 2.4)
			# Soft friendly eyes and slight blush
			_add_stroke(n, [[-20, -65], [-10, -68], [-5, -62]], ink, 2.2) # left eye
			_add_stroke(n, [[5, -62], [10, -68], [20, -65]], ink, 2.2)  # right eye
			_add_stroke(n, [[-15, -60], [-15, -55]], ink, 3.5)
			_add_stroke(n, [[15, -60], [15, -55]], ink, 3.5)
			# Sweet polite smile
			_add_stroke(n, [[-8, -35], [0, -30], [8, -35]], ink, 2.0)
			# Gentle watercolor blush wash
			_add_fill(n, [[-28, -50], [-12, -50], [-20, -40], [-28, -50]], Color(0.95, 0.6, 0.6, 0.35))
			_add_fill(n, [[12, -50], [28, -50], [20, -40], [12, -50]], Color(0.95, 0.6, 0.6, 0.35))
			# School uniform pinafore & collar
			var body_poly := [[-35, -20], [35, -20], [48, 80], [-48, 80], [-35, -20]]
			_add_fill(n, body_poly, BLUE_UNIFORM)
			_add_stroke(n, body_poly, ink, 2.8)
			# White Peter Pan collar
			var collar_l := [[-25, -20], [0, -10], [-5, 5], [-25, -10], [-25, -20]]
			var collar_r := [[25, -20], [0, -10], [5, 5], [25, -10], [25, -20]]
			_add_fill(n, collar_l, PAPER)
			_add_stroke(n, collar_l, ink, 1.8)
			_add_fill(n, collar_r, PAPER)
			_add_stroke(n, collar_r, ink, 1.8)

		"border_line_dispute":
			# Comedic diagram of the classroom double desk border line
			# Big bold pencil dividing line with "NO CROSSING" warning arrows
			_add_stroke(n, [[0, -140], [0, 140]], ink, 4.0)
			# Warning hatched marks along the line
			for y in range(-120, 130, 30):
				_add_stroke(n, [[-15, y - 10], [15, y + 10]], INK_MAIN, 2.0)
			# Territorial arrows pointing back
			_add_stroke(n, [[-60, -40], [-20, -40]], INK_MAIN, 2.5)
			_add_stroke(n, [[-30, -50], [-20, -40], [-30, -30]], INK_MAIN, 2.5)
			_add_stroke(n, [[60, 40], [20, 40]], INK_MAIN, 2.5)
			_add_stroke(n, [[30, 30], [20, 40], [30, 50]], INK_MAIN, 2.5)
			# Symbolic shared eraser in the middle crossing the line
			var eraser := [[-18, -12], [18, -12], [18, 12], [-18, 12], [-18, -12]]
			_add_fill(n, eraser, Color("#ff7675"))
			_add_stroke(n, eraser, ink, 2.2)

		"confession_paper_note":
			# Folded school note passed during class: "WHO DO YOU LIKE?"
			var note_poly := [[-120, -80], [120, -80], [120, 70], [-100, 70], [-120, 50], [-120, -80]]
			_add_fill(n, note_poly, PAPER)
			_add_stroke(n, note_poly, ink, 3.0)
			# Dog-eared corner
			_add_fill(n, [[-120, 50], [-100, 50], [-100, 70], [-120, 50]], WASH)
			_add_stroke(n, [[-120, 50], [-100, 50], [-100, 70]], ink, 2.2)
			# Blue ruled notebook lines
			for y in [-45, -15, 15, 45]:
				_add_stroke(n, [[-90, y], [90, y]], Color(0.3, 0.45, 0.65, 0.4), 1.5)
			# Scribbled question marks & little secret lock icon
			_add_stroke(n, [[-20, -10], [0, -25], [15, -10], [5, 5], [5, 15]], INK_MAIN, 2.8)
			_add_stroke(n, [[5, 25], [5, 27]], INK_MAIN, 3.5)

		"gossip_betrayal_tree":
			# Diagram showing the gossip network exploding from the friend
			# Center friend head node
			_add_fill(n, [[-30, -50], [30, -50], [30, 10], [-30, 10], [-30, -50]], WASH)
			_add_stroke(n, [[-30, -50], [30, -50], [30, 10], [-30, 10], [-30, -50]], ink, 2.8)
			_add_stroke(n, [[-12, -25], [12, -25], [0, -10], [-12, -25]], ink, 2.0) # grinning mouth
			# Branching gossip arrows pointing in all directions
			var targets: Array[Vector2] = [
				Vector2(-160, -90), Vector2(-180, 20), Vector2(-130, 100),
				Vector2(160, -90), Vector2(180, 20), Vector2(140, 110)
			]
			for tgt: Vector2 in targets:
				var start_pt: Vector2 = tgt.normalized() * 45.0
				_add_stroke(n, [[start_pt.x, start_pt.y], [tgt.x, tgt.y]], INK_MAIN, 2.5)
				# Arrow head
				var dir: Vector2 = (tgt - start_pt).normalized()
				var perp: Vector2 = Vector2(-dir.y, dir.x) * 8.0
				var tip: Vector2 = tgt
				var left_barb: Vector2 = tgt - dir * 16.0 + perp
				var right_barb: Vector2 = tgt - dir * 16.0 - perp
				_add_stroke(n, [[left_barb.x, left_barb.y], [tip.x, tip.y], [right_barb.x, right_barb.y]], INK_MAIN, 2.5)
				# Small whispering crowd circles at each endpoint
				_add_fill(n, [[tgt.x - 16, tgt.y - 16], [tgt.x + 16, tgt.y - 16], [tgt.x + 16, tgt.y + 16], [tgt.x - 16, tgt.y + 16]], Color(0.9, 0.4, 0.4, 0.3))
				_add_stroke(n, [[tgt.x - 14, tgt.y - 14], [tgt.x + 14, tgt.y - 14], [tgt.x + 14, tgt.y + 14], [tgt.x - 14, tgt.y + 14], [tgt.x - 14, tgt.y - 14]], ink, 1.8)

		"hallway_paralysis":
			# The moment of social execution: spotlight on ADB surrounded by whispering silhouettes
			# Dramatic floor shadow
			_add_fill(n, [[-140, 60], [140, 60], [180, 110], [-180, 110], [-140, 60]], Color(0.2, 0.2, 0.2, 0.15))
			# Whispering speech bubbles on left and right
			# Left bubble
			_add_fill(n, [[-210, -70], [-90, -70], [-90, -10], [-130, -10], [-150, 15], [-155, -10], [-210, -10], [-210, -70]], PAPER)
			_add_stroke(n, [[-210, -70], [-90, -70], [-90, -10], [-130, -10], [-150, 15], [-155, -10], [-210, -10], [-210, -70]], ink, 2.2)
			_add_stroke(n, [[-190, -45], [-110, -45]], INK_SOFT, 2.0)
			_add_stroke(n, [[-180, -30], [-120, -30]], INK_SOFT, 1.8)
			# Right bubble (the girl knowing)
			_add_fill(n, [[90, -80], [220, -80], [220, -15], [165, -15], [145, 10], [140, -15], [90, -15], [90, -80]], PAPER)
			_add_stroke(n, [[90, -80], [220, -80], [220, -15], [165, -15], [145, 10], [140, -15], [90, -15], [90, -80]], ink, 2.2)
			_add_stroke(n, [[110, -55], [200, -55]], ROSE_CRUSH, 2.2)
			_add_stroke(n, [[120, -38], [190, -38]], INK_SOFT, 1.8)

		"twin_crush_disaster":
			# Two arrows pointing at the same girl, showing the twin crush disaster!
			# Center heart / girl silhouette representation
			var girl_box := [[-45, -90], [45, -90], [45, 10], [-45, 10], [-45, -90]]
			_add_fill(n, girl_box, Color(0.95, 0.85, 0.85))
			_add_stroke(n, girl_box, ink, 2.6)
			_add_stroke(n, [[0, -65], [-15, -80], [-25, -65], [0, -35], [25, -65], [15, -80], [0, -65]], ROSE_CRUSH, 2.5) # heart in box
			# Left arrow from ADB
			_add_stroke(n, [[-170, 40], [-60, -20]], INK_MAIN, 3.2)
			_add_stroke(n, [[-80, -38], [-60, -20], [-85, -15]], INK_MAIN, 3.0)
			# Right arrow from Friend 2
			_add_stroke(n, [[170, 40], [60, -20]], INK_MAIN, 3.2)
			_add_stroke(n, [[80, -38], [60, -20], [85, -15]], INK_MAIN, 3.0)
			# Labels under the arrows
			_add_stroke(n, [[-190, 60], [-140, 60]], INK_SOFT, 2.0)
			_add_stroke(n, [[140, 60], [190, 60]], INK_SOFT, 2.0)
			# Shock / realization crack lines above the box
			_add_stroke(n, [[-20, -120], [-5, -100], [10, -130]], INK_MAIN, 2.2)
			_add_stroke(n, [[25, -115], [40, -100]], INK_MAIN, 2.0)

	return n
