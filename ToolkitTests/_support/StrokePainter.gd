extends Node2D
## Paints one InkStroke (stored in meta "stroke") via draw_to(self).
func _draw() -> void:
	if has_meta("stroke"):
		var stroke: RefCounted = get_meta("stroke")
		if stroke and stroke.has_method("draw_to"):
			stroke.draw_to(self)
