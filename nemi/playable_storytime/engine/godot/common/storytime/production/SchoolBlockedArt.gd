extends RefCounted
## SchoolBlockedArt — Hand-inked storytime illustrations for ADB EP05 "My Crush Blocked Me"
## Adheres strictly to the EP06 paper colour reference:
## - Contours in #2b2623 (charcoal ink)
## - Pale sepia/wood washes (#eedfc8, #e5d4bb), warm cream paper (#faf6ee)
## - Selective rose/red accents (#c05c58) for the crush & blocked stamp, cyan/blue for chat UI
## - 100% Vector LiveDrawing format with stable held and live stroke playback

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"japanese_classroom_desk",
	"japanese_blackboard",
	"school_chat_phone",
	"chat_bubble_outgoing_1",
	"chat_bubble_outgoing_2",
	"deactivated_contact_card",
	"peaceful_delusion_badge",
	"rival_boyfriend_diagram",
	"blocked_stamp",
	"broken_heart_doodle"
]

const INK_MAIN: Color = Color("#2b2623")
const INK_FAINT: Color = Color(0.17, 0.15, 0.14, 0.25)
const INK_SOFT: Color = Color(0.17, 0.15, 0.14, 0.45)
const PAPER: Color = Color("#fffdf8")
const WASH: Color = Color("#ece5d8")
const WOOD_TOP: Color = Color("#e8dac5")
const WOOD_LEG: Color = Color("#8d8173")
const ROSE_CRUSH: Color = Color("#c76b66")
const RED_BLOCKED: Color = Color("#c74b46")
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
		"japanese_classroom_desk":
			# Individual middle school wooden desk (unlike EP04 double desk)
			# Shows middle school separation and individual seating
			var top_poly := [[-150, -25], [150, -25], [170, 35], [-170, 35], [-150, -25]]
			_add_fill(n, top_poly, WOOD_TOP)
			_add_stroke(n, top_poly, ink, 3.0)
			# Pencil groove along the top
			_add_stroke(n, [[-130, -15], [130, -15]], INK_SOFT, 1.8)
			# Legs to floor
			_add_stroke(n, [[-130, 35], [-130, 185]], WOOD_LEG, 3.8)
			_add_stroke(n, [[130, 35], [130, 185]], WOOD_LEG, 3.8)
			_add_stroke(n, [[-135, 145], [135, 145]], WOOD_LEG, 2.8)
			# Japanese textbook on desk
			var book_poly := [[-60, -5], [50, -5], [45, 28], [-65, 28], [-60, -5]]
			_add_fill(n, book_poly, PAPER)
			_add_stroke(n, book_poly, ink, 2.0)
			# Book spine & hiragana symbol
			_add_stroke(n, [[-5, -5], [-5, 28]], INK_SOFT, 1.5)
			_add_stroke(n, [[-35, 8], [-25, 8], [-30, 18]], BLUE_CHAT, 1.8) # "あ" hint

		"japanese_blackboard":
			# Classroom chalkboard with frame showing "日本語" and hiragana drills
			var board_poly := [[-260, -130], [260, -130], [260, 110], [-260, 110], [-260, -130]]
			_add_fill(n, board_poly, Color("#3a4f44")) # Muted dark sage chalkboard
			_add_stroke(n, board_poly, ink, 3.5)
			# Wooden border frame
			_add_stroke(n, [[-270, -140], [270, -140], [270, 120], [-270, 120], [-270, -140]], WOOD_TOP, 4.0)
			# Chalk tray at bottom
			_add_fill(n, [[-250, 110], [250, 110], [250, 125], [-250, 125], [-250, 110]], WOOD_LEG)
			_add_stroke(n, [[-250, 110], [250, 110], [250, 125], [-250, 125], [-250, 110]], ink, 2.0)
			# Chalk writing: "日本語" (Japanese language) title
			_add_stroke(n, [[-180, -90], [-130, -90]], CHALK_WHITE, 2.8)
			_add_stroke(n, [[-155, -110], [-155, -70]], CHALK_WHITE, 2.8) # "日"
			_add_stroke(n, [[-100, -110], [-70, -110], [-70, -70], [-100, -70], [-100, -110]], CHALK_WHITE, 2.5) # "本"
			_add_stroke(n, [[-85, -110], [-85, -60]], CHALK_WHITE, 2.8)
			# Hiragana drills: "あ い う え お"
			_add_stroke(n, [[-180, -20], [-140, -20]], CHALK_WHITE, 2.0)
			_add_stroke(n, [[-100, -30], [-100, 0]], CHALK_WHITE, 2.0)
			_add_stroke(n, [[-80, -30], [-80, 0]], CHALK_WHITE, 2.0)
			_add_stroke(n, [[-40, -20], [0, -20]], CHALK_WHITE, 2.0)
			_add_stroke(n, [[40, -30], [80, -10]], CHALK_WHITE, 2.0)
			# Underline
			_add_stroke(n, [[-200, 30], [200, 30]], Color(0.9, 0.9, 0.8, 0.5), 2.0)

		"school_chat_phone":
			# Smartphone interface displaying the chat application
			var phone_poly := [[-120, -180], [120, -180], [120, 180], [-120, 180], [-120, -180]]
			_add_fill(n, phone_poly, PAPER)
			_add_stroke(n, phone_poly, ink, 3.2)
			# Top header bar (chat app header)
			var header_poly := [[-120, -180], [120, -180], [120, -125], [-120, -125], [-120, -180]]
			_add_fill(n, header_poly, Color("#dfe6ec"))
			_add_stroke(n, header_poly, ink, 2.0)
			# Back arrow and contact avatar circle
			_add_stroke(n, [[-100, -152], [-85, -162], [-85, -142]], ink, 2.2) # back arrow
			_add_fill(n, [[-70, -165], [-45, -165], [-45, -140], [-70, -140], [-70, -165]], ROSE_CRUSH) # crush avatar
			_add_stroke(n, [[-70, -165], [-45, -165], [-45, -140], [-70, -140], [-70, -165]], ink, 1.8)
			# Contact name line
			_add_stroke(n, [[-35, -155], [40, -155]], ink, 2.5)
			# Status / last seen line
			_add_stroke(n, [[-35, -142], [20, -142]], INK_FAINT, 1.5)
			# Home bar at bottom
			_add_stroke(n, [[-35, 165], [35, 165]], INK_SOFT, 2.5)

		"chat_bubble_outgoing_1":
			# Outgoing message 1: "Hey, how's it going?"
			var bubble_1 := [[-70, -35], [110, -35], [110, 15], [-60, 15], [-70, 25], [-68, 15], [-70, 15], [-70, -35]]
			_add_fill(n, bubble_1, Color("#d6e9f8")) # Soft blue outgoing bubble
			_add_stroke(n, bubble_1, ink, 2.4)
			# Text lines inside bubble
			_add_stroke(n, [[-50, -18], [80, -18]], ink, 2.4)
			_add_stroke(n, [[-50, -2], [40, -2]], ink, 2.0)
			# Timestamp & sent checkmark
			_add_stroke(n, [[65, 8], [85, 8]], INK_FAINT, 1.4)
			_add_stroke(n, [[92, 6], [96, 10], [102, 4]], BLUE_CHAT, 1.6)

		"chat_bubble_outgoing_2":
			# Outgoing message 2 (the desperate double text): "Did you see my message?"
			var bubble_2 := [[-80, -40], [115, -40], [115, 20], [-65, 20], [-78, 32], [-74, 20], [-80, 20], [-80, -40]]
			_add_fill(n, bubble_2, Color("#d6e9f8"))
			_add_stroke(n, bubble_2, ink, 2.4)
			# Text lines inside bubble
			_add_stroke(n, [[-60, -20], [90, -20]], ink, 2.4)
			_add_stroke(n, [[-60, -2], [65, -2]], ink, 2.0)
			# Timestamp & double checkmark (waiting in silence)
			_add_stroke(n, [[60, 12], [85, 12]], INK_FAINT, 1.4)
			_add_stroke(n, [[92, 10], [96, 14], [102, 8]], INK_SOFT, 1.6) # single check, no read receipt!

		"deactivated_contact_card":
			# The vanishing profile: Friend list showing blank silhouette and "User Not Found"
			var card_poly := [[-140, -80], [140, -80], [140, 80], [-140, 80], [-140, -80]]
			_add_fill(n, card_poly, PAPER)
			_add_stroke(n, card_poly, ink, 2.8)
			# Gray blank silhouette avatar circle
			var avatar_box := [[-115, -45], [-55, -45], [-55, 15], [-115, 15], [-115, -45]]
			_add_fill(n, avatar_box, Color("#d5d8dc")) # Mystery blank gray
			_add_stroke(n, avatar_box, INK_SOFT, 2.0)
			# Question mark over avatar
			_add_stroke(n, [[-90, -32], [-80, -40], [-75, -30], [-85, -20], [-85, -12]], INK_MAIN, 2.2)
			_add_stroke(n, [[-85, -5], [-85, -3]], INK_MAIN, 2.8)
			# "Account Not Found" label
			_add_stroke(n, [[-35, -28], [110, -28]], INK_MAIN, 2.6)
			_add_stroke(n, [[-35, -8], [70, -8]], INK_FAINT, 2.0)
			# Red diagonal slash indicating inactive/gone
			_add_stroke(n, [[-125, -55], [125, 55]], Color(0.8, 0.3, 0.3, 0.4), 2.2)

		"peaceful_delusion_badge":
			# Comedic "Social Media Detox" award badge: halo, wings, and academic book
			# Halo at top
			_add_stroke(n, [[-50, -75], [0, -85], [50, -75], [0, -65], [-50, -75]], Color("#f1c40f"), 3.0)
			# Angel wings on sides
			_add_stroke(n, [[-35, -40], [-80, -60], [-70, -20], [-40, -10]], Color("#a0b2c6"), 2.2)
			_add_stroke(n, [[35, -40], [80, -60], [70, -20], [40, -10]], Color("#a0b2c6"), 2.2)
			# Center study book
			var book := [[-45, -20], [45, -20], [40, 40], [-40, 40], [-45, -20]]
			_add_fill(n, book, WOOD_TOP)
			_add_stroke(n, book, ink, 2.5)
			# "RESPECT" banner across bottom
			var banner := [[-65, 30], [65, 30], [65, 65], [-65, 65], [-65, 30]]
			_add_fill(n, banner, PAPER)
			_add_stroke(n, banner, ink, 2.4)
			_add_stroke(n, [[-45, 48], [45, 48]], ink, 2.8) # "RESPECT" text line

		"rival_boyfriend_diagram":
			# Diagram showing the crush girl linked to the primary school rival boy!
			# Girl node (center)
			var girl_box := [[-30, -50], [30, -50], [30, 10], [-30, 10], [-30, -50]]
			_add_fill(n, girl_box, Color(0.96, 0.88, 0.88))
			_add_stroke(n, girl_box, ink, 2.6)
			_add_stroke(n, [[-10, -25], [0, -35], [10, -25], [0, -15], [-10, -25]], ROSE_CRUSH, 2.0)
			# Rival boy node (right)
			var boy_box := [[120, -50], [180, -50], [180, 10], [120, 10], [120, -50]]
			_add_fill(n, boy_box, Color(0.88, 0.92, 0.96))
			_add_stroke(n, boy_box, ink, 2.6)
			_add_stroke(n, [[135, -25], [165, -25], [150, -15], [135, -25]], ink, 2.0) # smug smirk
			# Active chat heart connection between them
			_add_stroke(n, [[30, -20], [120, -20]], ROSE_CRUSH, 3.0)
			_add_stroke(n, [[75, -40], [85, -25], [75, -20], [65, -25], [75, -40]], ROSE_CRUSH, 2.2) # heart
			# Green "ONLINE" indicator on their connection
			_add_fill(n, [[65, -8], [85, -8], [85, 12], [65, 12], [65, -8]], GREEN_STATUS)
			_add_stroke(n, [[65, -8], [85, -8], [85, 12], [65, 12], [65, -8]], ink, 1.5)
			# ADB node on left (severed connection)
			var adb_box := [[-180, -50], [-120, -50], [-120, 10], [-180, 10], [-180, -50]]
			_add_fill(n, adb_box, WASH)
			_add_stroke(n, adb_box, ink, 2.6)
			# Broken connection line from ADB with "X" mark
			_add_stroke(n, [[-120, -20], [-60, -20]], INK_FAINT, 2.0)
			_add_stroke(n, [[-80, -30], [-60, -10]], RED_BLOCKED, 3.0) # X
			_add_stroke(n, [[-60, -30], [-80, -10]], RED_BLOCKED, 3.0)

		"blocked_stamp":
			# Dramatic red BLOCKED stamp slamming onto the frame
			var stamp_poly := [[-130, -50], [130, -50], [130, 50], [-130, 50], [-130, -50]]
			_add_fill(n, stamp_poly, Color(0.9, 0.3, 0.3, 0.15))
			_add_stroke(n, stamp_poly, RED_BLOCKED, 4.5)
			# Inner border
			var inner_poly := [[-120, -42], [120, -42], [120, 42], [-120, 42], [-120, -42]]
			_add_stroke(n, inner_poly, RED_BLOCKED, 2.2)
			# "BLOCKED" bold letters
			# B
			_add_stroke(n, [[-95, -25], [-95, 25]], RED_BLOCKED, 4.0)
			_add_stroke(n, [[-95, -25], [-75, -25], [-75, 0], [-95, 0]], RED_BLOCKED, 3.5)
			_add_stroke(n, [[-95, 0], [-70, 0], [-70, 25], [-95, 25]], RED_BLOCKED, 3.5)
			# L
			_add_stroke(n, [[-60, -25], [-60, 25], [-45, 25]], RED_BLOCKED, 3.8)
			# O
			_add_stroke(n, [[-35, -25], [-15, -25], [-15, 25], [-35, 25], [-35, -25]], RED_BLOCKED, 3.8)
			# C
			_add_stroke(n, [[10, -25], [-5, -25], [-5, 25], [10, 25]], RED_BLOCKED, 3.8)
			# K
			_add_stroke(n, [[20, -25], [20, 25]], RED_BLOCKED, 4.0)
			_add_stroke(n, [[38, -25], [20, 0], [38, 25]], RED_BLOCKED, 3.5)
			# E
			_add_stroke(n, [[48, -25], [48, 25], [65, 25]], RED_BLOCKED, 3.8)
			_add_stroke(n, [[48, -25], [65, -25]], RED_BLOCKED, 3.5)
			_add_stroke(n, [[48, 0], [60, 0]], RED_BLOCKED, 3.5)
			# D
			_add_stroke(n, [[75, -25], [75, 25]], RED_BLOCKED, 4.0)
			_add_stroke(n, [[75, -25], [95, -10], [95, 10], [75, 25]], RED_BLOCKED, 3.8)

		"broken_heart_doodle":
			# Shattered heart in two halves with jagged lightning fracture down the center
			# Left heart lobe
			var left_heart := [[0, -40], [-35, -75], [-70, -45], [-70, 0], [-30, 45], [0, 75], [-5, 45], [5, 20], [-8, -5], [5, -25], [0, -40]]
			_add_fill(n, left_heart, Color(0.9, 0.45, 0.45, 0.35))
			_add_stroke(n, left_heart, RED_BLOCKED, 3.2)
			# Right heart lobe (separated slightly)
			var right_heart := [[15, -40], [50, -75], [85, -45], [85, 0], [45, 45], [15, 75], [10, 45], [20, 20], [8, -5], [20, -25], [15, -40]]
			_add_fill(n, right_heart, Color(0.9, 0.45, 0.45, 0.35))
			_add_stroke(n, right_heart, RED_BLOCKED, 3.2)
			# Comedic tear droplet falling from heart
			_add_fill(n, [[5, 90], [15, 110], [5, 125], [-5, 110], [5, 90]], Color("#74b9ff"))
			_add_stroke(n, [[5, 90], [15, 110], [5, 125], [-5, 110], [5, 90]], ink, 1.8)

	return n
