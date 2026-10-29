extends RefCounted
## ADBEpisodeBackdrop — Rich Hand-Illustrated Storytime Environments for ADB Episodes
## Matching the signature ADB Ep00 art direction:
## - Warm cream paper (#faf6ee / #f4ede2)
## - Diegetic hand-inked linework (#2b2623) with watercolor tonal washes
## - Grounded perspective floor (floor_y = 840) with wood grain planks and knots
## - Deeply detailed sets: Creator studio, dorm party, 4 AM balcony, morning panic

const KINDS = [
	"adb_studio_ep02",
	"adb_dorm_party",
	"adb_balcony_4am",
	"adb_morning_panic"
]

const INK_CONTOUR: Color = Color("#2b2623")
const INK_FAINT: Color = Color(0.17, 0.15, 0.14, 0.18)
const INK_SOFT: Color = Color(0.17, 0.15, 0.14, 0.35)
const PAPER_COLOR: Color = Color("#faf6ee")
const PAPER_FLOOR: Color = Color("#ede4d3")

static func draw_set(c: Node2D, kind: String) -> void:
	match kind:
		"adb_studio_ep02":
			_draw_studio(c)
		"adb_dorm_party":
			_draw_dorm_party(c)
		"adb_balcony_4am":
			_draw_balcony_4am(c)
		"adb_morning_panic":
			_draw_morning_panic(c)

static func _draw_plank_floor(c: Node2D, floor_y: float, floor_color: Color = PAPER_FLOOR, contour_color: Color = INK_CONTOUR) -> void:
	c.draw_rect(Rect2(-3000, floor_y, 8000, 3000), floor_color, true)
	c.draw_line(Vector2(-3000, floor_y), Vector2(5000, floor_y), contour_color, 3.2)
	var plank_xs := [-160.0, 140.0, 380.0, 680.0, 1020.0, 1340.0, 1660.0, 1940.0, 2220.0]
	for px in plank_xs:
		c.draw_line(Vector2(px, floor_y), Vector2(px - 90.0, 1200), INK_FAINT, 1.8)
		c.draw_arc(Vector2(px - 45.0, floor_y + 110), 12.0, 0.2, PI * 0.9, 10, INK_FAINT, 1.2)

# =========================================================================
# 1. SIGNATURE ADB STUDIO (Intro, Reveal, Disappointment, Outro)
# =========================================================================
static func _draw_studio(c: Node2D) -> void:
	var floor_y := 840.0
	c.draw_rect(Rect2(-3000, -3000, 8000, 8000), PAPER_COLOR, true)
	_draw_plank_floor(c, floor_y)

	# Room corner perspective
	c.draw_line(Vector2(1440, 60), Vector2(1440, floor_y), INK_FAINT, 2.0)
	c.draw_line(Vector2(1440, floor_y), Vector2(1920, floor_y + 90), INK_FAINT, 2.0)

	# Sunlit Window (Left wall: X=100..420, Y=160..600)
	var win_rect := Rect2(100, 160, 320, 440)
	c.draw_rect(win_rect, Color(0.92, 0.96, 1.0, 0.55), true)
	c.draw_rect(win_rect, INK_CONTOUR, false, 3.2)
	c.draw_line(Vector2(260, 160), Vector2(260, 600), INK_CONTOUR, 2.2)
	c.draw_line(Vector2(100, 380), Vector2(420, 380), INK_CONTOUR, 2.2)
	# Curtains on both sides
	c.draw_polyline(PackedVector2Array([
		Vector2(85, 140), Vector2(120, 170), Vector2(95, 360), Vector2(115, 620), Vector2(85, 620)
	]), INK_FAINT, 2.0)
	c.draw_polyline(PackedVector2Array([
		Vector2(435, 140), Vector2(400, 170), Vector2(425, 360), Vector2(405, 620), Vector2(435, 620)
	]), INK_FAINT, 2.0)

	# Hanging wall shelves (Left center: X=480..820)
	_draw_shelf(c, Vector2(500, 260), 320, [
		{"type": "plant", "offset": 30},
		{"type": "books", "offset": 120, "count": 6},
		{"type": "mug", "offset": 260}
	])
	_draw_shelf(c, Vector2(540, 420), 260, [
		{"type": "books", "offset": 40, "count": 8},
		{"type": "figure", "offset": 190}
	])

	# Studio Desk Setup (Right side: X=1200..1880)
	var desk_top_y := floor_y - 200.0
	c.draw_line(Vector2(1200, desk_top_y), Vector2(1880, desk_top_y), INK_CONTOUR, 3.5)
	c.draw_line(Vector2(1260, desk_top_y), Vector2(1260, floor_y), INK_CONTOUR, 3.0)
	c.draw_line(Vector2(1820, desk_top_y), Vector2(1820, floor_y), INK_CONTOUR, 3.0)

	# Dual Monitors on desk
	var mon_rect := Rect2(1340, desk_top_y - 230, 320, 190)
	c.draw_rect(mon_rect, Color(0.12, 0.15, 0.20, 0.25), true)
	c.draw_rect(mon_rect, INK_CONTOUR, false, 2.8)
	c.draw_line(Vector2(1500, desk_top_y - 40), Vector2(1500, desk_top_y), INK_CONTOUR, 4.0)
	c.draw_line(Vector2(1460, desk_top_y), Vector2(1540, desk_top_y), INK_CONTOUR, 3.0)
	c.draw_line(Vector2(1360, desk_top_y - 80), Vector2(1640, desk_top_y - 80), Color("#0984e3", 0.5), 2.0)
	c.draw_rect(Rect2(1360, desk_top_y - 210, 180, 110), Color(0.9, 0.6, 0.2, 0.3), true)

	# Pen Tablet on desk surface
	c.draw_rect(Rect2(1360, desk_top_y + 20, 140, 80), Color(0.2, 0.2, 0.25, 0.2), true)
	c.draw_rect(Rect2(1360, desk_top_y + 20, 140, 80), INK_CONTOUR, false, 1.8)
	# Steaming coffee mug
	c.draw_rect(Rect2(1280, desk_top_y + 40, 32, 38), Color(0.85, 0.5, 0.2, 0.35), true)
	c.draw_rect(Rect2(1280, desk_top_y + 40, 32, 38), INK_CONTOUR, false, 2.0)
	c.draw_arc(Vector2(1292, desk_top_y + 22), 8.0, 0.0, PI * 0.8, 8, INK_FAINT, 1.5)
	c.draw_arc(Vector2(1302, desk_top_y + 10), 8.0, PI * 0.2, PI, 8, INK_FAINT, 1.5)

	# Framed anime poster on wall (X=920..1140, Y=140..350)
	var post_rect := Rect2(920, 140, 220, 210)
	c.draw_rect(post_rect, Color(0.96, 0.92, 0.85, 0.6), true)
	c.draw_rect(post_rect, INK_CONTOUR, false, 2.5)
	c.draw_circle(Vector2(1030, 210), 24.0, Color(0.9, 0.3, 0.2, 0.35))
	c.draw_line(Vector2(950, 290), Vector2(1110, 290), INK_FAINT, 1.5)

# =========================================================================
# 2. DORM PARTY (Covid 2020 Hangout, Red Cup, Thermodynamics)
# =========================================================================
static func _draw_dorm_party(c: Node2D) -> void:
	var floor_y := 840.0
	c.draw_rect(Rect2(-3000, -3000, 8000, 8000), Color("#f7f1e7"), true)
	_draw_plank_floor(c, floor_y, Color("#e8dfcf"))

	# Hanging Party Fairy Lights draped across ceiling
	var wire_pts := PackedVector2Array()
	for i in range(25):
		var x := float(i) * 80.0
		var sag := sin(float(i) * 0.5) * 25.0
		wire_pts.append(Vector2(x, 120.0 + sag))
	c.draw_polyline(wire_pts, INK_CONTOUR, 2.2)

	# Glowing bulbs along the wire
	for i in range(1, 24, 2):
		var p: Vector2 = wire_pts[i]
		# Soft glowing halo
		c.draw_circle(p, 18.0, Color(1.0, 0.85, 0.35, 0.22))
		# Bulb fill
		c.draw_circle(p, 6.5, Color("#fed330"))
		c.draw_circle(p, 6.5, INK_CONTOUR, false, 1.5)

	# Dorm Room Door (Right side: X=1480..1820, Y=220..840)
	var door_rect := Rect2(1500, 220, 300, 620)
	c.draw_rect(door_rect, Color("#e5d9c5"), true)
	c.draw_rect(door_rect, INK_CONTOUR, false, 3.2)
	# Room number plate "304"
	c.draw_rect(Rect2(1610, 270, 80, 40), Color("#ffffff"), true)
	c.draw_rect(Rect2(1610, 270, 80, 40), INK_CONTOUR, false, 2.0)
	# Door whiteboard memo
	var memo_rect := Rect2(1550, 360, 200, 160)
	c.draw_rect(memo_rect, Color(0.98, 0.98, 1.0, 0.9), true)
	c.draw_rect(memo_rect, INK_CONTOUR, false, 2.2)
	c.draw_line(Vector2(1570, 400), Vector2(1730, 400), Color("#0984e3", 0.6), 2.0)
	c.draw_line(Vector2(1570, 430), Vector2(1710, 430), Color("#d63031", 0.6), 2.0)
	c.draw_circle(Vector2(1530, 560), 8.0, Color("#d3a26a"))

	# Study Corner Desk with focused Lamp (Left side: X=80..480, Y=640)
	var desk_y := floor_y - 200.0
	c.draw_line(Vector2(80, desk_y), Vector2(480, desk_y), INK_CONTOUR, 3.5)
	c.draw_line(Vector2(120, desk_y), Vector2(120, floor_y), INK_CONTOUR, 3.0)
	c.draw_line(Vector2(440, desk_y), Vector2(440, floor_y), INK_CONTOUR, 3.0)

	# Desk lamp cone of warm light
	var lamp_base := Vector2(160, desk_y)
	c.draw_line(lamp_base, lamp_base + Vector2(20, -100), INK_CONTOUR, 3.0)
	c.draw_circle(lamp_base + Vector2(25, -105), 14.0, Color("#2d3436"))
	var cone_pts := PackedVector2Array([
		lamp_base + Vector2(25, -100),
		Vector2(60, desk_y + 10),
		Vector2(420, desk_y + 10)
	])
	c.draw_colored_polygon(cone_pts, Color(1.0, 0.92, 0.55, 0.18))

	# Thermodynamics textbook on desk
	c.draw_rect(Rect2(240, desk_y - 12, 90, 24), Color("#0984e3", 0.7), true)
	c.draw_rect(Rect2(240, desk_y - 12, 90, 24), INK_CONTOUR, false, 2.0)

	# Stack of Red Solo Cups on side table (X=1340..1440)
	for r in range(4):
		var ry := desk_y + 30.0 - float(r) * 14.0
		var cup_pts := PackedVector2Array([
			Vector2(1360, ry), Vector2(1388, ry),
			Vector2(1384, ry + 26), Vector2(1364, ry + 26)
		])
		c.draw_colored_polygon(cup_pts, Color("#d63031"))
		c.draw_polyline(cup_pts, INK_CONTOUR, 2.0, true)

	# Dorm Wall Poster (Center wall: X=860..1120, Y=180..380)
	var poster := Rect2(880, 180, 220, 200)
	c.draw_rect(poster, Color(0.92, 0.94, 0.90, 0.8), true)
	c.draw_rect(poster, INK_CONTOUR, false, 2.5)
	c.draw_circle(Vector2(990, 260), 30.0, Color("#e17055", 0.5))
	c.draw_line(Vector2(910, 340), Vector2(1070, 340), INK_FAINT, 2.0)

# =========================================================================
# 3. 4:00 AM BALCONY (Deep Twilight, Moon, City Lights, First Kiss)
# =========================================================================
static func _draw_balcony_4am(c: Node2D) -> void:
	var floor_y := 840.0
	# Warm cream storytime paper with delicate twilight watercolor wash (#f0f3f8)
	var twilight_paper := Color("#f0f3f8")
	c.draw_rect(Rect2(-3000, -3000, 8000, 8000), twilight_paper, true)

	# Distant City Skyline Silhouettes with dark ink contours and soft watercolor wash
	var bldgs := [
		[60, 480, 140, 360],
		[180, 410, 180, 430],
		[340, 520, 120, 320],
		[440, 380, 220, 460],
		[640, 460, 160, 380],
		[780, 360, 260, 480],
		[1020, 440, 190, 400],
		[1190, 390, 240, 450],
		[1410, 490, 160, 350],
		[1550, 420, 220, 420]
	]
	for b in bldgs:
		var brect := Rect2(b[0], b[1], b[2], b[3])
		# Soft watercolor wash fill for buildings
		c.draw_rect(brect, Color(0.25, 0.30, 0.42, 0.22), true)
		c.draw_rect(brect, INK_CONTOUR, false, 2.2)
		# Scattered glowing windows in city
		for wx_i in range(3):
			for wy_i in range(5):
				if (b[0] + wx_i * 7 + wy_i * 13) % 4 == 0:
					var wx: float = b[0] + 25.0 + float(wx_i) * 35.0
					var wy: float = b[1] + 40.0 + float(wy_i) * 45.0
					c.draw_rect(Rect2(wx, wy, 12, 16), Color(1.0, 0.85, 0.40, 0.85), true)
					c.draw_rect(Rect2(wx, wy, 12, 16), INK_CONTOUR, false, 1.2)

	# Crescent Moon in upper sky (warm cream/gold with ink outline)
	var moon_center := Vector2(1480, 180)
	c.draw_circle(moon_center, 40.0, Color(1.0, 0.92, 0.70, 0.95))
	# Shadow cutout for crescent using sky paper color
	c.draw_circle(moon_center + Vector2(16, -10), 34.0, twilight_paper)
	c.draw_arc(moon_center, 40.0, 0.6, PI * 1.6, 24, INK_CONTOUR, 2.4)

	# Twinkling stars (golden sparkle crosses)
	var star_pts := [
		Vector2(240, 140), Vector2(480, 190), Vector2(720, 120), Vector2(980, 160),
		Vector2(1220, 110), Vector2(1660, 150), Vector2(1820, 210)
	]
	for sp in star_pts:
		c.draw_line(sp - Vector2(7, 0), sp + Vector2(7, 0), Color(0.85, 0.65, 0.15, 0.9), 2.2)
		c.draw_line(sp - Vector2(0, 7), sp + Vector2(0, 7), Color(0.85, 0.65, 0.15, 0.9), 2.2)
		c.draw_circle(sp, 2.0, Color("#ffffff"))

	# Patio Plank Floor (warm cream wood wash with perspective lines)
	_draw_plank_floor(c, floor_y, Color("#e8dfcf"), INK_CONTOUR)

	# Warm doorway light spill from dorm room interior (Right side: X=1520..1880)
	var glow_pts := PackedVector2Array([
		Vector2(1650, 480), Vector2(1860, 520),
		Vector2(1920, floor_y + 120), Vector2(1440, floor_y + 80)
	])
	c.draw_colored_polygon(glow_pts, Color(1.0, 0.85, 0.45, 0.20))

	# Metal Balcony Railing across entire width in dark ink
	var rail_top_y := floor_y - 180.0
	c.draw_line(Vector2(-3000, rail_top_y), Vector2(5000, rail_top_y), INK_CONTOUR, 4.0)
	c.draw_line(Vector2(-3000, rail_top_y + 60), Vector2(5000, rail_top_y + 60), INK_CONTOUR, 2.5)
	c.draw_line(Vector2(-3000, rail_top_y + 120), Vector2(5000, rail_top_y + 120), INK_CONTOUR, 2.5)
	# Vertical railing posts
	for px in range(-200, 2400, 140):
		c.draw_line(Vector2(px, rail_top_y), Vector2(px, floor_y), INK_CONTOUR, 3.2)

# =========================================================================
# 4. MORNING PANIC (9:00 AM, Sunbeams, Alarm Clock)
# =========================================================================
static func _draw_morning_panic(c: Node2D) -> void:
	var floor_y := 840.0
	c.draw_rect(Rect2(-3000, -3000, 8000, 8000), Color("#fcf9f2"), true)
	_draw_plank_floor(c, floor_y, Color("#ede5d5"))

	# Bedroom Window with streaming sunlight (Left: X=100..460, Y=140..580)
	var win_rect := Rect2(100, 140, 360, 440)
	c.draw_rect(win_rect, Color(0.85, 0.94, 1.0, 0.8), true)
	c.draw_rect(win_rect, INK_CONTOUR, false, 3.2)
	c.draw_line(Vector2(280, 140), Vector2(280, 580), INK_CONTOUR, 2.5)
	c.draw_line(Vector2(100, 360), Vector2(460, 360), INK_CONTOUR, 2.5)

	# Morning Diagonal Sunbeams streaming across room
	var beam_pts := PackedVector2Array([
		Vector2(100, 140), Vector2(460, 140),
		Vector2(1200, floor_y + 100), Vector2(500, floor_y + 100)
	])
	c.draw_colored_polygon(beam_pts, Color(1.0, 0.95, 0.75, 0.20))

	# Dorm Bed & Headboard on Right (X=1350..1880, Y=520..840)
	var bed_top_y := floor_y - 120.0
	c.draw_rect(Rect2(1340, bed_top_y - 140, 30, 260), Color("#c8b29b"), true) # Headboard
	c.draw_rect(Rect2(1340, bed_top_y - 140, 30, 260), INK_CONTOUR, false, 3.0)
	c.draw_rect(Rect2(1370, bed_top_y, 480, 120), Color("#81ecec", 0.6), true) # Blanket
	c.draw_rect(Rect2(1370, bed_top_y, 480, 120), INK_CONTOUR, false, 2.8)
	# Rumpled pillows
	c.draw_rect(Rect2(1375, bed_top_y - 45, 90, 42), Color("#ffffff"), true)
	c.draw_rect(Rect2(1375, bed_top_y - 45, 90, 42), INK_CONTOUR, false, 2.0)

	# Nightstand with screaming alarm clock (X=1200..1320)
	var stand_rect := Rect2(1200, bed_top_y - 30, 110, 150)
	c.draw_rect(stand_rect, Color("#dfcaa9"), true)
	c.draw_rect(stand_rect, INK_CONTOUR, false, 2.8)

	# Digital Alarm Clock showing "9:00 AM"
	var clock_rect := Rect2(1220, bed_top_y - 75, 80, 44)
	c.draw_rect(clock_rect, Color("#2d3436"), true)
	c.draw_rect(clock_rect, INK_CONTOUR, false, 2.2)
	# Red digital time indication
	c.draw_rect(Rect2(1230, bed_top_y - 65, 12, 22), Color("#d63031"), true)
	c.draw_circle(Vector2(1250, bed_top_y - 60), 2.5, Color("#d63031"))
	c.draw_circle(Vector2(1250, bed_top_y - 50), 2.5, Color("#d63031"))
	c.draw_rect(Rect2(1258, bed_top_y - 65, 14, 22), Color("#d63031"), true)
	c.draw_rect(Rect2(1276, bed_top_y - 65, 14, 22), Color("#d63031"), true)

	# Sound waves radiating from clock
	c.draw_arc(Vector2(1210, bed_top_y - 53), 16.0, PI * 0.7, PI * 1.3, 8, Color("#d63031"), 2.5)
	c.draw_arc(Vector2(1205, bed_top_y - 53), 26.0, PI * 0.7, PI * 1.3, 8, Color("#d63031"), 2.0)
	c.draw_arc(Vector2(1310, bed_top_y - 53), 16.0, -PI * 0.3, PI * 0.3, 8, Color("#d63031"), 2.5)
	c.draw_arc(Vector2(1315, bed_top_y - 53), 26.0, -PI * 0.3, PI * 0.3, 8, Color("#d63031"), 2.0)

# =========================================================================
# HELPER: Hand-drawn shelf
# =========================================================================
static func _draw_shelf(c: Node2D, pos: Vector2, width: float, items: Array[Dictionary]) -> void:
	c.draw_line(pos, pos + Vector2(width, 0), INK_CONTOUR, 3.5)
	c.draw_line(pos + Vector2(20, 0), pos + Vector2(10, 30), INK_CONTOUR, 2.0)
	c.draw_line(pos + Vector2(width - 20, 0), pos + Vector2(width - 10, 30), INK_CONTOUR, 2.0)

	for it in items:
		var ox: float = it.get("offset", 0.0)
		var item_pos := pos + Vector2(ox, 0)
		match it.get("type", ""):
			"plant":
				c.draw_rect(Rect2(item_pos.x - 14, item_pos.y - 32, 28, 32), Color(0.8, 0.45, 0.2, 0.4), true)
				c.draw_rect(Rect2(item_pos.x - 14, item_pos.y - 32, 28, 32), INK_CONTOUR, false, 1.8)
				c.draw_arc(Vector2(item_pos.x - 8, item_pos.y - 42), 12.0, 0.0, PI * 0.8, 8, Color("#00b894"), 2.5)
				c.draw_arc(Vector2(item_pos.x + 8, item_pos.y - 48), 14.0, 0.2, PI, 8, Color("#00b894"), 2.5)
			"books":
				var count: int = it.get("count", 4)
				var b_cols := [Color("#e17055"), Color("#0984e3"), Color("#6c5ce7"), Color("#00b894")]
				for bi in range(count):
					var bx := item_pos.x + float(bi) * 16.0
					var bh := 45.0 + float((bi * 7) % 20)
					c.draw_rect(Rect2(bx, item_pos.y - bh, 14, bh), b_cols[bi % b_cols.size()], true)
					c.draw_rect(Rect2(bx, item_pos.y - bh, 14, bh), INK_CONTOUR, false, 1.5)
			"mug":
				c.draw_rect(Rect2(item_pos.x, item_pos.y - 30, 24, 30), Color(0.9, 0.3, 0.2, 0.4), true)
				c.draw_rect(Rect2(item_pos.x, item_pos.y - 30, 24, 30), INK_CONTOUR, false, 1.8)
			"figure":
				c.draw_rect(Rect2(item_pos.x, item_pos.y - 55, 20, 55), Color(0.2, 0.2, 0.25, 0.3), true)
				c.draw_rect(Rect2(item_pos.x, item_pos.y - 55, 20, 55), INK_CONTOUR, false, 1.5)
				c.draw_circle(Vector2(item_pos.x + 10, item_pos.y - 65), 10.0, Color(0.2, 0.2, 0.25, 0.3))
