extends RefCounted
## ADBEpisodeArt — Episode-Specific Illustrated Props and Doodles for ADB Storytime
## Hand-inked vector artwork in the signature ADB storytime visual language:
## - Contours in #2b2623 (warm dark ink)
## - Diegetic watercolor paper washes and vibrant story accents
## - 100% Vector LiveDrawing format, fully compatible with Storytime illustration track

const Drawing = preload("res://common/engine/illustration/LiveDrawing.gd")
const Profile = preload("res://common/storytime/ProfileAssets.gd")

const KINDS = [
	"red_cup",
	"red_cup_offered",
	"thermo_laptop",
	"thermo_diagram",
	"anime_vs_physics",
	"stolen_hoodie",
	"anniversary_photo",
	"comic_speech_bubble",
	"sweat_drops",
	"confusion_marks",
	"sparkle_stars",
	"heart_doodle",
	"action_burst_mistake",
	"potato_chart"
]

const INK_MAIN: Color = Color("#2b2623")
const INK_SOFT: Color = Color(0.17, 0.15, 0.14, 0.40)
const RED_CUP: Color = Color("#d63031")
const PUNCH_NEON: Color = Color("#ff3838")
const GOLD_ACCENT: Color = Color("#fdcb6e")
const TEAL_ACCENT: Color = Color("#00cec9")
const BLUE_ACCENT: Color = Color("#0984e3")

static func _add_stroke(n: Node2D, pts_raw: Array, col: Color = INK_MAIN, w: float = 2.8, smooth: bool = false) -> void:
	var pts := PackedVector2Array()
	for p in pts_raw: pts.append(Vector2(p[0], p[1]))
	n.stroke_list.append({"pts": pts, "col": col, "w": w, "smooth": smooth, "pause": 0.04})

static func _add_fill(n: Node2D, pts_raw: Array, col: Color) -> void:
	var pts := PackedVector2Array()
	for p in pts_raw: pts.append(Vector2(p[0], p[1]))
	n.fills.append({"poly": pts, "col": col, "at": 0.0})

static func make(author: String, kind: String) -> Node2D:
	var n = Drawing.new()
	var ink := INK_MAIN

	match kind:
		"red_cup":
			# Classic college red party solo cup with white rim and neon mystery punch
			var cup_body := [[-20, -32], [20, -32], [14, 34], [-14, 34], [-20, -32]]
			var punch := [[-18, -20], [18, -20], [14, 32], [-14, 32], [-18, -20]]
			var white_rim := [[-22, -38], [22, -38], [20, -30], [-20, -30], [-22, -38]]
			_add_fill(n, cup_body, RED_CUP)
			_add_fill(n, punch, Color("#e84393")) # neon mystery punch
			_add_fill(n, white_rim, Color("#ffffff"))
			_add_stroke(n, cup_body, ink, 2.6)
			_add_stroke(n, white_rim, ink, 2.4)
			# Ribs on solo cup
			_add_stroke(n, [[-18, -10], [18, -10]], Color(0.6, 0.1, 0.1, 0.8), 2.0)
			_add_stroke(n, [[-16, 10], [16, 10]], Color(0.6, 0.1, 0.1, 0.8), 2.0)

		"red_cup_offered":
			# Red cup tilted slightly outward with neon punch sloshing
			var cup_body := [[-26, -34], [16, -38], [12, 30], [-18, 36], [-26, -34]]
			var punch := [[-23, -22], [14, -26], [11, 28], [-16, 33], [-23, -22]]
			var rim := [[-28, -40], [18, -44], [16, -36], [-26, -32], [-28, -40]]
			_add_fill(n, cup_body, RED_CUP)
			_add_fill(n, punch, Color("#e84393"))
			_add_fill(n, rim, Color("#ffffff"))
			_add_stroke(n, cup_body, ink, 2.6)
			_add_stroke(n, rim, ink, 2.4)
			# Handover motion speed arc
			_add_stroke(n, [[-45, -10], [-30, -5], [-25, 0]], GOLD_ACCENT, 2.5, true)

		"thermo_laptop":
			# Open laptop with thermodynamics P-V cycle graph
			var base := [[-110, 24], [110, 24], [135, 58], [-135, 58], [-110, 24]]
			var screen := [[-100, -96], [100, -96], [105, 22], [-105, 22], [-100, -96]]
			var display := [[-90, -86], [90, -86], [94, 14], [-94, 14], [-90, -86]]
			_add_fill(n, base, Color("#dfe6e9"))
			_add_fill(n, screen, Color("#2d3436"))
			_add_fill(n, display, Color("#1e272e"))
			_add_stroke(n, base, ink, 2.8)
			_add_stroke(n, screen, ink, 2.8)
			# P-V cycle diagram on screen (Thermodynamics)
			_add_stroke(n, [[-60, -70], [-60, 0], [60, 0]], TEAL_ACCENT, 2.2) # axes
			_add_stroke(n, [[-45, -55], [30, -50], [45, -15], [-20, -18], [-45, -55]], GOLD_ACCENT, 2.5, true) # Carnot cycle loop
			# Trackpad
			_add_stroke(n, [[-26, 32], [26, 32], [28, 48], [-28, 48], [-26, 32]], INK_SOFT, 1.8)

		"thermo_diagram":
			# Open engineering notebook with PV=nRT formulas and notes
			var page := [[-120, -80], [120, -80], [125, 80], [-125, 80], [-120, -80]]
			_add_fill(n, page, Color("#fffdf7"))
			_add_stroke(n, page, ink, 3.0)
			_add_stroke(n, [[0, -80], [0, 80]], INK_SOFT, 1.8) # spine
			# Handwritten equation lines
			_add_stroke(n, [[-95, -50], [-25, -50]], BLUE_ACCENT, 2.2) # PV = nRT
			_add_stroke(n, [[-95, -25], [-35, -25]], INK_MAIN, 2.0)
			_add_stroke(n, [[-95, 0], [-15, 0]], INK_MAIN, 2.0)
			_add_stroke(n, [[-95, 25], [-45, 25]], RED_CUP, 2.0)
			# Right page graph
			_add_stroke(n, [[20, 50], [20, -50]], INK_MAIN, 2.0)
			_add_stroke(n, [[20, 50], [100, 50]], INK_MAIN, 2.0)
			_add_stroke(n, [[30, -30], [50, 10], [90, 20]], TEAL_ACCENT, 2.4, true)

		"anime_vs_physics":
			# Split debate doodle: Anime Action vs Table Tennis Spin
			var frame := [[-150, -80], [150, -80], [150, 80], [-150, 80], [-150, -80]]
			_add_fill(n, frame, Color(1, 1, 1, 0.9))
			_add_stroke(n, frame, ink, 3.2)
			_add_stroke(n, [[0, -80], [0, 80]], Color("#b2bec3"), 2.2) # dividing line
			# Left: Anime stick fighter with sword & speedlines
			_add_stroke(n, [[-90, -35], [-75, 10], [-60, 45]], Color("#e84393"), 2.8)
			_add_stroke(n, [[-100, -10], [-50, -30]], Color("#e84393"), 2.8)
			_add_stroke(n, [[-130, -50], [-70, -40]], GOLD_ACCENT, 2.0)
			_add_stroke(n, [[-130, 20], [-80, 15]], GOLD_ACCENT, 2.0)
			# Right: Table tennis paddle with spinning curved arrow
			var paddle := [[60, -10], [90, -10], [90, 25], [60, 25], [60, -10]]
			_add_fill(n, paddle, RED_CUP)
			_add_stroke(n, paddle, ink, 2.2)
			_add_stroke(n, [[75, 25], [75, 55]], Color("#d3a26a"), 3.0) # handle
			_add_stroke(n, [[105, -25], [120, -5], [105, 15]], TEAL_ACCENT, 2.5, true) # curved spin arrow

		"stolen_hoodie":
			# Oversized hoodie draped with funny tag
			var body := [[-70, -40], [70, -40], [90, 60], [55, 65], [45, 15], [-45, 15], [-55, 65], [-90, 60], [-70, -40]]
			_add_fill(n, body, Color("#6ab04c"))
			_add_stroke(n, body, ink, 3.0)
			# Hood contour
			_add_stroke(n, [[-40, -40], [-30, -75], [30, -75], [40, -40]], ink, 2.8, true)
			# Drawstrings
			_add_stroke(n, [[-15, -40], [-12, -5]], Color("#ffffff"), 2.5)
			_add_stroke(n, [[15, -40], [12, -5]], Color("#ffffff"), 2.5)
			# Playful heart pin
			_add_fill(n, [[25, -15], [35, -25], [45, -15], [35, 0], [25, -15]], Color("#eb4d4b"))

		"anniversary_photo":
			# Framed picture of ADB & Nemi on desk
			var frame := [[-85, -65], [85, -65], [85, 65], [-85, 65], [-85, -65]]
			var pic := [[-70, -50], [70, -50], [70, 50], [-70, 50], [-70, -50]]
			_add_fill(n, frame, Color("#e17055"))
			_add_fill(n, pic, Color("#fdfaf2"))
			_add_stroke(n, frame, ink, 3.2)
			_add_stroke(n, pic, ink, 2.0)
			# Two smiling stick avatars together inside photo
			_add_stroke(n, [[-35, 10], [-35, -15]], ink, 2.5) # ADB
			_add_stroke(n, [[-45, -25], [-25, -25], [-25, -10], [-45, -10], [-45, -25]], ink, 2.0)
			_add_stroke(n, [[25, 10], [25, -10]], ink, 2.5) # Nemi
			_add_stroke(n, [[15, -20], [35, -20], [35, -5], [15, -5], [15, -20]], Color("#e84393"), 2.0)
			# Little heart floating between them
			_add_fill(n, [[-5, -30], [0, -38], [5, -30], [0, -22], [-5, -30]], Color("#ff7675"))

		"comic_speech_bubble":
			# Hand-drawn rounded comic speech bubble with tail
			var bubble := [
				[-90, -40], [90, -40], [105, -20], [105, 20], [90, 40],
				[-20, 40], [-45, 68], [-40, 40], [-90, 40], [-105, 20], [-105, -20], [-90, -40]
			]
			_add_fill(n, bubble, Color("#ffffff"))
			_add_stroke(n, bubble, ink, 3.0, true)

		"sweat_drops":
			# Anime sweat teardrops beside temple
			for ox in [-15, 15]:
				var drop := [[ox, -20], [ox + 6, -8], [ox + 4, 8], [ox, 12], [ox - 4, 8], [ox - 6, -8], [ox, -20]]
				_add_fill(n, drop, Color(0.65, 0.85, 1.0, 0.9))
				_add_stroke(n, drop, ink, 2.0)

		"confusion_marks":
			# Swirling question marks and confusion spiral
			_add_stroke(n, [[-30, 0], [-20, -20], [0, -25], [15, -10], [0, 10], [-10, 5], [0, -5]], INK_SOFT, 2.5, true)
			_add_stroke(n, [[25, -25], [35, -30], [45, -20], [40, -5], [35, 10]], GOLD_ACCENT, 3.0, true)
			_add_stroke(n, [[35, 22], [35, 26]], GOLD_ACCENT, 3.5)

		"sparkle_stars":
			# 4-pointed golden sparkle diamonds
			for p in [Vector2(-30, -20), Vector2(35, -15), Vector2(-15, 25), Vector2(25, 20)]:
				var star := [
					[p.x, p.y - 18], [p.x + 4, p.y - 4], [p.x + 18, p.y],
					[p.x + 4, p.y + 4], [p.x, p.y + 18], [p.x - 4, p.y + 4],
					[p.x - 18, p.y], [p.x - 4, p.y - 4], [p.x, p.y - 18]
				]
				_add_fill(n, star, GOLD_ACCENT)
				_add_stroke(n, star, INK_MAIN, 1.8)

		"heart_doodle":
			# Organic hand-drawn heart with highlight
			var heart := [
				[0, 10], [-22, -18], [-36, -6], [-32, 14], [0, 42],
				[32, 14], [36, -6], [22, -18], [0, 10]
			]
			_add_fill(n, heart, Color("#ff7675"))
			_add_stroke(n, heart, ink, 3.0, true)
			# Glint
			_add_stroke(n, [[-20, -5], [-24, 5]], Color("#ffffff"), 2.2)

		"action_burst_mistake":
			# Dramatic wide comic spike burst tailored for punchline text
			var burst := [
				[-160, -25], [-210, -60], [-120, -65], [-140, -115], [-50, -80], [0, -125],
				[50, -80], [140, -115], [120, -65], [210, -60], [160, -25], [230, 18],
				[140, 38], [160, 88], [70, 65], [0, 105], [-70, 65], [-160, 88],
				[-140, 38], [-230, 18], [-160, -25]
			]
			_add_fill(n, burst, Color("#fffa65"))
			_add_stroke(n, burst, RED_CUP, 3.5)

		"potato_chart":
			# Clean comic card matching Ep00 potato evolution chart
			var card := [[-160, -90], [160, -90], [160, 90], [-160, 90], [-160, -90]]
			_add_fill(n, card, Color("#fffef5"))
			_add_stroke(n, card, ink, 3.0)
			# Derpy potato (left)
			var pot := [[-120, -10], [-115, -35], [-95, -45], [-70, -35], [-60, 0], [-75, 30], [-105, 35], [-120, -10]]
			_add_fill(n, pot, Color("#d3a26a"))
			_add_stroke(n, pot, ink, 2.5)
			# Big red X over potato
			_add_stroke(n, [[-125, -45], [-55, 35]], RED_CUP, 4.0)
			_add_stroke(n, [[-55, -45], [-125, 35]], RED_CUP, 4.0)
			# Gold arrow to right
			_add_stroke(n, [[-30, 0], [15, 0]], GOLD_ACCENT, 3.2)
			_add_stroke(n, [[5, -8], [15, 0], [5, 8]], GOLD_ACCENT, 3.2)
			# Approved green box (right)
			var app_box := [[45, -40], [130, -40], [130, 40], [45, 40], [45, -40]]
			_add_fill(n, app_box, Color(0.9, 0.98, 0.92))
			_add_stroke(n, app_box, Color("#00b894"), 2.6)
			# Green checkmark
			_add_stroke(n, [[65, 0], [80, 15], [115, -20]], Color("#00b894"), 4.0)

	n.prepare()
	return n
