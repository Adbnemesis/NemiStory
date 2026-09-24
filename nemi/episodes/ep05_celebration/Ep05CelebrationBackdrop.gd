class_name Ep05CelebrationBackdrop
extends Node2D

## High-Aesthetic Illustrated Studio Backdrop for Episode 05: "WHAT IS GOING ON WITH YOUTUBE?"
## Hand-drawn animator studio inspired by cozy anime storytime creators (Pegi & Jaiden).
## Includes rich environmental details:
## - Bookshelf with shaded colorful books & cascading potted ivy plant
## - Window with draped pastel curtains, windowsill, and fluffy clouds
## - Corkboard with layered sticky notes, polaroid photo, and glowing fairy lights
## - Front drawing desk with wood grain, drawing tablet, pen holder, and steaming cat mug
## - Smooth multi-state lighting transitions (Normal, Suspense, Celebration Bunting, Comment Immersion, Sincere Warmth)

enum BackdropState {
	NORMAL_STUDIO,
	SUSPENSE_WALL,
	CELEBRATION_WALL,
	COMMENT_IMMERSION,
	SINCERE_WARMTH
}

@export var state: BackdropState = BackdropState.NORMAL_STUDIO
@export var celebration_intensity: float = 0.0 # 0.0 to 1.0 (party bunting, confetti, fairy glow)
@export var warmth_intensity: float = 0.0      # 0.0 to 1.0 (golden intimate lamp spotlight)
@export var comment_dim_intensity: float = 0.0 # 0.0 to 1.0 (lavender twilight dimming)

# Color Palette
const WALL_TOP: Color = Color("#fcf9f2")
const WALL_BOTTOM: Color = Color("#f4ebe0")
const CELEB_WALL: Color = Color("#fffcf5")
const TWILIGHT_WALL: Color = Color("#eeeaf5")
const WARMTH_WALL: Color = Color("#fdf3e5")

const INK_MAIN: Color = Color("#2e1822")
const INK_SOFT: Color = Color("#594551")
const WOOD_BASE: Color = Color("#d8c6b0")
const WOOD_DARK: Color = Color("#a68d75")
const WOOD_HIGHLIGHT: Color = Color("#f0e6d8")

var _active_tween: Tween
var foreground_desk: Node2D
var _confetti_particles: Array = []
var _steam_timer: float = 0.0

func _init() -> void:
	foreground_desk = Ep05StudioForegroundDesk.new(self)
	foreground_desk.name = "ForegroundDesk"
	_init_confetti()

func _ready() -> void:
	z_index = -10
	request_redraw_all()

func _process(delta: float) -> void:
	_steam_timer += delta
	if is_instance_valid(foreground_desk):
		foreground_desk.queue_redraw()

func _init_confetti() -> void:
	_confetti_particles.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var cols: Array[Color] = [Color("#ff6b81"), Color("#ffa502"), Color("#70a1ff"), Color("#2ed573"), Color("#a55eea")]
	for i in range(48):
		var x: float = rng.randf_range(-100.0, 1380.0)
		var y: float = rng.randf_range(40.0, 560.0)
		var rot: float = rng.randf_range(-PI, PI)
		var sz: float = rng.randf_range(7.0, 15.0)
		var c: Color = cols[rng.randi_range(0, cols.size() - 1)]
		_confetti_particles.append({"pos": Vector2(x, y), "rot": rot, "size": sz, "color": c})

func request_redraw_all() -> void:
	queue_redraw()
	if is_instance_valid(foreground_desk):
		foreground_desk.queue_redraw()

func transition_to_state(target_state: BackdropState, duration: float = 0.5) -> Signal:
	state = target_state
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	var target_celeb: float = 0.0
	var target_warmth: float = 0.0
	var target_dim: float = 0.0
	
	match target_state:
		BackdropState.NORMAL_STUDIO:
			target_celeb = 0.0
			target_warmth = 0.0
			target_dim = 0.0
		BackdropState.SUSPENSE_WALL:
			target_celeb = 0.2
			target_warmth = 0.0
			target_dim = 0.0
		BackdropState.CELEBRATION_WALL:
			target_celeb = 1.0
			target_warmth = 0.25
			target_dim = 0.0
		BackdropState.COMMENT_IMMERSION:
			target_celeb = 0.4
			target_warmth = 0.15
			target_dim = 0.65
		BackdropState.SINCERE_WARMTH:
			target_celeb = 0.15
			target_warmth = 1.0
			target_dim = 0.15

	_active_tween = create_tween()
	_active_tween.tween_property(self, "celebration_intensity", target_celeb, duration)
	_active_tween.parallel().tween_property(self, "warmth_intensity", target_warmth, duration)
	_active_tween.parallel().tween_property(self, "comment_dim_intensity", target_dim, duration)
	_active_tween.parallel().tween_method(func(_v): request_redraw_all(), 0.0, 1.0, duration)
	return _active_tween.finished

func _draw() -> void:
	var celeb := celebration_intensity
	var warm := warmth_intensity
	var dim := comment_dim_intensity
	
	# 1. Warm Wall Background with Gradient Feel
	var base_wall := WALL_TOP.lerp(CELEB_WALL, celeb).lerp(WARMTH_WALL, warm).lerp(TWILIGHT_WALL, dim)
	draw_rect(Rect2(-1000, -1000, 3280, 2720), base_wall)
	
	# Subtle warm wall tint at bottom
	var wall_shade := WALL_BOTTOM.lerp(Color("#fde8d0"), warm).lerp(Color("#e2d9ec"), dim)
	draw_rect(Rect2(-1000, 360, 3280, 200), Color(wall_shade.r, wall_shade.g, wall_shade.b, 0.45))
	
	# Warm spotlight glow in SINCERE_WARMTH
	if warm > 0.05:
		draw_circle(Vector2(640, 360), 420.0, Color(1.0, 0.88, 0.65, 0.18 * warm))
		draw_circle(Vector2(640, 360), 240.0, Color(1.0, 0.92, 0.75, 0.15 * warm))
	
	# 2. Wooden Floor & Baseboard Molding (Y = 560)
	var floor_y := 560.0
	var floor_col := Color("#ebdccb").lerp(Color("#ffe9d2"), warm * 0.4).lerp(Color("#d8cfdf"), dim * 0.5)
	draw_rect(Rect2(-1000, floor_y, 3280, 600), floor_col)
	
	# Baseboard trim
	draw_rect(Rect2(-1000, floor_y - 24, 3280, 24), WOOD_BASE)
	draw_line(Vector2(-1000, floor_y - 24), Vector2(2280, floor_y - 24), WOOD_DARK, 2.0)
	draw_line(Vector2(-1000, floor_y), Vector2(2280, floor_y), INK_MAIN, 2.8)
	
	# Floor wood plank lines
	for px in [-200, 150, 480, 820, 1150, 1480]:
		draw_line(Vector2(px, floor_y), Vector2(px - 140, floor_y + 600), Color(WOOD_DARK.r, WOOD_DARK.g, WOOD_DARK.b, 0.35), 1.5)
	
	# 3. Bookshelf on the Left
	_draw_bookshelf(Vector2(110, 150))
	
	# 4. Window on the Right with Curtains & Sky
	_draw_window(Vector2(990, 130), dim)
	
	# 5. Corkboard in Center
	_draw_corkboard(Vector2(440, 140))
	
	# 6. Fairy Lights String across Corkboard
	_draw_fairy_lights(Vector2(420, 125), Vector2(860, 135), celeb)
	
	# 7. Festive Celebration Bunting & Confetti (CELEBRATION_WALL)
	if celeb > 0.01:
		_draw_party_bunting(celeb)
		_draw_confetti(celeb)

func _draw_bookshelf(pos: Vector2) -> void:
	var w := 190.0
	var h := 380.0
	
	# Shadow
	draw_rect(Rect2(pos.x + 6, pos.y + 6, w, h), Color(0, 0, 0, 0.08))
	
	# Shelf Frame
	draw_rect(Rect2(pos.x, pos.y, w, h), WOOD_BASE)
	draw_rect(Rect2(pos.x, pos.y, w, h), INK_MAIN, false, 2.6)
	
	# Shelf Dividers
	var shelf_ys := [pos.y + 120, pos.y + 240, pos.y + 360]
	for sy in shelf_ys:
		draw_rect(Rect2(pos.x, sy - 8, w, 8), WOOD_DARK)
		draw_line(Vector2(pos.x, sy), Vector2(pos.x + w, sy), INK_MAIN, 2.2)
	
	# Shelf 1: Colorful Books
	var book_cols := [Color("#e74c3c"), Color("#3498db"), Color("#2ecc71"), Color("#9b59b6"), Color("#f39c12"), Color("#1abc9c")]
	var bx := pos.x + 12.0
	for i in range(book_cols.size()):
		var bw := 18.0
		var bh := 85.0 + (i % 3) * 8.0
		draw_rect(Rect2(bx, pos.y + 112 - bh, bw, bh), book_cols[i])
		draw_rect(Rect2(bx, pos.y + 112 - bh, bw, bh), INK_MAIN, false, 1.8)
		# Spine line
		draw_line(Vector2(bx + 4, pos.y + 112 - bh + 10), Vector2(bx + 4, pos.y + 112 - 10), Color(0,0,0,0.25), 1.2)
		bx += bw + 3.0
	
	# Potted Trailing Ivy Plant on Top Shelf
	var pot_x := pos.x + 140.0
	var pot_y := pos.y + 90.0
	var pot_pts := PackedVector2Array([
		Vector2(pot_x - 14, pot_y),
		Vector2(pot_x + 14, pot_y),
		Vector2(pot_x + 10, pot_y + 22),
		Vector2(pot_x - 10, pot_y + 22)
	])
	draw_colored_polygon(pot_pts, Color("#e67e22"))
	draw_polyline(pot_pts, INK_MAIN, 2.0, true)
	
	# Cascading ivy leaves
	var vine_cols := [Color("#27ae60"), Color("#2ecc71"), Color("#a3e4d7")]
	for v in range(5):
		var vx := pot_x - 10.0 + v * 6.0
		var vy := pot_y + 15.0 + v * 8.0
		draw_circle(Vector2(vx, vy), 4.5, vine_cols[v % 3])
		draw_circle(Vector2(vx, vy), 4.5, INK_MAIN, false, 1.2)
	
	# Shelf 2: Stacked and leaning books
	bx = pos.x + 15.0
	for i in range(4):
		draw_rect(Rect2(bx, pos.y + 232 - 75, 22, 75), book_cols[(i + 2) % book_cols.size()])
		draw_rect(Rect2(bx, pos.y + 232 - 75, 22, 75), INK_MAIN, false, 1.8)
		bx += 25.0
	# Leaning book
	draw_line(Vector2(bx + 5, pos.y + 232), Vector2(bx + 35, pos.y + 232 - 70), book_cols[0], 20.0)
	draw_line(Vector2(bx + 5, pos.y + 232), Vector2(bx + 35, pos.y + 232 - 70), INK_MAIN, 2.0)
	
	# Shelf 3: Sketchbook storage binders
	bx = pos.x + 12.0
	for i in range(5):
		draw_rect(Rect2(bx, pos.y + 352 - 95, 26, 95), Color("#fcf3cf") if i % 2 == 0 else Color("#d5d8dc"))
		draw_rect(Rect2(bx, pos.y + 352 - 95, 26, 95), INK_MAIN, false, 1.8)
		bx += 30.0

func _draw_window(pos: Vector2, dim: float) -> void:
	var w := 210.0
	var h := 250.0
	
	# Window Shadow
	draw_rect(Rect2(pos.x + 5, pos.y + 5, w, h), Color(0, 0, 0, 0.08))
	
	# Sky Pane (Light blue afternoon or twilight)
	var sky_col := Color("#d6eaf8").lerp(Color("#2c3e50"), dim)
	draw_rect(Rect2(pos.x, pos.y, w, h), sky_col)
	
	# Fluffy White Clouds in daylight
	if dim < 0.5:
		var cloud_col := Color(1, 1, 1, 0.85 * (1.0 - dim))
		draw_circle(Vector2(pos.x + 60, pos.y + 70), 22.0, cloud_col)
		draw_circle(Vector2(pos.x + 85, pos.y + 60), 28.0, cloud_col)
		draw_circle(Vector2(pos.x + 115, pos.y + 70), 20.0, cloud_col)
	
	# Window Outer Wooden Frame
	draw_rect(Rect2(pos.x, pos.y, w, h), WOOD_DARK, false, 4.0)
	draw_rect(Rect2(pos.x, pos.y, w, h), INK_MAIN, false, 2.2)
	
	# Panes Divider Cross
	var mx := pos.x + w * 0.5
	var my := pos.y + h * 0.45
	draw_line(Vector2(mx, pos.y), Vector2(mx, pos.y + h), INK_MAIN, 2.2)
	draw_line(Vector2(pos.x, my), Vector2(pos.x + w, my), INK_MAIN, 2.2)
	
	# Window Sill
	draw_rect(Rect2(pos.x - 12, pos.y + h - 4, w + 24, 14), WOOD_BASE)
	draw_rect(Rect2(pos.x - 12, pos.y + h - 4, w + 24, 14), INK_MAIN, false, 2.0)
	
	# Cozy Draped Curtains (Left and Right)
	var curtain_col := Color("#ecf0f1")
	# Left drape
	var left_curt := PackedVector2Array([
		Vector2(pos.x - 16, pos.y - 10),
		Vector2(pos.x + 35, pos.y - 10),
		Vector2(pos.x + 15, pos.y + h * 0.5),
		Vector2(pos.x + 38, pos.y + h),
		Vector2(pos.x - 16, pos.y + h)
	])
	draw_colored_polygon(left_curt, curtain_col)
	draw_polyline(left_curt, INK_MAIN, 2.0, true)
	
	# Right drape
	var right_curt := PackedVector2Array([
		Vector2(pos.x + w + 16, pos.y - 10),
		Vector2(pos.x + w - 35, pos.y - 10),
		Vector2(pos.x + w - 15, pos.y + h * 0.5),
		Vector2(pos.x + w - 38, pos.y + h),
		Vector2(pos.x + w + 16, pos.y + h)
	])
	draw_colored_polygon(right_curt, curtain_col)
	draw_polyline(right_curt, INK_MAIN, 2.0, true)

func _draw_corkboard(pos: Vector2) -> void:
	var w := 400.0
	var h := 220.0
	
	# Shadow
	draw_rect(Rect2(pos.x + 5, pos.y + 5, w, h), Color(0, 0, 0, 0.08))
	
	# Wood Frame
	draw_rect(Rect2(pos.x, pos.y, w, h), WOOD_DARK)
	draw_rect(Rect2(pos.x + 10, pos.y + 10, w - 20, h - 20), Color("#e5cbac")) # Cork fill
	draw_rect(Rect2(pos.x, pos.y, w, h), INK_MAIN, false, 2.5)
	draw_rect(Rect2(pos.x + 10, pos.y + 10, w - 20, h - 20), INK_MAIN, false, 1.8)
	
	# Sticky Note 1: Pastel Pink (Left)
	var n1_pos := pos.x + 30.0
	var n1_y := pos.y + 35.0
	draw_rect(Rect2(n1_pos, n1_y, 80, 85), Color("#fce4ec"))
	draw_rect(Rect2(n1_pos, n1_y, 80, 85), INK_MAIN, false, 1.5)
	draw_circle(Vector2(n1_pos + 40, n1_y + 8), 4.0, Color("#e91e63")) # pushpin
	# Squiggle lines
	draw_line(Vector2(n1_pos + 12, n1_y + 28), Vector2(n1_pos + 68, n1_y + 28), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	draw_line(Vector2(n1_pos + 12, n1_y + 44), Vector2(n1_pos + 64, n1_y + 44), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	draw_line(Vector2(n1_pos + 12, n1_y + 60), Vector2(n1_pos + 52, n1_y + 60), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	
	# Sticky Note 2: Mint Green (Center)
	var n2_pos := pos.x + 140.0
	var n2_y := pos.y + 30.0
	draw_rect(Rect2(n2_pos, n2_y, 90, 95), Color("#e8f8f5"))
	draw_rect(Rect2(n2_pos, n2_y, 90, 95), INK_MAIN, false, 1.5)
	draw_circle(Vector2(n2_pos + 45, n2_y + 8), 4.0, Color("#1abc9c"))
	draw_line(Vector2(n2_pos + 14, n2_y + 30), Vector2(n2_pos + 76, n2_y + 30), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	draw_line(Vector2(n2_pos + 14, n2_y + 50), Vector2(n2_pos + 70, n2_y + 50), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	draw_line(Vector2(n2_pos + 14, n2_y + 70), Vector2(n2_pos + 60, n2_y + 70), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	
	# Sticky Note 3: Pastel Yellow (Right)
	var n3_pos := pos.x + 265.0
	var n3_y := pos.y + 50.0
	draw_rect(Rect2(n3_pos, n3_y, 100, 110), Color("#fef9e7"))
	draw_rect(Rect2(n3_pos, n3_y, 100, 110), INK_MAIN, false, 1.5)
	draw_circle(Vector2(n3_pos + 50, n3_y + 8), 4.0, Color("#e67e22"))
	draw_line(Vector2(n3_pos + 14, n3_y + 32), Vector2(n3_pos + 86, n3_y + 32), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	draw_line(Vector2(n3_pos + 14, n3_y + 52), Vector2(n3_pos + 82, n3_y + 52), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)
	draw_line(Vector2(n3_pos + 14, n3_y + 72), Vector2(n3_pos + 70, n3_y + 72), Color(INK_SOFT.r, INK_SOFT.g, INK_SOFT.b, 0.4), 1.5)

func _draw_fairy_lights(start_p: Vector2, end_p: Vector2, celeb: float) -> void:
	# Curved wire
	var num_pts := 24
	var wire_pts := PackedVector2Array()
	var mid := (start_p + end_p) * 0.5 + Vector2(0, 35.0)
	
	for i in range(num_pts + 1):
		var t := i / float(num_pts)
		var p := (1.0 - t) * (1.0 - t) * start_p + 2.0 * (1.0 - t) * t * mid + t * t * end_p
		wire_pts.append(p)
	draw_polyline(wire_pts, INK_MAIN, 1.5)
	
	# Bulbs
	var bulb_cols := [Color("#e74c3c"), Color("#f1c40f"), Color("#3498db"), Color("#2ecc71"), Color("#e91e63")]
	var num_bulbs := 11
	for b in range(num_bulbs):
		var bt := (b + 0.5) / float(num_bulbs)
		var bp := (1.0 - bt) * (1.0 - bt) * start_p + 2.0 * (1.0 - bt) * bt * mid + bt * bt * end_p
		var col: Color = bulb_cols[b % bulb_cols.size()]
		# Bulb glow if celebration
		if celeb > 0.05:
			draw_circle(bp + Vector2(0, 4), 9.0 * celeb, Color(col.r, col.g, col.b, 0.4 * celeb))
		draw_circle(bp + Vector2(0, 4), 4.5, col)
		draw_circle(bp + Vector2(0, 4), 4.5, INK_MAIN, false, 1.2)

func _draw_party_bunting(celeb: float) -> void:
	# Dropping triangular garland from ceiling
	var y_top := 30.0 + (1.0 - celeb) * -80.0
	var num_flags := 16
	var flag_w := 80.0
	var flag_h := 36.0
	var cols := [Color("#ff7675"), Color("#fdcb6e"), Color("#74b9ff"), Color("#55efc4"), Color("#a29bfe")]
	
	# Main string
	draw_line(Vector2(-50, y_top), Vector2(1330, y_top), INK_MAIN, 2.0)
	
	for f in range(num_flags):
		var fx := f * flag_w - 20.0
		var tri := PackedVector2Array([
			Vector2(fx, y_top),
			Vector2(fx + flag_w, y_top),
			Vector2(fx + flag_w * 0.5, y_top + flag_h)
		])
		draw_colored_polygon(tri, cols[f % cols.size()])
		draw_polyline(tri, INK_MAIN, 1.8, true)

func _draw_confetti(celeb: float) -> void:
	for p in _confetti_particles:
		var pos: Vector2 = p["pos"]
		var rot: float = p["rot"]
		var sz: float = p["size"] * celeb
		var col: Color = p["color"]
		
		draw_set_transform(pos, rot, Vector2.ONE)
		draw_rect(Rect2(-sz * 0.5, -sz * 0.25, sz, sz * 0.5), col)
		draw_rect(Rect2(-sz * 0.5, -sz * 0.25, sz, sz * 0.5), INK_MAIN, false, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# -----------------------------------------------------------------------------
# FOREGROUND DESK WITH STEAMING CAT MUG & DRAWING TABLET
# -----------------------------------------------------------------------------
class Ep05StudioForegroundDesk extends Node2D:
	var backdrop: Ep05CelebrationBackdrop

	func _init(p_backdrop: Ep05CelebrationBackdrop) -> void:
		backdrop = p_backdrop
		z_index = 10 # In front of character waist

	func _draw() -> void:
		var desk_y := 830.0
		
		# 1. Warm Desk Surface
		draw_rect(Rect2(-200, desk_y, 1680, 250), Color("#e2d2be"))
		draw_line(Vector2(-200, desk_y), Vector2(1480, desk_y), Color("#2e1822"), 3.2)
		draw_line(Vector2(-200, desk_y + 10), Vector2(1480, desk_y + 10), Color("#bda58d"), 1.8)
		
		# 2. Modern Drawing Display Monitor (Center-Right)
		var mon_pos := Vector2(700, 805)
		var mon_w := 240.0
		var mon_h := 130.0
		# Monitor Stand
		draw_rect(Rect2(mon_pos.x + mon_w * 0.5 - 18, mon_pos.y + mon_h - 10, 36, 35), Color("#2d3436"))
		# Monitor Bezel
		draw_rect(Rect2(mon_pos.x, mon_pos.y, mon_w, mon_h), Color("#1e272e"))
		draw_rect(Rect2(mon_pos.x, mon_pos.y, mon_w, mon_h), Color("#2e1822"), false, 2.5)
		# Monitor Screen Canvas (Deep navy studio canvas)
		var screen_rect := Rect2(mon_pos.x + 8, mon_pos.y + 8, mon_w - 16, mon_h - 16)
		draw_rect(screen_rect, Color("#34495e"))
		# Screen subtle glare
		draw_line(Vector2(screen_rect.position.x + 10, screen_rect.position.y + 10),
				  Vector2(screen_rect.position.x + 70, screen_rect.end.y - 10),
				  Color(1, 1, 1, 0.15), 18.0)
		
		# 3. Stylus Pen on Desk
		var pen_pos := Vector2(980, 850)
		draw_line(pen_pos, pen_pos + Vector2(45, 80), Color("#2d3436"), 5.0)
		draw_line(pen_pos, pen_pos + Vector2(6, 11), Color("#bdc3c7"), 4.0) # tip
		
		# 4. Steaming Ceramic Cat Mug (Center-Left)
		var mug_pos := Vector2(330, 840)
		# Mug body
		draw_rect(Rect2(mug_pos.x - 20, mug_pos.y, 40, 48), Color("#ffffff"))
		draw_rect(Rect2(mug_pos.x - 20, mug_pos.y, 40, 48), Color("#2e1822"), false, 2.2)
		# Mug Handle
		var handle_pts := PackedVector2Array([
			Vector2(mug_pos.x + 20, mug_pos.y + 10),
			Vector2(mug_pos.x + 32, mug_pos.y + 18),
			Vector2(mug_pos.x + 32, mug_pos.y + 32),
			Vector2(mug_pos.x + 20, mug_pos.y + 38)
		])
		draw_polyline(handle_pts, Color("#2e1822"), 2.2)
		# Cute Cat Face on Mug
		draw_circle(Vector2(mug_pos.x - 8, mug_pos.y + 22), 2.0, Color("#2e1822"))
		draw_circle(Vector2(mug_pos.x + 8, mug_pos.y + 22), 2.0, Color("#2e1822"))
		draw_line(Vector2(mug_pos.x - 3, mug_pos.y + 28), Vector2(mug_pos.x + 3, mug_pos.y + 28), Color("#2e1822"), 1.5)
		
		# Floating Steam Wisps
		var t: float = backdrop._steam_timer if backdrop else 0.0
		for s in range(2):
			var sx := mug_pos.x - 6.0 + s * 12.0
			var sy1 := mug_pos.y - 8.0
			var sy2 := mug_pos.y - 32.0
			var wave := sin(t * 3.0 + s * 1.5) * 6.0
			var steam_pts := PackedVector2Array([
				Vector2(sx, sy1),
				Vector2(sx + wave, (sy1 + sy2) * 0.5),
				Vector2(sx - wave * 0.5, sy2)
			])
			draw_polyline(steam_pts, Color(0.9, 0.9, 0.9, 0.45), 1.8)
