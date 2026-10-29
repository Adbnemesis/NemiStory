extends RefCounted
## ScamEpisodeArt — Hand-inked vector storytime illustrations for Nemi EP14 "I Got Scammed"
## Follows EP06 cream paper theme:
## - Ink contours in canonical burgundy (#3d272a / #513541)
## - Pale washes (#efe2c8, #ece5d8, #e5d4bb), warm cream paper (#faf6ee)
## - Selective accent colors: concert red (#c05c58), ticket gold (#dfb868), bank blue (#6b9bc7), scam warning red (#d9433e)
## - 100% Vector LiveDrawing format with stable held and live stroke playback

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"scam_concert_poster",
	"scam_sold_out_screen",
	"scam_resale_listing",
	"scam_detective_badge",
	"scam_sherlock_pipe",
	"scam_urgency_timer",
	"scam_bank_transfer",
	"scam_blocked_alert",
	"scam_empty_wallet",
	"scam_ghost_soul"
]

const INK_MAIN: Color = Color("#3d272a")
const INK_FAINT: Color = Color(0.24, 0.15, 0.16, 0.25)
const INK_SOFT: Color = Color(0.24, 0.15, 0.16, 0.45)
const PAPER: Color = Color("#fffdf8")
const WASH: Color = Color("#ece5d8")
const GOLD_TICKET: Color = Color("#dfb868")
const RED_ALERT: Color = Color("#d9433e")
const BLUE_APP: Color = Color("#6b9bc7")
const GREEN_VERIFIED: Color = Color("#55a872")

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
		"scam_concert_poster":
			# Huge concert tour announcement poster with stars and golden ticket stub
			var poster_poly := [[-160, -220], [160, -220], [160, 220], [-160, 220], [-160, -220]]
			_add_fill(n, poster_poly, Color("#f5eedc"))
			_add_stroke(n, poster_poly, ink, 3.2)
			# Top header banner
			var header_poly := [[-150, -205], [150, -205], [145, -145], [-145, -145], [-150, -205]]
			_add_fill(n, header_poly, Color("#d95a53"))
			_add_stroke(n, header_poly, ink, 2.2)
			# "WORLD TOUR" text lines
			_add_stroke(n, [[-110, -180], [110, -180]], PAPER, 3.5)
			_add_stroke(n, [[-80, -165], [80, -165]], PAPER, 2.2)
			# Band silhouettes in center
			_add_fill(n, [[-90, -40], [-60, -110], [-30, -40], [-90, -40]], Color("#6e5560"))
			_add_fill(n, [[-30, -30], [0, -120], [30, -30], [-30, -30]], Color("#4e3943"))
			_add_fill(n, [[30, -40], [60, -105], [90, -40], [30, -40]], Color("#6e5560"))
			# Stage spotlights
			_add_stroke(n, [[-130, -130], [-50, -20]], Color(0.9, 0.85, 0.6, 0.4), 3.0)
			_add_stroke(n, [[130, -130], [50, -20]], Color(0.9, 0.85, 0.6, 0.4), 3.0)
			# Golden VIP ticket stub pinned to the bottom
			var ticket_poly := [[-120, 70], [120, 70], [110, 160], [-110, 160], [-120, 70]]
			_add_fill(n, ticket_poly, GOLD_TICKET)
			_add_stroke(n, ticket_poly, ink, 2.6)
			# Perforated ticket edge
			_add_stroke(n, [[40, 70], [40, 160]], ink, 2.0)
			_add_stroke(n, [[-90, 105], [20, 105]], ink, 3.0)
			_add_stroke(n, [[-90, 125], [-10, 125]], INK_SOFT, 2.0)
			_add_stroke(n, [[60, 115], [95, 115]], ink, 2.4) # "VIP"

		"scam_sold_out_screen":
			# Laptop monitor displaying the red "SOLD OUT" ticket drop disaster
			var mon_poly := [[-210, -130], [210, -130], [210, 90], [-210, 90], [-210, -130]]
			_add_fill(n, mon_poly, PAPER)
			_add_stroke(n, mon_poly, ink, 3.4)
			# Browser address bar & tabs
			var bar_poly := [[-210, -130], [210, -130], [210, -95], [-210, -95], [-210, -130]]
			_add_fill(n, bar_poly, WASH)
			_add_stroke(n, bar_poly, ink, 1.8)
			_add_stroke(n, [[-190, -112], [-140, -112]], INK_SOFT, 2.0)
			_add_stroke(n, [[-120, -112], [140, -112]], INK_FAINT, 1.6)
			# Giant RED SOLD OUT stamped banner
			var stamp_poly := [[-160, -40], [160, -55], [165, 45], [-155, 60], [-160, -40]]
			_add_fill(n, stamp_poly, Color(0.9, 0.25, 0.22, 0.15))
			_add_stroke(n, stamp_poly, RED_ALERT, 4.0)
			_add_stroke(n, [[-130, -5], [130, -15]], RED_ALERT, 5.0) # SOLD OUT text bar
			_add_stroke(n, [[-100, 22], [100, 12]], RED_ALERT, 2.8) # 0 SEATS REMAINING
			# Base stand of laptop
			_add_fill(n, [[-240, 90], [240, 90], [260, 115], [-260, 115], [-240, 90]], WASH)
			_add_stroke(n, [[-260, 115], [260, 115]], ink, 3.0)

		"scam_resale_listing":
			# Shady resale social media forum post card
			var card_poly := [[-170, -110], [170, -110], [170, 110], [-170, 110], [-170, -110]]
			_add_fill(n, card_poly, PAPER)
			_add_stroke(n, card_poly, ink, 2.8)
			# Shady seller avatar with sunglasses
			var av_poly := [[-145, -85], [-85, -85], [-85, -25], [-145, -25], [-145, -85]]
			_add_fill(n, av_poly, Color("#dcd6ce"))
			_add_stroke(n, av_poly, ink, 2.0)
			_add_fill(n, [[-135, -60], [-95, -60], [-95, -50], [-135, -50], [-135, -60]], INK_MAIN) # sunglasses
			# Username "@legit_tickets_vip"
			_add_stroke(n, [[-70, -65], [60, -65]], ink, 3.0)
			_add_stroke(n, [[-70, -45], [20, -45]], INK_FAINT, 1.8)
			# Post body text lines: "Friend got sick! Selling 2 VIP passes face value! DM fast!"
			_add_stroke(n, [[-140, -5], [140, -5]], INK_SOFT, 2.4)
			_add_stroke(n, [[-140, 20], [120, 20]], INK_SOFT, 2.4)
			_add_stroke(n, [[-140, 45], [40, 45]], INK_SOFT, 2.4)
			# Green "ONLINE NOW" badge
			_add_fill(n, [[100, -85], [145, -85], [145, -65], [100, -65], [100, -85]], GREEN_VERIFIED)
			_add_stroke(n, [[100, -85], [145, -85], [145, -65], [100, -65], [100, -85]], ink, 1.5)

		"scam_detective_badge":
			# Comedic magnifying glass inspecting proof of purchase
			# Magnifying glass circular rim
			var rim_pts: Array = []
			for i in range(17):
				var ang: float = float(i) * TAU / 16.0
				rim_pts.append([cos(ang) * 65.0 - 20.0, sin(ang) * 65.0 - 20.0])
			_add_fill(n, rim_pts, Color(0.85, 0.92, 0.95, 0.4))
			_add_stroke(n, rim_pts, ink, 3.8)
			# Handle extending diagonally down-right
			_add_fill(n, [[25, 25], [105, 105], [90, 120], [10, 40], [25, 25]], Color("#9c6b48"))
			_add_stroke(n, [[25, 25], [105, 105], [90, 120], [10, 40], [25, 25]], ink, 2.8)
			# Checklist inside view: 3 green checkmarks
			_add_stroke(n, [[-60, -45], [-50, -35], [-30, -55]], GREEN_VERIFIED, 3.0)
			_add_stroke(n, [[-20, -45], [30, -45]], ink, 2.2)
			_add_stroke(n, [[-60, -15], [-50, -5], [-30, -25]], GREEN_VERIFIED, 3.0)
			_add_stroke(n, [[-20, -15], [20, -15]], ink, 2.2)
			_add_stroke(n, [[-60, 15], [-50, 25], [-30, 5]], GREEN_VERIFIED, 3.0)
			_add_stroke(n, [[-20, 15], [35, 15]], ink, 2.2)

		"scam_sherlock_pipe":
			# Comedic Sherlock Holmes pipe doodle
			var bowl := [[-40, -20], [-10, -20], [-15, 30], [-35, 30], [-40, -20]]
			_add_fill(n, bowl, Color("#8c5835"))
			_add_stroke(n, bowl, ink, 3.0)
			_add_stroke(n, [[-25, 30], [20, 35], [55, 10], [75, 5]], Color("#4a3728"), 3.2)
			# Swirl of smoke
			_add_stroke(n, [[-25, -25], [-30, -45], [-15, -60], [-35, -80]], INK_FAINT, 2.0, true)

		"scam_urgency_timer":
			# Ticking red countdown clock: "4:59 REMAINING"
			var box := [[-120, -45], [120, -45], [120, 45], [-120, 45], [-120, -45]]
			_add_fill(n, box, Color(0.95, 0.9, 0.88))
			_add_stroke(n, box, RED_ALERT, 3.2)
			# Alarm bell ears
			_add_stroke(n, [[-100, -45], [-115, -65], [-90, -55]], RED_ALERT, 2.5)
			_add_stroke(n, [[100, -45], [115, -65], [90, -55]], RED_ALERT, 2.5)
			# "04:59" bold numbers bar
			_add_stroke(n, [[-80, 0], [-55, 0]], RED_ALERT, 4.0)
			_add_stroke(n, [[-40, -8], [-40, -4]], RED_ALERT, 3.0)
			_add_stroke(n, [[-40, 8], [-40, 4]], RED_ALERT, 3.0)
			_add_stroke(n, [[-25, 0], [10, 0]], RED_ALERT, 4.0)
			_add_stroke(n, [[30, 0], [75, 0]], RED_ALERT, 4.0)

		"scam_bank_transfer":
			# Smartphone banking app payment confirmation
			var phone_poly := [[-110, -170], [110, -170], [110, 170], [-110, 170], [-110, -170]]
			_add_fill(n, phone_poly, PAPER)
			_add_stroke(n, phone_poly, ink, 3.2)
			# Blue app header
			var header := [[-110, -170], [110, -170], [110, -120], [-110, -120], [-110, -170]]
			_add_fill(n, header, BLUE_APP)
			_add_stroke(n, header, ink, 2.0)
			# Big green checkmark: PAYMENT SENT
			var check_circle: Array = []
			for i in range(17):
				var a: float = float(i) * TAU / 16.0
				check_circle.append([cos(a) * 35.0, sin(a) * 35.0 - 45.0])
			_add_fill(n, check_circle, Color(0.85, 0.95, 0.88))
			_add_stroke(n, check_circle, GREEN_VERIFIED, 2.8)
			_add_stroke(n, [[-15, -45], [-5, -35], [18, -58]], GREEN_VERIFIED, 3.5)
			# Amount deducted: -$320.00
			_add_stroke(n, [[-65, 10], [65, 10]], RED_ALERT, 3.8)
			# Remaining balance: $1.42
			_add_stroke(n, [[-50, 45], [50, 45]], INK_FAINT, 2.0)
			_add_stroke(n, [[-30, 70], [30, 70]], INK_FAINT, 1.8)

		"scam_blocked_alert":
			# The sudden block alert: glowing red triangle dialog
			var alert_box := [[-150, -90], [150, -90], [150, 90], [-150, 90], [-150, -90]]
			_add_fill(n, alert_box, Color("#2b2225")) # Dark ominous modal
			_add_stroke(n, alert_box, RED_ALERT, 3.5)
			# Warning triangle
			var tri := [[0, -65], [45, 10], [-45, 10], [0, -65]]
			_add_fill(n, tri, RED_ALERT)
			_add_stroke(n, tri, PAPER, 2.5)
			# Exclamation mark inside
			_add_stroke(n, [[0, -45], [0, -15]], PAPER, 3.5)
			_add_stroke(n, [[0, -3], [0, 0]], PAPER, 4.0)
			# Text: "USER BLOCKED"
			_add_stroke(n, [[-95, 35], [95, 35]], PAPER, 3.2)
			_add_stroke(n, [[-70, 60], [70, 60]], Color(0.9, 0.6, 0.6), 2.2)

		"scam_empty_wallet":
			# Open empty leather wallet with cobweb and a tiny moth
			var wallet := [[-110, -50], [110, -50], [90, 60], [-90, 60], [-110, -50]]
			_add_fill(n, wallet, Color("#7a5238"))
			_add_stroke(n, wallet, ink, 3.4)
			# Empty interior pouch
			var inside := [[-85, -30], [85, -30], [70, 45], [-70, 45], [-85, -30]]
			_add_fill(n, inside, Color("#523624"))
			_add_stroke(n, inside, ink, 2.0)
			# Cobweb corner
			_add_stroke(n, [[-80, -25], [-50, 0]], Color(0.8, 0.8, 0.8, 0.5), 1.6)
			_add_stroke(n, [[-80, -5], [-60, 20]], Color(0.8, 0.8, 0.8, 0.5), 1.6)
			# Tiny fluttery moth doodle escaping
			_add_stroke(n, [[30, -70], [45, -85], [35, -65]], ink, 1.8)
			_add_stroke(n, [[50, -70], [35, -85], [45, -65]], ink, 1.8)

		"scam_ghost_soul":
			# Comedic spirit/soul doodle floating upwards
			var soul := [[-30, 50], [-40, 0], [-25, -50], [0, -70], [25, -50], [40, 0], [30, 50], [15, 30], [0, 55], [-15, 30], [-30, 50]]
			_add_fill(n, soul, Color(0.9, 0.95, 1.0, 0.55))
			_add_stroke(n, soul, Color("#768c99"), 2.4, true)
			# Peaceful closed eyes & open mouth
			_add_stroke(n, [[-18, -35], [-8, -35]], Color("#536673"), 2.0)
			_add_stroke(n, [[8, -35], [18, -35]], Color("#536673"), 2.0)
			_add_stroke(n, [[-5, -15], [5, -15]], Color("#536673"), 2.0)

		_:
			assert(false, "Unknown ScamEpisodeArt prop: " + kind)

	n.prepare()
	return n
