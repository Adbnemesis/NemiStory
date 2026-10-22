extends RefCounted
## MovingOnArt — Hand-inked storytime illustrations for ADB EP07 "How I Got Over My Crush"
## Adheres strictly to the EP06/EP07 paper colour reference:
## - Contours in #2b2623 (charcoal ink)
## - Pale sepia/wood washes (#eedfc8, #e5d4bb), warm cream paper (#faf6ee)
## - Selective red/rose accents (#c05c58), soft blue chat (#6b9bc7), muted green/ochre
## - 100% Vector LiveDrawing format with stable held and live stroke playback

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"post_confession_chat",
	"hallway_fight_doodle",
	"blocked_again_screen",
	"five_year_breakup_timeline",
	"wingmen_matchmaking_board",
	"unblocked_notification",
	"dating_again_announcement",
	"pedestal_shattered",
	"real_friends_desk",
	"college_nemi_cameo"
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
		"post_confession_chat":
			# Phone screen with casual message bubbles ("Homework page 42")
			var phone_poly := [[-120, -170], [120, -170], [120, 170], [-120, 170], [-120, -170]]
			_add_fill(n, phone_poly, PAPER)
			_add_stroke(n, phone_poly, ink, 3.2)
			# Top header bar
			var header_poly := [[-115, -165], [115, -165], [115, -125], [-115, -125], [-115, -165]]
			_add_fill(n, header_poly, WASH)
			_add_stroke(n, [[-115, -125], [115, -125]], ink, 1.8)
			# Outgoing bubble
			var b1_poly := [[-30, -100], [105, -100], [105, -60], [-30, -60], [-30, -100]]
			_add_fill(n, b1_poly, BLUE_CHAT)
			_add_stroke(n, b1_poly, ink, 2.0)
			_add_stroke(n, [[-15, -80], [85, -80]], PAPER, 2.2) # text placeholder
			# Incoming bubble
			var b2_poly := [[-105, -45], [30, -45], [30, -5], [-105, -5], [-105, -45]]
			_add_fill(n, b2_poly, WASH)
			_add_stroke(n, b2_poly, ink, 2.0)
			_add_stroke(n, [[-90, -25], [15, -25]], INK_SOFT, 2.2)
			# Second outgoing bubble
			var b3_poly := [[-20, 15], [105, 15], [105, 55], [-20, 55], [-20, 15]]
			_add_fill(n, b3_poly, BLUE_CHAT)
			_add_stroke(n, b3_poly, ink, 2.0)
			_add_stroke(n, [[-5, 35], [85, 35]], PAPER, 2.2)

		"hallway_fight_doodle":
			# Hallway quarrel: jagged argument lightning, tear drops, distant quarrel silhouettes
			var card_poly := [[-150, -110], [150, -110], [150, 110], [-150, 110], [-150, -110]]
			_add_fill(n, card_poly, PAPER)
			_add_stroke(n, card_poly, ink, 3.0)
			# Floor perspective line
			_add_stroke(n, [[-140, 60], [140, 60]], INK_FAINT, 1.8)
			# Jagged lightning argument bolt in center
			var bolt := [[-10, -70], [15, -25], [-15, 0], [20, 45]]
			_add_stroke(n, bolt, RED_ACCENT, 3.5)
			# Tear drops on right
			_add_stroke(n, [[60, -30], [55, -15], [65, -15], [60, -30]], BLUE_CHAT, 2.0)
			_add_stroke(n, [[75, 5], [70, 20], [80, 20], [75, 5]], BLUE_CHAT, 2.0)
			# Agitated scribble clouds
			_add_stroke(n, [[-80, -50], [-50, -65], [-30, -45], [-55, -30], [-80, -50]], INK_SOFT, 2.0)
			_add_stroke(n, [[50, -70], [80, -60], [100, -40], [70, -35], [50, -70]], INK_SOFT, 2.0)

		"blocked_again_screen":
			# Phone screen with red blocked alert banner: "You have been blocked by this contact"
			var phone_poly := [[-130, -180], [130, -180], [130, 180], [-130, 180], [-130, -180]]
			_add_fill(n, phone_poly, PAPER)
			_add_stroke(n, phone_poly, ink, 3.4)
			# Big Red Block Banner across screen
			var banner_poly := [[-120, -60], [120, -60], [120, 60], [-120, 60], [-120, -60]]
			_add_fill(n, banner_poly, Color("#fae5e5"))
			_add_stroke(n, banner_poly, RED_ACCENT, 2.8)
			# Red alert exclamation circle
			var alert_circle := [[-30, -35], [30, -35], [30, 25], [-30, 25], [-30, -35]]
			_add_stroke(n, [[0, -25], [0, 0]], RED_ACCENT, 4.0)
			_add_stroke(n, [[0, 12], [0, 16]], RED_ACCENT, 4.0)
			# "BLOCKED AGAIN" text underlines
			_add_stroke(n, [[-80, 40], [80, 40]], RED_ACCENT, 2.2)
			_add_stroke(n, [[-60, 95], [60, 95]], INK_SOFT, 1.8)

		"five_year_breakup_timeline":
			# 5-year relationship timeline ending with a snapped link
			var card_poly := [[-160, -95], [160, -95], [160, 95], [-160, 95], [-160, -95]]
			_add_fill(n, card_poly, PAPER)
			_add_stroke(n, card_poly, ink, 3.0)
			# Timeline horizontal axis
			_add_stroke(n, [[-130, 0], [40, 0]], INK_MAIN, 2.8)
			# Snapped line jumping off
			_add_stroke(n, [[45, -5], [70, -30]], RED_ACCENT, 3.0)
			_add_stroke(n, [[45, 5], [75, 30]], RED_ACCENT, 3.0)
			# "5 YEARS" badge
			_add_stroke(n, [[-110, -50], [-40, -50], [-40, -20], [-110, -20], [-110, -50]], WASH, 2.0)
			_add_stroke(n, [[-100, -35], [-50, -35]], INK_MAIN, 2.2)
			# Snapped link cross marks
			_add_stroke(n, [[80, -15], [110, 15]], RED_ACCENT, 3.2)
			_add_stroke(n, [[110, -15], [80, 15]], RED_ACCENT, 3.2)

		"wingmen_matchmaking_board":
			# Tactical whiteboard: "MISSION: GET THEM TOGETHER" with big squad arrows
			var board_poly := [[-170, -115], [170, -115], [170, 115], [-170, 115], [-170, -115]]
			_add_fill(n, board_poly, Color("#faf4eb"))
			_add_stroke(n, board_poly, ink, 3.2)
			# "MISSION" header box
			_add_stroke(n, [[-140, -95], [140, -95]], INK_SOFT, 1.5)
			# Left node: AIDEN
			var n1 := [[-120, -40], [-60, -40], [-60, 20], [-120, 20], [-120, -40]]
			_add_fill(n, n1, WASH)
			_add_stroke(n, n1, ink, 2.2)
			# Right node: CRUSH
			var n2 := [[60, -40], [120, -40], [120, 20], [60, 20], [60, -40]]
			_add_fill(n, n2, Color("#fae5e5"))
			_add_stroke(n, n2, ROSE_CRUSH, 2.2)
			# Big double-headed squad arrow in center
			_add_stroke(n, [[-50, -10], [50, -10]], GREEN_STATUS, 3.5)
			_add_stroke(n, [[35, -22], [50, -10], [35, 2]], GREEN_STATUS, 3.0)
			_add_stroke(n, [[-35, -22], [-50, -10], [-35, 2]], GREEN_STATUS, 3.0)
			# Tactical exclamation
			_add_stroke(n, [[-40, 55], [40, 55]], INK_MAIN, 2.4)

		"unblocked_notification":
			# Green alert card: "Contact Unblocked" with open padlock icon
			var card_poly := [[-140, -75], [140, -75], [140, 75], [-140, 75], [-140, -75]]
			_add_fill(n, card_poly, Color("#eaf5ed"))
			_add_stroke(n, card_poly, GREEN_STATUS, 3.0)
			# Open padlock symbol
			_add_stroke(n, [[-70, -10], [-70, -35], [-40, -35], [-40, -15]], GREEN_STATUS, 3.2) # shackle open
			var lock_body := [[-80, -10], [-30, -10], [-30, 35], [-80, 35], [-80, -10]]
			_add_fill(n, lock_body, GREEN_STATUS)
			_add_stroke(n, lock_body, ink, 2.2)
			# Notification text placeholder lines
			_add_stroke(n, [[-10, -10], [110, -10]], INK_MAIN, 2.6)
			_add_stroke(n, [[-10, 15], [80, 15]], INK_SOFT, 2.0)

		"dating_again_announcement":
			# Shocking relationship status update: "In a relationship again!"
			var card_poly := [[-160, -105], [160, -105], [160, 105], [-160, 105], [-160, -105]]
			_add_fill(n, card_poly, PAPER)
			_add_stroke(n, card_poly, ink, 3.2)
			# Comic shock border burst
			_add_stroke(n, [[-140, -85], [140, -85], [140, 85], [-140, 85], [-140, -85]], RED_ACCENT, 1.8)
			# Big bold status symbol
			_add_stroke(n, [[-100, -30], [100, -30]], RED_ACCENT, 3.6)
			_add_stroke(n, [[-70, 10], [70, 10]], INK_MAIN, 2.8)
			# Triple question marks / exclamation
			_add_stroke(n, [[80, -65], [115, -65], [115, -45], [95, -35], [95, -20]], RED_ACCENT, 2.6)
			_add_stroke(n, [[95, -10], [95, -6]], RED_ACCENT, 3.0)
			_add_stroke(n, [[125, -65], [125, -25]], RED_ACCENT, 3.0)
			_add_stroke(n, [[125, -10], [125, -6]], RED_ACCENT, 3.0)

		"pedestal_shattered":
			# Classical pedestal with cracking lines and tumbling heart idol
			var card_poly := [[-150, -130], [150, -130], [150, 130], [-150, 130], [-150, -130]]
			_add_fill(n, card_poly, PAPER)
			_add_stroke(n, card_poly, ink, 3.0)
			# Pedestal base
			var base_poly := [[-90, 60], [90, 60], [100, 100], [-100, 100], [-90, 60]]
			_add_fill(n, base_poly, WASH)
			_add_stroke(n, base_poly, ink, 2.8)
			# Pedestal column with jagged crack
			var col_poly := [[-60, -30], [60, -30], [65, 60], [-65, 60], [-60, -30]]
			_add_fill(n, col_poly, Color("#f3eee5"))
			_add_stroke(n, col_poly, ink, 2.6)
			# Big jagged crack through column
			_add_stroke(n, [[-20, -30], [15, 0], [-10, 25], [20, 60]], INK_MAIN, 3.2)
			# Tumbling heart icon rolling off top
			_add_stroke(n, [[30, -70], [55, -95], [80, -70], [55, -45], [30, -70]], ROSE_CRUSH, 2.8)
			# "FEELINGS = GONE" dry strikeout
			_add_stroke(n, [[-110, -10], [110, -10]], RED_ACCENT, 3.5)

		"real_friends_desk":
			# Classroom desk with two shared drink cups and genuine friendly homework notes
			var desk_poly := [[-160, 20], [160, 20], [130, 100], [-130, 100], [-160, 20]]
			_add_fill(n, desk_poly, WOOD_TOP)
			_add_stroke(n, desk_poly, ink, 3.2)
			# Cup 1 (tea/coffee)
			var c1 := [[-60, -20], [-30, -20], [-35, 30], [-55, 30], [-60, -20]]
			_add_fill(n, c1, PAPER)
			_add_stroke(n, c1, ink, 2.2)
			_add_stroke(n, [[-45, -35], [-45, -20]], INK_SOFT, 2.0) # straw
			# Cup 2 (juice/soda)
			var c2 := [[30, -20], [60, -20], [55, 30], [35, 30], [30, -20]]
			_add_fill(n, c2, PAPER)
			_add_stroke(n, c2, ink, 2.2)
			_add_stroke(n, [[45, -35], [45, -20]], INK_SOFT, 2.0) # straw
			# Friendly note paper on desk
			var note_poly := [[-20, 35], [20, 35], [20, 75], [-20, 75], [-20, 35]]
			_add_fill(n, note_poly, PAPER)
			_add_stroke(n, note_poly, ink, 1.8)
			_add_stroke(n, [[-12, 48], [12, 48]], INK_SOFT, 1.6)
			_add_stroke(n, [[-12, 60], [8, 60]], INK_SOFT, 1.6)

		"college_nemi_cameo":
			# Graduation scroll, college campus gate badge, and cute heart (<3)
			var badge_poly := [[-140, -110], [140, -110], [140, 110], [-140, 110], [-140, -110]]
			_add_fill(n, badge_poly, Color("#fbf8f2"))
			_add_stroke(n, badge_poly, ink, 3.2)
			# Graduation diploma scroll with ribbon
			var diploma := [[-90, -40], [10, -40], [10, -10], [-90, -10], [-90, -40]]
			_add_fill(n, diploma, PAPER)
			_add_stroke(n, diploma, ink, 2.2)
			_add_stroke(n, [[-45, -45], [-35, -5]], RED_ACCENT, 3.2) # red ribbon tie
			# Big warm heart (<3) in center right
			var heart := [[40, 10], [65, -15], [90, 10], [65, 45], [40, 10]]
			_add_fill(n, heart, ROSE_CRUSH)
			_add_stroke(n, heart, RED_ACCENT, 2.8)
			# "COLLEGE / NEMI <3" celebratory banner lines
			_add_stroke(n, [[-100, 60], [100, 60]], INK_MAIN, 2.6)
			_add_stroke(n, [[-60, 80], [60, 80]], GREEN_STATUS, 2.2)

	return n
