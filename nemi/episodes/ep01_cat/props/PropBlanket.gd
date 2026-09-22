extends Node2D
class_name PropBlanket

## PropBlanket — Hand-Drawn Folded Cat Blanket
## Soft pen-and-ink illustrated blanket/towel where Neeko curls into a loaf.
## Adheres to Nemi's hand-drawn pen-and-ink visual language.

const InkStroke = preload("res://nemi/characters/nemi/drawing/InkStroke.gd")

@export var blanket_width: float = 72.0
@export var blanket_height: float = 38.0
@export var fill_color: Color = Color("#f4ede4") # Warm cream linen
@export var pattern_color: Color = Color(0.35, 0.45, 0.38, 0.25) # Soft sage crosshatch
@export var line_color: Color = Color("#232026") # Authentic near-black ink

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var w := blanket_width * 0.5
	var h := blanket_height * 0.5
	
	# Shadow under blanket
	draw_colored_polygon(PackedVector2Array([
		Vector2(-w * 0.9, h * 0.7),
		Vector2(w * 0.9, h * 0.7),
		Vector2(w * 0.95, h * 1.15),
		Vector2(-w * 0.85, h * 1.15)
	]), Color(0.15, 0.12, 0.12, 0.12))
	
	# Blanket folded shape
	var pts := PackedVector2Array([
		Vector2(-w, -h * 0.5),
		Vector2(-w * 0.8, -h),
		Vector2(w * 0.8, -h),
		Vector2(w, -h * 0.4),
		Vector2(w * 0.95, h * 0.8),
		Vector2(-w * 0.95, h * 0.8),
		Vector2(-w, -h * 0.5)
	])
	
	draw_colored_polygon(pts, fill_color)
	
	# Subtle linen stitch stripes
	for i in range(-2, 3):
		var x := float(i) * (w * 0.3)
		draw_line(Vector2(x, -h * 0.8), Vector2(x + 4.0, h * 0.6), pattern_color, 1.2)
		
	# Pen-and-ink outer contour
	InkStroke.from_points(pts, 2.2, InkStroke.Profile.UNIFORM, line_color).draw_to(self)
	
	# Fold crease line across middle
	var crease := PackedVector2Array([
		Vector2(-w * 0.9, -h * 0.1),
		Vector2(-w * 0.2, -h * 0.05),
		Vector2(w * 0.85, -h * 0.15)
	])
	InkStroke.from_points(crease, 1.5, InkStroke.Profile.TAPER_BOTH, line_color).draw_to(self)

## Settle bounce when Neeko steps or curls onto it
func squish(amount: float = 0.15, duration: float = 0.35) -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.0 + amount * 0.6, 1.0 - amount), duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), duration * 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
