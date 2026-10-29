extends RefCounted
## EmbarrassedEpisodeArt — Hand-inked vector storytime illustrations for Nemi EP16 "I'm Embarrassed"
## Follows EP06 cream paper theme:
## - Ink contours in canonical burgundy (#3d272a / #513541)
## - Pale washes (#efe2c8, #ece5d8, #fffdf8), warm cream paper (#faf7f2)
## - Selective accents: muted red (#c05c58 / #ad5e69), sage green (#769d87), soft gold (#dfb868)
## - 100% Vector LiveDrawing format with stable held and live stroke playback

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"embarrassed_question_bubble",
	"embarrassed_normal_jobs",
	"embarrassed_derpy_cartoon",
	"embarrassed_polite_smile",
	"embarrassed_unemployed_stamp",
	"embarrassed_zero_earnings",
	"embarrassed_kofi_jar",
	"embarrassed_tablet_work",
	"embarrassed_clock_40h",
	"embarrassed_youtube_stats",
	"embarrassed_algorithm_monster",
	"embarrassed_doubt_cloud",
	"embarrassed_spark_heart",
	"embarrassed_next_frame"
]

const INK_MAIN: Color = Color("#3d272a")
const INK_ROSE: Color = Color("#ad5e69")
const INK_SAGE: Color = Color("#769d87")
const PAPER: Color = Color("#fffdf8")
const WASH: Color = Color("#ece5d8")
const SOFT_RED: Color = Color("#c05c58")
const SOFT_GOLD: Color = Color("#dfb868")

static func _add_stroke(n: Node2D, pts_raw: Array, col: Color = INK_MAIN, w: float = 3.0, smooth: bool = true) -> void:
	var pts := PackedVector2Array()
	for p in pts_raw: pts.append(Vector2(p[0], p[1]))
	n.stroke_list.append({"pts": pts, "col": col, "w": w, "smooth": smooth, "pause": 0.04, "pressure": PackedFloat32Array([0.5, 0.95, 0.85, 0.9, 0.4])})

static func _add_fill(n: Node2D, pts_raw: Array, col: Color) -> void:
	var pts := PackedVector2Array()
	for p in pts_raw: pts.append(Vector2(p[0], p[1]))
	n.fills.append({"poly": pts, "col": col, "at": 0.0})

static func make(author: String, kind: String) -> Node2D:
	var n = Drawing.new()
	var ink := Color(Profile.profile(author).ink)

	match kind:
		"embarrassed_question_bubble":
			# Speech bubble with "What do you do?" question mark from society
			var bubble := [[-160, -90], [160, -88], [165, 55], [-40, 56], [-85, 95], [-80, 58], [-162, 57], [-160, -90]]
			_add_fill(n, bubble, PAPER)
			_add_stroke(n, bubble, ink, 3.4, false)
			# Expressive large question mark in center
			_add_stroke(n, [[-30, -35], [-15, -55], [15, -55], [30, -35], [25, -15], [0, 5], [0, 16]], INK_ROSE, 4.5, false)
			_add_fill(n, [[-6, 25], [6, 25], [6, 37], [-6, 37]], INK_ROSE)
			# Small secondary question marks for awkward echo
			_add_stroke(n, [[-105, -20], [-92, -35], [-75, -35], [-65, -20], [-70, -8], [-82, 4], [-82, 10]], Color("#8f7980"), 2.6, false)
			_add_fill(n, [[-86, 16], [-78, 16], [-78, 24], [-86, 24]], Color("#8f7980"))
			_add_stroke(n, [[70, -15], [82, -28], [96, -28], [105, -15], [100, -5], [90, 4], [90, 10]], Color("#8f7980"), 2.6, false)
			_add_fill(n, [[86, 16], [94, 16], [94, 24], [86, 24]], Color("#8f7980"))

		"embarrassed_normal_jobs":
			# Briefcase / corporate career symbol representing respectable jobs
			var case_body := [[-140, -60], [140, -60], [145, 80], [-145, 80], [-140, -60]]
			_add_fill(n, case_body, Color("#e6dcce"))
			_add_stroke(n, case_body, ink, 3.2, false)
			# Handle
			_add_stroke(n, [[-45, -60], [-45, -95], [45, -95], [45, -60]], ink, 3.5, false)
			# Center lock and division
			_add_stroke(n, [[-140, 10], [140, 10]], ink, 2.0, false)
			_add_fill(n, [[-20, 0], [20, 0], [20, 22], [-20, 22], [-20, 0]], SOFT_GOLD)
			_add_stroke(n, [[-20, 0], [20, 0], [20, 22], [-20, 22], [-20, 0]], ink, 2.2, false)
			# Tie silhouette beside it
			_add_fill(n, [[160, -70], [195, -70], [205, 30], [178, 65], [150, 30], [160, -70]], SOFT_RED)
			_add_stroke(n, [[160, -70], [195, -70], [205, 30], [178, 65], [150, 30], [160, -70]], ink, 2.5, false)

		"embarrassed_polite_smile":
			# The awkward polite nod / pity reaction card
			var card := [[-140, -100], [140, -100], [140, 100], [-140, 100], [-140, -100]]
			_add_fill(n, card, PAPER)
			_add_stroke(n, card, ink, 3.0, false)
			# Eyes looking slightly sideways/awkward
			_add_stroke(n, [[-60, -40], [-40, -40]], ink, 3.5)
			_add_stroke(n, [[40, -40], [60, -40]], ink, 3.5)
			# Tight, flat, polite smile line
			_add_stroke(n, [[-50, 20], [0, 25], [50, 20]], INK_ROSE, 3.2)
			# Thought dots above
			for i in range(3):
				var dx: float = -30.0 + float(i) * 30.0
				_add_fill(n, [[dx - 6, 60], [dx + 6, 60], [dx + 6, 72], [dx - 6, 72]], Color("#ad5e69"))

		"embarrassed_zero_earnings":
			# Bank / revenue card with prominent $0.00
			var card := [[-180, -110], [180, -110], [185, 110], [-185, 110], [-180, -110]]
			_add_fill(n, card, PAPER)
			_add_stroke(n, card, ink, 3.5, false)
			# Header bar
			_add_fill(n, [[-175, -105], [175, -105], [175, -60], [-175, -60]], Color("#f0e6dc"))
			_add_stroke(n, [[-175, -60], [175, -60]], ink, 2.0, false)
			# Big "$0.00"
			# Dollar sign
			_add_stroke(n, [[-100, -25], [-70, -25], [-70, 5], [-100, 5], [-100, 35], [-70, 35]], SOFT_RED, 4.0)
			_add_stroke(n, [[-85, -40], [-85, 50]], SOFT_RED, 3.5, false)
			# Zero
			_add_stroke(n, [[-50, -30], [-20, -30], [-15, 40], [-45, 40], [-50, -30]], SOFT_RED, 4.5)
			# Point
			_add_fill(n, [[-5, 30], [5, 30], [5, 40], [-5, 40]], SOFT_RED)
			# Zero Zero
			_add_stroke(n, [[20, -30], [50, -30], [55, 40], [25, 40], [20, -30]], SOFT_RED, 4.0)
			_add_stroke(n, [[70, -30], [100, -30], [105, 40], [75, 40], [70, -30]], SOFT_RED, 4.0)
			# Subtitle underline
			_add_stroke(n, [[-130, 75], [130, 75]], ink, 1.8)

		"embarrassed_kofi_jar":
			# Hand-drawn Ko-fi cup / tip jar with solitary coins ("hardly anyone donates")
			var cup_body := [[-80, -70], [80, -70], [65, 80], [-65, 80], [-80, -70]]
			_add_fill(n, cup_body, PAPER)
			_add_stroke(n, cup_body, ink, 3.5, false)
			# Cup handle
			_add_stroke(n, [[80, -50], [115, -45], [115, 10], [75, 25]], ink, 3.2)
			# Little heart on cup
			_add_stroke(n, [[-20, -10], [-5, -25], [10, -10], [0, 15], [-10, 25], [-20, -10]], INK_ROSE, 3.0)
			# A couple of small lonely coins resting at the bottom of the tip cup
			_add_fill(n, [[-28, 48], [-6, 48], [-6, 68], [-28, 68]], SOFT_GOLD)
			_add_stroke(n, [[-28, 48], [-6, 48], [-6, 68], [-28, 68], [-28, 48]], ink, 2.0, false)
			_add_fill(n, [[-2, 52], [20, 52], [20, 72], [-2, 72]], SOFT_GOLD)
			_add_stroke(n, [[-2, 52], [20, 52], [20, 72], [-2, 72], [-2, 52]], ink, 2.0, false)

		"embarrassed_tablet_work":
			# Digital drawing tablet with active stylus and frame counter
			var tablet := [[-170, -100], [170, -100], [175, 95], [-175, 95], [-170, -100]]
			_add_fill(n, tablet, Color("#2e262a"))
			_add_stroke(n, tablet, ink, 3.5, false)
			# Screen area
			var screen := [[-140, -80], [140, -80], [140, 70], [-140, 70], [-140, -80]]
			_add_fill(n, screen, Color("#faf6ee"))
			_add_stroke(n, screen, ink, 2.0, false)
			# Timeline tracks
			_add_stroke(n, [[-130, 45], [130, 45]], Color("#d5c3bf"), 2.0, false)
			for i in range(8):
				var tx: float = -120.0 + float(i) * 32.0
				_add_stroke(n, [[tx, 35], [tx, 55]], INK_SAGE, 2.0, false)
			# Playhead / cursor
			_add_stroke(n, [[-20, 25], [-20, 65]], SOFT_RED, 2.5, false)
			# Stylus hovering
			_add_stroke(n, [[60, -40], [120, -110]], ink, 5.0, false)
			_add_stroke(n, [[50, -30], [60, -40]], INK_ROSE, 3.0, false)

		"embarrassed_youtube_stats":
			# YouTube studio dashboard flatline chart
			var card := [[-180, -110], [180, -110], [180, 110], [-180, 110], [-180, -110]]
			_add_fill(n, card, PAPER)
			_add_stroke(n, card, ink, 3.2, false)
			# Red play icon header
			_add_fill(n, [[-150, -90], [-110, -90], [-110, -65], [-150, -65]], SOFT_RED)
			_add_stroke(n, [[-150, -90], [-110, -90], [-110, -65], [-150, -65]], ink, 2.0, false)
			# Flatline graph
			_add_stroke(n, [[-150, 40], [-80, 40], [-20, 42], [50, 41], [150, 40]], SOFT_RED, 3.5, false)
			# Graph axis
			_add_stroke(n, [[-150, -40], [-150, 70], [150, 70]], Color("#a68c94"), 2.0, false)
			# Downward arrow
			_add_stroke(n, [[120, -10], [120, 20]], SOFT_RED, 2.5, false)
			_add_stroke(n, [[110, 10], [120, 20], [130, 10]], SOFT_RED, 2.5, false)

		"embarrassed_derpy_cartoon":
			# Derpy stick-figure / goofy doodle: "I draw cartoons on the internet"
			var frame := [[-120, -90], [120, -90], [120, 90], [-120, 90], [-120, -90]]
			_add_fill(n, frame, PAPER)
			_add_stroke(n, frame, ink, 2.8, false)
			# Goofy doodle head
			_add_stroke(n, [[-40, -20], [-20, -50], [20, -50], [40, -20], [20, 10], [-20, 10], [-40, -20]], INK_ROSE, 3.2)
			# Dot eyes and cat mouth
			_add_fill(n, [[-15, -28], [-7, -28], [-7, -20], [-15, -20]], INK_MAIN)
			_add_fill(n, [[7, -28], [15, -28], [15, -20], [7, -20]], INK_MAIN)
			_add_stroke(n, [[-12, -10], [0, -4], [12, -10]], INK_ROSE, 2.5)
			# Stick body and floppy waving arms
			_add_stroke(n, [[0, 10], [0, 55]], INK_MAIN, 3.0, false)
			_add_stroke(n, [[-45, 25], [-20, 30], [0, 25], [20, 30], [45, 25]], INK_MAIN, 2.8)
			_add_stroke(n, [[0, 55], [-25, 80]], INK_MAIN, 2.8, false)
			_add_stroke(n, [[0, 55], [25, 80]], INK_MAIN, 2.8, false)
			# Little crayon sun in corner
			_add_stroke(n, [[75, -65], [95, -65], [95, -45], [75, -45], [75, -65]], SOFT_GOLD, 3.0)

		"embarrassed_unemployed_stamp":
			# Dramatic red rubber stamp: "UNEMPLOYED" in clear block lettering
			var stamp_box := [[-160, -45], [160, -45], [160, 45], [-160, 45], [-160, -45]]
			_add_stroke(n, stamp_box, SOFT_RED, 4.5, false)
			var inner_box := [[-152, -37], [152, -37], [152, 37], [-152, 37], [-152, -37]]
			_add_stroke(n, inner_box, SOFT_RED, 2.0, false)
			# U
			_add_stroke(n, [[-136, -20], [-136, 16], [-118, 16], [-118, -20]], SOFT_RED, 3.8, false)
			# N
			_add_stroke(n, [[-108, 18], [-108, -18], [-92, 18], [-92, -18]], SOFT_RED, 3.8, false)
			# E
			_add_stroke(n, [[-70, -18], [-84, -18], [-84, 18], [-70, 18]], SOFT_RED, 3.8, false)
			_add_stroke(n, [[-84, 0], [-73, 0]], SOFT_RED, 3.4, false)
			# M
			_add_stroke(n, [[-60, 18], [-60, -18], [-50, 2], [-40, -18], [-40, 18]], SOFT_RED, 3.8, false)
			# P
			_add_stroke(n, [[-28, 18], [-28, -18], [-12, -18], [-12, 0], [-28, 0]], SOFT_RED, 3.8, false)
			# L
			_add_stroke(n, [[-2, -18], [-2, 18], [14, 18]], SOFT_RED, 3.8, false)
			# O
			_add_stroke(n, [[24, -18], [42, -18], [42, 18], [24, 18], [24, -18]], SOFT_RED, 3.8, false)
			# Y
			_add_stroke(n, [[52, -18], [62, 0], [72, -18]], SOFT_RED, 3.8, false)
			_add_stroke(n, [[62, 0], [62, 18]], SOFT_RED, 3.8, false)
			# E
			_add_stroke(n, [[96, -18], [82, -18], [82, 18], [96, 18]], SOFT_RED, 3.8, false)
			_add_stroke(n, [[82, 0], [93, 0]], SOFT_RED, 3.4, false)
			# D
			_add_stroke(n, [[106, -18], [106, 18], [122, 18], [128, 6], [128, -6], [122, -18], [106, -18]], SOFT_RED, 3.8, false)

		"embarrassed_clock_40h":
			# Spinning clock and calendar: "40 hours a week"
			var clock_face := [[-70, -70], [0, -95], [70, -70], [95, 0], [70, 70], [0, 95], [-70, 70], [-95, 0], [-70, -70]]
			_add_fill(n, clock_face, PAPER)
			_add_stroke(n, clock_face, ink, 3.2)
			for pt in [[0, -80], [0, 80], [-80, 0], [80, 0]]:
				_add_stroke(n, [[pt[0] * 0.85, pt[1] * 0.85], [pt[0], pt[1]]], ink, 3.0, false)
			_add_stroke(n, [[0, 0], [35, -45]], SOFT_RED, 3.5, false)
			_add_stroke(n, [[0, 0], [-50, 15]], INK_ROSE, 3.0, false)
			_add_fill(n, [[-6, -6], [6, -6], [6, 6], [-6, 6]], ink)
			var badge := [[110, -35], [175, -35], [175, 35], [110, 35], [110, -35]]
			_add_fill(n, badge, Color("#eee5d8"))
			_add_stroke(n, badge, ink, 2.5, false)
			_add_stroke(n, [[125, -20], [125, 5], [145, 5]], INK_ROSE, 3.0, false)
			_add_stroke(n, [[140, -20], [140, 20]], INK_ROSE, 3.0, false)
			_add_stroke(n, [[152, -20], [168, -20], [168, 20], [152, 20], [152, -20]], INK_ROSE, 3.0, false)

		"embarrassed_algorithm_monster":
			# Shadowy robot/tentacle eye inspecting the stats
			var eye_body := [[-60, 0], [-30, -50], [30, -50], [60, 0], [30, 50], [-30, 50], [-60, 0]]
			_add_fill(n, eye_body, Color("#3a2d33"))
			_add_stroke(n, eye_body, ink, 3.5)
			_add_fill(n, [[-15, -15], [15, -15], [15, 15], [-15, 15]], SOFT_RED)
			_add_stroke(n, [[-60, 0], [-110, -30], [-150, 10]], ink, 3.5)
			_add_stroke(n, [[60, 0], [110, -30], [150, 10]], ink, 3.5)
			_add_stroke(n, [[0, 50], [0, 95], [35, 120]], ink, 3.5)

		"embarrassed_doubt_cloud":
			# Dark scribbly thought storm cloud: "What if I'm just wasting my time?"
			var cloud_poly := [[-120, 0], [-90, -40], [-40, -55], [20, -50], [70, -55], [110, -35], [130, 0], [110, 35], [50, 45], [-20, 40], [-80, 45], [-120, 0]]
			_add_fill(n, cloud_poly, Color("#382e36"))
			_add_stroke(n, cloud_poly, ink, 3.2)
			_add_stroke(n, [[10, 45], [-10, 75], [5, 75], [-15, 110]], SOFT_GOLD, 3.5, false)
			for dx in [-80, -40, 50, 80]:
				_add_stroke(n, [[dx, 50], [dx - 8, 80]], Color("#a694a0"), 2.2, false)

		"embarrassed_spark_heart":
			# Warm glowing heart spark doodle: "I still care about this"
			var heart := [[0, 30], [-35, -5], [-35, -35], [-15, -45], [0, -25], [15, -45], [35, -35], [35, -5], [0, 30]]
			_add_fill(n, heart, SOFT_RED)
			_add_stroke(n, heart, INK_MAIN, 3.5)
			for angle in [0.0, 0.78, 1.57, 2.35, 3.14, 3.92, 4.71, 5.49]:
				var r1: float = 55.0
				var r2: float = 78.0
				var p1 := Vector2(cos(angle) * r1, sin(angle) * r1 - 10.0)
				var p2 := Vector2(cos(angle) * r2, sin(angle) * r2 - 10.0)
				_add_stroke(n, [[p1.x, p1.y], [p2.x, p2.y]], SOFT_GOLD, 3.0, false)

		"embarrassed_next_frame":
			# Clean animation paper sheet with registration pegs and pencil ready
			var paper_sheet := [[-140, -110], [140, -110], [145, 110], [-145, 110], [-140, -110]]
			_add_fill(n, paper_sheet, Color("#ffffff"))
			_add_stroke(n, paper_sheet, ink, 3.0, false)
			# Peg holes at bottom
			for px in [-90, 0, 90]:
				_add_fill(n, [[px - 8, 90], [px + 8, 90], [px + 8, 100], [px - 8, 100]], ink)
			# Gentle organic starting line
			_add_stroke(n, [[-50, -20], [-10, -10], [40, -30]], INK_ROSE, 3.2)
			# Stylus tip resting on line
			_add_stroke(n, [[40, -30], [90, -80]], ink, 4.5, false)
			_add_stroke(n, [[35, -25], [40, -30]], INK_SAGE, 3.0, false)

	n.prepare()
	return n
