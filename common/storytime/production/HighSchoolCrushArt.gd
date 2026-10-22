extends RefCounted
## HighSchoolCrushArt — Hand-inked storytime illustrations for ADB EP06 "My Crush Said 'I Know'"
## Adheres strictly to the EP06 paper colour reference:
## - Contours in #2b2623 (charcoal ink)
## - Pale sepia/wood washes (#eedfc8, #e5d4bb), warm cream paper (#faf6ee)
## - Selective red/rose accents (#c05c58), soft blue chat (#6b9bc7), muted green/ochre
## - 100% Vector LiveDrawing format with stable held and live stroke playback

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"high_school_reshuffle_board",
	"trio_seating_diagram",
	"quiet_corner_desk",
	"friend_group_doodle",
	"why_did_you_block_me_bubble",
	"she_forgot_doodle",
	"math_half_yearly_exam",
	"confession_text_screen",
	"i_know_reply_bubble",
	"high_school_anticlimax_badge"
]

const INK_MAIN: Color = Color("#2b2623")
const INK_FAINT: Color = Color(0.17, 0.15, 0.14, 0.25)
const INK_SOFT: Color = Color(0.17, 0.15, 0.14, 0.45)
const PAPER: Color = Color("#fffdf8")
const WASH: Color = Color("#ece5d8")
const WOOD_TOP: Color = Color("#e8dac5")
const WOOD_LEG: Color = Color("#8d8173")
const ROSE_CRUSH: Color = Color("#c76b66")
const RED_ACCENT: Color = Color("#c74b46")
const BLUE_CHAT: Color = Color("#6b9bc7")
const GREEN_STATUS: Color = Color("#55a872")
const CHALK_WHITE: Color = Color("#f4efe8")

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
		"high_school_reshuffle_board":
			# Notice board with pinned class list: "Japanese Elective -> Section C"
			var board_poly := [[-160, -110], [160, -110], [160, 110], [-160, 110], [-160, -110]]
			_add_fill(n, board_poly, Color("#d9c8af"))
			_add_stroke(n, board_poly, ink, 3.5)
			# Paper notice pinned on board
			var paper_poly := [[-130, -85], [130, -85], [130, 85], [-130, 85], [-130, -85]]
			_add_fill(n, paper_poly, PAPER)
			_add_stroke(n, paper_poly, ink, 2.2)
			# Push pins
			_add_fill(n, [[-120, -78], [-112, -78], [-112, -70], [-120, -70], [-120, -78]], RED_ACCENT)
			_add_fill(n, [[112, -78], [120, -78], [120, -70], [112, -70], [112, -78]], RED_ACCENT)
			# Headline: "HIGH SCHOOL RESHUFFLE"
			_add_stroke(n, [[-100, -60], [100, -60]], ink, 3.0)
			# Subtitle: "JAPANESE 2ND LANG -> ALL IN 10-A"
			_add_stroke(n, [[-80, -35], [80, -35]], BLUE_CHAT, 2.2)
			# Student list bullet items
			_add_stroke(n, [[-90, -10], [-80, -10]], ink, 2.0)
			_add_stroke(n, [[-70, -10], [40, -10]], INK_SOFT, 1.8)
			_add_stroke(n, [[-90, 15], [-80, 15]], ink, 2.0)
			_add_stroke(n, [[-70, 15], [60, 15]], INK_SOFT, 1.8)
			_add_stroke(n, [[-90, 40], [-80, 40]], ink, 2.0)
			_add_stroke(n, [[-70, 40], [30, 40]], INK_SOFT, 1.8)
			# Red highlighter circle around the rule
			_add_stroke(n, [[-95, -45], [95, -45], [95, -20], [-95, -20], [-95, -45]], Color(0.78, 0.29, 0.27, 0.45), 2.5)

		"trio_seating_diagram":
			# Classroom map showing Me, Crush, and Boyfriend in the same room
			var map_poly := [[-170, -110], [170, -110], [170, 110], [-170, 110], [-170, -110]]
			_add_fill(n, map_poly, PAPER)
			_add_stroke(n, map_poly, ink, 3.0)
			# Blackboard indicator at top
			_add_fill(n, [[-120, -95], [120, -95], [120, -85], [-120, -85], [-120, -95]], Color("#3a4f44"))
			_add_stroke(n, [[-120, -95], [120, -95], [120, -85], [-120, -85], [-120, -95]], ink, 1.8)
			# Desks: Crush desk (center)
			_add_fill(n, [[-30, -45], [30, -45], [30, -15], [-30, -15], [-30, -45]], ROSE_CRUSH)
			_add_stroke(n, [[-30, -45], [30, -45], [30, -15], [-30, -15], [-30, -45]], ink, 2.2)
			# Boyfriend desk (beside crush)
			_add_fill(n, [[50, -45], [110, -45], [110, -15], [50, -15], [50, -45]], Color("#a0b2c6"))
			_add_stroke(n, [[50, -45], [110, -45], [110, -15], [50, -15], [50, -45]], ink, 2.2)
			# Me desk (lonely back corner)
			_add_fill(n, [[-140, 45], [-80, 45], [-80, 75], [-140, 75], [-140, 45]], WOOD_TOP)
			_add_stroke(n, [[-140, 45], [-80, 45], [-80, 75], [-140, 75], [-140, 45]], ink, 2.2)
			# Dotted awkward tension line from Me to Crush
			_add_stroke(n, [[-80, 50], [-45, 10], [-10, -15]], RED_ACCENT, 2.0)
			# Heart connecting Crush & BF
			_add_stroke(n, [[30, -30], [50, -30]], RED_ACCENT, 2.5)

		"quiet_corner_desk":
			# Back corner desk: solitary setting with notebook and water bottle
			var top_poly := [[-140, -20], [140, -20], [160, 35], [-160, 35], [-140, -20]]
			_add_fill(n, top_poly, WOOD_TOP)
			_add_stroke(n, top_poly, ink, 3.0)
			_add_stroke(n, [[-120, 35], [-120, 160]], WOOD_LEG, 3.5)
			_add_stroke(n, [[120, 35], [120, 160]], WOOD_LEG, 3.5)
			_add_stroke(n, [[-125, 130], [125, 130]], WOOD_LEG, 2.5)
			# Open notebook
			_add_fill(n, [[-60, -8], [40, -8], [35, 25], [-65, 25], [-60, -8]], PAPER)
			_add_stroke(n, [[-60, -8], [40, -8], [35, 25], [-65, 25], [-60, -8]], ink, 1.8)
			_add_stroke(n, [[-10, -8], [-10, 25]], INK_SOFT, 1.4)
			# Water bottle / small cup
			_add_fill(n, [[75, -2], [95, -2], [95, 22], [75, 22], [75, -2]], Color("#c0d8e8"))
			_add_stroke(n, [[75, -2], [95, -2], [95, 22], [75, 22], [75, -2]], ink, 1.8)

		"friend_group_doodle":
			# "Year 2 Squad" badge showing 3 friends laughing together
			var circle_poly := []
			for idx in range(24):
				var ang = idx * PI * 2.0 / 24.0
				circle_poly.append([cos(ang) * 95, sin(ang) * 95])
			_add_fill(n, circle_poly, WASH)
			_add_stroke(n, circle_poly, ink, 3.0)
			# Center friend head
			_add_stroke(n, [[-20, -40], [20, -40], [20, 0], [-20, 0], [-20, -40]], ink, 2.4)
			_add_stroke(n, [[-10, -10], [10, -10]], INK_MAIN, 2.2) # smile
			# Left friend head
			_add_stroke(n, [[-65, -25], [-35, -25], [-35, 10], [-65, 10], [-65, -25]], ink, 2.0)
			# Right friend head
			_add_stroke(n, [[35, -25], [65, -25], [65, 10], [35, 10], [35, -25]], ink, 2.0)
			# Arms high-fiving
			_add_stroke(n, [[-35, 25], [0, 45], [35, 25]], ink, 2.5)
			# Banner text line: "GOOD FRIENDS"
			_add_stroke(n, [[-50, 65], [50, 65]], GREEN_STATUS, 2.8)

		"why_did_you_block_me_bubble":
			# Speech bubble with the burning question
			var bubble := [[-160, -55], [160, -55], [160, 25], [-20, 25], [-50, 60], [-45, 25], [-160, 25], [-160, -55]]
			_add_fill(n, bubble, PAPER)
			_add_stroke(n, bubble, ink, 3.0)
			# Text: "WHY DID YOU BLOCK ME?"
			_add_stroke(n, [[-130, -30], [-10, -30]], ink, 3.2)
			_add_stroke(n, [[10, -30], [130, -30]], RED_ACCENT, 3.2)
			_add_stroke(n, [[-80, -2], [80, -2]], INK_SOFT, 2.2)
			# Big question mark
			_add_stroke(n, [[125, -40], [140, -40], [140, -25], [132, -15], [132, -5]], RED_ACCENT, 2.8)
			_add_fill(n, [[130, 5], [134, 5], [134, 9], [130, 9], [130, 5]], RED_ACCENT)

		"she_forgot_doodle":
			# Confusion portrait: swirl eyes and "I don't remember!"
			var card := [[-140, -90], [140, -90], [140, 90], [-140, 90], [-140, -90]]
			_add_fill(n, card, PAPER)
			_add_stroke(n, card, ink, 2.8)
			# Swirl eyes
			_add_stroke(n, [[-45, -40], [-35, -50], [-25, -40], [-35, -30], [-40, -40]], INK_MAIN, 2.2)
			_add_stroke(n, [[25, -40], [35, -50], [45, -40], [35, -30], [30, -40]], INK_MAIN, 2.2)
			# Open confused mouth
			_add_stroke(n, [[-15, -10], [15, -10], [0, 5], [-15, -10]], INK_MAIN, 2.0)
			# Speech quote: "Wait, I blocked you??"
			_add_stroke(n, [[-100, 30], [100, 30]], INK_SOFT, 2.4)
			_add_stroke(n, [[-70, 55], [70, 55]], Color(0.8, 0.4, 0.4), 2.2)
			# Question marks
			_add_stroke(n, [[-80, -70], [-70, -70], [-70, -60], [-75, -50]], Color("#d97736"), 2.2)
			_add_stroke(n, [[70, -70], [80, -70], [80, -60], [75, -50]], Color("#d97736"), 2.2)

		"math_half_yearly_exam":
			# Examination paper with equations and red mark
			var sheet := [[-120, -160], [120, -160], [120, 160], [-120, 160], [-120, -160]]
			_add_fill(n, sheet, PAPER)
			_add_stroke(n, sheet, ink, 2.8)
			# Header: "HALF-YEARLY EXAM: MATH"
			_add_stroke(n, [[-95, -130], [95, -130]], ink, 3.0)
			_add_stroke(n, [[-70, -105], [70, -105]], INK_SOFT, 2.0)
			# Math equations: "x² + y = √z"
			_add_stroke(n, [[-90, -70], [-50, -70]], INK_MAIN, 2.0)
			_add_stroke(n, [[-20, -75], [-10, -65], [10, -75]], ink, 1.8)
			_add_stroke(n, [[40, -70], [80, -70]], INK_MAIN, 2.0)
			# Formula scribbles
			_add_stroke(n, [[-90, -30], [70, -30]], INK_SOFT, 1.8)
			_add_stroke(n, [[-90, 0], [40, 0]], INK_SOFT, 1.8)
			_add_stroke(n, [[-90, 30], [80, 30]], INK_SOFT, 1.8)
			# Red grade score / tick mark
			_add_stroke(n, [[45, -145], [65, -125], [105, -155]], RED_ACCENT, 3.2)
			_add_stroke(n, [[30, 90], [90, 90], [90, 135], [30, 135], [30, 90]], RED_ACCENT, 2.5)

		"confession_text_screen":
			# Smartphone screen displaying the outgoing confession text
			var phone := [[-120, -180], [120, -180], [120, 180], [-120, 180], [-120, -180]]
			_add_fill(n, phone, PAPER)
			_add_stroke(n, phone, ink, 3.2)
			# Header bar
			var hdr := [[-120, -180], [120, -180], [120, -125], [-120, -125], [-120, -180]]
			_add_fill(n, hdr, Color("#dfe6ec"))
			_add_stroke(n, hdr, ink, 2.0)
			_add_fill(n, [[-70, -165], [-45, -165], [-45, -140], [-70, -140], [-70, -165]], ROSE_CRUSH)
			_add_stroke(n, [[-70, -165], [-45, -165], [-45, -140], [-70, -140], [-70, -165]], ink, 1.8)
			_add_stroke(n, [[-35, -152], [50, -152]], ink, 2.5)
			# Outgoing confession text bubble
			var bubble := [[-80, -60], [105, -60], [105, 30], [-70, 30], [-80, 45], [-78, 30], [-80, 30], [-80, -60]]
			_add_fill(n, bubble, Color("#d6e9f8"))
			_add_stroke(n, bubble, ink, 2.4)
			# Confession lines: "I still like you"
			_add_stroke(n, [[-60, -35], [85, -35]], ink, 2.6)
			_add_stroke(n, [[-60, -10], [55, -10]], ink, 2.6)
			_add_stroke(n, [[-60, 12], [20, 12]], ink, 2.2)
			# Sent double checkmarks
			_add_stroke(n, [[75, 20], [80, 25], [88, 17]], BLUE_CHAT, 1.8)
			_add_stroke(n, [[81, 20], [86, 25], [94, 17]], BLUE_CHAT, 1.8)

		"i_know_reply_bubble":
			# Incoming message bubble: bold "I know."
			var bubble := [[-110, -50], [110, -50], [110, 35], [-70, 35], [-100, 65], [-92, 35], [-110, 35], [-110, -50]]
			_add_fill(n, bubble, Color("#f0ede6"))
			_add_stroke(n, bubble, ink, 3.2)
			# Bold text: "I KNOW."
			# "I"
			_add_stroke(n, [[-70, -25], [-70, 10]], ink, 4.0)
			_add_stroke(n, [[-80, -25], [-60, -25]], ink, 3.0)
			_add_stroke(n, [[-80, 10], [-60, 10]], ink, 3.0)
			# "K"
			_add_stroke(n, [[-40, -25], [-40, 10]], ink, 4.0)
			_add_stroke(n, [[-15, -25], [-40, -5], [-15, 10]], ink, 3.5)
			# "N"
			_add_stroke(n, [[-5, 10], [-5, -25], [15, 10], [15, -25]], ink, 3.5)
			# "O"
			_add_stroke(n, [[25, -15], [35, -25], [50, -25], [60, -15], [60, 0], [50, 10], [35, 10], [25, 0], [25, -15]], ink, 3.5)
			# "W"
			_add_stroke(n, [[70, -25], [78, 10], [85, -10], [92, 10], [100, -25]], ink, 3.5)
			# Period
			_add_fill(n, [[103, 7], [107, 7], [107, 11], [103, 11], [103, 7]], ink)

		"high_school_anticlimax_badge":
			# Humorous badge stamped over the conclusion
			var badge := []
			for idx in range(32):
				var r = 90.0 if (idx % 2 == 0) else 102.0
				var ang = idx * PI * 2.0 / 32.0
				badge.append([cos(ang) * r, sin(ang) * r])
			_add_fill(n, badge, Color("#faf2e6"))
			_add_stroke(n, badge, ink, 3.0)
			# Inner circle
			var inner := []
			for idx in range(24):
				var ang = idx * PI * 2.0 / 24.0
				inner.append([cos(ang) * 75, sin(ang) * 75])
			_add_stroke(n, inner, RED_ACCENT, 2.0)
			# Text lines: "ANTICLIMAX"
			_add_stroke(n, [[-55, -20], [55, -20]], RED_ACCENT, 3.5)
			_add_stroke(n, [[-40, 5], [40, 5]], INK_MAIN, 2.5)
			_add_stroke(n, [[-20, 25], [20, 25]], INK_SOFT, 2.0)

	n.prepare()
	return n
