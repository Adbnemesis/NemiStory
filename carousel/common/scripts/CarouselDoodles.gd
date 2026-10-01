class_name CarouselDoodles
extends RefCounted

## Brand-Aware Procedural Doodle Router
## Dispatches procedural doodle drawing to the appropriate brand implementation.

const NemiDoodles = preload("res://carousel/nemi/doodles/NemiBrandDoodles.gd")
const ADBDoodles = preload("res://carousel/adb/doodles/ADBBrandDoodles.gd")

static func draw_doodle(canvas: CanvasItem, brand: String, doodle_name: String, pos: Vector2, d_scale: float = 1.0) -> void:
	match brand:
		"adb":
			ADBDoodles.draw_doodle(canvas, doodle_name, pos, d_scale)
		"nemi", _:
			NemiDoodles.draw_doodle(canvas, doodle_name, pos, d_scale)
